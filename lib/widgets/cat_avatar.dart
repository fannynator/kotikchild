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
  StateMachineController? _riveController;

  SMIInput<SMITrigger>? _triggerBlink;
  SMIInput<SMITrigger>? _triggerJump;
  SMIInput<SMITrigger>? _triggerTailAnim;
  SMIInput<SMITrigger>? _triggerIdleTail;
  SMIInput<SMITrigger>? _triggerREarAnim;
  SMIInput<SMITrigger>? _triggerIdleREar;
  SMIInput<SMITrigger>? _triggerLEarAnim;
  SMIInput<SMITrigger>? _triggerIdleLEar;
  SMIInput<SMITrigger>? _triggerIdle;

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
    if (widget.mood != old.mood) {
      _applyMood(widget.mood);
    }
  }

  @override
  void dispose() {
    _hugController.dispose();
    _riveController?.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    final controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1',
    );
    if (controller != null) {
      artboard.addController(controller);
      _riveController = controller;
      _cacheInputs(controller);
      _applyMood(widget.mood);
    }
  }

  void _cacheInputs(StateMachineController controller) {
    _triggerBlink = controller.findInput<SMITrigger>('blink');
    _triggerJump = controller.findInput<SMITrigger>('jump');
    _triggerTailAnim = controller.findInput<SMITrigger>('tail_an');
    _triggerIdleTail = controller.findInput<SMITrigger>('idle_tail');
    _triggerREarAnim = controller.findInput<SMITrigger>('R_ear_an');
    _triggerIdleREar = controller.findInput<SMITrigger>('idle_R_ear');
    _triggerLEarAnim = controller.findInput<SMITrigger>('L_ear_an');
    _triggerIdleLEar = controller.findInput<SMITrigger>('edle_L_ear');
    _triggerIdle = controller.findInput<SMITrigger>('idle');
  }

  void _applyMood(CatMood mood) {
  if (_riveController == null) return;

  switch (mood) {
    case CatMood.neutral:
      _triggerIdle?.change(true);
      _triggerIdleTail?.change(true);
      break;
    case CatMood.curious:
      _triggerREarAnim?.change(true);
      _triggerLEarAnim?.change(true);
      break;
    case CatMood.thinking:
      _triggerBlink?.change(true);
      _triggerIdleTail?.change(true);
      break;
    case CatMood.happy:
      _triggerJump?.change(true);
      _triggerTailAnim?.change(true);
      break;
    case CatMood.celebrating:
      _triggerJump?.change(true);
      _triggerTailAnim?.change(true);
      break;
    case CatMood.shrugging:
      _triggerIdle?.change(true);
      break;
    case CatMood.encouraging:
      _triggerTailAnim?.change(true);
      _triggerIdleLEar?.change(true);
      _triggerIdleREar?.change(true);
      break;
  }
}

  @override
  Widget build(BuildContext context) {
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
                child: RiveAnimation.asset(
                  'assets/animations/bouncy_cat.riv',
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                  placeHolder: const Center(
                    child: CircularProgressIndicator(
                      color: CatWiseTheme.warmHoney,
                      strokeWidth: 2,
                    ),
                  ),
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
