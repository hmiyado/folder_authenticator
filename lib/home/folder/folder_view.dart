import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:totp_folder/home/folder/folder_entries_provider.dart';
import 'package:totp_folder/home/folder/folder_path_provider.dart';
import 'package:totp_folder/home/home_page_providers.dart';
import 'package:totp_folder/home/totp_entry_card.dart';
import 'package:totp_folder/models/folder.dart';

class FolderView extends ConsumerWidget {
  final int folderId;

  const FolderView({
    super.key,
    required this.folderId,
  });
  
  Widget _buildFolderPathDisplay(List<Folder> folderPath) {
    if (folderPath.isEmpty) {
      return const Text('Root');
    }
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < folderPath.length; i++) ...[
            if (i > 0) 
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(Icons.chevron_right, size: 16),
              ),
            Text(
              folderPath[i].name,
              style: TextStyle(
                fontWeight: i == folderPath.length - 1 ? FontWeight.bold : FontWeight.normal,
                color: i == folderPath.length - 1 
                    ? Colors.black 
                    : Colors.grey[700],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFolderItem(BuildContext context, Folder folder, WidgetRef ref) {
    return ListTile(
      leading: Icon(
        Icons.folder,
        color: Color(int.parse(folder.color.replaceFirst('#', '0xFF'))),
      ),
      title: Text(folder.name),
      onTap: () {
        ref.read(currentFolderProvider.notifier).setCurrentFolder(folder.id!);
      },
    );
  }

  Widget _buildFolderPathText(List<Folder> folderPath) {
    if (folderPath.isEmpty) {
      return const Text(
        'Root',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }
    
    return Text(
      folderPath.map((folder) => folder.name).join(' / '),
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderPathAsyncValue = ref.watch(folderPathProvider(folderId: folderId));
    final allFolderEntries = ref.watch(allFolderEntriesProvider(folderId));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Folder path navigation display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: folderPathAsyncValue.when(
            data: (folderPath) {
              return _buildFolderPathDisplay(folderPath);
            },
            loading: () => const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (_, __) => const Text('Error loading folder path'),
          ),
        ),
        const Divider(),
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
