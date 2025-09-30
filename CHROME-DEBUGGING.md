# Connecting to Existing Chrome Instance

This guide explains how to connect the Strudel MCP server to an existing Chrome/Chromium browser instance instead of launching a new one.

## Table of Contents
- [Why Use an Existing Chrome Instance?](#why-use-an-existing-chrome-instance)
- [Quick Start](#quick-start)
- [Platform-Specific Instructions](#platform-specific-instructions)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)

## Why Use an Existing Chrome Instance?

Using an existing Chrome instance provides several benefits:

- **✅ Use Your Profile**: Access bookmarks, extensions, and saved passwords
- **✅ Visual Control**: Keep the browser visible and interact with it directly
- **✅ Session Persistence**: Reuse existing Strudel.cc sessions
- **✅ DevTools Access**: Use Chrome DevTools alongside the MCP server
- **✅ Multiple Tabs**: Work with multiple Strudel patterns in different tabs
- **✅ Resource Efficiency**: Share the same browser instance across tools

## Quick Start

### 1. Launch Chrome with Remote Debugging

Choose the command for your operating system:

#### macOS
```bash
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222
```

#### Linux
```bash
google-chrome --remote-debugging-port=9222
# or
chromium --remote-debugging-port=9222
```

#### Windows
```cmd
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

### 2. Configure Strudel MCP Server

Edit `config.json` in the strudel-mcp-server directory:

```json
{
  "cdpEndpoint": "http://localhost:9222",
  "strudel_url": "https://strudel.cc/",
  "patterns_dir": "./patterns",
  "audio_analysis": {
    "fft_size": 2048,
    "smoothing": 0.8
  }
}
```

### 3. Use the Server

Start using the MCP server as normal:

```bash
# If installed globally
strudel-mcp

# If built from source
node dist/index.js
```

When you call the `init` tool, it will:
1. Connect to your existing Chrome instance
2. Look for an existing Strudel.cc tab
3. Use the existing tab if found, or create a new one

## Platform-Specific Instructions

### macOS

#### Using Chrome
```bash
# Standard location
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Chrome Canary
/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --remote-debugging-port=9222

# Chromium
/Applications/Chromium.app/Contents/MacOS/Chromium --remote-debugging-port=9222
```

#### Create an alias (optional)
Add to your `~/.zshrc` or `~/.bash_profile`:
```bash
alias chrome-debug='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222'
```

Then simply run:
```bash
chrome-debug
```

### Linux

#### Ubuntu/Debian
```bash
google-chrome --remote-debugging-port=9222

# Or Chromium
chromium-browser --remote-debugging-port=9222
```

#### Fedora/RHEL
```bash
google-chrome-stable --remote-debugging-port=9222
```

#### Arch Linux
```bash
chromium --remote-debugging-port=9222
```

#### Create a desktop shortcut (optional)
Create `~/.local/share/applications/chrome-debug.desktop`:
```ini
[Desktop Entry]
Version=1.0
Name=Chrome Remote Debug
Exec=google-chrome --remote-debugging-port=9222
Terminal=false
Type=Application
Icon=google-chrome
```

### Windows

#### PowerShell
```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

#### Command Prompt
```cmd
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222
```

#### Create a shortcut (optional)
1. Right-click Chrome shortcut
2. Select "Properties"
3. In "Target" field, add ` --remote-debugging-port=9222` at the end
4. Click "OK"

## Advanced Configuration

### Use a Different Port

If port 9222 is already in use, choose a different port:

```bash
# Launch Chrome on port 9333
chrome --remote-debugging-port=9333
```

Update `config.json`:
```json
{
  "cdpEndpoint": "http://localhost:9333"
}
```

### Remote Chrome Instance

Connect to Chrome running on another machine:

```bash
# On remote machine (192.168.1.100)
chrome --remote-debugging-port=9222 --remote-debugging-address=0.0.0.0
```

Update `config.json`:
```json
{
  "cdpEndpoint": "http://192.168.1.100:9222"
}
```

⚠️ **Security Warning**: Only expose remote debugging on trusted networks!

### Additional Chrome Flags

Combine with other useful flags:

```bash
# Keep user data separate
chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-dev-profile

# Disable web security (for development only!)
chrome --remote-debugging-port=9222 --disable-web-security

# Start with specific URL
chrome --remote-debugging-port=9222 https://strudel.cc/

# Enable verbose logging
chrome --remote-debugging-port=9222 --enable-logging --v=1
```

### Multiple Instances

Run multiple Chrome instances with different profiles:

```bash
# Instance 1 (port 9222)
chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile-1

# Instance 2 (port 9223)
chrome --remote-debugging-port=9223 --user-data-dir=/tmp/chrome-profile-2
```

## Troubleshooting

### "No browser contexts available"

**Problem**: The server can't find any browser contexts.

**Solutions**:
1. Make sure Chrome is fully started before running `init`
2. Try opening a new tab manually
3. Restart Chrome with the debugging flag

### "Connection refused" / "ECONNREFUSED"

**Problem**: Can't connect to the CDP endpoint.

**Solutions**:
1. Verify Chrome is running with `--remote-debugging-port=9222`
2. Check the port number in `config.json` matches the Chrome port
3. Ensure no firewall is blocking the connection
4. Try `http://localhost:9222/json` in a browser to verify CDP is working

### Port Already in Use

**Problem**: Port 9222 is already taken.

**Solutions**:
1. Find what's using the port:
   ```bash
   # macOS/Linux
   lsof -i :9222
   
   # Windows
   netstat -ano | findstr :9222
   ```
2. Use a different port (e.g., 9223, 9333)
3. Kill the process using the port

### "Cannot find existing Strudel tab"

**Problem**: Server creates a new tab instead of using the existing one.

**Solutions**:
1. Make sure the Strudel tab URL is exactly `https://strudel.cc/`
2. Close and reopen the Strudel tab
3. The server will still create a new tab if it can't find one - this is normal

### DevTools Already Connected

**Problem**: Can't connect because DevTools is already attached.

**Solutions**:
1. Close Chrome DevTools if open on the Strudel tab
2. Playwright can connect even with DevTools open, but some features may conflict
3. Use a different tab or window

## Checking CDP is Working

Verify the Chrome DevTools Protocol is accessible:

```bash
# Using curl
curl http://localhost:9222/json

# Using a browser
# Open http://localhost:9222 in any browser
```

You should see a JSON response listing all open tabs/targets.

## Environment Variables

Set environment variables for easier configuration:

```bash
# Set CDP endpoint
export STRUDEL_CDP_ENDPOINT="http://localhost:9222"

# Use in your code or scripts
echo $STRUDEL_CDP_ENDPOINT
```

## Switching Between Modes

### To use an existing Chrome instance:
```json
{
  "cdpEndpoint": "http://localhost:9222"
}
```

### To launch a new Chromium instance:
```json
{
  "cdpEndpoint": null
}
```

## Best Practices

1. **Keep Chrome Visible**: Don't minimize or hide the window when using the MCP server
2. **Single Strudel Tab**: Work with one Strudel tab at a time for best results
3. **Restart Chrome**: If experiencing issues, restart Chrome with the debug flag
4. **Profile Separation**: Use separate Chrome profiles for development vs. personal use
5. **Port Consistency**: Stick to one port number for easier configuration

## Security Considerations

⚠️ **Important Security Notes**:

- The Chrome DevTools Protocol provides **full access** to your browser
- Anyone with network access to the debugging port can control your browser
- **Never** expose the debugging port to the internet
- **Never** use `--remote-debugging-address=0.0.0.0` on untrusted networks
- Consider using a separate Chrome profile for debugging
- Close Chrome when done debugging to close the CDP port

## Additional Resources

- [Chrome DevTools Protocol Documentation](https://chromedevtools.github.io/devtools-protocol/)
- [Playwright CDP Documentation](https://playwright.dev/docs/api/class-browsertype#browser-type-connect-over-cdp)
- [Chrome Command Line Switches](https://peter.sh/experiments/chromium-command-line-switches/)

## Examples

### Example 1: Basic Usage

```bash
# Terminal 1: Start Chrome
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Terminal 2: Start Strudel MCP server (with config.json configured)
node dist/index.js

# Terminal 3: Use with Claude
claude chat
# Then: "Initialize Strudel and create a techno beat"
```

### Example 2: Development Workflow

```bash
# Start Chrome with fresh profile and Strudel already open
chrome --remote-debugging-port=9222 \
       --user-data-dir=/tmp/strudel-dev \
       https://strudel.cc/

# The MCP server will find and use this tab
```

### Example 3: Multiple Projects

```bash
# Project 1 - Techno
chrome --remote-debugging-port=9222 --user-data-dir=/tmp/project-techno

# Project 2 - Ambient  
chrome --remote-debugging-port=9223 --user-data-dir=/tmp/project-ambient

# Configure config.json for each project with the appropriate port
```

---

**Need help?** Open an issue at [GitHub Issues](https://github.com/gee842/strudel-mcp-server/issues)
