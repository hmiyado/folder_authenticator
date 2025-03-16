import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

// Provider for the current folder ID
final currentFolderProvider = StateProvider<int>((ref) => Folder.rootFolderId);

// Provider for the HomePageViewModel
final homePageViewModelProvider = Provider<HomePageViewModel>((ref) {
  final folderRepository = ref.watch(folderRepositoryProvider);
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  return HomePageViewModel(ref, folderRepository, totpEntryRepository);
});

class HomePageViewModel {
  final Ref _ref;
  final FolderRepository _folderRepository;
  final TotpEntryRepository _totpEntryRepository;

  HomePageViewModel(this._ref, this._folderRepository, this._totpEntryRepository);

  // Get the current folder ID
  int get currentFolderId => _ref.read(currentFolderProvider);

  // Set the current folder ID
  void setCurrentFolder(int folderId) {
    _ref.read(currentFolderProvider.notifier).state = folderId;
  }

  // Get root folders
  Future<List<Folder>> getRootFolders() async {
    return await _folderRepository.getFolders(parentId: null);
  }

  // Get subfolders for a folder
  Future<List<Folder>> getSubfolders(int parentId) async {
    return await _folderRepository.getFolders(parentId: parentId);
  }

  // Create a new folder
  Future<Folder> createFolder(String name, String color, {int? parentId}) async {
    final folder = Folder(
      name: name,
      color: color,
      parentId: parentId ?? currentFolderId,
    );
    return await _folderRepository.createFolder(folder);
  }

  // Create a new TOTP entry
  Future<TotpEntry> createTotpEntry({
    required String name,
    required String secret,
    String issuer = '',
  }) async {
    final entry = TotpEntry(
      name: name,
      secret: secret,
      issuer: issuer,
      folderId: currentFolderId,
    );
    return await _totpEntryRepository.createTotpEntry(entry);
  }
}
