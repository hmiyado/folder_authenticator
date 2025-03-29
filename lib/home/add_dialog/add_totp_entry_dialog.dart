import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/home_page_providers.dart';

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
      title: const Text('Add TOTP'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: secretController,
              decoration: const InputDecoration(labelText: 'Secret'),
            ),
            TextField(
              controller: issuerController,
              decoration: const InputDecoration(labelText: 'Issuer (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            ref.read(
              createTotpEntryProvider(
                widget.folderId,
                nameController.text,
                secretController.text,
                issuerController.text,
              ),
            );
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
