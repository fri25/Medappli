#!/bin/bash

# Vercel build script for vendor optimization
# Removes unnecessary files from vendor directory to reduce bundle size

VENDOR_DIR="vendor"

echo "=== Starting Build Process ==="

# 1. Install dependencies with production optimizations
if command -v composer >/dev/null 2>&1; then
    echo "Running composer install..."
    composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
    # Run the google cleanup task manually if it exists
    composer dump-autoload --optimize --no-dev
else
    echo "Composer not found, skipping install (assuming vendor already exists)"
fi

if [ ! -d "$VENDOR_DIR" ]; then
    echo "Vendor directory not found!"
    exit 1
fi

echo "=== Starting Vendor Cleanup ==="

# Patterns for files and directories to remove
patterns=(
    ".github"
    ".git"
    ".gitignore"
    ".gitattributes"
    ".travis.yml"
    ".travis.yaml"
    ".editorconfig"
    "appveyor.yml"
    ".gitlab-ci.yml"
    "Dockerfile"
    "Jenkinsfile"
    "tests"
    "Tests"
    "test"
    "docs"
    "doc"
    "examples"
    "example"
    "phpunit*"
    "psalm*"
    "phpstan*"
    "Makefile"
    "CHANGELOG*"
    "CONTRIBUTING*"
    "README*"
    "LICENSE*"
    "*.md"
    "*.MD"
    "*.txt"
    "composer.json"
    "composer.lock"
    "*.yml"
    "*.yaml"
    "*.xml"
    "*.dist"
    "bin"
)

# Find and remove files/directories in vendor
for pattern in "${patterns[@]}"; do
    find "$VENDOR_DIR" -name "$pattern" -exec rm -rf {} + 2>/dev/null
done

# 2. Specific cleanup for Google API Client Services
# This is the biggest part of the bundle. 
# Even if composer cleanup runs, we want to be sure only Oauth2 and Calendar are kept.
GOOGLE_SERVICES_DIR="$VENDOR_DIR/google/apiclient-services/src"
if [ -d "$GOOGLE_SERVICES_DIR" ]; then
    echo "Optimizing Google API Services..."
    # List of services to KEEP (case sensitive)
    # We keep Calendar, Oauth2 and common files
    find "$GOOGLE_SERVICES_DIR" -maxdepth 1 -mindepth 1 -type d | while read dir; do
        service_name=$(basename "$dir")
        if [[ "$service_name" != "Calendar" && "$service_name" != "Oauth2" ]]; then
            rm -rf "$dir"
        fi
    done
    
    # Also remove corresponding .php files in the src root except the kept ones
    find "$GOOGLE_SERVICES_DIR" -maxdepth 1 -type f -name "*.php" | while read file; do
        file_name=$(basename "$file")
        if [[ "$file_name" != "Calendar.php" && "$file_name" != "Oauth2.php" ]]; then
            rm -f "$file"
        fi
    done
fi

# 3. Specific cleanup for dompdf (remove extra fonts)
DOMPDF_FONTS="$VENDOR_DIR/dompdf/dompdf/lib/fonts"
if [ -d "$DOMPDF_FONTS" ]; then
    echo "Extreme cleaning of dompdf fonts..."
    # Keep ONLY the bare minimum for Helvetica
    find "$DOMPDF_FONTS" -type f ! -name "Helvetica*" -delete
fi

# 4. Specific cleanup for PHPMailer (remove extra languages)
PHPMAILER_LANG="$VENDOR_DIR/phpmailer/phpmailer/language"
if [ -d "$PHPMAILER_LANG" ]; then
    echo "Cleaning up PHPMailer languages..."
    find "$PHPMAILER_LANG" -type f ! -name "phpmailer.lang-fr.php" -delete
fi

# 5. Global Cleanup: Remove all tests, docs, and non-essential files recursively
echo "Global cleanup of tests, docs, and SQL files..."
find . -type d -name "tests" -exec rm -rf {} + 2>/dev/null
find . -type d -name "Tests" -exec rm -rf {} + 2>/dev/null
find . -type d -name "docs" -exec rm -rf {} + 2>/dev/null
find . -type d -name ".github" -exec rm -rf {} + 2>/dev/null
find . -type f -name "*.md" -delete 2>/dev/null
find . -type f -name "*.sql" -delete 2>/dev/null
find . -type f -name "*.txt" -delete 2>/dev/null
find . -type f -name "composer.lock" -delete 2>/dev/null

echo "=== Extreme Cleanup Complete ==="
# Show final size
du -sh . 2>/dev/null || ls -lh . | head -n 1
exit 0
