# Document Management System

A Flutter application for managing documents and folders with Firebase integration.

## Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android and iOS apps to the Firebase project
3. Download the configuration files:
   - For Android: `google-services.json` → place in `android/app/`
   - For iOS: `GoogleService-Info.plist` → place in `ios/Runner/`
4. Generate the Firebase configuration file:
   ```bash
   flutter pub global activate flutterfire_cli
   flutterfire configure
   ```
   This will create `lib/firebase_options.dart`

## Important Notes

- Never commit the following files to version control:
  - `lib/firebase_options.dart`
  - `google-services.json`
  - `GoogleService-Info.plist`
  - Any `.env` files
- Use the template file `lib/firebase_options.template.dart` as a reference
- Keep your Firebase configuration secure and share it through secure channels

## Development Setup

1. Clone the repository
2. Copy `lib/firebase_options.template.dart` to `lib/firebase_options.dart`
3. Update the Firebase configuration values in `lib/firebase_options.dart`
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Features

- User authentication
- Folder creation and management
- Document upload and organization
- File sharing and permissions
- Version control for documents
- Comments and collaboration

## Dependencies

- Flutter
- Firebase (Authentication, Firestore, Storage)
- flutter_bloc for state management
- file_picker for document selection
- google_fonts for typography
