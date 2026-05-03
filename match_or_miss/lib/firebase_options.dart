// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Replace with your actual Firebase configuration
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: '1:269061882766:android:709e496ab6a357e59cdadf',
      messagingSenderId: '269061882766',
      projectId: 'match-or-miss-game',
      authDomain: 'YOUR_AUTH_DOMAIN',
      databaseURL: 'YOUR_DATABASE_URL',
      storageBucket: 'YOUR_STORAGE_BUCKET',
    );
  }
}