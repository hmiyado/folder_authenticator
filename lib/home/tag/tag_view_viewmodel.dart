import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

// Provider for the TagViewModel
final tagViewViewModelProvider = Provider.family<TagViewModel, String?>((ref, tag) {
  final totpEntryRepository = ref.watch(totpEntryRepositoryProvider);
  return TagViewModel(tag, totpEntryRepository);
});

class TagViewModel {
  final String? tag;
  final TotpEntryRepository _totpEntryRepository;

  TagViewModel(this.tag, this._totpEntryRepository);

  // Get TOTP entries for the current tag
  Future<List<TotpEntry>> getTotpEntries() async {
    if (tag == null) {
      // If no tag is selected, return all entries
      return await _totpEntryRepository.getTotpEntries();
    } else {
      return await _totpEntryRepository.getTotpEntries(tag: tag);
    }
  }

  // Get all available tags
  Future<List<String>> getAllTags() async {
    return await _totpEntryRepository.getAllTags();
  }

  // Check if this is the "all tags" view
  bool get isAllTags => tag == null;

  // Get tag name for display
  String getTagDisplayName() {
    return tag ?? 'All TOTPs';
  }

  // Check if a TOTP entry has the current tag
  bool hasCurrentTag(TotpEntry entry) {
    if (tag == null) return true;
    return entry.tags.contains(tag);
  }
}
