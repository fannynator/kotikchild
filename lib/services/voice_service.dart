import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../core/constants.dart';

enum VoiceServiceStatus { unavailable, ready, listening, processing, done }

class VoiceResult {
  final String transcript;
  final double confidence;
  final bool isFinal;

  const VoiceResult({
    required this.transcript,
    this.confidence = 0.0,
    this.isFinal = true,
  });
}

class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  VoiceServiceStatus _status = VoiceServiceStatus.unavailable;
  String _lastTranscript = '';
  Timer? _silenceTimer;
  bool _isInitialized = false;

  VoiceServiceStatus get status => _status;
  String get lastTranscript => _lastTranscript;
  bool get isAvailable => _isInitialized;

  Future<bool> initialize() async {
    try {
      _isInitialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: _onError,
      );
      if (_isInitialized) {
        _status = VoiceServiceStatus.ready;
        notifyListeners();
      }
      return _isInitialized;
    } catch (e) {
      debugPrint('VoiceService init error: $e');
      _isInitialized = false;
      return false;
    }
  }

  Future<VoiceResult?> listen({
    Duration silenceTimeout = const Duration(seconds: 3),
    Duration maxDuration = const Duration(seconds: 10),
  }) async {
    if (!_isInitialized) return null;

    final completer = Completer<VoiceResult?>();
    final buffer = StringBuffer();

    _status = VoiceServiceStatus.listening;
    notifyListeners();

    try {
      await _speech.listen(
        onResult: (result) {
          final transcript = result.recognizedWords;
          if (transcript.isNotEmpty) {
            buffer.clear();
            buffer.write(transcript);
          }

          if (result.finalResult) {
            _status = VoiceServiceStatus.done;
            _lastTranscript = buffer.toString();
            notifyListeners();
            if (!completer.isCompleted) {
              _silenceTimer?.cancel();
              completer.complete(VoiceResult(
                transcript: _lastTranscript,
                confidence: result.confidence,
                isFinal: true,
              ));
            }
          } else {
            _resetSilenceTimer(completer, buffer.toString(), silenceTimeout);
          }
        },
        listenFor: maxDuration,
        pauseFor: silenceTimeout,
        partialResults: true,
        localeId: 'ru_RU',
        cancelOnError: false,
      );

      Future.delayed(maxDuration, () {
        if (!completer.isCompleted) {
          _lastTranscript = buffer.toString();
          _status = VoiceServiceStatus.done;
          notifyListeners();
          completer.complete(_lastTranscript.isNotEmpty
              ? VoiceResult(transcript: _lastTranscript, isFinal: true)
              : null);
        }
      });
    } catch (e) {
      debugPrint('VoiceService listen error: $e');
      if (!completer.isCompleted) {
        completer.completeError(e);
      }
    }

    return completer.future;
  }

  void _resetSilenceTimer(Completer<VoiceResult?> completer, String currentText, Duration timeout) {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        _lastTranscript = currentText;
        _status = VoiceServiceStatus.done;
        notifyListeners();
        _speech.stop();
        completer.complete(currentText.isNotEmpty
            ? VoiceResult(transcript: currentText, isFinal: true)
            : null);
      }
    });
  }

  Future<void> stop() async {
    _silenceTimer?.cancel();
    await _speech.stop();
    _status = VoiceServiceStatus.ready;
    notifyListeners();
  }

  Future<void> cancel() async {
    _silenceTimer?.cancel();
    await _speech.cancel();
    _status = VoiceServiceStatus.ready;
    _lastTranscript = '';
    notifyListeners();
  }

  void _onStatus(String status) {
    debugPrint('STT status: $status');
    if (status == 'notListening') {
      if (_status == VoiceServiceStatus.listening) {
        _status = VoiceServiceStatus.done;
        notifyListeners();
      }
    }
  }

  void _onError(dynamic error) {
    debugPrint('STT error: $error');
    _silenceTimer?.cancel();
    _status = VoiceServiceStatus.ready;
    notifyListeners();
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.cancel();
    super.dispose();
  }
}
