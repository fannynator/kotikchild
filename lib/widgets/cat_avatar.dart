import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class CatAvatar extends StatefulWidget {
  final CatMood mood;
  final double size;
  final bool showEars;
  final bool isHugging;
  final String? costumeId;

  const CatAvatar({
    super.key,
    this.mood = CatMood.neutral,
    this.size = 200,
    this.showEars = true,
    this.isHugging = false,
    this.costumeId,
  });

  @override
  State<CatAvatar> createState() => _CatAvatarState();
}

class _CatAvatarState extends State<CatAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _hugController;
  String _lastSmName = '';

  @override
  void initState() {
    super.initState();
    _hugController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: widget.isHugging ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(CatAvatar old) {
    super.didUpdateWidget(old);
    if (widget.isHugging && !old.isHugging) {
      _hugController.forward();
    } else if (!widget.isHugging && old.isHugging) {
      _hugController.reverse();
    }
  }

  @override
  void dispose() {
    _hugController.dispose();
    super.dispose();
  }

  String _stateMachineFor(CatMood mood) {
    switch (mood) {
      case CatMood.neutral:
        return 'idle';
      case CatMood.curious:
        return 'listening';
      case CatMood.thinking:
        return 'thinking';
      case CatMood.happy:
        return 'happy';
      case CatMood.celebrating:
        return 'celebrating';
      case CatMood.shrugging:
        return 'shrugging';
      case CatMood.encouraging:
        return 'encouraging';
    }
  }

  String _fallbackStateMachine(String preferred) {
    const fallbacks = ['idle', 'happy', 'idle', 'idle', 'happy', 'idle', 'happy'];
    const names = ['idle', 'listening', 'thinking', 'happy', 'celebrating', 'shrugging', 'encouraging'];
    final idx = names.indexOf(preferred);
    if (idx >= 0 && idx < fallbacks.length) {
      return fallbacks[idx];
    }
    return 'idle';
  }

  @override
  Widget build(BuildContext context) {
    final smName = _stateMachineFor(widget.mood);
    final effectiveSm = smName != _lastSmName ? smName : _lastSmName;
    _lastSmName = smName;

    final hugScale = 1.0 + 0.2 * _hugController.value;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _hugController,
        builder: (context, _) {
          return Stack(
            children: [
              Transform.scale(
                scale: hugScale,
                child: _RiveCat(
                  key: ValueKey('cat_${widget.mood.name}'),
                  stateMachineName: effectiveSm,
                  fallbackSm: _fallbackStateMachine(effectiveSm),
                ),
              ),
              if (widget.costumeId != null)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _HatPainter(
                    mood: widget.mood,
                    costumeId: widget.costumeId,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _RiveCat extends StatefulWidget {
  final String stateMachineName;
  final String fallbackSm;

  const _RiveCat({
    super.key,
    required this.stateMachineName,
    required this.fallbackSm,
  });

  @override
  State<_RiveCat> createState() => _RiveCatState();
}

class _RiveCatState extends State<_RiveCat> {
  @override
  Widget build(BuildContext context) {
    return RiveAnimation.asset(
      'assets/animations/bouncy_cat.riv',
      stateMachine: widget.stateMachineName,
      fit: BoxFit.contain,
      onInit: (artboard) {
        if (widget.stateMachineName != widget.fallbackSm) {
          final controller = StateMachineController.fromArtboard(
            artboard,
            widget.fallbackSm,
          );
          if (controller != null) {
            artboard.addController(controller);
          }
        }
      },
    );
  }
}

class _HatPainter extends CustomPainter {
  final CatMood mood;
  final String? costumeId;

  _HatPainter({required this.mood, this.costumeId});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width * 0.35;
    final hatBase = Offset(center.dx, center.dy - r * 0.85);

    final hatPath = Path()
      ..moveTo(hatBase.dx - r * 0.32, hatBase.dy + r * 0.05)
      ..quadraticBezierTo(hatBase.dx, hatBase.dy - r * 0.05, hatBase.dx + r * 0.32, hatBase.dy + r * 0.05)
      ..lineTo(hatBase.dx + r * 0.22, hatBase.dy - r * 0.15)
      ..quadraticBezierTo(hatBase.dx, hatBase.dy - r * 0.35, hatBase.dx - r * 0.22, hatBase.dy - r * 0.15)
      ..close();

    final hatColor = mood == CatMood.celebrating
        ? CatWiseTheme.starGold
        : CatWiseTheme.warmHoney.withOpacity(0.6);

    canvas.drawPath(hatPath, Paint()..color = hatColor);
  }

  @override
  bool shouldRepaint(covariant _HatPainter oldDelegate) {
    return mood != oldDelegate.mood || costumeId != oldDelegate.costumeId;
  }
}
