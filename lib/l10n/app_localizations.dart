import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Folder Authenticator'**
  String get appTitle;

  /// Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Licenses menu item
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get licenses;

  /// Open source licenses title
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// About dialog title
  ///
  /// In en, this message translates to:
  /// **'About Folder Authenticator'**
  String get aboutFolderAuthenticator;

  /// About dialog description
  ///
  /// In en, this message translates to:
  /// **'A Flutter-based mobile application that allows you to manage your Time-based One-Time Passwords (TOTP) efficiently.'**
  String get aboutDescription;

  /// Features section title
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Organize TOTP entries into folders'**
  String get featureOrganizeWithFolders;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Secure encryption of TOTP secrets'**
  String get featureSecureEncryption;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• QR code scanning for easy setup'**
  String get featureQRCodeScanning;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Export functionality for backup'**
  String get featureExportFunctionality;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Clean and intuitive user interface'**
  String get featureCleanIntuitive;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Offline access to all your TOTP codes'**
  String get featureOfflineAccess;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Hierarchical organization with nested folders'**
  String get featureHierarchicalOrganization;

  /// Feature description
  ///
  /// In en, this message translates to:
  /// **'• Real-time synchronization of TOTP codes'**
  String get featureRealTimeSync;

  /// Version display
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String version(String version);

  /// Version when unknown
  ///
  /// In en, this message translates to:
  /// **'Version: Unknown'**
  String get versionUnknown;

  /// Version while loading
  ///
  /// In en, this message translates to:
  /// **'Version: Loading...'**
  String get versionLoading;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// TOTP details page title
  ///
  /// In en, this message translates to:
  /// **'TOTP Details'**
  String get totpDetails;

  /// Export button tooltip
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Countdown message
  ///
  /// In en, this message translates to:
  /// **'Refreshes in {seconds} seconds'**
  String refreshesIn(int seconds);

  /// Copy TOTP code button
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// Snackbar message when code is copied
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedToClipboard;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Issuer field label
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get issuer;

  /// Delete TOTP entry button
  ///
  /// In en, this message translates to:
  /// **'Delete TOTP Entry'**
  String get deleteTotpEntry;

  /// Delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteConfirmation(String name);

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit TOTP page title
  ///
  /// In en, this message translates to:
  /// **'Edit TOTP'**
  String get editTotp;

  /// Success message when TOTP entry is updated
  ///
  /// In en, this message translates to:
  /// **'TOTP entry updated'**
  String get totpEntryUpdated;

  /// Export TOTP dialog title
  ///
  /// In en, this message translates to:
  /// **'Export TOTP'**
  String get exportTotp;

  /// Copy URI button
  ///
  /// In en, this message translates to:
  /// **'Copy URI'**
  String get copyUri;

  /// URI copied message
  ///
  /// In en, this message translates to:
  /// **'URI copied to clipboard'**
  String get uriCopiedToClipboard;

  /// Show secret button
  ///
  /// In en, this message translates to:
  /// **'Show Secret'**
  String get showSecret;

  /// Secret copied message
  ///
  /// In en, this message translates to:
  /// **'Secret copied to clipboard'**
  String get secretCopiedToClipboard;

  /// Security warning message
  ///
  /// In en, this message translates to:
  /// **'Warning: Keep this secret secure and do not share it with anyone.'**
  String get securityWarning;

  /// Edit folder page title
  ///
  /// In en, this message translates to:
  /// **'Edit Folder'**
  String get editFolder;

  /// Delete folder button
  ///
  /// In en, this message translates to:
  /// **'Delete Folder'**
  String get deleteFolder;

  /// Delete folder confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String deleteFolderConfirmation(String name);

  /// Folder name field label
  ///
  /// In en, this message translates to:
  /// **'Folder Name'**
  String get folderName;

  /// Select folder path button
  ///
  /// In en, this message translates to:
  /// **'Select Folder Path'**
  String get selectFolderPath;

  /// Folder path selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Folder path selection dialog'**
  String get folderPathSelectionDialog;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Add new dialog title
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// Add TOTP manually button
  ///
  /// In en, this message translates to:
  /// **'Add TOTP Manually'**
  String get addTotpManually;

  /// Scan QR code button
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// Add folder button
  ///
  /// In en, this message translates to:
  /// **'Add Folder'**
  String get addFolder;

  /// Folder created success message
  ///
  /// In en, this message translates to:
  /// **'Folder \"{name}\" created'**
  String folderCreated(String name);

  /// Error creating folder message
  ///
  /// In en, this message translates to:
  /// **'Error creating folder: {error}'**
  String errorCreatingFolder(String error);

  /// Add button
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Add TOTP dialog title
  ///
  /// In en, this message translates to:
  /// **'Add TOTP'**
  String get addTotp;

  /// Secret field label
  ///
  /// In en, this message translates to:
  /// **'Secret'**
  String get secret;

  /// Optional issuer field label
  ///
  /// In en, this message translates to:
  /// **'Issuer (optional)'**
  String get issuerOptional;

  /// TOTP entry added success message
  ///
  /// In en, this message translates to:
  /// **'TOTP entry added successfully'**
  String get totpEntryAddedSuccessfully;

  /// Invalid QR code error message
  ///
  /// In en, this message translates to:
  /// **'Invalid TOTP QR code'**
  String get invalidTotpQrCode;

  /// QR code processing error
  ///
  /// In en, this message translates to:
  /// **'Error processing QR code: {error}'**
  String errorProcessingQrCode(String error);

  /// Root folder name
  ///
  /// In en, this message translates to:
  /// **'Root'**
  String get root;

  /// Error loading folder entries
  ///
  /// In en, this message translates to:
  /// **'Error loading folder entries: {error}'**
  String errorLoadingFolderEntries(String error);

  /// Empty folder message
  ///
  /// In en, this message translates to:
  /// **'No TOTP entries or subfolders found'**
  String get noTotpEntriesOrSubfolders;

  /// Error loading TOTP entry
  ///
  /// In en, this message translates to:
  /// **'Error loading TOTP entry'**
  String get errorLoadingTotpEntry;

  /// Seconds abbreviation
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// Language settings option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Japanese language option
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get japanese;

  /// System default language option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
