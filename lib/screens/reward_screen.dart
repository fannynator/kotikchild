import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/tts_service.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/plush_button.dart';

class RewardScreen extends StatefulWidget {
  final double starsEarned;
  final VoidCallback onContinue;
  final VoidCallback onExit;

  const RewardScreen({
    super.key,
    required this.starsEarned,
    required this.onContinue,
    required this.onExit,
  });

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> with TickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _hugController;
  late final AnimationController _starController;
  bool _showStars = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 4));

    _hugController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _starController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));

    Future.delayed(const Duration(milliseconds: 300), () {
      _confetti.play();
      _hugController.forward();
      _starController.forward();
      if (mounted) {
        setState(() => _showStars = true);
      }

      final tts = context.read<TtsService>();
      context.read<UserProgress>().addStars(widget.starsEarned, tts);
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    _hugController.dispose();
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: CatWiseTheme.watercolorBg(),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                _buildCatWithStars(),
                const Spacer(flex: 1),
                _buildStarRow(),
                const SizedBox(height: 32),
                _buildButtons(),
                const Spacer(),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              CatWiseTheme.starGold,
              CatWiseTheme.candyPink,
              CatWiseTheme.successGreen,
              CatWiseTheme.softLavender,
              CatWiseTheme.skyBlue,
            ],
            numberOfParticles: 30,
            maxBlastForce: 15,
            minBlastForce: 5,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCatWithStars() {
    return AnimatedBuilder(
      animation: _hugController,
      builder: (context, _) {
        final scale = 1.0 + (_hugController.value * 0.2);

        return Transform.scale(
          scale: scale,
          child: const CatAvatar(
            mood: CatMood.celebrating,
            size: 200,
            isHugging: true,
          ),
        );
      },
    );
  }

  Widget _buildStarRow() {
    final fullStars = widget.starsEarned.floor();
    final hasHalf = (widget.starsEarned - fullStars) >= 0.5;
    final totalItems = fullStars + (hasHalf ? 1 : 0);

    return AnimatedBuilder(
      animation: _starController,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalItems, (i) {
            final delay = 0.15 * i;
            final starProgress = ((_starController.value - delay) / 0.5).clamp(0.0, 1.0);
            final isHalf = hasHalf && i == totalItems - 1;

            return Transform.scale(
              scale: Curves.elasticOut.transform(starProgress),
              child: Opacity(
                opacity: starProgress.clamp(0.0, 1.0),
                child: Container(
                  width: 48,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: CatWiseTheme.starGold,
                    shape: BoxShape.circle,
                    boxShadow: CatWiseTheme.softGlow,
                  ),
                  child: Icon(
                    isHalf ? Icons.star_half_rounded : Icons.star_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PlushButton(
            onTap: widget.onExit,
            size: 72,
            color: CatWiseTheme.dustyRose,
            child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
          ),
          PlushButton(
            onTap: widget.onContinue,
            size: 96,
            color: CatWiseTheme.successGreen,
            child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }
}
