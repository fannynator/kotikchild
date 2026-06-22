import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

    if (_provider == 'gigachat') {
      return _gigaChat(message, mode: mode);
    }
    return _geminiChat(message, mode: mode);
  }

  static Future<String> _geminiChat(String message, {String mode = 'chat'}) async {

    final systemPrompt = switch (mode) {
      'story' => _storyPrompt,
      'riddle' => _riddlePrompt,
      _ => _systemPrompt,
    };

    try {
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'system_instruction': {
            'parts': [{'text': systemPrompt}]
          },
          'contents': [
            {
              'parts': [{'text': message}]
            }
          ],
          'safetySettings': [
            {'category': 'HARM_CATEGORY_HARASSMENT', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_HATE_SPEECH', 'threshold': 'BLOCK_ONLY_HIGH'},
            {'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold': 'BLOCK_ONLY_HIGH'},
          ],
          'generationConfig': {
            'maxOutputTokens': 300,
            'temperature': 0.9,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return text ?? 'Мяу! Я задумался... Давай ещё раз!';
      }

      debugPrint('Gemini API error: ${response.statusCode} ${response.body}');
      return 'Ой! Мой волшебный шарик затуманился. Попробуем ещё раз?';
    } catch (e) {
      debugPrint('Gemini API exception: $e');
      return 'Мяу! Что-то пошло не так. Давай попробуем позже!';
    }
  }

  static Future<String> _gigaChat(String message, {String mode = 'chat'}) async {
    final systemPrompt = switch (mode) {
      'story' => _storyPrompt,
      'riddle' => _riddlePrompt,
      _ => _systemPrompt,
    };

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

      String accessToken;
      if (authResponse.statusCode == 200) {
        final authData = jsonDecode(authResponse.body);
        accessToken = authData['access_token'] as String;
      } else {
        debugPrint('GigaChat auth error: ${authResponse.statusCode}');
        return 'Ой! Не могу подключиться к волшебству. Проверь ключ!';
      }

      final chatResponse = await http.post(
        Uri.parse('https://gigachat.devices.sberbank.ru/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'model': 'GigaChat',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': message},
          ],
          'max_tokens': 300,
          'temperature': 0.9,
        }),
      );

      if (chatResponse.statusCode == 200) {
        final data = jsonDecode(chatResponse.body);
        final text = data['choices']?[0]?['message']?['content'] as String?;
        return text ?? 'Мяу! Я задумался... Давай ещё раз!';
      }

      debugPrint('GigaChat API error: ${chatResponse.statusCode} ${chatResponse.body}');
      return 'Ой! Мой волшебный шарик затуманился. Попробуем ещё раз?';
    } catch (e) {
      debugPrint('GigaChat API exception: $e');
      return 'Мяу! Что-то пошло не так. Давай попробуем позже!';
    }
  }
}
