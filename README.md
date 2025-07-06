# Folder Authenticator

Folder Authenticator is a Flutter-based mobile application that allows you to manage your Time-based One-Time Passwords (TOTP) efficiently. Organize your TOTP entries into folders, tag them for better categorization, and utilize sorting and filtering options for quick access.

## Features
- **Folder Management**: Organize TOTP entries into folders.
- **Tagging**: Assign tags to TOTP entries for easier categorization.
- **Sorting & Filtering**: Quickly find the TOTP you need with sorting and filtering options.

## Requirements
- Flutter SDK (latest stable version recommended)
- Dart (compatible with the Flutter version in use)
- A mobile device or emulator running Android or iOS

## Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/totp-folder.git
   cd totp-folder
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Generate code
    ```sh
    dart run build_runner build --delete-conflicting-outputs
    ```
4. Run the application:
   ```sh
   flutter run
   ```
5. Release the application:
   ```sh
   flutter build ipa --obfuscate --split-debug-info=vX.Y.Z
   ```
   Use Transporter to upload ipa.

## Development

```sh
# test
flutter test
```
