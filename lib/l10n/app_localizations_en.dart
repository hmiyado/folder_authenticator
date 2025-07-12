// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Folder Authenticator';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get licenses => 'Licenses';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get aboutFolderAuthenticator => 'About Folder Authenticator';

  @override
  String get aboutDescription =>
      'A Flutter-based mobile application that allows you to manage your Time-based One-Time Passwords (TOTP) efficiently.';

  @override
  String get features => 'Features:';

  @override
  String get featureOrganizeWithFolders =>
      '• Organize TOTP entries into folders';

  @override
  String get featureSecureEncryption => '• Secure encryption of TOTP secrets';

  @override
  String get featureQRCodeScanning => '• QR code scanning for easy setup';

  @override
  String get featureExportFunctionality => '• Export functionality for backup';

  @override
  String get featureCleanIntuitive => '• Clean and intuitive user interface';

  @override
  String get featureOfflineAccess => '• Offline access to all your TOTP codes';

  @override
  String get featureHierarchicalOrganization =>
      '• Hierarchical organization with nested folders';

  @override
  String get featureRealTimeSync => '• Real-time synchronization of TOTP codes';

  @override
  String version(String version) {
    return 'Version: $version';
  }

  @override
  String get versionUnknown => 'Version: Unknown';

  @override
  String get versionLoading => 'Version: Loading...';

  @override
  String get close => 'Close';

  @override
  String get totpDetails => 'TOTP Details';

  @override
  String get export => 'Export';

  @override
  String refreshesIn(int seconds) {
    return 'Refreshes in $seconds seconds';
  }

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard';

  @override
  String get name => 'Name';

  @override
  String get issuer => 'Issuer';

  @override
  String get deleteTotpEntry => 'Delete TOTP Entry';

  @override
  String deleteConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get editTotp => 'Edit TOTP';

  @override
  String get totpEntryUpdated => 'TOTP entry updated';

  @override
  String get exportTotp => 'Export TOTP';

  @override
  String get copyUri => 'Copy URI';

  @override
  String get uriCopiedToClipboard => 'URI copied to clipboard';

  @override
  String get showSecret => 'Show Secret';

  @override
  String get secretCopiedToClipboard => 'Secret copied to clipboard';

  @override
  String get securityWarning =>
      'Warning: Keep this secret secure and do not share it with anyone.';

  @override
  String get editFolder => 'Edit Folder';

  @override
  String get deleteFolder => 'Delete Folder';

  @override
  String deleteFolderConfirmation(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get folderName => 'Folder Name';

  @override
  String get selectFolderPath => 'Select Folder Path';

  @override
  String get folderPathSelectionDialog => 'Folder path selection dialog';

  @override
  String get ok => 'OK';

  @override
  String get save => 'Save';

  @override
  String get addNew => 'Add New';

  @override
  String get addTotpManually => 'Add TOTP Manually';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get addFolder => 'Add Folder';

  @override
  String folderCreated(String name) {
    return 'Folder \"$name\" created';
  }

  @override
  String errorCreatingFolder(String error) {
    return 'Error creating folder: $error';
  }

  @override
  String get add => 'Add';

  @override
  String get addTotp => 'Add TOTP';

  @override
  String get secret => 'Secret';

  @override
  String get issuerOptional => 'Issuer (optional)';

  @override
  String get totpEntryAddedSuccessfully => 'TOTP entry added successfully';

  @override
  String get invalidTotpQrCode => 'Invalid TOTP QR code';

  @override
  String errorProcessingQrCode(String error) {
    return 'Error processing QR code: $error';
  }

  @override
  String get root => 'Root';

  @override
  String errorLoadingFolderEntries(String error) {
    return 'Error loading folder entries: $error';
  }

  @override
  String get noTotpEntriesOrSubfolders => 'No TOTP entries or subfolders found';

  @override
  String get errorLoadingTotpEntry => 'Error loading TOTP entry';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get systemDefault => 'System Default';
}
