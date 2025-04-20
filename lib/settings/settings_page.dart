import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/settings/settings_page_viewmodel.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsPageViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            subtitle: const Text('TOTP Folder App'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Licenses'),
            subtitle: const Text('Open Source Licenses'),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'TOTP Folder',
                applicationVersion: ref
                    .read(settingsPageViewModelProvider)
                    .getAppVersion(),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final viewModel = ref.watch(settingsPageViewModelProvider);
            return AlertDialog(
              title: const Text('About TOTP Folder'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTP Folder is a Flutter-based mobile application that allows you to manage your Time-based One-Time Passwords (TOTP) efficiently.',
                  ),
                  const SizedBox(height: 16),
                  const Text('Features:'),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    'Folder Management: Organize TOTP entries into folders.',
                  ),
                  _buildFeatureItem(
                    'Tagging: Assign tags to TOTP entries for easier categorization.',
                  ),
                  _buildFeatureItem(
                    'Sorting & Filtering: Quickly find the TOTP you need.',
                  ),
                  const SizedBox(height: 16),
                  Text('Version: ${viewModel.getAppVersion()}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [const Text('• '), Expanded(child: Text(text))],
      ),
    );
  }
}
