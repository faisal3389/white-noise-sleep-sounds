# TestFlight & App Store Connect Guide — White Noise Sleep Sounds

> **Key Fact:** Uploading to App Store Connect does NOT make your app public. TestFlight internal testing requires NO App Review. You control if/when the app goes live.

---

## Phase 1 — One-Time Setup

### 1. Confirm Apple Developer Program
- Go to [developer.apple.com/account](https://developer.apple.com/account)
- Ensure your $99/year membership is active

### 2. Create App on App Store Connect
Go to [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → My Apps → "+" → New App

| Field | Value |
|-------|-------|
| Platform | iOS |
| Name | `White Noise — Sleep Sounds` |
| Primary Language | English (U.S.) |
| Bundle ID | `zalgo.White-Noise---Sleep-Sounds` |
| SKU | `whitenoise-sleep-2026` |
| User Access | Full Access |

### 3. App Information Tab
| Field | Value |
|-------|-------|
| Subtitle | `Rain, Fan & Nature Sound Mixer` |
| Primary Category | Health & Fitness |
| Secondary Category | Lifestyle |
| Content Rights | "This app does not contain, show, or access third-party content" |
| Age Rating | 4+ |

### 4. Pricing and Availability
- Price: Free
- Territories: All (worldwide)

### 5. Privacy Policy
- Host at: `https://yourusername.github.io/whitenoise-privacy`
- Required for both TestFlight and App Store

---

## Phase 2 — Archive & Upload from Xcode

1. **Set signing team** — Target → Signing & Capabilities → Team → your Apple Developer account
2. **Set destination** — "Any iOS Device (arm64)" (not a simulator)
3. **Set version** — General tab → Version: `1.0`, Build: `1`
4. **Archive** — Product → Archive
5. **Upload** — Organizer → select archive → Distribute App → App Store Connect → Upload
6. **Wait** — Apple processes the build (5-15 min). You'll get an email when ready.

---

## Phase 3 — TestFlight Internal Testing

1. Go to **App Store Connect → Your App → TestFlight tab**
2. Find your build under "iOS Builds"
3. Click "+" next to **Internal Testing** → create a group → add yourself
4. Testers get an email invite → install TestFlight app → install your app
5. **No App Review needed** for internal testers (up to 100 people on your team)

---

## Phase 4 — External Testing (Optional, Later)

- For up to 10,000 testers outside your team
- Requires lightweight Beta App Review (~24 hours)
- Create an "External Testing" group and add testers by email

---

## App Store Metadata (for when you go public)

### App Name (30 chars)
```
White Noise — Sleep Sounds
```

### Subtitle (30 chars)
```
Rain, Fan & Nature Sound Mixer
```

### Keywords (100 chars)
```
calm,focus,baby,deep,brown,pink,green,ocean,machine,relax,nap,box,ambient,waves,study,bedtime,aid
```

### Promotional Text (170 chars, editable anytime)
```
Mix rain, ocean, fan & nature sounds to create your perfect sleep environment. 27+ free sounds, custom mixing, and a beautiful dark UI.
```

### Description
```
Fall asleep faster with White Noise — Sleep Sounds. Mix and match from a library of white noise, brown noise, pink noise, rain, ocean waves, fan sounds, and nature ambiences to create your perfect sleep environment.

Features:
• 27+ free high-quality sounds — no ads in the free version
• Custom sound mixing — blend multiple sounds with individual volume control
• Curated mixes — pre-built soundscapes for sleep, focus, and relaxation
• Save your favorite mixes and sounds
• Background playback — keeps playing when you lock your phone
• Beautiful, modern interface designed for nighttime use
• AirPlay support — stream to your speakers

Upgrade to Premium ($0.99) to unlock additional sounds and remove ads.

White Noise — Sleep Sounds is designed to help you sleep better, focus deeper, and relax fully. No account required, no tracking, no data collection.
```

### App Review Notes
```
This app provides white noise and nature sounds for sleep, relaxation, and focus. The free version includes 27 sounds with banner ads. The $0.99 in-app purchase removes ads and unlocks premium sounds. Test account not needed — all features work without login.
```

### Privacy
- If no ads/analytics: "Data Not Collected"
- If AdMob is present: Declare Advertising Data collection

### Pricing
- Free with $0.99 IAP (removes ads + unlocks premium sounds)

---

## Pre-Submission Checklist (for full App Store release)

- [ ] App runs without crashes on iPhone
- [ ] All sounds play correctly, loop seamlessly
- [ ] Background audio works when app is minimized
- [ ] IAP purchase and restore work in sandbox
- [ ] Privacy Policy URL is live
- [ ] App icon — no alpha/transparency, follows HIG
- [ ] All screenshots at correct resolutions
- [ ] No copyrighted sounds or images
- [ ] Metadata doesn't reference competitor names

---

## Common Rejection Reasons

1. **Guideline 2.1 — App Completeness:** No placeholder screens or "coming soon" labels
2. **Guideline 3.1.1 — IAP:** All digital content must use IAP (your StoreKit 2 setup handles this)
3. **Guideline 5.1.2 — Data Use:** Declare data collection accurately in App Privacy
4. **Guideline 4.0 — Design:** Must not be a thin wrapper or low-quality clone

---

## Post-Launch

1. Monitor crashes via Xcode Organizer
2. Respond to reviews (even negative ones)
3. Check keyword rankings weekly in Astro, swap underperformers
4. Submit updates every 2-3 weeks (algorithm favors active apps)
