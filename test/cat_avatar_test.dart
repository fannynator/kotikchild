import 'package:flutter_test/flutter_test.dart';
import 'package:kotik_ucheny/core/constants.dart';
import 'package:kotik_ucheny/models/task.dart';

void main() {
  group('Task answer checking', () {
    final task = Task(
      id: 'test_1',
      block: TaskBlock.letters,
      type: TaskType.nameLetter,
      difficulty: 1,
      prompt: 'Назови букву',
      correctAnswerRaw: 'а',
      acceptedAnswers: ['а', 'буква а', 'звук а'],
    );

    test('exact answer passes', () {
      expect(task.checkAnswer('а'), isTrue);
    });

    test('fuzzy matching tolerates extra spaces', () {
      expect(task.checkAnswer(' а '), isTrue);
    });

    test('wrong answer fails', () {
      expect(task.checkAnswer('б'), isFalse);
    });

    test('fuzzy check tolerates one phoneme off', () {
      expect(task.fuzzyCheckAnswer('аа'), isTrue);
    });
  });

  group('Constants', () {
    test('parent gate answer is 56', () {
      expect(AppConstants.parentGateAnswer, 56);
    });

    test('trial days is 3', () {
      expect(AppConstants.trialDays, 3);
    });
  });
}
