#!/bin/bash
# Example: Connect Strudel MCP Server to Existing Chrome Instance
# 
# This script demonstrates how to use the CDP endpoint feature
# to connect to an existing Chrome instance instead of launching a new one.

set -e

echo "🎵 Strudel MCP Server - Connect to Existing Chrome"
echo "=================================================="
echo ""

# Detect operating system
OS="$(uname -s)"
CHROME_PATH=""

case "${OS}" in
    Darwin*)
        echo "📍 Detected: macOS"
        CHROME_PATH="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        ;;
    Linux*)
        echo "📍 Detected: Linux"
        if command -v google-chrome &> /dev/null; then
            CHROME_PATH="google-chrome"
        elif command -v chromium-browser &> /dev/null; then
            CHROME_PATH="chromium-browser"
        elif command -v chromium &> /dev/null; then
            CHROME_PATH="chromium"
        else
            echo "❌ Error: Chrome/Chromium not found"
            exit 1
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        echo "📍 Detected: Windows"
        CHROME_PATH="C:/Program Files/Google/Chrome/Application/chrome.exe"
        ;;
    *)
        echo "❌ Error: Unsupported operating system: ${OS}"
        exit 1
        ;;
esac

echo "🌐 Chrome path: $CHROME_PATH"
echo ""

# Check if Chrome is already running with debugging port
if lsof -i :9222 &> /dev/null || netstat -an 2>/dev/null | grep -q ":9222.*LISTEN"; then
    echo "✅ Chrome is already running with remote debugging on port 9222"
    echo ""
else
    echo "🚀 Launching Chrome with remote debugging on port 9222..."
    echo ""
    
    # Launch Chrome with remote debugging
    if [[ "${OS}" == "Darwin"* ]]; then
        open -a "Google Chrome" --args --remote-debugging-port=9222 &
    else
        "${CHROME_PATH}" --remote-debugging-port=9222 &
    fi
    
    # Wait for Chrome to start
    echo "⏳ Waiting for Chrome to start..."
    sleep 3
    
    echo "✅ Chrome launched successfully"
    echo ""
fi

# Check if Chrome DevTools Protocol is accessible
echo "🔍 Verifying CDP endpoint is accessible..."
if curl -s http://localhost:9222/json > /dev/null; then
    echo "✅ CDP endpoint is accessible at http://localhost:9222"
    echo ""
else
    echo "❌ Error: Cannot access CDP endpoint"
    echo "   Make sure Chrome is running with --remote-debugging-port=9222"
    exit 1
fi

# Display available targets
echo "📋 Available Chrome targets:"
curl -s http://localhost:9222/json | jq -r '.[] | "  - \(.title) (\(.type))"' 2>/dev/null || \
    curl -s http://localhost:9222/json | grep -o '"title":"[^"]*"' | sed 's/"title":"//;s/"$//' | sed 's/^/  - /'
echo ""

# Update config.json
CONFIG_FILE="./config.json"
if [ -f "$CONFIG_FILE" ]; then
    echo "⚙️  Updating config.json to use CDP endpoint..."
    
    # Backup original config
    cp "$CONFIG_FILE" "${CONFIG_FILE}.backup"
    echo "   (Backup saved to ${CONFIG_FILE}.backup)"
    
    # Update config.json (simple approach - assumes standard format)
    if command -v jq &> /dev/null; then
        jq '.cdpEndpoint = "http://localhost:9222"' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp" && \
            mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
        echo "✅ config.json updated with CDP endpoint"
    else
        echo "⚠️  Warning: jq not found. Please manually update config.json:"
        echo '   { "cdpEndpoint": "http://localhost:9222" }'
    fi
    echo ""
else
    echo "⚠️  Warning: config.json not found in current directory"
    echo "   Please create one with: { \"cdpEndpoint\": \"http://localhost:9222\" }"
    echo ""
fi

echo "✨ Setup complete!"
echo ""
echo "📖 Next steps:"
echo "   1. (Optional) Open https://strudel.cc/ in Chrome"
echo "   2. Run the Strudel MCP server:"
echo "      npm start"
echo "      # or"
echo "      node dist/index.js"
echo ""
echo "   3. Use with Claude:"
echo "      claude chat"
echo "      # Then: 'Initialize Strudel and create a techno beat'"
echo ""
echo "💡 Tips:"
echo "   - The server will automatically find existing Strudel tabs"
echo "   - You can use Chrome DevTools alongside the MCP server"
echo "   - Your Chrome profile and extensions are available"
echo ""
echo "🔧 To revert to launching a new Chrome instance:"
echo "   Set 'cdpEndpoint' to null in config.json"
echo ""
echo "📚 For more information, see CHROME-DEBUGGING.md"
echo ""
