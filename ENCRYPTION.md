# TOTP Secret Encryption

This document describes how TOTP secrets are encrypted in the TOTP Folder application.

## Overview

TOTP secrets are sensitive information that should be protected. This application encrypts TOTP secrets before storing them in the database, and decrypts them when they need to be used to generate TOTP codes.

## Encryption Implementation

### Encryption Algorithm

- **Algorithm**: AES-256 in CBC mode
- **Key Size**: 32 bytes (256 bits)
- **IV**: A random 16-byte initialization vector is generated for each encryption operation
- **Output Format**: Base64-encoded string containing the IV (first 16 bytes) followed by the encrypted data

### Key Management

The encryption key is specified at build time through one of the following methods:

1. **Environment Variable**: The `ENCRYPTION_KEY` environment variable
2. **Configuration File**: A `.env` file in the project root
3. **Secure Storage**: If no key is provided at build time, a default key is used in debug mode, and an error is thrown in release mode

The key is stored securely using the device's secure storage mechanism for subsequent app launches.

## How to Set the Encryption Key

### Option 1: Using a .env File (Development)

1. Create a `.env` file in the project root (it's already added to `.gitignore`)
2. Add the following line to the file:
   ```
   ENCRYPTION_KEY=your_32_character_encryption_key_here
   ```
3. Replace `your_32_character_encryption_key_here` with a secure 32-character key

### Option 2: Using Environment Variables (CI/CD)

When building the app in a CI/CD environment, set the `ENCRYPTION_KEY` environment variable:

```bash
export ENCRYPTION_KEY=your_32_character_encryption_key_here
flutter build apk
```

## Security Considerations

- The encryption key should be kept secure and not committed to version control
- In production, the key should be managed through a secure CI/CD process
- The app uses the device's secure storage to store the key after first use
- If the encryption key is lost, all encrypted TOTP secrets will be unrecoverable

## Implementation Details

The encryption is implemented in the following components:

- `EncryptionService`: Handles encryption and decryption operations
- `ConfigService`: Manages the encryption key
- `DatabaseService`: Uses the encryption service to encrypt secrets before storing and decrypt them when retrieving

## Testing

The encryption implementation is tested in `test/services/encryption_service_test.dart`.
