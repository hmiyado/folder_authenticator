import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/repositories/folder_repository.dart';
import 'package:folder_authenticator/services/database_service.dart';

// Generate a MockDatabaseService using Mockito
@GenerateMocks([DatabaseService])
import 'folder_repository_test.mocks.dart';

void main() {
  late FolderRepository folderRepository;
  late MockDatabaseService mockDatabaseService;

  setUp(() {
    mockDatabaseService = MockDatabaseService();
    folderRepository = FolderRepository(mockDatabaseService);
  });

  group('FolderRepository', () {
    final testFolder = Folder(
      id: 1,
      name: 'Test Folder',
      icon: '',
      parentId: 0,
    );

    final testChildFolder = Folder(
      id: 2,
      name: 'Child Folder',
      icon: '',
      parentId: 1,
    );

    final rootFolder = Folder(
      id: Folder.rootFolderId,
      name: 'Root',
      parentId: Folder.rootFolderId,
    );

    test('getFolders should return folders from database service', () async {
      // Arrange
      when(
        mockDatabaseService.getFolders(1),
      ).thenAnswer((_) async => [testChildFolder]);

      // Act
      final result = await folderRepository.getFolders(1);

      // Assert
      expect(result, [testChildFolder]);
      verify(mockDatabaseService.getFolders(1)).called(1);
    });

    test('getFolder should return a folder from database service', () async {
      // Arrange
      when(
        mockDatabaseService.getFolder(1),
      ).thenAnswer((_) async => testFolder);

      // Act
      final result = await folderRepository.getFolder(1);

      // Assert
      expect(result, testFolder);
      verify(mockDatabaseService.getFolder(1)).called(1);
    });

    test('createFolder should insert folder and return with new id', () async {
      // Arrange
      final folderToCreate = Folder(
        id: 1,
        parentId: 0,
        name: 'New Folder',
        icon: '#0000FF',
      );
      when(
        mockDatabaseService.insertFolder(
          folderToCreate.name,
          folderToCreate.icon,
          folderToCreate.parentId,
          any,
          any,
        ),
      ).thenAnswer((_) async => 3);

      // Act
      await folderRepository.createFolder(
        folderToCreate.name,
        folderToCreate.icon,
        folderToCreate.parentId,
      );

      // Assert
      verify(
        mockDatabaseService.insertFolder(
          folderToCreate.name,
          folderToCreate.icon,
          folderToCreate.parentId,
          any,
          any,
        ),
      );
    });

    test('updateFolder should update folder and return success', () async {
      // Arrange
      when(
        mockDatabaseService.updateFolder(
          testFolder.id,
          any,
          name: testFolder.name,
          icon: testFolder.icon,
          parentId: testFolder.parentId,
        ),
      ).thenAnswer((_) async => 1);

      // Act
      final result = await folderRepository.updateFolder(
        testFolder.id,
        name: testFolder.name,
        icon: testFolder.icon,
        parentId: testFolder.parentId,
      );

      // Assert
      expect(result, true);
      verify(
        mockDatabaseService.updateFolder(
          testFolder.id,
          any,
          name: testFolder.name,
          icon: testFolder.icon,
          parentId: testFolder.parentId,
        ),
      ).called(1);
    });

    test('updateFolder should return false when no rows affected', () async {
      // Arrange
      when(
        mockDatabaseService.updateFolder(
          testFolder.id,
          any,
          name: testFolder.name,
          icon: testFolder.icon,
          parentId: testFolder.parentId,
        ),
      ).thenAnswer((_) async => 0);

      // Act
      final result = await folderRepository.updateFolder(
        testFolder.id,
        name: testFolder.name,
        icon: testFolder.icon,
        parentId: testFolder.parentId,
      );

      // Assert
      expect(result, false);
      verify(
        mockDatabaseService.updateFolder(
          testFolder.id,
          any,
          name: testFolder.name,
          icon: testFolder.icon,
          parentId: testFolder.parentId,
        ),
      ).called(1);
    });

    test('deleteFolder should delete folder and return success', () async {
      // Arrange
      when(mockDatabaseService.deleteFolder(1)).thenAnswer((_) async => 1);

      // Act
      final result = await folderRepository.deleteFolder(1);

      // Assert
      expect(result, true);
      verify(mockDatabaseService.deleteFolder(1)).called(1);
    });

    test('deleteFolder should return false when no rows affected', () async {
      // Arrange
      when(mockDatabaseService.deleteFolder(1)).thenAnswer((_) async => 0);

      // Act
      final result = await folderRepository.deleteFolder(1);

      // Assert
      expect(result, false);
      verify(mockDatabaseService.deleteFolder(1)).called(1);
    });

    test('deleteFolder should return false for root folder', () async {
      // Act
      final result = await folderRepository.deleteFolder(Folder.rootFolderId);

      // Assert
      expect(result, false);
      // Verify that database service deleteFolder is not called for root folder
      verifyNever(mockDatabaseService.deleteFolder(Folder.rootFolderId));
    });

    test('getFolderPath should return path of folders', () async {
      // Arrange
      when(
        mockDatabaseService.getFolder(0),
      ).thenAnswer((_) async => rootFolder);
      when(
        mockDatabaseService.getFolder(1),
      ).thenAnswer((_) async => testFolder);
      when(
        mockDatabaseService.getFolder(2),
      ).thenAnswer((_) async => testChildFolder);
      // Act
      final result = await folderRepository.getFolderPath(2);

      // Assert
      expect(result.length, 3);
      expect(result[0].id, 0);
      expect(result[1].id, 1);
      expect(result[2].id, 2);
    });

    test('ensureRootFolderExists should create root folder if it does not exist', () async {
      // Arrange
      var callCount = 0;
      when(mockDatabaseService.getFolder(Folder.rootFolderId))
          .thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return null; // First call - folder doesn't exist
            } else {
              return rootFolder; // Second call - folder exists after creation
            }
          });
      when(mockDatabaseService.insertFolder('Root', '', Folder.rootFolderId, any, any))
          .thenAnswer((_) async => Folder.rootFolderId);

      // Act
      final result = await folderRepository.ensureRootFolderExists();

      // Assert
      expect(result, rootFolder);
      verify(mockDatabaseService.insertFolder('Root', '', Folder.rootFolderId, any, any)).called(1);
      verify(mockDatabaseService.getFolder(Folder.rootFolderId)).called(2);
    });

    test('ensureRootFolderExists should return existing root folder if it exists', () async {
      // Arrange
      when(mockDatabaseService.getFolder(Folder.rootFolderId))
          .thenAnswer((_) async => rootFolder);

      // Act
      final result = await folderRepository.ensureRootFolderExists();

      // Assert
      expect(result, rootFolder);
      verify(mockDatabaseService.getFolder(Folder.rootFolderId)).called(1);
      verifyNever(mockDatabaseService.insertFolder(any, any, any, any, any));
    });
  });
}
