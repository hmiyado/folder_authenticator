import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folder_authenticator/services/config_service.dart';
import 'package:folder_authenticator/services/encryption_service.dart';

// Generate a MockConfigService using Mockito
@GenerateMocks([ConfigService])
import 'encryption_service_test.mocks.dart';

void main() {
  group('EncryptionService', () {
    late EncryptionService encryptionService;
    late MockConfigService mockConfigService;

    setUp(() {
      mockConfigService = MockConfigService();
      when(mockConfigService.getEncryptionKey()).thenAnswer(
        (_) async => '01234567890123456789012345678901', // 32-character test key
      );
      encryptionService = EncryptionService(mockConfigService);
    });

    test('should encrypt and decrypt a string correctly', () async {
      // Arrange
      const originalText = 'ABCDEFGHIJKLMNOP'; // Sample TOTP secret
      
      // Act
      await encryptionService.initialize();
      final encrypted = await encryptionService.encrypt(originalText);
      final decrypted = await encryptionService.decrypt(encrypted);
      
      // Assert
      expect(encrypted, isNot(equals(originalText))); // Encrypted text should be different
      expect(decrypted, equals(originalText)); // Decrypted text should match original
    });

    test('should generate different encrypted values for the same input', () async {
      // Arrange
      const originalText = 'ABCDEFGHIJKLMNOP'; // Sample TOTP secret
      
      // Act
      await encryptionService.initialize();
      final encrypted1 = await encryptionService.encrypt(originalText);
      final encrypted2 = await encryptionService.encrypt(originalText);
      
      // Assert
      expect(encrypted1, isNot(equals(encrypted2))); // Each encryption should be unique (due to IV)
    });

    test('should handle empty strings', () async {
      // Arrange
      const originalText = '';
      
      // Act
      await encryptionService.initialize();
      final encrypted = await encryptionService.encrypt(originalText);
      final decrypted = await encryptionService.decrypt(encrypted);
      
      // Assert
      expect(decrypted, equals(originalText));
    });

    test('should handle special characters', () async {
      // Arrange
      const originalText = 'A!@#\$%^&*()_+{}:"<>?~';
      
      // Act
      await encryptionService.initialize();
      final encrypted = await encryptionService.encrypt(originalText);
      final decrypted = await encryptionService.decrypt(encrypted);
      
      // Assert
      expect(decrypted, equals(originalText));
    });

    test('should return original string when decryption fails', () async {
      // Arrange
      const invalidEncrypted = 'not-a-valid-encrypted-string';
      
      // Act
      await encryptionService.initialize();
      final result = await encryptionService.decrypt(invalidEncrypted);
      
      // Assert
      expect(result, equals(invalidEncrypted)); // Should return the original string
    });
  });
}
