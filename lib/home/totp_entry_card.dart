import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_detail_page.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/services/totp_service.dart';

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
  late String _totpCode;
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateTotpValues();
    
    // Set up timer to update values every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTotpValues();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTotpValues() {
    final totpService = ref.read(totpServiceProvider);
    setState(() {
      _totpCode = totpService.generateTotp(widget.entry);
      _remainingSeconds = totpService.getRemainingSeconds(widget.entry);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(widget.entry.name),
        subtitle: Text(widget.entry.issuer),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _totpCode,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('$_remainingSeconds s'),
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
