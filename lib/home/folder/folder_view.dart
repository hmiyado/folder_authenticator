import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_entry_card.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/home/folder/folder_view_viewmodel.dart';

class FolderView extends ConsumerWidget {
  final int? folderId;

  const FolderView({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(folderViewViewModelProvider(folderId));
    final entriesAsyncValue = ref.watch(FutureProvider<List<TotpEntry>>((ref) => viewModel.getTotpEntries()));
    final folderAsyncValue = folderId != null
        ? ref.watch(FutureProvider<Folder?>((ref) => viewModel.getCurrentFolder()))
        : const AsyncValue<Folder?>.data(null);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (folderId != null)
          folderAsyncValue.when(
            data: (folder) => folder != null
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Folder: ${folder.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
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
