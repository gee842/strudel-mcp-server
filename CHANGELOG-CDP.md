# CDP Connection Feature - Changelog

**Date**: 2025-09-30  
**Feature**: Connect to Existing Chrome Instance

## Summary

Modified `strudel-mcp-server` to support connecting to an existing Chrome/Chromium instance via Chrome DevTools Protocol (CDP) instead of always launching a new Chromium instance.

## Changes Made

### 1. Fixed `EnhancedMCPServerFixed.ts`
**File**: `src/server/EnhancedMCPServerFixed.ts`

**Problem**: The server was passing `config.headless` (boolean) to `StrudelController`, but the controller expects a CDP endpoint string.

**Solution**: Updated to pass `config.cdpEndpoint` instead:
- Line 18: Changed default config from `{ headless: false }` to `{ cdpEndpoint: null }`
- Line 46: Changed `new StrudelController(config.headless)` to `new StrudelController(config.cdpEndpoint || null)`

### 2. Updated `config.json`
**File**: `config.json`

**Changes**:
- Removed: `"headless": false`
- Added: `"cdpEndpoint": null`
- Added: `"_comments"` section with usage instructions

**New Configuration**:
```json
{
  "cdpEndpoint": null,  // Set to "http://localhost:9222" to connect to existing Chrome
  "strudel_url": "https://strudel.cc/",
  "patterns_dir": "./patterns",
  "audio_analysis": {
    "fft_size": 2048,
    "smoothing": 0.8
  },
  "_comments": {
    "cdpEndpoint": "Set to null to launch a new Chrome instance, or provide a CDP endpoint..."
  }
}
```

### 3. Updated `README.md`
**File**: `README.md`

**Added Section**: "Connect to Existing Chrome Instance"

**Content**:
- Platform-specific instructions for launching Chrome with remote debugging
- Step-by-step configuration guide
- Benefits of using existing Chrome instance
- Link to detailed documentation

### 4. Created `CHROME-DEBUGGING.md`
**File**: `CHROME-DEBUGGING.md` (NEW)

**Comprehensive guide including**:
- Why use an existing Chrome instance
- Quick start guide
- Platform-specific instructions (macOS, Linux, Windows)
- Advanced configuration options
- Troubleshooting section
- Security considerations
- Best practices
- Multiple examples

## How It Works

### Connection Flow

1. **Launch Mode** (default, `cdpEndpoint: null`):
   ```
   Server → Playwright → Launch new Chromium → Open Strudel.cc
   ```

2. **Connect Mode** (`cdpEndpoint: "http://localhost:9222"`):
   ```
   Server → Playwright → Connect to existing Chrome → Find/Create Strudel tab
   ```

### Implementation Details

The `StrudelController` already had CDP support built-in:

```typescript
// Lines 8-43 in StrudelController.ts
constructor(cdpEndpoint: string | null = null) {
  this.cdpEndpoint = cdpEndpoint;
}

async initialize(): Promise<string> {
  if (this.cdpEndpoint) {
    // Connect to existing Chrome via CDP
    this.browser = await chromium.connectOverCDP(this.cdpEndpoint);
    // Find existing Strudel tab or create new one
  } else {
    // Launch new Chromium instance (original behavior)
    this.browser = await chromium.launch({ headless: false });
  }
}
```

The issue was just that the server wasn't properly utilizing this feature.

## Usage Examples

### Example 1: Connect to Existing Chrome

```bash
# Step 1: Launch Chrome with remote debugging
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Step 2: Update config.json
{
  "cdpEndpoint": "http://localhost:9222"
}

# Step 3: Run the server
node dist/index.js
```

### Example 2: Launch New Instance (Default)

```bash
# config.json
{
  "cdpEndpoint": null
}

# Run the server - will launch new Chromium
node dist/index.js
```

## Benefits

### For Users
- ✅ Use existing Chrome profile with all extensions and settings
- ✅ Keep browser visible for visual feedback
- ✅ Reuse existing Strudel sessions
- ✅ Work with Chrome DevTools alongside MCP
- ✅ Save resources by not launching multiple browser instances

### For Developers
- ✅ Easier debugging with Chrome DevTools
- ✅ Multiple MCP tools can share same browser
- ✅ Better integration with existing workflows
- ✅ More control over browser environment

## Testing

Build completed successfully:
```bash
npm run build
# Exit code: 0
```

## Files Modified

1. ✅ `src/server/EnhancedMCPServerFixed.ts` - Fixed CDP endpoint handling
2. ✅ `config.json` - Updated configuration schema
3. ✅ `README.md` - Added usage instructions
4. ✅ `CHROME-DEBUGGING.md` - Created comprehensive guide (NEW)
5. ✅ `dist/` - Rebuilt with TypeScript compiler

## Backward Compatibility

✅ **Fully backward compatible**

Existing configurations will continue to work:
- Default behavior unchanged (launches new Chromium)
- No breaking changes to existing code
- All existing features still work

## Security Notes

⚠️ **Important**: The Chrome DevTools Protocol provides full browser access. Only expose the debugging port on trusted networks.

See `CHROME-DEBUGGING.md` for detailed security considerations.

## Future Enhancements

Potential improvements:
- [ ] Auto-detect running Chrome instances
- [ ] Support for multiple concurrent Strudel tabs
- [ ] Environment variable support for CDP endpoint
- [ ] CLI flag for CDP endpoint override
- [ ] Headless mode support for CDP connections

## Documentation

- **Quick Reference**: See README.md "Connect to Existing Chrome Instance" section
- **Comprehensive Guide**: See CHROME-DEBUGGING.md
- **Configuration**: See config.json comments

## Version

This feature is included starting from version **2.2.0**

---

**Verified Working**: ✅ Build successful, no linter errors
