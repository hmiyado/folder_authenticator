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

  FolderEntries({required this.folderPath, required this.entries});
}

// Provider for folder entries (path + entries)
@riverpod
Future<FolderEntries> folderEntries(Ref ref, int folderId) async {
  final folderPath = await ref.watch(
    folderPathProvider(folderId: folderId).future,
  );
  final entries = await ref.watch(
    totpEntriesByFolderProvider(folderId: folderId).future,
  );

  return FolderEntries(folderPath: folderPath, entries: entries);
}

// Provider for all folder entries (current folder + subfolders)
@riverpod
Future<List<FolderEntries>> allFolderEntries(Ref ref, int folderId) async {
  final folderEntries = await ref.watch(folderEntriesProvider(folderId).future);
  List<FolderEntries> allFolderEntries = [folderEntries];
  List<int> queue = [folderId];

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    final nested = await ref.watch(
      subfoldersProvider(parentId: current).future,
    );
    final folderEntries = await ref.watch(
      folderEntriesProvider(current).future,
    );
    allFolderEntries.add(folderEntries);
    queue.addAll(nested.map((e) => e.id).where((e) => e != Folder.rootFolderId));
  }

  return allFolderEntries;
}
