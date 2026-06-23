import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../data/task_repository.dart';
import '../models/task.dart';
import '../models/pet.dart';
import '../services/voice_service.dart';
import '../services/tts_service.dart';
import '../services/ai_service.dart';
import '../services/subscription_service.dart';
import '../services/sound_service.dart';
import '../widgets/cat_avatar.dart';
import '../widgets/star_counter.dart';
import 'reward_screen.dart';

class TaskScreen extends StatefulWidget {
  final TaskBlock block;

  const TaskScreen({super.key, required this.block});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late final AnimationController _micPulse;
  late final AnimationController _confettiController;
  late final AnimationController _shakeController;

  VoiceService get _voice => context.read<VoiceService>();
  TtsService get _tts => context.read<TtsService>();

  CatMood _catMood = CatMood.curious;
  bool _isListening = false;
  bool _isProcessing = false;
  int _wrongInRow = 0;
  double _starsEarned = 0.0;
  bool _taskDone = false;
  Task? _currentTask;

  final List<Task> _sessionTasks = [];
  int _taskIndex = 0;

  @override
  void initState() {
    super.initState();
    _micPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _confettiController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

    _loadTasks();
    SchedulerBinding.instance.addPostFrameCallback((_) => _startTask());
  }

  Future<void> _loadTasks() async {
    final subActive = context.read<SubscriptionService>().hasSubscription;
    int? difficulty;

    if (subActive) {
      final blockName = widget.block.name;
      final stats = <String, int>{'total': 10, 'errors': 0};
      difficulty = await AIService.adaptDifficulty(blockName, stats);
    }

    _sessionTasks.addAll(TaskRepository.session(widget.block, difficulty: difficulty));
    if (_sessionTasks.isNotEmpty) {
      _currentTask = _sessionTasks.first;
    }
    if (mounted) setState(() {});
  }

  Future<void> _startTask() async {
    if (_currentTask == null) return;
    setState(() {
      _catMood = CatMood.thinking;
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    await _tts.speak(_currentTask!.prompt);
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      setState(() {
        _catMood = CatMood.curious;
        _isProcessing = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (_isListening || _isProcessing || _taskDone) return;

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
      _isProcessing = true;
      _catMood = CatMood.thinking;
    });

    if (result == null || result.transcript.isEmpty) {
      setState(() {
        _isProcessing = false;
        _catMood = CatMood.curious;
      });
      return;
    }

    await _processAnswer(result.transcript);
  }

  Future<void> _processAnswer(String answer) async {
    final task = _currentTask;
    if (task == null) return;

    final isCorrect = task.checkAnswer(answer);

    if (isCorrect) {
      await _handleCorrect();
    } else {
      await _handleWrong(task, answer);
    }

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleCorrect() async {
    _wrongInRow = 0;
    _starsEarned += 1;
    _taskDone = true;

    SoundService.correct();
    setState(() => _catMood = CatMood.celebrating);

    await _tts.speakPraise();
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      _confettiController.forward(from: 0);

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => RewardScreen(
            starsEarned: _starsEarned,
            onContinue: _nextTask,
            onExit: () => Navigator.of(context).pop(),
          ),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: CatWiseTheme.animSmooth,
          fullscreenDialog: true,
        ),
      );
    }
  }

  Future<void> _handleWrong(Task task, String answer) async {
    _wrongInRow++;
    SoundService.wrong();

    if (_wrongInRow >= AppConstants.maxWrongBeforeHint) {
      setState(() => _catMood = CatMood.encouraging);
      await _tts.speakHint();
      await Future.delayed(const Duration(milliseconds: 300));

      final subActive = context.read<SubscriptionService>().hasSubscription;
      if (subActive) {
        final explanation = await AIService.explainMistake(task, answer);
        await _tts.speak(explanation);
      } else {
        await _tts.speak(task.hint ?? 'Давай я помогу!');
      }
      _starsEarned += 0.5;
      _wrongInRow = 0;
    } else {
      setState(() => _catMood = CatMood.shrugging);
      await _shakeController.forward(from: 0);
      await _tts.speakEncourage();
      setState(() => _catMood = CatMood.encouraging);
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _catMood = CatMood.curious);
    }
  }

  void _nextTask() {
    _taskIndex++;
    if (_taskIndex < _sessionTasks.length) {
      setState(() {
        _currentTask = _sessionTasks[_taskIndex];
        _taskDone = false;
        _wrongInRow = 0;
        _catMood = CatMood.curious;
      });
      _startTask();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _micPulse.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

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
                const SizedBox(height: 16),
                Expanded(child: _buildCatArea()),
                const SizedBox(height: 8),
                _buildVisualCard(),
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
          StarCounter(count: _starsEarned),
        ],
      ),
    );
  }

  Widget _buildCatArea() {
    final mood = _catMood;

    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = _shakeController.isAnimating
            ? 8.0 * (1 - _shakeController.value) * (_shakeController.value < 0.5 ? _shakeController.value * 2 : (1 - _shakeController.value) * 2)
            : 0.0;

        return Transform.translate(
          offset: Offset(
            shake * (_shakeController.value < 0.25
                ? 1
                : _shakeController.value < 0.5
                    ? -1
                    : _shakeController.value < 0.75
                        ? 1
                        : -1),
            0,
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.circular(CatWiseTheme.plushRadius),
              boxShadow: CatWiseTheme.plushShadow,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CatAvatar(
                  mood: mood,
                  size: 240,
                  showEars: true,
                  isHugging: mood == CatMood.celebrating,
                ),
                const SizedBox(height: 16),
                _buildSpeechBubble(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeechBubble() {
    if (_isListening) {
      return _ListeningIndicator();
    }
    if (_isProcessing) {
      return _ThinkingDots();
    }
    return const SizedBox(height: 40);
  }

  Widget _buildVisualCard() {
    if (_currentTask == null) return const SizedBox.shrink();

    final emoji = TaskRepository.emojiFor(_currentTask!);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: CatWiseTheme.animSmooth,
      builder: (context, value, _) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(CatWiseTheme.plushRadius),
              boxShadow: CatWiseTheme.plushShadow,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onLongPressStart: (_) {
        HapticFeedback.mediumImpact();
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
