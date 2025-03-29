import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder/folder_path_provider.dart';
import 'package:totp_folder/home/folder/subfolders_provider.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

// A class to hold folder path and its entries
class FolderEntries {
  final List<Folder> folderPath;
  final List<TotpEntry> entries;

  FolderEntries({
    required this.folderPath,
    required this.entries,
  });
}

// Provider for folder entries (path + entries)
final folderEntriesProvider = FutureProvider.family<FolderEntries, int>(
  (ref, folderId) async {
    final folderPath = await ref.watch(folderPathProvider(folderId: folderId).future);
    final entries = await ref.watch(totpEntriesByFolderProvider(folderId: folderId).future);
    
    return FolderEntries(
      folderPath: folderPath,
      entries: entries,
    );
  },
);

// Provider for all folder entries (current folder + subfolders)
final allFolderEntriesProvider = FutureProvider.family<List<FolderEntries>, int>(
  (ref, parentFolderId) async {
    final result = <FolderEntries>[];
    
    // Get the parent folder entries
    final parentEntries = await ref.watch(folderEntriesProvider(parentFolderId).future);
    if (parentEntries.entries.isNotEmpty) {
      result.add(parentEntries);
    }
    
    // Get all subfolders
    final subfolders = await ref.watch(subfoldersProvider(parentId: parentFolderId).future);
    
    // Get entries for each subfolder
    for (final folder in subfolders) {
      if (folder.id != null) {
        final subfolderEntries = await ref.watch(folderEntriesProvider(folder.id!).future);
        if (subfolderEntries.entries.isNotEmpty) {
          result.add(subfolderEntries);
        }
      }
    }
    
    return result;
  },
);
