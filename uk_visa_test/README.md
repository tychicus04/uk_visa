# uk_visa_test

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

// Setup Guide and Configuration

/*
# UK Visa Test Flutter App - Setup Guide

## 📱 Flutter App Structure Overview

This is a complete bilingual (English/Vietnamese) UK Visa Test preparation app built with Flutter 3.32.8. The app follows clean architecture principles and uses Riverpod for state management.

## 🚀 Quick Start

### Prerequisites
- Flutter 3.32.8 or later
- Dart SDK 3.0.0 or later
- Android SDK (for Android development)
- Xcode (for iOS development - macOS only)
- Running backend API (see backend setup guide)

### 1. Clone and Setup
```bash
# Create new Flutter project
flutter create uk_visa_test
cd uk_visa_test

# Replace the default files with the provided code structure
# Copy all the files according to the project structure provided

# Install dependencies
flutter pub get

# Generate code (for json_serializable, riverpod, etc.)
flutter packages pub run build_runner build
```

### 2. Assets Setup
Create the following directories and add assets:

```
assets/
├── images/
│   ├── uk_flag.png          # UK flag image
│   └── app_logo.png         # App logo
├── icons/
│   └── app_icon.png         # App icon
└── animations/
    └── loading.json         # Lottie animation (optional)
```

### 3. Environment Configuration
Create a `.env` file in the root directory:

```env
# API Configuration
API_BASE_URL=http://localhost/UKVisa/backend
API_TIMEOUT=30000

# App Configuration
APP_NAME=Life in the UK
APP_VERSION=1.0.0
```

### 4. Platform-Specific Setup

#### Android (android/app/build.gradle)
```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.example.uk_visa_test"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

#### iOS (ios/Runner/Info.plist)
Add network permissions for HTTP requests:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 5. Code Generation
Run code generation for models and providers:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the App
```bash
# Run on debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for release
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🏗️ Project Architecture

### Folder Structure
```
lib/
├── main.dart                 # App entry point
├── app/                      # App configuration
├── core/                     # Core utilities and constants
├── data/                     # Data layer (models, services, repositories)
├── features/                 # Feature-based modules
├── l10n/                     # Internationalization
└── shared/                   # Shared widgets and providers
```

### Key Features
- ✅ Bilingual support (English/Vietnamese)
- ✅ Dark/Light theme with system preference
- ✅ User authentication and profiles
- ✅ Test taking with timer and progress tracking
- ✅ Chapter-based study materials
- ✅ Progress analytics and statistics
- ✅ Offline-first architecture (with sync)
- ✅ Premium subscription model
- ✅ Modern Material 3 design

## 🔧 Development

### State Management
The app uses Riverpod for state management:
- `StateNotifierProvider` for complex state
- `FutureProvider` for async data
- `Provider` for services and dependencies

### Navigation
Using Go Router for type-safe navigation:
- Declarative routing
- Deep linking support
- Protected routes with auth guards

### Localization
Flutter's built-in internationalization:
- ARB files for translations
- Context-aware text scaling
- RTL language support ready

### API Integration
- Dio for HTTP requests
- Retrofit-style service definitions
- Automatic token management
- Error handling and retry logic

## 📱 Backend Integration

### API Endpoints Used
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /tests/available` - Get available tests
- `POST /attempts/start` - Start test attempt
- `POST /attempts/submit` - Submit test answers
- `GET /chapters` - Get study chapters
- `GET /subscriptions/plans` - Get subscription plans

### Authentication Flow
1. User registers/logs in
2. JWT token stored securely
3. Token attached to API requests
4. Auto-refresh on token expiry
5. Logout clears all tokens

## 🎨 Design System

### Colors
- Primary: #2B7CE9 (UK Blue)
- Secondary: #00C896 (Success Green)
- Accent: #FF6B35 (Warning Orange)
- Error: #EF4444 (Error Red)

### Typography
- Font: Inter (Google Fonts)
- Scale: Material 3 type scale
- Responsive sizing

### Components
- Custom buttons with loading states
- Form fields with validation
- Progress indicators and cards
- Empty states and error handling

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Widget Tests
```bash
flutter test test/widget_test.dart
```

## 🚀 Deployment

### Android Release
```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### iOS Release
```bash
# Build for App Store
flutter build ios --release

# Archive in Xcode for distribution
```

## 🔐 Security

### Data Protection
- JWT tokens stored in secure storage
- Sensitive data encrypted
- Network traffic secured with HTTPS
- No sensitive data in logs

### Privacy
- Minimal data collection
- User consent for analytics
- GDPR compliant design
- Clear privacy policy

## 📈 Performance

### Optimizations
- Image caching with `cached_network_image`
- Lazy loading for large lists
- Efficient state management
- Minimal rebuilds with Riverpod

### Monitoring
- Crash reporting integration ready
- Performance monitoring setup
- Analytics events tracking
- User behavior insights

## 🐛 Troubleshooting

### Common Issues

1. **Build Runner Conflicts**
   ```bash
   flutter packages pub run build_runner clean
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

2. **iOS Simulator Network Issues**
    - Check iOS simulator network settings
    - Use actual device for testing API calls

3. **Android Debug Certificate**
   ```bash
   flutter clean
   flutter pub get
   cd android && ./gradlew clean
   ```

4. **Localization Not Working**
   ```bash
   flutter gen-l10n
   flutter pub get
   ```

### Debug Commands
```bash
# Check Flutter installation
flutter doctor

# Analyze code issues
flutter analyze

# Check for dependency conflicts
flutter pub deps
```

## 📚 Documentation

### API Documentation
- Swagger/OpenAPI specs in backend
- Postman collection available
- Authentication examples

### Code Documentation
- Inline code comments
- README files for each feature
- Architecture decision records

## 🤝 Contributing

### Code Style
- Follow Dart style guide
- Use meaningful variable names
- Comment complex logic
- Write tests for new features

### Git Workflow
- Feature branches for new development
- Pull requests for code review
- Conventional commit messages
- Automated testing on PR

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the troubleshooting guide above
- Review the API documentation
- Check Flutter documentation
- Create an issue in the repository

---

## Next Steps

1. **Set up the backend API** (see backend documentation)
2. **Configure the Flutter app** with your API endpoint
3. **Add your assets** (UK flag, app icons, etc.)
4. **Test the authentication flow** with real API
5. **Customize the branding** and colors as needed
6. **Add real test content** from the official study guide
7. **Set up analytics** and crash reporting
8. **Prepare for app store submission**

The app is designed to be production-ready with proper error handling, loading states, and user experience considerations. The modular architecture makes it easy to extend and maintain.
*/
