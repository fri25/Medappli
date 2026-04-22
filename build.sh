#!/bin/bash

# Vercel build script for vendor optimization
# Vercel already runs composer install automatically — we just clean up

VENDOR_DIR="vendor"

echo "=== Starting Build Process ==="

if [ ! -d "$VENDOR_DIR" ]; then
    echo "Vendor directory not found! Running composer install..."
    composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --apcu-autoloader
fi

if [ ! -d "$VENDOR_DIR" ]; then
    echo "Vendor directory still not found!"
    exit 1
fi

echo "Vendor size before cleanup:"
du -sh "$VENDOR_DIR" 2>/dev/null

echo "=== Starting Aggressive Vendor Cleanup ==="

# 1. Remove .git directories FIRST (they are huge — 25MB+ in google/auth alone)
find "$VENDOR_DIR" -type d -name ".git" -exec rm -rf {} + 2>/dev/null
echo "Removed .git directories"

# 2. Google API Client Services: keep ONLY Calendar and Oauth2
GOOGLE_SERVICES_DIR="$VENDOR_DIR/google/apiclient-services/src"
if [ -d "$GOOGLE_SERVICES_DIR" ]; then
    echo "Cleaning Google API Services (keeping only Calendar + Oauth2)..."
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
fi

# 3. Remove phpseclib unnecessary files (keep only what's needed for RSA/OAuth)
# Remove C/C++ source, tests, build files
find "$VENDOR_DIR/phpseclib" -type d -name "tests" -exec rm -rf {} + 2>/dev/null
find "$VENDOR_DIR/phpseclib" -type f \( -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.a" \) -delete 2>/dev/null

# 4. Broad pattern cleanup
patterns=(
    ".github" ".gitignore" ".gitattributes" ".travis.yml" ".travis.yaml"
    ".editorconfig" "appveyor.yml" ".gitlab-ci.yml" "Dockerfile" "Jenkinsfile"
    "tests" "Tests" "test" "docs" "doc" "examples" "example" "phpunit*"
    "psalm*" "phpstan*" "Makefile" "CHANGELOG*" "CONTRIBUTING*" "README*"
    "LICENSE*" "*.md" "*.MD" "*.txt" "composer.json" "composer.lock"
    "*.yml" "*.yaml" "*.xml" "*.dist" "bin" "vendor-bin"
    ".repo-metadata.json" "renovate.json" ".php-cs-fixer*" ".phpcs*"
    "src/Cache" "src/Session" "Resources" "stubs"
)

for pattern in "${patterns[@]}"; do
    find "$VENDOR_DIR" -name "$pattern" -exec rm -rf {} + 2>/dev/null
done

# 5. Remove empty directories
find "$VENDOR_DIR" -type d -empty -delete 2>/dev/null

# 6. Dump optimized autoloader (critical — reflects removed files)
composer dump-autoload --optimize --no-dev --no-interaction 2>/dev/null || true

echo "=== Vendor Cleanup Complete ==="

echo "Vendor size after cleanup:"
du -sh "$VENDOR_DIR" 2>/dev/null || echo "Cannot measure"

echo "Total project size:"
du -sh . 2>/dev/null || echo "Cannot measure"

exit 0
