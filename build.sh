#!/bin/bash

# Vercel build script for vendor optimization
# Removes unnecessary files from vendor directory to reduce bundle size

VENDOR_DIR="vendor"

echo "=== Starting Build Process ==="

# 1. Install dependencies with production optimizations
if command -v composer >/dev/null 2>&1; then
    echo "Running composer install --no-dev --optimize-autoloader..."
    composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
    # Forcer le cleanup Google s'il est configuré
    composer dump-autoload --optimize --no-dev
else
    echo "Composer not found! Trying to use local vendor if it exists."
fi

if [ ! -d "$VENDOR_DIR" ]; then
    echo "Vendor directory not found!"
    exit 1
fi

echo "=== Starting Vendor Cleanup ==="

# 1. Patterns for files and directories to remove
patterns=(
    ".github" ".git" ".gitignore" ".gitattributes" ".travis.yml" ".travis.yaml"
    ".editorconfig" "appveyor.yml" ".gitlab-ci.yml" "Dockerfile" "Jenkinsfile"
    "tests" "Tests" "test" "docs" "doc" "examples" "example" "phpunit*"
    "psalm*" "phpstan*" "Makefile" "CHANGELOG*" "CONTRIBUTING*" "README*"
    "LICENSE*" "*.md" "*.MD" "*.txt" "composer.json" "composer.lock"
    "*.yml" "*.yaml" "*.xml" "*.dist" "bin"
    "*.a" "*.c" "*.h" "*.cpp" # Remove C/C++ source and static libs
)

# Find and remove files/directories in vendor
for pattern in "${patterns[@]}"; do
    find "$VENDOR_DIR" -name "$pattern" -exec rm -rf {} + 2>/dev/null
done

# 2. Specific cleanup for Google API Client Services
GOOGLE_SERVICES_DIR="$VENDOR_DIR/google/apiclient-services/src"
if [ -d "$GOOGLE_SERVICES_DIR" ]; then
    echo "Current Google Services size:"
    du -sh "$GOOGLE_SERVICES_DIR" 2>/dev/null
    
    echo "Force optimizing Google API Services..."
    # On ne garde que Oauth2 et Calendar, on supprime tout le reste
    find "$GOOGLE_SERVICES_DIR" -maxdepth 1 -mindepth 1 -type d | while read dir; do
        service_name=$(basename "$dir")
        if [[ "$service_name" != "Calendar" && "$service_name" != "Oauth2" ]]; then
            rm -rf "$dir"
        fi
    done
    
    find "$GOOGLE_SERVICES_DIR" -maxdepth 1 -type f -name "*.php" | while read file; do
        file_name=$(basename "$file")
        if [[ "$file_name" != "Calendar.php" && "$file_name" != "Oauth2.php" ]]; then
            rm -f "$file"
        fi
    done
    echo "Google Services size after cleanup:"
    du -sh "$GOOGLE_SERVICES_DIR" 2>/dev/null
fi

# 3. Final aggressive cleanup
find "$VENDOR_DIR" -type d -empty -delete 2>/dev/null

echo "=== Vendor Cleanup Complete ==="

# Show final size
echo "Final vendor size:"
du -sh "$VENDOR_DIR" 2>/dev/null || ls -lh "$VENDOR_DIR" | head -n 1

echo "Total project size:"
du -sh . 2>/dev/null

exit 0
