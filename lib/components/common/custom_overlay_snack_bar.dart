// lib/components/common/custom_overlay_snack_bar.dart
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

/// Static helper to show themed overlay toast notifications.
/// Colors derived from [ColorScheme] tokens — adapts to light/dark.
class CustomOverlaySnackBar {
  static final List<_SnackBarEntry> _entries = [];

  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismissed,
  }) {
    final overlay = Overlay.of(context);
    final cs = Theme.of(context).colorScheme;
    final key = UniqueKey();
    final entry = _SnackBarEntry(
      key: key,
      message: message,
      type: type,
      duration: duration,
      colorScheme: cs,
      onDismissed: () {
        _removeEntry(key, overlay);
        onDismissed?.call();
      },
    );

    _entries.add(entry);
    _updatePositions(overlay);
    overlay.insert(entry.overlayEntry);
  }

  static void _removeEntry(Key key, OverlayState overlay) {
    final index = _entries.indexWhere((e) => e.key == key);
    if (index != -1) {
      _entries[index].overlayEntry.remove();
      _entries.removeAt(index);
      _updatePositions(overlay);
    }
  }

  static void _updatePositions(OverlayState overlay) {
    final paddingTop = MediaQuery.of(overlay.context).padding.top;
    for (int i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      entry.targetTop = paddingTop + (i * 50);
      entry.overlayEntry.markNeedsBuild();
    }
  }

  static void clearAll() {
    for (var entry in List.from(_entries)) {
      entry.overlayEntry.remove();
    }
    _entries.clear();
  }
}

class _SnackBarEntry {
  final Key key;
  final String message;
  final SnackBarType type;
  final Duration duration;
  final ColorScheme colorScheme;
  final VoidCallback onDismissed;
  double targetTop = 0;

  late final OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => _SnackBarWidget(
      key: key,
      message: message,
      type: type,
      duration: duration,
      colorScheme: colorScheme,
      targetTop: targetTop,
      onDismissed: onDismissed,
    ),
  );

  _SnackBarEntry({
    required this.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.colorScheme,
    required this.onDismissed,
  });
}

class _SnackBarWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final Duration duration;
  final double targetTop;
  final ColorScheme colorScheme;
  final VoidCallback onDismissed;

  const _SnackBarWidget({
    required super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.targetTop,
    required this.colorScheme,
    required this.onDismissed,
  });

  @override
  State<_SnackBarWidget> createState() => _SnackBarWidgetState();
}

class _SnackBarWidgetState extends State<_SnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _positionAnimation;
  double _currentTop = 0;

  @override
  void initState() {
    super.initState();
    _currentTop = widget.targetTop - 70;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _positionAnimation = Tween<double>(
      begin: _currentTop,
      end: widget.targetTop,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) _dismiss();
    });
  }

  @override
  void didUpdateWidget(_SnackBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTop != widget.targetTop) {
      _currentTop = oldWidget.targetTop;
      _positionAnimation = Tween<double>(
        begin: _currentTop,
        end: widget.targetTop,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward();
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _resolveColor() {
    final cs = widget.colorScheme;
    return switch (widget.type) {
      SnackBarType.success => cs.secondary,
      SnackBarType.error => cs.error,
      SnackBarType.warning => const Color(0xFFE65100),
      SnackBarType.info => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.type) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.error => Icons.error,
      SnackBarType.warning => Icons.warning_amber,
      SnackBarType.info => Icons.info,
    };

    final color = _resolveColor();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final top = _positionAnimation.value;
        return Positioned(
          top: top,
          left: 16,
          right: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _dismiss,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _dismiss,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
