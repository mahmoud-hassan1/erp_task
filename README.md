# Document Management System 📚

A modern, secure, and efficient document management system built with Flutter and Firebase. This application provides a seamless experience for managing, organizing, and collaborating on documents.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-%23039BE5.svg?style=for-the-badge&logo=firebase)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

- 🔐 **Secure Authentication**
  - Email/Password authentication
  - Secure session management

- 📁 **Document Management**
  - Create and organize folders
  - Upload multiple file types
  - Advanced PDF viewer with search functionality

- 👥 **Collaboration**
  - Share documents with team members
  - Set custom permissions
- 🔍 **Search & Organization**
  - Full-text search in documents
  - Smart folder organization
  - Tags and categories

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK (latest version)
- Firebase account
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/document-management-system.git
   cd document-management-system
   ```

2. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add your Android and iOS apps to the Firebase project
   - Download configuration files:
     - Android: `google-services.json` → `android/app/`
     - iOS: `GoogleService-Info.plist` → `ios/Runner/`
   - Generate Firebase configuration:
     ```bash
     flutter pub global activate flutterfire_cli
     flutterfire configure
     ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗️ Architecture

The project follows Clean Architecture principles and uses BLoC pattern for state management:

```
lib/
├── core/
│   ├── error/
│   ├── network/
│   └── utils/
├── features/
│   ├── auth/
│   └── home/
└── main.dart
```

## 📦 Dependencies

- **State Management**
  - flutter_bloc

- **Firebase**
  - firebase_core
  - firebase_auth
  - cloud_firestore
  - firebase_storage

- **UI Components**
  - google_fonts


- **Document Handling**
  - file_picker
  - syncfusion_flutter_pdfviewer
  - path_provider

## 🔒 Security

- Never commit sensitive files:
  - `lib/firebase_options.dart`
  - `google-services.json`
  - `GoogleService-Info.plist`
  - `.env` files
- Use secure channels for sharing configuration
- Follow Firebase security best practices

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- Your Name - Initial work - [mahmoud-hassan1 ](https://github.com/mahmoud-hassan1)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the backend services
- All contributors who have helped shape this project

## 📞 Support

For support, email mahmoudhassan10191019@gnail.com or open an issue in the repository.

---

⭐️ If you like this project, please give it a star on GitHub!
