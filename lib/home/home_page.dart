import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder/folder_view.dart';
import 'package:totp_folder/settings/settings_page.dart';
import 'package:totp_folder/home/tag/tag_view.dart';
import 'package:totp_folder/home/home_page_viewmodel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(homePageViewModelProvider);
    final viewMode = ref.watch(viewModeProvider);
    final currentFolderId = ref.watch(currentFolderProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TOTP Folder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder),
            onPressed: () {
              viewModel.switchToFolderView();
            },
          ),
          IconButton(
            icon: const Icon(Icons.tag),
            onPressed: () {
              viewModel.switchToTagView();
            },
          ),
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
      body: viewMode == ViewMode.folder
          ? FolderView(folderId: currentFolderId)
          : TagView(tag: selectedTag),
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
                title: const Text('Add TOTP'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddTotpDialog(context);
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

  void _showAddFolderDialog(BuildContext context) {
    final viewModel = ref.read(homePageViewModelProvider);
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
              onPressed: () {
                viewModel.createFolder(
                  nameController.text,
                  colorController.text,
                );
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
    final viewModel = ref.read(homePageViewModelProvider);
    final nameController = TextEditingController();
    final secretController = TextEditingController();
    final issuerController = TextEditingController();
    final tagsController = TextEditingController();
    
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
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (comma separated)',
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
                final tags = viewModel.parseTagsFromString(tagsController.text);
                
                viewModel.createTotpEntry(
                  name: nameController.text,
                  secret: secretController.text,
                  issuer: issuerController.text,
                  tags: tags,
                );
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
