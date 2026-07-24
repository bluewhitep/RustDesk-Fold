part of '../pages/remote_page.dart';

class _FoldInputPane extends StatelessWidget {
  const _FoldInputPane({
    required this.splitAxis,
    required this.trackpadPlacement,
    required this.touchpadRatio,
    required this.hapticStrengthPercent,
    required this.ffi,
    required this.keyboard,
    required this.onToggleTrackpadPlacement,
    required this.onModifierPressed,
    required this.onModifierChanged,
    required this.inputRevision,
    required this.displayMode,
    required this.fitRemoteResolutionEnabled,
    required this.canFitRemoteResolution,
    required this.onDisplayModeSelected,
    required this.onToggleFitRemoteResolution,
    required this.displayModeLabel,
    required this.displayModeIcon,
    required this.modifierDisplayStyle,
    required this.paneResizeMode,
    required this.paneRatioLabel,
    required this.onTogglePaneResizeMode,
    required this.languageSwitchMode,
    required this.previousLanguageTooltip,
    required this.nextLanguageTooltip,
    required this.onPreviousLanguagePressed,
    required this.onNextLanguagePressed,
    required this.onLanguageSettingsPressed,
    required this.onOfficialOptionsPressed,
    required this.onClosePressed,
    required this.onMoreActionsPressed,
    required this.onChatPressed,
    required this.onToggleTouchMode,
    required this.canToggleTouchMode,
    required this.touchMode,
    required this.shortcutCaptureLabel,
    required this.shortcutCapturePreview,
    required this.canSaveShortcutCapture,
    required this.onSaveShortcutCapture,
    required this.onCancelShortcutCapture,
    this.toolsBar,
  });

  final Axis splitAxis;
  final _TrackpadPlacement trackpadPlacement;
  final double touchpadRatio;
  final int hapticStrengthPercent;
  final FFI ffi;
  final Widget keyboard;
  final Widget? toolsBar;
  final VoidCallback onToggleTrackpadPlacement;
  final ValueChanged<String> onModifierPressed;
  final VoidCallback onModifierChanged;
  final int inputRevision;
  final _FoldRemoteDisplayMode displayMode;
  final bool fitRemoteResolutionEnabled;
  final bool canFitRemoteResolution;
  final ValueChanged<_FoldRemoteDisplayMode> onDisplayModeSelected;
  final VoidCallback onToggleFitRemoteResolution;
  final String Function(_FoldRemoteDisplayMode mode) displayModeLabel;
  final IconData Function(_FoldRemoteDisplayMode mode) displayModeIcon;
  final _FoldModifierDisplayStyle modifierDisplayStyle;
  final bool paneResizeMode;
  final String paneRatioLabel;
  final VoidCallback onTogglePaneResizeMode;
  final _FoldLanguageSwitchMode languageSwitchMode;
  final String previousLanguageTooltip;
  final String nextLanguageTooltip;
  final VoidCallback onPreviousLanguagePressed;
  final VoidCallback onNextLanguagePressed;
  final VoidCallback onLanguageSettingsPressed;
  final VoidCallback onOfficialOptionsPressed;
  final VoidCallback onClosePressed;
  final VoidCallback onMoreActionsPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onToggleTouchMode;
  final bool canToggleTouchMode;
  final bool touchMode;
  final String? shortcutCaptureLabel;
  final String shortcutCapturePreview;
  final bool canSaveShortcutCapture;
  final VoidCallback onSaveShortcutCapture;
  final VoidCallback onCancelShortcutCapture;

  Axis get _inputAxis =>
      splitAxis == Axis.vertical ? Axis.horizontal : Axis.vertical;

  bool _trackpadFirst(Axis inputAxis) {
    return trackpadPlacement == _TrackpadPlacement.left;
  }

  Widget _divider(Axis axis) {
    return SizedBox(
      width: axis == Axis.horizontal ? 1 : double.infinity,
      height: axis == Axis.vertical ? 1 : double.infinity,
      child: const DecoratedBox(
        decoration: BoxDecoration(color: Color(0xFF4B4D50)),
      ),
    );
  }

