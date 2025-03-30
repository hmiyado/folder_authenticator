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
  final colorController = TextEditingController();
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
    colorController.dispose();
    folderPathController.dispose();
    super.dispose();
  }

  void _saveFolder() {
    if (_formKey.currentState!.validate()) {
      ref.read(updateFolderProvider(
        widget.folder.id,
        folderName: nameController.text == widget.folder.name ? null : nameController.text,
        color: colorController.text == widget.folder.color ? null : colorController.text,
        parentId: parentFolderId == widget.folder.parentId ? null : parentFolderId,
      ));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final folderPath = ref.read(folderPathProvider(folderId: parentFolderId))
      .valueOrNull
      ?.map((f) => f.name)
      .join('/')
      ?? widget.folder.name;
    nameController.text = widget.folder.name;
    colorController.text = widget.folder.color;
    folderPathController.text = folderPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Folder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a folder name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Color',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              DropdownButton(
                value: folderPathController.text,
                items: [],
                onChanged: (value) => folderPathController.text = value.toString(),
                onTap: () => showDialog(
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
              ElevatedButton(
                onPressed: _saveFolder,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}