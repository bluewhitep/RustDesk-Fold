part of '../pages/remote_page.dart';

enum _FoldRemoteDisplayMode {
  contain,
  fill,
  panZoom,
}

enum _TrackpadPlacement {
  left,
  right,
}

enum _LocalKeyboardLayer {
  main,
  system,
  symbols,
}

enum _FoldLanguageSwitchMode {
  macLanguageCycle,
  windowsLanguageCycle,
  linuxLanguageCycle,
}

enum _FoldTargetOs {
  mac,
  windows,
  linux,
}

enum _FoldLanguageShortcutSlot {
  macPrev,
  macNext,
  winPrev,
  winNext,
  linuxPrev,
  linuxNext,
}

enum _FoldShortcutCaptureTarget {
  previous,
  next,
}

enum _FoldModifierDisplayStyle {
  mac,
  win,
  linux,
}

enum _FoldKeyboardInputMode {
  textInjection,
  remoteImeKeyEvents,
}

class _FoldRemoteImeKeyEvent {
  const _FoldRemoteImeKeyEvent({
    required this.keyName,
    required this.usbHid,
  });

  final String keyName;
  final int usbHid;
}

_FoldRemoteImeKeyEvent? _foldRemoteImeKeyEventForCharacter(String char) {
  if (char == ' ') {
    return const _FoldRemoteImeKeyEvent(keyName: 'VK_SPACE', usbHid: 0x2C);
  }
  if (char == '\n') {
    return const _FoldRemoteImeKeyEvent(keyName: 'VK_RETURN', usbHid: 0x28);
  }
  if (char.length != 1) {
    return null;
  }
  final codeUnit = char.codeUnitAt(0);
  if (codeUnit >= 0x61 && codeUnit <= 0x7A) {
    return _FoldRemoteImeKeyEvent(
      keyName: 'VK_${char.toUpperCase()}',
      usbHid: 0x04 + codeUnit - 0x61,
    );
  }
  if (codeUnit >= 0x41 && codeUnit <= 0x5A) {
    return _FoldRemoteImeKeyEvent(
      keyName: 'VK_$char',
      usbHid: 0x04 + codeUnit - 0x41,
    );
  }
  if (codeUnit >= 0x30 && codeUnit <= 0x39) {
    final hid = codeUnit == 0x30 ? 0x27 : 0x1E + codeUnit - 0x31;
    return _FoldRemoteImeKeyEvent(keyName: 'VK_$char', usbHid: hid);
  }
  return null;
}

_FoldRemoteImeKeyEvent? _foldRemoteImeKeyEventForKeyName(String key) {
  if (key.startsWith('VK_') && key.length == 4) {
    return _foldRemoteImeKeyEventForCharacter(key.substring(3).toLowerCase());
  }
  switch (key) {
    case 'VK_ENTER':
    case 'VK_RETURN':
      return _FoldRemoteImeKeyEvent(keyName: key, usbHid: 0x28);
    case 'VK_ESCAPE':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_ESCAPE', usbHid: 0x29);
    case 'VK_BACK':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_BACK', usbHid: 0x2A);
    case 'VK_TAB':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_TAB', usbHid: 0x2B);
    case 'VK_SPACE':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_SPACE', usbHid: 0x2C);
    case 'VK_INSERT':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_INSERT', usbHid: 0x49);
    case 'VK_HOME':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_HOME', usbHid: 0x4A);
    case 'VK_PRIOR':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_PRIOR', usbHid: 0x4B);
    case 'VK_DELETE':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_DELETE', usbHid: 0x4C);
    case 'VK_END':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_END', usbHid: 0x4D);
    case 'VK_NEXT':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_NEXT', usbHid: 0x4E);
    case 'VK_RIGHT':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_RIGHT', usbHid: 0x4F);
    case 'VK_LEFT':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_LEFT', usbHid: 0x50);
    case 'VK_DOWN':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_DOWN', usbHid: 0x51);
    case 'VK_UP':
      return const _FoldRemoteImeKeyEvent(keyName: 'VK_UP', usbHid: 0x52);
  }
  if (key.startsWith('VK_F')) {
    final number = int.tryParse(key.substring(4));
    if (number != null && number >= 1 && number <= 12) {
      return _FoldRemoteImeKeyEvent(
        keyName: key,
        usbHid: 0x3A + number - 1,
      );
    }
  }
  return null;
}

const _kFoldLanguageSwitchModeOption = 'fold.languageSwitchMode';
const _kFoldModifierDisplayStyleOption = 'fold.modifierDisplayStyle';
const _kFoldRemotePaneRatioOption = 'fold.remotePaneRatio';
const _kFoldKeyboardInputModeOption = 'fold.keyboardInputMode';
const _kFoldHapticStrengthOption = 'fold.hapticStrengthPercent';
const _kDefaultFoldHapticStrengthPercent = 50;
const _kFoldHapticStrengthValues = <int>[0, 20, 50, 80];

