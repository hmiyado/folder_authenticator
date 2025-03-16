import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

// Provider for the FolderViewModel
final folderViewViewModelProvider = Provider.family<FolderViewModel, int>((ref, folderId) {
  final folderRepository = ref.watch(folderRepositoryProvider);
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  return FolderViewModel(folderId, folderRepository, totpEntryRepository);
});

class FolderViewModel {
  final int folderId;
  final FolderRepository _folderRepository;
  final TotpEntryRepository _totpEntryRepository;

  FolderViewModel(this.folderId, this._folderRepository, this._totpEntryRepository);

  // Get the current folder
  Future<Folder?> getCurrentFolder() async {
    return await _folderRepository.getFolder(folderId);
  }

  // Get TOTP entries for the current folder
  Future<List<TotpEntry>> getTotpEntries() async {
    return await _totpEntryRepository.getTotpEntriesByFolderId(folderId);
  }

  // Get folder path (breadcrumbs)
  Future<List<Folder>> getFolderPath() async {
    return await _folderRepository.getFolderPath(folderId);
  }

  // Check if this is the root folder view
  bool get isRootFolder => folderId == Folder.rootFolderId;

  // Get folder name
  Future<String> getFolderName() async {
    final folder = await getCurrentFolder();
    return folder?.name ?? 'All TOTPs';
  }

  // Get folder color
  Future<String> getFolderColor() async {
    final folder = await getCurrentFolder();
    return folder?.color ?? '#3498db';
  }
}
