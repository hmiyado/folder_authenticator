import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/settings/settings_page_viewmodel.dart';

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
            subtitle: const Text('Folder Authenticator'),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Licenses'),
            subtitle: const Text('Open Source Licenses'),
            onTap: () async {
              final version = await ref
                  .read(settingsPageViewModelProvider)
                  .getAppVersion();
              if (context.mounted) {
                showLicensePage(
                  context: context,
                  applicationName: 'Folder Authenticator',
                  applicationVersion: version,
                );
              }
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
              title: const Text('About Folder Authenticator'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Folder Authenticator is a Flutter-based mobile application that allows you to manage your Time-based One-Time Passwords (TOTP) efficiently.',
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
                  FutureBuilder<String>(
                    future: viewModel.getAppVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text('Version: ${snapshot.data}');
                      } else if (snapshot.hasError) {
                        return const Text('Version: Unknown');
                      } else {
                        return const Text('Version: Loading...');
                      }
                    },
                  ),
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
