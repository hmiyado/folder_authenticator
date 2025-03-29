import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/totp_detail/totp_detail_page.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/home/totp_entry_card_providers.dart';
import 'package:totp_folder/totp_detail/totp_detail_providers.dart';

class TotpEntryCard extends ConsumerStatefulWidget {
  final TotpEntry entry;

  const TotpEntryCard({
    super.key,
    required this.entry,
  });

  @override
  ConsumerState<TotpEntryCard> createState() => _TotpEntryCardState();
}

class _TotpEntryCardState extends ConsumerState<TotpEntryCard> {

  @override
  Widget build(BuildContext context) {
    // Watch the providers to get the latest values
    final totpCode = ref.watch(generateTotpProvider(widget.entry));
    final remainingSeconds = ref.watch(remainingSecondsProvider(widget.entry));
    final totpEntry = ref.watch(totpEntryProvider(widget.entry));

    return totpEntry.when(
      data: (data) => _buildContent(context, data, totpCode, remainingSeconds), 
      error: (error, stack) => const Card(
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text('Error loading TOTP entry'),
          ),
      ),
      loading: () => const Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListTile(
          title: Center(child: CircularProgressIndicator()),
        ),
      ),
      );
  }

  Widget _buildContent(
    BuildContext context,
    TotpEntry totpEntry,
    String totpCode,
    int remainingSeconds,
  ){ 
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(totpEntry.name),
        subtitle: Text(totpEntry.issuer),
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
              builder: (context) => TotpDetailPage(entry: widget.entry),
            ),
          );
        },
      ),
    );
  }
}
