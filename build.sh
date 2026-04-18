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
    echo "Cleaning up dompdf fonts..."
    # Keep only basic fonts if needed, or just let them be if size is okay.
    # For now, we'll just remove the .afm files which are often unnecessary for basic PDF generation
    find "$DOMPDF_FONTS" -name "*.afm" -delete
fi

# 4. Remove other known large unnecessary directories
rm -rf "$VENDOR_DIR/tecnickcom" 2>/dev/null

echo "=== Vendor Cleanup Complete ==="

# Show final size
echo "Final vendor size:"
du -sh "$VENDOR_DIR" 2>/dev/null || ls -lh "$VENDOR_DIR" | head -n 1

exit 0
