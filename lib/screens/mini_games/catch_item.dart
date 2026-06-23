import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/cat_avatar.dart';

enum CatchMode { letters, numbers, animals }
enum CatchLevel { easy, medium, hard }

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
  CatchMode _mode = CatchMode.letters;
  CatchLevel _level = CatchLevel.easy;

  List<String> _targets = [];
  List<String> _distractors = [];

  int get _spawnMs => switch (_level) { CatchLevel.easy => 1000, CatchLevel.medium => 700, CatchLevel.hard => 500 };
  double get _speed => switch (_level) { CatchLevel.easy => 1.2, CatchLevel.medium => 1.8, CatchLevel.hard => 2.5 };
  int get _timer => switch (_level) { CatchLevel.easy => 45, CatchLevel.medium => 35, CatchLevel.hard => 25 };

  @override
  void dispose() {
    _spawnTimer?.cancel();
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    super.dispose();
  }

  void _initMode() {
    switch (_mode) {
      case CatchMode.letters:
        _targets = ['А', 'Б', 'В', 'Г', 'Д', 'Е', 'Ж', 'З', 'И', 'К'];
        _distractors = ['Л', 'М', 'Н', 'О', 'П', 'Р', 'С', 'Т', 'У', 'Ф'];
      case CatchMode.numbers:
        _targets = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'];
        _distractors = ['11', '12', '13', '14', '15', '16', '17', '18', '19', '20'];
      case CatchMode.animals:
        _targets = ['🐱', '🐶', '🐮', '🐵', '🦊', '🐰', '🐸', '🐻', '🐷', '🐼'];
        _distractors = ['🐔', '🐴', '🐭', '🐹', '🐨', '🐯', '🦁', '🐙', '🐠', '🐧'];
    }
  }

  void _start() {
    _initMode();
    setState(() {
      _started = true;
      _target = _targets[_rng.nextInt(_targets.length)];
      _secondsLeft = _timer;
    });
    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnMs), (_) => _spawnItem());
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
    final isTarget = _rng.nextDouble() < 0.35;
    final label = isTarget ? _target : _distractors[_rng.nextInt(_distractors.length)];

    _items.add(_FlyingItem(label: label, x: _rng.nextDouble() * 280 + 20, y: -50.0, isTarget: isTarget));
    if (_items.length > 20) _items.removeAt(0);
    if (mounted) setState(() {});
  }

  void _moveItems() {
    for (final item in _items) { item.y += _speed; }
    _items.removeWhere((i) => i.y > 650);
    if (mounted) setState(() {});
  }

  void _tapItem(_FlyingItem item) {
    if (_gameOver) return;
    if (item.isTarget) {
      setState(() { _score++; _items.remove(item);
        if (_score % 5 == 0) _target = _targets[_rng.nextInt(_targets.length)];
      });
    } else {
      setState(() { _misses++; _items.remove(item); });
    }
  }

  void _endGame() {
    _gameOver = true; _spawnTimer?.cancel(); _gameTimer?.cancel(); _moveTimer?.cancel();
    setState(() {});
  }

  void _restart() {
    _items.clear(); _score = 0; _misses = 0; _secondsLeft = _timer; _gameOver = false; _started = true;
    _target = _targets[_rng.nextInt(_targets.length)];
    setState(() {});
    _spawnTimer = Timer.periodic(Duration(milliseconds: _spawnMs), (_) => _spawnItem());
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _moveItems());
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsLeft > 0) { setState(() => _secondsLeft--); } else { _endGame(); }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: !_started ? _buildStartScreen() : Stack(children: [
          Positioned.fill(child: _buildGameField()),
          _buildHUD(),
          if (_gameOver) _buildGameOver(),
        ]),
      ),
    );
  }

  Widget _buildStartScreen() {
    final modeEmoji = switch (_mode) { CatchMode.letters => '🔤', CatchMode.numbers => '🔢', CatchMode.animals => '🐱' };
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CatAvatar(mood: CatMood.happy, size: 100),
              const SizedBox(height: 16),
              const Text('Поймай!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
              const SizedBox(height: 20),
              const Text('Режим', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textSecondary)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Chip(label: '🔤 Буквы', selected: _mode == CatchMode.letters, onTap: () => setState(() => _mode = CatchMode.letters)),
                const SizedBox(width: 8),
                _Chip(label: '🔢 Цифры', selected: _mode == CatchMode.numbers, onTap: () => setState(() => _mode = CatchMode.numbers)),
                const SizedBox(width: 8),
                _Chip(label: '🐱 Звери', selected: _mode == CatchMode.animals, onTap: () => setState(() => _mode = CatchMode.animals)),
              ]),
              const SizedBox(height: 20),
              const Text('Сложность', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textSecondary)),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _Chip(label: '⭐ Легко', selected: _level == CatchLevel.easy, onTap: () => setState(() => _level = CatchLevel.easy)),
                const SizedBox(width: 8),
                _Chip(label: '⭐⭐ Средне', selected: _level == CatchLevel.medium, onTap: () => setState(() => _level = CatchLevel.medium)),
                const SizedBox(width: 8),
                _Chip(label: '⭐⭐⭐ Трудно', selected: _level == CatchLevel.hard, onTap: () => setState(() => _level = CatchLevel.hard)),
              ]),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _start,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
                  decoration: BoxDecoration(color: CatWiseTheme.warmHoney, borderRadius: BorderRadius.circular(28), boxShadow: CatWiseTheme.softGlow),
                  child: Text('$modeEmoji Играть!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameField() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _items.map((item) {
          return Positioned(
            left: item.x, top: item.y,
            child: GestureDetector(
              onTap: () => _tapItem(item),
              child: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: item.isTarget ? CatWiseTheme.starGold : CatWiseTheme.softLavender.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: CatWiseTheme.plushShadow,
                ),
                child: Center(
                  child: Text(item.label, style: TextStyle(fontSize: item.label.length > 2 ? 14 : 22, fontWeight: FontWeight.w700,
                      color: item.isTarget ? Colors.white : CatWiseTheme.textPrimary)),
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
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _HudPill(icon: Icons.star_rounded, text: '$_score', color: CatWiseTheme.starGold),
          _HudPill(icon: Icons.timer_rounded, text: '$_secondsLeft', color: CatWiseTheme.textSecondary),
          _HudPill(icon: Icons.close_rounded, text: '$_misses', color: CatWiseTheme.errorPeach),
        ]),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(18), boxShadow: CatWiseTheme.plushShadow),
          child: Text('Лови: $_target', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildGameOver() {
    final stars = (_score ~/ 3).clamp(0, 5);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: CatWiseTheme.cardDecoration(),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(stars >= 3 ? '🎉' : '💪', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text('Поймано: $_score', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
          Text('Ошибок: $_misses  |  ${_level.name.toUpperCase()}', style: const TextStyle(fontSize: 14, color: CatWiseTheme.textSecondary)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) =>
              Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, color: CatWiseTheme.starGold, size: 30))),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _GameButton(icon: Icons.home_rounded, color: CatWiseTheme.dustyRose, onTap: () => Navigator.of(context).pop()),
            const SizedBox(width: 16),
            _GameButton(label: 'Ещё раз', color: CatWiseTheme.successGreen, onTap: _restart),
            const SizedBox(width: 16),
            _GameButton(label: 'Меню', color: CatWiseTheme.warmHoney, onTap: () => setState(() { _started = false; _gameOver = false; _items.clear(); })),
          ]),
        ]),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const _GameButton({this.label, this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: icon != null ? Icon(icon, color: Colors.white) : Text(label!, style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({required this.label, required this.selected, required this.onTap});

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

class _HudPill extends StatelessWidget {
  final IconData icon; final String text; final Color color;
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
  final String label; double x; double y; final bool isTarget;
  _FlyingItem({required this.label, required this.x, required this.y, required this.isTarget});
}
