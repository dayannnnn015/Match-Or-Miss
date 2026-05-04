// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform; // Added for complete structure

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // This part of the code determines which platform your Flutter app is running on
    // and returns the corresponding Firebase options.
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios; // Placeholder, you'd need to configure this for iOS as well
      case TargetPlatform.macOS:
        return macos; // Placeholder
      case TargetPlatform.windows:
        return windows; // Placeholder
      case TargetPlatform.linux:
        return linux; // Placeholder
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Configuration for your Android app based on your project details
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY', // You need to obtain this from Firebase Console
    appId: '1:269061882766:android:709e496ab6a357e59cdadf', // Provided in your snippet
    messagingSenderId: '269061882766', // Your Project Number
    projectId: 'match-or-miss-game', // Your Project ID
    // These might be optional depending on the Firebase services you use,
    // but are usually included for a complete configuration.
    authDomain: 'match-or-miss-game.firebaseapp.com', // Typically derived from Project ID
    databaseURL: 'https://match-or-miss-game.firebaseio.com', // Typically derived from Project ID
    storageBucket: 'match-or-miss-game.appspot.com', // Typically derived from Project ID
  );

  // You would define similar FirebaseOptions for other platforms if your Flutter app supports them
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY', // Obtain from Firebase Console
    appId: 'YOUR_IOS_APP_ID', // Obtain from Firebase Console
    messagingSenderId: '269061882766',
    projectId: 'match-or-miss-game',
    authDomain: 'match-or-miss-game.firebaseapp.com',
    databaseURL: 'https://match-or-miss-game.firebaseio.com',
    storageBucket: 'match-or-miss-game.appspot.com',
    iosClientId: 'YOUR_IOS_CLIENT_ID', // Required for Google Sign-In on iOS
    iosBundleId: 'com.game.match_or_miss', // Your Bundle ID
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY', // Obtain from Firebase Console
    appId: 'YOUR_WEB_APP_ID', // Obtain from Firebase Console
    messagingSenderId: '269061882766',
    projectId: 'match-or-miss-game',
    authDomain: 'match-or-miss-game.firebaseapp.com',
    databaseURL: 'https://match-or-miss-game.firebaseio.com',
    storageBucket: 'match-or-miss-game.appspot.com',
    measurementId: 'YOUR_MEASUREMENT_ID', // If using Google Analytics for Web
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: '269061882766',
    projectId: 'match-or-miss-game',
    authDomain: 'match-or-miss-game.firebaseapp.com',
    databaseURL: 'https://match-or-miss-game.firebaseio.com',
    storageBucket: 'match-or-miss-game.appspot.com',
    iosClientId: 'YOUR_MACOS_CLIENT_ID', // macOS often uses iOS client IDs
    iosBundleId: 'com.game.match_or_miss', // Your Bundle ID
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'YOUR_WINDOWS_API_KEY',
    appId: 'YOUR_WINDOWS_APP_ID',
    messagingSenderId: '269061882766',
    projectId: 'match-or-miss-game',
    authDomain: 'match-or-miss-game.firebaseapp.com',
    databaseURL: 'https://match-or-miss-game.firebaseio.com',
    storageBucket: 'match-or-miss-game.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'YOUR_LINUX_API_KEY',
    appId: 'YOUR_LINUX_APP_ID',
    messagingSenderId: '269061882766',
    projectId: 'match-or-miss-game',
    authDomain: 'match-or-miss-game.firebaseapp.com',
    databaseURL: 'https://match-or-miss-game.firebaseio.com',
    storageBucket: 'match-or-miss-game.appspot.com',
  );
}
