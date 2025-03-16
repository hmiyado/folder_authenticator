import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_detail_page.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';
import 'package:totp_folder/services/totp_service.dart';

class TagView extends ConsumerWidget {
  final String? tag;

  const TagView({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsyncValue = tag != null
        ? ref.watch(totpEntriesByTagProvider(tag!))
        : ref.watch(FutureProvider((ref) => ref.watch(totpEntryRepositoryProvider).getTotpEntries()));
    
    // Debug print to check if entries are being retrieved
    entriesAsyncValue.whenData((entries) {
      print('TOTP Entries for tag $tag: ${entries.length}');
      for (var entry in entries) {
        print('  - ${entry.name} (${entry.issuer})');
      }
    });
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (tag != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tag: $tag',
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
