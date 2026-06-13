part of '../pages/remote_page.dart';

class _LocalRemoteKeyboard extends StatefulWidget {
  const _LocalRemoteKeyboard({
    Key? key,
    required this.ffi,
    required this.onCharacter,
    required this.onSpecialKey,
    required this.onComboKey,
    required this.onModifierChanged,
    required this.isCapturingShortcut,
    required this.onCaptureShortcutKey,
    required this.modifierDisplayStyle,
    required this.remoteImeModeEnabled,
    required this.onRemoteImeKeyEvent,
  }) : super(key: key);

  final FFI ffi;
  final ValueChanged<String> onCharacter;
  final ValueChanged<String> onSpecialKey;
  final void Function(String keyName, int usbHid) onRemoteImeKeyEvent;
  final ValueChanged<String> onCaptureShortcutKey;
  final VoidCallback onModifierChanged;
  final bool isCapturingShortcut;
  final bool remoteImeModeEnabled;
  final _FoldModifierDisplayStyle modifierDisplayStyle;
  final void Function(
    String key, {
    bool ctrl,
    bool alt,
    bool shift,
    bool command,
  }) onComboKey;

  @override
  State<_LocalRemoteKeyboard> createState() => _LocalRemoteKeyboardState();
}

class _LocalRemoteKeyboardState extends State<_LocalRemoteKeyboard> {
  _LocalKeyboardLayer _layer = _LocalKeyboardLayer.main;

  InputModel get inputModel => widget.ffi.inputModel;

  bool get _isMac => widget.ffi.ffiModel.pi.platform == kPeerPlatformMacOS;

  _FoldModifierLabels get _modifierLabels =>
      _foldModifierLabels(widget.modifierDisplayStyle);

