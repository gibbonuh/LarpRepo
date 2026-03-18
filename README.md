# larpxodus

`larpxodus` is an original macOS SwiftUI mock wallet app scaffold. It is not a real cryptocurrency wallet and does not connect to any blockchain.

## What it does

- Shows a wallet-style dashboard with sample crypto assets
- Lets you toggle edit mode and directly change coin amounts
- Lets you change per-asset USD price and 24h change values
- Recomputes displayed wallet totals from those editable values

## Run locally

```bash
swift run
```

If you want a full `.app` bundle and signing setup, open the package in Xcode and create a macOS app target around these sources.

## Open in Xcode

There is also a native Xcode project at `larpxodus.xcodeproj`.

1. Install full Xcode
2. Open `larpxodus.xcodeproj`
3. Select the `larpxodus` scheme for Mac or `larpxodus iOS` for iPhone
4. Press Run