  Widget _inputContent(
    BuildContext context,
    bool showTrackpad,
    Axis inputAxis,
  ) {
    if (!showTrackpad) {
      return keyboard;
    }
    final touchpadFlex = (touchpadRatio * 1000).round();
    final keyboardFlex = ((1 - touchpadRatio) * 1000).round();
    final trackpad = Expanded(
      flex: touchpadFlex,
      child: _FoldTouchpad(
        ffi: ffi,
        hapticStrengthPercent: hapticStrengthPercent,
      ),
    );
    final keyboardPane = Expanded(
      flex: keyboardFlex,
      child: keyboard,
    );
    final children = _trackpadFirst(inputAxis)
        ? <Widget>[trackpad, _divider(inputAxis), keyboardPane]
        : <Widget>[keyboardPane, _divider(inputAxis), trackpad];
    return Flex(
      direction: inputAxis,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ffiModel = Provider.of<FfiModel>(context);
    final showTrackpad = !ffiModel.touchMode;
    final inputAxis = _inputAxis;
    return Material(
      color: const Color(0xFF202124),
      child: LayoutBuilder(builder: (context, constraints) {
        final maxToolsHeight = constraints.maxHeight.isFinite
            ? (constraints.maxHeight * 0.45).clamp(48.0, 180.0).toDouble()
            : 120.0;
        return Column(
          children: [
            _FoldInputToolbar(
              ffi: ffi,
              showTrackpad: showTrackpad,
              inputAxis: inputAxis,
              trackpadPlacement: trackpadPlacement,
              inputRevision: inputRevision,
              displayMode: displayMode,
              fitRemoteResolutionEnabled: fitRemoteResolutionEnabled,
              canFitRemoteResolution: canFitRemoteResolution,
              displayModeLabel: displayModeLabel,
              displayModeIcon: displayModeIcon,
              modifierDisplayStyle: modifierDisplayStyle,
              paneResizeMode: paneResizeMode,
              paneRatioLabel: paneRatioLabel,
              onTogglePaneResizeMode: onTogglePaneResizeMode,
              languageSwitchMode: languageSwitchMode,
              previousLanguageTooltip: previousLanguageTooltip,
              nextLanguageTooltip: nextLanguageTooltip,
              onToggleTrackpadPlacement: onToggleTrackpadPlacement,
              onModifierPressed: onModifierPressed,
              onModifierChanged: onModifierChanged,
              onDisplayModeSelected: onDisplayModeSelected,
              onToggleFitRemoteResolution: onToggleFitRemoteResolution,
              onPreviousLanguagePressed: onPreviousLanguagePressed,
              onNextLanguagePressed: onNextLanguagePressed,
              onLanguageSettingsPressed: onLanguageSettingsPressed,
              onOfficialOptionsPressed: onOfficialOptionsPressed,
              onClosePressed: onClosePressed,
              onMoreActionsPressed: onMoreActionsPressed,
              onChatPressed: onChatPressed,
              onToggleTouchMode: onToggleTouchMode,
              canToggleTouchMode: canToggleTouchMode,
              touchMode: touchMode,
              shortcutCaptureLabel: shortcutCaptureLabel,
              shortcutCapturePreview: shortcutCapturePreview,
              canSaveShortcutCapture: canSaveShortcutCapture,
              onSaveShortcutCapture: onSaveShortcutCapture,
              onCancelShortcutCapture: onCancelShortcutCapture,
            ),
            Expanded(child: _inputContent(context, showTrackpad, inputAxis)),
            if (toolsBar != null)
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxToolsHeight),
                child: toolsBar!,
              ),
          ],
        );
      }),
    );
  }
}

class _FoldInputToolbar extends StatelessWidget {
  const _FoldInputToolbar({
    required this.ffi,
    required this.showTrackpad,
    required this.inputAxis,
    required this.trackpadPlacement,
    required this.inputRevision,
    required this.displayMode,
    required this.fitRemoteResolutionEnabled,
    required this.canFitRemoteResolution,
    required this.displayModeLabel,
    required this.displayModeIcon,
    required this.modifierDisplayStyle,
    required this.paneResizeMode,
    required this.paneRatioLabel,
    required this.onTogglePaneResizeMode,
    required this.languageSwitchMode,
    required this.previousLanguageTooltip,
    required this.nextLanguageTooltip,
    required this.onToggleTrackpadPlacement,
    required this.onModifierPressed,
    required this.onModifierChanged,
    required this.onDisplayModeSelected,
    required this.onToggleFitRemoteResolution,
    required this.onPreviousLanguagePressed,
    required this.onNextLanguagePressed,
    required this.onLanguageSettingsPressed,
    required this.onOfficialOptionsPressed,
    required this.onClosePressed,
    required this.onMoreActionsPressed,
    required this.onChatPressed,
    required this.onToggleTouchMode,
    required this.canToggleTouchMode,
    required this.touchMode,
    required this.shortcutCaptureLabel,
    required this.shortcutCapturePreview,
    required this.canSaveShortcutCapture,
    required this.onSaveShortcutCapture,
    required this.onCancelShortcutCapture,
  });

