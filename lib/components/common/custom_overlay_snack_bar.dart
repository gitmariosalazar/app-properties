// lib/components/common/custom_overlay_snack_bar.dart
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

/// Static helper to show themed overlay toast notifications.
/// Colors derived from premium curated dark palettes — adapts to light/dark.
class CustomOverlaySnackBar {
  static final List<_SnackBarEntry> _entries = [];

  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
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
      entry.targetTop = paddingTop + 12 + (i * 86); // 86px staggered spacing to prevent overlap
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
    _currentTop = widget.targetTop - 80;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.6),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

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

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.type) {
      SnackBarType.success => Icons.check_circle_outline_rounded,
      SnackBarType.error => Icons.error_outline_rounded,
      SnackBarType.warning => Icons.warning_amber_rounded,
      SnackBarType.info => Icons.info_outline_rounded,
    };

    // Premium custom dark background and accent colors for high aesthetics
    final (bgColor, accentColor) = switch (widget.type) {
      SnackBarType.success => (const Color(0xFF132A1C), const Color(0xFF2ECC71)),
      SnackBarType.error => (const Color(0xFF2C1919), const Color(0xFFE74C3C)),
      SnackBarType.warning => (const Color(0xFF2C2216), const Color(0xFFF39C12)),
      SnackBarType.info => (const Color(0xFF142433), const Color(0xFF3498DB)),
    };

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
                child: Container(
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.96),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                bottomLeft: Radius.circular(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Icon(icon, color: accentColor, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14.0),
                              child: Text(
                                widget.message,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.0,
                                  height: 1.25,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white60,
                              size: 18,
                            ),
                            onPressed: _dismiss,
                            splashRadius: 20,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                        ],
                      ),
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
