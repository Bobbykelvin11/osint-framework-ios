# OSINT Framework for iOS

An unsigned SwiftUI iOS wrapper (iOS 16+) for [OSINT Framework](https://osintframework.com) ([`lockfale/osint-framework`](https://github.com/lockfale/osint-framework)).

## Features
- **Works Offline**: Bundles `index.html`, `arf.json`, `js/`, and `css/` inside the app and serves them from a custom `WKURLSchemeHandler` (`osintapp://app/`), so the full interactive D3 tree and search work without an internet connection.
- **Live Site Toggle**: Switch between the bundled offline tree and the live `https://osintframework.com` site anytime.
- **In-App Browser**: External tool links open in an in-app `SFSafariViewController` while keeping your expanded tree position intact.
- **Navigation Controls**: Back, forward, home (offline tree), live site, reload, pull-to-refresh, and an About & Attribution screen.

## Attribution & License
OSINT Framework was created by Justin Nordine (`s0lray` / `lockfale`) and is licensed under the MIT License (see `LICENSE`).
