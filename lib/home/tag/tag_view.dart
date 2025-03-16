import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_entry_card.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/home/tag/tag_view_viewmodel.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

class TagView extends ConsumerWidget {
  final String? tag;

  const TagView({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(tagViewViewModelProvider(tag));
    final entriesAsyncValue = tag != null
        ? ref.watch(totpEntriesByTagProvider(tag!))
        : const AsyncValue<List<TotpEntry>>.data([]);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tag != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tag: ${viewModel.getTagDisplayName()}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        Expanded(
          child: entriesAsyncValue.when(
            data: (entries) {
              if (entries.isEmpty) {
                return const Center(
                  child: Text('No TOTP entries found'),
                );
              }
              
              return ListView.builder(
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  return TotpEntryCard(entry: entries[index]);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

}
