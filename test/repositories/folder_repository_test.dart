import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/services/database_service.dart';

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
      color: '#FF0000',
      parentId: null,
    );

    final testChildFolder = Folder(
      id: 2,
      name: 'Child Folder',
      color: '#00FF00',
      parentId: 1,
    );

    test('getFolders should return folders from database service', () async {
      // Arrange
      when(mockDatabaseService.getFolders(parentId: 1))
          .thenAnswer((_) async => [testChildFolder]);

      // Act
      final result = await folderRepository.getFolders(parentId: 1);

      // Assert
      expect(result, [testChildFolder]);
      verify(mockDatabaseService.getFolders(parentId: 1)).called(1);
    });

    test('getFolder should return a folder from database service', () async {
      // Arrange
      when(mockDatabaseService.getFolder(1)).thenAnswer((_) async => testFolder);

      // Act
      final result = await folderRepository.getFolder(1);

      // Assert
      expect(result, testFolder);
      verify(mockDatabaseService.getFolder(1)).called(1);
    });

    test('createFolder should insert folder and return with new id', () async {
      // Arrange
      final folderToCreate = Folder(
        name: 'New Folder',
        color: '#0000FF',
      );
      when(mockDatabaseService.insertFolder(folderToCreate))
          .thenAnswer((_) async => 3);

      // Act
      final result = await folderRepository.createFolder(folderToCreate);

      // Assert
      expect(result.id, 3);
      expect(result.name, 'New Folder');
      expect(result.color, '#0000FF');
      verify(mockDatabaseService.insertFolder(folderToCreate)).called(1);
    });

    test('updateFolder should update folder and return success', () async {
      // Arrange
      when(mockDatabaseService.updateFolder(testFolder))
          .thenAnswer((_) async => 1);

      // Act
      final result = await folderRepository.updateFolder(testFolder);

      // Assert
      expect(result, true);
      verify(mockDatabaseService.updateFolder(testFolder)).called(1);
    });

    test('updateFolder should return false when no rows affected', () async {
      // Arrange
      when(mockDatabaseService.updateFolder(testFolder))
          .thenAnswer((_) async => 0);

      // Act
      final result = await folderRepository.updateFolder(testFolder);

      // Assert
      expect(result, false);
      verify(mockDatabaseService.updateFolder(testFolder)).called(1);
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

    test('getFolderPath should return path of folders', () async {
      // Arrange
      when(mockDatabaseService.getFolder(2)).thenAnswer((_) async => testChildFolder);
      when(mockDatabaseService.getFolder(1)).thenAnswer((_) async => testFolder);

      // Act
      final result = await folderRepository.getFolderPath(2);

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 1);
      expect(result[1].id, 2);
      verify(mockDatabaseService.getFolder(2)).called(1);
      verify(mockDatabaseService.getFolder(1)).called(1);
    });
  });
}
