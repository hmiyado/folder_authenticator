import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/home/folder/subfolders_provider.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

part 'home_page_providers.g.dart';

@riverpod
class CurrentFolder extends _$CurrentFolder {
  @override
  Folder build() => Folder.rootFolder();

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
  String color,
) async {
  final i = await ref
      .watch(folderRepositoryProvider)
      .createFolder(folderName, color, parentId);
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
      .createTotpEntry(totpName, secret, issuer,  digits, period, algorithm, folderId,);
  ref.invalidate(totpEntriesByFolderProvider(folderId: folderId));
  return id;
}
