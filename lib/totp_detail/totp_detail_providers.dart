import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

part 'totp_detail_providers.g.dart';

@riverpod
Future<bool> updateTotpEntry(
  Ref ref,
  TotpEntry entry, {
  String? entryName,
  String? secret,
  String? issuer,
  int? folderId,
  int? digits,
  int? period,
  String? algorithm,
}) {
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  return totpEntryRepository.updateTotpEntry(
    entry.copyWith(
      name: entryName,
      secret: secret,
      issuer: issuer,
      folderId: folderId,
      digits: digits,
      period: period,
      algorithm: algorithm,
    ),
  );
}