import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:totp_folder/home/folder/folder_entries_provider.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

@GenerateNiceMocks([
  MockSpec<FolderRepository>(),
  MockSpec<TotpEntryRepository>(),
])
import 'folder_entries_provider_test.mocks.dart';

void main() {
  late ProviderContainer container;
  late FolderRepository mockFolderRepository;
  late TotpEntryRepository mockTotpEntryRepository;

  setUp(() {
    mockFolderRepository = MockFolderRepository();
    mockTotpEntryRepository = MockTotpEntryRepository();

    container = ProviderContainer(
      overrides: [
        folderRepositoryProvider.overrideWithValue(mockFolderRepository),
        totpEntryRepositoryProvider.overrideWithValue(mockTotpEntryRepository),
      ],
    );

    addTearDown(container.dispose);
  });

  group('folderEntriesProvider', () {
    test(
      'should return folder path and entries when data is available',
      () async {
        // Arrange
        final testFolderPath = [
          Folder.rootFolder(),
          Folder(id: 1, name: 'Test Folder', parentId: 0),
        ];
        final testEntries = [
          TotpEntry(
            id: 1,
            name: 'Test Entry',
            secret: 'SECRET',
            issuer: 'Test Issuer',
            folderId: 1,
          ),
        ];

        when(
          mockFolderRepository.getFolderPath(1),
        ).thenAnswer((_) async => testFolderPath);
        when(
          mockTotpEntryRepository.getTotpEntriesByFolderId(1),
        ).thenAnswer((_) async => testEntries);

        // Act
        final result = await container.read(folderEntriesProvider(1).future);

        // Assert
        expect(result.folderPath, testFolderPath);
        expect(result.entries, testEntries);
      },
    );
  });

  group('allFolderEntriesProvider', () {
    test('should return', () async {
      // Arrange
      // Setup parent folder with no entries
      when(
        mockFolderRepository.getFolderPath(0),
      ).thenAnswer((_) async => [Folder.rootFolder()]);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(0),
      ).thenAnswer((_) async => []);

      // Act
      final result = await container.read(allFolderEntriesProvider(0).future);

      // Assert
      expect(result[0].folderPath, [Folder.rootFolder()]);
      expect(result[0].entries, []);
    });

    test('should return parent folder entries when available', () async {
      // Arrange
      final testFolderPath = [Folder.rootFolder()];
      final testEntries = [
        TotpEntry(
          id: 1,
          name: 'Root Entry',
          secret: 'SECRET',
          issuer: 'Test Issuer',
          folderId: 0,
        ),
      ];
      when(
        mockFolderRepository.getFolderPath(0),
      ).thenAnswer((_) async => testFolderPath);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(0),
      ).thenAnswer((_) async => testEntries);

      // Act
      final result = await container.read(allFolderEntriesProvider(0).future);

      // Assert
      expect(result.length, 1);
      expect(result[0].folderPath, testFolderPath);
      expect(result[0].entries, testEntries);
    });

    test('should return entries from parent and subfolders', () async {
      // Arrange
      // Setup parent folder
      final rootFolder = Folder.rootFolder();
      final parentFolderPath = [rootFolder];
      final parentEntries = [
        TotpEntry(
          id: 1,
          name: 'Root Entry',
          secret: 'SECRET1',
          issuer: 'Test Issuer',
          folderId: 0,
        ),
      ];

      // Setup subfolder
      final subfolder = Folder(
        id: 1,
        name: 'Subfolder',
        parentId: Folder.rootFolderId,
      );
      final subfolderPath = [rootFolder, subfolder];
      final subfolderEntries = [
        TotpEntry(
          id: 2,
          name: 'Subfolder Entry',
          secret: 'SECRET2',
          issuer: 'Test Issuer',
          folderId: 1,
        ),
      ];

      // Mock parent folder data
      when(
        mockFolderRepository.getFolderPath(0),
      ).thenAnswer((_) async => parentFolderPath);
      when(
        mockFolderRepository.getFolders(0),
      ).thenAnswer((_) async => [subfolder]);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(0),
      ).thenAnswer((_) async => parentEntries);
      // Mock subfolder data
      when(
        mockFolderRepository.getFolderPath(1),
      ).thenAnswer((_) async => subfolderPath);
      when(mockFolderRepository.getFolders(1)).thenAnswer((_) async => []);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(1),
      ).thenAnswer((_) async => subfolderEntries);

      // Act
      final result = await container.read(allFolderEntriesProvider(0).future);

      // Assert
      expect(result.length, 2);

      // Check parent folder entries
      expect(result[0].folderPath, parentFolderPath);
      expect(result[0].entries, parentEntries);

      // Check subfolder entries
      expect(result[1].folderPath, subfolderPath);
      expect(result[1].entries, subfolderEntries);
    });

    test('should not skip folders with no entries', () async {
      // Arrange
      // Setup parent folder with entries
      final rootFolder = Folder.rootFolder();
      final parentFolderPath = [rootFolder];
      final parentEntries = [
        TotpEntry(
          id: 1,
          name: 'Root Entry',
          secret: 'SECRET1',
          issuer: 'Test Issuer',
          folderId: Folder.rootFolderId,
        ),
      ];

      // Setup subfolder with no entries
      final subfolder = Folder(
        id: 1,
        name: 'Empty Subfolder',
        parentId: rootFolder.id,
      );
      final subfolderPath = [rootFolder, subfolder];
      final subfolderEntries = <TotpEntry>[];

      // Mock parent folder data
      when(
        mockFolderRepository.getFolderPath(0),
      ).thenAnswer((_) async => parentFolderPath);
      when(
        mockFolderRepository.getFolders(0),
      ).thenAnswer((_) async => [subfolder]);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(0),
      ).thenAnswer((_) async => parentEntries);

      // Mock subfolders list
      when(
        mockFolderRepository.getFolderPath(1),
      ).thenAnswer((_) async => subfolderPath);
      when(mockFolderRepository.getFolders(1)).thenAnswer((_) async => []);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(1),
      ).thenAnswer((_) async => subfolderEntries);

      // Act
      final result = await container.read(allFolderEntriesProvider(0).future);

      // Assert
      expect(result.length, 2);
      expect(result[0].folderPath, parentFolderPath);
      expect(result[0].entries, parentEntries);
      expect(result[1].folderPath, subfolderPath);
      expect(result[1].entries, subfolderEntries);
    });
  });
}
