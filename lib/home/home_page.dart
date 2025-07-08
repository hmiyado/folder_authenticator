import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/home/folder/folder_view.dart';
import 'package:folder_authenticator/settings/settings_page.dart';
import 'package:folder_authenticator/home/home_page_providers.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final currentFolder = ref.watch(currentFolderProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'settings',
                    child: Text(AppLocalizations.of(context)!.settings),
                  ),
                ],
          ),
        ],
      ),
      body: FolderView(folderId: currentFolder.id),
    );
  }
}