  final FFI ffi;
  final bool showTrackpad;
  final Axis inputAxis;
  final _TrackpadPlacement trackpadPlacement;
  final int inputRevision;
  final _FoldRemoteDisplayMode displayMode;
  final bool fitRemoteResolutionEnabled;
  final bool canFitRemoteResolution;
  final String Function(_FoldRemoteDisplayMode mode) displayModeLabel;
  final IconData Function(_FoldRemoteDisplayMode mode) displayModeIcon;
  final _FoldModifierDisplayStyle modifierDisplayStyle;
  final bool paneResizeMode;
  final String paneRatioLabel;
  final VoidCallback onTogglePaneResizeMode;
  final _FoldLanguageSwitchMode languageSwitchMode;
  final String previousLanguageTooltip;
  final String nextLanguageTooltip;
  final VoidCallback onToggleTrackpadPlacement;
  final ValueChanged<String> onModifierPressed;
  final VoidCallback onModifierChanged;
  final ValueChanged<_FoldRemoteDisplayMode> onDisplayModeSelected;
  final VoidCallback onToggleFitRemoteResolution;
  final VoidCallback onPreviousLanguagePressed;
  final VoidCallback onNextLanguagePressed;
  final VoidCallback onLanguageSettingsPressed;
  final VoidCallback onOfficialOptionsPressed;
  final VoidCallback onClosePressed;
  final VoidCallback onMoreActionsPressed;
  final VoidCallback onChatPressed;
  final VoidCallback onToggleTouchMode;
  final bool canToggleTouchMode;
  final bool touchMode;
  final String? shortcutCaptureLabel;
  final String shortcutCapturePreview;
  final bool canSaveShortcutCapture;
  final VoidCallback onSaveShortcutCapture;
  final VoidCallback onCancelShortcutCapture;

  InputModel get inputModel => ffi.inputModel;

  void _toggleModifier(void Function(InputModel model) update) {
    update(inputModel);
    onModifierChanged();
  }

  Widget _separator() => const SizedBox(
        height: 24,
        child: VerticalDivider(width: 1, color: Color(0xFF4B4D50)),
      );

