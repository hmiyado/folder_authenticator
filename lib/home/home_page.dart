import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder/folder_view.dart';
import 'package:totp_folder/home/folder/subfolders_provider.dart';
import 'package:totp_folder/home/qr_scanner_page.dart';
import 'package:totp_folder/settings/settings_page.dart';
import 'package:totp_folder/home/home_page_providers.dart';

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
        title: const Text('TOTP Folder'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
          ),
        ],
      ),
      body: FolderView(folderId: currentFolder.id),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.key),
                title: const Text('Add TOTP Manually'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTotpDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan QR Code'),
                onTap: () {
                  Navigator.pop(context);
                  _openQrScanner(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Add Folder'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddFolderDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openQrScanner(BuildContext context) {
    final currentFolder = ref.watch(currentFolderProvider);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QrScannerPage(folderId: currentFolder.id),
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context) {
    final currentFolder = ref.watch(currentFolderProvider);
    final nameController = TextEditingController();
    final colorController = TextEditingController(text: '#3498db');
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Folder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                ),
              ),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color (hex)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  // Create the subfolder
                  final folderFuture = ref.read(createSubFolderProvider(
                    currentFolder.id,
                    nameController.text,
                    colorController.text,
                  ));
                  
                  // Wait for the folder to be created
                  folderFuture.when(
                    data: (folder) {
                      // Invalidate the subfolders provider to refresh the UI
                      ref.invalidate(subfoldersProvider(parentId: currentFolder.id));
                      
                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Folder "${nameController.text}" created')),
                      );
                    },
                    loading: () => null,
                    error: (error, stack) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error creating folder: $error')),
                      );
                    },
                  );
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTotpDialog(BuildContext context) {
    final nameController = TextEditingController();
    final secretController = TextEditingController();
    final issuerController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add TOTP'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    labelText: 'Issuer (optional)',
                  ),
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
                final currentFolder = ref.watch(currentFolderProvider);
                ref.read(createTotpEntryProvider(
                  currentFolder.id,
                  nameController.text,
                  secretController.text,
                  issuerController.text
                ));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
