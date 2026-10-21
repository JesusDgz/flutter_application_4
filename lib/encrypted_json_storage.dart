import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

class EncryptedJsonStorage {
  static const String _storagePrefix = 'secure_json_';

  // These values are only suitable for this exercise. Production apps should
  // keep encryption keys in a platform secure store.
  final encrypt.Key _key = encrypt.Key.fromUtf8(
    'my32lengthsupersecretkey12345678',
  );
  final encrypt.IV _iv = encrypt.IV.fromUtf8('1234567890123456');

  String _storageKey(String filename) => '$_storagePrefix$filename';

  Future<void> saveEncryptedJson(
    String filename,
    Map<String, dynamic> data,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedText = _encrypt(jsonEncode(data));
    await prefs.setString(_storageKey(filename), encryptedText);
  }

  Future<Map<String, dynamic>?> readEncryptedJson(String filename) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encryptedText = prefs.getString(_storageKey(filename));

      if (encryptedText == null || encryptedText.isEmpty) return null;

      final decryptedText = _decrypt(encryptedText);
      final decoded = jsonDecode(decryptedText);

      if (decoded is! Map<String, dynamic>) return null;
      return decoded;
    } catch (_) {
      // A corrupt file or an invalid key must not crash the application.
      return null;
    }
  }

  String _encrypt(String plainText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.encrypt(plainText, iv: _iv).base64;
  }

  String _decrypt(String encryptedText) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    return encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