  @override
  void didUpdateWidget(covariant _LocalRemoteKeyboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isCapturingShortcut && widget.isCapturingShortcut) {
      _layer = _LocalKeyboardLayer.system;
    }
  }

  List<Widget> _withHorizontalGaps(List<Widget> children, double gap) {
    final separated = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        separated.add(SizedBox(width: gap));
      }
      separated.add(children[i]);
    }
    return separated;
  }

  void _setLayer(_LocalKeyboardLayer layer) {
    setState(() => _layer = layer);
  }

  void _releaseMomentaryShift() {
    if (!inputModel.shift) {
      return;
    }
    setState(() => inputModel.shift = false);
    widget.onModifierChanged();
  }

  void _sendCombo(
    String key, {
    bool ctrl = false,
    bool alt = false,
    bool shift = false,
    bool command = false,
  }) {
    widget.onComboKey(
      key,
      ctrl: ctrl,
      alt: alt,
      shift: shift,
      command: command,
    );
    _releaseMomentaryShift();
  }

  Widget _keyButton({
    required VoidCallback? onPressed,
    String? label,
    IconData? icon,
    int flex = 1,
    required double height,
    required double fontSize,
    required double iconSize,
    bool selected = false,
    String? tooltip,
  }) {
    final button = SizedBox(
      height: height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor:
              selected ? MyTheme.accent80 : const Color(0xFF3B3D40),
          foregroundColor: Colors.white,
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: onPressed,
        child: icon == null
            ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label ?? '',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : Icon(icon, size: iconSize),
      ),
    );
    return Expanded(
      flex: flex,
      child:
          tooltip == null ? button : Tooltip(message: tooltip, child: button),
    );
  }

  Widget _row(List<Widget> keys, double gap) {
    return Row(children: _withHorizontalGaps(keys, gap));
  }

  Widget _layerButton({
    required _LocalKeyboardLayer layer,
    required IconData icon,
    required double keyHeight,
    required double fontSize,
    required double iconSize,
    required String tooltip,
  }) {
    return _keyButton(
      icon: icon,
      flex: 2,
      height: keyHeight,
      fontSize: fontSize,
      iconSize: iconSize,
      selected: _layer == layer,
      tooltip: tooltip,
      onPressed: () => _setLayer(layer),
    );
  }

  Widget _mainLayerButton(
    double keyHeight,
    double fontSize,
    double iconSize,
  ) {
    return _layerButton(
      layer: _LocalKeyboardLayer.main,
      icon: Icons.keyboard,
      keyHeight: keyHeight,
      fontSize: fontSize,
      iconSize: iconSize,
      tooltip: translate('Input Pane'),
    );
  }

  Widget _characterKey(
    String char,
    double keyHeight,
    double fontSize,
    double iconSize, {
    int flex = 1,
  }) {
    final label = char == ' '
        ? translate('Space')
        : char == '\n'
            ? translate('Enter')
            : char;
    return _keyButton(
      label: label,
      flex: flex,
      height: keyHeight,
      fontSize: fontSize,
      iconSize: iconSize,
      onPressed: () {
        if (widget.isCapturingShortcut) {
          return;
        }
        final remoteImeKey = widget.remoteImeModeEnabled
            ? _foldRemoteImeKeyEventForCharacter(char)
            : null;
        if (remoteImeKey != null) {
          widget.onRemoteImeKeyEvent(remoteImeKey.keyName, remoteImeKey.usbHid);
          _releaseMomentaryShift();
          return;
        }
        widget.onCharacter(char);
        _releaseMomentaryShift();
      },
    );
  }

  Widget _specialKey(
    String label,
    String key,
    double keyHeight,
    double fontSize,
    double iconSize, {
    IconData? icon,
    int flex = 1,
  }) {
    return _keyButton(
      label: icon == null ? label : null,
      icon: icon,
      flex: flex,
      height: keyHeight,
      fontSize: fontSize,
      iconSize: iconSize,
      onPressed: () {
        if (widget.isCapturingShortcut) {
          widget.onCaptureShortcutKey(key);
          return;
        }
        final remoteImeKey = widget.remoteImeModeEnabled
            ? _foldRemoteImeKeyEventForKeyName(key)
            : null;
        if (remoteImeKey != null) {
          widget.onRemoteImeKeyEvent(remoteImeKey.keyName, remoteImeKey.usbHid);
          _releaseMomentaryShift();
          return;
        }
        widget.onSpecialKey(key);
        _releaseMomentaryShift();
      },
    );
  }

  Widget _modifierKey(
    String label,
    bool active,
    VoidCallback onPressed,
    double keyHeight,
    double fontSize,
    double iconSize,
  ) {
    return _keyButton(
      label: label,
      height: keyHeight,
      fontSize: fontSize,
      iconSize: iconSize,
      selected: active,
      onPressed: onPressed,
    );
  }

  Widget _characterRow(
    String characters,
    double keyHeight,
    double gap,
    double fontSize,
    double iconSize,
  ) {
    final keys = characters
        .split('')
        .map((char) => _characterKey(
              char,
              keyHeight,
              fontSize,
              iconSize,
            ))
        .toList();
    return _row(keys, gap);
  }

  List<Widget> _mainRows(
    double keyHeight,
    double gap,
    double fontSize,
    double iconSize,
  ) {
    return [
      _row([
        _layerButton(
          layer: _LocalKeyboardLayer.system,
          icon: Icons.tune,
          keyHeight: keyHeight,
          fontSize: fontSize,
          iconSize: iconSize,
          tooltip: translate('System Keys'),
        ),
        ...'1234567890'.split('').map(
              (char) => _characterKey(char, keyHeight, fontSize, iconSize),
            ),
        _layerButton(
          layer: _LocalKeyboardLayer.symbols,
          icon: Icons.tag,
          keyHeight: keyHeight,
          fontSize: fontSize,
          iconSize: iconSize,
          tooltip: translate('Symbols'),
        ),
      ], gap),
      _characterRow('qwertyuiop', keyHeight, gap, fontSize, iconSize),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: keyHeight * 0.22),
        child: _characterRow('asdfghjkl', keyHeight, gap, fontSize, iconSize),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: keyHeight * 0.44),
        child: _characterRow('zxcvbnm', keyHeight, gap, fontSize, iconSize),
      ),
      _row([
        _specialKey('Esc', 'VK_ESCAPE', keyHeight, fontSize, iconSize),
        _specialKey('Tab', 'VK_TAB', keyHeight, fontSize, iconSize),
        _specialKey(
          'Backspace',
          'VK_BACK',
          keyHeight,
          fontSize,
          iconSize,
          icon: Icons.backspace_outlined,
          flex: 2,
        ),
      ], gap),
      _row([
        _characterKey(' ', keyHeight, fontSize, iconSize, flex: 5),
        _characterKey('\n', keyHeight, fontSize, iconSize, flex: 2),
      ], gap),
    ];
  }

  List<Widget> _systemRows(
    double keyHeight,
    double gap,
    double fontSize,
    double iconSize,
  ) {
    void toggleModifier(String key, void Function() update) {
      setState(update);
      widget.onModifierChanged();
      if (widget.isCapturingShortcut) {
        widget.onCaptureShortcutKey(key);
      }
    }

    final shift = _modifierKey(
        translate('Shift'),
        inputModel.shift,
        () => toggleModifier(
            'VK_SHIFT', () => inputModel.shift = !inputModel.shift),
        keyHeight,
        fontSize,
        iconSize);
    final control = _modifierKey(
        _modifierLabels.control,
        inputModel.ctrl,
        () => toggleModifier(
            'VK_CONTROL', () => inputModel.ctrl = !inputModel.ctrl),
        keyHeight,
        fontSize,
        iconSize);
    final alt = _modifierKey(
        _modifierLabels.alt,
        inputModel.alt,
        () => toggleModifier('VK_MENU', () => inputModel.alt = !inputModel.alt),
        keyHeight,
        fontSize,
        iconSize);
    final meta = _modifierKey(
        _modifierLabels.meta,
        inputModel.command,
        () => toggleModifier(
            'Meta', () => inputModel.command = !inputModel.command),
        keyHeight,
        fontSize,
        iconSize);
    final modifierKeys =
        widget.modifierDisplayStyle == _FoldModifierDisplayStyle.mac
            ? [shift, control, alt, meta]
            : [shift, control, meta, alt];

    return [
      _row([
        _mainLayerButton(keyHeight, fontSize, iconSize),
        ...modifierKeys,
      ], gap),
      _row([
        for (var i = 1; i <= 6; i++)
          _specialKey('F$i', 'VK_F$i', keyHeight, fontSize, iconSize),
      ], gap),
      _row([
        for (var i = 7; i <= 12; i++)
          _specialKey('F$i', 'VK_F$i', keyHeight, fontSize, iconSize),
      ], gap),
      _row([
        _specialKey('Home', 'VK_HOME', keyHeight, fontSize, iconSize),
        _specialKey('End', 'VK_END', keyHeight, fontSize, iconSize),
        _specialKey('PgUp', 'VK_PRIOR', keyHeight, fontSize, iconSize),
        _specialKey('PgDn', 'VK_NEXT', keyHeight, fontSize, iconSize),
        _specialKey('Ins', 'VK_INSERT', keyHeight, fontSize, iconSize),
        _specialKey('Del', 'VK_DELETE', keyHeight, fontSize, iconSize),
      ], gap),
      _row([
        _specialKey('Esc', 'VK_ESCAPE', keyHeight, fontSize, iconSize),
        _specialKey('Tab', 'VK_TAB', keyHeight, fontSize, iconSize),
        _specialKey('Space', 'VK_SPACE', keyHeight, fontSize, iconSize,
            flex: 2),
        _specialKey('Back', 'VK_BACK', keyHeight, fontSize, iconSize,
            icon: Icons.backspace_outlined),
        _specialKey('Enter', 'VK_ENTER', keyHeight, fontSize, iconSize,
            icon: Icons.keyboard_return),
        _specialKey('', 'VK_LEFT', keyHeight, fontSize, iconSize,
            icon: Icons.keyboard_arrow_left),
        _specialKey('', 'VK_UP', keyHeight, fontSize, iconSize,
            icon: Icons.keyboard_arrow_up),
        _specialKey('', 'VK_DOWN', keyHeight, fontSize, iconSize,
            icon: Icons.keyboard_arrow_down),
        _specialKey('', 'VK_RIGHT', keyHeight, fontSize, iconSize,
            icon: Icons.keyboard_arrow_right),
      ], gap),
      _row([
        _keyButton(
          label: _isMac ? 'Cmd+C' : 'Ctrl+C',
          height: keyHeight,
          fontSize: fontSize,
          iconSize: iconSize,
          onPressed: widget.isCapturingShortcut
              ? null
              : () => _sendCombo(
                    'VK_C',
                    ctrl: !_isMac,
                    command: _isMac,
                  ),
        ),
        _keyButton(
          label: _isMac ? 'Cmd+V' : 'Ctrl+V',
          height: keyHeight,
          fontSize: fontSize,
          iconSize: iconSize,
          onPressed: widget.isCapturingShortcut
              ? null
              : () => _sendCombo(
                    'VK_V',
                    ctrl: !_isMac,
                    command: _isMac,
                  ),
        ),
        _keyButton(
          label: 'Ctrl+Alt+Del',
          flex: 2,
          height: keyHeight,
          fontSize: fontSize,
          iconSize: iconSize,
          onPressed: widget.isCapturingShortcut
              ? null
              : () => _sendCombo(
                    'VK_DELETE',
                    ctrl: true,
                    alt: true,
                  ),
        ),
      ], gap),
    ];
  }

  List<Widget> _symbolRows(
    double keyHeight,
    double gap,
    double fontSize,
    double iconSize,
  ) {
    Widget symbolKey(String symbol) =>
        _characterKey(symbol, keyHeight, fontSize, iconSize);
    return [
      _row([
        _mainLayerButton(keyHeight, fontSize, iconSize),
        ...['~', '!', '@', '#', '\$', '%', '^', '&']
            .map((symbol) => symbolKey(symbol)),
      ], gap),
      _row([
        ...['*', '(', ')', '-', '_', '=', '+', '[']
            .map((symbol) => symbolKey(symbol)),
      ], gap),
      _row([
        ...[']', '{', '}', '\\', '|', ';', ':', "'"]
            .map((symbol) => symbolKey(symbol)),
      ], gap),
      _row([
        ...['"', ',', '.', '/', '?', '<', '>']
            .map((symbol) => symbolKey(symbol)),
      ], gap),
    ];
  }

  int get _rowCount {
    switch (_layer) {
      case _LocalKeyboardLayer.main:
      case _LocalKeyboardLayer.system:
        return 6;
      case _LocalKeyboardLayer.symbols:
        return 4;
    }
  }

  List<Widget> _rows(
    double keyHeight,
    double gap,
    double fontSize,
    double iconSize,
  ) {
    switch (_layer) {
      case _LocalKeyboardLayer.main:
        return _mainRows(keyHeight, gap, fontSize, iconSize);
      case _LocalKeyboardLayer.system:
        return _systemRows(keyHeight, gap, fontSize, iconSize);
      case _LocalKeyboardLayer.symbols:
        return _symbolRows(keyHeight, gap, fontSize, iconSize);
    }
  }

  List<Widget> _withVerticalGaps(List<Widget> rows, double gap) {
    final separated = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) {
        separated.add(SizedBox(height: gap));
      }
      separated.add(rows[i]);
    }
    return separated;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF202124),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF4B4D50)),
            left: BorderSide(color: Color(0xFF4B4D50)),
          ),
        ),
        child: LayoutBuilder(builder: (context, constraints) {
          final availableHeight =
              constraints.maxHeight.isFinite ? constraints.maxHeight : 320.0;
          final availableWidth =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 420.0;
          final compact = availableHeight < 300 || availableWidth < 360;
          final padding = compact ? 6.0 : 8.0;
          final gap = (availableHeight / 80).clamp(3.0, 7.0).toDouble();
          final keyHeight =
              ((availableHeight - padding * 2 - gap * (_rowCount - 1)) /
                      _rowCount)
                  .clamp(30.0, 60.0)
                  .toDouble();
          final fontSize = (keyHeight * 0.42).clamp(12.0, 22.0).toDouble();
          final iconSize = (keyHeight * 0.48).clamp(16.0, 26.0).toDouble();
          final rows = _rows(keyHeight, gap, fontSize, iconSize);
          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _withVerticalGaps(rows, gap),
            ),
          );
        }),
      ),
    );
  }
}
