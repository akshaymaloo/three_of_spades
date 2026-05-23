# Changelog

All notable changes to the **Kaali Ki Teeggi (Three of Spades) — Cyberpunk Edition** project will be documented in this file.

## [1.1.0] - 2026-05-23

### Fixed
- **GlassDialog Layout & Keyboard Overflow**:
  - Wrapped dialog `Column` in a `SingleChildScrollView` to allow scrolling when contents exceed the screen height.
  - Dynamically read `MediaQuery.viewInsetsOf(context).bottom` to adjust the `insetPadding` of the `AlertDialog`, shifting the dialog upward when the soft keyboard is open.
  - Constrained the max height of the dialog container to prevent overflows behind the keyboard.
- **Main Screen (Home Screen) Layout Adjustments**:
  - Reduced vertical paddings and sized boxes on the "Offline Play" card to prevent a 10px vertical layout overflow on smaller landscape devices.
- **Save / Name Edit Functionality**:
  - Verified and guaranteed that name saving through the custom text dialog correctly updates Riverpod's `StatsNotifier` and persists changes.

### Added
- **GlassDialog Widget Tests**:
  - `renders title, content and actions`
  - `SAVE button is tappable even in constrained height` (simulated landscape viewport with vertical scroll interaction check)
  - `X button dismisses dialog`
- Total test suite coverage increased from 25 to 28 passing tests.
