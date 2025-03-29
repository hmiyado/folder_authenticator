import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/totp_entry_card_providers.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/totp_detail/totp_detail_viewmodel.dart';

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
  late TextEditingController digitsController;
  late TextEditingController periodController;
  late String algorithm;
  bool isEditing = false;
  late TotpDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ref.read(totpDetailViewModelProvider(widget.entry));
    nameController = TextEditingController(text: _viewModel.name);
    secretController = TextEditingController(text: _viewModel.secret);
    issuerController = TextEditingController(text: _viewModel.issuer);
    digitsController = TextEditingController(text: _viewModel.digits.toString());
    periodController = TextEditingController(text: _viewModel.period.toString());
    algorithm = _viewModel.algorithm;
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
    final totpCode = ref.read(generateTotpProvider(widget.entry));
    final remainingSeconds = ref.read(remainingSecondsProvider(widget.entry));
    final progressValue = ref.read(progressValueProvider(widget.entry));

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
                      value: progressValue,
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
              _buildInfoRow('Name', _viewModel.name),
              _buildInfoRow('Issuer', _viewModel.issuer),
              _buildInfoRow('Secret', _viewModel.secret, obscure: true),
              _buildInfoRow('Digits', _viewModel.digits.toString()),
              _buildInfoRow('Period', '${_viewModel.period} seconds'),
              _buildInfoRow('Algorithm', _viewModel.algorithm),
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
          content: Text(_viewModel.secret),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _viewModel.secret));
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
    _viewModel.updateTotpEntry(
      name: nameController.text,
      secret: secretController.text,
      issuer: issuerController.text,
      digits: int.tryParse(digitsController.text) ?? 6,
      period: int.tryParse(periodController.text) ?? 30,
      algorithm: algorithm,
    );
    
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
          content: Text('Are you sure you want to delete "${_viewModel.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _viewModel.deleteTotpEntry();
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
