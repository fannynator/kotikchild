import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/ai_service.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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

  void _save() {
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

class _ReportsTab extends StatelessWidget {
  final UserProgress? progress;

  const _ReportsTab({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(32),
        decoration: CatWiseTheme.cardDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf_rounded, size: 64, color: CatWiseTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'PDF-отчёты доступны\nпо подписке «Волшебный чердак»',
              textAlign: TextAlign.center,
              style: CatWiseTheme.parentStyle,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: CatWiseTheme.warmHoney,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {},
                child: Text('Оформить подписку', style: CatWiseTheme.bodyStyle.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
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
    if (mounted) setState(() => _provider = provider);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ai_api_key', _keyController.text.trim());
    await prefs.setString('ai_provider', _provider);
    AIService.setApiKey(_keyController.text.trim());
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
                    : 'GigaChat API от Сбера. Работает в РФ. Ключ: developers.sber.ru',
                style: const TextStyle(fontSize: 12, color: CatWiseTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
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