int _foldHapticStrengthFromOptionValue(String value) {
  final parsed = int.tryParse(value);
  if (parsed == null) {
    return _kDefaultFoldHapticStrengthPercent;
  }
  return _nearestFoldHapticStrengthPercent(parsed);
}

int _nearestFoldHapticStrengthPercent(int value) {
  var nearest = _kFoldHapticStrengthValues.first;
  var nearestDistance = (value - nearest).abs();
  for (final candidate in _kFoldHapticStrengthValues.skip(1)) {
    final distance = (value - candidate).abs();
    if (distance < nearestDistance) {
      nearest = candidate;
      nearestDistance = distance;
    }
  }
  return nearest;
}

String _foldHapticStrengthLabel(int percent) {
  final value = _nearestFoldHapticStrengthPercent(percent);
  switch (value) {
    case 0:
      return translate('Off');
    case 20:
      return '${translate('Haptic Weak')} 20%';
    case 50:
      return '${translate('Haptic Normal')} 50%';
    case 80:
      return '${translate('Haptic Strong')} 80%';
  }
  return '$value%';
}

String _foldHapticStrengthTickLabel(int percent) {
  final value = _nearestFoldHapticStrengthPercent(percent);
  switch (value) {
    case 0:
      return translate('Off');
    case 20:
      return translate('Haptic Weak');
    case 50:
      return translate('Haptic Normal');
    case 80:
      return translate('Haptic Strong');
  }
  return '$value%';
}

Future<void> _performFoldHapticFeedback({
  required int strengthPercent,
  bool activated = false,
}) async {
  final strength = _nearestFoldHapticStrengthPercent(strengthPercent);
  if (strength <= 0) {
    return;
  }
  if (isAndroid) {
    try {
      await gFFI.invokeMethod('fold_haptic_feedback', {
        'strength': strength,
        'durationMs': activated ? 24 : 12,
      });
      return;
    } catch (_) {
      // Fall through to Flutter's coarse haptic presets if the native bridge is unavailable.
    }
  }
  if (activated) {
    await HapticFeedback.mediumImpact();
  } else {
    await HapticFeedback.selectionClick();
  }
}

class _FoldModifierLabels {
  const _FoldModifierLabels({
    required this.control,
    required this.alt,
    required this.meta,
  });

  final String control;
  final String alt;
  final String meta;
}

_FoldModifierLabels _foldModifierLabels(_FoldModifierDisplayStyle style) {
  switch (style) {
    case _FoldModifierDisplayStyle.mac:
      return _FoldModifierLabels(
        control: translate('Control'),
        alt: translate('Option'),
        meta: translate('Command'),
      );
    case _FoldModifierDisplayStyle.win:
      return _FoldModifierLabels(
        control: translate('Ctrl'),
        alt: translate('Alt'),
        meta: translate('Win'),
      );
    case _FoldModifierDisplayStyle.linux:
      return _FoldModifierLabels(
        control: translate('Ctrl'),
        alt: translate('Alt'),
        meta: translate('Super'),
      );
  }
}

class _FoldKeyShortcut {
  const _FoldKeyShortcut({
    required this.key,
    this.ctrl = false,
    this.alt = false,
    this.shift = false,
    this.command = false,
    this.label,
  });

  final String key;
  final bool ctrl;
  final bool alt;
  final bool shift;
  final bool command;
  final String? label;

  String displayLabelFor(_FoldModifierDisplayStyle style) {
    final labels = _foldModifierLabels(style);
    final parts = <String>[
      if (shift) translate('Shift'),
      if (ctrl) labels.control,
      if (style == _FoldModifierDisplayStyle.mac) ...[
        if (alt) labels.alt,
        if (command) labels.meta,
      ] else ...[
        if (command) labels.meta,
        if (alt) labels.alt,
      ],
      _foldShortcutKeyLabel(key, style),
    ];
    return parts.join(' + ');
  }

  String toOptionValue() => jsonEncode({
        'key': key,
        'ctrl': ctrl,
        'alt': alt,
        'shift': shift,
        'command': command,
        if (label != null) 'label': label,
      });

  static _FoldKeyShortcut fromOptionValue(
      String value, _FoldKeyShortcut fallback) {
    if (value.isEmpty) {
      return fallback;
    }
    try {
      final decoded = jsonDecode(value);
      if (decoded is! Map) {
        return fallback;
      }
      final key = decoded['key'];
      if (key is! String || key.isEmpty) {
        return fallback;
      }
      return _FoldKeyShortcut(
        key: key,
        ctrl: decoded['ctrl'] == true,
        alt: decoded['alt'] == true,
        shift: decoded['shift'] == true,
        command: decoded['command'] == true,
        label: decoded['label'] is String ? decoded['label'] as String : null,
      );
    } catch (_) {
      return fallback;
    }
  }
}

