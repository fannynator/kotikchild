import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/cat_avatar.dart';

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
  int _pairCount = 6;
  bool _started = false;

  final _allPairs = ['🐱', '🐶', '🐮', '🐵', '🦊', '🐰', '🐸', '🐻', '🐷', '🐼', '🦄', '🐙'];
  final _letters = ['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ж', 'З', 'И', 'К', 'Л', 'М'];
  final _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];
  final _shapes = ['●', '▲', '■', '♦', '★', '♥', '⬟', '⬢', '◼', '◆', '⬠', '⬡'];

  String _mode = 'animals';
  int _totalPairs = 0;

  void _start(int pairs, String mode) {
    _pairCount = pairs;
    _mode = mode;
    _shuffleCards();
    setState(() => _started = true);
  }

  void _shuffleCards() {
    final pool = switch (_mode) {
      'animals' => _allPairs,
      'letters' => _letters,
      'numbers' => _numbers,
      'shapes' => _shapes,
      _ => _allPairs,
    };
    final selected = (pool.toList()..shuffle()).take(_pairCount).toList();
    _cards = [...selected, ...selected].map((e) => _MemoryCard(label: e)).toList();
    _cards.shuffle();
    _score = 0;
    _attempts = 0;
    _totalPairs = _pairCount;
  }

  void _tapCard(int index) {
    if (_lock || _cards[index].matched || _cards[index].flipped) return;
    setState(() => _cards[index].flipped = true);

    final flipped = _cards.where((c) => c.flipped && !c.matched).toList();
    if (flipped.length == 2) {
      _attempts++;
      _lock = true;
      if (flipped[0].label == flipped[1].label) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;
          setState(() {
            flipped[0].matched = true; flipped[1].matched = true;
            _score++; _lock = false;
            if (_score == _totalPairs) _showWin();
          });
        });
      } else {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (!mounted) return;
          setState(() { flipped[0].flipped = false; flipped[1].flipped = false; _lock = false; });
        });
      }
    }
  }

  void _showWin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: CatWiseTheme.warmCream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('🎉 Все пары найдены!', textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Попыток: $_attempts', style: const TextStyle(fontSize: 16, color: CatWiseTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(_pairCount, (i) =>
              const Icon(Icons.star_rounded, color: CatWiseTheme.starGold, size: 24))),
        ]),
        actions: [
          TextButton(onPressed: () { Navigator.of(ctx).pop(); _shuffleCards(); setState(() {}); }, child: const Text('Ещё раз')),
          TextButton(onPressed: () { Navigator.of(ctx).pop(); Navigator.of(context).pop(); }, child: const Text('Выйти')),
        ],
      ),
    );
  }

  int _gridCols() {
    final total = _pairCount * 2;
    if (total <= 12) return 3;
    if (total <= 20) return 4;
    return 5;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: !_started ? _buildMenu() : _buildGame(),
      ),
    );
  }

  Widget _buildMenu() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CatAvatar(mood: CatMood.happy, size: 100),
          const SizedBox(height: 20),
          const Text('Парочки', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text('Найди пару для каждой карточки!', style: TextStyle(fontSize: 14, color: CatWiseTheme.textSecondary)),
          const SizedBox(height: 24),
          const Text('Что искать?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _MenuChip(label: '🐱 Звери', selected: _mode == 'animals', onTap: () => setState(() => _mode = 'animals')),
            _MenuChip(label: '🔤 Буквы', selected: _mode == 'letters', onTap: () => setState(() => _mode = 'letters')),
            _MenuChip(label: '🔢 Цифры', selected: _mode == 'numbers', onTap: () => setState(() => _mode = 'numbers')),
            _MenuChip(label: '🔷 Фигуры', selected: _mode == 'shapes', onTap: () => setState(() => _mode = 'shapes')),
          ]),
          const SizedBox(height: 24),
          const Text('Сколько пар?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textSecondary)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
            _MenuChip(label: '6 пар ⭐', selected: _pairCount == 6, onTap: () => setState(() => _pairCount = 6)),
            _MenuChip(label: '8 пар ⭐⭐', selected: _pairCount == 8, onTap: () => setState(() => _pairCount = 8)),
            _MenuChip(label: '10 пар ⭐⭐⭐', selected: _pairCount == 10, onTap: () => setState(() => _pairCount = 10)),
            _MenuChip(label: '12 пар 🏆', selected: _pairCount == 12, onTap: () => setState(() => _pairCount = 12)),
          ]),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => _start(_pairCount, _mode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
              decoration: BoxDecoration(color: CatWiseTheme.warmHoney, borderRadius: BorderRadius.circular(28), boxShadow: CatWiseTheme.softGlow),
              child: const Text('🧠 Играть!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGame() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          GestureDetector(
            onTap: () => setState(() => _started = false),
            child: Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.menu_rounded, size: 24, color: CatWiseTheme.textSecondary),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
            child: Row(children: [
              const Icon(Icons.star_rounded, color: CatWiseTheme.starGold, size: 18),
              const SizedBox(width: 4),
              Text('$_score/$_totalPairs', style: const TextStyle(fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
            ]),
          ),
        ]),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridCols(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: _cards.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) => _CardWidget(card: _cards[i], onTap: () => _tapCard(i)),
          ),
        ),
      ),
    ]);
  }
}

class _MenuChip extends StatelessWidget {
  final String label; final bool selected; final VoidCallback onTap;
  const _MenuChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? CatWiseTheme.warmHoney.withOpacity(0.4) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: selected ? Border.all(color: CatWiseTheme.warmHoney) : null,
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final _MemoryCard card; final VoidCallback onTap;
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
          borderRadius: BorderRadius.circular(16),
          boxShadow: CatWiseTheme.plushShadow,
        ),
        child: Center(
          child: card.flipped || card.matched
              ? FittedBox(fit: BoxFit.scaleDown, child: Text(card.label, style: const TextStyle(fontSize: 40)))
              : const Text('?', style: TextStyle(fontSize: 28, color: CatWiseTheme.textPrimary)),
        ),
      ),
    );
  }
}

class _MemoryCard {
  final String label; bool flipped = false; bool matched = false;
  _MemoryCard({required this.label});
}
