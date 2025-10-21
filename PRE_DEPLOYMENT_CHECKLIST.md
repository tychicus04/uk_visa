# Pre-Deployment Checklist - LifeInTheUKPrep

## Tổng Quan
Checklist đầy đủ để đảm bảo app sẵn sàng cho deployment lên Google Play và App Store.

**Hoàn thành checklist này TRƯỚC KHI build và submit app!**

---

## 📱 1. Thông Tin App Cơ Bản

### App Identity
- [ ] **App Name** đã quyết định:
  - Play Store: _______________________
  - App Store: _______________________
  - Display Name trong app: _______________________

- [ ] **Package/Bundle Identifiers**:
  - Android: `com.yourcompany.ukvisatest` (đổi từ `com.example.uk_visa_test`)
  - iOS: `com.yourcompany.ukvisatest` (đổi từ `com.example.ukVisaTest`)

- [ ] **Version & Build Numbers**:
  - Version: 1.0.0 (semantic versioning)
  - Build number: 1 (sẽ tăng cho mỗi build)

### Contact & Legal
- [ ] **Support Email**: _______________________
- [ ] **Website**: _______________________ (nếu có)
- [ ] **Privacy Policy URL**: _______________________
- [ ] **Terms of Service URL**: _______________________ (optional)

---

## 🎨 2. Design Assets

### App Icons
- [ ] **Android Icon** (512x512 px, PNG, 32-bit):
  - Location: `/home/user/uk_visa/uk_visa_test/android/app/src/main/res/mipmap-*/ic_launcher.png`
  - All densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi
  - Uploaded to Play Console (512x512)