const Map<_FoldLanguageShortcutSlot, _FoldKeyShortcut>
    _kDefaultFoldLanguageShortcuts = {
  _FoldLanguageShortcutSlot.macPrev: _FoldKeyShortcut(
    key: 'VK_SPACE',
    ctrl: true,
    label: 'Ctrl+Space',
  ),
  _FoldLanguageShortcutSlot.macNext: _FoldKeyShortcut(
    key: 'VK_SPACE',
    ctrl: true,
    alt: true,
    label: 'Ctrl+Alt+Space',
  ),
  _FoldLanguageShortcutSlot.winPrev: _FoldKeyShortcut(
    key: 'VK_SHIFT',
    alt: true,
    label: 'Alt+Shift',
  ),
  _FoldLanguageShortcutSlot.winNext: _FoldKeyShortcut(
    key: 'VK_SPACE',
    command: true,
    label: 'Win+Space',
  ),
  _FoldLanguageShortcutSlot.linuxPrev: _FoldKeyShortcut(
    key: 'VK_SHIFT',
    ctrl: true,
    label: 'Ctrl+Shift',
  ),
  _FoldLanguageShortcutSlot.linuxNext: _FoldKeyShortcut(
    key: 'VK_SPACE',
    command: true,
    label: 'Super+Space',
  ),
};

String _foldLanguageSwitchModeValue(_FoldLanguageSwitchMode mode) {
  switch (mode) {
    case _FoldLanguageSwitchMode.macLanguageCycle:
      return 'macLanguageCycle';
    case _FoldLanguageSwitchMode.windowsLanguageCycle:
      return 'windowsLanguageCycle';
    case _FoldLanguageSwitchMode.linuxLanguageCycle:
      return 'linuxLanguageCycle';
  }
}

_FoldLanguageSwitchMode _foldLanguageSwitchModeFromValue(String value) {
  if (value == 'macGlobal') {
    return _FoldLanguageSwitchMode.macLanguageCycle;
  }
  for (final mode in _FoldLanguageSwitchMode.values) {
    if (_foldLanguageSwitchModeValue(mode) == value) {
      return mode;
    }
  }
  return _FoldLanguageSwitchMode.macLanguageCycle;
}

String _foldLanguageShortcutOptionKey(_FoldLanguageShortcutSlot slot) {
  switch (slot) {
    case _FoldLanguageShortcutSlot.macPrev:
      return 'fold.macPrevLanguageShortcut';
    case _FoldLanguageShortcutSlot.macNext:
      return 'fold.macNextLanguageShortcut';
    case _FoldLanguageShortcutSlot.winPrev:
      return 'fold.winPrevLanguageShortcut';
    case _FoldLanguageShortcutSlot.winNext:
      return 'fold.winNextLanguageShortcut';
    case _FoldLanguageShortcutSlot.linuxPrev:
      return 'fold.linuxPrevLanguageShortcut';
    case _FoldLanguageShortcutSlot.linuxNext:
      return 'fold.linuxNextLanguageShortcut';
  }
}

String _foldLanguageShortcutTitle(_FoldLanguageShortcutSlot slot) {
  switch (slot) {
    case _FoldLanguageShortcutSlot.macPrev:
      return translate('Set Previous Input Source Shortcut');
    case _FoldLanguageShortcutSlot.macNext:
      return translate('Set Input Next Source In Input Menu Shortcut');
    case _FoldLanguageShortcutSlot.winPrev:
    case _FoldLanguageShortcutSlot.linuxPrev:
      return translate('Set Previous Language Shortcut');
    case _FoldLanguageShortcutSlot.winNext:
    case _FoldLanguageShortcutSlot.linuxNext:
      return translate('Set Next Language Shortcut');
  }
}

String _foldPreviousLanguageTooltip(_FoldLanguageSwitchMode mode) {
  return mode == _FoldLanguageSwitchMode.macLanguageCycle
      ? translate('Previous Input Source')
      : translate('Previous Language');
}

String _foldNextLanguageTooltip(_FoldLanguageSwitchMode mode) {
  return mode == _FoldLanguageSwitchMode.macLanguageCycle
      ? translate('Next in Input Menu')
      : translate('Next Language');
}

