import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/pet.dart';
import '../services/tts_service.dart';

class UserProgress extends ChangeNotifier {
  double totalStars;
  int totalCandies;
  int tasksCompleted;
  int currentStreak;
  int longestStreak;
  DateTime? lastPlayedDate;
  List<String> ownedCostumes;
  String activeCostume;
  bool hasSubscription;
  DateTime? trialStart;
  Map<String, int> blockProgress;
  Map<String, int> soundAccuracy;
  int totalMinutesPlayed;
  List<String> completedTaskIds;

  UserProgress({
    this.totalStars = 0.0,
    this.totalCandies = 0,
    this.tasksCompleted = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastPlayedDate,
    this.ownedCostumes = const ['default_hat'],
    this.activeCostume = 'default_hat',
    this.hasSubscription = false,
    this.trialStart,
    this.blockProgress = const {},
    this.soundAccuracy = const {},
    this.totalMinutesPlayed = 0,
    this.completedTaskIds = const [],
  });

  void addStars(double amount, TtsService tts) {
    totalStars += amount;
    tasksCompleted++;

    _updateStreak();

    while (totalStars >= AppConstants.starsPerCandy) {
      totalStars -= AppConstants.starsPerCandy;
      totalCandies++;
      tts.speak('Мяу! Ты заработал конфету!');
    }

    if (totalCandies >= AppConstants.candiesPerReward) {
      final lockedCostumes = CostumeInfo.all
          .where((c) => c.price > 0 && !ownedCostumes.contains(c.id))
          .toList();

      if (lockedCostumes.isNotEmpty) {
        final randomCostume = lockedCostumes[math.Random().nextInt(lockedCostumes.length)];
        totalCandies -= AppConstants.candiesPerReward;
        ownedCostumes = [...ownedCostumes, randomCostume.id];
        activeCostume = randomCostume.id;
        tts.speak('Ура! Новая шляпа для меня!');
      }
    }

    notifyListeners();
    save();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastPlayedDate != null) {
      final lastDay = DateTime(lastPlayedDate!.year, lastPlayedDate!.month, lastPlayedDate!.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 1) {
        currentStreak++;
      } else if (diff > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    lastPlayedDate = today;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('totalStars', totalStars);
    prefs.setInt('totalCandies', totalCandies);
    prefs.setInt('tasksCompleted', tasksCompleted);
    prefs.setInt('currentStreak', currentStreak);
    prefs.setInt('longestStreak', longestStreak);
    prefs.setString('lastPlayedDate', lastPlayedDate?.toIso8601String() ?? '');
    prefs.setStringList('ownedCostumes', ownedCostumes);
    prefs.setString('activeCostume', activeCostume);
    prefs.setInt('totalMinutesPlayed', totalMinutesPlayed);
    prefs.setString('completedTaskIds', jsonEncode(completedTaskIds));
    prefs.setString('blockProgress', jsonEncode(blockProgress));
  }

  static Future<UserProgress> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('lastPlayedDate') ?? '';

    return UserProgress(
      totalStars: prefs.getDouble('totalStars') ?? 0.0,
      totalCandies: prefs.getInt('totalCandies') ?? 0,
      tasksCompleted: prefs.getInt('tasksCompleted') ?? 0,
      currentStreak: prefs.getInt('currentStreak') ?? 0,
      longestStreak: prefs.getInt('longestStreak') ?? 0,
      lastPlayedDate: lastDateStr.isNotEmpty ? DateTime.parse(lastDateStr) : null,
      ownedCostumes: prefs.getStringList('ownedCostumes') ?? ['default_hat'],
      activeCostume: prefs.getString('activeCostume') ?? 'default_hat',
      totalMinutesPlayed: prefs.getInt('totalMinutesPlayed') ?? 0,
      completedTaskIds: _parseJsonList(prefs.getString('completedTaskIds')),
      blockProgress: _parseJsonMap(prefs.getString('blockProgress')),
    );
  }

