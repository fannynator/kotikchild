import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'core/theme.dart';
import 'models/user.dart';
import 'services/subscription_service.dart';
import 'services/voice_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: CatWiseTheme.warmCream,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final voiceService = VoiceService();
  final ttsService = TtsService();
  final userProgress = await UserProgress.load();
  await SubscriptionService.instance.init();

  await Future.wait([
    voiceService.initialize(),
    ttsService.initialize(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: voiceService),
        ChangeNotifierProvider.value(value: ttsService),
        ChangeNotifierProvider.value(value: userProgress),
        ChangeNotifierProvider.value(value: SubscriptionService.instance),
      ],
      child: const CatWiseApp(),
    ),
  );
}
