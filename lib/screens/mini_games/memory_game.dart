import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final _rng = Random();
  late List<_MemoryCard> _cards;
  int _score = 0;
  int _attempts = 0;
  bool _lock = false;

  final _pairs = ['🐱', '🐶', '🐮', '🐵', '🦊', '🐰', '🐸', '🐻'];

  @override
  void initState() {
    super.initState();
    _shuffleCards();
  }

  void _shuffleCards() {
    final selected = (_pairs.toList()..shuffle()).take(6).toList();
    _cards = [...selected, ...selected].map((e) => _MemoryCard(emoji: e)).toList();
    _cards.shuffle();
    _score = 0;
    _attempts = 0;
  }

  void _tapCard(int index) {
    if (_lock || _cards[index].matched || _cards[index].flipped) return;

    setState(() {
      _cards[index].flipped = true;
    });

    final flipped = _cards.where((c) => c.flipped && !c.matched).toList();
    if (flipped.length == 2) {
      _attempts++;
      _lock = true;
      if (flipped[0].emoji == flipped[1].emoji) {
        Future.delayed(const Duration(milliseconds: 400), () {
          setState(() {
            flipped[0].matched = true;
            flipped[1].matched = true;
            _score++;
            _lock = false;
            if (_score == 6) _showWin();
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 600), () {
          setState(() {
            flipped[0].flipped = false;
            flipped[1].flipped = false;
            _lock = false;
          });
        });
      }
    }
  }

  void _showWin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CatWiseTheme.warmCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('🎉 Все пары найдены!', textAlign: TextAlign.center),
        content: Text('Попыток: $_attempts', textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () { Navigator.of(ctx).pop(); _shuffleCards(); setState(() {}); }, child: const Text('Ещё раз')),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Выйти')),
        ],
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
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
                  itemCount: _cards.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) => _CardWidget(card: _cards[i], onTap: () => _tapCard(i)),
                ),
              ),
            ),
          ],
        ),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.star_rounded, color: CatWiseTheme.starGold, size: 18),
              const SizedBox(width: 4),
              Text('$_score/6', style: const TextStyle(fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final _MemoryCard card;
  final VoidCallback onTap;

  const _CardWidget({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.flipped || card.matched
              ? (card.matched ? CatWiseTheme.successGreen.withOpacity(0.3) : Colors.white.withOpacity(0.8))
              : CatWiseTheme.warmHoney.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: CatWiseTheme.plushShadow,
        ),
        child: Center(
          child: card.flipped || card.matched
              ? Text(card.emoji, style: const TextStyle(fontSize: 40))
              : const Text('?', style: TextStyle(fontSize: 32, color: CatWiseTheme.textPrimary)),
        ),
      ),
    );
  }
}

class _MemoryCard {
  final String emoji;
  bool flipped = false;
  bool matched = false;

  _MemoryCard({required this.emoji});
}
