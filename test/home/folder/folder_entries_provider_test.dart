import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folder_authenticator/home/folder/folder_entries_provider.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/repositories/folder_repository.dart';
import 'package:folder_authenticator/repositories/totp_entry_repository.dart';

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
          Folder(id: Folder.rootFolderId, name: 'Root', parentId: Folder.rootFolderId),
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
      final rootFolder = Folder(id: Folder.rootFolderId, name: 'Root', parentId: Folder.rootFolderId);
      // Setup parent folder with no entries
      when(
        mockFolderRepository.getFolderPath(0),
      ).thenAnswer((_) async => [rootFolder]);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(0),
      ).thenAnswer((_) async => []);

      // Act
      final result = await container.read(allFolderEntriesProvider(0).future);

      // Assert
      expect(result[0].folderPath, [rootFolder]);
      expect(result[0].entries, []);
    });

    test('should return parent folder entries when available', () async {
      // Arrange
      final rootFolder = Folder(id: Folder.rootFolderId, name: 'Root', parentId: Folder.rootFolderId);
      final testFolderPath = [rootFolder];
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
      final rootFolder = Folder(id: Folder.rootFolderId, name: 'Root', parentId: Folder.rootFolderId);
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

    test('should return entries recursively from nested subfolders', () async {
      // Arrange
      // Folder tree
      // Root
      // ├── Subfolder 1
      // │   ├── Subfolder 2
      // │   │   └── Nested Entry
      // │   └── Subfolder1 Entry
      // └── Root Entry
      // Setup root folder
      final rootFolder = Folder(id: Folder.rootFolderId, name: 'Root', parentId: Folder.rootFolderId);
      final rootFolderPath = [rootFolder];
      final rootEntries = [
        TotpEntry(
          id: 1,
          name: 'Root Entry',
          secret: 'SECRET1',
          issuer: 'Test Issuer',
          folderId: 0,
        ),
      ];

      // Setup first level subfolder
      final subfolder1 = Folder(
        id: 1,
        name: 'Subfolder 1',
        parentId: Folder.rootFolderId,
      );
      final subfolder1Path = [rootFolder, subfolder1];
      final subfolder1Entries = [
        TotpEntry(
          id: 2,
          name: 'Subfolder1 Entry',
          secret: 'SECRET2',
          issuer: 'Test Issuer',
          folderId: 1,
        ),
      ];

      // Setup second level subfolder (nested)
      final subfolder2 = Folder(id: 2, name: 'Subfolder 2', parentId: 1);
      final subfolder2Path = [rootFolder, subfolder1, subfolder2];
      final subfolder2Entries = [
        TotpEntry(
          id: 3,
          name: 'Nested Entry',
          secret: 'SECRET3',
          issuer: 'Test Issuer',
          folderId: 2,
        ),
      ];

      // Mock root folder data
      when(
        mockFolderRepository.getFolderPath(0),
      ).thenAnswer((_) async => rootFolderPath);
      when(
        mockFolderRepository.getFolders(0),
      ).thenAnswer((_) async => [subfolder1]);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(0),
      ).thenAnswer((_) async => rootEntries);

      // Mock first level subfolder data
      when(
        mockFolderRepository.getFolderPath(1),
      ).thenAnswer((_) async => subfolder1Path);
      when(
        mockFolderRepository.getFolders(1),
      ).thenAnswer((_) async => [subfolder2]);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(1),
      ).thenAnswer((_) async => subfolder1Entries);

      // Mock second level subfolder data
      when(
        mockFolderRepository.getFolderPath(2),
      ).thenAnswer((_) async => subfolder2Path);
      when(mockFolderRepository.getFolders(2)).thenAnswer((_) async => []);
      when(
        mockTotpEntryRepository.getTotpEntriesByFolderId(2),
      ).thenAnswer((_) async => subfolder2Entries);

      // Act
      final result = await container.read(allFolderEntriesProvider(0).future);

      // Assert
      expect(result.length, 3);

      // Check root folder entries
      expect(result[0].folderPath, rootFolderPath);
      expect(result[0].entries, rootEntries);

      // Check first level subfolder entries
      expect(result[1].folderPath, subfolder1Path);
      expect(result[1].entries, subfolder1Entries);

      // Check second level (nested) subfolder entries
      expect(result[2].folderPath, subfolder2Path);
      expect(result[2].entries, subfolder2Entries);
    });

    test('should not skip folders with no entries', () async {
      // Arrange
      // Setup parent folder with entries
      final rootFolder = Folder(id: Folder.rootFolderId, name: 'Root', parentId: Folder.rootFolderId);
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
