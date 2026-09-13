# AR-AdVision Design System (Stitch)

> Modern, minimalistic, informative, pastel color-coordinated, light-themed AR advertising platform.

## 1. Color Palette

```
Primary:             #7C9FE5   /* Pastel Lavender Blue (CTAs, active tabs, brand focus) */
Primary Light:       #EBF2FD   /* Subtle background wash for pills & cards */
Primary Dark:        #5A7DC2   /* Pressed & focus states */

Secondary:           #A8D8B9   /* Pastel Mint Green (Success, AR Tracking Locked, confirmations) */
Secondary Light:     #EAF7F0   /* Mint badge backgrounds */

Accent Peach:        #F5C6AA   /* Pastel Peach (Offers, promotions, warm highlights) */
Accent Peach Light:  #FDF3EC   /* Promo card backgrounds */

Warning Yellow:      #F9D88D   /* Pastel Warm Yellow (Alerts, stars, metrics) */
Warning Light:       #FEF9EC   /* Warning banners */

Error Rose:          #F2A8A8   /* Pastel Soft Rose (Destructive actions, expired states) */

Surface / Cards:     #FFFFFF   /* Crisp card surfaces */
Background:          #FAFBFE   /* Ultra-light ambient wash */
Card Border:         #EDF1F7   /* Delicate 1px borders */

Text Primary:        #1E2432   /* Deep Slate for high legibility */
Text Secondary:      #68758D   /* Muted Slate for subtitles, metadata */
Text Tertiary:       #9AA5B6   /* Hint and disabled text */
```

## 2. Typography

We leverage Google Fonts to provide distinct visual hierarchy:
- **Headings & Brand Title**: `Outfit` (Bold, SemiBold) — Modern, geometric, clean aesthetic.
- **Body & Captions**: `Inter` (Regular, Medium) — Optimized for mobile screen legibility.
- **Labels, Chips & Tabs**: `DM Sans` (Medium, SemiBold) — Compact, modern UI labels.
- **Numbers & Metrics**: `Outfit` (Bold) — High-impact dashboard stats.

## 3. Elevation, Radius & Spacing

- **Border Radius**:
  - Small pills & tags: `8px`
  - Standard cards & inputs: `16px`
  - Modals & bottom sheets: `24px` (top corners)
  - Floating action buttons: `9999px` (Full pill / circular)
- **Shadows**:
  - Soft ambient: `0 4px 20px rgba(124, 159, 229, 0.08)`
  - Elevated card: `0 8px 30px rgba(30, 36, 50, 0.06)`
  - Frosted Glass HUD: `backdrop-filter: blur(16px); background: rgba(255, 255, 255, 0.82)`

## 4. Stitch Screens Reference

| Screen Name | Stitch ID | Purpose |
|---|---|---|
| AR-AdVision Home | `679fa771` | Consumer feed, trending AR ads, active categories |
| AR-AdVision Viewer | `008595ea` | Live AR 3D model viewport, plane tracking, HUD & hotspots |
| AR-AdVision QR Scanner | `9681a0bb` | Camera scanner reticle, laser line, recent scans |
| Product Detail & AI Assistant | `33d4b58e` | 3D preview, Groq AI summary, specs, promo copy code |
| Advertiser Analytics & Campaigns | `ae70af22` | KPI metrics, engagement graph, campaign cards |
| Campaign & QR Studio | `8535603f` | Campaign form, 3D model picker, QR code generation |
| Login & Registration | `be6fe65f` | Email/password auth, role selector, guest mode |
