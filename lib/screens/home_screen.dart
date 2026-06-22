import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/tts_service.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/star_counter.dart';
import '../widgets/candy_jar.dart';
import '../widgets/plush_button.dart';
import 'task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _catBreathe;
  bool _hasGreeted = false;

  @override
  void initState() {
    super.initState();
    _catBreathe = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasGreeted) {
      _hasGreeted = true;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          context.read<TtsService>().speak('Привет! Выбирай, во что будем играть!');
        }
      });
    }
  }

  @override
  void dispose() {
    _catBreathe.dispose();
    super.dispose();
  }

  void _onBlockTap(TaskBlock block) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => TaskScreen(block: block),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: CatWiseTheme.animSmooth,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildTopBar(),
            const SizedBox(height: 8),
            Expanded(child: _buildCatSection()),
            const SizedBox(height: 8),
            _buildBlockButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: CatWiseTheme.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          StarCounter(),
          CandyJar(),
        ],
      ),
    );
  }

  Widget _buildCatSection() {
    return AnimatedBuilder(
      animation: _catBreathe,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_catBreathe.value * 0.03),
          child: const CatAvatar(
            mood: CatMood.neutral,
            size: 220,
            showEars: true,
          ),
        );
      },
    );
  }

  Widget _buildBlockButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _BlockButton(
            icon: Icons.auto_stories,
            color: CatWiseTheme.softLavender,
            onTap: () => _onBlockTap(TaskBlock.letters),
            label: 'Буквы',
          ),
          _BlockButton(
            icon: Icons.calculate_rounded,
            color: CatWiseTheme.mintGreen,
            onTap: () => _onBlockTap(TaskBlock.math),
            label: 'Цифры',
          ),
          _BlockButton(
            icon: Icons.public_rounded,
            color: CatWiseTheme.skyBlue,
            onTap: () => _onBlockTap(TaskBlock.world),
            label: 'Мир',
          ),
        ],
      ),
    );
  }
}

class _BlockButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String label;

  const _BlockButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return PlushButton(
      onTap: onTap,
      size: 90,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: CatWiseTheme.textPrimary),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
