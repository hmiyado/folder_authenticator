import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_detail_page.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';
import 'package:totp_folder/services/totp_service.dart';

class FolderView extends ConsumerWidget {
  final int? folderId;

  const FolderView({
    super.key,
    required this.folderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsyncValue = ref.watch(totpEntriesByFolderProvider(folderId));
    final folderAsyncValue = folderId != null
        ? ref.watch(FutureProvider<Folder?>((ref) => ref.watch(folderRepositoryProvider).getFolder(folderId!)))
        : const AsyncValue<Folder?>.data(null);
    
    // Debug print to check if entries are being retrieved
    entriesAsyncValue.whenData((entries) {
      print('TOTP Entries for folder $folderId: ${entries.length}');
      for (var entry in entries) {
        print('  - ${entry.name} (${entry.issuer})');
      }
    });
    
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
                  return _buildTotpEntryCard(context, ref, entries[index]);
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

  Widget _buildTotpEntryCard(BuildContext context, WidgetRef ref, TotpEntry entry) {
    final totpService = ref.watch(totpServiceProvider);
    final totpCode = totpService.generateTotp(entry);
    final remainingSeconds = totpService.getRemainingSeconds(entry);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(entry.name),
        subtitle: Text(entry.issuer),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              totpCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('$remainingSeconds s'),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TotpDetailPage(entry: entry),
            ),
          );
        },
      ),
    );
  }
}
