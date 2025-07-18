#!/bin/bash

# Azure Static Web App Deployment Script (Bash version)
# This script reads configuration from environment files and deploys the application

set -e  # Exit on any error

# Default values
ENVIRONMENT=${1:-dev}
CONFIG_PATH=${2:-./config}
VALIDATE_ONLY=${VALIDATE_ONLY:-false}
WHAT_IF=${WHAT_IF:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "ERROR")
            echo -e "[$timestamp] [${RED}ERROR${NC}] $message" >&2
            ;;
        "WARN")
            echo -e "[$timestamp] [${YELLOW}WARN${NC}] $message"
            ;;
        "SUCCESS")
            echo -e "[$timestamp] [${GREEN}SUCCESS${NC}] $message"
            ;;
        *)
            echo -e "[$timestamp] [INFO] $message"
            ;;
    esac
}

# Load configuration function
load_configuration() {
    local environment=$1
    local config_path=$2
    
    log "INFO" "Loading configuration for environment: $environment"
    
    # Create associative array for configuration
    declare -A config
    
    # Load .env template first
    local env_template="$config_path/.env.template"
    if [[ -f "$env_template" ]]; then
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            if [[ ! $key =~ ^# ]] && [[ -n $key ]]; then
                key=$(echo "$key" | xargs)  # trim whitespace
                value=$(echo "$value" | xargs)  # trim whitespace
                config[$key]=$value
            fi
        done < "$env_template"
    fi
    
    # Load environment-specific configuration from JSON
    local env_json="$config_path/environments.json"
    if [[ -f "$env_json" ]]; then
        # Extract environment-specific config using jq if available
        if command -v jq &> /dev/null; then
            local env_config=$(jq -r ".environments.$environment // empty" "$env_json")
            if [[ -n "$env_config" ]]; then
                # Parse JSON and update config array
                while IFS='=' read -r key value; do
                    if [[ -n $key ]]; then
                        config[$key]=$value
                    fi
                done < <(echo "$env_config" | jq -r 'to_entries[] | "\(.key)=\(.value)"')
            fi
        fi
    fi
    
    # Load from actual .env file if it exists
    local env_file="$config_path/.env"
    if [[ -f "$env_file" ]]; then
        while IFS='=' read -r key value; do
            if [[ ! $key =~ ^# ]] && [[ -n $key ]]; then
                key=$(echo "$key" | xargs)
                value=$(echo "$value" | xargs)
                config[$key]=$value
            fi
        done < "$env_file"
    fi
    
    # Export configuration to environment variables
    for key in "${!config[@]}"; do
        export "$key"="${config[$key]}"
        echo "export $key=\"${config[$key]}\""
    done
}

# Validate configuration function
validate_configuration() {
    log "INFO" "Validating configuration..."
    
    local required_vars=(
        "AZURE_SUBSCRIPTION_ID"
        "AZURE_TENANT_ID"
        "AZURE_LOCATION"
        "AZURE_RESOURCE_GROUP_NAME"
        "AZURE_STATIC_WEB_APP_NAME"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log "ERROR" "Missing required configuration variables: ${missing_vars[*]}"
        return 1
    fi
    
    # Validate GUID format for subscription and tenant
    local guid_pattern="^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
    
    if [[ ! $AZURE_SUBSCRIPTION_ID =~ $guid_pattern ]]; then
        log "ERROR" "Invalid AZURE_SUBSCRIPTION_ID format. Must be a valid GUID."
        return 1
    fi
    
    if [[ ! $AZURE_TENANT_ID =~ $guid_pattern ]]; then
        log "ERROR" "Invalid AZURE_TENANT_ID format. Must be a valid GUID."
        return 1
    fi
    
    log "SUCCESS" "Configuration validation passed!"
    return 0
}

# Deploy application function
deploy_application() {
    log "INFO" "Starting deployment process..."
    
    if [[ "$WHAT_IF" == "true" ]]; then
        log "WARN" "WhatIf mode - showing what would be deployed:"
        log "INFO" "  Subscription: $AZURE_SUBSCRIPTION_ID"
        log "INFO" "  Resource Group: $AZURE_RESOURCE_GROUP_NAME"
        log "INFO" "  Static Web App: $AZURE_STATIC_WEB_APP_NAME"
        log "INFO" "  Location: $AZURE_LOCATION"
        return 0
    fi
    
    # Check if azd is available
    if ! command -v azd &> /dev/null; then
        log "ERROR" "Azure Developer CLI (azd) not found. Please install it first."
        log "ERROR" "Install instructions: https://docs.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd"
        exit 1
    fi
    
    local azd_version=$(azd version 2>/dev/null || echo "unknown")
    log "INFO" "Using Azure Developer CLI version: $azd_version"
    
    # Initialize azd environment if not exists
    log "INFO" "Initializing azd environment: $AZURE_ENV_NAME"
    
    if ! azd env select "$AZURE_ENV_NAME" 2>/dev/null; then
        log "INFO" "Creating new azd environment: $AZURE_ENV_NAME"
        azd env new "$AZURE_ENV_NAME" --location "$AZURE_LOCATION"
    fi
    
    # Deploy the application
    log "INFO" "Deploying application using azd..."
    if azd up --no-prompt; then
        log "SUCCESS" "Deployment completed successfully!"
        
        # Try to get the deployed URL
        if command -v jq &> /dev/null; then
            local endpoint=$(azd show --output json 2>/dev/null | jq -r '.services.web.endpoint // empty')
            if [[ -n "$endpoint" ]]; then
                log "SUCCESS" "Website URL: $endpoint"
            fi
        fi
    else
        log "ERROR" "Deployment failed. Check the azd output above for details."
        exit 1
    fi
}

# Main execution
main() {
    log "SUCCESS" "=== Azure Static Web App Deployment Script ==="
    log "INFO" "Environment: $ENVIRONMENT"
    log "INFO" "Config Path: $CONFIG_PATH"
    
    # Load configuration
    eval "$(load_configuration "$ENVIRONMENT" "$CONFIG_PATH")"
    
    # Validate configuration
    if ! validate_configuration; then
        log "ERROR" "Configuration validation failed. Please fix the issues above."
        exit 1
    fi
    
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        log "SUCCESS" "Configuration validation completed successfully!"
        exit 0
    fi
    
    # Deploy application
    deploy_application
    
    log "SUCCESS" "=== Deployment Script Completed ==="
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [ENVIRONMENT] [CONFIG_PATH]"
        echo "       $0 --validate [ENVIRONMENT] [CONFIG_PATH]"
        echo "       $0 --what-if [ENVIRONMENT] [CONFIG_PATH]"
        echo ""
        echo "Arguments:"
        echo "  ENVIRONMENT   Environment to deploy (default: dev)"
        echo "  CONFIG_PATH   Path to configuration files (default: ./config)"
        echo ""
        echo "Environment Variables:"
        echo "  VALIDATE_ONLY=true   Only validate configuration"
        echo "  WHAT_IF=true        Show what would be deployed"
        exit 0
        ;;
    --validate)
        VALIDATE_ONLY=true
        ENVIRONMENT=${2:-dev}
        CONFIG_PATH=${3:-./config}
        ;;
    --what-if)
        WHAT_IF=true
        ENVIRONMENT=${2:-dev}
        CONFIG_PATH=${3:-./config}
        ;;
esac

# Run main function
main
