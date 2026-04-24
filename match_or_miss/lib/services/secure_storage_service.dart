// lib/services/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static Future<void> saveAPIKey(String provider, String key) async {
    await _storage.write(key: 'api_key_$provider', value: key);
  }
  
  static Future<String?> getAPIKey(String provider) async {
    return await _storage.read(key: 'api_key_$provider');
  }
  
  static Future<void> deleteAPIKey(String provider) async {
    await _storage.delete(key: 'api_key_$provider');
  }
  
  static Future<bool> hasAPIKey(String provider) async {
    final key = await getAPIKey(provider);
    return key != null && key.isNotEmpty;
  }
}