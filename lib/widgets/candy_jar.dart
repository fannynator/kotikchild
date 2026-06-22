import 'package:flutter/material.dart';
import '../core/theme.dart';

class CandyJar extends StatefulWidget {
  final int count;

  const CandyJar({super.key, this.count = 0});

  @override
  State<CandyJar> createState() => _CandyJarState();
}

class _CandyJarState extends State<CandyJar> with SingleTickerProviderStateMixin {
  late final AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _bounce.forward(from: 0);
      },
      child: AnimatedBuilder(
        animation: _bounce,
        builder: (context, _) {
          return Transform.scale(
            scale: 1.0 + 0.15 * _bounce.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: CatWiseTheme.plushShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.favorite_rounded,
                    color: CatWiseTheme.candyPink,
                    size: 28,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.count}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: CatWiseTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
