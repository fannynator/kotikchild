import 'package:flutter/material.dart';
import '../core/theme.dart';

class StarCounter extends StatelessWidget {
  final double count;

  const StarCounter({super.key, this.count = 0.0});

  @override
  Widget build(BuildContext context) {
    final hasHalf = count % 1 >= 0.5;
    final displayText = hasHalf ? '${count.floor()}½' : '${count.floor()}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        boxShadow: CatWiseTheme.plushShadow,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasHalf ? Icons.star_half_rounded : Icons.star_rounded,
            color: CatWiseTheme.starGold,
            size: 28,
          ),
          const SizedBox(width: 6),
          Text(
            displayText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CatWiseTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
