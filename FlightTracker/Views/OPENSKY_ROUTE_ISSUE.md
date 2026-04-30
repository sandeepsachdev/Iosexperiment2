# OpenSky Route Data Issue - 403 Forbidden

## Problem
All requests to the OpenSky `/api/flights/aircraft` endpoint return **403 Forbidden**, regardless of authentication.

## Root Cause
The `/api/flights/aircraft` endpoint is **restricted to OpenSky contributors only**. Regular user accounts do not have access to this endpoint, even with valid credentials.

This is **not a rate limiting issue** - it's an account permission limitation.

## What is a Contributor?
OpenSky contributors are users who:
- Set up and maintain an ADS-B receiver
- Stream real-time flight data to OpenSky's network
- Get enhanced API access in return

## Solutions

### Option 1: Become a Contributor (Best for OpenSky Access)
1. Purchase an ADS-B receiver (~$100-300)
2. Set it up following: https://opensky-network.org/community/projects
3. Connect it to OpenSky Network
4. Get contributor status and unlock restricted endpoints

**Pros:**
- Free API access to all endpoints
- Support the community
- Higher rate limits

**Cons:**
- Requires hardware purchase and setup
- Need physical location for receiver

### Option 2: Use Alternative APIs (Recommended for Most Users)

#### AviationStack (Free tier available)
- Free tier: 500 requests/month
- Paid plans from $9.99/month
- Sign up: https://aviationstack.com/
- Good for occasional lookups

#### FlightAware AeroAPI
- Commercial API with comprehensive data
- Most reliable route information
- Starts at $99/month for basic tier
- Sign up: https://www.flightaware.com/commercial/aeroapi/

#### ADS-B Exchange
- Free API with community data
- No authentication required for basic features
- Less restrictive than OpenSky
- Docs: https://www.adsbexchange.com/data/

### Option 3: Use Fallback Data (Current Implementation)
Your app already handles this gracefully by:
- Showing aircraft callsigns
- Extracting airline codes
- Providing useful info even without routes

## Configuration Changes Made

### OpenSkyConfig.swift
Added:
- `attemptOpenSkyRoutes = false` - Disabled by default to save quota
- `useAlternativeRouteData = true` - Ready for alternative APIs
- `aviationStackAPIKey` - Environment variable support
- `verboseLogging` - Better debugging

### OpenSkyService.swift
Improved:
- Respects `attemptOpenSkyRoutes` flag
- Better error messages (401 vs 403 vs 429)
- Response body logging for debugging
- Tries without authentication (sometimes works better)
- Enhanced fallback route with airline code extraction

## How to Set Environment Variables in Xcode

1. Open your scheme: **Product** → **Scheme** → **Edit Scheme**
2. Select **Run** on the left
3. Go to **Arguments** tab
4. Under **Environment Variables**, click **+** to add:
   - `OPENSKY_USERNAME` (if you want to try)
   - `OPENSKY_PASSWORD` (if you want to try)
   - `AVIATIONSTACK_API_KEY` (for alternative API)

## Testing Recommendations

### Test 1: Verify the 403 is account-related
1. Set `attemptOpenSkyRoutes = true` in `OpenSkyConfig.swift`
2. Run the app
3. Check console logs - you should see:
   ```
   🔍 Attempting route lookup for [icao24]
   📡 HTTP 403 for [icao24]
   📄 Response body: ...
   🚫 403: Access forbidden
       This usually means:
       - The endpoint requires contributor/researcher status
       - Your account doesn't have permission for historical data
   ```

### Test 2: Try AviationStack
1. Sign up for free at https://aviationstack.com/
2. Get your API key
3. Add to Xcode environment variables: `AVIATIONSTACK_API_KEY`
4. Update `AlternativeFlightDataService.swift` to use it
5. Should get actual route data!

## Current Status

✅ **App works correctly** - Shows aircraft positions, callsigns, and basic data
✅ **Graceful degradation** - No routes doesn't break the UX
✅ **Security fixed** - Credentials removed from source code
✅ **Better logging** - Clear error messages explain the issue
⚠️ **Route data unavailable** - Due to OpenSky API restrictions

## Recommended Next Steps

1. **Short term**: Leave `attemptOpenSkyRoutes = false` to avoid wasted API calls
2. **Medium term**: Try AviationStack free tier for route data
3. **Long term**: Consider becoming an OpenSky contributor if you need reliable access

## Questions?

If you see different behavior or want to explore other options, let me know!

---
**Last Updated**: 2026-05-01
**Status**: Known limitation, working as expected
