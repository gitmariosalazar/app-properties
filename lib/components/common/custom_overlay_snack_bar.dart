// lib/components/common/custom_overlay_snack_bar.dart
import 'package:flutter/material.dart';
import 'package:app_properties/core/theme/app_colors.dart';

enum SnackBarType { success, error, warning, info }

class CustomOverlaySnackBar {
  // === CORREGIDO: List<_SnackBarEntry> ===
  static final List<_SnackBarEntry> _entries = [];

  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismissed,
  }) {
    final overlay = Overlay.of(context);
    final key = UniqueKey();
    final entry = _SnackBarEntry(
      key: key,
      message: message,
      type: type,
      duration: duration,
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

// === ENTRY CON KEY Y POSICIÓN ===
class _SnackBarEntry {
  final Key key;
  final String message;
  final SnackBarType type;
  final Duration duration;
  final VoidCallback onDismissed;
  double targetTop = 0;

  late final OverlayEntry overlayEntry = OverlayEntry(
    builder: (context) => _SnackBarWidget(
      key: key,
      message: message,
      type: type,
      duration: duration,
      targetTop: targetTop,
      onDismissed: onDismissed,
    ),
  );

  _SnackBarEntry({
    required this.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });
}

// === WIDGET CON ANIMACIÓN ===
class _SnackBarWidget extends StatefulWidget {
  final String message;
  final SnackBarType type;
  final Duration duration;
  final double targetTop;
  final VoidCallback onDismissed;

  const _SnackBarWidget({
    required super.key,
    required this.message,
    required this.type,
    required this.duration,
    required this.targetTop,
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

  @override
  Widget build(BuildContext context) {
    final icon = switch (widget.type) {
      SnackBarType.success => Icons.check_circle,
      SnackBarType.error => Icons.error,
      SnackBarType.warning => Icons.warning_amber,
      SnackBarType.info => Icons.info,
    };

    final color = switch (widget.type) {
      SnackBarType.success => AppColors.secondary,
      SnackBarType.error => AppColors.error,
      SnackBarType.warning => Colors.orange[700]!,
      SnackBarType.info => Theme.of(context).primaryColor,
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
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
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