  static List<String> _parseJsonList(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(json) as List);
    } catch (_) {
      return [];
    }
  }

  static Map<String, int> _parseJsonMap(String? json) {
    if (json == null || json.isEmpty) return {};
    try {
      return Map<String, int>.from(jsonDecode(json) as Map);
    } catch (_) {
      return {};
    }
  }

  int get starsProgressInBlock => totalStars.toInt() % AppConstants.starsPerCandy;
  int get candiesProgressInBlock => totalCandies % AppConstants.candiesPerReward;

  bool get isTrialActive {
    if (trialStart == null || hasSubscription) return false;
    return DateTime.now().difference(trialStart!).inDays < AppConstants.trialDays;
  }

  bool get canAccessPremium => hasSubscription || isTrialActive;

  UserProgress copyWith({
    double? totalStars,
    int? totalCandies,
    int? tasksCompleted,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastPlayedDate,
    List<String>? ownedCostumes,
    String? activeCostume,
    bool? hasSubscription,
    DateTime? trialStart,
    Map<String, int>? blockProgress,
    Map<String, int>? soundAccuracy,
    int? totalMinutesPlayed,
    List<String>? completedTaskIds,
  }) {
    return UserProgress(
      totalStars: totalStars ?? this.totalStars,
      totalCandies: totalCandies ?? this.totalCandies,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      ownedCostumes: ownedCostumes ?? this.ownedCostumes,
      activeCostume: activeCostume ?? this.activeCostume,
      hasSubscription: hasSubscription ?? this.hasSubscription,
      trialStart: trialStart ?? this.trialStart,
      blockProgress: blockProgress ?? this.blockProgress,
      soundAccuracy: soundAccuracy ?? this.soundAccuracy,
      totalMinutesPlayed: totalMinutesPlayed ?? this.totalMinutesPlayed,
      completedTaskIds: completedTaskIds ?? this.completedTaskIds,
    );
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalStars: (json['totalStars'] as num?)?.toDouble() ?? 0.0,
      totalCandies: json['totalCandies'] as int? ?? 0,
      tasksCompleted: json['tasksCompleted'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null ? DateTime.parse(json['lastPlayedDate'] as String) : null,
      ownedCostumes: List<String>.from(json['ownedCostumes'] as List? ?? ['default_hat']),
      activeCostume: json['activeCostume'] as String? ?? 'default_hat',
      hasSubscription: json['hasSubscription'] as bool? ?? false,
      trialStart: json['trialStart'] != null ? DateTime.parse(json['trialStart'] as String) : null,
      blockProgress: Map<String, int>.from(json['blockProgress'] as Map? ?? {}),
      soundAccuracy: Map<String, int>.from(json['soundAccuracy'] as Map? ?? {}),
      totalMinutesPlayed: json['totalMinutesPlayed'] as int? ?? 0,
      completedTaskIds: List<String>.from(json['completedTaskIds'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalStars': totalStars,
        'totalCandies': totalCandies,
        'tasksCompleted': tasksCompleted,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'lastPlayedDate': lastPlayedDate?.toIso8601String(),
        'ownedCostumes': ownedCostumes,
        'activeCostume': activeCostume,
        'hasSubscription': hasSubscription,
        'trialStart': trialStart?.toIso8601String(),
        'blockProgress': blockProgress,
        'soundAccuracy': soundAccuracy,
        'totalMinutesPlayed': totalMinutesPlayed,
        'completedTaskIds': completedTaskIds,
      };
}

class ParentSettings {
  final int dailyTimeLimitMinutes;
  final bool soundEffectsEnabled;
  final bool hapticFeedbackEnabled;
  final int voiceSpeed;
  final String childName;
  final int childAge;

  const ParentSettings({
    this.dailyTimeLimitMinutes = 30,
    this.soundEffectsEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.voiceSpeed = 1,
    this.childName = '',
    this.childAge = 5,
  });

  ParentSettings copyWith({
    int? dailyTimeLimitMinutes,
    bool? soundEffectsEnabled,
    bool? hapticFeedbackEnabled,
    int? voiceSpeed,
    String? childName,
    int? childAge,
  }) {
    return ParentSettings(
      dailyTimeLimitMinutes: dailyTimeLimitMinutes ?? this.dailyTimeLimitMinutes,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      childName: childName ?? this.childName,
      childAge: childAge ?? this.childAge,
    );
  }

  factory ParentSettings.fromJson(Map<String, dynamic> json) {
    return ParentSettings(
      dailyTimeLimitMinutes: json['dailyTimeLimitMinutes'] as int? ?? 30,
      soundEffectsEnabled: json['soundEffectsEnabled'] as bool? ?? true,
      hapticFeedbackEnabled: json['hapticFeedbackEnabled'] as bool? ?? true,
      voiceSpeed: json['voiceSpeed'] as int? ?? 1,
      childName: json['childName'] as String? ?? '',
      childAge: json['childAge'] as int? ?? 5,
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyTimeLimitMinutes': dailyTimeLimitMinutes,
        'soundEffectsEnabled': soundEffectsEnabled,
        'hapticFeedbackEnabled': hapticFeedbackEnabled,
        'voiceSpeed': voiceSpeed,
        'childName': childName,
        'childAge': childAge,
      };
}
