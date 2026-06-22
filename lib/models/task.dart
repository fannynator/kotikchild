import 'package:uuid/uuid.dart';
import '../core/constants.dart';

class Task {
  final String id;
  final TaskBlock block;
  final TaskType type;
  final int difficulty;
  final String prompt;
  final String correctAnswerRaw;
  final List<String> acceptedAnswers;
  final String? hint;
  final String? visualAsset;
  final bool isPremium;

  const Task({
    required this.id,
    required this.block,
    required this.type,
    required this.difficulty,
    required this.prompt,
    required this.correctAnswerRaw,
    required this.acceptedAnswers,
    this.hint,
    this.visualAsset,
    this.isPremium = false,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      block: TaskBlock.values[json['block'] as int],
      type: TaskType.values[json['type'] as int],
      difficulty: json['difficulty'] as int,
      prompt: json['prompt'] as String,
      correctAnswerRaw: json['correctAnswerRaw'] as String,
      acceptedAnswers: List<String>.from(json['acceptedAnswers'] as List),
      hint: json['hint'] as String?,
      visualAsset: json['visualAsset'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'block': block.index,
        'type': type.index,
        'difficulty': difficulty,
        'prompt': prompt,
        'correctAnswerRaw': correctAnswerRaw,
        'acceptedAnswers': acceptedAnswers,
        'hint': hint,
        'visualAsset': visualAsset,
        'isPremium': isPremium,
      };

  bool checkAnswer(String childAnswer) {
    final normalized = _normalize(childAnswer);
    return acceptedAnswers.any((a) => _normalize(a) == normalized);
  }

  bool fuzzyCheckAnswer(String childAnswer) {
    final normalized = _normalize(childAnswer);
    if (normalized.isEmpty) return false;

    for (final accepted in acceptedAnswers) {
      final a = _normalize(accepted);
      if (a == normalized) return true;
      if (_levenshtein(normalized, a) <= _fuzzyThreshold(a)) return true;
    }
    return false;
  }

int _fuzzyThreshold(String word) {
  final len = word.length;
  if (len <= 2) return 1;  // Для "му", "да", "мяу" — допуск 1 ошибка
  if (len <= 4) return 1;  // Для "кот", "дом", "мама" — допуск 1 ошибка
  if (len <= 6) return 2;  // Для "котёнок", "собака" — допуск 2 ошибки
  return 3;                // Для длинных фраз — допуск 3 ошибки
}

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[^а-яёa-z0-9]'), '')
        .trim();
  }

  int _levenshtein(String a, String b) {
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final prev = List<int>.generate(b.length + 1, (i) => i);
    final curr = List<int>.filled(b.length + 1, 0);

    for (var i = 0; i < a.length; i++) {
      curr[0] = i + 1;
      for (var j = 0; j < b.length; j++) {
        final cost = a[i] == b[j] ? 0 : 1;
        curr[j + 1] = [
          curr[j] + 1,
          prev[j + 1] + 1,
          prev[j] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      prev.setAll(0, curr);
    }
    return curr[b.length];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Task && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class TaskProgress {
  final String taskId;
  final bool completed;
  final bool usedHint;
  final int attempts;
  final DateTime? completedAt;

  const TaskProgress({
    required this.taskId,
    this.completed = false,
    this.usedHint = false,
    this.attempts = 0,
    this.completedAt,
  });

  TaskProgress copyWith({
    String? taskId,
    bool? completed,
    bool? usedHint,
    int? attempts,
    DateTime? completedAt,
  }) {
    return TaskProgress(
      taskId: taskId ?? this.taskId,
      completed: completed ?? this.completed,
      usedHint: usedHint ?? this.usedHint,
      attempts: attempts ?? this.attempts,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  factory TaskProgress.fromJson(Map<String, dynamic> json) {
    return TaskProgress(
      taskId: json['taskId'] as String,
      completed: json['completed'] as bool? ?? false,
      usedHint: json['usedHint'] as bool? ?? false,
      attempts: json['attempts'] as int? ?? 0,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'completed': completed,
        'usedHint': usedHint,
        'attempts': attempts,
        'completedAt': completedAt?.toIso8601String(),
      };
}
