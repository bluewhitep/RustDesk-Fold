# RustDesk Fold Known Issues

Status: Active
Scope: Android arm64 Fold release test builds

This file records known Fold-specific behavior found during maintainer device
testing. It is not a complete upstream RustDesk issue list.

## Touchpad And Touchscreen Drag Behavior

Status: Open

Observed during manual testing:

- Basic remote-control functionality works.
- Touchscreen mode can move a remote window.
- Touchscreen and touchpad interactions are not smooth for dragging remote
  window resize handles.
- Touchpad mode does not reliably move a remote window.
- Touchpad single-click and press-drag behavior likely needs adjustment because
  holding and dragging does not behave like a normal mouse drag.

Impact:

- Fine-grained remote window move and resize workflows are degraded on Fold
  input surfaces.
- This does not currently block basic connection and remote-control testing,
  but it should be disclosed for public test APKs and fixed before claiming a
  polished Fold touchpad experience.

Follow-up direction:

- Review the touchpad gesture state machine for click, press, drag, and release.
- Keep wheel-scroll mode separate from normal pointer drag mode.
- Change the touchpad middle scroll button activation from long-press activation
  to short tap/click activation.
- Compare event sequences emitted by touchscreen mode and touchpad mode while
  dragging a remote window title bar and resize handle.
- Add haptic feedback for touchpad interactions: single tap and two-finger tap
  should vibrate once; long press should vibrate once on press and once again
  after the long/heavy-press operation becomes active.
- In the app settings page, rename the bottom "About RustDesk" entry to
  "About RustDesk Fold"; keep the version number unchanged, keep the official
  `rustdesk.com` URL, and add a second line for
  `https://github.com/bluewhitep/RustDesk-Fold`.
- Validate behavior on the target remote OS window manager after changes.
