import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder/subfolders_provider.dart';
import 'package:totp_folder/home/home_page_providers.dart';

class AddFolderDialog extends ConsumerStatefulWidget {
  final int folderId;

  const AddFolderDialog({super.key, required this.folderId});

  @override
  ConsumerState<AddFolderDialog> createState() => _AddFolderDialogState();
}

class _AddFolderDialogState extends ConsumerState<AddFolderDialog> {
  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final iconController = TextEditingController(text: '');

    return AlertDialog(
      title: const Text('Add Folder'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Folder Name'),
          ),
          TextField(
            controller: iconController,
            decoration: const InputDecoration(labelText: 'Icon'),
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
              final folderFuture = ref.read(
                createSubFolderProvider(
                  widget.folderId,
                  nameController.text,
                  iconController.text,
                ),
              );

              // Wait for the folder to be created
              folderFuture.when(
                data: (folder) {
                  // Invalidate the subfolders provider to refresh the UI
                  ref.invalidate(subfoldersProvider(parentId: widget.folderId));

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Folder "${nameController.text}" created'),
                    ),
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
  }
}
