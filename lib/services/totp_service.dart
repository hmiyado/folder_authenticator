import 'dart:async';
import 'package:base32/base32.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:otp/otp.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:totp_folder/models/totp_entry.dart';

part 'totp_service.g.dart';

// Provider for the TotpService
@riverpod
TotpService totpService(Ref ref) {
  final timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
    ref.invalidateSelf(); // Invalidate the provider to trigger a rebuild
  });

  // Clean up when the provider is disposed
  ref.onDispose(() {
    timer.cancel();
  });

  return TotpService();
}

class TotpService {
  // Generate a TOTP code based on the entry's parameters
  String generateTotp(TotpEntry entry) {
    try {
      // Generate the OTP directly from the base32 secret
      return OTP.generateTOTPCodeString(
        entry.secret.toUpperCase(),
        DateTime.now().millisecondsSinceEpoch,
        length: entry.digits,
        interval: entry.period,
        algorithm: _getAlgorithm(entry.algorithm),
        isGoogle: true,
      );
    } catch (e) {
      // Return error indicator if generation fails
      return 'ERROR';
    }
  }

  // Calculate the remaining time until the next TOTP refresh
  int getRemainingMilliSeconds(TotpEntry entry) {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final entryPeriodMillis = entry.period * 1000;
    final elapsedSeconds = currentTime % entryPeriodMillis;
    return entryPeriodMillis - elapsedSeconds;
  }

  // Convert string algorithm to OTP.Algorithm enum
  Algorithm _getAlgorithm(String algorithm) {
    switch (algorithm.toUpperCase()) {
      case 'SHA256':
        return Algorithm.SHA256;
      case 'SHA512':
        return Algorithm.SHA512;
      case 'SHA1':
      default:
        return Algorithm.SHA1;
    }
  }

  // Validate a TOTP secret
  bool isValidSecret(String secret) {
    try {
      // Try to decode the secret to check if it's valid base32
      base32.decode(secret.toUpperCase());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Parse TOTP URI and extract parameters
  Map<String, dynamic>? parseTotpUri(String uri) {
    try {
      // Parse the URI
      final Uri parsedUri = Uri.parse(uri);

      if (parsedUri.scheme != 'otpauth' || parsedUri.host != 'totp') {
        return null;
      }

      // Extract the path (which contains the label)
      final String path = parsedUri.path;
      if (path.isEmpty || path == '/') {
        return null;
      }

      // The path is in the format "/label" or "/issuer:label"
      String label = path.substring(1); // Remove leading '/'
      String? issuer = parsedUri.queryParameters['issuer'];

      // If the label contains a colon, it might have the issuer in it
      if (label.contains(':')) {
        final parts = label.split(':');
        if (issuer == null || issuer.isEmpty) {
          issuer = parts[0].trim();
        }
        label = parts[1].trim();
      }

      // Get the secret from query parameters
      final String? secret = parsedUri.queryParameters['secret'];
      if (secret == null || secret.isEmpty) {
        return null;
      }

      // Get optional parameters with defaults
      final String algorithm = parsedUri.queryParameters['algorithm'] ?? 'SHA1';
      final int digits =
          int.tryParse(parsedUri.queryParameters['digits'] ?? '') ?? 6;
      final int period =
          int.tryParse(parsedUri.queryParameters['period'] ?? '') ?? 30;

      return {
        'name': label,
        'secret': secret,
        'issuer': issuer ?? '',
        'algorithm': algorithm,
        'digits': digits,
        'period': period,
      };
    } catch (e) {
      return null;
    }
  }
  
  // Generate otpauth URI for a TOTP entry
  String generateOtpauthUri(TotpEntry entry) {
    // Format: otpauth://totp/{issuer}:{name}?secret={secret}&issuer={issuer}&algorithm={algorithm}&digits={digits}&period={period}
    final label = entry.issuer.isNotEmpty 
        ? '${Uri.encodeComponent(entry.issuer)}:${Uri.encodeComponent(entry.name)}'
        : Uri.encodeComponent(entry.name);
    
    return 'otpauth://totp/$label?'
        'secret=${entry.secret}'
        '&issuer=${Uri.encodeComponent(entry.issuer)}'
        '&algorithm=${entry.algorithm}'
        '&digits=${entry.digits}'
        '&period=${entry.period}';
  }
}
