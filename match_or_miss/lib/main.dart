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
  ai_svc.AIProvider savedProvider = ai_svc.AIProvider.openAI;

  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    savedKey = prefs.getString('openai_api_key');
    if (savedKey != null && savedKey.isNotEmpty) {
      savedProvider = ai_svc.AIProvider.openAI;
    } else {
      savedKey = prefs.getString('gemini_api_key');
      if (savedKey != null && savedKey.isNotEmpty) {
        savedProvider = ai_svc.AIProvider.googleGemini;
      }
    }
  } else {
    savedKey = await SecureStorageService.getAPIKey('openai');
    if (savedKey != null && savedKey.isNotEmpty) {
      savedProvider = ai_svc.AIProvider.openAI;
    } else {
      savedKey = await SecureStorageService.getAPIKey('gemini');
      if (savedKey != null && savedKey.isNotEmpty) {
        savedProvider = ai_svc.AIProvider.googleGemini;
      }
    }

    if (savedKey == null || savedKey.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      savedKey = prefs.getString('openai_api_key');
      if (savedKey != null && savedKey.isNotEmpty) {
        savedProvider = ai_svc.AIProvider.openAI;
      } else {
        savedKey = prefs.getString('gemini_api_key');
        if (savedKey != null && savedKey.isNotEmpty) {
          savedProvider = ai_svc.AIProvider.googleGemini;
        }
      }
    }
  }

  if (savedKey == null || savedKey.isEmpty) {
    const openAIBuildTimeKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
    if (openAIBuildTimeKey.isNotEmpty) {
      savedKey = openAIBuildTimeKey;
      savedProvider = ai_svc.AIProvider.openAI;
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('openai_api_key', openAIBuildTimeKey);
      } else {
        await SecureStorageService.saveAPIKey('openai', openAIBuildTimeKey);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('openai_api_key', openAIBuildTimeKey);
      }
    }
  }

  if (savedKey == null || savedKey.isEmpty) {
    const buildTimeKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
    if (buildTimeKey.isNotEmpty) {
      savedKey = buildTimeKey;
      savedProvider = ai_svc.AIProvider.googleGemini;
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