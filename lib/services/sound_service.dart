import 'package:flutter/services.dart';

class SoundService {
  SoundService._();

  static void tap() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  static void correct() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  static void star() {
    HapticFeedback.heavyImpact();
  }

  static void candy() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  static void hat() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }

  static void wrong() {
    HapticFeedback.lightImpact();
  }
}
