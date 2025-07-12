import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folder_authenticator/totp_detail/totp_detail_page.dart';
import 'package:folder_authenticator/totp_detail/totp_edit_page.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/totp_detail/totp_detail_providers.dart';
import 'package:folder_authenticator/l10n/app_localizations.dart';

class TotpEntryCard extends ConsumerStatefulWidget {
  final TotpEntry entry;

  const TotpEntryCard({super.key, required this.entry});

  @override
  ConsumerState<TotpEntryCard> createState() => _TotpEntryCardState();
}

class _TotpEntryCardState extends ConsumerState<TotpEntryCard> {
  @override
  Widget build(BuildContext context) {
    // Watch the providers to get the latest values
    final totpCode = ref.watch(generateTotpProvider(widget.entry));
    final remainingSeconds = ref.watch(remainingSecondsProvider(widget.entry));
    final totpEntry = ref.watch(totpEntryProvider(widget.entry));

    return totpEntry.when(
      data: (data) => _buildContent(context, data, totpCode, remainingSeconds),
      error:
          (error, stack) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(title: Text(AppLocalizations.of(context)!.errorLoadingTotpEntry)),
          ),
      loading:
          () => const Card(
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(title: Center(child: CircularProgressIndicator())),
          ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TotpEntry totpEntry,
    String totpCode,
    int remainingSeconds,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Dismissible(
        key: Key('totp_entry_${totpEntry.id}'),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await _showDeleteConfirmation(context);
          } else if (direction == DismissDirection.startToEnd) {
            _navigateToEdit(context);
            return false;
          }
          return false;
        },
        background: Container(
          color: Colors.blue,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.edit, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.editTotp,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.delete, color: Colors.white),
            ],
          ),
        ),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            _deleteTotpEntry(context);
          }
        },
        child: ListTile(
          title: Text(totpEntry.name),
          subtitle: Text(totpEntry.issuer),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                totpCode,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(AppLocalizations.of(context)!.secondsShort(remainingSeconds)),
            ],
          ),
          onTap: () {
            Clipboard.setData(ClipboardData(text: totpCode));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.codeCopiedToClipboard),
              ),
            );
          },
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TotpDetailPage(entry: widget.entry),
              ),
            );
          },
        ),
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TotpEditPage(entry: widget.entry),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteTotpEntry),
          content: Text(AppLocalizations.of(context)!.deleteConfirmation(widget.entry.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.delete),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _deleteTotpEntry(BuildContext context) {
    ref.read(deleteTotpEntryProvider(widget.entry));
  }
}
