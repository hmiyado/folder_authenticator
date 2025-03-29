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
  late TextEditingController secretController;
  late TextEditingController issuerController;
  late TextEditingController digitsController;
  late TextEditingController periodController;
  late String algorithm;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.entry.name);
    secretController = TextEditingController(text: widget.entry.secret);
    issuerController = TextEditingController(text: widget.entry.issuer);
    digitsController = TextEditingController(
      text: widget.entry.digits.toString(),
    );
    periodController = TextEditingController(
      text: widget.entry.period.toString(),
    );
    algorithm = widget.entry.algorithm;
  }

  @override
  void dispose() {
    nameController.dispose();
    secretController.dispose();
    issuerController.dispose();
    digitsController.dispose();
    periodController.dispose();
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
        if (secretController.text != data.secret) {
          secretController.text = data.secret;
        }
        if (issuerController.text != data.issuer) {
          issuerController.text = data.issuer;
        }
        if (digitsController.text != data.digits.toString()) {
          digitsController.text = data.digits.toString();
        }
        if (periodController.text != data.period.toString()) {
          periodController.text = data.period.toString();
        }
        algorithm = data.algorithm;
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
              controller: secretController,
              decoration: const InputDecoration(labelText: 'Secret'),
            ),
            TextField(
              controller: issuerController,
              decoration: const InputDecoration(labelText: 'Issuer'),
            ),
            TextField(
              controller: digitsController,
              decoration: const InputDecoration(labelText: 'Digits'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: periodController,
              decoration: const InputDecoration(labelText: 'Period (seconds)'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: algorithm,
              decoration: const InputDecoration(labelText: 'Algorithm'),
              items:
                  ['SHA1', 'SHA256', 'SHA512'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    algorithm = newValue;
                  });
                }
              },
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
        secret: secretController.text,
        issuer: issuerController.text,
        folderId: widget.entry.folderId,
        digits: int.tryParse(digitsController.text),
        period: int.tryParse(periodController.text),
        algorithm: algorithm,
      ),
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('TOTP entry updated')));

    Navigator.pop(context); // Return to detail page
  }
}
