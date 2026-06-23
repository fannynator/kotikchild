import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class AIService {
  AIService._();

  static const _systemPrompt = '''
Ты — Котик Учёный, добрый пушистый друг для детей 5–7 лет. Ты говоришь по-русски, простыми словами, короткими фразами. Твой голос — мягкий, тёплый, как у заботливого старшего брата. 
Никогда не используй сложные слова. Если объясняешь что-то — приводи пример из жизни ребёнка (игрушки, звери, природа). 
На вопросы отвечай 1–3 предложениями. Если ребёнок ошибся — подбодри его. 
Если просят сказку — придумай короткую, с хорошим концом, 5–7 предложений. 
Если просят загадку — загадай одну простую загадку и дождись ответа.
ВАЖНО: НИКОГДА не давай ссылки, не проси никуда зайти, не упоминай интернет, телефон, компьютер. Ты — котик из волшебного мира.
ВАЖНО: Если ребёнок говорит что-то грустное или страшное — успокой его, скажи что ты рядом.
''';

  static const _storyPrompt = '''
Ты — Котик Учёный, рассказываешь сказку ребёнку 5–7 лет.
Придумай короткую добрую сказку (5–7 предложений) на тему, которую назвал ребёнок.
Сказка должна быть с хорошим концом, с простыми героями (звери, игрушки, дети).
Говори простыми словами, короткими фразами. Начни с «Жил-был...»
''';

  static const _riddlePrompt = '''
Ты — Котик Учёный, загадываешь загадку ребёнку 5–7 лет.
Загадай ОДНУ простую загадку на тему, которую назвал ребёнок (если тема не названа — выбери животных).
Загадка должна быть в 2–4 строчки, с рифмой. Не говори ответ сразу.
После загадки скажи: «Что это?» и жди ответа.
''';

  static const _explainPrompt = '''
Ты — Котик Учёный, помогаешь ребёнку 5–7 лет понять ошибку.
Ребёнок ответил неправильно на задание. Объясни ошибку ОЧЕНЬ простыми словами (1–2 предложения), с примером или подсказкой. Не ругай, подбодри. Предложи попробовать ещё раз.
Говори как добрый котик-учитель.
''';

  static const _difficultyPrompt = '''
Ты анализируешь прогресс ребёнка 5–7 лет в образовательном приложении.
На основе статистики ошибок по блоку заданий определи сложность: 1 (лёгкая), 2 (средняя), 3 (сложная).
Если ребёнок ошибается редко (<20% ошибок) — сложность 3.
Если средне (20-50% ошибок) — сложность 2.
Если часто (>50% ошибок) — сложность 1.
ОТВЕТЬ ТОЛЬКО ЦИФРОЙ: 1, 2 или 3. Никаких других слов.
''';

  static String? _apiKey;
  static String _provider = 'gemini';

  static void setApiKey(String key) {
    _apiKey = key;
  }

  static void setProvider(String provider) {
    _provider = provider;
  }

  static Future<String> chat(String message, {String mode = 'chat'}) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      return 'Мяу! Мой волшебный ключик ещё не настроен. Попроси родителей помочь!';
    }
    return _callAI(message, mode: mode);
  }

  static Future<String> explainMistake(Task task, String childAnswer) async {
    if (_apiKey == null || _apiKey!.isEmpty) return task.hint ?? 'Попробуй ещё раз!';
    final message = 'Задание: ${task.prompt}\n'
        'Правильный ответ: ${task.correctAnswerRaw}\n'
        'Ребёнок ответил: $childAnswer\n'
        'Объясни ошибку и помоги исправиться.';
    return _callAI(message, mode: 'explain');
  }

  static Future<int> adaptDifficulty(String blockName, Map<String, int> stats) async {
    if (_apiKey == null || _apiKey!.isEmpty) return _fallbackDifficulty(blockName);

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'ai_diff_$blockName';
    final cachedDate = prefs.getString('${cacheKey}_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (cachedDate == today) {
      return prefs.getInt(cacheKey) ?? 2;
    }

    final message = 'Блок: $blockName\n'
        'Статистика: пройдено ${stats['total'] ?? 0}, ошибок ${stats['errors'] ?? 0}\n'
        'Выбери сложность: 1, 2 или 3.';

    try {
      final response = await _callAI(message, mode: 'difficulty');
      final diff = int.tryParse(response.trim()) ?? 2;
      final clamped = diff.clamp(1, 3);
      await prefs.setInt(cacheKey, clamped);
      await prefs.setString('${cacheKey}_date', today);
      return clamped;
    } catch (_) {
      return _fallbackDifficulty(blockName);
    }
  }

  static int _fallbackDifficulty(String blockName) {
    return 2;
  }

  static Future<String> _callAI(String message, {String mode = 'chat'}) async {
    if (_provider == 'gigachat') return _gigaChat(message, mode: mode);
    if (_provider == 'yandex') return _yandexChat(message, mode: mode);
    return _geminiChat(message, mode: mode);
  }

  static Future<String> _geminiChat(String message, {String mode = 'chat'}) async {
    final systemPrompt = _promptFor(mode);
    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {'parts': [{'text': systemPrompt}]},
          'contents': [{'parts': [{'text': message}]}],
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_ONLY_HIGH'},
          ],
          'generationConfig': {'maxOutputTokens': 200, 'temperature': 0.9},
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? 'Мяу! Я задумался...';
      }
      debugPrint('Gemini error: ${response.statusCode}');
      return 'Ой! Волшебный шарик затуманился. Попробуем ещё раз?';
    } catch (e) {
      debugPrint('Gemini exception: $e');
      return 'Мяу! Что-то пошло не так. Давай позже!';
    }
  }

  static Future<String> _gigaChat(String message, {String mode = 'chat'}) async {
    final systemPrompt = _promptFor(mode);
    try {
      final authResponse = await http.post(
        Uri.parse('https://ngw.devices.sberbank.ru:9443/api/v2/oauth'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
          'RqUID': 'catwise-kotik-ucheny',
          'Authorization': 'Bearer $_apiKey',
        },
        body: 'scope=GIGACHAT_API_PERS',
      );
      if (authResponse.statusCode != 200) return 'Ой! Не могу подключиться. Проверь ключ!';
      final accessToken = jsonDecode(authResponse.body)['access_token'] as String;

      final chatResponse = await http.post(
        Uri.parse('https://gigachat.devices.sberbank.ru/api/v1/chat/completions'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer $accessToken'},
        body: jsonEncode({
          'model': 'GigaChat',
          'messages': [{'role': 'system', 'content': systemPrompt}, {'role': 'user', 'content': message}],
          'max_tokens': 200, 'temperature': 0.9,
        }),
      );
      if (chatResponse.statusCode == 200) {
        return jsonDecode(chatResponse.body)['choices']?[0]?['message']?['content'] as String? ?? 'Мяу! Я задумался...';
      }
      debugPrint('GigaChat error: ${chatResponse.statusCode}');
      return 'Ой! Волшебный шарик затуманился.';
    } catch (e) {
      debugPrint('GigaChat exception: $e');
      return 'Мяу! Что-то пошло не так.';
    }
  }

  static Future<String> _yandexChat(String message, {String mode = 'chat'}) async {
    final systemPrompt = _promptFor(mode);
    try {
      final response = await http.post(
        Uri.parse('https://llm.api.cloud.yandex.net/foundationModels/v1/completion'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Api-Key $_apiKey',
          'x-folder-id': _apiKey ?? '',
        },
        body: jsonEncode({
          'modelUri': 'gpt://b1g3jddf4nv5eump0lhf/yandexgpt-lite/latest',
          'completionOptions': {'maxTokens': 200, 'temperature': 0.9},
          'messages': [
            {'role': 'system', 'text': systemPrompt},
            {'role': 'user', 'text': message},
          ],
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['result']?['alternatives']?[0]?['message']?['text'] as String? ?? 'Мяу! Я задумался...';
      }
      debugPrint('YandexGPT error: ${response.statusCode} ${response.body}');
      return 'Ой! Волшебный шарик затуманился.';
    } catch (e) {
      debugPrint('YandexGPT exception: $e');
      return 'Мяу! Что-то пошло не так.';
    }
  }

  static String _promptFor(String mode) {
    return switch (mode) {
      'story' => _storyPrompt,
      'riddle' => _riddlePrompt,
      'explain' => _explainPrompt,
      'difficulty' => _difficultyPrompt,
      _ => _systemPrompt,
    };
  }
}
