# RustDesk Fold Known Issues

Status: Active
Scope: Android arm64 Fold release test builds

This file records known Fold-specific behavior found during maintainer device
testing. It is not a complete upstream RustDesk issue list.

## Touchpad And Touchscreen Drag Behavior

Status: Fixed in current test build; monitor for device-specific tuning

Observed during manual testing:

- Basic remote-control functionality works.
- Touchscreen mode can move a remote window.
- Maintainer validation confirmed that remote window resize handles can be
  dragged smoothly after the touchpad follow-up changes.

Impact:

- No current blocker for basic Fold remote-control testing.
- Keep monitoring subjective touchpad feel and device-specific haptic strength.

Follow-up direction:

- Review the touchpad gesture state machine for click, press, drag, and release.
- Compare event sequences emitted by touchscreen mode and touchpad mode while
  dragging a remote window title bar and resize handle.
- Validate behavior on the target remote OS window manager after changes.

Implemented in `fix/fold-touchpad-drag-gestures`:

- Normal touchpad long press now sends remote left-button down, pointer movement,
  and left-button up on release, so press-drag can behave like a mouse drag.
- Wheel-scroll mode stays separate from normal pointer drag mode.
- The touchpad middle scroll button toggles wheel-scroll mode with a short
  tap/click instead of requiring a long press.
- Touchpad single-finger tap and two-finger tap provide one local haptic
  feedback event; long press provides the initial haptic event and a second
  event when the long/heavy-press operation becomes active.
- Connected-session Target OS settings now include an Input Mode vibration
  strength slider with four stops: off, weak 20%, normal 50%, and strong 80%.
- The app settings About area now says "About RustDesk Fold", keeps the version
  number unchanged, keeps `rustdesk.com`, and adds
  `https://github.com/bluewhitep/RustDesk-Fold`.

Remaining validation:

- Tune touchpad tap slop, long-press delay, scroll scale, or haptic strength
  stops only if target-device testing shows unreliable or uncomfortable input.
