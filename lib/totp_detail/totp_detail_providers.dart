import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:folder_authenticator/home/folder/folder_entries_provider.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/repositories/totp_entry_repository.dart';
import 'package:folder_authenticator/services/totp_service.dart';

part 'totp_detail_providers.g.dart';

@riverpod
Future<TotpEntry> totpEntry(Ref ref, TotpEntry entry) {
  return ref.watch(totpEntryRepositoryProvider).getTotpEntry(entry.id).then((
    fetchedEntry,
  ) {
    return fetchedEntry ?? entry;
  });
}

/// Provider for generating TOTP code for a specific entry
@riverpod
String generateTotp(Ref ref, TotpEntry entry) {
  final totpService = ref.watch(totpServiceProvider);
  return totpService.generateTotp(entry);
}

/// Provider for getting remaining seconds until the next TOTP refresh
/// Updates every 500ms automatically
@riverpod
int remainingSeconds(Ref ref, TotpEntry entry) {
  final totpService = ref.watch(totpServiceProvider);

  return totpService.getRemainingMilliSeconds(entry) ~/ 1000;
}

/// Provider for calculating progress value for the progress indicator (0.0 to 1.0)
@riverpod
double progressValue(Ref ref, TotpEntry entry) {
  final totpService = ref.watch(totpServiceProvider);
  return totpService.getRemainingMilliSeconds(entry) / (entry.period * 1000);
}

@riverpod
Future<bool> updateTotpEntry(
  Ref ref,
  TotpEntry entry, {
  String? entryName,
  String? issuer,
  int? folderId,
}) async {
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  final updated = await totpEntryRepository.updateTotpEntry(
    entry.id,
    entryName,
    issuer,
    folderId,
  );
  ref.invalidate(totpEntryProvider(entry));
  ref.invalidate(folderEntriesProvider(entry.folderId));
  return updated;
}

@riverpod
Future<bool> deleteTotpEntry(Ref ref, TotpEntry entry) {
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  ref.invalidate(folderEntriesProvider(entry.folderId));
  return totpEntryRepository.deleteTotpEntry(entry.id);
}
