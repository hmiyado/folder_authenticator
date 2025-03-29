import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';
import 'package:totp_folder/services/totp_service.dart';

// Provider for the TotpDetailViewModel
final totpDetailViewModelProvider = Provider.family<TotpDetailViewModel, TotpEntry>((ref, entry) {
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  final totpService = ref.watch(totpServiceProvider);
  return TotpDetailViewModel(entry, totpEntryRepository, totpService);
});

class TotpDetailViewModel {
  final TotpEntry entry;
  final TotpEntryRepository _totpEntryRepository;
  final TotpService _totpService;

  TotpDetailViewModel(this.entry, this._totpEntryRepository, this._totpService);

  // Get remaining seconds until the next TOTP refresh
  int getRemainingSeconds() {
    return _totpService.getRemainingSeconds(entry);
  }

  // Calculate progress value for the progress indicator (0.0 to 1.0)
  double getProgressValue() {
    return getRemainingSeconds() / entry.period;
  }

  // Update the TOTP entry
  Future<bool> updateTotpEntry({
    String? name,
    String? secret,
    String? issuer,
    int? folderId,
    int? digits,
    int? period,
    String? algorithm,
  }) async {
    final updatedEntry = entry.copyWith(
      name: name,
      secret: secret,
      issuer: issuer,
      folderId: folderId,
      digits: digits,
      period: period,
      algorithm: algorithm,
      updatedAt: DateTime.now(),
    );

    return await _totpEntryRepository.updateTotpEntry(updatedEntry);
  }

  // Delete the TOTP entry
  Future<bool> deleteTotpEntry() async {
    if (entry.id == null) return false;
    return await _totpEntryRepository.deleteTotpEntry(entry.id!);
  }

  // Validate a TOTP secret
  bool isValidSecret(String secret) {
    return _totpService.isValidSecret(secret);
  }

  // Get entry properties
  String get name => entry.name;
  String get secret => entry.secret;
  String get issuer => entry.issuer;
  int? get folderId => entry.folderId;
  int get digits => entry.digits;
  int get period => entry.period;
  String get algorithm => entry.algorithm;
}
