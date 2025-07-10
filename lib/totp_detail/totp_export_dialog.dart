import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/services/totp_service.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

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
      title: Text(AppLocalizations.of(context)!.exportTotp),
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
              label: Text(AppLocalizations.of(context)!.copyUri),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: otpauthUri));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.uriCopiedToClipboard)),
                );
              },
            ),
            
            const SizedBox(height: 16.0),
            
            // Show/Hide Secret Toggle
            SwitchListTile(
              title: Text(AppLocalizations.of(context)!.showSecret),
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
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.secretCopiedToClipboard),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                AppLocalizations.of(context)!.securityWarning,
                style: const TextStyle(
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
          child: Text(AppLocalizations.of(context)!.close),
        ),
      ],
    );
  }
}
