class AppConstants {
  AppConstants._();

  static const String appName = 'Котик Учёный';
  static const String appVersion = '1.0.0';

  static const int freeTaskLimit = 120;
  static const int tasksPerBlock = 40;

  static const int starsPerCandy = 5;
  static const int candiesPerReward = 10;

  static const int maxWrongBeforeHint = 2;
  static const double halfStarValue = 0.5;

  static const int trialDays = 3;

  static const int parentGateAnswer = 56;
  static const String parentGateQuestion = '7 × 8 = ?';
  static const int maxParentAttempts = 3;

  static const Duration answerTimeout = Duration(seconds: 8);
  static const Duration celebrationDuration = Duration(seconds: 3);
  static const Duration hintDelay = Duration(seconds: 2);

  static const String subscriptionId = 'catwise_magic_attic_monthly';
  static const String subscriptionName = 'Волшебный чердак';

  static const List<String> costumeIds = [
    'default_hat',
    'wizard_hat',
    'crown',
    'flower_crown',
    'pirate_hat',
    'astronaut_helmet',
    'detective_hat',
    'chef_hat',
    'birthday_hat',
    'sleep_cap',
  ];

  static const List<int> costumePrices = [10, 20, 25, 15, 30, 35, 20, 15, 25, 10];
}

enum TaskBlock { letters, math, world }

enum TaskType {
  nameLetter,
  findSound,
  inventWord,
  clapWhenHear,
  hardSoft,
  syllables,
  rhyme,
  lostLetter,
  vowelConsonant,
  buildWord,
  count,
  addition,
  subtraction,
  greaterLess,
  numberNeighbors,
  continueSequence,
  shapes,
  logicPuzzle,
  compareObjects,
  time,
  whoSays,
  nameBaby,
  whatIsExtra,
  describeObject,
  seasons,
  madeOf,
  professions,
  artistMistake,
  whatFirst,
  sayOpposite,
}

extension TaskBlockLabel on TaskBlock {
  String get label {
    switch (this) {
      case TaskBlock.letters:
        return 'Буквы и чтение';
      case TaskBlock.math:
        return 'Математика и логика';
      case TaskBlock.world:
        return 'Окружающий мир';
    }
  }

  String get iconAsset {
    switch (this) {
      case TaskBlock.letters:
        return 'assets/images/block_letters.png';
      case TaskBlock.math:
        return 'assets/images/block_math.png';
      case TaskBlock.world:
        return 'assets/images/block_world.png';
    }
  }
}

enum VoiceState { idle, listening, processing, speaking, success, error }

enum CatMood { neutral, curious, happy, thinking, encouraging, celebrating, shrugging }
