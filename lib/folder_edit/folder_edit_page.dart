import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/folder_edit/folder_edit_providers.dart';
import 'package:totp_folder/home/folder/folder_path_provider.dart';
import 'package:totp_folder/models/folder.dart';

class FolderEditPage extends ConsumerStatefulWidget {
  final Folder folder;

  const FolderEditPage({super.key, required this.folder});

  @override
  ConsumerState<FolderEditPage> createState() => _FolderEditPageState();
}

class _FolderEditPageState extends ConsumerState<FolderEditPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final iconController = TextEditingController();
  final folderPathController = TextEditingController();
  var parentFolderId = 0;

  @override
  void initState() {
    super.initState();
    parentFolderId = widget.folder.parentId;
  }

  @override
  void dispose() {
    nameController.dispose();
    iconController.dispose();
    folderPathController.dispose();
    super.dispose();
  }

  void _saveFolder() {
    if (_formKey.currentState!.validate()) {
      ref.read(
        updateFolderProvider(
          widget.folder.id,
          folderName:
              nameController.text == widget.folder.name
                  ? null
                  : nameController.text,
          icon:
              iconController.text == widget.folder.icon
                  ? null
                  : iconController.text,
          parentId:
              parentFolderId == widget.folder.parentId ? null : parentFolderId,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderPath =
        ref
            .read(folderPathProvider(folderId: parentFolderId))
            .valueOrNull
            ?.map((f) => f.name)
            .join('/') ??
        widget.folder.name;
    nameController.text = widget.folder.name;
    iconController.text = widget.folder.icon;
    folderPathController.text = folderPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Folder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Delete Folder'),
                      content: Text(
                        'Are you sure you want to delete "${widget.folder.name}"?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            ref.read(deleteFolderProvider(widget.folder.id));
                            Navigator.of(context).pop(); // Close dialog
                            Navigator.of(
                              context,
                            ).pop(); // Return to previous screen
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'Icon',
                ),
              ),
              DropdownButton(
                value: folderPathController.text,
                items: [],
                onChanged:
                    (value) => folderPathController.text = value.toString(),
                onTap:
                    () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Select Folder Path'),
                          content: const Text('Folder path selection dialog'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveFolder, child: const Text('Save')),
            ],
          ),
        ),
      ),
    );
  }
}
