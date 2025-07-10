import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/folder_edit/folder_edit_page.dart';
import 'package:folder_authenticator/home/add_dialog/add_dialog.dart';
import 'package:folder_authenticator/home/folder/folder_entries_provider.dart';
import 'package:folder_authenticator/home/totp_entry_card.dart';
import 'package:folder_authenticator/models/folder.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class FolderView extends ConsumerWidget {
  final int folderId;

  const FolderView({super.key, required this.folderId});

  Widget _buildFolderPathText(BuildContext context, List<Folder> folderPath) {
    const textStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    if (folderPath.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.folder, size: 20),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.root, style: textStyle),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (folderPath.isEmpty) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FolderEditPage(folder: folderPath.last),
                ),
              );
            },
            child: Row(
              children: [
                const Icon(Icons.folder, size: 20),
                const SizedBox(width: 8),
                Text(
                  folderPath.map((folder) => folder.name).join(' / '),
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddDialog(folder: folderPath.last),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFolderEntries = ref.watch(allFolderEntriesProvider(folderId));

    return allFolderEntries.when(
      data: (allFolderEntries) {
        return _buildFolderEntries(context, allFolderEntries);
      },
      error: (error, stack) {
        return Center(child: Text(AppLocalizations.of(context)!.errorLoadingFolderEntries(error.toString())));
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFolderEntries(
    BuildContext context,
    List<FolderEntries> allFolderEntries,
  ) {
    if (allFolderEntries.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noTotpEntriesOrSubfolders));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: allFolderEntries
                .map((folderEntries) {
                  final header = Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      top: 16.0,
                      bottom: 8.0,
                    ),
                    child: _buildFolderPathText(
                      context,
                      folderEntries.folderPath,
                    ),
                  );

                  if (folderEntries.entries.isEmpty) {
                    return [
                      header,
                      Center(
                        child: Text(AppLocalizations.of(context)!.noTotpEntriesOrSubfolders),
                      ),
                    ];
                  }

                  final totpEntries =
                      folderEntries.entries
                          .map((entry) => TotpEntryCard(entry: entry))
                          .toList();

                  return [header, ...totpEntries];
                })
                .reduce(
                  (allFolderEntries, folderEntries) =>
                      allFolderEntries + folderEntries,
                ),
          ),
        ),
      ],
    );
  }
}
