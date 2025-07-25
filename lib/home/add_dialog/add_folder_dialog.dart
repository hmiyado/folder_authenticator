import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/home/folder/subfolders_provider.dart';
import 'package:folder_authenticator/home/home_page_providers.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

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

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.addFolder),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: AppLocalizations.of(context)!.folderName),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: () async {
            if (nameController.text.isNotEmpty) {
              // Create the subfolder
              final folderFuture = ref.read(
                createSubFolderProvider(
                  widget.folderId,
                  nameController.text
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
                      content: Text(AppLocalizations.of(context)!.folderCreated(nameController.text)),
                    ),
                  );
                },
                loading: () => null,
                error: (error, stack) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.errorCreatingFolder(error.toString()))),
                  );
                },
              );
            }
            Navigator.pop(context);
          },
          child: Text(AppLocalizations.of(context)!.add),
        ),
      ],
    );
  }
}
