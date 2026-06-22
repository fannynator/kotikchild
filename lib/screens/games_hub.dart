import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/plush_button.dart';
import 'mini_games/catch_item.dart';
import 'mini_games/memory_game.dart';
import 'mini_games/coloring_game.dart';

class GamesHub extends StatelessWidget {
  const GamesHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GameCard(
                      emoji: '🎯',
                      title: 'Поймай букву',
                      subtitle: 'Лови правильные буквы и цифры!',
                      color: CatWiseTheme.softLavender,
                      onTap: () => _openGame(context, const CatchItemGame()),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      emoji: '🧠',
                      title: 'Парочки',
                      subtitle: 'Найди пару для каждой карточки!',
                      color: CatWiseTheme.skyBlue,
                      onTap: () => _openGame(context, const MemoryGame()),
                    ),
                    const SizedBox(height: 16),
                    _GameCard(
                      emoji: '🎨',
                      title: 'Раскраска',
                      subtitle: 'Рисуй и раскрашивай картинки!',
                      color: CatWiseTheme.dustyRose,
                      onTap: () => _openGame(context, const ColoringGame()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGame(BuildContext context, Widget game) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => game,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: CatWiseTheme.animSmooth,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                boxShadow: CatWiseTheme.plushShadow,
              ),
              child: const Icon(Icons.close_rounded, size: 24, color: CatWiseTheme.textSecondary),
            ),
          ),
          const Spacer(),
          const CatAvatar(mood: CatMood.happy, size: 60),
        ],
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(CatWiseTheme.plushRadius),
          boxShadow: CatWiseTheme.plushShadow,
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: CatWiseTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: CatWiseTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}
