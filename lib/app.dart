import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/home_screen.dart';
import 'screens/parent_dashboard.dart';
import 'widgets/time_limit_gate.dart';

class CatWiseApp extends StatelessWidget {
  const CatWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Котик Учёный',
      debugShowCheckedModeBanner: false,
      theme: CatWiseTheme.theme,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _parentTaps = 0;
  DateTime? _firstTapTime;

  void _onLogoLongPress() {
    final now = DateTime.now();
    if (_firstTapTime == null || now.difference(_firstTapTime!) > const Duration(seconds: 3)) {
      _firstTapTime = now;
      _parentTaps = 1;
      return;
    }
    _parentTaps++;

    if (_parentTaps >= 5) {
      _parentTaps = 0;
      _firstTapTime = null;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ParentGate(
            child: ParentDashboard(),
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: CatWiseTheme.animSmooth,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _onLogoLongPress,
      child: const TimeLimitGate(
        child: HomeScreen(),
      ),
    );
  }
}
