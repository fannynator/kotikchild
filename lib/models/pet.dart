import 'package:flutter/animation.dart';
import '../core/constants.dart';

class PetState {
  final CatMood mood;
  final String activeCostume;
  final double earLeftAngle;
  final double earRightAngle;
  final double blinkProgress;
  final double tailWag;
  final double scale;
  final bool isHugging;

  const PetState({
    this.mood = CatMood.neutral,
    this.activeCostume = 'default_hat',
    this.earLeftAngle = 0.0,
    this.earRightAngle = 0.0,
    this.blinkProgress = 0.0,
    this.tailWag = 0.0,
    this.scale = 1.0,
    this.isHugging = false,
  });

  PetState copyWith({
    CatMood? mood,
    String? activeCostume,
    double? earLeftAngle,
    double? earRightAngle,
    double? blinkProgress,
    double? tailWag,
    double? scale,
    bool? isHugging,
  }) {
    return PetState(
      mood: mood ?? this.mood,
      activeCostume: activeCostume ?? this.activeCostume,
      earLeftAngle: earLeftAngle ?? this.earLeftAngle,
      earRightAngle: earRightAngle ?? this.earRightAngle,
      blinkProgress: blinkProgress ?? this.blinkProgress,
      tailWag: tailWag ?? this.tailWag,
      scale: scale ?? this.scale,
      isHugging: isHugging ?? this.isHugging,
    );
  }

  static PetState forMood(CatMood mood, {String costume = 'default_hat'}) {
    switch (mood) {
      case CatMood.neutral:
        return PetState(mood: mood, activeCostume: costume, tailWag: 0.1);
      case CatMood.curious:
        return PetState(mood: mood, activeCostume: costume, earLeftAngle: 0.2, earRightAngle: -0.1, tailWag: 0.3);
      case CatMood.happy:
        return PetState(mood: mood, activeCostume: costume, earLeftAngle: 0.3, earRightAngle: 0.3, tailWag: 0.6);
      case CatMood.thinking:
        return PetState(mood: mood, activeCostume: costume, earLeftAngle: -0.1, earRightAngle: -0.1, tailWag: 0.15);
      case CatMood.encouraging:
        return PetState(mood: mood, activeCostume: costume, earLeftAngle: 0.2, earRightAngle: 0.1, tailWag: 0.4);
      case CatMood.celebrating:
        return PetState(mood: mood, activeCostume: costume, scale: 1.15, earLeftAngle: 0.4, earRightAngle: 0.4, tailWag: 0.8, isHugging: true);
      case CatMood.shrugging:
        return PetState(mood: mood, activeCostume: costume, earLeftAngle: -0.3, earRightAngle: -0.3, tailWag: 0.05);
    }
  }
}

class CostumeInfo {
  final String id;
  final String name;
  final int price;
  final String assetPath;

  const CostumeInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.assetPath,
  });

  static final List<CostumeInfo> all = [
    const CostumeInfo(id: 'default_hat', name: 'Котик', price: 0, assetPath: 'assets/images/hat_default.png'),
    const CostumeInfo(id: 'wizard_hat', name: 'Волшебник', price: 20, assetPath: 'assets/images/hat_wizard.png'),
    const CostumeInfo(id: 'crown', name: 'Корона', price: 25, assetPath: 'assets/images/hat_crown.png'),
    const CostumeInfo(id: 'flower_crown', name: 'Веночек', price: 15, assetPath: 'assets/images/hat_flower.png'),
    const CostumeInfo(id: 'pirate_hat', name: 'Пират', price: 30, assetPath: 'assets/images/hat_pirate.png'),
    const CostumeInfo(id: 'astronaut_helmet', name: 'Астронавт', price: 35, assetPath: 'assets/images/hat_astro.png'),
    const CostumeInfo(id: 'detective_hat', name: 'Сыщик', price: 20, assetPath: 'assets/images/hat_detective.png'),
    const CostumeInfo(id: 'chef_hat', name: 'Повар', price: 15, assetPath: 'assets/images/hat_chef.png'),
    const CostumeInfo(id: 'birthday_hat', name: 'Праздник', price: 25, assetPath: 'assets/images/hat_birthday.png'),
    const CostumeInfo(id: 'sleep_cap', name: 'Соня', price: 10, assetPath: 'assets/images/hat_sleep.png'),
  ];

  static CostumeInfo? findById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
