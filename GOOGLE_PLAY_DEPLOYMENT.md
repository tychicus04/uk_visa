# Hướng Dẫn Đưa App Lên Google Play Console

## Tổng Quan
Tài liệu này hướng dẫn chi tiết cách đưa ứng dụng **LifeInTheUKPrep** (UK Visa Test) lên Google Play Store.

---

## 📋 Mục Lục
1. [Yêu Cầu Chuẩn Bị](#1-yêu-cầu-chuẩn-bị)
2. [Tạo Tài Khoản Google Play Console](#2-tạo-tài-khoản-google-play-console)
3. [Cấu Hình Android Signing](#3-cấu-hình-android-signing)
4. [Build App Bundle](#4-build-app-bundle)
5. [Tạo App Listing](#5-tạo-app-listing)
6. [Upload Build](#6-upload-build)
7. [Hoàn Thiện Store Listing](#7-hoàn-thiện-store-listing)
8. [Submit Để Review](#8-submit-để-review)

---

## 1. Yêu Cầu Chuẩn Bị

### 1.1 Tài Khoản & Phí
- **Google Play Developer Account** (phí một lần: $25 USD)
- **Thẻ tín dụng/ghi nợ** để thanh toán
- **Email doanh nghiệp** (khuyến nghị)

### 1.2 Thông Tin Cần Có
- [ ] **Tên ứng dụng**: LifeInTheUKPrep (hoặc UK Visa Test)
- [ ] **Package Name**: `com.example.uk_visa_test` (nên đổi thành domain riêng, ví dụ: `com.yourcompany.ukvisatest`)
- [ ] **Mô tả ngắn**: Tối đa 80 ký tự
- [ ] **Mô tả đầy đủ**: Tối đa 4000 ký tự
- [ ] **Icon ứng dụng**: 512x512 px (PNG, 32-bit)
- [ ] **Feature Graphic**: 1024x500 px (PNG hoặc JPG)
- [ ] **Screenshots**:
  - Phone: 2-8 ảnh, tối thiểu 320px, tối đa 3840px
  - 7-inch tablet: 1-8 ảnh (tùy chọn)
  - 10-inch tablet: 1-8 ảnh (tùy chọn)
- [ ] **Privacy Policy URL** (bắt buộc)
- [ ] **Email hỗ trợ**
- [ ] **Category**: Education
- [ ] **Content Rating Questionnaire**

### 1.3 Tài Liệu Pháp Lý
- [ ] Chính sách quyền riêng tư (Privacy Policy)
- [ ] Điều khoản sử dụng (Terms of Service) - tùy chọn
- [ ] Data Safety Declaration
- [ ] Export Compliance (nếu có mã hóa)

---

## 2. Tạo Tài Khoản Google Play Console

### Bước 1: Đăng Ký
1. Truy cập: https://play.google.com/console/signup
2. Đăng nhập bằng Google Account
3. Chấp nhận **Google Play Developer Distribution Agreement**
4. Thanh toán $25 USD
5. Hoàn thành xác minh danh tính (có thể mất vài ngày)

### Bước 2: Thiết Lập Tài Khoản
1. Vào **Account Details**
2. Điền thông tin:
   - Developer name (tên hiển thị trên Play Store)
   - Email address (contact email)
   - Phone number
   - Website (nếu có)
3. Thiết lập **Merchant Account** (nếu có In-App Purchase)

---

## 3. Cấu Hình Android Signing

### 3.1 Tạo Upload Keystore

**⚠️ QUAN TRỌNG**: Hiện tại app đang dùng debug signing. Cần tạo production keystore!

```bash
cd /home/user/uk_visa/uk_visa_test/android/app

# Tạo keystore
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload \
  -storetype JKS
```

**Lưu ý**:
- Lưu password an toàn!
- Backup keystore file!
- Nếu mất keystore, không thể update app!

### 3.2 Cấu Hình key.properties

Tạo file `/home/user/uk_visa/uk_visa_test/android/key.properties`:

```properties
storePassword=<password-của-bạn>
keyPassword=<password-của-bạn>
keyAlias=upload
storeFile=upload-keystore.jks
```

**⚠️ BẢO MẬT**: Thêm `key.properties` vào `.gitignore`!

```bash
echo "android/key.properties" >> .gitignore
echo "android/app/upload-keystore.jks" >> .gitignore
```

### 3.3 Cập Nhật build.gradle.kts

Sửa file `/home/user/uk_visa/uk_visa_test/android/app/build.gradle.kts`:

```kotlin
import java.util.Properties
import java.io.FileInputStream

// Load keystore
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Bật ProGuard/R8
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

### 3.4 Cập Nhật Package Name (Khuyến Nghị)

Đổi package name từ `com.example.uk_visa_test` sang domain của bạn:

**File cần sửa**:
1. `/home/user/uk_visa/uk_visa_test/android/app/build.gradle.kts`
   ```kotlin
   namespace = "com.yourcompany.ukvisatest"
   applicationId = "com.yourcompany.ukvisatest"
   ```

2. `/home/user/uk_visa/uk_visa_test/android/app/src/main/AndroidManifest.xml`
   ```xml
   <manifest package="com.yourcompany.ukvisatest">
   ```

3. Đổi tên folder:
   ```bash
   cd android/app/src/main/kotlin/com/
   mkdir -p yourcompany/ukvisatest
   mv example/uk_visa_test/MainActivity.kt yourcompany/ukvisatest/
   rm -rf example
   ```

4. Sửa MainActivity.kt:
   ```kotlin
   package com.yourcompany.ukvisatest
   ```

---

## 4. Build App Bundle

### 4.1 Chuẩn Bị Build

```bash
cd /home/user/uk_visa/uk_visa_test

# Clean project
flutter clean
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Verify build
flutter doctor -v
```

### 4.2 Build App Bundle (AAB)

**Google Play yêu cầu App Bundle, không phải APK!**

```bash
# Build release AAB
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### 4.3 Kiểm Tra Bundle

```bash
# Kiểm tra size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Analyze bundle (nếu có bundletool)
java -jar bundletool-all.jar validate --bundle=build/app/outputs/bundle/release/app-release.aab
```

**Lưu ý**: File AAB thường nhỏ hơn APK vì Google Play tối ưu hóa theo từng thiết bị.

---

## 5. Tạo App Listing

### 5.1 Tạo Ứng Dụng Mới

1. Vào **Google Play Console**: https://play.google.com/console
2. Click **Create app**
3. Điền thông tin:
   - **App name**: LifeInTheUKPrep
   - **Default language**: English (United States) hoặc Vietnamese
   - **App or game**: App
   - **Free or paid**: Free (hoặc Paid nếu tính phí)
4. Chấp nhận **Declarations**
5. Click **Create app**

### 5.2 Thiết Lập App Access

1. Vào **Setup** > **App access**
2. Chọn:
   - [ ] All functionality is available without special access
   - [ ] All or some functionality is restricted (nếu có login)
3. Cung cấp **demo account** nếu cần login
4. Save

### 5.3 Khai Báo Quảng Cáo

1. Vào **Setup** > **Ads**
2. Chọn: **Yes, my app contains ads** (vì có Google Mobile Ads)
3. Save

### 5.4 Content Rating

1. Vào **Setup** > **Content rating**
2. Điền **questionnaire**:
   - Email address
   - Category: Education/Reference
3. Trả lời các câu hỏi về nội dung:
   - Violence: No
   - Sexual content: No
   - Profanity: No
   - Drugs/alcohol/tobacco: No
   - User interaction: Yes (nếu có share/chat)
   - Personal info: Yes (nếu có login)
   - Location: No/Yes
4. Submit > Apply rating

### 5.5 Target Audience

1. Vào **Setup** > **Target audience**
2. Chọn **age group**: 13+ hoặc All ages
3. Save

### 5.6 Data Safety

**⚠️ RẤT QUAN TRỌNG từ tháng 7/2022!**

1. Vào **Setup** > **Data safety**
2. Khai báo dữ liệu thu thập:

**Dựa vào code của bạn**:
- **Personal info**: Email (nếu có login/registration)
- **App activity**: Test results, study progress
- **Device ID**: For ads (Google Mobile Ads)

3. Mục đích sử ddụng:
   - App functionality
   - Advertising
   - Analytics

4. Data sharing:
   - Shared with **Google AdMob**
   - **Encryption in transit**: Yes (HTTPS)
   - **User can request deletion**: Yes/No

5. Privacy Policy: Thêm URL

---

## 6. Upload Build

### 6.1 Tạo Release Track

1. Vào **Release** > **Production**
2. Click **Create new release**

**Hoặc dùng Internal/Closed/Open Testing trước**:
- **Internal testing**: Tối đa 100 testers, review nhanh
- **Closed testing**: Nhóm testers giới hạn
- **Open testing**: Public beta
- **Production**: Release chính thức

### 6.2 Upload AAB

1. Click **Upload** hoặc kéo thả file AAB
2. Upload: `build/app/outputs/bundle/release/app-release.aab`
3. Chờ processing (1-5 phút)

### 6.3 App Signing by Google Play

**Khuyến nghị sử dụng Google Play App Signing**:

1. Khi upload AAB lần đầu, Google sẽ yêu cầu enrollment
2. Chọn **Enroll**
3. Google sẽ:
   - Tạo **app signing key** (lưu bởi Google)
   - Bạn giữ **upload key** (keystore vừa tạo)
4. Lợi ích:
   - Google quản lý app signing key
   - Có thể reset upload key nếu mất
   - Bảo mật cao hơn

### 6.4 Điền Release Notes

**Release name**: 1.0.0 (hoặc theo version trong pubspec.yaml)

**Release notes** (EN):
```
Initial release of LifeInTheUKPrep!

Features:
- Practice tests for UK visa/citizenship exam
- Bilingual support (English/Vietnamese)
- Chapter-based learning
- Progress tracking
- Detailed answer explanations

Thank you for using our app!
```

**Release notes** (VI):
```
Phát hành đầu tiên của LifeInTheUKPrep!

Tính năng:
- Bài thi thử cho kỳ thi visa/nhập quốc tịch UK
- Hỗ trợ song ngữ (Anh/Việt)
- Học theo chương
- Theo dõi tiến trình
- Giải thích đáp án chi tiết

Cảm ơn bạn đã sử dụng ứng dụng!
```

### 6.5 Thiết Lập Rollout

- **Staged rollout**: Bắt đầu với 5-20% users, tăng dần
- **Full rollout**: 100% ngay lập tức

**Khuyến nghị**: Bắt đầu với 20% rollout, theo dõi crash/reviews.

---

## 7. Hoàn Thiện Store Listing

### 7.1 Main Store Listing

1. Vào **Grow** > **Main store listing**
2. Điền:

**App name**: LifeInTheUKPrep
**Short description** (80 chars):
```
Practice tests for UK citizenship exam. English & Vietnamese support.
```

**Full description** (4000 chars):
```
Prepare for the Life in the UK test with confidence!

LifeInTheUKPrep is your comprehensive study companion for the UK citizenship and visa examination. Whether you're applying for settlement or British citizenship, our app helps you master the official test content.

KEY FEATURES:
✓ Full-length practice tests
✓ Chapter-based learning modules
✓ Bilingual support (English & Vietnamese)
✓ Detailed answer explanations
✓ Progress tracking and history
✓ Offline access to study materials
✓ User-friendly interface with Material Design

STUDY MODES:
• Practice Mode: Learn at your own pace
• Test Mode: Simulate the real exam experience
• Chapter Review: Focus on specific topics
• Mixed Practice: Randomized questions

CONTENT COVERAGE:
All official topics including:
- British values and principles
- UK history and traditions
- Government and law
- Culture and everyday life

BILINGUAL SUPPORT:
Perfect for Vietnamese speakers preparing for the UK test. All content available in both English and Vietnamese to help you understand better.

TRACK YOUR PROGRESS:
Monitor your improvement with detailed statistics, test history, and performance analytics.

NO HIDDEN COSTS:
Free to download and use core features. Optional premium features available.

Perfect for:
- UK visa applicants
- Settlement applicants
- British citizenship candidates
- Anyone studying UK culture and history

Download now and start your journey to passing the Life in the UK test!

Support: [your-email@example.com]
Privacy Policy: [your-privacy-policy-url]
```

**App icon**: Upload 512x512 PNG
**Feature graphic**: Upload 1024x500 PNG/JPG
**Phone screenshots**: Upload 2-8 ảnh
**7-inch tablet screenshots**: (Tùy chọn)
**10-inch tablet screenshots**: (Tùy chọn)

### 7.2 Graphic Assets Checklist

**Cần chuẩn bị**:
- [ ] App icon: 512x512px, 32-bit PNG, no transparency
- [ ] Feature graphic: 1024x500px
- [ ] Screenshots (phone):
  - Home screen
  - Test interface
  - Chapter selection
  - Results screen
  - Settings
  - (Tối thiểu 2, tối đa 8)
- [ ] Screenshots (tablet): Tùy chọn
- [ ] Promo video: YouTube URL (tùy chọn)

**Tools để tạo**:
- Figma, Adobe XD, Canva
- Screenshot từ emulator/device
- Screen recorder cho promo video

### 7.3 Categorization

1. **App category**: Education
2. **Tags** (tối đa 5):
   - Education
   - UK Citizenship
   - Test Preparation
   - Language Learning
   - Reference

### 7.4 Contact Details

- **Website**: https://yourcompany.com (nếu có)
- **Email**: support@yourcompany.com
- **Phone**: +84... (tùy chọn)
- **Privacy Policy**: **BẮT BUỘC** - URL đầy đủ

### 7.5 Store Settings

1. **App pricing**: Free
2. **Distributed countries**:
   - Chọn **Add countries/regions**
   - Chọn **Available in all countries** hoặc chọn specific
   - Khuyến nghị: Ít nhất UK, Vietnam, USA, Canada, Australia

---

## 8. Submit Để Review

### 8.1 Pre-Review Checklist

- [ ] Upload AAB đã sign
- [ ] Hoàn thành Store Listing
- [ ] Upload tất cả graphic assets
- [ ] Điền Content Rating
- [ ] Hoàn thành Data Safety
- [ ] Thêm Privacy Policy
- [ ] Thiết lập pricing & distribution
- [ ] Kiểm tra App Access
- [ ] Khai báo Ads
- [ ] Target Audience

### 8.2 Review Dashboard

1. Vào dashboard chính
2. Kiểm tra tất cả sections có dấu ✓ xanh
3. Không có warning ⚠ hoặc error ❌

### 8.3 Submit App

1. Vào **Release** > **Production** (hoặc testing track)
2. Tại release đã tạo, click **Review release**
3. Xem lại tất cả thông tin
4. Click **Start rollout to Production**
5. Confirm

### 8.4 Review Timeline

- **Review thường mất**: 1-7 ngày (thường 2-3 ngày)
- **Internal testing**: Vài giờ
- **Closed/Open testing**: 1-2 ngày
- **Production**: 3-7 ngày

### 8.5 Theo Dõi Review

1. Check email notifications
2. Vào **Policy status** để xem status
3. Nếu bị reject:
   - Đọc kỹ lý do
   - Fix vấn đề
   - Resubmit

---

## 9. Post-Release

### 9.1 Monitor Metrics

1. **Dashboard** > **Statistics**:
   - Installs
   - Uninstalls
   - Ratings
   - Crashes
   - ANRs (App Not Responding)

2. **Android vitals**:
   - Crash rate (nên < 2%)
   - ANR rate (nên < 0.5%)
   - Battery usage
   - Rendering time

### 9.2 Respond to Reviews

- Phản hồi reviews (tốt và xấu)
- Giải quyết vấn đề users phản ánh
- Update app dựa trên feedback

### 9.3 Release Updates

**Khi có version mới**:

1. Update `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version+buildNumber
   ```

2. Build AAB mới:
   ```bash
   flutter build appbundle --release
   ```

3. Create new release trong Play Console
4. Upload AAB mới
5. Điền release notes
6. Submit

---

## 10. Troubleshooting

### Vấn Đề Thường Gặp

**1. "Upload failed: Version code conflict"**
- **Giải pháp**: Tăng build number trong `pubspec.yaml`
  ```yaml
  version: 1.0.0+2  # Tăng số sau dấu +
  ```

**2. "App not signed properly"**
- **Giải pháp**: Kiểm tra lại `key.properties` và signing config

**3. "Privacy Policy required"**
- **Giải pháp**: Phải có URL privacy policy hợp lệ

**4. "Data safety section incomplete"**
- **Giải pháp**: Điền đầy đủ Data Safety form

**5. "Target SDK version too low"**
- **Giải pháp**: Update targetSdk trong `build.gradle.kts` (hiện tại là 34, OK)

**6. "App bundle contains prohibited permissions"**
- **Giải pháp**: Xem lại `AndroidManifest.xml`, xóa permissions không cần

**7. "Crash on launch"**
- **Giải pháp**:
  - Test trên nhiều devices/emulators
  - Check ProGuard rules nếu bật
  - Review Firebase Crashlytics logs

---

## 11. Compliance & Policies

### 11.1 Google Play Policies

Đọc kỹ:
- **User Data Policy**: https://play.google.com/about/developer-content-policy/#!?modal_active=none
- **Developer Program Policies**: https://play.google.com/about/developer-distribution-agreement/
- **Families Policy** (nếu target trẻ em)

### 11.2 Ads Compliance

Vì app có Google Mobile Ads:
- Phải khai báo ads trong app listing
- Ads phải tuân thủ Google AdMob policies
- Không đặt ads misleading
- Không ads trong test/quiz interface (có thể vi phạm UX policy)

### 11.3 Data Privacy (GDPR, CCPA)

Nếu có users từ EU/California:
- Cho phép users xóa data
- Có consent cho data collection
- Implement "Do Not Track"

---

## 12. Checklist Tổng Hợp

### Trước Khi Upload
- [ ] Đổi package name (khuyến nghị)
- [ ] Tạo và cấu hình upload keystore
- [ ] Update version trong pubspec.yaml
- [ ] Build AAB release
- [ ] Test AAB trên nhiều devices
- [ ] Chuẩn bị graphics (icon, feature graphic, screenshots)
- [ ] Viết store description (EN + VI)
- [ ] Tạo privacy policy
- [ ] Setup AdMob production app ID (đổi từ test ID)

### Trong Play Console
- [ ] Tạo app listing
- [ ] Upload AAB
- [ ] Enroll App Signing
- [ ] Hoàn thành Store Listing
- [ ] Upload graphic assets
- [ ] Điền Content Rating
- [ ] Complete Data Safety
- [ ] Set pricing & distribution
- [ ] Configure App Access
- [ ] Declare Ads
- [ ] Set Target Audience
- [ ] Add contact details

### Submit & Post-Release
- [ ] Review pre-launch report
- [ ] Submit for review
- [ ] Monitor review status
- [ ] Track metrics post-launch
- [ ] Respond to reviews
- [ ] Plan updates

---

## 13. Resources

### Official Documentation
- Google Play Console: https://play.google.com/console
- Developer Policies: https://play.google.com/about/developer-content-policy/
- Flutter Deployment: https://docs.flutter.dev/deployment/android

### Tools
- Bundletool: https://github.com/google/bundletool
- Android Studio: https://developer.android.com/studio
- Fastlane: https://fastlane.tools/

### Support
- Google Play Help: https://support.google.com/googleplay/android-developer
- Flutter Discord: https://discord.gg/flutter
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

## Ghi Chú Bảo Mật

**⚠️ TUYỆT ĐỐI KHÔNG COMMIT**:
- `android/key.properties`
- `android/app/upload-keystore.jks`
- `android/app/*.keystore`
- Bất kỳ file chứa password/credentials

**✓ Backup an toàn**:
- Lưu keystore và passwords vào password manager (1Password, LastPass, Bitwarden)
- Backup keystore lên cloud storage riêng tư (Google Drive, Dropbox - encrypted folder)
- Không gửi qua email hoặc chat

---

**Chúc bạn thành công trong việc đưa app lên Google Play Store!** 🚀
