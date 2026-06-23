import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ColoringGame extends StatefulWidget {
  const ColoringGame({super.key});

  @override
  State<ColoringGame> createState() => _ColoringGameState();
}

class _ColoringGameState extends State<ColoringGame> {
  Color _currentColor = CatWiseTheme.candyPink;
  double _brushSize = 8;
  String _stencil = '🐱';
  final List<String> _stencils = ['🐱', '⭐', '🌸', '🏠', '🚀', '🦋', '🌙', '🐶', '🎂', '❤️'];
  final List<_Stroke> _strokes = [];
  _Stroke? _currentStroke;

  final _colors = [
    CatWiseTheme.candyPink,
    CatWiseTheme.starGold,
    CatWiseTheme.successGreen,
    CatWiseTheme.skyBlue,
    CatWiseTheme.softLavender,
    CatWiseTheme.errorPeach,
    CatWiseTheme.warmHoney,
    CatWiseTheme.cocoa,
    CatWiseTheme.mintGreen,
    CatWiseTheme.dustyRose,
  ];

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
    }
  }

  void _clear() {
    setState(() => _strokes.clear());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: CatWiseTheme.plushShadow,
                  ),
                  child: Stack(
                    children: [
                      _buildCanvas(),
                      Center(child: Text(_stencil, style: const TextStyle(fontSize: 120))),
                    ],
                  ),
                ),
              ),
            ),
            _buildToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return GestureDetector(
      onPanStart: (details) {
        _currentStroke = _Stroke(color: _currentColor, size: _brushSize, points: [details.localPosition]);
        setState(() => _strokes.add(_currentStroke!));
      },
      onPanUpdate: (details) {
        _currentStroke?.points.add(details.localPosition);
        setState(() {});
      },
      child: CustomPaint(
        painter: _DrawingPainter(strokes: _strokes),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.close_rounded, size: 24, color: CatWiseTheme.textSecondary),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _undo,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.undo_rounded, size: 24, color: CatWiseTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _clear,
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.delete_outline_rounded, size: 24, color: CatWiseTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: CatWiseTheme.plushShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _stencils.map((s) {
                final selected = _stencil == s;
                return GestureDetector(
                  onTap: () => setState(() => _stencil = s),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? CatWiseTheme.warmHoney.withOpacity(0.3) : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: selected ? Border.all(color: CatWiseTheme.warmHoney) : null,
                    ),
                    child: Text(s, style: const TextStyle(fontSize: 24)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _colors.map((c) {
              final selected = _currentColor == c;
              return GestureDetector(
                onTap: () => setState(() => _currentColor = c),
                child: Container(
                  width: selected ? 36 : 28,
                  height: selected ? 36 : 28,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: CatWiseTheme.textPrimary, width: 2) : null,
                    boxShadow: selected ? CatWiseTheme.softGlow : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.brush_rounded, color: CatWiseTheme.textSecondary, size: 18),
            const SizedBox(width: 8),
            SizedBox(
              width: 200,
              child: Slider(
                value: _brushSize,
                min: 2,
                max: 20,
                activeColor: _currentColor,
                onChanged: (v) => setState(() => _brushSize = v),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

class _Stroke {
  final Color color;
  final double size;
  final List<Offset> points;

  _Stroke({required this.color, required this.size, required this.points});
}

class _DrawingPainter extends CustomPainter {
  final List<_Stroke> strokes;

  _DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.size
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.size / 2, paint);
      } else {
        final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (var i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
