import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/services/totp_service.dart';
import 'package:folder_authenticator/totp_detail/totp_detail_providers.dart';
import 'package:folder_authenticator/totp_detail/totp_edit_page.dart';
import 'package:folder_authenticator/totp_detail/totp_export_dialog.dart';

class TotpDetailPage extends ConsumerStatefulWidget {
  final TotpEntry entry;

  const TotpDetailPage({super.key, required this.entry});

  @override
  ConsumerState<TotpDetailPage> createState() => _TotpDetailPageState();
}

class _TotpDetailPageState extends ConsumerState<TotpDetailPage> {
  @override
  Widget build(BuildContext context) {
    final totpEntry = ref.watch(totpEntryProvider(widget.entry));
    final totpCode = ref.watch(generateTotpProvider(widget.entry));
    final remainingSeconds = ref.watch(remainingSecondsProvider(widget.entry));
    final progressValue = ref.watch(progressValueProvider(widget.entry));

    return totpEntry.when(
      data:
          (data) => _buildContent(
            context,
            data,
            totpCode,
            remainingSeconds,
            progressValue,
          ),
      error: (error, stack) {
        return Scaffold(
          appBar: AppBar(title: const Text('TOTP Details')),
          body: Center(child: Text('Error loading TOTP entry: $error')),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TotpEntry data,
    String totpCode,
    int remainingSeconds,
    double progressValue,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TotpEditPage(entry: data),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code),
            tooltip: 'Export',
            onPressed: () {
              _showExportDialog(data);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation(data);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    totpCode,
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progressValue),
                  Text('Refreshes in $remainingSeconds seconds'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Code'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: totpCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            _buildInfoRow('Name', data.name),
            _buildInfoRow('Issuer', data.issuer),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showExportDialog(TotpEntry entry) {
    final totpService = ref.read(totpServiceProvider);
    showDialog(
      context: context,
      builder: (context) {
        return TotpExportDialog(
          entry: entry,
          totpService: totpService,
        );
      },
    );
  }

  void _showDeleteConfirmation(TotpEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete TOTP Entry'),
          content: Text('Are you sure you want to delete "${entry.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(deleteTotpEntryProvider(entry));
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
