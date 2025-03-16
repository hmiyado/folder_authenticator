import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/services/totp_service.dart';

// Provider for the TotpEntryCardViewModel
final totpEntryCardViewModelProvider = Provider.family<TotpEntryCardViewModel, TotpEntry>((ref, entry) {
  final totpService = ref.watch(totpServiceProvider);
  return TotpEntryCardViewModel(entry, totpService);
});

class TotpEntryCardViewModel {
  final TotpEntry entry;
  final TotpService _totpService;

  TotpEntryCardViewModel(this.entry, this._totpService);

  // Generate TOTP code for the entry
  String generateTotp() {
    return _totpService.generateTotp(entry);
  }

  // Get remaining seconds until the next TOTP refresh
  int getRemainingSeconds() {
    return _totpService.getRemainingSeconds(entry);
  }

  // Get the entry name
  String get name => entry.name;

  // Get the entry issuer
  String get issuer => entry.issuer;

  // Calculate progress value for the progress indicator (0.0 to 1.0)
  double getProgressValue() {
    return getRemainingSeconds() / entry.period;
  }
}
