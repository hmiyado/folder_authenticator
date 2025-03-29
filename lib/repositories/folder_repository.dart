import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/services/database_service.dart';

part 'folder_repository.g.dart';

// Provider for the FolderRepository
@riverpod
FolderRepository folderRepository(Ref ref) {
  return FolderRepository(ref.watch(databaseServiceProvider));
}

class FolderRepository {
  final DatabaseService _databaseService;

  FolderRepository(this._databaseService);

  Future<List<Folder>> getFolders(int parentId) async {
    return await _databaseService.getFolders(parentId);
  }

  Future<Folder?> getFolder(int id) async {
    return await _databaseService.getFolder(id);
  }

  Future<int?> createFolder(
    String name,
    String color,
    int parentId,
  ) async {
    return await _databaseService.insertFolder(
      name,
      color,
      parentId,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<bool> updateFolder(Folder folder) async {
    final rowsAffected = await _databaseService.updateFolder(folder);
    return rowsAffected > 0;
  }

  Future<bool> deleteFolder(int id) async {
    final rowsAffected = await _databaseService.deleteFolder(id);
    return rowsAffected > 0;
  }

  /// Get the full path of a folder (including all parent folders)
  Future<List<Folder>> getFolderPath(int folderId) async {
    List<Folder> path = [];
    Folder? current = await getFolder(folderId);
    
    while (current != null) {
      path.insert(0, current);
      if (current.id == Folder.rootFolderId) break;
      current = await getFolder(current.parentId);
    }
    
    return path;
  }
}
