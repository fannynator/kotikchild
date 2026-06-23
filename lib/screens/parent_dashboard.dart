import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/ai_service.dart';
import '../services/subscription_service.dart';

class ParentGate extends StatefulWidget {
  final Widget child;

  const ParentGate({super.key, required this.child});

  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  final _controller = TextEditingController();
  int _attemptsLeft = AppConstants.maxParentAttempts;
  bool _unlocked = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkAnswer() {
    final input = int.tryParse(_controller.text.trim());
    if (input == AppConstants.parentGateAnswer) {
      HapticFeedback.heavyImpact();
      setState(() => _unlocked = true);
    } else {
      setState(() {
        _attemptsLeft--;
        _errorText = _attemptsLeft > 0
            ? 'Неверно. Осталось попыток: $_attemptsLeft'
            : null;
      });
      if (_attemptsLeft <= 0) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_unlocked) return widget.child;

    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 64,
                color: CatWiseTheme.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.parentGateQuestion,
                style: CatWiseTheme.displayStyle.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: CatWiseTheme.displayStyle.copyWith(fontSize: 28),
                decoration: InputDecoration(
                  errorText: _errorText,
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                onSubmitted: (_) => _checkAnswer(),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CatWiseTheme.warmHoney,
                    foregroundColor: CatWiseTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _checkAnswer,
                  child: Text(
                    'Войти',
                    style: CatWiseTheme.bodyStyle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CatWiseTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Назад',
                  style: CatWiseTheme.parentStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  ParentSettings _settings = const ParentSettings();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: CatWiseTheme.watercolorBg(),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            TabBar(
              controller: _tabController,
              labelColor: CatWiseTheme.textPrimary,
              unselectedLabelColor: CatWiseTheme.textSecondary,
              indicatorColor: CatWiseTheme.warmHoney,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Прогресс'),
                Tab(text: 'Настройки'),
                Tab(text: 'Отчёты'),
                Tab(text: 'ИИ'),
                Tab(text: 'Подписка'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ProgressTab(progress: context.watch<UserProgress>()),
                  _SettingsTab(settings: _settings, onChanged: _updateSettings),
                  _ReportsTab(progress: context.watch<UserProgress>()),
                  const _AiTab(),
                  const _SubTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Text('Родительский кабинет', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: CatWiseTheme.textSecondary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _updateSettings(ParentSettings updated) {
    setState(() => _settings = updated);
  }
}

class _ProgressTab extends StatelessWidget {
  final UserProgress? progress;

  const _ProgressTab({required this.progress});

  @override
  Widget build(BuildContext context) {
    if (progress == null) {
      return const Center(
        child: Text('Нет данных', style: TextStyle(color: CatWiseTheme.textSecondary)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _StatsCard(
          title: 'Заданий пройдено',
          value: '${progress!.tasksCompleted}',
          icon: Icons.task_alt_rounded,
          color: CatWiseTheme.successGreen,
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Звёзд заработано',
          value: '${progress!.totalStars}',
          icon: Icons.star_rounded,
          color: CatWiseTheme.starGold,
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Конфет собрано',
          value: '${progress!.totalCandies}',
          icon: Icons.favorite_rounded,
          color: CatWiseTheme.candyPink,
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Серия дней',
          value: '${progress!.currentStreak}',
          icon: Icons.local_fire_department_rounded,
          color: CatWiseTheme.errorPeach,
        ),
        const SizedBox(height: 12),
        _StatsCard(
          title: 'Время в приложении',
          value: '${progress!.totalMinutesPlayed} мин',
          icon: Icons.timer_rounded,
          color: CatWiseTheme.cocoa,
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: CatWiseTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Прогресс по блокам', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
              const SizedBox(height: 12),
              _BlockProgressRow(label: 'Буквы', done: progress!.blockProgress['letters'] ?? 0, total: AppConstants.tasksPerBlock, color: CatWiseTheme.softLavender),
              const SizedBox(height: 8),
              _BlockProgressRow(label: 'Математика', done: progress!.blockProgress['math'] ?? 0, total: AppConstants.tasksPerBlock, color: CatWiseTheme.mintGreen),
              const SizedBox(height: 8),
              _BlockProgressRow(label: 'Окр. мир', done: progress!.blockProgress['world'] ?? 0, total: AppConstants.tasksPerBlock, color: CatWiseTheme.skyBlue),
            ],
          ),
        ),
      ],
    );
  }
}

class _BlockProgressRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final Color color;

  const _BlockProgressRow({
    required this.label,
    required this.done,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? done / total : 0.0;
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label, style: CatWiseTheme.parentStyle)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 16,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('$done/${total}', style: CatWiseTheme.parentStyle),
      ],
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: CatWiseTheme.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Text(title, style: CatWiseTheme.parentStyle),
          const Spacer(),
          Text(value, style: CatWiseTheme.parentStyle.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _SettingsTab extends StatefulWidget {
  final ParentSettings settings;
  final ValueChanged<ParentSettings> onChanged;

  const _SettingsTab({required this.settings, required this.onChanged});

  @override
  State<_SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<_SettingsTab> {
  late double _timeLimit;
  late bool _soundEnabled;
  late double _voiceSpeed;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _timeLimit = widget.settings.dailyTimeLimitMinutes.toDouble();
    _soundEnabled = widget.settings.soundEffectsEnabled;
    _voiceSpeed = widget.settings.voiceSpeed.toDouble();
    _nameController = TextEditingController(text: widget.settings.childName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('dailyTimeLimitMinutes', _timeLimit.round());
    prefs.setBool('soundEffectsEnabled', _soundEnabled);
    prefs.setInt('voiceSpeed', _voiceSpeed.round());
    prefs.setString('childName', _nameController.text);

    widget.onChanged(widget.settings.copyWith(
      dailyTimeLimitMinutes: _timeLimit.round(),
      soundEffectsEnabled: _soundEnabled,
      voiceSpeed: _voiceSpeed.round(),
      childName: _nameController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: CatWiseTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Имя ребёнка', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              Text('Лимит времени: ${_timeLimit.round()} мин', style: CatWiseTheme.parentStyle),
              Slider(
                value: _timeLimit,
                min: 10,
                max: 60,
                divisions: 5,
                activeColor: CatWiseTheme.warmHoney,
                onChanged: (v) => setState(() => _timeLimit = v),
                onChangeEnd: (_) => _save(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Звуки', style: CatWiseTheme.parentStyle),
                  Switch(
                    value: _soundEnabled,
                    activeColor: CatWiseTheme.warmHoney,
                    onChanged: (v) {
                      setState(() => _soundEnabled = v);
                      _save();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Скорость речи: ${_voiceSpeed.round()}', style: CatWiseTheme.parentStyle),
              Slider(
                value: _voiceSpeed,
                min: 1,
                max: 3,
                divisions: 2,
                activeColor: CatWiseTheme.warmHoney,
                onChanged: (v) => setState(() => _voiceSpeed = v),
                onChangeEnd: (_) => _save(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReportsTab extends StatefulWidget {
  final UserProgress? progress;

  const _ReportsTab({required this.progress});

  @override
  State<_ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<_ReportsTab> {
  final _repaintKey = GlobalKey();

  Future<void> _share() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/kotik_report.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles([XFile(file.path)], text: 'Успехи в Котике Учёном!');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (widget.progress == null) {
      return const Center(
        child: Text('Нет данных', style: TextStyle(color: CatWiseTheme.textSecondary)),
      );
    }

    final p = widget.progress!;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: RepaintBoundary(
              key: _repaintKey,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: CatWiseTheme.cardDecoration(color: Colors.white),
                child: Column(
                  children: [
                    const Icon(Icons.pets_rounded, size: 48, color: CatWiseTheme.warmHoney),
                    const SizedBox(height: 8),
                    const Text('Котик Учёный',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary)),
                    const Text('Отчёт об успехах',
                        style: TextStyle(fontSize: 14, color: CatWiseTheme.textSecondary)),
                    const SizedBox(height: 20),
                    _ReportRow(label: 'Пройдено заданий', value: '${p.tasksCompleted}', icon: Icons.task_alt_rounded, color: CatWiseTheme.successGreen),
                    _ReportRow(label: 'Звёзд заработано', value: p.totalStars.toStringAsFixed(1), icon: Icons.star_rounded, color: CatWiseTheme.starGold),
                    _ReportRow(label: 'Конфет собрано', value: '${p.totalCandies}', icon: Icons.favorite_rounded, color: CatWiseTheme.candyPink),
                    _ReportRow(label: 'Серия дней', value: '${p.currentStreak} (рекорд: ${p.longestStreak})', icon: Icons.local_fire_department_rounded, color: CatWiseTheme.errorPeach),
                    _ReportRow(label: 'Шляп собрано', value: '${p.ownedCostumes.length} из 10', icon: Icons.auto_awesome_rounded, color: CatWiseTheme.warmHoney),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text('Прогресс по блокам',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
                    const SizedBox(height: 8),
                    _BlockReportRow(label: 'Буквы', done: p.blockProgress['letters'] ?? 0, total: AppConstants.tasksPerBlock, color: CatWiseTheme.softLavender),
                    _BlockReportRow(label: 'Математика', done: p.blockProgress['math'] ?? 0, total: AppConstants.tasksPerBlock, color: CatWiseTheme.mintGreen),
                    _BlockReportRow(label: 'Окружающий мир', done: p.blockProgress['world'] ?? 0, total: AppConstants.tasksPerBlock, color: CatWiseTheme.skyBlue),
                    const SizedBox(height: 16),
                    Text(
                      'Сформировано: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                      style: const TextStyle(fontSize: 11, color: CatWiseTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: CatWiseTheme.warmHoney,
                foregroundColor: CatWiseTheme.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: _share,
              icon: const Icon(Icons.share_rounded),
              label: const Text('Поделиться', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportRow({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: CatWiseTheme.parentStyle)),
          Text(value, style: CatWiseTheme.parentStyle.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _BlockReportRow extends StatelessWidget {
  final String label;
  final int done;
  final int total;
  final Color color;

  const _BlockReportRow({required this.label, required this.done, required this.total, required this.color});

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? done / total : 0.0;
    final emoji = fraction >= 1.0 ? '⭐' : fraction >= 0.5 ? '🌟' : '💪';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: CatWiseTheme.parentStyle)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 12,
                backgroundColor: color.withOpacity(0.2),
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$done/$total', style: const TextStyle(fontSize: 13, color: CatWiseTheme.textSecondary)),
          const SizedBox(width: 4),
          Text(emoji, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class _AiTab extends StatefulWidget {
  const _AiTab();

  @override
  State<_AiTab> createState() => _AiTabState();
}

class _AiTabState extends State<_AiTab> {
  final _keyController = TextEditingController();
  String _provider = 'gemini';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('ai_api_key') ?? '';
    final provider = prefs.getString('ai_provider') ?? 'gemini';
    _keyController.text = key;
    AIService.setApiKey(key);
    AIService.setProvider(provider);
    if (mounted) setState(() => _provider = provider);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_api_key', _keyController.text.trim());
    await prefs.setString('ai_provider', _provider);
    AIService.setApiKey(_keyController.text.trim());
    AIService.setProvider(_provider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сохранено!'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: CatWiseTheme.cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Провайдер ИИ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _ProviderChip(
                    label: 'Gemini',
                    selected: _provider == 'gemini',
                    onTap: () => setState(() => _provider = 'gemini'),
                  ),
                  const SizedBox(width: 8),
                  _ProviderChip(
                    label: 'GigaChat',
                    selected: _provider == 'gigachat',
                    onTap: () => setState(() => _provider = 'gigachat'),
                  ),
                  const SizedBox(width: 8),
                  _ProviderChip(
                    label: 'YandexGPT',
                    selected: _provider == 'yandex',
                    onTap: () => setState(() => _provider = 'yandex'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('API-ключ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: CatWiseTheme.textPrimary)),
              const SizedBox(height: 8),
              TextField(
                controller: _keyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Вставьте ключ...',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.save_rounded),
                    onPressed: _save,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _provider == 'gemini'
                    ? 'Gemini API бесплатен (1500 запросов/день). Нужен VPN для РФ. Ключ: aistudio.google.com'
                    : _provider == 'gigachat'
                        ? 'GigaChat API от Сбера. Работает в РФ. Ключ: developers.sber.ru'
                        : 'YandexGPT API. От 0.5₽/1000 токенов. Для РФ. Ключ: cloud.yandex.ru → YandexGPT',
                style: const TextStyle(fontSize: 12, color: CatWiseTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SubTab extends StatelessWidget {
  const _SubTab();

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionService>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: CatWiseTheme.cardDecoration(),
          child: Column(
            children: [
              Icon(
                sub.hasSubscription ? Icons.workspace_premium_rounded : Icons.card_giftcard_rounded,
                size: 56,
                color: sub.hasSubscription ? CatWiseTheme.starGold : CatWiseTheme.warmHoney,
              ),
              const SizedBox(height: 12),
              Text(
                sub.hasSubscription ? 'Волшебный чердак активен!' : 'Волшебный чердак',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: CatWiseTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              if (sub.hasSubscription)
                Text(
                  'Подписка действует до ${sub.expiryDate?.day}.${sub.expiryDate?.month}.${sub.expiryDate?.year}',
                  style: const TextStyle(fontSize: 14, color: CatWiseTheme.textSecondary),
                )
              else if (sub.isTrialAvailable)
                const Text('3 дня бесплатно, потом 149₽/мес',
                    style: TextStyle(fontSize: 14, color: CatWiseTheme.textSecondary)),
              const SizedBox(height: 20),
              ..._features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: CatWiseTheme.successGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(f, style: CatWiseTheme.parentStyle)),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              if (sub.hasSubscription)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CatWiseTheme.successGreen.withOpacity(0.2),
                      foregroundColor: CatWiseTheme.successGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: null,
                    child: const Text('Подписка активна', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                )
              else if (sub.isTrialAvailable)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CatWiseTheme.warmHoney,
                      foregroundColor: CatWiseTheme.textPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () => sub.startTrial(),
                    child: const Text('Начать триал 3 дня', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                )
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CatWiseTheme.starGold,
                          foregroundColor: CatWiseTheme.textPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () => sub.purchase(store: 'rustore'),
                        child: const Text('Купить — RuStore', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => sub.restorePurchase(),
                      child: const Text('Восстановить покупку', style: TextStyle(color: CatWiseTheme.textSecondary)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  static const _features = [
    '🖼️ Эксклюзивные шляпы для Котика',
    '🎮 Мини-игры между заданиями',
    '📊 Отчёты для родителей (поделиться)',
    '🦸 Безлимитные задания',
    '🌸 Новые наряды каждый месяц',
  ];
}

class _ProviderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProviderChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? CatWiseTheme.warmHoney.withOpacity(0.4) : Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: selected ? Border.all(color: CatWiseTheme.warmHoney) : null,
        ),
        child: Text(label, style: const TextStyle(fontSize: 14, color: CatWiseTheme.textPrimary)),
      ),
    );
  }
}
