// Resume Website Interactive Features and Functionality
document.addEventListener('DOMContentLoaded', function() {
    // Initialize all features when the page loads
    initializeNavigation();
    initializeScrollEffects();
    initializeContactInteractions();
    initializeSkillAnimations();
    initializeThemeToggle();
    initializeAccessibility();
    
    console.log('Resume website loaded successfully');
});

/**
 * Navigation and Scroll-to-Section Functionality
 */
function initializeNavigation() {
    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            if (targetElement) {
                targetElement.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        });
    });
    
    // Add scroll indicator for mobile
    if (window.innerWidth <= 768) {
        addScrollIndicator();
    }
}

/**
 * Scroll Effects and Animations
 */
function initializeScrollEffects() {
    // Intersection Observer for fade-in animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);
    
    // Observe sections for animation
    document.querySelectorAll('.section').forEach(section => {
        section.classList.add('animate-on-scroll');
        observer.observe(section);
    });
    
    // Progress indicator
    addScrollProgress();
}

/**
 * Contact Information Interactions
 */
function initializeContactInteractions() {
    // Copy email to clipboard functionality
    const emailElement = document.querySelector('a[href^="mailto:"]');
    if (emailElement) {
        emailElement.addEventListener('click', function(e) {
            if (navigator.clipboard) {
                e.preventDefault();
                const email = this.href.replace('mailto:', '');
                navigator.clipboard.writeText(email).then(() => {
                    showToast('Email copied to clipboard!');
                }).catch(() => {
                    // Fallback - just follow the link
                    window.location.href = this.href;
                });
            }
        });
    }
    
    // LinkedIn profile tracking (for analytics if needed)
    const linkedinElement = document.querySelector('a[href*="linkedin.com"]');
    if (linkedinElement) {
        linkedinElement.addEventListener('click', function() {
            console.log('LinkedIn profile visited');
            // Add analytics tracking here if needed
        });
    }
}

/**
 * Skill Category Hover Effects and Interactions
 */
function initializeSkillAnimations() {
    const skillCategories = document.querySelectorAll('.skill-category');
    
    skillCategories.forEach(category => {
        category.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-2px)';
            this.style.boxShadow = '0 8px 25px rgba(0, 0, 0, 0.15)';
        });
        
        category.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = '0 2px 10px rgba(0, 0, 0, 0.1)';
        });
        
        // Add skill tags interaction
        const skillTags = category.querySelectorAll('.skill-tag');
        skillTags.forEach(tag => {
            tag.addEventListener('click', function() {
                this.classList.toggle('highlighted');
                // Could add skill filtering functionality here
            });
        });
    });
}

/**
 * Theme Toggle (Light/Dark Mode)
 */
function initializeThemeToggle() {
    // Create theme toggle button
    const themeToggle = document.createElement('button');
    themeToggle.innerHTML = '🌙';
    themeToggle.className = 'theme-toggle';
    themeToggle.setAttribute('aria-label', 'Toggle dark mode');
    themeToggle.title = 'Toggle dark/light theme';
    
    // Add to header
    const header = document.querySelector('.header');
    if (header) {
        header.appendChild(themeToggle);
    }
    
    // Check for saved theme preference
    const savedTheme = localStorage.getItem('resume-theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    
    if (savedTheme === 'dark' || (!savedTheme && prefersDark)) {
        document.body.classList.add('dark-theme');
        themeToggle.innerHTML = '☀️';
    }
    
    // Theme toggle functionality
    themeToggle.addEventListener('click', function() {
        document.body.classList.toggle('dark-theme');
        const isDark = document.body.classList.contains('dark-theme');
        
        themeToggle.innerHTML = isDark ? '☀️' : '🌙';
        localStorage.setItem('resume-theme', isDark ? 'dark' : 'light');
        
        showToast(`Switched to ${isDark ? 'dark' : 'light'} theme`);
    });
}

/**
 * Accessibility Enhancements
 */
function initializeAccessibility() {
    // Keyboard navigation improvements
    document.addEventListener('keydown', function(e) {
        // Skip to main content with Tab
        if (e.key === 'Tab' && !e.shiftKey && document.activeElement === document.body) {
            const mainContent = document.querySelector('.main-content');
            if (mainContent) {
                mainContent.focus();
                e.preventDefault();
            }
        }
    });
    
    // Focus indicators for keyboard users
    document.addEventListener('keydown', function() {
        document.body.classList.add('keyboard-user');
    });
    
    document.addEventListener('mousedown', function() {
        document.body.classList.remove('keyboard-user');
    });
    
    // Announce section changes for screen readers
    const sections = document.querySelectorAll('.section');
    sections.forEach(section => {
        section.setAttribute('role', 'region');
        const title = section.querySelector('.section-title');
        if (title) {
            section.setAttribute('aria-labelledby', title.id || `section-${Math.random().toString(36).substr(2, 9)}`);
        }
    });
}

/**
 * Utility Functions
 */
function addScrollIndicator() {
    const indicator = document.createElement('div');
    indicator.className = 'scroll-indicator';
    indicator.innerHTML = '↓ Scroll to explore';
    
    const header = document.querySelector('.header');
    if (header) {
        header.appendChild(indicator);
        
        // Hide indicator after first scroll
        let hasScrolled = false;
        window.addEventListener('scroll', function() {
            if (!hasScrolled && window.scrollY > 100) {
                indicator.style.opacity = '0';
                hasScrolled = true;
                setTimeout(() => indicator.remove(), 300);
            }
        });
    }
}

function addScrollProgress() {
    const progressBar = document.createElement('div');
    progressBar.className = 'scroll-progress';
    document.body.appendChild(progressBar);
    
    window.addEventListener('scroll', function() {
        const windowHeight = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (window.scrollY / windowHeight) * 100;
        progressBar.style.width = scrolled + '%';
    });
}

function showToast(message, duration = 3000) {
    // Remove existing toast
    const existingToast = document.querySelector('.toast');
    if (existingToast) {
        existingToast.remove();
    }
    
    // Create new toast
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'polite');
    
    document.body.appendChild(toast);
    
    // Show toast
    setTimeout(() => toast.classList.add('show'), 100);
    
    // Hide and remove toast
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, duration);
}

/**
 * Performance Optimizations
 */
// Debounce function for scroll events
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Lazy loading for any images (if added later)
function initializeLazyLoading() {
    if ('IntersectionObserver' in window) {
        const imageObserver = new IntersectionObserver((entries, observer) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    const img = entry.target;
                    img.src = img.dataset.src;
                    img.classList.remove('lazy');
                    observer.unobserve(img);
                }
            });
        });
        
        document.querySelectorAll('img[data-src]').forEach(img => {
            imageObserver.observe(img);
        });
    }
}

/**
 * Error Handling and Fallbacks
 */
window.addEventListener('error', function(e) {
    console.error('Resume website error:', e.error);
    // Could send error reports to analytics service
});

// Service Worker registration for offline functionality (optional)
if ('serviceWorker' in navigator) {
    window.addEventListener('load', function() {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => console.log('SW registered'))
            .catch(registrationError => console.log('SW registration failed'));
    });
}

// Add last updated timestamp
function updateLastModified() {
    const lastUpdatedElement = document.getElementById('lastUpdated');
    if (lastUpdatedElement) {
        const now = new Date();
        lastUpdatedElement.textContent = now.toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
        });
    }
}

// Initialize last updated timestamp
updateLastModified();

// Export functions for testing (if needed)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initializeNavigation,
        initializeScrollEffects,
        initializeContactInteractions,
        initializeSkillAnimations,
        showToast,
        debounce,
        updateLastModified
    };
}
