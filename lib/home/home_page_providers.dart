import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

part 'home_page_providers.g.dart';

@riverpod
class CurrentFolder extends _$CurrentFolder {
  @override
  Folder build() => Folder.rootFolder();

  void setCurrentFolder(int folderId) async {
    Folder? folder = await ref.watch(folderRepositoryProvider).getFolder(folderId);
    if (folder != null) {
      state = folder;
    }
  }

}

@riverpod
Future<Folder> createSubFolder(Ref ref, int parentId,String folderName, String color) async {
  return await ref.watch(folderRepositoryProvider).createFolder(Folder(name: folderName,color: color, parentId: parentId));
}

@riverpod
Future<TotpEntry> createTotpEntry(Ref ref, int folderId, String totpName, String secret, String issuer) async {
  return await ref.watch(totpEntryRepositoryProvider).createTotpEntry(TotpEntry(
    name: totpName,
    secret: secret,
    issuer: issuer,
    folderId: folderId,
  ));
}