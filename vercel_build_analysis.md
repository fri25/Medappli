# Vercel Build Error Analysis & Resolution

The error `Error: Command "vercel build" exited with 1` with the message `Cannot set properties of undefined (setting 'mode')` is a known bug in **Vercel CLI 52.0.0** when using community builders like `vercel-php` on Windows.

## Findings
1. **CLI Compatibility**: Vercel CLI 52.0.0 has internal changes in how it handles local builds, which causes the community PHP builder to crash when trying to set file permissions (`mode`) on Windows.
2. **Local vs. Remote**: This error primarily affects **local builds** performed by the CLI. A remote build (triggered by pushing to GitHub) is likely to succeed as it runs on a Linux environment.
3. **Symlink Issues**: Attempting to downgrade or switch builders locally on Windows often results in `EPERM` (Permission Denied) because the CLI tries to create symlinks.

## Recommended Actions

### 1. Update `vercel.json` to a Stable State
We have reverted `vercel.json` to use the standard `functions` configuration with `vercel-php@0.9.0`.

### 2. Workaround for CLI Deployment
If you must deploy from the command line on Windows:
- **Run Terminal as Administrator**: This may resolve the `EPERM` symlink errors.
- **Use an older CLI version**: Try running `npx vercel@51 --prod`.

### 3. Preferred Deployment Method
**Push to GitHub**: Pushing your changes will trigger a Vercel build on their servers (Linux), which bypasses the Windows-specific CLI bugs.

---

## Final `vercel.json` Configuration
I have set up the following configuration which is the most compatible:

```json
{
  "version": 2,
  "functions": {
    "api/index.php": {
      "runtime": "vercel-php@0.9.0"
    }
  },
  "rewrites": [
    { "source": "/assets/(.*)", "destination": "/public/assets/$1" },
    { "source": "/(.*)", "destination": "/api/index.php" }
  ]
}
```
