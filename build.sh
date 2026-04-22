#!/bin/bash

# Post-install cleanup script for Vercel
# Runs via composer post-install-cmd AFTER composer install completes
# Vercel auto-runs composer install when composer.json is detected
# No npm/node_modules since Tailwind is loaded via CDN

VENDOR_DIR="vendor"

echo "=== Post-Install Cleanup ==="

if [ ! -d "$VENDOR_DIR" ]; then
    echo "Vendor directory not found, nothing to clean."
    exit 0
fi

echo "Vendor size before cleanup:"
du -sh "$VENDOR_DIR" 2>/dev/null || true

# 1. Remove .git directories (25MB+ in google/auth alone)
find "$VENDOR_DIR" -type d -name ".git" -exec rm -rf {} + 2>/dev/null || true
echo "Removed .git directories"

# 2. Google API Client Services: keep ONLY Calendar and Oauth2
# (pre-autoload-dump Google cleanup should have run, but double-check)
GOOGLE_SERVICES_DIR="$VENDOR_DIR/google/apiclient-services/src"
if [ -d "$GOOGLE_SERVICES_DIR" ]; then
    echo "Cleaning Google API Services..."
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

# 3. Remove phpseclib bloat
find "$VENDOR_DIR/phpseclib" -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true
find "$VENDOR_DIR/phpseclib" -type f \( -name "*.c" -o -name "*.h" -o -name "*.cpp" -o -name "*.a" \) -delete 2>/dev/null || true

# 4. Remove dompdf unused fonts
if [ -d "$VENDOR_DIR/dompdf/dompdf/lib/fonts" ]; then
    echo "Cleaning dompdf fonts..."
    find "$VENDOR_DIR/dompdf/dompdf/lib/fonts" -type f ! -name "DejaVu*" ! -name "Helvetica*" -delete 2>/dev/null || true
fi

# 5. Broad pattern cleanup
patterns=(
    ".github" ".gitignore" ".gitattributes" ".travis.yml" ".travis.yaml"
    ".editorconfig" "appveyor.yml" ".gitlab-ci.yml" "Dockerfile" "Jenkinsfile"
    "tests" "Tests" "test" "docs" "doc" "examples" "example" "phpunit*"
    "psalm*" "phpstan*" "Makefile" "CHANGELOG*" "CONTRIBUTING*" "README*"
    "LICENSE*" "*.md" "*.MD" "*.txt" "composer.json" "composer.lock"
    "*.yml" "*.yaml" "*.xml" "*.dist" "bin" "vendor-bin"
    ".repo-metadata.json" "renovate.json" ".php-cs-fixer*" ".phpcs*"
    "Resources" "stubs"
)

for pattern in "${patterns[@]}"; do
    find "$VENDOR_DIR" -name "$pattern" -exec rm -rf {} + 2>/dev/null || true
done

# 6. Remove empty directories
find "$VENDOR_DIR" -type d -empty -delete 2>/dev/null || true

# 7. Regenerate autoloader to reflect removed files
composer dump-autoload --optimize --no-dev --no-interaction 2>/dev/null || true

echo "Vendor size after cleanup:"
du -sh "$VENDOR_DIR" 2>/dev/null || true
echo "Total project size:"
du -sh . 2>/dev/null || true

exit 0
