import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/services/database_service.dart';

// Provider for the FolderRepository
final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return FolderRepository(databaseService);
});

// Provider for all folders
final foldersProvider = FutureProvider.family<List<Folder>, int?>((ref, parentId) {
  final repository = ref.watch(folderRepositoryProvider);
  return repository.getFolders(parentId: parentId);
});

// Provider for a single folder
final folderProvider = FutureProvider.family<Folder?, int>((ref, id) {
  final repository = ref.watch(folderRepositoryProvider);
  return repository.getFolder(id);
});

class FolderRepository {
  final DatabaseService _databaseService;

  FolderRepository(this._databaseService);

  Future<List<Folder>> getFolders({int? parentId}) async {
    return await _databaseService.getFolders(parentId: parentId);
  }

  Future<Folder?> getFolder(int id) async {
    return await _databaseService.getFolder(id);
  }

  Future<Folder> createFolder(Folder folder) async {
    final id = await _databaseService.insertFolder(folder);
    return folder.copyWith(id: id);
  }

  Future<bool> updateFolder(Folder folder) async {
    final rowsAffected = await _databaseService.updateFolder(folder);
    return rowsAffected > 0;
  }

  Future<bool> deleteFolder(int id) async {
    final rowsAffected = await _databaseService.deleteFolder(id);
    return rowsAffected > 0;
  }

  // Get the full path of a folder (including all parent folders)
  Future<List<Folder>> getFolderPath(int folderId) async {
    List<Folder> path = [];
    Folder? current = await getFolder(folderId);
    
    while (current != null) {
      path.insert(0, current);
      if (current.parentId == null) break;
      current = await getFolder(current.parentId!);
    }
    
    return path;
  }
}
