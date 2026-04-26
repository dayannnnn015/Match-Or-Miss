// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/multiplayer_provider.dart';
import 'providers/ai_provider.dart';
import 'screens/splash_screen.dart';
import 'services/openai_service.dart' as ai_svc;
import 'services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? savedKey;

  if (kIsWeb) {
    // Web: use shared_preferences (browser localStorage)
    final prefs = await SharedPreferences.getInstance();
    savedKey = prefs.getString('gemini_api_key');
  } else {
    // Mobile: use flutter_secure_storage (encrypted keychain/keystore)
    savedKey = await SecureStorageService.getAPIKey('gemini');
    // Also check shared_preferences as fallback
    if (savedKey == null || savedKey.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      savedKey = prefs.getString('gemini_api_key');
    }
  }

  // Fall back to build-time --dart-define key
  if (savedKey == null || savedKey.isEmpty) {
    const buildTimeKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (buildTimeKey.isNotEmpty) {
      savedKey = buildTimeKey;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gemini_api_key', buildTimeKey);
      } else {
        await SecureStorageService.saveAPIKey('gemini', buildTimeKey);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('gemini_api_key', buildTimeKey);
      }
    }
  }

  // ── DEV ONLY: hardcoded fallback so key always works on Chrome ──────────
  // Remove this block before publishing your app!
  if (savedKey == null || savedKey.isEmpty) {
    savedKey = 'AIzaSyBirbgvTFvrqXfozk36HfBqqN_qOKXpTRo';
  }
  // ────────────────────────────────────────────────────────────────────────

  runApp(MyApp(initialApiKey: savedKey ?? ''));
}

class MyApp extends StatelessWidget {
  final String initialApiKey;
  const MyApp({super.key, required this.initialApiKey});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameProvider(initialApiKey: initialApiKey),
        ),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
      ],
      child: MaterialApp(
        title: 'Match or Miss',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}