import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/totp_detail/totp_detail_providers.dart';

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
          SnackBar(content: Text('Error loading TOTP entry: $error')),
        );
      },
      loading: () {
        // Optionally show a loading indicator
        return const Center(child: CircularProgressIndicator());
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit TOTP'),
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
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: TextEditingController(text: widget.entry.secret),
              decoration: const InputDecoration(labelText: 'Secret'),
              enabled: false,
            ),
            TextField(
              controller: issuerController,
              decoration: const InputDecoration(labelText: 'Issuer'),
            ),
            TextField(
              controller: TextEditingController(
                text: widget.entry.digits.toString(),
              ),
              decoration: const InputDecoration(labelText: 'Digits'),
              keyboardType: TextInputType.number,
              enabled: false,
            ),
            TextField(
              controller: TextEditingController(
                text: widget.entry.period.toString(),
              ),
              decoration: const InputDecoration(labelText: 'Period (seconds)'),
              keyboardType: TextInputType.number,
              enabled: false,
            ),
            TextField(
              controller: TextEditingController(text: widget.entry.algorithm),
              decoration: const InputDecoration(labelText: 'Algorithm'),
              enabled: false,
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
    ).showSnackBar(const SnackBar(content: Text('TOTP entry updated')));

    Navigator.pop(context); // Return to detail page
  }
}
