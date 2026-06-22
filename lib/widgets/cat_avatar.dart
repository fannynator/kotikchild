import 'dart:math';
import 'package:flutter/material.dart';
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

class _CatAvatarState extends State<CatAvatar> with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final AnimationController _earWiggle;
  late final AnimationController _tailWag;
  late final AnimationController _hugController;

  double _earPhase = 0;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

    _earWiggle = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _tailWag = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);

    _hugController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _startBlinkCycle();

    if (widget.mood == CatMood.celebrating && widget.isHugging) {
      _hugController.forward();
    }

    final rng = Random();
    Future.delayed(Duration(milliseconds: 2000 + rng.nextInt(3000)), () {
      if (mounted) _earWiggle.forward(from: 0);
    });
  }

  void _startBlinkCycle() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _blinkController.forward(from: 0).then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          _blinkController.reverse();
        });
      });
      Future.delayed(Duration(seconds: 2 + Random().nextInt(4)), _startBlinkCycle);
    });
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
    _blinkController.dispose();
    _earWiggle.dispose();
    _tailWag.dispose();
    _hugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_blinkController, _earWiggle, _tailWag, _hugController]),
        builder: (context, _) {
          final scale = widget.isHugging ? 1.0 + 0.12 * _hugController.value : 1.0;

          return Transform.scale(
            scale: scale,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _CatPainter(
                mood: widget.mood,
                blinkProgress: _blinkController.value,
                earAngle: _earWiggle.value * 0.3,
                tailWag: _tailWag.value,
                isHugging: widget.isHugging,
                hugProgress: _hugController.value,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CatPainter extends CustomPainter {
  final CatMood mood;
  final double blinkProgress;
  final double earAngle;
  final double tailWag;
  final bool isHugging;
  final double hugProgress;

  _CatPainter({
    required this.mood,
    required this.blinkProgress,
    required this.earAngle,
    required this.tailWag,
    required this.isHugging,
    required this.hugProgress,
  });

  Color get _bodyColor {
    switch (mood) {
      case CatMood.celebrating:
        return const Color(0xFFFFE0B2);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color get _earInner {
    switch (mood) {
      case CatMood.happy:
      case CatMood.celebrating:
        return const Color(0xFFFFAB91);
      default:
        return const Color(0xFFFFCCBC);
    }
  }

  Color get _noseColor {
    switch (mood) {
      case CatMood.shrugging:
        return const Color(0xFFEF9A9A);
      default:
        return const Color(0xFFFF8A80);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.35;

    _drawBodyShadow(canvas, center, baseRadius);

    _drawTail(canvas, center, baseRadius);

    if (isHugging && hugProgress > 0) {
      _drawHugArms(canvas, center, baseRadius);
    } else {
      _drawPaws(canvas, center, baseRadius);
    }

    _drawBody(canvas, center, baseRadius);

    _drawHead(canvas, center, baseRadius);

    _drawEars(canvas, center, baseRadius);

    _drawFace(canvas, center, baseRadius);

    _drawCostume(canvas, center, baseRadius);
  }

  void _drawBodyShadow(Canvas canvas, Offset center, double r) {
    final shadowPaint = Paint()
      ..color = CatWiseTheme.textPrimary.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.6), width: r * 1.7, height: r * 1.1),
      shadowPaint,
    );
  }

  void _drawTail(Canvas canvas, Offset center, double r) {
    final tailPath = Path();
    final tailBase = Offset(center.dx + r * 0.55, center.dy + r * 0.5);
    final wagOffset = tailWag * r * 0.25;

    tailPath.moveTo(tailBase.dx, tailBase.dy);
    tailPath.cubicTo(
      tailBase.dx + r * 0.4,
      tailBase.dy + wagOffset - r * 0.3,
      tailBase.dx + r * 0.7 + wagOffset * 1.5,
      tailBase.dy - r * 0.4,
      tailBase.dx + r * 0.8 + wagOffset * 2,
      tailBase.dy - r * 0.7,
    );
    tailPath.cubicTo(
      tailBase.dx + r * 0.9 + wagOffset * 2,
      tailBase.dy - r * 0.5,
      tailBase.dx + r * 0.5,
      tailBase.dy + wagOffset - r * 0.1,
      tailBase.dx + r * 0.3,
      tailBase.dy + r * 0.15,
    );

    final tailGradient = RadialGradient(
      colors: [_bodyColor, _bodyColor.withOpacity(0.85)],
    ).createShader(Rect.fromCircle(center: tailBase, radius: r * 0.6));

    final tailPaint = Paint()
      ..shader = tailGradient
      ..style = PaintingStyle.fill;

    canvas.drawPath(tailPath, tailPaint);
  }

  void _drawBody(Canvas canvas, Offset center, double r) {
    final bodyGradient = RadialGradient(
      center: const Alignment(-0.1, -0.1),
      colors: [_bodyColor, _bodyColor.withOpacity(0.85)],
    ).createShader(Rect.fromCircle(center: Offset(center.dx, center.dy + r * 0.3), radius: r * 1.1));

    final bodyPaint = Paint()
      ..shader = bodyGradient
      ..style = PaintingStyle.fill;

    final bodyPath = Path()..addOval(Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.4), width: r * 1.6, height: r * 1.0));

    canvas.drawPath(bodyPath, bodyPaint);

    final whiskerTint = _bodyColor;
    for (var i = -1; i <= 1; i += 2) {
      final whiskerPath = Path()
        ..addOval(Rect.fromCenter(
          center: Offset(center.dx + i * r * 0.7, center.dy + r * 0.15),
          width: r * 0.5,
          height: r * 0.35,
        ));

      canvas.drawPath(whiskerPath, Paint()..color = whiskerTint.withOpacity(0.4));
    }
  }

  void _drawPaws(Canvas canvas, Offset center, double r) {
    final pawPaint = Paint()
      ..color = _bodyColor
      ..style = PaintingStyle.fill;

    for (var i = -1; i <= 1; i += 2) {
      final pawPath = Path()..addOval(Rect.fromCenter(center: Offset(center.dx + i * r * 0.55, center.dy + r * 0.75), width: r * 0.32, height: r * 0.25));
      canvas.drawPath(pawPath, pawPaint);

      for (var j = -1; j <= 1; j += 2) {
        canvas.drawCircle(
          Offset(center.dx + i * r * 0.55 + j * r * 0.06, center.dy + r * 0.68),
          r * 0.04,
          Paint()..color = const Color(0xFFFFE0B2),
        );
      }
    }
  }

  void _drawHugArms(Canvas canvas, Offset center, double r) {
    final armPaint = Paint()
      ..color = _bodyColor
      ..style = PaintingStyle.fill;

    for (var i = -1; i <= 1; i += 2) {
      final armExtend = hugProgress * r * 0.6;

      final armPath = Path()
        ..moveTo(center.dx + i * r * 0.45, center.dy + r * 0.15)
        ..cubicTo(
          center.dx + i * (r * 0.45 + armExtend * 0.5),
          center.dy + r * 0.1,
          center.dx + i * (r * 0.6 + armExtend),
          center.dy + r * 0.3,
          center.dx + i * (r * 0.7 + armExtend),
          center.dy + r * 0.2,
        )
        ..cubicTo(
          center.dx + i * (r * 0.7 + armExtend),
          center.dy + r * 0.05,
          center.dx + i * (r * 0.5 + armExtend * 0.4),
          center.dy - r * 0.05,
          center.dx + i * r * 0.42,
          center.dy + r * 0.05,
        )
        ..close();

      canvas.drawPath(armPath, armPaint);
    }
  }

  void _drawHead(Canvas canvas, Offset center, double r) {
    final headGradient = RadialGradient(
      center: const Alignment(-0.1, -0.15),
      colors: [_bodyColor, _bodyColor.withOpacity(0.9)],
    ).createShader(Rect.fromCircle(center: Offset(center.dx, center.dy - r * 0.35), radius: r * 0.65));

    final headPaint = Paint()
      ..shader = headGradient
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - r * 0.35), r * 0.55, headPaint);

    for (var i = -1; i <= 1; i += 2) {
      final cheekPath = Path()..addOval(Rect.fromCenter(center: Offset(center.dx + i * r * 0.35, center.dy - r * 0.2), width: r * 0.3, height: r * 0.22));

      canvas.drawPath(cheekPath, Paint()..color = const Color(0xFFFFE0B2).withOpacity(0.5));
    }
  }

  void _drawEars(Canvas canvas, Offset center, double r) {
    for (var i = -1; i <= 1; i += 2) {
      final earBaseX = center.dx + i * r * 0.3;
      final earBaseY = center.dy - r * 0.78;
      final earTipX = earBaseX + i * r * 0.15 + earAngle * (i == 1 ? -r * 0.15 : r * 0.15);
      final earTipY = earBaseY - r * 0.5;

      final outerPath = Path()
        ..moveTo(earBaseX - i * r * 0.08, earBaseY)
        ..quadraticBezierTo(earBaseX + i * r * 0.05, earBaseY - r * 0.25, earTipX, earTipY)
        ..quadraticBezierTo(earBaseX + i * r * 0.02, earBaseY - r * 0.1, earBaseX + i * r * 0.08, earBaseY)
        ..close();

      canvas.drawPath(
        outerPath,
        Paint()
          ..shader = RadialGradient(colors: [_bodyColor, _bodyColor.withOpacity(0.85)]).createShader(Rect.fromCircle(center: Offset(earBaseX, earTipY), radius: r * 0.5)),
      );

      final innerPath = Path()
        ..moveTo(earBaseX - i * r * 0.04, earBaseY + r * 0.02)
        ..quadraticBezierTo(earBaseX + i * r * 0.02, earBaseY - r * 0.15, earTipX + i * r * 0.02, earTipY + r * 0.08)
        ..quadraticBezierTo(earBaseX + i * r * 0.01, earBaseY - r * 0.04, earBaseX + i * r * 0.04, earBaseY + r * 0.02)
        ..close();

      canvas.drawPath(innerPath, Paint()..color = _earInner);
    }
  }

  void _drawFace(Canvas canvas, Offset center, double r) {
    final faceCenter = Offset(center.dx, center.dy - r * 0.35);

    final eyeY = faceCenter.dy - r * 0.05;

    for (var i = -1; i <= 1; i += 2) {
      final eyeX = faceCenter.dx + i * r * 0.18;

      final eyePaint = Paint()..color = CatWiseTheme.textPrimary;

      final eyeHeight = 1.0 - blinkProgress;
      final eyePath = Path()..addOval(Rect.fromCenter(center: Offset(eyeX, eyeY), width: r * 0.15, height: r * 0.17 * eyeHeight));

      canvas.drawPath(eyePath, eyePaint);

      if (blinkProgress < 0.6) {
        canvas.drawCircle(Offset(eyeX + i * r * 0.03, eyeY - r * 0.02), r * 0.04, Paint()..color = Colors.white);
      }
    }

    if (mood == CatMood.happy || mood == CatMood.celebrating) {
      _drawHappyMouth(canvas, faceCenter, r);
    } else if (mood == CatMood.shrugging) {
      _drawShrugMouth(canvas, faceCenter, r);
    } else if (mood == CatMood.thinking) {
      _drawThinkingMouth(canvas, faceCenter, r);
    } else {
      _drawNeutralMouth(canvas, faceCenter, r);
    }

    final noseY = faceCenter.dy + r * 0.1;
    final nosePath = Path()
      ..moveTo(faceCenter.dx, noseY - r * 0.04)
      ..lineTo(faceCenter.dx - r * 0.06, noseY + r * 0.02)
      ..lineTo(faceCenter.dx + r * 0.06, noseY + r * 0.02)
      ..close();

    canvas.drawPath(nosePath, Paint()..color = _noseColor);

    for (var i = -1; i <= 1; i += 2) {
      canvas.drawLine(
        Offset(faceCenter.dx + i * r * 0.25, faceCenter.dy + r * 0.08),
        Offset(faceCenter.dx + i * r * 0.55, faceCenter.dy + r * 0.02 + (i * r * 0.05)),
        Paint()
          ..color = CatWiseTheme.textSecondary.withOpacity(0.3)
          ..strokeWidth = 1.0,
      );

      canvas.drawLine(
        Offset(faceCenter.dx + i * r * 0.28, faceCenter.dy + r * 0.14),
        Offset(faceCenter.dx + i * r * 0.5, faceCenter.dy + r * 0.18),
        Paint()
          ..color = CatWiseTheme.textSecondary.withOpacity(0.25)
          ..strokeWidth = 1.0,
      );
    }
  }

  void _drawNeutralMouth(Canvas canvas, Offset center, double r) {
    final mouthPath = Path()
      ..moveTo(center.dx - r * 0.1, center.dy + r * 0.16)
      ..cubicTo(center.dx - r * 0.05, center.dy + r * 0.19, center.dx + r * 0.05, center.dy + r * 0.19, center.dx + r * 0.1, center.dy + r * 0.16);

    canvas.drawPath(mouthPath, Paint()..color = CatWiseTheme.textPrimary..style = PaintingStyle.stroke..strokeWidth = 2.0);
  }

  void _drawHappyMouth(Canvas canvas, Offset center, double r) {
    final mouthPath = Path()
      ..moveTo(center.dx - r * 0.12, center.dy + r * 0.15)
      ..quadraticBezierTo(center.dx, center.dy + r * 0.3, center.dx + r * 0.12, center.dy + r * 0.15);

    canvas.drawPath(mouthPath, Paint()..color = CatWiseTheme.textPrimary..style = PaintingStyle.stroke..strokeWidth = 2.0);
  }

  void _drawShrugMouth(Canvas canvas, Offset center, double r) {
    final mouthPath = Path()
      ..moveTo(center.dx - r * 0.1, center.dy + r * 0.2)
      ..quadraticBezierTo(center.dx, center.dy + r * 0.16, center.dx + r * 0.1, center.dy + r * 0.2);

    canvas.drawPath(mouthPath, Paint()..color = CatWiseTheme.textPrimary..style = PaintingStyle.stroke..strokeWidth = 2.0);
  }

  void _drawThinkingMouth(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.18), r * 0.05, Paint()..color = CatWiseTheme.textPrimary.withOpacity(0.5));
  }

  void _drawCostume(Canvas canvas, Offset center, double r) {
    final hatBase = Offset(center.dx, center.dy - r * 0.85);

    final hatPath = Path()
      ..moveTo(hatBase.dx - r * 0.32, hatBase.dy + r * 0.05)
      ..quadraticBezierTo(hatBase.dx, hatBase.dy - r * 0.05, hatBase.dx + r * 0.32, hatBase.dy + r * 0.05)
      ..lineTo(hatBase.dx + r * 0.22, hatBase.dy - r * 0.15)
      ..quadraticBezierTo(hatBase.dx, hatBase.dy - r * 0.35, hatBase.dx - r * 0.22, hatBase.dy - r * 0.15)
      ..close();

    final hatColor = mood == CatMood.celebrating ? CatWiseTheme.starGold : CatWiseTheme.warmHoney.withOpacity(0.6);
    canvas.drawPath(hatPath, Paint()..color = hatColor);
  }

  @override
  bool shouldRepaint(covariant _CatPainter oldDelegate) {
    return mood != oldDelegate.mood ||
        blinkProgress != oldDelegate.blinkProgress ||
        earAngle != oldDelegate.earAngle ||
        tailWag != oldDelegate.tailWag ||
        hugProgress != oldDelegate.hugProgress;
  }
}
