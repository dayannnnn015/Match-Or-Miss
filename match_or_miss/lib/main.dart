// ============================================================================
// MAIN APPLICATION ENTRY POINT
// ============================================================================
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
  ai_svc.AIProvider savedProvider = ai_svc.AIProvider.grok;

  // Priority 1: env.json build-time keys (most reliable — always use these first)
  const grokBuildKey   = String.fromEnvironment('GROK_API_KEY',   defaultValue: '');
  const geminiBuiltKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  const openAIBuiltKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');

  if (grokBuildKey.isNotEmpty) {
    savedKey = grokBuildKey;
    savedProvider = ai_svc.AIProvider.grok;
  } else if (geminiBuiltKey.isNotEmpty) {
    savedKey = geminiBuiltKey;
    savedProvider = ai_svc.AIProvider.googleGemini;
  } else if (openAIBuiltKey.isNotEmpty) {
    savedKey = openAIBuiltKey;
    savedProvider = ai_svc.AIProvider.openAI;
  }

  // Priority 2: keys saved via in-app dialog (only used if no env.json key found)
  if (savedKey == null || savedKey.isEmpty) {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final grokStored = prefs.getString('grok_api_key');
      final geminiStored = prefs.getString('gemini_api_key');
      final openaiStored = prefs.getString('openai_api_key');
      if (grokStored != null && grokStored.isNotEmpty) {
        savedKey = grokStored; savedProvider = ai_svc.AIProvider.grok;
      } else if (geminiStored != null && geminiStored.isNotEmpty) {
        savedKey = geminiStored; savedProvider = ai_svc.AIProvider.googleGemini;
      } else if (openaiStored != null && openaiStored.isNotEmpty) {
        savedKey = openaiStored; savedProvider = ai_svc.AIProvider.openAI;
      }
    } else {
      final grokStored   = await SecureStorageService.getAPIKey('grok');
      final geminiStored = await SecureStorageService.getAPIKey('gemini');
      final openaiStored = await SecureStorageService.getAPIKey('openai');
      if (grokStored != null && grokStored.isNotEmpty) {
        savedKey = grokStored; savedProvider = ai_svc.AIProvider.grok;
      } else if (geminiStored != null && geminiStored.isNotEmpty) {
        savedKey = geminiStored; savedProvider = ai_svc.AIProvider.googleGemini;
      } else if (openaiStored != null && openaiStored.isNotEmpty) {
        savedKey = openaiStored; savedProvider = ai_svc.AIProvider.openAI;
      }
    }
  }

  print(savedKey != null && savedKey.isNotEmpty
      ? '🤖 AI ready — provider: ${savedProvider.name}'
      : '⚠️ No AI key found — local fallback active');

  runApp(MyApp(initialApiKey: savedKey ?? '', initialProvider: savedProvider));
}

class MyApp extends StatelessWidget {
  final String initialApiKey;
  final ai_svc.AIProvider initialProvider;
  const MyApp({
    super.key,
    required this.initialApiKey,
    required this.initialProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GameProvider(
            initialApiKey: initialApiKey,
            initialProvider: initialProvider,
          ),
        ),
        ChangeNotifierProvider(create: (_) => MultiplayerProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
      ],
      child: MaterialApp(
        title: 'NEBULA CODE',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            secondary: Color(0xFFFF6584),
            surface: Color(0xFF1A1A2E),
            background: Color(0xFF0F0F1A),
            tertiary: Color(0xFF00D2FF),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F1A),
          fontFamily: 'Poppins',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            elevation: 0,
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}