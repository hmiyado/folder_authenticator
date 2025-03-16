import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

// View mode enum (folder or tag)
enum ViewMode { folder, tag }

// Provider for the current view mode
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.folder);

// Provider for the current folder ID
final currentFolderProvider = StateProvider<int?>((ref) => null);

// Provider for the selected tag
final selectedTagProvider = StateProvider<String?>((ref) => null);

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

  // Get the current view mode
  ViewMode get viewMode => _ref.read(viewModeProvider);

  // Set the view mode
  void setViewMode(ViewMode mode) {
    _ref.read(viewModeProvider.notifier).state = mode;
  }

  // Get the current folder ID
  int? get currentFolderId => _ref.read(currentFolderProvider);

  // Set the current folder ID
  void setCurrentFolder(int? folderId) {
    _ref.read(currentFolderProvider.notifier).state = folderId;
  }

  // Get the selected tag
  String? get selectedTag => _ref.read(selectedTagProvider);

  // Set the selected tag
  void setSelectedTag(String? tag) {
    _ref.read(selectedTagProvider.notifier).state = tag;
  }

  // Switch to folder view
  void switchToFolderView() {
    setViewMode(ViewMode.folder);
    setSelectedTag(null);
  }

  // Switch to tag view
  void switchToTagView() {
    setViewMode(ViewMode.tag);
  }

  // Get root folders
  Future<List<Folder>> getRootFolders() async {
    return await _folderRepository.getFolders(parentId: null);
  }

  // Get subfolders for a folder
  Future<List<Folder>> getSubfolders(int parentId) async {
    return await _folderRepository.getFolders(parentId: parentId);
  }

  // Get all tags
  Future<List<String>> getAllTags() async {
    return await _totpEntryRepository.getAllTags();
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
    List<String>? tags,
  }) async {
    final entry = TotpEntry(
      name: name,
      secret: secret,
      issuer: issuer,
      folderId: currentFolderId,
      tags: tags ?? [],
    );
    return await _totpEntryRepository.createTotpEntry(entry);
  }

  // Parse tags from comma-separated string
  List<String> parseTagsFromString(String tagsString) {
    return tagsString
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }
}
