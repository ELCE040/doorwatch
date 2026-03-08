# DoorWatch (Flutter Pay‑Per‑View Streaming)

A Flutter sample app focused on:

- Modern UX/UI for browsing and watching movies.
- Pay‑per‑view flow (users pay before each movie).
- Smooth playback with buffering controls, retry UX, and crash-resistant handling.
- Data optimization controls with quality preference and adaptive stream fallback.

## Features

- **Catalog UX** with clear lock/unlock states.
- **Secure payment screen** with no-subscription messaging.
- **Playback preferences**:
  - data-saver mode,
  - quality choice (Auto, Data saver, Balanced, High).
- **Resilient playback screen** using `video_player` with:
  - lifecycle pause handling,
  - retry action,
  - buffering indicator,
  - ordered quality fallback if one stream fails,
  - guarded error handling to avoid player crashes.

## Run

```bash
flutter pub get
flutter run
```

## Notes for production

- Replace mock payment form with Stripe/PayPal backend tokenization.
- Use signed HLS/DASH manifests with server-side entitlement checks after purchase.
- Add telemetry for startup time, rebuffer ratio, and playback failure rates.
