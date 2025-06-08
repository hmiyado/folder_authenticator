import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/repositories/totp_entry_repository.dart';
import 'package:folder_authenticator/services/database_service.dart';

// Generate a MockDatabaseService using Mockito
@GenerateMocks([DatabaseService])
import 'totp_entry_repository_test.mocks.dart';

void main() {
  late TotpEntryRepository totpEntryRepository;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    totpEntryRepository = TotpEntryRepository(mockDatabaseService);
  });

  group('TotpEntryRepository', () {
    final testTotpEntry = TotpEntry(
      id: 1,
      name: 'Test Entry',
      secret: 'ABCDEFGHIJKLMNOP',
      issuer: 'Test Issuer',
      folderId: 1,
    );

    test(
      'getTotpEntriesByFolderId should return entries from database service',
      () async {
        // Arrange
        when(
          mockDatabaseService.getTotpEntries(folderId: 1),
        ).thenAnswer((_) async => [testTotpEntry]);

        // Act
        final result = await totpEntryRepository.getTotpEntriesByFolderId(1);

        // Assert
        expect(result, [testTotpEntry]);
        verify(mockDatabaseService.getTotpEntries(folderId: 1)).called(1);
      },
    );

    test('getTotpEntry should return an entry from database service', () async {
      // Arrange
      when(
        mockDatabaseService.getTotpEntry(1),
      ).thenAnswer((_) async => testTotpEntry);

      // Act
      final result = await totpEntryRepository.getTotpEntry(1);

      // Assert
      expect(result, testTotpEntry);
      verify(mockDatabaseService.getTotpEntry(1)).called(1);
    });

    test(
      'createTotpEntry should insert entry and return with new id',
      () async {
        // Arrange
        final entryToCreate = TotpEntry(
          id: 1,
          name: 'New Entry',
          secret: 'QRSTUVWXYZ123456',
          issuer: 'New Issuer',
          folderId: 2,
        );
        when(
          mockDatabaseService.insertTotpEntry(
            any,
            any,
            any,
            any,
            any,
            any,
            any,
          ),
        ).thenAnswer((_) async => 3);

        // Act
        await totpEntryRepository.createTotpEntry(
          entryToCreate.name,
          entryToCreate.secret,
          entryToCreate.issuer,
          entryToCreate.digits,
          entryToCreate.period,
          entryToCreate.algorithm,
          entryToCreate.folderId,
        );

        // Assert
        verify(
          mockDatabaseService.insertTotpEntry(
            entryToCreate.name,
            entryToCreate.secret,
            entryToCreate.issuer,
            entryToCreate.digits,
            entryToCreate.period,
            entryToCreate.algorithm,
            entryToCreate.folderId,
          ),
        ).called(1);
      },
    );

    test('updateTotpEntry should update entry and return success', () async {
      // Arrange
      when(
        mockDatabaseService.updateTotpEntry(
          testTotpEntry.id,
          testTotpEntry.name,
          testTotpEntry.issuer,
          testTotpEntry.folderId,
          any,
        ),
      ).thenAnswer((_) async => 1);

      // Act
      final result = await totpEntryRepository.updateTotpEntry(
        testTotpEntry.id,
        testTotpEntry.name,
        testTotpEntry.issuer,
        testTotpEntry.folderId,
      );

      // Assert
      expect(result, true);
      verify(
        mockDatabaseService.updateTotpEntry(
          testTotpEntry.id,
          testTotpEntry.name,
          testTotpEntry.issuer,
          testTotpEntry.folderId,
          any,
        ),
      ).called(1);
    });

    test('updateTotpEntry should return false when no rows affected', () async {
      // Arrange
      when(
        mockDatabaseService.updateTotpEntry(
          testTotpEntry.id,
          testTotpEntry.name,
          testTotpEntry.issuer,
          testTotpEntry.folderId,
          any,
        ),
      ).thenAnswer((_) async => 0);

      // Act
      final result = await totpEntryRepository.updateTotpEntry(
        testTotpEntry.id,
        testTotpEntry.name,
        testTotpEntry.issuer,
        testTotpEntry.folderId,
      );

      // Assert
      expect(result, false);
      verify(
        mockDatabaseService.updateTotpEntry(
          testTotpEntry.id,
          testTotpEntry.name,
          testTotpEntry.issuer,
          testTotpEntry.folderId,
          any,
        ),
      ).called(1);
    });

    test('deleteTotpEntry should delete entry and return success', () async {
      // Arrange
      when(mockDatabaseService.deleteTotpEntry(1)).thenAnswer((_) async => 1);

      // Act
      final result = await totpEntryRepository.deleteTotpEntry(1);

      // Assert
      expect(result, true);
      verify(mockDatabaseService.deleteTotpEntry(1)).called(1);
    });

    test('deleteTotpEntry should return false when no rows affected', () async {
      // Arrange
      when(mockDatabaseService.deleteTotpEntry(1)).thenAnswer((_) async => 0);

      // Act
      final result = await totpEntryRepository.deleteTotpEntry(1);

      // Assert
      expect(result, false);
      verify(mockDatabaseService.deleteTotpEntry(1)).called(1);
    });
  });
}
