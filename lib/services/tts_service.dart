import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isReady = false;
  bool _isSpeaking = false;
  double _speed = 0.45;
  double _basePitch = 1.5;
  Completer<void>? _speakCompleter;

  bool get isReady => _isReady;
  bool get isSpeaking => _isSpeaking;
  double get speed => _speed;

  final List<String> _praisePhrases = [
    'Молодец! У тебя отлично получается!',
    'Замечательно! Ты очень умный!',
    'Ура! Правильно! Дай пять!',
    'Ты просто супер! Продолжай!',
    'Великолепно! Я горжусь тобой!',
  ];

  final List<String> _encouragePhrases = [
    'Почти получилось! Давай попробуем ещё раз!',
    'Ты близко! Попробуй снова!',
    'Хорошая попытка! Давай ещё разок!',
    'Не сдавайся! У тебя всё получится!',
  ];

  final List<String> _hintPhrases = [
    'Давай я подскажу...',
    'Посмотри внимательно...',
    'Подумай хорошенько...',
  ];

  Future<void> initialize() async {
    try {
      await _tts.setLanguage('ru-RU');
      await _tts.setSpeechRate(_speed);
      await _tts.setPitch(_basePitch);
      await _tts.setVolume(0.9);

      try {
        final voices = await _tts.getVoices;
        if (voices != null && voices.isNotEmpty) {
          final ruVoices = voices.where((v) {
            final locale = (v['locale'] ?? '').toString().toLowerCase();
            return locale.startsWith('ru');
          }).toList();

          if (ruVoices.isNotEmpty) {
            final femaleVoice = ruVoices.firstWhere(
              (_) => true,
              orElse: () => ruVoices.first,
            );
            await _tts.setVoice(femaleVoice);
            debugPrint('TTS voice set: ${femaleVoice['name']}');
          }
        }
      } catch (_) {
        debugPrint('TTS voice selection skipped — using system default');
      }

      _isReady = true;
      notifyListeners();
    } catch (e) {
      debugPrint('TTS init error: $e');
    }
  }

  Future<void> setSpeed(int level) async {
    _speed = 0.3 + (level * 0.15);
    if (_speed > 0.9) _speed = 0.9;
    if (_speed < 0.3) _speed = 0.3;
    await _tts.setSpeechRate(_speed);
    notifyListeners();
  }

  Future<void> speak(String text, {double? pitchOverride}) async {
    if (!_isReady) return;

    if (pitchOverride != null) {
      await _tts.setPitch(pitchOverride);
    } else if (_basePitch != 1.5) {
      await _tts.setPitch(_basePitch);
    }

    _isSpeaking = true;
    _speakCompleter = Completer<void>();
    notifyListeners();

    try {
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }

    _isSpeaking = false;
    _speakCompleter?.complete();
    _speakCompleter = null;

    if (pitchOverride != null) {
      await _tts.setPitch(_basePitch);
    }

    notifyListeners();
  }

  Future<void> speakPraise() async {
    _praisePhrases.shuffle();
    await speak(_praisePhrases.first, pitchOverride: 1.7);
  }

  Future<void> speakEncourage() async {
    _encouragePhrases.shuffle();
    await speak(_encouragePhrases.first, pitchOverride: 1.3);
  }

  Future<void> speakHint() async {
    _hintPhrases.shuffle();
    await speak(_hintPhrases.first, pitchOverride: 1.3);
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _tts.stop();
      _isSpeaking = false;
      _speakCompleter?.complete();
      _speakCompleter = null;
      notifyListeners();
    }
  }

  Future<void> awaitCompletion() async {
    if (_speakCompleter != null) {
      await _speakCompleter!.future;
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
