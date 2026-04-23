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
GOOGLE_SERVICES_DIR="$VENDOR_DIR/google/apiclient-services/src"
if [ -d "$GOOGLE_SERVICES_DIR" ]; then
    echo "Cleaning Google API Services..."
    # On utilise find pour être très sélectif et éviter les erreurs xargs
    find "$GOOGLE_SERVICES_DIR" -maxdepth 1 -mindepth 1 -type d ! -name "Calendar" ! -name "Oauth2" -exec rm -rf {} + 2>/dev/null || true
    find "$GOOGLE_SERVICES_DIR" -maxdepth 1 -type f ! -name "Calendar.php" ! -name "Oauth2.php" ! -name "autoload.php" -exec rm -f {} + 2>/dev/null || true
fi

# 3. Remove phpseclib and other large dependencies bloat
find "$VENDOR_DIR" -type d -name "tests" -exec rm -rf {} + 2>/dev/null || true
find "$VENDOR_DIR" -type d -name "Tests" -exec rm -rf {} + 2>/dev/null || true
find "$VENDOR_DIR" -type d -name "docs" -exec rm -rf {} + 2>/dev/null || true
find "$VENDOR_DIR" -type d -name "examples" -exec rm -rf {} + 2>/dev/null || true

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
    "Resources" "stubs" "phpstan.neon" "phpunit.xml.dist"
)

for pattern in "${patterns[@]}"; do
    find "$VENDOR_DIR" -name "$pattern" -exec rm -rf {} + 2>/dev/null || true
done

# 6. Remove empty directories
find "$VENDOR_DIR" -type d -empty -delete 2>/dev/null || true

echo "Vendor size after cleanup:"
du -sh "$VENDOR_DIR" 2>/dev/null || true
echo "Total project size:"
du -sh . 2>/dev/null || true

exit 0