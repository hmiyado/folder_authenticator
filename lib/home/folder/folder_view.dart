import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder/folder_entries_provider.dart';
import 'package:totp_folder/home/totp_entry_card.dart';
import 'package:totp_folder/models/folder.dart';

class FolderView extends ConsumerWidget {
  final int folderId;

  const FolderView({
    super.key,
    required this.folderId,
  });
  
  Widget _buildFolderPathText(List<Folder> folderPath) {
    const textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    
    if (folderPath.isEmpty) {
      return const Row(
        children: [
          Icon(Icons.folder, size: 20),
          SizedBox(width: 8),
          Text(
            'Root',
            style: textStyle,
          ),
        ],
      );
    }
    
    return Row(
      children: [
        const Icon(Icons.folder, size: 20),
        const SizedBox(width: 8),
        Text(
          folderPath.map((folder) => folder.name).join(' / '),
          style: textStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allFolderEntries = ref.watch(allFolderEntriesProvider(folderId));
    if (allFolderEntries.isEmpty) {
      return const Center(
        child: Text('No TOTP entries or subfolders found'),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ListView(
            children: allFolderEntries.map((folderEntries){
              if (folderEntries.entries.isEmpty) {
                return [const Center(
                  child: Text('No TOTP entries or subfolders found'),
                )];
              }

              final header = Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
                  child: _buildFolderPathText(folderEntries.folderPath),
                );

              final totpEntries = folderEntries.entries.map(
                  (entry) => TotpEntryCard(entry: entry),
                ).toList();

              return [
                header,
                ...totpEntries,
              ];
            }).reduce((allFolderEntries, folderEntries) => allFolderEntries + folderEntries)
          )
        ),
        ],
    );
  }
}
