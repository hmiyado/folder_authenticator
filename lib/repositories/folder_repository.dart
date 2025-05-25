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
    if (parentId == Folder.rootFolderId) {
      // Ensure root folder exists before fetching subfolders
      await ensureRootFolderExists();
    }
    return await _databaseService.getFolders(parentId);
  }

  Future<Folder?> getFolder(int id) async {
    return await _databaseService.getFolder(id);
  }

  /// Ensures the root folder exists in the database
  Future<Folder> ensureRootFolderExists() async {
    Folder? rootFolder = await getFolder(Folder.rootFolderId);
    if (rootFolder == null) {
      // Create root folder if it doesn't exist
      await _databaseService.insertFolder(
        'Root',
        '',
        Folder.rootFolderId,
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
      );
      rootFolder = await getFolder(Folder.rootFolderId);
    }
    return rootFolder!;
  }

  Future<int?> createFolder(String name, String icon, int parentId) async {
    return await _databaseService.insertFolder(
      name,
      icon,
      parentId,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<bool> updateFolder(
    int id, {
    String? name,
    String? icon,
    int? parentId,
  }) async {
    final rowsAffected = await _databaseService.updateFolder(
      id,
      DateTime.now(),
      name: name,
      icon: icon,
      parentId: parentId,
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteFolder(int id) async {
    // Prevent deletion of root folder
    if (id == Folder.rootFolderId) {
      return false;
    }
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
