import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:folder_authenticator/services/config_service.dart';

part 'encryption_service.g.dart';

/// Provider for the EncryptionService
@riverpod
EncryptionService encryptionService(Ref ref) {
  final configService = ref.watch(configServiceProvider);
  return EncryptionService(configService);
}

/// Service for encrypting and decrypting sensitive data
class EncryptionService {
  final ConfigService _configService;
  Encrypter? _encrypter;

  EncryptionService(this._configService);

  /// Initialize the encryption service with the encryption key
  Future<void> initialize() async {
    final key = await _configService.getEncryptionKey();
    final keyBytes = Uint8List.fromList(utf8.encode(key));
    final encryptionKey = Key(keyBytes);
    _encrypter = Encrypter(AES(encryptionKey, mode: AESMode.cbc));
  }

  /// Encrypt a string value
  /// Returns the encrypted value as a base64 string with IV prepended
  Future<String> encrypt(String value) async {
    if (_encrypter == null) {
      await initialize();
    }

    // Handle empty strings specially
    if (value.isEmpty) {
      return ''; // Special marker for empty strings
    }

    // Generate a random IV for each encryption
    final iv = IV.fromSecureRandom(16);
    
    // Encrypt the value
    final encrypted = _encrypter!.encrypt(value, iv: iv);
    
    // Combine IV and encrypted data
    final combined = iv.bytes + encrypted.bytes;
    
    // Return as base64 string
    return base64.encode(combined);
  }

  /// Decrypt a string value
  /// Expects the encrypted value as a base64 string with IV prepended
  Future<String> decrypt(String encryptedValue) async {
    if (_encrypter == null) {
      await initialize();
    }

    // Handle empty strings specially
    if (encryptedValue.isEmpty) {
      return '';
    }

    try {
      // Decode the base64 string
      final bytes = base64.decode(encryptedValue);
      
      // Extract IV (first 16 bytes) and encrypted data
      final iv = IV(Uint8List.fromList(bytes.sublist(0, 16)));
      final encryptedBytes = Encrypted(Uint8List.fromList(bytes.sublist(16)));
      
      // Decrypt the value
      return _encrypter!.decrypt(encryptedBytes, iv: iv);
    } catch (e) {
      // If decryption fails, return the original value
      // This is useful for handling migration from unencrypted to encrypted data
      return encryptedValue;
    }
  }
}
