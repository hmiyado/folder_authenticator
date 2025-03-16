import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';
import 'package:totp_folder/services/totp_service.dart';

class TotpDetailPage extends ConsumerStatefulWidget {
  final TotpEntry entry;

  const TotpDetailPage({super.key, required this.entry});

  @override
  ConsumerState<TotpDetailPage> createState() => _TotpDetailPageState();
}

class _TotpDetailPageState extends ConsumerState<TotpDetailPage> {
  late TextEditingController nameController;
  late TextEditingController secretController;
  late TextEditingController issuerController;
  late TextEditingController tagsController;
  late TextEditingController digitsController;
  late TextEditingController periodController;
  late String algorithm;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.entry.name);
    secretController = TextEditingController(text: widget.entry.secret);
    issuerController = TextEditingController(text: widget.entry.issuer);
    tagsController = TextEditingController(text: widget.entry.tags.join(', '));
    digitsController = TextEditingController(text: widget.entry.digits.toString());
    periodController = TextEditingController(text: widget.entry.period.toString());
    algorithm = widget.entry.algorithm;
  }

  @override
  void dispose() {
    nameController.dispose();
    secretController.dispose();
    issuerController.dispose();
    tagsController.dispose();
    digitsController.dispose();
    periodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totpService = ref.watch(totpServiceProvider);
    final totpCode = totpService.generateTotp(widget.entry);
    final remainingSeconds = totpService.getRemainingSeconds(widget.entry);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit TOTP' : 'TOTP Details'),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                _saveChanges();
              } else {
                setState(() {
                  isEditing = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmation();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditing) ...[
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
                    LinearProgressIndicator(
                      value: remainingSeconds / widget.entry.period,
                    ),
                    Text('Refreshes in $remainingSeconds seconds'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy Code'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: totpCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Code copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 32),
              _buildInfoRow('Name', widget.entry.name),
              _buildInfoRow('Issuer', widget.entry.issuer),
              _buildInfoRow('Secret', widget.entry.secret, obscure: true),
              _buildInfoRow('Digits', widget.entry.digits.toString()),
              _buildInfoRow('Period', '${widget.entry.period} seconds'),
              _buildInfoRow('Algorithm', widget.entry.algorithm),
              _buildInfoRow('Tags', widget.entry.tags.join(', ')),
            ] else ...[
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                ),
              ),
              TextField(
                controller: secretController,
                decoration: const InputDecoration(
                  labelText: 'Secret',
                ),
              ),
              TextField(
                controller: issuerController,
                decoration: const InputDecoration(
                  labelText: 'Issuer',
                ),
              ),
              TextField(
                controller: tagsController,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                ),
              ),
              TextField(
                controller: digitsController,
                decoration: const InputDecoration(
                  labelText: 'Digits',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: periodController,
                decoration: const InputDecoration(
                  labelText: 'Period (seconds)',
                ),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: algorithm,
                decoration: const InputDecoration(
                  labelText: 'Algorithm',
                ),
                items: ['SHA1', 'SHA256', 'SHA512'].map((String value) {
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
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: obscure
                ? Row(
                    children: [
                      Text('•' * 10),
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () {
                          _showSecret();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Secret copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  )
                : Text(value),
          ),
        ],
      ),
    );
  }

  void _showSecret() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Secret Key'),
          content: Text(widget.entry.secret),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: widget.entry.secret));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Secret copied to clipboard')),
                );
                Navigator.pop(context);
              },
              child: const Text('Copy'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    final tags = tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final updatedEntry = widget.entry.copyWith(
      name: nameController.text,
      secret: secretController.text,
      issuer: issuerController.text,
      tags: tags,
      digits: int.tryParse(digitsController.text) ?? 6,
      period: int.tryParse(periodController.text) ?? 30,
      algorithm: algorithm,
      updatedAt: DateTime.now(),
    );

    ref.read(totpEntryRepositoryProvider).updateTotpEntry(updatedEntry);
    
    setState(() {
      isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('TOTP entry updated')),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete TOTP Entry'),
          content: Text('Are you sure you want to delete "${widget.entry.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(totpEntryRepositoryProvider).deleteTotpEntry(widget.entry.id!);
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
