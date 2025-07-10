import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/folder_edit/folder_edit_providers.dart';
import 'package:folder_authenticator/home/folder/folder_path_provider.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class FolderEditPage extends ConsumerStatefulWidget {
  final Folder folder;

  const FolderEditPage({super.key, required this.folder});

  @override
  ConsumerState<FolderEditPage> createState() => _FolderEditPageState();
}

class _FolderEditPageState extends ConsumerState<FolderEditPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
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
          parentId:
              // Prevent changing parent of root folder
              widget.folder.id == Folder.rootFolderId || parentFolderId == widget.folder.parentId 
                  ? null 
                  : parentFolderId,
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
    folderPathController.text = folderPath;

    final isRootFolder = widget.folder.id == Folder.rootFolderId;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.editFolder),
        actions: [
          // Hide delete button for root folder
          if (!isRootFolder)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(AppLocalizations.of(context)!.deleteFolder),
                        content: Text(
                          AppLocalizations.of(context)!.deleteFolderConfirmation(widget.folder.name),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              ref.read(deleteFolderProvider(widget.folder.id));
                              Navigator.of(context).pop(); // Close dialog
                              Navigator.of(
                                context,
                              ).pop(); // Return to previous screen
                            },
                            child: Text(AppLocalizations.of(context)!.delete),
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
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.folderName,
                ),
              ),
              // Hide folder path selector for root folder
              if (!isRootFolder)
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
                            title: Text(AppLocalizations.of(context)!.selectFolderPath),
                            content: Text(AppLocalizations.of(context)!.folderPathSelectionDialog),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(AppLocalizations.of(context)!.ok),
                              ),
                            ],
                          );
                        },
                      ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _saveFolder, child: Text(AppLocalizations.of(context)!.save)),
            ],
          ),
        ),
      ),
    );
  }
}
