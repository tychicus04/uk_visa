# Hướng Dẫn Đưa App Lên Apple App Store

## Tổng Quan
Tài liệu này hướng dẫn chi tiết cách đưa ứng dụng **LifeInTheUKPrep** (UK Visa Test) lên Apple App Store.

---

## 📋 Mục Lục
1. [Yêu Cầu Chuẩn Bị](#1-yêu-cầu-chuẩn-bị)
2. [Tạo Apple Developer Account](#2-tạo-apple-developer-account)
3. [Cấu Hình Xcode Project](#3-cấu-hình-xcode-project)
4. [App ID & Certificates](#4-app-id--certificates)
5. [Provisioning Profiles](#5-provisioning-profiles)
6. [Build & Archive](#6-build--archive)
7. [App Store Connect Setup](#7-app-store-connect-setup)
8. [Upload Build](#8-upload-build)
9. [Submit Để Review](#9-submit-để-review)
10. [TestFlight (Optional)](#10-testflight-optional)

---

## 1. Yêu Cầu Chuẩn Bị

### 1.1 Yêu Cầu Phần Cứng & Phần Mềm
- **macOS** (bắt buộc - không thể build iOS từ Windows/Linux)
- **Xcode** (phiên bản mới nhất, hiện tại: Xcode 15+)
- **Flutter** đã cài đặt và cấu hình
- **CocoaPods** đã cài đặt
- **iPhone/iPad** (để test - khuyến nghị) hoặc Simulator

```bash
# Kiểm tra requirements
flutter doctor -v
xcode-select --version
pod --version
```

### 1.2 Tài Khoản & Phí
- **Apple Developer Program**: $99 USD/năm (phí hàng năm, không phải một lần)
- **Apple ID** (cá nhân hoặc doanh nghiệp)
- **Thẻ tín dụng/ghi nợ** quốc tế

**Loại tài khoản**:
- **Individual**: Cho cá nhân ($99/năm)
- **Organization**: Cho công ty/tổ chức ($99/năm, cần giấy tờ pháp lý)
- **Enterprise**: Cho phân phối nội bộ ($299/năm)

### 1.3 Thông Tin Cần Có
- [ ] **App name**: LifeInTheUKPrep (hoặc UK Visa Test)
- [ ] **Bundle Identifier**: `com.example.ukVisaTest` (nên đổi thành domain riêng)
- [ ] **SKU**: Mã định danh duy nhất (ví dụ: `ukvisatest001`)
- [ ] **Primary language**: English (US) hoặc Vietnamese
- [ ] **App subtitle**: Tối đa 30 ký tự
- [ ] **Privacy Policy URL** (bắt buộc)
- [ ] **Support URL**
- [ ] **Marketing URL** (tùy chọn)
- [ ] **App Icon**: 1024x1024 px (PNG, không alpha channel)
- [ ] **Screenshots**:
  - iPhone 6.7" (iPhone 15 Pro Max): 1-10 ảnh (2796 x 1290 px)
  - iPhone 6.5" (iPhone 14 Plus): 1-10 ảnh (optional)
  - iPhone 5.5" (iPhone 8 Plus): 1-10 ảnh (optional)
  - iPad Pro 12.9": 1-10 ảnh (2048 x 2732 px) - optional
- [ ] **App Preview Videos** (tùy chọn): 15-30 giây

### 1.4 Tài Liệu Pháp Lý
- [ ] Chính sách quyền riêng tư (Privacy Policy) - **BẮT BUỘC**
- [ ] EULA (End User License Agreement) - tùy chọn
- [ ] App Privacy Questions & Answers
- [ ] Export Compliance Information

---

## 2. Tạo Apple Developer Account

### Bước 1: Đăng Ký
1. Truy cập: https://developer.apple.com/programs/enroll/
2. Đăng nhập bằng Apple ID
3. Chọn **Individual** hoặc **Organization**
4. Điền thông tin:
   - Legal name
   - Contact information
   - Address
5. Thanh toán $99 USD
6. Chờ xác minh (1-2 ngày, đôi khi tới 1 tuần)

### Bước 2: Xác Minh (Organization)
Nếu đăng ký tài khoản Organization:
- Cần D-U-N-S Number
- Giấy phép kinh doanh
- Có thể mất 1-2 tuần để Apple xác minh

### Bước 3: Accept Agreements
1. Vào **Apple Developer** > **Account** > **Agreements, Tax, and Banking**
2. Accept **Apple Developer Program License Agreement**
3. Thiết lập **Tax Forms** (W-8BEN cho non-US entities)
4. Thiết lập **Banking** (nếu có paid app hoặc IAP)

---

## 3. Cấu Hình Xcode Project

### 3.1 Mở Project Trong Xcode

```bash
cd /home/user/uk_visa/uk_visa_test

# Install iOS dependencies
cd ios
pod install
cd ..

# Mở Xcode workspace (QUAN TRỌNG: phải mở .xcworkspace, không phải .xcodeproj!)
open ios/Runner.xcworkspace
```

### 3.2 Cấu Hình General Settings

Trong Xcode:

1. **Select Runner** (project root) > **Runner** (target)
2. Tab **General**:

**Identity**:
- **Display Name**: LifeInTheUKPrep
- **Bundle Identifier**: `com.yourcompany.ukvisatest`
  - **⚠️ QUAN TRỌNG**: Đổi từ `com.example.ukVisaTest`
  - Phải unique trên toàn App Store
  - Không thể đổi sau khi đã submit

**Deployment Info**:
- **Deployment Target**: iOS 12.0 hoặc cao hơn (khuyến nghị iOS 13.0+)
- **Devices**: iPhone, iPad (hoặc chỉ iPhone)
- **Orientations**:
  - Portrait ✓
  - Landscape (tùy app)

**App Icons and Launch Screen**:
- **App Icon Source**: AppIcon (từ Assets.xcassets)
- **Launch Screen File**: LaunchScreen

3. Tab **Signing & Capabilities**:
- **Automatically manage signing**: ✓ (khuyến nghị cho Flutter)
- **Team**: Chọn team từ Apple Developer Account
- **Signing Certificate**: Tự động (Xcode quản lý)

**Thêm Capabilities** (nếu cần):
- **In-App Purchase**: Nếu có IAP
- **Push Notifications**: Nếu có push notifs
- **App Groups**: Nếu share data với extensions
- **Associated Domains**: Nếu có universal links

### 3.3 Update Info.plist

File: `/home/user/uk_visa/uk_visa_test/ios/Runner/Info.plist`

**Cần kiểm tra/thêm**:

```xml
<dict>
    <!-- App Display Name -->
    <key>CFBundleDisplayName</key>
    <string>LifeInTheUKPrep</string>

    <!-- Privacy Descriptions (BẮT BUỘC nếu request permissions) -->
    <!-- Nếu app request tracking (cho ads) -->
    <key>NSUserTrackingUsageDescription</key>
    <string>We use tracking to show you personalized ads and improve your experience.</string>

    <!-- Google Mobile Ads App ID (ĐỔI TỪ TEST ID!) -->
    <key>GADApplicationIdentifier</key>
    <string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>

    <!-- Supported Orientations -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <!-- <string>UIInterfaceOrientationLandscapeLeft</string> -->
        <!-- <string>UIInterfaceOrientationLandscapeRight</string> -->
    </array>

    <!-- Status Bar -->
    <key>UIStatusBarHidden</key>
    <false/>

    <!-- Launch Screen -->
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
</dict>
```

**⚠️ Privacy Permissions**:
- App Store từ iOS 14+ yêu cầu `NSUserTrackingUsageDescription` nếu có ads/tracking
- Thêm description rõ ràng tại sao cần permission

### 3.4 Update AdMob App ID

**Hiện tại trong code**: Test AdMob ID
```xml
<string>ca-app-pub-3940256099942544~1458002511</string>
```

**Phải đổi sang Production AdMob App ID**:
1. Vào Google AdMob Console: https://apps.admob.com/
2. Tạo app mới hoặc lấy App ID
3. Update trong `Info.plist`

### 3.5 App Icons

**Yêu cầu**:
- File: `/home/user/uk_visa/uk_visa_test/ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- Sizes: 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024
- Format: PNG, không alpha channel

**Tool tự động generate**:
- https://appicon.co/
- https://www.appicon.build/
- Upload 1024x1024, tải về toàn bộ sizes

### 3.6 Bundle Identifier Best Practices

**Đổi Bundle ID**:

1. Trong Xcode: Runner > General > Bundle Identifier
   ```
   com.yourcompany.ukvisatest
   ```

2. Update trong Flutter project:
   - File: `ios/Runner.xcodeproj/project.pbxproj`
   - Xcode sẽ tự update khi bạn đổi trong GUI

**⚠️ Lưu ý**:
- Bundle ID phải unique trên toàn App Store
- Không thể đổi sau khi submit app
- Format: reverse-domain style (com.company.appname)

---

## 4. App ID & Certificates

### 4.1 Tạo App ID

1. Vào **Apple Developer** > **Certificates, IDs & Profiles**
2. Click **Identifiers** > **+** (Add)
3. Select **App IDs** > **Continue**
4. Chọn **App** > **Continue**
5. Điền:
   - **Description**: LifeInTheUKPrep
   - **Bundle ID**: Explicit - `com.yourcompany.ukvisatest`
   - **Capabilities**:
     - ✓ In-App Purchase (nếu có)
     - ✓ Push Notifications (nếu có)
     - ✓ Associated Domains (nếu có)
6. **Continue** > **Register**

**Lưu ý**: Nếu dùng Xcode automatic signing, Xcode sẽ tự tạo App ID.

### 4.2 Certificates

**Xcode sẽ tự quản lý** nếu dùng "Automatically manage signing".

**Manual certificate management**:
1. Vào **Certificates, IDs & Profiles** > **Certificates**
2. Click **+**
3. Chọn:
   - **iOS Distribution** (cho App Store)
   - **Apple Development** (cho testing)
4. Follow wizard:
   - Tạo CSR (Certificate Signing Request) từ Keychain Access
   - Upload CSR
   - Download certificate
   - Double-click để cài vào Keychain

---

## 5. Provisioning Profiles

### 5.1 Automatic Provisioning (Khuyến Nghị)

Trong Xcode:
1. Runner > Signing & Capabilities
2. ✓ **Automatically manage signing**
3. Chọn **Team**
4. Xcode sẽ tự tạo provisioning profiles

### 5.2 Manual Provisioning

1. Vào **Apple Developer** > **Profiles**
2. Click **+**
3. Select **App Store** (cho distribution)
4. Chọn App ID đã tạo
5. Chọn Distribution Certificate
6. **Generate** > Download
7. Double-click để cài đặt

---

## 6. Build & Archive

### 6.1 Chuẩn Bị Build

```bash
cd /home/user/uk_visa/uk_visa_test

# Clean
flutter clean
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Install iOS dependencies
cd ios
pod install
pod update
cd ..
```

### 6.2 Update Version & Build Number

File: `/home/user/uk_visa/uk_visa_test/pubspec.yaml`

```yaml
version: 1.0.0+1  # version+buildNumber
```

**Version format**:
- **Version**: 1.0.0 (hiển thị cho users)
- **Build number**: 1 (internal, phải tăng mỗi lần upload)

**Best practice**:
- Version: Semantic versioning (major.minor.patch)
- Build: Integer, tăng dần mỗi build

### 6.3 Build iOS Release

**Option 1: Flutter CLI (Khuyến nghị cho CI/CD)**

```bash
# Build IPA (cho App Store)
flutter build ipa --release

# Output: build/ios/ipa/uk_visa_test.ipa
```

**Option 2: Xcode Archive (Khuyến nghị cho lần đầu)**

1. Mở Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Chọn **Any iOS Device (arm64)** từ device dropdown (KHÔNG chọn simulator!)

3. **Product** > **Clean Build Folder** (Shift+Cmd+K)

4. **Product** > **Archive** (Cmd+B sau đó Shift+Cmd+Option+K)
   - Chờ build (5-15 phút tùy máy)
   - Nếu thành công, Organizer window sẽ mở

5. Trong **Organizer** window:
   - Chọn archive vừa tạo
   - Click **Distribute App**

### 6.4 Distribute App

Trong Xcode Organizer:

1. **Distribute App** > Chọn method:
   - **App Store Connect** (cho submit lên App Store)
   - **Ad Hoc** (cho testing trên devices cụ thể)
   - **Enterprise** (cho enterprise distribution)
   - **Development** (cho local testing)

2. Chọn **App Store Connect** > **Next**

3. **Upload** hoặc **Export**:
   - **Upload**: Upload trực tiếp lên App Store Connect
   - **Export**: Export IPA để upload sau (qua Transporter)

4. Distribution options:
   - ✓ **Include bitcode**: NO (deprecated từ Xcode 14)
   - ✓ **Upload your app's symbols**: YES (cho crash reports)
   - ✓ **Manage version and build number**: Xcode managed (khuyến nghị)

5. **Re-sign** với Distribution certificate

6. Review > **Upload** hoặc **Export**

**Nếu Upload thành công**:
- Xcode sẽ upload lên App Store Connect
- Chờ processing (15-60 phút)
- Nhận email "Build processed" từ Apple

---

## 7. App Store Connect Setup

### 7.1 Tạo App Listing

1. Vào **App Store Connect**: https://appstoreconnect.apple.com/
2. Click **My Apps** > **+** > **New App**
3. Điền:
   - **Platforms**: ✓ iOS
   - **Name**: LifeInTheUKPrep (phải unique, 30 chars max)
   - **Primary Language**: English (U.S.) hoặc Vietnamese
   - **Bundle ID**: Chọn từ dropdown (com.yourcompany.ukvisatest)
   - **SKU**: `ukvisatest001` (ID nội bộ, không hiển thị)
   - **User Access**: Full Access (hoặc Limited)
4. Click **Create**

### 7.2 App Information

1. Vào app vừa tạo > **App Information**

**General Information**:
- **Name**: LifeInTheUKPrep
- **Subtitle** (30 chars):
  ```
  UK Citizenship Test Prep
  ```
- **Category**:
  - **Primary**: Education
  - **Secondary**: Reference (optional)

**Privacy**:
- **Privacy Policy URL**: **BẮT BUỘC** - https://yoursite.com/privacy
- **User Privacy Choices URL**: (nếu có opt-out cho data collection)

**License Agreement**:
- Dùng Apple's Standard EULA (mặc định)
- Hoặc upload custom EULA

### 7.3 Pricing and Availability

1. **Price Schedule**:
   - **Free** (khuyến nghị)
   - Hoặc chọn price tier ($0.99, $1.99, ...)

2. **Availability**:
   - **Countries/Regions**: Chọn all hoặc specific countries
   - Khuyến nghị: Ít nhất UK, Vietnam, USA, Canada, Australia

3. **Pre-Order**: (tùy chọn, nếu muốn pre-order trước launch)

### 7.4 App Privacy

**⚠️ BẮT BUỘC từ iOS 14.5+**

1. Vào **App Privacy**
2. Click **Get Started**

**Data Collection**:

Dựa vào code của bạn, cần khai báo:

**1. Contact Info**:
- **Email Address**: (nếu có đăng ký/login)
  - Purpose: App Functionality
  - Linked to user: Yes
  - Used for tracking: No

**2. Identifiers**:
- **Device ID**: (cho Google Mobile Ads)
  - Purpose: Advertising, Analytics
  - Linked to user: No
  - Used for tracking: Yes

**3. Usage Data**:
- **Product Interaction**: (test results, study progress)
  - Purpose: App Functionality, Analytics
  - Linked to user: Yes
  - Used for tracking: No

**4. Advertising Data**:
- Nếu có Google AdMob:
  - Purpose: Third-Party Advertising
  - Linked to user: No
  - Used for tracking: Yes

3. **Data Retention**:
   - Khai báo retention policy
   - User can request deletion: Yes/No

4. **Save**

### 7.5 App Store Screenshots & Previews

**Yêu cầu sizes**:

| Device | Size (Portrait) | Required |
|--------|----------------|----------|
| iPhone 6.7" (15 Pro Max) | 2796 x 1290 px | **YES** |
| iPhone 6.5" (14 Plus) | 2688 x 1242 px | Optional |
| iPhone 5.5" (8 Plus) | 2208 x 1242 px | Optional |
| iPad Pro 12.9" | 2048 x 2732 px | Optional |
| iPad Pro 11" | 2388 x 1668 px | Optional |

**Số lượng**: 1-10 screenshots mỗi size

**Content**:
- Home screen
- Test interface
- Question screen
- Results/progress
- Settings
- Language switch demo

**Tools**:
- Xcode Simulator > Screenshot (Cmd+S)
- Figma/Sketch với device frames
- Screenshot tools: https://www.appstorescreenshot.com/

**App Preview Video** (optional):
- 15-30 giây
- Format: .mov, .m4v, .mp4
- Upload lên App Store Connect

---

## 8. Upload Build

### 8.1 Upload Qua Xcode

Đã upload trong bước 6.4.

### 8.2 Upload Qua Transporter (Alternative)

**Nếu đã export IPA**:

1. Mở **Transporter** app (có sẵn trên macOS App Store)
2. Đăng nhập bằng Apple ID
3. Click **+** hoặc kéo thả IPA file
4. Click **Deliver**
5. Chờ upload (5-30 phút tùy internet)

### 8.3 Kiểm Tra Build Trong App Store Connect

1. Vào **App Store Connect** > App > **TestFlight**
2. Tab **iOS**
3. Chờ build xuất hiện (15-60 phút)
4. Status: **Processing** → **Ready to Submit**

**Nếu có lỗi**:
- Check email từ Apple
- Common issues:
  - Missing compliance info
  - Invalid Info.plist
  - Missing icons
  - API usage issues

### 8.4 Export Compliance

Khi build processed, cần trả lời:

**"Does your app use encryption?"**
- Nếu chỉ dùng HTTPS: **No** (exempt)
- Nếu có custom encryption: **Yes** → Cần export compliance doc

**Cho app này**:
- Chọn **No** (app chỉ dùng standard HTTPS)

---

## 9. Submit Để Review

### 9.1 Version Information

1. Vào **App Store Connect** > App > **App Store** tab
2. Click **+** (New version) hoặc chọn version hiện tại
3. Điền **Version**: 1.0.0

**What's New in This Version** (Release notes):
```
Initial release of LifeInTheUKPrep!

✓ Comprehensive UK citizenship test preparation
✓ Practice tests and chapter-based learning
✓ Bilingual support (English & Vietnamese)
✓ Track your progress and review history
✓ Detailed explanations for every answer
✓ Offline access to all content

Perfect for anyone preparing for the Life in the UK test. Download now and ace your exam!
```

### 9.2 App Store Description

**Promotional Text** (170 chars, có thể edit sau khi release):
```
Master the Life in the UK test with our comprehensive prep app. Features practice tests, study guides, and bilingual support. Download free today!
```

**Description** (4000 chars max):
```
Prepare for your UK citizenship or visa test with confidence!

LifeInTheUKPrep is the ultimate study companion for the official "Life in the UK" test. Whether you're applying for settlement, indefinite leave to remain, or British citizenship, our app provides everything you need to pass the exam.

━━━━━━━━━━━━━━━━━━━━━━
✓ KEY FEATURES
━━━━━━━━━━━━━━━━━━━━━━

📝 COMPREHENSIVE PRACTICE TESTS
• Full-length mock exams simulating the real test
• Hundreds of practice questions
• Official test format and timing
• Instant feedback and scoring

📚 CHAPTER-BASED LEARNING
• Organized by official study topics
• British values and principles
• UK history and traditions
• Government and law
• Modern British culture

🌍 BILINGUAL SUPPORT
• Full content in English & Vietnamese
• Perfect for Vietnamese speakers
• Switch languages anytime
• Understand concepts better

📊 TRACK YOUR PROGRESS
• Detailed performance analytics
• Test history and results
• Identify weak areas
• Monitor improvement over time

💡 DETAILED EXPLANATIONS
• Learn from every question
• Understand why answers are correct
• Reference official handbook content
• Build real knowledge, not just memorization

📱 OFFLINE ACCESS
• Study anywhere, anytime
• No internet required after download
• All content available offline
• Sync progress when online

━━━━━━━━━━━━━━━━━━━━━━
🎯 PERFECT FOR
━━━━━━━━━━━━━━━━━━━━━━

• UK visa applicants
• Settlement (ILR) candidates
• British citizenship applicants
• Anyone interested in UK culture
• Students and learners

━━━━━━━━━━━━━━━━━━━━━━
📖 COMPLETE COVERAGE
━━━━━━━━━━━━━━━━━━━━━━

Our content covers all official topics:
✓ The values and principles of the UK
✓ What is the UK?
✓ A long and illustrious history
✓ A modern, thriving society
✓ The UK government, law and your role

━━━━━━━━━━━━━━━━━━━━━━
🏆 WHY CHOOSE US
━━━━━━━━━━━━━━━━━━━━━━

• Regularly updated content
• User-friendly interface
• Based on official handbook
• Proven study methods
• Free to download and use

━━━━━━━━━━━━━━━━━━━━━━
💬 SUPPORT
━━━━━━━━━━━━━━━━━━━━━━

Need help? Contact us:
Email: support@yourcompany.com
Website: https://yourcompany.com

Privacy Policy: https://yourcompany.com/privacy
Terms of Service: https://yourcompany.com/terms

━━━━━━━━━━━━━━━━━━━━━━

Download LifeInTheUKPrep today and take the first step toward passing your UK citizenship test!

Good luck with your exam! 🇬🇧
```

**Keywords** (100 chars, comma-separated):
```
UK test,citizenship,visa,Life in UK,british,exam,IELTS,immigration,settlement,study
```

**Support URL**: https://yourcompany.com/support
**Marketing URL**: https://yourcompany.com (optional)

### 9.3 Select Build

1. Scroll to **Build** section
2. Click **Select a build before you submit your app**
3. Chọn build vừa upload
4. Click **Done**

### 9.4 Rating

**Age Rating**:
1. Click **Edit** next to Age Rating
2. Trả lời questionnaire:
   - Alcohol, Tobacco, Drug: None
   - Gambling: None
   - Sexual Content: None
   - Violence: None
   - Profanity: None
   - Horror/Fear: None
   - Mature/Suggestive: None
   - Contests: None
   - Made for Kids: No
3. Likely rating: **4+** (Everyone)

### 9.5 Copyright & Contact

**Copyright**: 2025 Your Company Name
**Contact Information**:
- First name
- Last name
- Phone number
- Email

### 9.6 App Review Information

**Contact Information** (cho Apple reviewers):
- First Name
- Last Name
- Phone Number
- Email

**Demo Account** (nếu app cần login):
- Username: demo@example.com
- Password: Demo123!
- Notes: Any special instructions

**Notes** (cho reviewers):
```
Thank you for reviewing LifeInTheUKPrep!

This app helps users prepare for the official UK citizenship test ("Life in the UK" test).

Features:
- Practice tests based on official content
- Study materials in English and Vietnamese
- No login required for core features
- Contains ads (Google AdMob)

All content is educational and suitable for all ages.

Please contact us if you have any questions.
```

### 9.7 Version Release

**Release Options**:
- ☑ **Automatically release this version** (ngay khi approved)
- ☐ **Manually release this version** (release khi bạn muốn sau khi approved)
- ☐ **Schedule for release** (release vào ngày cụ thể)

### 9.8 Submit

1. Review tất cả thông tin
2. Kiểm tra checklist:
   - ✓ Version info filled
   - ✓ Description written
   - ✓ Screenshots uploaded
   - ✓ Build selected
   - ✓ Age rating set
   - ✓ Privacy info completed
   - ✓ Pricing set
3. Click **Add for Review** (góc trên bên phải)
4. Confirm > **Submit for Review**

---

## 10. TestFlight (Optional)

### 10.1 Internal Testing

**Setup**:
1. Vào **TestFlight** tab
2. **Internal Testing** section
3. Click **+** để tạo group
4. Thêm testers (dùng email Apple ID)
5. Testers nhận email invite
6. Download TestFlight app > Install build

**Limits**:
- Tối đa 100 internal testers
- Không cần App Review
- Build available ngay lập tức

### 10.2 External Testing

**Setup**:
1. **External Testing** section
2. Click **+** tạo group
3. Điền:
   - Group name
   - Enable public link (optional)
   - Add testers (email hoặc public link)
4. Thêm build
5. Điền test information (như App Store submission)
6. Submit cho Beta App Review (1-2 ngày)

**Limits**:
- Tối đa 10,000 external testers
- Cần Beta App Review
- Public link: Anyone với link có thể test

### 10.3 TestFlight Beta Info

**What to Test** (cho testers):
```
Thank you for testing LifeInTheUKPrep!

Please test:
✓ Taking practice tests
✓ Reviewing chapters
✓ Switching between English and Vietnamese
✓ Checking your progress/history
✓ App performance and stability

Report bugs or feedback to: beta@yourcompany.com

What's new in this build:
- Initial beta release
- Core features implemented
```

---

## 11. Review Process & Timeline

### 11.1 App Review Timeline

**Typical timeline**:
- **In Review**: 1-3 ngày (thường 24-48h)
- **Pending Developer Release**: Approved, chờ bạn release
- **Ready for Sale**: Đã live trên App Store

**Status tracking**:
1. **Waiting for Review**: Đang chờ queue
2. **In Review**: Apple đang review
3. **Pending Developer Release**: Approved, chờ manual release
4. **Ready for Sale**: Live!
5. **Rejected**: Bị từ chối (xem rejection reasons)

### 11.2 Common Rejection Reasons

**1. Guideline 2.1 - App Completeness**
- App crashes
- Missing features
- Broken links
- Issue: Fix bugs, test thoroughly

**2. Guideline 4.3 - Spam**
- App quá giống apps khác
- Issue: Differentiate app, add unique features

**3. Guideline 5.1.1 - Privacy**
- Missing privacy policy
- Privacy info không đầy đủ
- Issue: Update privacy policy, app privacy section

**4. Guideline 2.3.10 - Accurate Metadata**
- Screenshots không match app
- Description sai lệch
- Issue: Update screenshots, description

**5. Guideline 4.2 - Minimum Functionality**
- App quá đơn giản
- Issue: Add more features

### 11.3 Nếu Bị Reject

1. **Đọc rejection message**:
   - App Store Connect > Resolution Center
   - Email từ Apple

2. **Fix issues**:
   - Update code nếu cần
   - Update metadata
   - Rebuild và upload

3. **Respond** (nếu cần clarification):
   - Trong Resolution Center
   - Giải thích hoặc hỏi thêm

4. **Resubmit**:
   - Fix xong, click **Resubmit**
   - Vào queue review lại

---

## 12. Post-Release

### 12.1 Monitor App

1. **Sales and Trends**:
   - Downloads
   - Updates
   - In-app purchases

2. **App Analytics**:
   - Sessions
   - Active devices
   - Crashes
   - Retention

3. **Ratings & Reviews**:
   - App Store Connect > Ratings and Reviews
   - Respond to reviews (khuyến nghị)

### 12.2 Update App

**Khi có version mới**:

1. Update `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # version+buildNumber
   ```

2. Build và upload IPA mới

3. Trong App Store Connect:
   - Create new version (1.0.1)
   - Điền "What's New"
   - Select build mới
   - Submit for review

**Update types**:
- **Bug fixes**: Patch version (1.0.1)
- **New features**: Minor version (1.1.0)
- **Major changes**: Major version (2.0.0)

### 12.3 Phased Release

**Enable phased release**:
1. Version page > **Phased Release**
2. Enable
3. Distribution:
   - Day 1: 1% users
   - Day 2: 2%
   - Day 3: 5%
   - Day 4: 10%
   - Day 5: 20%
   - Day 6: 50%
   - Day 7: 100%

**Benefits**:
- Catch bugs early
- Can pause release nếu có issue critical

---

## 13. Troubleshooting

### Issue 1: "App Specific Password Required"

**Solution**:
1. Vào appleid.apple.com
2. Sign in > Security > App-Specific Passwords
3. Generate password
4. Dùng password này thay vì Apple ID password

### Issue 2: "No code signing identities found"

**Solution**:
```bash
# Check certificates
security find-identity -v -p codesigning

# If none, create in Xcode:
# Preferences > Accounts > Manage Certificates > +
```

### Issue 3: "Build failed with CocoaPods"

**Solution**:
```bash
cd ios
rm Podfile.lock
rm -rf Pods
pod cache clean --all
pod install
```

### Issue 4: "Invalid Swift Support"

**Solution**:
- Issue: App chứa Swift frameworks
- Fix: Xcode tự fix, hoặc update CocoaPods

### Issue 5: "Missing compliance"

**Solution**:
1. App Store Connect > App > Build
2. Provide export compliance info
3. Usually select "No" for standard apps

### Issue 6: "Provisioning profile doesn't match"

**Solution**:
1. Xcode > Preferences > Accounts > Download Manual Profiles
2. Hoặc: Delete derived data
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

### Issue 7: "Bitcode error"

**Solution**:
- Bitcode deprecated từ Xcode 14
- Build Settings > Enable Bitcode = No

---

## 14. Checklist Tổng Hợp

### Trước Khi Build
- [ ] Đăng ký Apple Developer Program ($99)
- [ ] Đổi Bundle Identifier
- [ ] Update AdMob App ID (từ test sang production)
- [ ] Add App Icons (all sizes)
- [ ] Update Info.plist (privacy descriptions)
- [ ] Update version trong pubspec.yaml
- [ ] Test trên real device
- [ ] Chuẩn bị screenshots (iPhone 6.7", iPad optional)
- [ ] Viết Privacy Policy
- [ ] Viết app description

### Trong Xcode
- [ ] Configure signing (automatic hoặc manual)
- [ ] Select team
- [ ] Build & Archive
- [ ] Distribute app (upload to App Store Connect)

### Trong App Store Connect
- [ ] Tạo app listing
- [ ] Upload screenshots
- [ ] Điền description, keywords
- [ ] Complete App Privacy
- [ ] Set pricing & availability
- [ ] Select build
- [ ] Set age rating
- [ ] Fill app review information
- [ ] Submit for review

### Post-Submission
- [ ] Monitor review status
- [ ] Check email từ Apple
- [ ] Respond nếu có questions
- [ ] Release khi approved
- [ ] Monitor analytics
- [ ] Respond to reviews

---

## 15. Resources

### Official Documentation
- App Store Connect: https://appstoreconnect.apple.com/
- App Store Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- Flutter iOS Deployment: https://docs.flutter.dev/deployment/ios

### Tools
- Xcode: https://developer.apple.com/xcode/
- Transporter: https://apps.apple.com/app/transporter/id1450874784
- TestFlight: https://developer.apple.com/testflight/
- Fastlane: https://fastlane.tools/

### Support
- Apple Developer Forums: https://developer.apple.com/forums/
- App Store Connect Help: https://developer.apple.com/contact/
- Flutter Discord: https://discord.gg/flutter

---

## 16. Security Notes

**⚠️ TUYỆT ĐỐI KHÔNG COMMIT**:
- `ios/Runner.xcodeproj/project.pbxproj` (có thể chứa secrets)
- `ios/exportOptions.plist`
- `*.p12`, `*.cer`, `*.mobileprovision`
- `GoogleService-Info.plist` (Firebase)

**✓ Backup an toàn**:
- Certificates và provisioning profiles (download từ Apple Developer)
- Lưu vào password manager
- Backup encrypted

**⚠️ Team Management**:
- Chỉ thêm trusted members vào Apple Developer team
- Sử dụng role-based access (Admin, Developer, etc.)

---

**Chúc bạn thành công trong việc đưa app lên Apple App Store!** 🍎🚀
