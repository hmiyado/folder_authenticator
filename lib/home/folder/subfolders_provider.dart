import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/repositories/folder_repository.dart';

part 'subfolders_provider.g.dart';

@riverpod
Future<List<Folder>> subfolders(Ref ref, {required int parentId}) async {
  final folderRepository = ref.watch(folderRepositoryProvider);
  return folderRepository.getFolders(parentId);
}
