import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/home/folder/folder_path_provider.dart';
import 'package:totp_folder/home/folder/subfolders_provider.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

part 'folder_entries_provider.g.dart';

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
@riverpod
FolderEntries folderEntries(Ref ref, int folderId) {
  final folderPath = ref.watch(folderPathProvider(folderId: folderId)).valueOrNull;
  final entries = ref.watch(totpEntriesByFolderProvider(folderId: folderId)).valueOrNull;
  if (folderPath == null || entries == null) {
    return FolderEntries(
      folderPath: [],
      entries: [],
    );
  }
  
  return FolderEntries(
    folderPath: folderPath,
    entries: entries,
  );
}

// Provider for all folder entries (current folder + subfolders)
@riverpod
List<FolderEntries> allFolderEntries(Ref ref,int parentFolderId) {
  final result = <FolderEntries>[];
  
  // Get the parent folder entries
  final parentEntries = ref.watch(folderEntriesProvider(parentFolderId));
  if (parentEntries.entries.isNotEmpty) {
    result.add(parentEntries);
  }
  
  // Get all subfolders
  final subfolders = ref.watch(subfoldersProvider(parentId: parentFolderId)).valueOrNull ?? [];
  
  // Get entries for each subfolder
  for (final folder in subfolders) {
    final folderId = folder.id;
    if (folderId == null) {
      continue;
    }
    final subfolderEntries = ref.read(folderEntriesProvider(folderId));
    if (subfolderEntries.entries.isNotEmpty) {
      result.add(subfolderEntries);
    }
  }
  
  return result;
}