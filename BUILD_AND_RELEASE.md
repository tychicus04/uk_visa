# Build and Release Process

## Tổng Quan
Hướng dẫn step-by-step để build và release ứng dụng LifeInTheUKPrep lên Google Play Store và Apple App Store.

---

## 📋 Mục Lục
1. [Chuẩn Bị Môi Trường](#1-chuẩn-bị-môi-trường)
2. [Configuration Changes](#2-configuration-changes)
3. [Build Android](#3-build-android)
4. [Build iOS](#4-build-ios)
5. [Testing Release Builds](#5-testing-release-builds)
6. [Upload & Submit](#6-upload--submit)
7. [Post-Release](#7-post-release)
8. [Versioning Strategy](#8-versioning-strategy)
9. [CI/CD Setup (Optional)](#9-cicd-setup-optional)

---

## 1. Chuẩn Bị Môi Trường

### 1.1 Verify Development Environment

```bash
# Check Flutter
flutter doctor -v

# Expected output:
# ✓ Flutter (version 3.3.0+)
# ✓ Android toolchain
# ✓ Xcode (macOS only)
# ✓ Android Studio / VS Code
# ✓ Connected device / emulator
```

**Fix issues nếu có**:
```bash
# Update Flutter
flutter upgrade

# Accept licenses
flutter doctor --android-licenses

# Install pods (macOS)
sudo gem install cocoapods
```

### 1.2 Project Location

```bash
cd /home/user/uk_visa/uk_visa_test
```

### 1.3 Dependencies

```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Verify no errors
flutter analyze
```

---

## 2. Configuration Changes

### 2.1 Update Package/Bundle Identifiers

**⚠️ LÀM TRƯỚC KHI BUILD LẦN ĐẦU!**

#### Android

**File: `/home/user/uk_visa/uk_visa_test/android/app/build.gradle.kts`**

```kotlin
android {
    namespace = "com.yourcompany.ukvisatest"  // Đổi từ com.example.uk_visa_test

    defaultConfig {
        applicationId = "com.yourcompany.ukvisatest"  // Đổi từ com.example.uk_visa_test
        minSdk = 21
        targetSdk = 34
        versionCode = flutterVersionCode.toInt()
        versionName = flutterVersionName
    }
}
```

**File: `/home/user/uk_visa/uk_visa_test/android/app/src/main/AndroidManifest.xml`**

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.ukvisatest">
```

**Rename folder structure**:
```bash
cd /home/user/uk_visa/uk_visa_test/android/app/src/main/kotlin

# Create new structure
mkdir -p com/yourcompany/ukvisatest

# Move MainActivity
mv com/example/uk_visa_test/MainActivity.kt com/yourcompany/ukvisatest/

# Remove old structure
rm -rf com/example
```

**File: `MainActivity.kt`**
```kotlin
package com.yourcompany.ukvisatest

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

#### iOS

**Mở Xcode**:
```bash
cd /home/user/uk_visa/uk_visa_test
open ios/Runner.xcworkspace
```

**Trong Xcode**:
1. Select **Runner** (project) > **Runner** (target)
2. Tab **General** > **Identity**
3. **Bundle Identifier**: `com.yourcompany.ukvisatest`

### 2.2 Update AdMob App IDs

**⚠️ ĐỔI TỪ TEST ID SANG PRODUCTION ID!**

#### Android

**File: `/home/user/uk_visa/uk_visa_test/android/app/src/main/AndroidManifest.xml`**

```xml
<application>
    <!-- Đổi từ test ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>  <!-- Production ID -->
</application>
```

#### iOS

**File: `/home/user/uk_visa/uk_visa_test/ios/Runner/Info.plist`**

```xml
<dict>
    <!-- Đổi từ test ID -->
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>  <!-- Production ID -->
</dict>
```

**Lấy Production AdMob ID**:
1. Vào https://apps.admob.com/
2. **Apps** > **Add App** (hoặc select existing)
3. Copy **App ID** (format: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`)

### 2.3 Update Version

**File: `/home/user/uk_visa/uk_visa_test/pubspec.yaml`**

```yaml
name: uk_visa_test
description: UK Visa Test Preparation App

publish_to: 'none'

# Version format: major.minor.patch+buildNumber
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
```

**Version Guidelines**:
- **1.0.0**: Initial release
- **1.0.1**: Bug fixes
- **1.1.0**: New features
- **2.0.0**: Major changes
- **+1**: Build number (phải tăng mỗi build)

### 2.4 Environment Configuration

**Tạo file cho environments** (optional nhưng recommended):

**File: `/home/user/uk_visa/uk_visa_test/lib/core/constants/app_constants.dart`**

```dart
class AppConstants {
  // App Info
  static const String appName = 'LifeInTheUKPrep';

  // API URLs
  static const String apiBaseUrl = _isProduction
      ? 'https://api.production.com'
      : 'https://api.staging.com';

  // Feature Flags
  static const bool enableDebugLogs = !_isProduction;
  static const bool enableAnalytics = true;

  // Build config
  static const bool _isProduction = bool.fromEnvironment(
    'dart.vm.product',
    defaultValue: false,
  );
}
```

---

## 3. Build Android

### 3.1 Setup Android Signing

#### Tạo Upload Keystore

```bash
cd /home/user/uk_visa/uk_visa_test/android/app

# Tạo keystore (chỉ làm 1 lần!)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias upload \
  -storetype JKS

# Bạn sẽ được hỏi:
# - Enter keystore password: [nhập password mạnh]
# - Re-enter password: [nhập lại]
# - What is your first and last name?: [Your Name]
# - What is the name of your organizational unit?: [Your Company]
# - What is the name of your organization?: [Your Company]
# - What is the name of your City or Locality?: [Your City]
# - What is the name of your State or Province?: [Your State]
# - What is the two-letter country code?: VN (hoặc country code của bạn)
# - Is CN=... correct?: yes
# - Enter key password: [Enter = same as keystore password]
```

**⚠️ QUAN TRỌNG**:
- **LƯU PASSWORD AN TOÀN!** Không thể khôi phục nếu quên!
- **BACKUP KEYSTORE!** Lưu ít nhất 2 nơi (password manager + cloud storage)
- Nếu mất keystore, không thể update app!

#### Tạo key.properties

**File: `/home/user/uk_visa/uk_visa_test/android/key.properties`**

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks
```

**Add to .gitignore**:
```bash
echo "android/key.properties" >> .gitignore
echo "android/app/upload-keystore.jks" >> .gitignore
git add .gitignore
```

#### Configure Signing in build.gradle.kts

**File: `/home/user/uk_visa/uk_visa_test/android/app/build.gradle.kts`**

Thêm vào đầu file (sau imports):

```kotlin
import java.util.Properties
import java.io.FileInputStream

// Load keystore properties
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
```

Trong `android {}` block:

```kotlin
android {
    // ... existing config ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")

            // Enable code shrinking
            isMinifyEnabled = true
            isShrinkResources = true

            // ProGuard files
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 3.2 Build App Bundle (AAB)

```bash
cd /home/user/uk_visa/uk_visa_test

# Clean build
flutter clean
flutter pub get

# Build AAB for release
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

**Kiểm tra output**:
```bash
ls -lh build/app/outputs/bundle/release/app-release.aab

# Expected: File size khoảng 20-50 MB (tùy app)
```

### 3.3 Build APK (Optional - cho testing)

```bash
# Build single APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk

# Build APKs for specific architectures (nhỏ hơn)
flutter build apk --release --split-per-abi

# Output:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

**Lưu ý**: Google Play yêu cầu AAB, không phải APK (từ 2021)!

### 3.4 Test Release Build

```bash
# Install APK on connected device
adb install build/app/outputs/flutter-apk/app-release.apk

# Or use:
flutter install --release
```

**Kiểm tra**:
- App launches không crash
- All features work
- Không có debug logs
- Ads hiển thị (production)
- Performance tốt

---

## 4. Build iOS

**⚠️ YÊU CẦU macOS + Xcode!**

### 4.1 Install Dependencies

```bash
cd /home/user/uk_visa/uk_visa_test/ios

# Update pods
pod install
pod update

cd ..
```

### 4.2 Configure Xcode

```bash
# Mở Xcode workspace (KHÔNG mở .xcodeproj!)
open ios/Runner.xcworkspace
```

**Trong Xcode**:

1. **Select Runner** (project) > **Runner** (target)

2. **Tab General**:
   - **Display Name**: LifeInTheUKPrep
   - **Bundle Identifier**: com.yourcompany.ukvisatest
   - **Version**: 1.0.0 (sync với pubspec.yaml)
   - **Build**: 1

3. **Tab Signing & Capabilities**:
   - ✓ **Automatically manage signing** (khuyến nghị)
   - **Team**: Select your Apple Developer team
   - **Signing Certificate**: Distribution (tự động)
   - **Provisioning Profile**: Tự động

   **Hoặc Manual signing**:
   - Uncheck "Automatically manage signing"
   - Select **Provisioning Profile** (tạo trên Apple Developer Portal)
   - Select **Signing Certificate**

4. **Deployment Target**:
   - Set **iOS Deployment Target**: 12.0 hoặc 13.0

### 4.3 Build Archive

#### Option 1: Flutter CLI

```bash
cd /home/user/uk_visa/uk_visa_test

# Build IPA
flutter build ipa --release

# Output: build/ios/ipa/uk_visa_test.ipa
```

#### Option 2: Xcode (Recommended cho lần đầu)

**Trong Xcode**:

1. **Chọn device**: Any iOS Device (arm64) - KHÔNG chọn simulator!

2. **Clean**: Product > Clean Build Folder (Shift+Cmd+K)

3. **Archive**: Product > Archive (hoặc Cmd+B rồi Shift+Cmd+Option+K)
   - Chờ build (5-15 phút)

4. **Organizer window** sẽ mở khi archive thành công

### 4.4 Distribute App

**Trong Xcode Organizer**:

1. **Select archive** > **Distribute App**

2. **Chọn method**:
   - **App Store Connect** (cho submit)
   - **Ad Hoc** (cho testing)
   - **Development** (cho local test)

3. **App Store Connect** > **Next**

4. **Upload** hoặc **Export**:
   - **Upload**: Upload trực tiếp
   - **Export**: Export IPA để upload sau

5. **Distribution options**:
   - ☐ Include bitcode: NO (deprecated)
   - ✓ Upload your app's symbols: YES
   - ✓ Manage version and build number: Xcode managed

6. **Re-sign**: Automatic

7. **Review** > **Upload/Export**

**Khi upload thành công**:
- Xcode shows "Upload Successful"
- Nhận email từ Apple (15-60 phút): "Build processed"

### 4.5 Alternative: Transporter App

**Nếu đã export IPA**:

1. Mở **Transporter** app (download từ Mac App Store)
2. Sign in với Apple ID
3. Click **+** hoặc drag-drop IPA file
4. Click **Deliver**
5. Chờ upload

---

## 5. Testing Release Builds

### 5.1 Android Testing

**Install APK**:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Test checklist**:
- [ ] App launches
- [ ] No crashes
- [ ] All screens accessible
- [ ] Test flow works (take test, submit, view results)
- [ ] Language switch works
- [ ] Ads display (production ads)
- [ ] No debug logs in logcat
- [ ] Performance good (no lag)
- [ ] Back button works
- [ ] App lifecycle (minimize, restore)

**Logcat check**:
```bash
adb logcat | grep -i flutter
# Should see minimal logs, no debug prints
```

### 5.2 iOS Testing

**Install via Xcode**:
1. Connect iPhone/iPad
2. Xcode > Window > Devices and Simulators
3. Select device > Installed Apps > **+**
4. Select IPA file
5. Install

**Test checklist**:
- [ ] App launches
- [ ] No crashes
- [ ] All screens accessible
- [ ] Test flow works
- [ ] Language switch works
- [ ] Ads display
- [ ] No debug logs in Console
- [ ] Performance good
- [ ] Home indicator behavior (iPhone X+)
- [ ] Safe areas respected
- [ ] App lifecycle works

### 5.3 TestFlight (iOS - Optional)

**Benefits**:
- Test với nhiều users
- Test trên nhiều devices
- Crash logs automatic
- Easy distribution

**Setup**:
1. Upload build to App Store Connect (đã làm ở bước 4.4)
2. Vào App Store Connect > TestFlight
3. Chờ build processed
4. Add internal/external testers
5. Testers download TestFlight app
6. Testers install build từ TestFlight

### 5.4 Internal Testing Track (Android - Optional)

**Benefits**:
- Test trên nhiều devices
- Quick review (vài giờ)
- Up to 100 testers

**Setup**:
1. Upload AAB to Play Console
2. Release > Internal testing
3. Create internal testing release
4. Add testers (email)
5. Share link with testers
6. Testers opt-in và download

---

## 6. Upload & Submit

### 6.1 Google Play Console

**Prerequisites**:
- AAB file ready
- Play Console account created
- Store listing completed (xem GOOGLE_PLAY_DEPLOYMENT.md)

**Upload**:
1. Vào https://play.google.com/console
2. Select app
3. Release > Production (hoặc Testing track)
4. **Create new release**
5. **Upload** AAB file
6. Wait for processing (1-5 phút)
7. Điền **Release notes**
8. **Review release**
9. **Start rollout to Production**

**Timeline**:
- Processing: 1-5 phút
- Review: 1-7 ngày (thường 2-3 ngày)

### 6.2 App Store Connect

**Prerequisites**:
- IPA uploaded (qua Xcode hoặc Transporter)
- App Store Connect app created
- Store listing completed (xem APP_STORE_DEPLOYMENT.md)

**Submit**:
1. Vào https://appstoreconnect.apple.com
2. My Apps > Select app
3. **App Store** tab
4. Version **1.0.0** (hoặc create new)
5. **Build** section > **Select a build**
6. Review all info:
   - Version info
   - Description
   - Screenshots
   - Privacy
   - Age rating
7. **Add for Review** (góc trên phải)
8. **Submit for Review**

**Timeline**:
- Processing: 15-60 phút
- Review: 1-3 ngày (thường 24-48h)

---

## 7. Post-Release

### 7.1 Monitor Submissions

**Google Play**:
- Dashboard > **Policy status**
- Check email cho review updates
- **Publishing overview** cho rollout status

**App Store**:
- App Store Connect > **App Status**
- Check email
- Status: Waiting → In Review → Pending Developer Release → Ready for Sale

### 7.2 Nếu Bị Reject

**Đọc rejection email**:
- Understand exact issues
- Check guidelines violated

**Fix issues**:
- Update code (nếu technical issue)
- Update metadata (nếu listing issue)
- Update screenshots (nếu không match)

**Resubmit**:
- Google Play: Fix và create new release
- App Store: Fix và click "Resubmit"

### 7.3 Release to Production

**Google Play**:
- Auto-release khi approved (nếu chọn automatic)
- Manual release: Release > Manage > **Release to Production**

**App Store**:
- Auto-release khi approved (nếu chọn automatic)
- Manual release: Version page > **Release This Version**

### 7.4 Monitor Post-Launch

**Metrics to track**:
- [ ] Downloads/Installs
- [ ] Crash rate (target: < 2%)
- [ ] ANR rate (Android, target: < 0.5%)
- [ ] Ratings & Reviews
- [ ] User feedback
- [ ] Revenue (nếu có IAP/ads)

**Tools**:
- Google Play Console > **Statistics**
- App Store Connect > **Analytics**
- Firebase Analytics
- Firebase Crashlytics

**Actions**:
- Respond to reviews (trong vòng 24h)
- Fix critical bugs ASAP
- Plan updates dựa trên feedback

---

## 8. Versioning Strategy

### 8.1 Version Numbering

**Format**: `MAJOR.MINOR.PATCH+BUILD`

Example: `1.2.3+45`
- **MAJOR** (1): Breaking changes, complete redesign
- **MINOR** (2): New features, backwards compatible
- **PATCH** (3): Bug fixes, small improvements
- **BUILD** (45): Internal build number, must increase

### 8.2 When to Bump Versions

| Change Type | Example | Version Change |
|------------|---------|----------------|
| Initial release | First launch | 1.0.0+1 |
| Bug fixes | Fix crash, typos | 1.0.1+2 |
| Small improvements | UI tweaks, performance | 1.0.2+3 |
| New features | Add quiz mode | 1.1.0+4 |
| Major features | Complete redesign | 2.0.0+5 |

### 8.3 Update pubspec.yaml

```yaml
# Bug fix release
version: 1.0.1+2  # Was 1.0.0+1

# Feature release
version: 1.1.0+3  # Was 1.0.1+2

# Major release
version: 2.0.0+4  # Was 1.1.0+3
```

### 8.4 Git Tagging

```bash
# Tag release
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# List tags
git tag -l

# Checkout specific version
git checkout v1.0.0
```

---

## 9. CI/CD Setup (Optional)

### 9.1 GitHub Actions - Android

**File: `.github/workflows/android-release.yml`**

```yaml
name: Android Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.13.0'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Run build_runner
      run: dart run build_runner build --delete-conflicting-outputs

    - name: Decode keystore
      run: |
        echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/upload-keystore.jks

    - name: Create key.properties
      run: |
        cat > android/key.properties <<EOF
        storePassword=${{ secrets.KEYSTORE_PASSWORD }}
        keyPassword=${{ secrets.KEY_PASSWORD }}
        keyAlias=${{ secrets.KEY_ALIAS }}
        storeFile=upload-keystore.jks
        EOF

    - name: Build AAB
      run: flutter build appbundle --release

    - name: Upload AAB
      uses: actions/upload-artifact@v3
      with:
        name: app-release.aab
        path: build/app/outputs/bundle/release/app-release.aab
```

**Setup secrets**:
1. Encode keystore:
   ```bash
   base64 android/app/upload-keystore.jks > keystore.base64
   ```
2. GitHub repo > Settings > Secrets > New secret
3. Add:
   - `KEYSTORE_BASE64`: Nội dung file keystore.base64
   - `KEYSTORE_PASSWORD`: Keystore password
   - `KEY_PASSWORD`: Key password
   - `KEY_ALIAS`: upload

### 9.2 GitHub Actions - iOS

**File: `.github/workflows/ios-release.yml`**

```yaml
name: iOS Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: macos-latest

    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.13.0'
        channel: 'stable'

    - name: Install dependencies
      run: flutter pub get

    - name: Run build_runner
      run: dart run build_runner build --delete-conflicting-outputs

    - name: Install pods
      run: cd ios && pod install

    - name: Build IPA
      run: flutter build ipa --release --export-options-plist=ios/ExportOptions.plist

    - name: Upload IPA
      uses: actions/upload-artifact@v3
      with:
        name: app-release.ipa
        path: build/ios/ipa/*.ipa
```

### 9.3 Fastlane (Advanced)

**Install**:
```bash
# macOS
sudo gem install fastlane

# Linux
gem install fastlane
```

**Initialize**:
```bash
# Android
cd android
fastlane init

# iOS
cd ios
fastlane init
```

**Example Fastfile (Android)**:
```ruby
default_platform(:android)

platform :android do
  desc "Deploy to Play Store"
  lane :deploy do
    gradle(
      task: "bundle",
      build_type: "Release"
    )

    upload_to_play_store(
      track: 'production',
      aab: '../build/app/outputs/bundle/release/app-release.aab'
    )
  end
end
```

---

## 10. Quick Reference Commands

### Clean Build
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Android
```bash
# Build AAB (production)
flutter build appbundle --release

# Build APK (testing)
flutter build apk --release

# Install
adb install build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
# Install pods
cd ios && pod install && cd ..

# Build IPA
flutter build ipa --release

# Or via Xcode
open ios/Runner.xcworkspace
# Then: Product > Archive
```

### Version Update
```bash
# Edit pubspec.yaml
version: 1.0.1+2  # Increment version and build

# Verify
flutter pub get
```

### Testing
```bash
# Analyze
flutter analyze

# Test
flutter test

# Run release mode
flutter run --release
```

---

## 11. Troubleshooting

### Build Failed

**Check logs**:
```bash
flutter build appbundle --release --verbose
```

**Common fixes**:
```bash
# Clear cache
flutter clean
rm -rf build/

# Re-get dependencies
flutter pub get

# Re-run code generation
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Android: Clean gradle
cd android && ./gradlew clean && cd ..

# iOS: Clean pods
cd ios && rm -rf Pods Podfile.lock && pod install && cd ..
```

### Signing Issues (Android)

```bash
# Check keystore
keytool -list -v -keystore android/app/upload-keystore.jks

# Verify key.properties exists
cat android/key.properties
```

### Signing Issues (iOS)

```bash
# Check certificates
security find-identity -v -p codesigning

# Refresh profiles (Xcode)
# Preferences > Accounts > Download Manual Profiles
```

### AAB/IPA Too Large

**Check size**:
```bash
# Android
ls -lh build/app/outputs/bundle/release/app-release.aab

# iOS
ls -lh build/ios/ipa/*.ipa
```

**Reduce size**:
- Enable ProGuard/R8 (Android)
- Remove unused assets
- Compress images
- Use WebP instead of PNG
- Split APKs by ABI (testing only)

---

## 12. Checklist

### Before Build
- [ ] Code complete & tested
- [ ] Version updated in pubspec.yaml
- [ ] Dependencies updated (`flutter pub upgrade`)
- [ ] Code generation ran
- [ ] Analyze passed (`flutter analyze`)
- [ ] Tests passed (`flutter test`)
- [ ] Package/Bundle IDs updated
- [ ] AdMob IDs updated (production)

### Android Build
- [ ] Keystore created & backed up
- [ ] key.properties configured
- [ ] Signing config in build.gradle.kts
- [ ] AAB build successful
- [ ] AAB tested on device
- [ ] No crashes or bugs

### iOS Build
- [ ] Xcode configured
- [ ] Signing setup (automatic/manual)
- [ ] Pods installed
- [ ] Archive successful
- [ ] IPA uploaded to App Store Connect
- [ ] Build processed

### Submission
- [ ] Store listings complete
- [ ] Screenshots uploaded
- [ ] Descriptions written
- [ ] Privacy policies added
- [ ] Builds selected
- [ ] Submitted for review

---

**Good luck với release của bạn!** 🚀
