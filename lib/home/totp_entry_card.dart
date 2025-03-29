import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/totp_detail/totp_detail_page.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/home/totp_entry_card_providers.dart';

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
    final name = ref.watch(entryNameProvider(widget.entry));
    final issuer = ref.watch(entryIssuerProvider(widget.entry));
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(name),
        subtitle: Text(issuer),
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
