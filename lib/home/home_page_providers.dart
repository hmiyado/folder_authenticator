import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:folder_authenticator/home/folder/subfolders_provider.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/repositories/folder_repository.dart';
import 'package:folder_authenticator/repositories/totp_entry_repository.dart';

part 'home_page_providers.g.dart';

@riverpod
Future<Folder> rootFolder(Ref ref) async {
  return await ref.watch(folderRepositoryProvider).ensureRootFolderExists();
}

@riverpod
class CurrentFolder extends _$CurrentFolder {
  @override
  Folder build() {
    // Start with the root folder as default
    ref.watch(rootFolderProvider).when(
      data: (folder) => state = folder,
      loading: () {},
      error: (_, __) {},
    );
    
    // Return a temporary folder while loading
    return Folder(
      id: Folder.rootFolderId,
      name: 'Root',
      parentId: Folder.rootFolderId,
    );
  }

  void setCurrentFolder(int folderId) async {
    Folder? folder = await ref
        .watch(folderRepositoryProvider)
        .getFolder(folderId);
    if (folder != null) {
      state = folder;
    }
  }
}

@riverpod
Future<int?> createSubFolder(
  Ref ref,
  int parentId,
  String folderName,
  {
    String? icon,
  }
) async {
  final i = await ref
      .watch(folderRepositoryProvider)
      .createFolder(folderName, icon ?? '', parentId);
  ref.invalidate(subfoldersProvider(parentId: parentId));
  return i;
}

@riverpod
Future<int> createTotpEntry(
  Ref ref,
  int folderId,
  String totpName,
  String secret,
  String issuer,
  int? digits,
  int? period,
  String? algorithm,
) async {
  final id = await ref
      .watch(totpEntryRepositoryProvider)
      .createTotpEntry(
        totpName,
        secret,
        issuer,
        digits,
        period,
        algorithm,
        folderId,
      );
  ref.invalidate(totpEntriesByFolderProvider(folderId: folderId));
  return id;
}
