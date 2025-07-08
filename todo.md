# Multi-Language Support Implementation Todo

## Overview
Implementation of internationalization (i18n) for Japanese and other languages in the Flutter TOTP Folder Authenticator app.

## Current State
- No existing i18n setup
- 20+ files with hardcoded English strings
- 60+ individual strings requiring translation
- Complete setup needed from scratch

## High Priority Tasks

### 1. Setup i18n Dependencies
- [x] Add internationalization packages to pubspec.yaml (flutter_localizations, intl, intl_utils)

### 2. Create l10n Configuration
- [x] Create l10n.yaml configuration file for code generation

### 3. Create ARB Files
- [x] Create ARB files for English (app_en.arb) and Japanese (app_ja.arb) localizations

### 4. Configure MaterialApp
- [x] Update MaterialApp in main.dart with localizationsDelegates and supportedLocales

## Medium Priority Tasks

### 5. Main App Localization
- [x] Replace hardcoded strings in main.dart with localized versions

### 6. Home Page Localization
- [x] Replace hardcoded strings in home_page.dart with localized versions

### 7. Settings Page Localization
- [x] Replace hardcoded strings in settings_page.dart with localized versions (includes about dialog)

### 8. TOTP Detail Page Localization
- [x] Replace hardcoded strings in totp_detail_page.dart with localized versions

### 9. TOTP Edit Page Localization
- [ ] Replace hardcoded strings in totp_edit_page.dart with localized versions

### 10. TOTP Export Dialog Localization
- [ ] Replace hardcoded strings in totp_export_dialog.dart with localized versions

### 11. Folder Edit Page Localization
- [ ] Replace hardcoded strings in folder_edit_page.dart with localized versions

### 12. Add Dialogs Localization
- [ ] Replace hardcoded strings in add_dialog.dart, add_folder_dialog.dart, and add_totp_entry_dialog.dart

### 13. QR Scanner Localization
- [ ] Replace hardcoded strings in qr_scanner_page.dart with localized versions

### 14. Folder View Localization
- [ ] Replace hardcoded strings in folder_view.dart with localized versions

### 15. TOTP Entry Card Localization
- [ ] Replace hardcoded strings in totp_entry_card.dart with localized versions

### 16. Generate Localization Files
- [x] Run dart run build_runner build to generate localization files

### 17. Add Japanese Translations
- [x] Add comprehensive Japanese translations to app_ja.arb file

### 18. Test Localization
- [ ] Test app with different locales and ensure proper fallback behavior

## Low Priority Tasks

### 19. Language Selection Feature
- [ ] Add language selection option in settings page

## Files Requiring Localization

### Core App Files
- `lib/main.dart` - App title
- `lib/home/home_page.dart` - Main navigation
- `lib/settings/settings_page.dart` - Settings and about dialog

### TOTP Management Files
- `lib/totp_detail/totp_detail_page.dart` - TOTP details view
- `lib/totp_detail/totp_edit_page.dart` - TOTP editing
- `lib/totp_detail/totp_export_dialog.dart` - Export functionality

### Folder Management Files
- `lib/folder_edit/folder_edit_page.dart` - Folder editing
- `lib/home/folder/folder_view.dart` - Folder display

### Add/Create Files
- `lib/home/add_dialog/add_dialog.dart` - Main add dialog
- `lib/home/add_dialog/add_folder_dialog.dart` - Add folder dialog
- `lib/home/add_dialog/add_totp_entry_dialog.dart` - Add TOTP dialog
- `lib/home/add_dialog/qr_scanner_page.dart` - QR code scanner

### UI Components
- `lib/home/totp_entry_card.dart` - TOTP entry display

## Implementation Notes

### Required Dependencies
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

dev_dependencies:
  intl_utils: ^2.8.7
```

### l10n.yaml Configuration
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### MaterialApp Configuration
```dart
MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  // ...
)
```

### String Usage Pattern
Replace hardcoded strings like:
```dart
// Before
Text('Settings')

// After
Text(AppLocalizations.of(context)!.settings)
```

## Translation Requirements

### Japanese Translations Needed
- App title: "フォルダオーセンティケータ"
- Navigation: "設定", "追加", "戻る"
- TOTP terms: "認証コード", "秘密鍵", "発行者"
- Actions: "コピー", "削除", "保存", "キャンセル"
- Messages: Success/error messages in Japanese
- Time formats: "秒", "残り時間"

### String Categories
1. **Navigation** - Menu items, page titles
2. **Actions** - Button labels, confirmation dialogs
3. **Forms** - Input labels, validation messages
4. **Notifications** - Success/error messages
5. **Time/Date** - Time remaining, formatting
6. **Security** - Encryption warnings, sensitive data alerts

## Previous Tasks
- fastlane の導入
