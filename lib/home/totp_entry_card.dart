import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/totp_detail/totp_detail_page.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/home/totp_entry_card_viewmodel.dart';

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
  late TotpEntryCardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ref.read(totpEntryCardViewModelProvider(widget.entry));
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
    setState(() {
      _totpCode = _viewModel.generateTotp();
      _remainingSeconds = _viewModel.getRemainingSeconds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        title: Text(_viewModel.name),
        subtitle: Text(_viewModel.issuer),
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
