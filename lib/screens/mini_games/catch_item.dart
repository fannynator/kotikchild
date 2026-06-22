import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class CatchItemGame extends StatefulWidget {
  const CatchItemGame({super.key});

  @override
  State<CatchItemGame> createState() => _CatchItemGameState();
}

class _CatchItemGameState extends State<CatchItemGame> {
  final _rng = Random();
  final List<_FlyingItem> _items = [];
  Timer? _spawnTimer;
  Timer? _gameTimer;
  Timer? _moveTimer;
  int _score = 0;
  int _misses = 0;
  int _secondsLeft = 30;
  String _target = 'А';
  bool _gameOver = false;
  bool _started = false;

  final _targets = ['А', 'Б', 'В', 'Г', 'Д', '1', '2', '3', '4', '5'];
  final _distractors = ['Ё', 'Ж', 'З', 'К', 'Л', '6', '7', '8', '9', '0'];

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _started = true;
      _target = _targets[_rng.nextInt(_targets.length)];
    });
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) => _spawnItem());
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _moveItems());
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _endGame();
      }
    });
  }

  void _spawnItem() {
    if (_gameOver) return;
    final isTarget = _rng.nextDouble() < 0.4;
    final label = isTarget ? _target : _distractors[_rng.nextInt(_distractors.length)];

    _items.add(_FlyingItem(
      label: label,
      x: _rng.nextDouble() * 300,
      y: -40.0,
      isTarget: isTarget,
    ));

    if (_items.length > 15) _items.removeAt(0);
    if (mounted) setState(() {});
  }

  void _moveItems() {
    for (final item in _items) {
      item.y += 1.5;
    }
    _items.removeWhere((i) => i.y > 600);
    if (mounted) setState(() {});
  }

  void _tapItem(_FlyingItem item) {
    if (_gameOver) return;
    if (item.isTarget) {
      setState(() {
        _score++;
        _items.remove(item);
        if (_score % 5 == 0) {
          _target = _targets[_rng.nextInt(_targets.length)];
        }
      });
    } else {
      setState(() {
        _misses++;
        _items.remove(item);
      });
    }
  }

  void _endGame() {
    _gameOver = true;
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    setState(() {});
  }

  void _restart() {
    _items.clear();
    _score = 0;
    _misses = 0;
    _secondsLeft = 30;
    _gameOver = false;
    _started = true;
    _target = _targets[_rng.nextInt(_targets.length)];
    setState(() {});
    _spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (_) => _spawnItem());
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _moveItems());
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _endGame();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: !_started
            ? _buildStartScreen()
            : Stack(
                children: [
                  Positioned.fill(child: _buildGameField()),
                  _buildHUD(),
                  if (_gameOver) _buildGameOver(),
                ],
              ),
      ),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🎯', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Поймай букву!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
          const SizedBox(height: 8),
          const Text('Котик называет букву — лови её!\nНе трогай другие буквы.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: CatWiseTheme.textSecondary)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _start,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: BoxDecoration(color: CatWiseTheme.warmHoney, borderRadius: BorderRadius.circular(24)),
              child: const Text('Играть!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameField() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _items.map((item) {
          return Positioned(
            left: item.x,
            top: item.y,
            child: GestureDetector(
              onTap: () => _tapItem(item),
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: item.isTarget ? CatWiseTheme.starGold : CatWiseTheme.softLavender.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: CatWiseTheme.plushShadow,
                ),
                child: Center(
                  child: Text(item.label, style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700,
                    color: item.isTarget ? Colors.white : CatWiseTheme.textPrimary,
                  )),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HudPill(icon: Icons.star_rounded, text: '$_score', color: CatWiseTheme.starGold),
              _HudPill(icon: Icons.timer_rounded, text: '$_secondsLeft', color: CatWiseTheme.textSecondary),
              _HudPill(icon: Icons.close_rounded, text: '$_misses', color: CatWiseTheme.errorPeach),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
            child: Text('Лови: $_target', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    final stars = (_score ~/ 3).clamp(0, 5);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: CatWiseTheme.cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(stars >= 3 ? '🎉' : '💪', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            const Text('Время вышло!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
            const SizedBox(height: 4),
            Text('Поймано: $_score', style: const TextStyle(fontSize: 16, color: CatWiseTheme.textSecondary)),
            const SizedBox(height: 4),
            Text('Ошибок: $_misses', style: const TextStyle(fontSize: 14, color: CatWiseTheme.textSecondary)),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) {
              return Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, color: CatWiseTheme.starGold, size: 28);
            })),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(color: CatWiseTheme.dustyRose, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.home_rounded, color: Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: _restart,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(color: CatWiseTheme.successGreen, borderRadius: BorderRadius.circular(20)),
                  child: const Text('Ещё раз', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class _HudPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _HudPill({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

class _FlyingItem {
  final String label;
  double x;
  double y;
  final bool isTarget;

  _FlyingItem({required this.label, required this.x, required this.y, required this.isTarget});
}
