import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/services/totp_service.dart';

part 'totp_entry_card_providers.g.dart';

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
    
  return totpService.getRemainingSeconds(entry);
}

/// Provider for calculating progress value for the progress indicator (0.0 to 1.0)
@riverpod
double progressValue(Ref ref, TotpEntry entry) {
  final remainingSecs = ref.watch(remainingSecondsProvider(entry));
  return remainingSecs / entry.period;
}
