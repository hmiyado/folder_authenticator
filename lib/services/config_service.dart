import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'config_service.g.dart';

/// Provider for the ConfigService
@riverpod
ConfigService configService(Ref ref) {
  return ConfigService();
}

/// Service for managing application configuration and secrets
class ConfigService {
  static const String _encryptionKeyEnvVar = 'ENCRYPTION_KEY';
  static const String _encryptionKeyStorageKey = 'encryption_key';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? _encryptionKey;

  /// Initialize the config service and load encryption key
  Future<void> initialize() async {
    await _loadEncryptionKey();
  }

  /// Get the encryption key for TOTP secrets
  Future<String> getEncryptionKey() async {
    if (_encryptionKey == null) {
      await _loadEncryptionKey();
    }
    return _encryptionKey!;
  }

  /// Load the encryption key from environment variables or secure storage
  Future<void> _loadEncryptionKey() async {
    // First try to get from environment variables (build-time config)
    String? key = _getEnvVar(_encryptionKeyEnvVar);
    
    // If not found in environment, try secure storage (for previously generated keys)
    if (key == null || key.isEmpty) {
      key = await _secureStorage.read(key: _encryptionKeyStorageKey);
    }
    
    // If still not found, generate a new key and store it
    if (key == null || key.isEmpty) {
      if (kDebugMode) {
        print('Warning: No encryption key found. Using default development key.');
        // Use a default key for development only
        key = '01234567890123456789012345678901';
      } else {
        throw Exception('No encryption key found. Please set the ENCRYPTION_KEY environment variable.');
      }
    }
    
    _encryptionKey = key;
    
    // Store the key in secure storage for future use
    await _secureStorage.write(key: _encryptionKeyStorageKey, value: key);
  }

  /// Read an environment variable from .env file or platform environment
  String? _getEnvVar(String name) {
    // Try to read from platform environment variables first
    String? value = Platform.environment[name];
    
    // If not found, try to read from .env file
    if (value == null || value.isEmpty) {
      try {
        final envFile = File('.env');
        if (envFile.existsSync()) {
          final lines = envFile.readAsLinesSync();
          for (final line in lines) {
            if (line.trim().startsWith('#') || !line.contains('=')) continue;
            
            final parts = line.split('=');
            if (parts.length >= 2 && parts[0].trim() == name) {
              value = parts.sublist(1).join('=').trim();
              break;
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error reading .env file: $e');
        }
      }
    }
    
    return value;
  }
}
