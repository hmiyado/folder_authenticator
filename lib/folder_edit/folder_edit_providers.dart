import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/repositories/folder_repository.dart';

part 'folder_edit_providers.g.dart';

@riverpod
Future<Folder?> folder(Ref ref, int folderId) {
  return ref.watch(folderRepositoryProvider).getFolder(folderId);
}

@riverpod
Future<bool> updateFolder(
  Ref ref,
  int folderId, {
  String? folderName,
  String? color,
  int? parentId,
}) async {
  final updated = ref
      .read(folderRepositoryProvider)
      .updateFolder(
        folderId,
        name: folderName,
        color: color,
        parentId: parentId,
      );
  ref.invalidate(folderRepositoryProvider);
  return updated;
}

@riverpod
Future<bool> deleteFolder(Ref ref, int folderId) async {
  final deleted = ref.read(folderRepositoryProvider).deleteFolder(folderId);
  ref.invalidate(folderRepositoryProvider);
  return deleted;
}
