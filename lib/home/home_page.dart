import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder_view.dart';
import 'package:totp_folder/home/settings_page.dart';
import 'package:totp_folder/home/tag_view.dart';
import 'package:totp_folder/models/folder.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/folder_repository.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

// Current folder provider
final currentFolderProvider = StateProvider<int?>((ref) => null);

// Current view mode provider (folder or tag)
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.folder);

// Selected tag provider
final selectedTagProvider = StateProvider<String?>((ref) => null);

enum ViewMode { folder, tag }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
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
              ref.read(viewModeProvider.notifier).state = ViewMode.folder;
              ref.read(selectedTagProvider.notifier).state = null;
            },
          ),
          IconButton(
            icon: const Icon(Icons.tag),
            onPressed: () {
              ref.read(viewModeProvider.notifier).state = ViewMode.tag;
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
      drawer: Drawer(
        child: viewMode == ViewMode.folder
            ? _buildFolderNavigationDrawer()
            : _buildTagNavigationDrawer(),
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

  Widget _buildFolderNavigationDrawer() {
    return Consumer(
      builder: (context, ref, child) {
        final foldersAsyncValue = ref.watch(foldersProvider(null));
        
        return foldersAsyncValue.when(
          data: (folders) {
            return ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Folders',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('All TOTPs'),
                  onTap: () {
                    ref.read(currentFolderProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ...folders.map((folder) => _buildFolderListTile(folder)),
                ListTile(
                  leading: const Icon(Icons.create_new_folder),
                  title: const Text('Add Folder'),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddFolderDialog(context);
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }

  Widget _buildFolderListTile(Folder folder) {
    return Consumer(
      builder: (context, ref, child) {
        final subFoldersAsyncValue = ref.watch(foldersProvider(folder.id));
        
        return subFoldersAsyncValue.when(
          data: (subFolders) {
            return ExpansionTile(
              leading: Icon(
                Icons.folder,
                color: Color(int.parse(folder.color.substring(1, 7), radix: 16) + 0xFF000000),
              ),
              title: Text(folder.name),
              children: [
                ...subFolders.map((subFolder) => _buildFolderListTile(subFolder)),
                if (subFolders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No subfolders'),
                  ),
              ],
              onExpansionChanged: (expanded) {
                if (expanded) {
                  ref.read(currentFolderProvider.notifier).state = folder.id;
                  Navigator.pop(context);
                }
              },
            );
          },
          loading: () => ListTile(
            leading: Icon(
              Icons.folder,
              color: Color(int.parse(folder.color.substring(1, 7), radix: 16) + 0xFF000000),
            ),
            title: Text(folder.name),
            trailing: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          error: (error, stack) => ListTile(
            leading: const Icon(Icons.error),
            title: Text('Error: $error'),
          ),
        );
      },
    );
  }

  Widget _buildTagNavigationDrawer() {
    return Consumer(
      builder: (context, ref, child) {
        final tagsAsyncValue = ref.watch(allTagsProvider);
        
        return tagsAsyncValue.when(
          data: (tags) {
            return ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Tags',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.tag),
                  title: const Text('All Tags'),
                  onTap: () {
                    ref.read(selectedTagProvider.notifier).state = null;
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                ...tags.map((tag) => ListTile(
                  leading: const Icon(Icons.tag),
                  title: Text(tag),
                  onTap: () {
                    ref.read(selectedTagProvider.notifier).state = tag;
                    Navigator.pop(context);
                  },
                )),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
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
                final currentFolderId = ref.read(currentFolderProvider);
                final folder = Folder(
                  name: nameController.text,
                  color: colorController.text,
                  parentId: currentFolderId,
                );
                
                ref.read(folderRepositoryProvider).createFolder(folder);
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
                final currentFolderId = ref.read(currentFolderProvider);
                final tags = tagsController.text
                    .split(',')
                    .map((tag) => tag.trim())
                    .where((tag) => tag.isNotEmpty)
                    .toList();
                
                final entry = TotpEntry(
                  name: nameController.text,
                  secret: secretController.text,
                  issuer: issuerController.text,
                  folderId: currentFolderId,
                  tags: tags,
                );
                
                ref.read(totpEntryRepositoryProvider).createTotpEntry(entry);
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
