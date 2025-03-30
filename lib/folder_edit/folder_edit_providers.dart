import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/repositories/folder_repository.dart';

part 'folder_edit_providers.g.dart';

@riverpod
Future<Folder?> folder(Ref ref, int folderId) {
  return ref.watch(folderRepositoryProvider).getFolder(folderId);
}