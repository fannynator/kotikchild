import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../services/ai_service.dart';
import '../services/voice_service.dart';
import '../services/tts_service.dart';
import '../services/sound_service.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/plush_button.dart';

enum ChatMode { dialog, story, riddle }

class ChatScreen extends StatefulWidget {
  final ChatMode mode;

  const ChatScreen({super.key, this.mode = ChatMode.dialog});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final AnimationController _micPulse;
  VoiceService get _voice => context.read<VoiceService>();
  TtsService get _tts => context.read<TtsService>();

  bool _isListening = false;
  bool _isThinking = false;
  CatMood _catMood = CatMood.curious;

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _greet();
    });
  }

  @override
  void dispose() {
    _micPulse.dispose();
    super.dispose();
  }

  Future<void> _greet() async {
    final greeting = switch (widget.mode) {
      ChatMode.dialog => 'Давай поболтаем! Спрашивай меня о чём хочешь!',
      ChatMode.story => 'Давай придумаем сказку! Назови героя или тему!',
      ChatMode.riddle => 'Я загадаю тебе загадку! На какую тему?',
    };
    await _tts.speak(greeting);
    if (mounted) setState(() => _catMood = CatMood.curious);
  }

  Future<void> _startListening() async {
    if (_isListening || _isThinking) return;
    SoundService.tap();
    HapticFeedback.mediumImpact();

    setState(() {
      _isListening = true;
      _micPulse.repeat(reverse: true);
      _catMood = CatMood.thinking;
    });

    final result = await _voice.listen(silenceTimeout: const Duration(seconds: 2));

    _micPulse.stop();
    _micPulse.reset();

    if (!mounted) return;

    setState(() {
      _isListening = false;
      _isThinking = true;
      _catMood = CatMood.thinking;
    });

    if (result == null || result.transcript.isEmpty) {
      setState(() {
        _isThinking = false;
        _catMood = CatMood.curious;
      });
      return;
    }

    final modeStr = switch (widget.mode) {
      ChatMode.story => 'story',
      ChatMode.riddle => 'riddle',
      _ => 'chat',
    };

    final response = await AIService.chat(result.transcript, mode: modeStr);
    await _tts.speak(response);

    if (mounted) {
      setState(() {
        _isThinking = false;
        _catMood = CatMood.happy;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _catMood = CatMood.curious);
      });
    }
  }

  String get _modeLabel => switch (widget.mode) {
        ChatMode.dialog => 'Диалог',
        ChatMode.story => 'Сказка',
        ChatMode.riddle => 'Загадки',
      };

  IconData get _modeIcon => switch (widget.mode) {
        ChatMode.dialog => Icons.chat_bubble_rounded,
        ChatMode.story => Icons.auto_stories,
        ChatMode.riddle => Icons.help_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildCatArea()),
                const SizedBox(height: 16),
                _buildModeSelector(),
                const SizedBox(height: 12),
                _buildMicButton(),
                const SizedBox(height: 32),
              ],
            ),
            if (_isListening) _buildListeningOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _PlushIconButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              boxShadow: CatWiseTheme.plushShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_modeIcon, color: CatWiseTheme.warmHoney, size: 22),
                const SizedBox(width: 6),
                Text(
                  _modeLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: CatWiseTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(CatWiseTheme.plushRadius),
            boxShadow: CatWiseTheme.plushShadow,
          ),
          child: CatAvatar(
            mood: _catMood,
            size: 220,
            isHugging: _catMood == CatMood.happy,
          ),
        ),
        const SizedBox(height: 16),
        _buildSpeechBubble(),
      ],
    );
  }

  Widget _buildSpeechBubble() {
    if (_isListening) {
      return _ListeningIndicator();
    }
    if (_isThinking) {
      return _ThinkingDots();
    }
    return const SizedBox(height: 40);
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ModeButton(
            icon: Icons.chat_bubble_rounded,
            label: 'Диалог',
            active: widget.mode == ChatMode.dialog,
            onTap: () => _switchMode(ChatMode.dialog),
          ),
          _ModeButton(
            icon: Icons.auto_stories,
            label: 'Сказка',
            active: widget.mode == ChatMode.story,
            onTap: () => _switchMode(ChatMode.story),
          ),
          _ModeButton(
            icon: Icons.help_outline_rounded,
            label: 'Загадки',
            active: widget.mode == ChatMode.riddle,
            onTap: () => _switchMode(ChatMode.riddle),
          ),
        ],
      ),
    );
  }

  void _switchMode(ChatMode newMode) {
    if (newMode == widget.mode) return;
    SoundService.tap();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ChatScreen(mode: newMode),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: CatWiseTheme.animSmooth,
      ),
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onLongPressStart: (_) {
        _startListening();
      },
      onLongPressEnd: (_) {
        _voice.stop();
      },
      child: AnimatedBuilder(
        animation: _micPulse,
        builder: (context, child) {
          final pulse = _micPulse.isAnimating ? 1.0 + (_micPulse.value * 0.25) : 1.0;

          return Transform.scale(
            scale: pulse,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening ? CatWiseTheme.errorPeach : CatWiseTheme.pastelPeach,
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? CatWiseTheme.errorPeach : CatWiseTheme.warmHoney).withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                Icons.mic_rounded,
                size: 48,
                color: _isListening ? Colors.white : CatWiseTheme.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListeningOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _micPulse,
          builder: (context, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    CatWiseTheme.warmHoney.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  radius: _micPulse.value * 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PlushIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PlushIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: CatWiseTheme.plushShadow,
        ),
        child: Icon(icon, size: 24, color: CatWiseTheme.textSecondary),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? CatWiseTheme.warmHoney.withOpacity(0.4) : Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active ? CatWiseTheme.softGlow : CatWiseTheme.plushShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: CatWiseTheme.textPrimary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: CatWiseTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ListeningIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: CatWiseTheme.cardDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, _) {
              return Container(
                width: 6,
                height: 20 * value,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: CatWiseTheme.warmHoney,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: CatWiseTheme.cardDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final delay = i * 0.2;
              final value = ((_controller.value + delay) % 1.0);
              final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
              return Opacity(
                opacity: opacity,
                child: Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: CatWiseTheme.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
