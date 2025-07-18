import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/totp_detail/totp_detail_providers.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class TotpEditPage extends ConsumerStatefulWidget {
  final TotpEntry entry;

  const TotpEditPage({super.key, required this.entry});

  @override
  ConsumerState<TotpEditPage> createState() => _TotpEditPageState();
}

class _TotpEditPageState extends ConsumerState<TotpEditPage> {
  late TextEditingController nameController;
  late TextEditingController issuerController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.entry.name);
    issuerController = TextEditingController(text: widget.entry.issuer);
  }

  @override
  void dispose() {
    nameController.dispose();
    issuerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totpEntry = ref.watch(totpEntryProvider(widget.entry));

    totpEntry.when(
      data: (data) {
        // Only update controllers if the data has changed
        if (nameController.text != data.name) {
          nameController.text = data.name;
        }
        if (issuerController.text != data.issuer) {
          issuerController.text = data.issuer;
        }
      },
      error: (error, stack) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.errorLoadingTotpEntry}: $error')),
        );
      },
      loading: () {
        // Optionally show a loading indicator
        return const Center(child: CircularProgressIndicator());
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editTotp),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveChanges),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.name),
            ),
            TextField(
              controller: issuerController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.issuer),
            ),
          ],
        ),
      ),
    );
  }

  void _saveChanges() {
    ref.read(
      updateTotpEntryProvider(
        widget.entry,
        entryName: nameController.text,
        issuer: issuerController.text,
        folderId: widget.entry.folderId,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.totpEntryUpdated)));

    Navigator.pop(context); // Return to detail page
  }
}
