import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/services/totp_service.dart';

class TotpExportDialog extends StatefulWidget {
  final TotpEntry entry;
  final TotpService totpService;

  const TotpExportDialog({
    super.key,
    required this.entry,
    required this.totpService,
  });

  @override
  State<TotpExportDialog> createState() => _TotpExportDialogState();
}

class _TotpExportDialogState extends State<TotpExportDialog> {
  bool _showSecret = false;
  
  // Constants for QR code
  static const double qrCodeSize = 200.0;
  static const double qrCodePadding = 16.0;

  @override
  Widget build(BuildContext context) {
    final otpauthUri = widget.totpService.generateOtpauthUri(widget.entry);
    
    return AlertDialog(
      title: const Text('Export TOTP'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code
            SizedBox(
              width: qrCodeSize + (qrCodePadding * 2),
              height: qrCodeSize + (qrCodePadding * 2),
              child: Container(
                padding: EdgeInsets.all(qrCodePadding),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: QrImageView(
                  data: otpauthUri,
                  version: QrVersions.auto,
                  size: qrCodeSize,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            
            // Copy URI button
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Copy URI'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: otpauthUri));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('URI copied to clipboard')),
                );
              },
            ),
            
            const SizedBox(height: 16.0),
            
            // Show/Hide Secret Toggle
            SwitchListTile(
              title: const Text('Show Secret'),
              value: _showSecret,
              onChanged: (value) {
                setState(() {
                  _showSecret = value;
                });
              },
            ),
            
            // Secret (only shown if toggle is on)
            if (_showSecret) ...[
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.entry.secret,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        Clipboard.setData(
                          ClipboardData(text: widget.entry.secret),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Secret copied to clipboard'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Warning: Keep this secret secure. Anyone with this secret '
                'can generate your TOTP codes.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12.0,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
