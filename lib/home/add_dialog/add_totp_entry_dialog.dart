import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/home/home_page_providers.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class AddTotpEntryDialog extends ConsumerStatefulWidget {
  const AddTotpEntryDialog({super.key, required this.folderId});
  final int folderId;

  @override
  ConsumerState<AddTotpEntryDialog> createState() => _AddTotpEntryDialogState();
}

class _AddTotpEntryDialogState extends ConsumerState<AddTotpEntryDialog> {
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final secretController = TextEditingController();
    final issuerController = TextEditingController();

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addTotp),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
            ),
            TextField(
              controller: secretController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.secret),
            ),
            TextField(
              controller: issuerController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.issuerOptional),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () {
            ref.read(
              createTotpEntryProvider(
                widget.folderId,
                nameController.text,
                secretController.text,
                issuerController.text,
                null,
                null,
                null,
              ),
            );
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }
}
