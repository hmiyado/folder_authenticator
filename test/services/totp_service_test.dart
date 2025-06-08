import 'package:flutter_test/flutter_test.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/services/totp_service.dart';

void main() {
  group('TotpService', () {
    late TotpService totpService;

    setUp(() {
      totpService = TotpService();
    });

    group('parseTotpUri', () {
      test('should correctly parse a standard TOTP URI', () {
        // Arrange
        final uri =
            'otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example&algorithm=SHA1&digits=6&period=30';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNotNull);
        expect(result!['name'], equals('alice@example.com'));
        expect(result['secret'], equals('JBSWY3DPEHPK3PXP'));
        expect(result['issuer'], equals('Example'));
        expect(result['algorithm'], equals('SHA1'));
        expect(result['digits'], equals(6));
        expect(result['period'], equals(30));
      });

      test('should correctly parse a URI with label containing issuer', () {
        // Arrange
        final uri =
            'otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNotNull);
        expect(result!['name'], equals('alice@example.com'));
        expect(result['secret'], equals('JBSWY3DPEHPK3PXP'));
        expect(result['issuer'], equals('Example'));
        expect(result['algorithm'], equals('SHA1')); // Default
        expect(result['digits'], equals(6)); // Default
        expect(result['period'], equals(30)); // Default
      });

      test('should correctly parse a URI with issuer in query params', () {
        // Arrange
        final uri =
            'otpauth://totp/alice@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNotNull);
        expect(result!['name'], equals('alice@example.com'));
        expect(result['secret'], equals('JBSWY3DPEHPK3PXP'));
        expect(result['issuer'], equals('Example'));
      });

      test('should correctly parse a URI with non-default parameters', () {
        // Arrange
        final uri =
            'otpauth://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP&algorithm=SHA256&digits=8&period=60';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNotNull);
        expect(result!['algorithm'], equals('SHA256'));
        expect(result['digits'], equals(8));
        expect(result['period'], equals(60));
      });

      test('should return null for invalid scheme', () {
        // Arrange
        final uri =
            'invalid://totp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNull);
      });

      test('should return null for invalid host', () {
        // Arrange
        final uri =
            'otpauth://hotp/Example:alice@example.com?secret=JBSWY3DPEHPK3PXP';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNull);
      });

      test('should return null for missing secret', () {
        // Arrange
        final uri = 'otpauth://totp/Example:alice@example.com';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNull);
      });

      test('should return null for empty path', () {
        // Arrange
        final uri = 'otpauth://totp/?secret=JBSWY3DPEHPK3PXP';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNull);
      });

      test('should handle malformed URI gracefully', () {
        // Arrange
        final uri = 'not a valid uri';

        // Act
        final result = totpService.parseTotpUri(uri);

        // Assert
        expect(result, isNull);
      });
    });
    
    group('generateOtpauthUri', () {
      test('should generate correct URI with issuer', () {
        // Arrange
        final totpEntry = TotpEntry(
          id: 1,
          name: 'Test Account',
          secret: 'ABCDEFGHIJKLMNOP',
          issuer: 'Test Issuer',
          folderId: 1,
          digits: 6,
          period: 30,
          algorithm: 'SHA1',
        );

        // Expected URI format:
        // otpauth://totp/{issuer}:{name}?secret={secret}&issuer={issuer}&algorithm={algorithm}&digits={digits}&period={period}
        final expectedUri = 'otpauth://totp/Test%20Issuer:Test%20Account?'
            'secret=ABCDEFGHIJKLMNOP'
            '&issuer=Test%20Issuer'
            '&algorithm=SHA1'
            '&digits=6'
            '&period=30';

        // Act
        final uri = totpService.generateOtpauthUri(totpEntry);

        // Assert
        expect(uri, equals(expectedUri));
      });

      test('should generate correct URI without issuer', () {
        // Arrange
        final totpEntry = TotpEntry(
          id: 1,
          name: 'Test Account',
          secret: 'ABCDEFGHIJKLMNOP',
          issuer: '', // Empty issuer
          folderId: 1,
          digits: 6,
          period: 30,
          algorithm: 'SHA1',
        );

        // Expected URI format without issuer in label:
        // otpauth://totp/{name}?secret={secret}&issuer={issuer}&algorithm={algorithm}&digits={digits}&period={period}
        final expectedUri = 'otpauth://totp/Test%20Account?'
            'secret=ABCDEFGHIJKLMNOP'
            '&issuer='
            '&algorithm=SHA1'
            '&digits=6'
            '&period=30';

        // Act
        final uri = totpService.generateOtpauthUri(totpEntry);

        // Assert
        expect(uri, equals(expectedUri));
      });

      test('should handle special characters in name and issuer', () {
        // Arrange
        final totpEntry = TotpEntry(
          id: 1,
          name: 'Test & Account+',
          secret: 'ABCDEFGHIJKLMNOP',
          issuer: 'Test & Issuer+',
          folderId: 1,
          digits: 6,
          period: 30,
          algorithm: 'SHA1',
        );

        // Expected URI with encoded special characters
        final expectedUri = 'otpauth://totp/Test%20%26%20Issuer%2B:Test%20%26%20Account%2B?'
            'secret=ABCDEFGHIJKLMNOP'
            '&issuer=Test%20%26%20Issuer%2B'
            '&algorithm=SHA1'
            '&digits=6'
            '&period=30';

        // Act
        final uri = totpService.generateOtpauthUri(totpEntry);

        // Assert
        expect(uri, equals(expectedUri));
      });

      test('should handle non-default parameters', () {
        // Arrange
        final totpEntry = TotpEntry(
          id: 1,
          name: 'Test Account',
          secret: 'ABCDEFGHIJKLMNOP',
          issuer: 'Test Issuer',
          folderId: 1,
          digits: 8, // Non-default
          period: 60, // Non-default
          algorithm: 'SHA256', // Non-default
        );

        // Expected URI with non-default parameters
        final expectedUri = 'otpauth://totp/Test%20Issuer:Test%20Account?'
            'secret=ABCDEFGHIJKLMNOP'
            '&issuer=Test%20Issuer'
            '&algorithm=SHA256'
            '&digits=8'
            '&period=60';

        // Act
        final uri = totpService.generateOtpauthUri(totpEntry);

        // Assert
        expect(uri, equals(expectedUri));
      });
    });
  });
}
