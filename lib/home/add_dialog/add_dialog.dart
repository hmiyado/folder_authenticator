import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/home/add_dialog/add_folder_dialog.dart';
import 'package:folder_authenticator/home/add_dialog/add_totp_entry_dialog.dart';
import 'package:folder_authenticator/home/add_dialog/qr_scanner_page.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class AddDialog extends ConsumerStatefulWidget {
  final Folder folder;
  const AddDialog({super.key, required this.folder});

  @override
  ConsumerState<AddDialog> createState() => _AddDialogState();
}

class _AddDialogState extends ConsumerState<AddDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addNew),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.key),
            title: Text(AppLocalizations.of(context)!.addTotpManually),
            onTap: () {
              Navigator.pop(context);
              _showAddTotpDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.qr_code_scanner),
            title: Text(AppLocalizations.of(context)!.scanQrCode),
            onTap: () {
              Navigator.pop(context);
              _openQrScanner(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder),
            title: Text(AppLocalizations.of(context)!.addFolder),
            onTap: () {
              Navigator.pop(context);
              _showAddFolderDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showAddTotpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddTotpEntryDialog(folderId: widget.folder.id);
      },
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AddFolderDialog(folderId: widget.folder.id);
      },
    );
  }

  void _openQrScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerPage(folderId: widget.folder.id),
      ),
    );
  }
}
