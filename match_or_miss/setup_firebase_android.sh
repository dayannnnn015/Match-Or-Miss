#!/bin/bash
set -euo pipefail

echo "Setting up Firebase for Match or Miss Android (Kotlin DSL)"

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
ANDROID_SETTINGS="$ROOT_DIR/android/settings.gradle.kts"
ANDROID_APP_GRADLE="$ROOT_DIR/android/app/build.gradle.kts"
GOOGLE_SERVICES_JSON="$ROOT_DIR/android/app/google-services.json"

echo "1) Validating required Android Gradle files..."
if [[ ! -f "$ANDROID_SETTINGS" ]]; then
	echo "Error: Missing android/settings.gradle.kts"
	exit 1
fi
if [[ ! -f "$ANDROID_APP_GRADLE" ]]; then
	echo "Error: Missing android/app/build.gradle.kts"
	exit 1
fi

echo "2) Verifying Firebase plugin configuration..."
if ! grep -q 'com.google.gms.google-services' "$ANDROID_SETTINGS"; then
	echo "Error: com.google.gms.google-services plugin version is missing in android/settings.gradle.kts"
	exit 1
fi
if ! grep -q 'com.google.gms.google-services' "$ANDROID_APP_GRADLE"; then
	echo "Error: com.google.gms.google-services plugin is not applied in android/app/build.gradle.kts"
	exit 1
fi

echo "3) Verifying Firebase dependencies..."
if ! grep -q 'com.google.firebase:firebase-bom' "$ANDROID_APP_GRADLE"; then
	echo "Error: Firebase BoM is missing in android/app/build.gradle.kts"
	exit 1
fi

echo "4) Checking google-services.json..."
if [[ ! -f "$GOOGLE_SERVICES_JSON" ]]; then
	echo "Warning: android/app/google-services.json not found."
	echo "Download it from Firebase Console and place it at android/app/google-services.json"
fi

echo "5) Cleaning Android build..."
cd "$ROOT_DIR/android"
if [[ -x "./gradlew" ]]; then
	./gradlew clean
elif [[ -f "./gradlew.bat" ]]; then
	./gradlew.bat clean
else
	echo "Error: No Gradle wrapper found in android/."
	exit 1
fi

echo "6) Getting Flutter packages..."
cd "$ROOT_DIR"
flutter pub get

echo "Setup complete. Run 'flutter run' to test."
