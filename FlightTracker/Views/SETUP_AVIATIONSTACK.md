# Setting Up AviationStack for Route Data

Your app is now configured to use **AviationStack** as an alternative to OpenSky for route information!

## Quick Start (5 minutes)

### Step 1: Get Your Free API Key

1. Go to **https://aviationstack.com/**
2. Click **"Sign Up Free"**
3. Create your account (email + password)
4. Verify your email
5. Go to your dashboard: https://aviationstack.com/dashboard
6. Copy your **API Access Key** (it looks like: `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`)

### Step 2: Add API Key to Xcode

1. In Xcode, go to **Product** → **Scheme** → **Edit Scheme...**
2. Select **Run** on the left sidebar
3. Click the **Arguments** tab
4. Under **Environment Variables**, click the **+** button
5. Add this variable:
   - **Name:** `AVIATIONSTACK_API_KEY`
   - **Value:** `[paste your API key here]`
6. Click **Close**

### Step 3: Test It!

1. Run your app (⌘R)
2. Select an aircraft
3. Check the console logs - you should see:
   ```
   ✈️ Fetching AviationStack route for [callsign]
   📡 AviationStack HTTP 200
   ✅ AviationStack route: YSSY → YMML
   ```

## What You Get

### Free Tier
- **500 requests per month** (about 16 per day)
- Live flight data
- Departure and arrival airports
- Flight status
- Airline information

### Paid Tiers (Optional)
- **Basic:** $9.99/month - 10,000 requests
- **Professional:** $49.99/month - 100,000 requests
- **Business:** $99.99/month - 500,000 requests

## How It Works

The app now follows this flow for route data:

```
1. User selects aircraft
   ↓
2. Try AviationStack first (if API key configured)
   ↓ (if fails or not configured)
3. Try OpenSky (if attemptOpenSkyRoutes = true)
   ↓ (if fails)
4. Use fallback (show callsign + airline code)
```

## Configuration Options

In `OpenSkyConfig.swift`, you can adjust:

```swift
// Enable/disable AviationStack
static let useAlternativeRouteData = true  // Currently: ON

// Enable/disable OpenSky attempts (will fail with 403)
static let attemptOpenSkyRoutes = false    // Currently: OFF

// Enable detailed console logging
static let verboseLogging = true           // Currently: ON
```

## Monitoring Your Usage

1. Visit your dashboard: https://aviationstack.com/dashboard
2. Check **API Usage** to see:
   - Requests made today
   - Requests remaining this month
   - Request history

**Tip:** To conserve requests, only fetch routes when a user actually selects an aircraft (which your app already does!)

## Troubleshooting

### "No API key configured" message
- Make sure you added `AVIATIONSTACK_API_KEY` to Xcode's environment variables
- Restart Xcode after adding the variable
- Verify the key is correct (no extra spaces)

### "AviationStack HTTP 401"
- Your API key is invalid
- Double-check you copied it correctly from the dashboard

### "No flights found"
- The callsign might not be in AviationStack's database
- Try with a commercial flight (Qantas, Virgin Australia, etc.)
- Some general aviation flights won't have route data

### "AviationStack HTTP 429"
- You've exceeded your monthly limit (500 for free tier)
- Upgrade your plan or wait until next month
- Rate limiting is 2 seconds between requests (already configured)

## Example Console Output

### Successful Route Lookup
```
✈️ Fetching AviationStack route for QFA123
📡 AviationStack HTTP 200
✅ AviationStack route: YSSY → YMML
```

### Failed (No Data)
```
✈️ Fetching AviationStack route for N12345
📡 AviationStack HTTP 200
ℹ️ No flights found in AviationStack response
ℹ️ Created route with airline code: N12
```

### Failed (No API Key)
```
⚠️ AviationStack API key not configured
   Sign up at https://aviationstack.com/ and add to environment variables
ℹ️ Created route with airline code: QFA
```

## Alternative APIs (If You Need More)

If AviationStack doesn't meet your needs:

### FlightAware AeroAPI
- **Most comprehensive data**
- Starts at $99/month
- Real-time worldwide coverage
- https://www.flightaware.com/commercial/aeroapi/

### ADS-B Exchange
- **Free API available**
- Community-driven
- Good for general aviation
- https://www.adsbexchange.com/data/

### OpenSky (Contributor Status)
- **Free with hardware**
- Set up ADS-B receiver (~$100-300)
- Unlimited API access
- https://opensky-network.org/contribute

## Questions?

Check the main documentation in `OPENSKY_ROUTE_ISSUE.md` for more details!

---
**Status:** Ready to use! Just add your API key.
