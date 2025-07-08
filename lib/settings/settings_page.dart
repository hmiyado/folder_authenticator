import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/settings/settings_page_viewmodel.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(settingsPageViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context)!.about),
            subtitle: Text(AppLocalizations.of(context)!.appTitle),
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(AppLocalizations.of(context)!.licenses),
            subtitle: Text(AppLocalizations.of(context)!.openSourceLicenses),
            onTap: () async {
              final version = await ref
                  .read(settingsPageViewModelProvider)
                  .getAppVersion();
              if (context.mounted) {
                showLicensePage(
                  context: context,
                  applicationName: AppLocalizations.of(context)!.appTitle,
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
              title: Text(AppLocalizations.of(context)!.aboutFolderAuthenticator),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.aboutDescription,
                  ),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.features),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureOrganizeWithFolders,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureSecureEncryption,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureQRCodeScanning,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureExportFunctionality,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureCleanIntuitive,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureOfflineAccess,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureHierarchicalOrganization,
                  ),
                  _buildFeatureItem(
                    AppLocalizations.of(context)!.featureRealTimeSync,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<String>(
                    future: viewModel.getAppVersion(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(AppLocalizations.of(context)!.version(snapshot.data!));
                      } else if (snapshot.hasError) {
                        return Text(AppLocalizations.of(context)!.versionUnknown);
                      } else {
                        return Text(AppLocalizations.of(context)!.versionLoading);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.close),
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