List<_FoldLanguageShortcutSlot> _foldLanguageShortcutSlotsForMode(
    _FoldLanguageSwitchMode mode) {
  switch (mode) {
    case _FoldLanguageSwitchMode.macLanguageCycle:
      return const [
        _FoldLanguageShortcutSlot.macPrev,
        _FoldLanguageShortcutSlot.macNext,
      ];
    case _FoldLanguageSwitchMode.windowsLanguageCycle:
      return const [
        _FoldLanguageShortcutSlot.winPrev,
        _FoldLanguageShortcutSlot.winNext,
      ];
    case _FoldLanguageSwitchMode.linuxLanguageCycle:
      return const [
        _FoldLanguageShortcutSlot.linuxPrev,
        _FoldLanguageShortcutSlot.linuxNext,
      ];
  }
}

String _foldModifierDisplayStyleValue(_FoldModifierDisplayStyle style) {
  switch (style) {
    case _FoldModifierDisplayStyle.mac:
      return 'mac';
    case _FoldModifierDisplayStyle.win:
      return 'win';
    case _FoldModifierDisplayStyle.linux:
      return 'linux';
  }
}

_FoldModifierDisplayStyle? _foldModifierDisplayStyleFromValue(String value) {
  for (final style in _FoldModifierDisplayStyle.values) {
    if (_foldModifierDisplayStyleValue(style) == value) {
      return style;
    }
  }
  return null;
}

String _foldKeyboardInputModeValue(_FoldKeyboardInputMode mode) {
  switch (mode) {
    case _FoldKeyboardInputMode.textInjection:
      return 'textInjection';
    case _FoldKeyboardInputMode.remoteImeKeyEvents:
      return 'remoteImeKeyEvents';
  }
}

_FoldKeyboardInputMode _foldKeyboardInputModeFromValue(String value) {
  for (final mode in _FoldKeyboardInputMode.values) {
    if (_foldKeyboardInputModeValue(mode) == value) {
      return mode;
    }
  }
  return _FoldKeyboardInputMode.remoteImeKeyEvents;
}

_FoldTargetOs _foldTargetOsForLanguageSwitchMode(_FoldLanguageSwitchMode mode) {
  switch (mode) {
    case _FoldLanguageSwitchMode.macLanguageCycle:
      return _FoldTargetOs.mac;
    case _FoldLanguageSwitchMode.windowsLanguageCycle:
      return _FoldTargetOs.windows;
    case _FoldLanguageSwitchMode.linuxLanguageCycle:
      return _FoldTargetOs.linux;
  }
}

_FoldTargetOs _foldTargetOsForModifierDisplayStyle(
    _FoldModifierDisplayStyle style) {
  switch (style) {
    case _FoldModifierDisplayStyle.mac:
      return _FoldTargetOs.mac;
    case _FoldModifierDisplayStyle.win:
      return _FoldTargetOs.windows;
    case _FoldModifierDisplayStyle.linux:
      return _FoldTargetOs.linux;
  }
}

_FoldLanguageSwitchMode _foldLanguageSwitchModeForTargetOs(
    _FoldTargetOs targetOs) {
  switch (targetOs) {
    case _FoldTargetOs.mac:
      return _FoldLanguageSwitchMode.macLanguageCycle;
    case _FoldTargetOs.windows:
      return _FoldLanguageSwitchMode.windowsLanguageCycle;
    case _FoldTargetOs.linux:
      return _FoldLanguageSwitchMode.linuxLanguageCycle;
  }
}

_FoldModifierDisplayStyle _foldModifierDisplayStyleForTargetOs(
    _FoldTargetOs targetOs) {
  switch (targetOs) {
    case _FoldTargetOs.mac:
      return _FoldModifierDisplayStyle.mac;
    case _FoldTargetOs.windows:
      return _FoldModifierDisplayStyle.win;
    case _FoldTargetOs.linux:
      return _FoldModifierDisplayStyle.linux;
  }
}

String _foldTargetOsLabel(_FoldTargetOs targetOs) {
  switch (targetOs) {
    case _FoldTargetOs.mac:
      return translate('Mac');
    case _FoldTargetOs.windows:
      return translate('Windows');
    case _FoldTargetOs.linux:
      return translate('Linux');
  }
}

String _foldShortcutKeyLabel(
    String key, _FoldModifierDisplayStyle modifierDisplayStyle) {
  final labels = _foldModifierLabels(modifierDisplayStyle);
  switch (key) {
    case 'VK_SPACE':
      return translate('Space');
    case 'VK_SHIFT':
      return translate('Shift');
    case 'VK_CONTROL':
      return labels.control;
    case 'VK_MENU':
      return labels.alt;
    case 'Meta':
      return labels.meta;
    case 'VK_ESCAPE':
      return translate('Esc');
    case 'VK_TAB':
      return translate('Tab');
    case 'VK_BACK':
      return translate('Backspace');
    case 'VK_ENTER':
      return translate('Enter');
    default:
      if (key.startsWith('VK_') && key.length == 4) {
        return key.substring(3);
      }
      return key;
  }
}
