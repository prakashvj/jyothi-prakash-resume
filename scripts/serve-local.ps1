# Simple PowerShell HTTP Server for Local Testing
# Run this script from the src folder to test your resume website locally

param(
    [int]$Port = 8080,
    [string]$Path = "."
)

# Get the absolute path
$AbsolutePath = Resolve-Path $Path

Write-Host "Starting local web server..." -ForegroundColor Green
Write-Host "Serving files from: $AbsolutePath" -ForegroundColor Yellow
Write-Host "Local URL: http://localhost:$Port" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Red
Write-Host ""

# Create HTTP listener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Start()

Write-Host "✅ Server started successfully!" -ForegroundColor Green
Write-Host "🌐 Open http://localhost:$Port in your browser" -ForegroundColor Magenta
Write-Host ""

try {
    while ($listener.IsListening) {
        # Wait for request
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        # Get requested file path
        $requestedPath = $request.Url.AbsolutePath
        if ($requestedPath -eq "/") {
            $requestedPath = "/index.html"
        }
        
        $filePath = Join-Path $AbsolutePath $requestedPath.TrimStart('/')
        
        Write-Host "$(Get-Date -Format 'HH:mm:ss') - $($request.HttpMethod) $requestedPath" -ForegroundColor Gray
        
        if (Test-Path $filePath -PathType Leaf) {
            # File exists, serve it
            $content = [System.IO.File]::ReadAllBytes($filePath)
            $response.ContentLength64 = $content.Length
            
            # Set content type based on file extension
            $extension = [System.IO.Path]::GetExtension($filePath).ToLower()
            switch ($extension) {
                ".html" { $response.ContentType = "text/html" }
                ".css"  { $response.ContentType = "text/css" }
                ".js"   { $response.ContentType = "application/javascript" }
                ".json" { $response.ContentType = "application/json" }
                ".png"  { $response.ContentType = "image/png" }
                ".jpg"  { $response.ContentType = "image/jpeg" }
                ".jpeg" { $response.ContentType = "image/jpeg" }
                ".gif"  { $response.ContentType = "image/gif" }
                ".svg"  { $response.ContentType = "image/svg+xml" }
                ".ico"  { $response.ContentType = "image/x-icon" }
                ".woff" { $response.ContentType = "font/woff" }
                ".woff2" { $response.ContentType = "font/woff2" }
                default { $response.ContentType = "application/octet-stream" }
            }
            
            $response.StatusCode = 200
            $response.OutputStream.Write($content, 0, $content.Length)
        } else {
            # File not found, serve index.html for SPA routing
            $indexPath = Join-Path $AbsolutePath "index.html"
            if (Test-Path $indexPath) {
                $content = [System.IO.File]::ReadAllBytes($indexPath)
                $response.ContentLength64 = $content.Length
                $response.ContentType = "text/html"
                $response.StatusCode = 200
                $response.OutputStream.Write($content, 0, $content.Length)
            } else {
                # Return 404
                $errorContent = [System.Text.Encoding]::UTF8.GetBytes("404 - File Not Found")
                $response.ContentLength64 = $errorContent.Length
                $response.ContentType = "text/plain"
                $response.StatusCode = 404
                $response.OutputStream.Write($errorContent, 0, $errorContent.Length)
            }
        }
        
        $response.Close()
    }
} catch {
    Write-Host "Server stopped or error occurred: $($_.Exception.Message)" -ForegroundColor Red
} finally {
    $listener.Stop()
    Write-Host "Server stopped." -ForegroundColor Yellow
}
