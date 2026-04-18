#!/bin/bash

# Vercel build script for vendor cleanup
# Removes unnecessary files from vendor directory to reduce bundle size

VENDOR_DIR="vendor"

if [ ! -d "$VENDOR_DIR" ]; then
    echo "Vendor directory not found"
    exit 1
fi

echo "=== Starting Vendor Cleanup ==="

# Remove patterns
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
)

# Find and remove files in vendor subdirectories
for pattern in "${patterns[@]}"; do
    find "$VENDOR_DIR" -type d -name "$pattern" 2>/dev/null | while read dir; do
        rm -rf "$dir"
        echo "Removed: $dir"
    done
    find "$VENDOR_DIR" -type f -name "$pattern" 2>/dev/null | while read file; do
        rm -f "$file"
        echo "Removed: $file"
    done
done

# Remove specific files
find "$VENDOR_DIR" -type f \( -name "README*" -o -name "CHANGELOG*" -o -name "LICENSE*" -o -name "*.md" -o -name "*.MD" -o -name "composer.json" -o -name "composer.lock" -o -name "composer.phar" -o -name "*.yml" -o -name "*.yaml" -o -name "*.xml" -o -name "*.dist" -o -name "*.phar" \) 2>/dev/null | while read file; do
    rm -f "$file"
done

# Remove bin directories except critical ones
find "$VENDOR_DIR" -type d -name "bin" 2>/dev/null | while read dir; do
    # Keep only essential binaries if needed
    rm -rf "$dir"
    echo "Removed: $dir"
done

echo "=== Vendor Cleanup Complete ==="

# Show final size
du -sh "$VENDOR_DIR"

exit 0
