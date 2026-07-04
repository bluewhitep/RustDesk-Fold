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
- Compare event sequences emitted by touchscreen mode and touchpad mode while
  dragging a remote window title bar and resize handle.
- Validate behavior on the target remote OS window manager after changes.
