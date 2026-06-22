import 'package:flutter/material.dart';
import '../core/theme.dart';

class PlushButton extends StatefulWidget {
  final VoidCallback? onTap;
  final double size;
  final Color color;
  final Widget child;
  final bool enabled;

  const PlushButton({
    super.key,
    this.onTap,
    this.size = 72,
    required this.color,
    required this.child,
    this.enabled = true,
  });

  @override
  State<PlushButton> createState() => _PlushButtonState();
}

class _PlushButtonState extends State<PlushButton> with SingleTickerProviderStateMixin {
  late final AnimationController _squish;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _squish = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _squish.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.onTap == null) return;
    setState(() => _pressed = true);
    _squish.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled || widget.onTap == null) return;
    _squish.reverse().then((_) {
      if (mounted) setState(() => _pressed = false);
    });
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _squish.reverse();
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _squish,
        builder: (context, _) {
          final scaleX = 1.0 + 0.08 * _squish.value;
          final scaleY = 1.0 - 0.06 * _squish.value;

          return Transform.scale(
            scaleX: scaleX,
            scaleY: scaleY,
            child: AnimatedContainer(
              duration: CatWiseTheme.animQuick,
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.enabled ? widget.color : widget.color.withOpacity(0.4),
                borderRadius: BorderRadius.circular(widget.size * 0.35),
                boxShadow: _pressed
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : CatWiseTheme.plushShadow,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
