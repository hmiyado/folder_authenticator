import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/services/database_service.dart';

// Provider for the TotpEntryRepository
final totpEntryRepositoryProvider = Provider<TotpEntryRepository>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TotpEntryRepository(databaseService);
});

// Provider for TOTP entries by folder
final totpEntriesByFolderProvider = FutureProvider.family<List<TotpEntry>, int>((ref, folderId) {
  final repository = ref.watch(totpEntryRepositoryProvider);
  return repository.getTotpEntriesByFolderId(folderId);
});

// Provider for TOTP entries by tag
final totpEntriesByTagProvider = FutureProvider.family<List<TotpEntry>, String>((ref, tag) {
  final repository = ref.watch(totpEntryRepositoryProvider);
  return repository.getTotpEntriesByTag(tag);
});

// Provider for all tags
final allTagsProvider = FutureProvider<List<String>>((ref) {
  final repository = ref.watch(totpEntryRepositoryProvider);
  return repository.getAllTags();
});

class TotpEntryRepository {
  final DatabaseService _databaseService;

  TotpEntryRepository(this._databaseService);

  Future<List<TotpEntry>> getTotpEntriesByFolderId(int folderId) async {
    return await _databaseService.getTotpEntries(folderId: folderId);
  }
  
  Future<List<TotpEntry>> getTotpEntriesByTag(String tag) async {
    return await _databaseService.getTotpEntries(folderId: Folder.rootFolderId, tag: tag);
  }

  Future<TotpEntry?> getTotpEntry(int id) async {
    return await _databaseService.getTotpEntry(id);
  }

  Future<TotpEntry> createTotpEntry(TotpEntry entry) async {
    final id = await _databaseService.insertTotpEntry(entry);
    return entry.copyWith(id: id);
  }

  Future<bool> updateTotpEntry(TotpEntry entry) async {
    final rowsAffected = await _databaseService.updateTotpEntry(entry);
    return rowsAffected > 0;
  }

  Future<bool> deleteTotpEntry(int id) async {
    final rowsAffected = await _databaseService.deleteTotpEntry(id);
    return rowsAffected > 0;
  }

  Future<List<String>> getAllTags() async {
    return await _databaseService.getAllTags();
  }
}