  Widget _iconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool selected = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      color: selected ? MyTheme.accent : Colors.white70,
      disabledColor: Colors.white24,
      icon: Icon(icon, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
    );
  }

  Widget _coloredIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    final background = onPressed == null ? Colors.white12 : color;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 40,
        height: 32,
        child: Tooltip(
          message: tooltip,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: background,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white38,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: onPressed,
            child: Icon(icon, size: 18),
          ),
        ),
      ),
    );
  }

  Widget _languageSwitchIcon(IconData overlayIcon) {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Icon(Icons.language, size: 20),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D1F),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 0.8),
              ),
              child: Icon(overlayIcon, size: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageIconButton({
    required IconData overlayIcon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      color: Colors.white70,
      icon: _languageSwitchIcon(overlayIcon),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      onPressed: onPressed,
    );
  }

  Widget _modifierButton({
    required String label,
    required bool selected,
    required VoidCallback onPressed,
    required VoidCallback onLongPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 32,
        child: TextButton(
          style: TextButton.styleFrom(
            backgroundColor:
                selected ? MyTheme.accent80 : const Color(0xFF313438),
            foregroundColor: Colors.white,
            minimumSize: const Size(44, 32),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: onPressed,
          onLongPress: onLongPress,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _trackpadPlacementButton() {
    final nextIsLeft = trackpadPlacement == _TrackpadPlacement.right;
    final icon = inputAxis == Axis.horizontal
        ? (nextIsLeft
            ? Icons.keyboard_double_arrow_left
            : Icons.keyboard_double_arrow_right)
        : (nextIsLeft
            ? Icons.keyboard_double_arrow_up
            : Icons.keyboard_double_arrow_down);
    return _iconButton(
      tooltip:
          nextIsLeft ? translate('Trackpad Left') : translate('Trackpad Right'),
      icon: icon,
      onPressed: showTrackpad ? onToggleTrackpadPlacement : null,
    );
  }

  Widget _displayModeButton() {
    return PopupMenuButton<_FoldRemoteDisplayMode>(
      tooltip: '${translate('Display Mode')}: ${displayModeLabel(displayMode)}',
      initialValue: displayMode,
      icon: Icon(
        displayModeIcon(displayMode),
        color: Colors.white70,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      onSelected: onDisplayModeSelected,
      itemBuilder: (context) => _FoldRemoteDisplayMode.values
          .map((mode) => PopupMenuItem<_FoldRemoteDisplayMode>(
                value: mode,
                child: Text(displayModeLabel(mode)),
              ))
          .toList(),
    );
  }

  Widget _paneRatioButton() {
    return _iconButton(
      tooltip: '${translate('Adjust Split Ratio')}: $paneRatioLabel',
      icon: Icons.splitscreen,
      selected: paneResizeMode,
      onPressed: onTogglePaneResizeMode,
    );
  }

  List<Widget> _languageButtons() {
    final previousOverlay =
        languageSwitchMode == _FoldLanguageSwitchMode.macLanguageCycle
            ? Icons.sync
            : Icons.arrow_back;
    return [
      _languageIconButton(
        overlayIcon: previousOverlay,
        tooltip: previousLanguageTooltip,
        onPressed: onPreviousLanguagePressed,
      ),
      _languageIconButton(
        overlayIcon: Icons.arrow_forward,
        tooltip: nextLanguageTooltip,
        onPressed: onNextLanguagePressed,
      ),
    ];
  }

  List<Widget> _shortcutCaptureButtons() {
    final label = shortcutCaptureLabel;
    if (label == null) {
      return const [];
    }
    return [
      _coloredIconButton(
        tooltip: '$label: $shortcutCapturePreview\n${translate('Save')}',
        icon: Icons.check,
        color: const Color(0xFF2563EB),
        onPressed: canSaveShortcutCapture ? onSaveShortcutCapture : null,
      ),
      _coloredIconButton(
        tooltip: translate('Cancel'),
        icon: Icons.close,
        color: const Color(0xFFDC2626),
        onPressed: onCancelShortcutCapture,
      ),
    ];
  }

  List<Widget> _modifierButtons(_FoldModifierLabels modifierLabels) {
    final isCapturingShortcut = shortcutCaptureLabel != null;

    final shift = _modifierButton(
      label: translate('Shift'),
      selected: inputModel.shift,
      onPressed: isCapturingShortcut
          ? () => _toggleModifier((model) => model.shift = !model.shift)
          : () => onModifierPressed('VK_SHIFT'),
      onLongPress: () => _toggleModifier((model) => model.shift = !model.shift),
    );
    final control = _modifierButton(
      label: modifierLabels.control,
      selected: inputModel.ctrl,
      onPressed: isCapturingShortcut
          ? () => _toggleModifier((model) => model.ctrl = !model.ctrl)
          : () => onModifierPressed('VK_CONTROL'),
      onLongPress: () => _toggleModifier((model) => model.ctrl = !model.ctrl),
    );
    final alt = _modifierButton(
      label: modifierLabels.alt,
      selected: inputModel.alt,
      onPressed: isCapturingShortcut
          ? () => _toggleModifier((model) => model.alt = !model.alt)
          : () => onModifierPressed('VK_MENU'),
      onLongPress: () => _toggleModifier((model) => model.alt = !model.alt),
    );
    final meta = _modifierButton(
      label: modifierLabels.meta,
      selected: inputModel.command,
      onPressed: isCapturingShortcut
          ? () => _toggleModifier((model) => model.command = !model.command)
          : () => onModifierPressed('Meta'),
      onLongPress: () =>
          _toggleModifier((model) => model.command = !model.command),
    );
    if (modifierDisplayStyle == _FoldModifierDisplayStyle.mac) {
      return [shift, control, alt, meta];
    }
    return [shift, control, meta, alt];
  }

  @override
  Widget build(BuildContext context) {
    // Read this value so the toolbar rebuilds when parent modifier state changes.
    final _ = inputRevision;
    final modifierLabels = _foldModifierLabels(modifierDisplayStyle);
    return SizedBox(
      height: 44,
      child: Material(
        color: const Color(0xFF1B1D1F),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _iconButton(
                tooltip: translate('Close'),
                icon: Icons.clear,
                onPressed: onClosePressed,
              ),
              _iconButton(
                tooltip: translate('Official Settings'),
                icon: Icons.tv,
                onPressed: onOfficialOptionsPressed,
              ),
              _iconButton(
                tooltip: translate('Text chat'),
                icon: Icons.message,
                onPressed: onChatPressed,
              ),
              _iconButton(
                tooltip: translate(touchMode ? 'Mouse mode' : 'Touch mode'),
                icon: touchMode ? Icons.mouse : Icons.touch_app,
                onPressed: canToggleTouchMode ? onToggleTouchMode : null,
              ),
              _iconButton(
                tooltip: translate('More'),
                icon: Icons.more_vert,
                onPressed: onMoreActionsPressed,
              ),
              _separator(),
              _displayModeButton(),
              _paneRatioButton(),
              if (canFitRemoteResolution)
                _iconButton(
                  tooltip: translate('resolution_fit_local_tip'),
                  icon: Icons.display_settings,
                  selected: fitRemoteResolutionEnabled,
                  onPressed: onToggleFitRemoteResolution,
                ),
              _separator(),
              ..._modifierButtons(modifierLabels),
              _separator(),
              ..._languageButtons(),
              _iconButton(
                tooltip: translate('Target OS'),
                icon: Icons.tune,
                onPressed: onLanguageSettingsPressed,
              ),
              ..._shortcutCaptureButtons(),
              _separator(),
              _trackpadPlacementButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoldTouchpad extends StatefulWidget {
  const _FoldTouchpad({
    required this.ffi,
    required this.hapticStrengthPercent,
  });

  final FFI ffi;
  final int hapticStrengthPercent;

  @override
  State<_FoldTouchpad> createState() => _FoldTouchpadState();
}

class _FoldTouchpadState extends State<_FoldTouchpad> {
  static const double _tapSlop = 8.0;
  static const double _scrollScale = 0.65;
  static const Duration _longPressDelay = Duration(milliseconds: 450);

  final Map<int, Offset> _activePointers = {};
  Offset? _lastFocalPoint;
  Offset _scrollRemainder = Offset.zero;
  Offset? _wheelPointerLastPosition;
  Timer? _longPressTimer;
  double _gestureDistance = 0.0;
  double _wheelPointerDistance = 0.0;
  int _maxPointerCount = 0;
  int? _primaryPointer;
  int? _wheelPointer;
  bool _longPressDragActive = false;
  bool _wheelScrollModeActive = false;

  Offset get _currentFocalPoint {
    if (_activePointers.isEmpty) {
      return Offset.zero;
    }
    var x = 0.0;
    var y = 0.0;
    for (final point in _activePointers.values) {
      x += point.dx;
      y += point.dy;
    }
    return Offset(x / _activePointers.length, y / _activePointers.length);
  }

  void _startPointer(PointerDownEvent event) {
    if (_activePointers.isEmpty) {
      _gestureDistance = 0.0;
      _maxPointerCount = 0;
      _lastFocalPoint = event.localPosition;
      _primaryPointer = event.pointer;
      _tapHaptic();
      _startLongPressTimer(event);
    }
    _activePointers[event.pointer] = event.localPosition;
    _maxPointerCount = _maxPointerCount < _activePointers.length
        ? _activePointers.length
        : _maxPointerCount;
    _lastFocalPoint = _currentFocalPoint;
    if (_activePointers.length > 1) {
      _cancelLongPressTimer();
      _releaseLongPressDrag();
    }
  }

  void _movePointer(PointerMoveEvent event) {
    if (!_activePointers.containsKey(event.pointer)) {
      return;
    }
    final previousFocalPoint = _lastFocalPoint ?? _currentFocalPoint;
    _activePointers[event.pointer] = event.localPosition;
    final nextFocalPoint = _currentFocalPoint;
    final delta = nextFocalPoint - previousFocalPoint;
    _lastFocalPoint = nextFocalPoint;
    if (delta == Offset.zero) {
      return;
    }
    _gestureDistance += delta.distance;
    if (_wheelScrollModeActive) {
      _cancelLongPressTimer();
      _releaseLongPressDrag();
      _sendTrackpadScroll(delta);
      return;
    }
    if (_activePointers.length >= 2) {
      _cancelLongPressTimer();
      _releaseLongPressDrag();
      _sendTrackpadScroll(delta);
    } else {
      if (!_longPressDragActive && _gestureDistance >= _tapSlop) {
        _cancelLongPressTimer();
      }
      unawaited(widget.ffi.cursorModel.updatePan(
        delta,
        event.localPosition,
        false,
      ));
    }
  }

  void _endPointer(PointerEvent event) {
    final wasPrimaryPointer = event.pointer == _primaryPointer;
    _activePointers.remove(event.pointer);
    if (_activePointers.isNotEmpty) {
      if (wasPrimaryPointer) {
        _cancelLongPressTimer();
        _releaseLongPressDrag();
        _primaryPointer = null;
      }
      _lastFocalPoint = _currentFocalPoint;
      return;
    }
    final isTap = _gestureDistance < _tapSlop;
    final pointerCount = _maxPointerCount;
    _cancelLongPressTimer();
    _lastFocalPoint = null;
    _gestureDistance = 0.0;
    _maxPointerCount = 0;
    _primaryPointer = null;
    if (_longPressDragActive) {
      _releaseLongPressDrag();
      return;
    }
    if (_wheelScrollModeActive) {
      return;
    }
    if (!isTap) {
      return;
    }
    unawaited(widget.ffi.inputModel
        .tap(pointerCount >= 2 ? MouseButtons.right : MouseButtons.left));
  }

  void _startLongPressTimer(PointerDownEvent event) {
    _cancelLongPressTimer();
    _longPressTimer = Timer(_longPressDelay, () {
      if (!mounted ||
          _primaryPointer != event.pointer ||
          !_activePointers.containsKey(event.pointer) ||
          _activePointers.length != 1 ||
          _gestureDistance >= _tapSlop ||
          _wheelScrollModeActive ||
          _longPressDragActive) {
        return;
      }
      _longPressDragActive = true;
      _longPressHaptic();
      unawaited(widget.ffi.inputModel.tapDown(MouseButtons.left));
    });
  }

  void _cancelLongPressTimer() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
  }

  void _releaseLongPressDrag() {
    if (!_longPressDragActive) {
      return;
    }
    _longPressDragActive = false;
    unawaited(widget.ffi.inputModel.tapUp(MouseButtons.left));
  }

  void _tapHaptic() {
    unawaited(_performFoldHapticFeedback(
      strengthPercent: widget.hapticStrengthPercent,
    ));
  }

  void _longPressHaptic() {
    unawaited(_performFoldHapticFeedback(
      strengthPercent: widget.hapticStrengthPercent,
      activated: true,
    ));
  }

  void _sendTrackpadScroll(Offset rawDelta) {
    if (!widget.ffi.inputModel.keyboardPerm ||
        widget.ffi.inputModel.isViewCamera) {
      return;
    }
    final speed = widget.ffi.inputModel.trackpadSpeed / 100.0;
    _scrollRemainder += rawDelta * speed * _scrollScale;
    final x = _scrollRemainder.dx.truncate();
    final y = _scrollRemainder.dy.truncate();
    if (x == 0 && y == 0) {
      return;
    }
    _scrollRemainder -= Offset(x.toDouble(), y.toDouble());
    unawaited(bind.sessionSendMouse(
      sessionId: widget.ffi.sessionId,
      msg: json.encode(widget.ffi.inputModel.modify({
        'type': 'trackpad',
        'x': '$x',
        'y': '$y',
      })),
    ));
  }

  void _setWheelScrollMode(bool active) {
    if (_wheelScrollModeActive == active) {
      return;
    }
    _cancelLongPressTimer();
    _releaseLongPressDrag();
    _scrollRemainder = Offset.zero;
    _activePointers.clear();
    _lastFocalPoint = null;
    _gestureDistance = 0.0;
    _maxPointerCount = 0;
    _primaryPointer = null;
    setState(() => _wheelScrollModeActive = active);
  }

  void _onWheelTap() {
    _tapHaptic();
    _setWheelScrollMode(!_wheelScrollModeActive);
  }

  void _startWheelPointer(PointerDownEvent event) {
    _wheelPointer = event.pointer;
    _wheelPointerLastPosition = event.localPosition;
    _wheelPointerDistance = 0.0;
  }

  void _moveWheelPointer(PointerMoveEvent event) {
    if (event.pointer != _wheelPointer) {
      return;
    }
    final previous = _wheelPointerLastPosition ?? event.localPosition;
    _wheelPointerLastPosition = event.localPosition;
    final delta = event.localPosition - previous;
    if (delta == Offset.zero) {
      return;
    }
    _wheelPointerDistance += delta.distance;
    if (!_wheelScrollModeActive) {
      return;
    }
    _sendTrackpadScroll(delta);
  }

  void _endWheelPointer(PointerEvent event) {
    if (event.pointer != _wheelPointer) {
      return;
    }
    final isTap = _wheelPointerDistance < _tapSlop;
    _wheelPointer = null;
    _wheelPointerLastPosition = null;
    _wheelPointerDistance = 0.0;
    if (isTap) {
      _onWheelTap();
    }
  }

  void _cancelWheelPointer(PointerEvent event) {
    if (event.pointer != _wheelPointer) {
      return;
    }
    _wheelPointer = null;
    _wheelPointerLastPosition = null;
    _wheelPointerDistance = 0.0;
  }

  @override
  void dispose() {
    _cancelLongPressTimer();
    _releaseLongPressDrag();
    super.dispose();
  }

  Widget _trackpadCenterIcon() {
    final touchIcon = Icon(
      Icons.touch_app,
      color: _wheelScrollModeActive ? MyTheme.accent : Colors.white70,
      size: 36,
    );
    if (!_wheelScrollModeActive) {
      return Center(child: touchIcon);
    }
    const arrowSize = 22.0;
    final arrowColor = MyTheme.accent;
    return Center(
      child: SizedBox(
        width: 76,
        height: 76,
        child: Stack(
          alignment: Alignment.center,
          children: [
            touchIcon,
            Positioned(
              top: 0,
              child: Icon(
                Icons.keyboard_arrow_up,
                color: arrowColor,
                size: arrowSize,
              ),
            ),
            Positioned(
              bottom: 0,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: arrowColor,
                size: arrowSize,
              ),
            ),
            Positioned(
              left: 0,
              child: Icon(
                Icons.keyboard_arrow_left,
                color: arrowColor,
                size: arrowSize,
              ),
            ),
            Positioned(
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_right,
                color: arrowColor,
                size: arrowSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buttonArea({
    required Widget child,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    final button = InkWell(
      onTap: onTap,
      child: Center(child: child),
    );
    return Expanded(
      child:
          tooltip == null ? button : Tooltip(message: tooltip, child: button),
    );
  }

  Widget _wheelArea() {
    return Expanded(
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _startWheelPointer,
        onPointerMove: _moveWheelPointer,
        onPointerUp: _endWheelPointer,
        onPointerCancel: _cancelWheelPointer,
        child: Tooltip(
          message: translate('Mouse Wheel'),
          child: Center(
            child: Icon(
              Icons.unfold_more,
              color: _wheelScrollModeActive ? MyTheme.accent : Colors.white70,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF151719),
        border: Border(
          right: BorderSide(color: Color(0xFF2F3337)),
          bottom: BorderSide(color: Color(0xFF2F3337)),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _startPointer,
              onPointerMove: _movePointer,
              onPointerUp: _endPointer,
              onPointerCancel: _endPointer,
              child: _trackpadCenterIcon(),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF2F3337)),
          Expanded(
            child: Material(
              color: const Color(0xFF1B1D1F),
              child: Row(
                children: [
                  _buttonArea(
                    tooltip: translate('Left Mouse'),
                    onTap: () =>
                        unawaited(widget.ffi.inputModel.tap(MouseButtons.left)),
                    child: const Text(
                      'L',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1, color: Color(0xFF2F3337)),
                  _wheelArea(),
                  const VerticalDivider(width: 1, color: Color(0xFF2F3337)),
                  _buttonArea(
                    tooltip: translate('Right Mouse'),
                    onTap: () => unawaited(
                        widget.ffi.inputModel.tap(MouseButtons.right)),
                    child: const Text(
                      'R',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
