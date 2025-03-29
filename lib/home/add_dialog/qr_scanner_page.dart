import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:totp_folder/home/home_page_providers.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';
import 'package:totp_folder/services/totp_service.dart';
import 'package:totp_folder/totp_detail/totp_detail_providers.dart';

class QrScannerPage extends ConsumerStatefulWidget {
  final int folderId;

  const QrScannerPage({super.key, required this.folderId});

  @override
  ConsumerState<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends ConsumerState<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off);
                  case TorchState.on:
                    return const Icon(Icons.flash_on);
                }
              },
            ),
            onPressed: () => controller.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: controller.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            onPressed: () => controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _onDetect),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      if (barcode.rawValue == null) continue;

      final String rawValue = barcode.rawValue!;

      // Check if it's a TOTP URI
      if (rawValue.startsWith('otpauth://totp/')) {
        setState(() {
          _isProcessing = true;
        });

        try {
          final totpService = ref.read(totpServiceProvider);
          final totpData = totpService.parseTotpUri(rawValue);

          if (totpData != null) {
            // Validate the secret
            if (!totpService.isValidSecret(totpData['secret'])) {
              _showErrorAndReset('Invalid TOTP secret');
              return;
            }

            // Create the TOTP entry with all parameters from QR code
            final entryIdFuture = ref.read(
              createTotpEntryProvider(
                widget.folderId,
                totpData['name'],
                totpData['secret'],
                totpData['issuer'],
              ),
            );

            final entryId = await entryIdFuture.when(
              data: (id) => id,
              loading: () => -1,
              error: (_, __) => -1,
            );

            // Update the entry with additional parameters if needed
            if (entryId > 0 &&
                (totpData['digits'] != 6 ||
                    totpData['period'] != 30 ||
                    totpData['algorithm'] != 'SHA1')) {
              // Get the created entry
              final entry = await ref
                  .read(totpEntryRepositoryProvider)
                  .getTotpEntry(entryId);
              if (entry != null) {
                // Update with additional parameters
                ref.read(updateTotpEntryProvider(entry));
              }
            }

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('TOTP entry added successfully')),
              );
              Navigator.pop(context);
            }
          } else {
            _showErrorAndReset('Invalid TOTP QR code');
          }
        } catch (e) {
          _showErrorAndReset('Error processing QR code: $e');
        }
      }
    }
  }

  void _showErrorAndReset(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
