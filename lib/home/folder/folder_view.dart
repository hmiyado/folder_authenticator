import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_entry_card.dart';
import 'package:totp_folder/home/folder/folder_view_viewmodel.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';
import 'package:totp_folder/repositories/folder_repository.dart';

class FolderView extends ConsumerWidget {
  final int folderId;

  const FolderView({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(folderViewViewModelProvider(folderId));
    final entriesAsyncValue = ref.watch(totpEntriesByFolderProvider(folderId));
    final folderAsyncValue = ref.watch(folderProvider(folderId));    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        folderAsyncValue.when(
          data: (folder) {
            if (folder == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.all(16.0),
                child: Row(
                children: [
                  const Icon(Icons.folder, size: 24.0),
                  const SizedBox(width: 8.0),
                  Text(
                  folder.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
                ),
            );
          },
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