- [ ] **iOS Icon** (Multiple sizes):
  - Location: `/home/user/uk_visa/uk_visa_test/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
  - Sizes: 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024
  - Format: PNG, NO alpha channel
  - App Store icon (1024x1024)

### Store Graphics
- [ ] **Feature Graphic** (Google Play):
  - Size: 1024x500 px
  - Format: PNG or JPG
  - No text if possible (many locales)

- [ ] **Screenshots**:
  - **Android Phone**: 2-8 screenshots
    - Min: 320px, Max: 3840px
    - Recommended: 1080x1920 or 1440x2560
  - **Android Tablet**: 1-8 screenshots (optional)
    - 7-inch and 10-inch
  - **iPhone 6.7"** (iPhone 15 Pro Max): 1-10 screenshots
    - Size: 2796 x 1290 px (portrait)
  - **iPad Pro 12.9"**: 1-10 screenshots (optional)
    - Size: 2048 x 2732 px (portrait)

- [ ] **Promo Video** (optional):
  - Google Play: YouTube URL, 30-120 seconds
  - App Store: 15-30 seconds, .mov/.m4v/.mp4

### Screenshots Content Prepared
- [ ] Home screen
- [ ] Test/quiz interface
- [ ] Question screen với answers
- [ ] Results/score screen
- [ ] Progress/history screen
- [ ] Chapter selection
- [ ] Settings screen
- [ ] Language switch demo (EN ↔ VI)

---

## 📝 3. Store Listing Content

### Google Play Store
- [ ] **App Name**: (tối đa 50 chars) _______________________
- [ ] **Short Description**: (tối đa 80 chars)
  ```
  _______________________________________________________
  ```
- [ ] **Full Description**: (tối đa 4000 chars)
  - Feature highlights
  - Study modes
  - Bilingual support
  - Target audience
  - Support contact
  - Privacy policy mention

- [ ] **Category**: Education
- [ ] **Tags**: (nếu có)

### Apple App Store
- [ ] **App Name**: (tối đa 30 chars) _______________________
- [ ] **Subtitle**: (tối đa 30 chars)
  ```
  _______________________________________________________
  ```
- [ ] **Promotional Text**: (tối đa 170 chars, có thể edit sau release)
  ```
  _______________________________________________________
  ```
- [ ] **Description**: (tối đa 4000 chars)
- [ ] **Keywords**: (tối đa 100 chars, comma-separated)
  ```
  _______________________________________________________
  ```
- [ ] **Primary Category**: Education
- [ ] **Secondary Category**: Reference (optional)

---

## 🔐 4. Accounts & Credentials

### Google Play
- [ ] **Google Play Developer Account** đã tạo
  - Email: _______________________
  - Phí $25 đã thanh toán
  - Account verified

### Apple Developer
- [ ] **Apple Developer Program** đã đăng ký
  - Account type: Individual / Organization
  - Phí $99/năm đã thanh toán
  - Verification completed
  - Agreements signed

### Third-Party Services
- [ ] **Google AdMob**:
  - Account created
  - App registered
  - Production App ID (Android): ca-app-pub-________________
  - Production App ID (iOS): ca-app-pub-________________
  - ⚠️ Đổi từ test ID sang production!

- [ ] **Firebase** (nếu sử dụng):
  - Project created
  - `google-services.json` (Android) added
  - `GoogleService-Info.plist` (iOS) added
  - Analytics enabled
  - Crashlytics enabled (recommended)

- [ ] **Backend API**:
  - Production URL: _______________________
  - API credentials configured
  - Staging/Production environments separated

---

## 🔧 5. Code Configuration

### Package/Bundle ID Changes
- [ ] **Android**:
  - `android/app/build.gradle.kts`: `applicationId` updated
  - `AndroidManifest.xml`: `package` attribute updated
  - Folder structure: `android/app/src/main/kotlin/com/yourcompany/ukvisatest/`
  - `MainActivity.kt`: package declaration updated

- [ ] **iOS**:
  - Xcode: Bundle Identifier updated
  - `ios/Runner/Info.plist`: Bundle ID updated
  - App ID created in Apple Developer Portal

### App Configuration Files
- [ ] `pubspec.yaml`:
  - App name
  - Version: 1.0.0+1
  - All dependencies added
  - Assets declared

- [ ] `android/app/build.gradle.kts`:
  - `applicationId` correct
  - `minSdk`: 21
  - `targetSdk`: 34 (latest)
  - Version codes from `pubspec.yaml`
  - Signing config added

- [ ] `ios/Runner/Info.plist`:
  - `CFBundleDisplayName`: LifeInTheUKPrep
  - `GADApplicationIdentifier`: Production AdMob ID
  - Privacy usage descriptions added (nếu có permissions)
  - `NSUserTrackingUsageDescription` added (cho ads)

### Environment Variables
- [ ] **API URLs**:
  - Development: _______________________
  - Staging: _______________________
  - Production: _______________________
  - Current build sử dụng: Production

- [ ] **API Keys/Secrets**:
  - Không hardcode trong code
  - Sử dụng environment variables hoặc secure storage
  - `.env` files NOT committed to git

### Feature Flags
- [ ] Debug features disabled (logging, mock data, etc.)
- [ ] Test ads disabled, production ads enabled
- [ ] Analytics tracking enabled
- [ ] Crash reporting enabled
- [ ] Performance monitoring enabled (optional)

---

## 🔒 6. Signing & Certificates

### Android Signing
- [ ] **Upload Keystore** created:
  - Location: `android/app/upload-keystore.jks`
  - Alias: upload
  - Password: Saved securely (password manager)
  - Validity: 10000 days

- [ ] **key.properties** file created:
  - Location: `android/key.properties`
  - Contains: storePassword, keyPassword, keyAlias, storeFile
  - ⚠️ Added to `.gitignore`

- [ ] **build.gradle.kts** signing config:
  - `signingConfigs` block added
  - Release build type uses signing config
  - ProGuard/R8 enabled for release

- [ ] **Keystore backed up**:
  - Location 1: _______________________
  - Location 2: _______________________
  - Password stored in: _______________________

### iOS Signing
- [ ] **Xcode automatic signing** configured:
  - Team selected
  - Bundle ID registered
  - Or **Manual signing**:
    - Distribution certificate downloaded
    - Provisioning profile downloaded

- [ ] **App Store Connect** access verified

- [ ] **Certificates backed up**:
  - Downloaded from Apple Developer
  - Stored securely

---

## 📄 7. Legal & Privacy

### Privacy Policy
- [ ] **Privacy Policy** created
  - URL: _______________________
  - Hosted online (accessible)
  - Covers:
    - Data collection (email, usage data, device ID)
    - How data is used (app functionality, ads, analytics)
    - Third-party sharing (AdMob, Firebase)
    - User rights (access, deletion, opt-out)
    - Contact information
  - Languages: English (required), Vietnamese (optional)

### Data Safety & Privacy
- [ ] **Google Play Data Safety** filled:
  - Data types collected
  - Purpose of collection
  - Data sharing practices
  - Security practices (encryption)
  - User can request deletion

- [ ] **App Store App Privacy** filled:
  - Data types collected
  - Linked to user identity
  - Used for tracking
  - Privacy policy URL added

### Terms of Service (Optional)
- [ ] **Terms of Service** created (if applicable)
  - URL: _______________________
  - Covers: Usage terms, limitations, liability

### Compliance
- [ ] **GDPR compliance** (nếu có EU users):
  - User consent for data collection
  - Data deletion capability
  - Privacy policy compliant

- [ ] **COPPA compliance** (nếu target trẻ em < 13):
  - Parental consent mechanisms
  - Age-appropriate content

- [ ] **Export Compliance**:
  - Google Play: Standard encryption (HTTPS) only
  - App Store: Export compliance answered

---

## 🧪 8. Testing

### Functional Testing
- [ ] **Core Features** tested:
  - [ ] App launches successfully
  - [ ] Home screen loads
  - [ ] Navigation works (all screens)
  - [ ] Take practice test
  - [ ] Answer questions
  - [ ] Submit test
  - [ ] View results
  - [ ] Review answers
  - [ ] Study chapters
  - [ ] View progress/history
  - [ ] Settings screen
  - [ ] Language switch (EN ↔ VI)
  - [ ] All text translated properly

### Platform-Specific Testing
- [ ] **Android Testing**:
  - [ ] Tested on Android 5.0 (API 21) - minimum
  - [ ] Tested on Android 14 (API 34) - target
  - [ ] Tested on multiple screen sizes
  - [ ] Tested on different manufacturers (Samsung, Google, etc.)
  - [ ] Back button behavior correct
  - [ ] App lifecycle (background, foreground) correct
  - [ ] Permissions handling (if any)

- [ ] **iOS Testing**:
  - [ ] Tested on iOS minimum version
  - [ ] Tested on iOS latest version
  - [ ] Tested on iPhone (6.7", 6.5", 5.5")
  - [ ] Tested on iPad (optional)
  - [ ] Home indicator behavior (iPhone X+)
  - [ ] Safe areas respected
  - [ ] App lifecycle correct
  - [ ] Permissions handling (if any)

### Release Build Testing
- [ ] **Android Release APK/AAB**:
  - [ ] Build successful
  - [ ] App launches (no crashes)
  - [ ] All features work
  - [ ] No debug logs visible
  - [ ] ProGuard/R8 not breaking features
  - [ ] APK size reasonable (< 100MB recommended)

- [ ] **iOS Release IPA**:
  - [ ] Archive successful
  - [ ] App launches (no crashes)
  - [ ] All features work
  - [ ] No debug logs visible
  - [ ] App size reasonable (< 200MB recommended)

### Performance Testing
- [ ] **App Performance**:
  - [ ] Launch time < 3 seconds
  - [ ] No ANRs (Application Not Responding)
  - [ ] No memory leaks
  - [ ] Smooth scrolling
  - [ ] Images load quickly
  - [ ] Battery usage reasonable

- [ ] **Network Testing**:
  - [ ] Works on WiFi
  - [ ] Works on mobile data (4G/5G)
  - [ ] Handles offline gracefully
  - [ ] API errors handled
  - [ ] Timeout handling

### Edge Cases
- [ ] Low storage space
- [ ] Low battery
- [ ] Airplane mode
- [ ] Device orientation changes
- [ ] Interruptions (calls, notifications)
- [ ] App updates (if updating existing app)

---

## 🛡️ 9. Security

### Code Security
- [ ] **No hardcoded secrets**:
  - [ ] API keys
  - [ ] Passwords
  - [ ] Tokens
  - [ ] URLs (use environment variables)

- [ ] **Secure storage** for sensitive data:
  - [ ] User credentials (if any)
  - [ ] Tokens/JWT
  - [ ] Personal information

- [ ] **HTTPS only** for API calls
- [ ] **Certificate pinning** (optional, advanced)

### .gitignore Check
- [ ] **Android**:
  - [ ] `android/key.properties`
  - [ ] `android/app/upload-keystore.jks`
  - [ ] `android/app/*.keystore`
  - [ ] `android/local.properties`

- [ ] **iOS**:
  - [ ] `ios/Runner.xcodeproj/project.pbxproj` (nếu có secrets)
  - [ ] `ios/exportOptions.plist`
  - [ ] `*.p12`, `*.cer`, `*.mobileprovision`
  - [ ] `ios/GoogleService-Info.plist` (nếu có Firebase)

- [ ] **General**:
  - [ ] `.env`, `.env.local`
  - [ ] `*.log`
  - [ ] API keys, secrets files

### Dependency Security
- [ ] **Dependencies updated**:
  ```bash
  flutter pub outdated
  flutter pub upgrade
  ```
- [ ] **Known vulnerabilities** checked
- [ ] **Unused dependencies** removed

---

## 📊 10. Analytics & Monitoring

### Analytics Setup
- [ ] **Analytics provider** chosen:
  - [ ] Firebase Analytics
  - [ ] Google Analytics
  - [ ] Mixpanel
  - [ ] Other: _______________________

- [ ] **Events tracked**:
  - [ ] App opened
  - [ ] Test started
  - [ ] Test completed
  - [ ] Chapter viewed
  - [ ] Language switched
  - [ ] Custom events: _______________________

### Crash Reporting
- [ ] **Crash reporting** enabled:
  - [ ] Firebase Crashlytics (recommended)
  - [ ] Sentry
  - [ ] Other: _______________________

- [ ] **Symbolication files** uploaded (iOS)
- [ ] **ProGuard mapping files** uploaded (Android)

### Performance Monitoring
- [ ] **Performance monitoring** enabled (optional):
  - [ ] Firebase Performance Monitoring
  - [ ] New Relic
  - [ ] Other: _______________________

---

## 💰 11. Monetization (Nếu Có)

### In-App Purchases
- [ ] **Products created**:
  - Google Play: Products created in Play Console
  - App Store: Products created in App Store Connect

- [ ] **IAP implementation** tested:
  - [ ] Purchase flow works
  - [ ] Restoration works
  - [ ] Receipt validation (server-side recommended)

### Ads
- [ ] **AdMob configured**:
  - [ ] Production App IDs (Android & iOS)
  - [ ] Ad units created (banner, interstitial, rewarded)
  - [ ] Test ads disabled, production ads enabled
  - [ ] Ad placement tested
  - [ ] GDPR consent (if needed)
  - [ ] COPPA compliant (if target kids)

- [ ] **Ads Policy Compliance**:
  - [ ] No ads on test/quiz screens (UX policy)
  - [ ] No misleading ad placements
  - [ ] Ad-free option available (optional)

---

## 📦 12. Build Preparation

### Pre-Build
- [ ] **Code cleanup**:
  - [ ] Remove debug code
  - [ ] Remove console.log / print statements (hoặc giữ minimal)
  - [ ] Remove commented code
  - [ ] Format code (dart format)
  - [ ] Lint check passed (flutter analyze)

- [ ] **Dependencies**:
  ```bash
  flutter clean
  flutter pub get
  dart run build_runner build --delete-conflicting-outputs
  ```

- [ ] **Version updated** in `pubspec.yaml`:
  ```yaml
  version: 1.0.0+1
  ```

### Android Build
- [ ] **Build configuration**:
  - [ ] Release build type configured
  - [ ] Signing configured
  - [ ] ProGuard/R8 rules added (if needed)
  - [ ] Shrink resources enabled

- [ ] **Build commands**:
  ```bash
  flutter build appbundle --release
  # Output: build/app/outputs/bundle/release/app-release.aab
  ```

- [ ] **AAB file**:
  - [ ] Build successful
  - [ ] File size reasonable
  - [ ] Validated (bundletool)

### iOS Build
- [ ] **Xcode configuration**:
  - [ ] Signing configured (automatic/manual)
  - [ ] Team selected
  - [ ] Bundle ID correct
  - [ ] Version/Build number correct

- [ ] **Build commands**:
  ```bash
  cd ios && pod install && cd ..
  flutter build ipa --release
  # Or: Xcode > Product > Archive
  ```

- [ ] **IPA file**:
  - [ ] Archive successful
  - [ ] File size reasonable
  - [ ] Uploaded to App Store Connect

---

## 📤 13. Pre-Submission

### Google Play Console
- [ ] **App created** in Play Console
- [ ] **Store Listing** hoàn thành:
  - [ ] Title, description
  - [ ] Icon, feature graphic
  - [ ] Screenshots (phone, tablet)
  - [ ] Category
  - [ ] Contact details

- [ ] **App Access** configured:
  - [ ] Demo account (nếu cần login)
  - [ ] Special access instructions

- [ ] **Content Rating** completed
- [ ] **Data Safety** completed
- [ ] **Target Audience** set
- [ ] **Ads** declared (Yes/No)
- [ ] **Pricing & Distribution**:
  - [ ] Free/Paid
  - [ ] Countries selected

### App Store Connect
- [ ] **App created** in App Store Connect
- [ ] **App Information**:
  - [ ] Name, subtitle
  - [ ] Category
  - [ ] Privacy Policy URL

- [ ] **Pricing & Availability**:
  - [ ] Price tier
  - [ ] Countries

- [ ] **App Privacy** completed
- [ ] **Version Information**:
  - [ ] Version number
  - [ ] What's new
  - [ ] Description, keywords
  - [ ] Screenshots
  - [ ] Build selected

- [ ] **Age Rating** set
- [ ] **App Review Information**:
  - [ ] Contact info
  - [ ] Demo account (nếu cần)
  - [ ] Notes for reviewer

---

## ✅ 14. Final Checks

### Pre-Submission Checklist
- [ ] **All required fields** filled in Play Console and App Store Connect
- [ ] **No placeholder content** (lorem ipsum, test data)
- [ ] **All links work** (privacy policy, support, website)
- [ ] **Email addresses** monitored (support, contact)
- [ ] **Screenshots** match current app version
- [ ] **Description** accurate và không misleading
- [ ] **Version number** correct
- [ ] **Build uploaded** và processed

### Policy Compliance
- [ ] **Google Play Policies** reviewed:
  - https://play.google.com/about/developer-content-policy/
- [ ] **App Store Review Guidelines** reviewed:
  - https://developer.apple.com/app-store/review/guidelines/
- [ ] **Content appropriate** cho age rating
- [ ] **No copyright violations** (images, text, music)
- [ ] **No misleading claims**

### Team Readiness
- [ ] **Support team** ready để respond reviews/emails
- [ ] **Bug fix process** ready
- [ ] **Update plan** prepared (nếu có issues)
- [ ] **Monitoring tools** configured (analytics, crashes)

---

## 🚀 15. Ready to Submit!

### Final Confirmation
- [ ] Đã review toàn bộ checklist
- [ ] Tất cả items đã complete hoặc N/A
- [ ] Backup của keystore/certificates
- [ ] Team notified về submission

### Submit
- [ ] **Google Play**: Click "Submit for review"
- [ ] **App Store**: Click "Add for Review"

### Post-Submission
- [ ] **Monitor status**:
  - [ ] Google Play Console dashboard
  - [ ] App Store Connect
  - [ ] Email notifications

- [ ] **Prepare for questions** từ review team
- [ ] **Plan release announcement** (social media, website, email)

---

## 📞 Support Contacts

**Nếu gặp vấn đề**:

### Google Play
- Developer Console Help: https://support.google.com/googleplay/android-developer
- Developer Policy Center: https://support.google.com/googleplay/android-developer/topic/9858052

### Apple
- App Store Connect Help: https://developer.apple.com/support/app-store-connect/
- Developer Program Support: https://developer.apple.com/contact/

### Flutter
- Flutter Docs: https://docs.flutter.dev/deployment
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

## 📝 Notes

**Ghi chú cá nhân**:
```
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
```

**Issues gặp phải**:
```
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
_____________________________________________________________________________
```

---

**Completion Date**: ____ / ____ / ________

**Submitted By**: _______________________

**Status**: ☐ Ready to Submit  ☐ Need More Work  ☐ Submitted  ☐ Live

---

**Good luck với việc launch app của bạn!** 🚀📱
