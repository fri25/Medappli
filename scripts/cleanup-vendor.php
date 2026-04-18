<?php
/**
 * Cleanup script for vendor directory - removes unnecessary files to reduce bundle size
 * Run: php scripts/cleanup-vendor.php
 * Can be called from vercel.json build process
 */

$vendorPath = __DIR__ . '/../vendor';

if (!is_dir($vendorPath)) {
    echo "Vendor directory not found\n";
    exit(1);
}

// Patterns to remove
$removePatterns = [
    // Documentation
    '*.md' => 'Markdown docs',
    '*.markdown' => 'Markdown files',
    'README*' => 'README files',
    'CHANGELOG*' => 'Changelog files',
    'LICENSE*' => 'License files',
    'COPYING*' => 'Copying files',
    'AUTHORS*' => 'Authors files',
    'CONTRIBUTORS*' => 'Contributors files',
    
    // Build & CI/CD
    '.travis.yml' => 'Travis CI',
    '.travis.yaml' => 'Travis CI YAML',
    'appveyor.yml' => 'AppVeyor',
    '.gitlab-ci.yml' => 'GitLab CI',
    '.github' => 'GitHub actions',
    '.editorconfig' => 'Editor config',
    'Makefile' => 'Makefile',
    'Dockerfile' => 'Dockerfile',
    'docker-compose*' => 'Docker Compose',
    'Jenkinsfile' => 'Jenkins',
    
    // Testing
    'phpunit*' => 'PHPUnit files',
    'psalm*' => 'Psalm files',
    'phpstan*' => 'PHPStan files',
    '.phpunit*' => 'PHPUnit config',
    'tests' => 'Test directories',
    'test' => 'Test directory',
    'Tests' => 'Tests directory',
    
    // Examples & Documentation
    'examples' => 'Examples',
    'example' => 'Example',
    'examples.php' => 'Example PHP file',
    'docs' => 'Documentation',
    'doc' => 'Documentation directory',
    
    // Source control
    '.gitignore' => 'Git ignore files',
    '.gitattributes' => 'Git attributes',
    '.git' => 'Git repositories',
    '.hg' => 'Mercurial',
    '.svn' => 'SVN',
    
    // Config files
    'composer.json' => 'Composer config (in subdirs)',
    'composer.lock' => 'Composer lock (in subdirs)',
    'composer.phar' => 'Composer executable',
    '.composer' => 'Composer directory',
    
    // Node & NPM (if present)
    'package.json' => 'NPM package',
    'package-lock.json' => 'NPM lock',
    'yarn.lock' => 'Yarn lock',
    'node_modules' => 'Node modules',
    
    // Other
    '.editorconfig' => 'Editor config',
    '.env.example' => 'Env example',
    'build' => 'Build directory',
    'dist' => 'Distribution',
];

$removed = 0;
$totalSize = 0;
$errors = 0;

/**
 * Recursively remove files matching patterns
 */
function removeRecursive($path, $pattern) {
    global $removed, $totalSize, $errors;
    
    $pattern = preg_quote($pattern, '/');
    $pattern = str_replace('\*', '.*', $pattern);
    $pattern = '/^' . $pattern . '$/i';
    
    try {
        if (is_dir($path)) {
            $items = @scandir($path);
            if ($items === false) return;
            
            foreach ($items as $item) {
                if ($item === '.' || $item === '..') continue;
                
                $fullPath = $path . DIRECTORY_SEPARATOR . $item;
                
                if (preg_match($pattern, $item)) {
                    if (is_dir($fullPath)) {
                        removeDirectory($fullPath);
                        $removed++;
                    } elseif (is_file($fullPath)) {
                        $size = filesize($fullPath);
                        unlink($fullPath);
                        $totalSize += $size;
                        $removed++;
                    }
                }
            }
        }
    } catch (Exception $e) {
        $errors++;
    }
}

/**
 * Recursively remove directory
 */
function removeDirectory($path) {
    global $totalSize;
    
    if (!is_dir($path)) {
        if (is_file($path)) {
            $size = filesize($path);
            unlink($path);
            $totalSize += $size;
            return;
        }
        return;
    }
    
    $items = @scandir($path);
    if ($items === false) {
        @rmdir($path);
        return;
    }
    
    foreach ($items as $item) {
        if ($item === '.' || $item === '..') continue;
        $fullPath = $path . DIRECTORY_SEPARATOR . $item;
        if (is_dir($fullPath)) {
            removeDirectory($fullPath);
        } else {
            $size = filesize($fullPath);
            @unlink($fullPath);
            $totalSize += $size;
        }
    }
    
    @rmdir($path);
}

echo "=== Vendor Cleanup Started ===\n";

// Remove each pattern from all vendor subdirectories
foreach ($removePatterns as $pattern => $description) {
    $items = @scandir($vendorPath);
    if ($items === false) continue;
    
    foreach ($items as $vendor) {
        if ($vendor === '.' || $vendor === '..' || $vendor === 'autoload.php') continue;
        
        $vendorSubPath = $vendorPath . DIRECTORY_SEPARATOR . $vendor;
        if (!is_dir($vendorSubPath)) continue;
        
        // Check for vendor/vendor/* structure
        $subItems = @scandir($vendorSubPath);
        if ($subItems) {
            foreach ($subItems as $subItem) {
                if ($subItem === '.' || $subItem === '..') continue;
                $fullPath = $vendorSubPath . DIRECTORY_SEPARATOR . $subItem;
                if (is_dir($fullPath)) {
                    removeRecursive($fullPath, $pattern);
                } else {
                    removeRecursive($vendorSubPath, $pattern);
                }
            }
        }
    }
}

echo "\n=== Cleanup Complete ===\n";
echo "Files removed: $removed\n";
echo "Size freed: " . number_format($totalSize / 1024 / 1024, 2) . " MB\n";
echo "Errors: $errors\n";

exit($errors > 0 ? 1 : 0);
