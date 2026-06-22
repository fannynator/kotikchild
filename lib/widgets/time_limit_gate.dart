import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../models/user.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/plush_button.dart';

class TimeLimitGate extends StatefulWidget {
  final Widget child;

  const TimeLimitGate({super.key, required this.child});

  @override
  State<TimeLimitGate> createState() => _TimeLimitGateState();
}

class _TimeLimitGateState extends State<TimeLimitGate> {
  Timer? _timer;
  bool _limitReached = false;

  @override
  void initState() {
    super.initState();
    _checkLimit();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        final progress = context.read<UserProgress>();
        progress.addPlayedMinute();
        _checkLimit();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkLimit() async {
    final progress = context.read<UserProgress>();
    final prefs = await SharedPreferences.getInstance();
    final limit = prefs.getInt('dailyTimeLimitMinutes') ?? 30;
    if (progress.isTimeLimitReached(limit)) {
      setState(() => _limitReached = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_limitReached) {
      return _LimitScreen(onDone: () {
        setState(() => _limitReached = false);
      });
    }
    return widget.child;
  }
}

class _LimitScreen extends StatelessWidget {
  final VoidCallback onDone;

  const _LimitScreen({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CatAvatar(mood: CatMood.neutral, size: 180),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: CatWiseTheme.cardDecoration(),
                child: Column(
                  children: [
                    const Icon(Icons.bedtime_rounded, size: 40, color: CatWiseTheme.softLavender),
                    const SizedBox(height: 12),
                    const Text(
                      'Пора отдыхать!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Котик устал и пошёл спать.\nПриходи завтра — будем играть снова!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: CatWiseTheme.textSecondary, height: 1.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PlushButton(
                size: 72,
                color: CatWiseTheme.dustyRose,
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
