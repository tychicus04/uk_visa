# LifeInTheUKPrep - Deployment Guide

## 🚀 Tổng Quan

Chào mừng đến với hướng dẫn deployment cho ứng dụng **LifeInTheUKPrep** (UK Visa Test)!

Tài liệu này sẽ hướng dẫn bạn toàn bộ quy trình để đưa app lên **Google Play Store** và **Apple App Store**.

---

## 📚 Tài Liệu

Deployment guide được chia thành các phần sau:

### 1. **[Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md)** ⭐ BẮT ĐẦU TẠI ĐÂY!
- Checklist đầy đủ trước khi deployment
- Design assets requirements
- Account setup
- Legal & privacy requirements
- Security checklist

**👉 Đọc và hoàn thành checklist này TRƯỚC KHI tiếp tục!**

### 2. **[Build and Release Process](./BUILD_AND_RELEASE.md)**
- Step-by-step build guide
- Configuration changes
- Android & iOS build commands
- Testing release builds
- Versioning strategy
- CI/CD setup (optional)

### 3. **[Google Play Deployment](./GOOGLE_PLAY_DEPLOYMENT.md)**
- Chi tiết cách đưa app lên Google Play Console
- Account setup
- Android signing
- Store listing
- Upload & submit
- Post-release monitoring

### 4. **[App Store Deployment](./APP_STORE_DEPLOYMENT.md)**
- Chi tiết cách đưa app lên Apple App Store
- Apple Developer setup
- iOS signing & certificates
- Xcode configuration
- App Store Connect setup
- TestFlight (optional)

---

## 🎯 Quick Start Guide

### Tôi Chưa Bao Giờ Deploy App - Bắt Đầu Từ Đâu?

**Follow theo thứ tự này**:

#### Week 1: Preparation
1. ✅ **Đọc [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md)**
2. ✅ **Tạo accounts**:
   - Google Play Developer Account ($25)
   - Apple Developer Program ($99/năm)
   - Google AdMob account
3. ✅ **Chuẩn bị legal documents**:
   - Viết Privacy Policy
   - Tạo website/landing page (optional nhưng recommended)
4. ✅ **Chuẩn bị design assets**:
   - App icons (512x512 cho Android, multiple sizes cho iOS)
   - Screenshots (phone & tablet)
   - Feature graphic (1024x500 cho Google Play)
   - Store descriptions (English & Vietnamese)

#### Week 2: Configuration & Build
5. ✅ **Đọc [Build and Release Process](./BUILD_AND_RELEASE.md)**
6. ✅ **Update app configuration**:
   - Đổi package/bundle identifiers
   - Update AdMob IDs (production)
   - Set version numbers
7. ✅ **Setup signing**:
   - Android: Tạo keystore
   - iOS: Configure certificates
8. ✅ **Build release versions**:
   - Android AAB
   - iOS IPA

#### Week 3: Testing
9. ✅ **Test release builds** thoroughly:
   - Test trên real devices
   - Check all features work
   - Verify no debug logs
   - Performance testing
10. ✅ **Internal testing** (optional nhưng recommended):
    - Google Play: Internal testing track
    - Apple: TestFlight

#### Week 4: Submission
11. ✅ **Setup store listings**:
    - [Google Play deployment guide](./GOOGLE_PLAY_DEPLOYMENT.md)
    - [App Store deployment guide](./APP_STORE_DEPLOYMENT.md)
12. ✅ **Submit cho review**
13. ✅ **Monitor review status**
14. ✅ **Release to production!** 🎉

---

## 📱 Platform-Specific Guides

### Google Play Store

**Timeline**: ~2-4 tuần từ đầu đến khi live
**Review time**: 1-7 ngày (thường 2-3 ngày)
**Cost**: $25 (one-time fee)

**Bắt đầu**:
1. Đọc [Google Play Deployment Guide](./GOOGLE_PLAY_DEPLOYMENT.md)
2. Hoàn thành [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md) phần Android
3. Follow [Build and Release Process](./BUILD_AND_RELEASE.md) phần Android

**Requirements**:
- Android AAB file (không phải APK!)
- App signing keystore
- Store listing (icon, screenshots, description)
- Privacy Policy URL
- Content rating
- Data safety declaration

### Apple App Store

**Timeline**: ~2-4 tuần từ đầu đến khi live
**Review time**: 1-3 ngày (thường 24-48h)
**Cost**: $99/năm (recurring)

**Bắt đầu**:
1. Đọc [App Store Deployment Guide](./APP_STORE_DEPLOYMENT.md)
2. Hoàn thành [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md) phần iOS
3. Follow [Build and Release Process](./BUILD_AND_RELEASE.md) phần iOS

**Requirements**:
- macOS + Xcode (bắt buộc!)
- iOS IPA file
- Signing certificates & provisioning profiles
- Store listing (icon, screenshots, description)
- Privacy Policy URL
- App Privacy declarations
- Age rating

---

## 🎨 Design Assets Requirements

### Icons

| Platform | Size | Format | Notes |
|----------|------|--------|-------|
| Android (Play Store) | 512x512 px | PNG, 32-bit | High-res icon |
| Android (App) | Multiple densities | PNG | mdpi to xxxhdpi |
| iOS (App Store) | 1024x1024 px | PNG | No alpha channel |
| iOS (App) | Multiple sizes | PNG | 20x20 to 1024x1024 |

### Screenshots

| Platform | Device | Size | Quantity |
|----------|--------|------|----------|
| Android | Phone | 1080x1920+ | 2-8 |
| Android | Tablet (optional) | Variable | 1-8 |
| iOS | iPhone 6.7" | 2796 x 1290 | 1-10 |
| iOS | iPad (optional) | 2048 x 2732 | 1-10 |

### Other Graphics

| Asset | Platform | Size | Format |
|-------|----------|------|--------|
| Feature Graphic | Google Play | 1024x500 | PNG/JPG |
| Promo Video | Both (optional) | 15-120s | YouTube/MP4 |

**Xem chi tiết trong [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md)**

---

## 💰 Cost Breakdown

### One-Time Costs
- **Google Play Developer Account**: $25 USD (one-time)
- **Design assets creation**: $0-500 (nếu thuê designer)

### Recurring Costs
- **Apple Developer Program**: $99 USD/năm
- **Web hosting** (cho privacy policy): $0-10/tháng
- **Domain name** (optional): $10-15/năm

### Optional Costs
- **Firebase** (analytics, crashlytics): Free tier usually sufficient
- **CI/CD** (GitHub Actions): Free for public repos
- **App Store Optimization tools**: $0-100/tháng

**Total estimated cost cho year 1**: ~$150-200 USD

---

## ⏱️ Timeline Estimate

### First-Time Deployment

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Preparation** | 1-2 tuần | Account setup, legal docs, design assets |
| **Configuration** | 2-3 ngày | Update app config, signing setup |
| **Build & Test** | 3-5 ngày | Build releases, testing |
| **Store Setup** | 1-2 ngày | Create listings, upload assets |
| **Review** | 1-7 ngày | Wait for approval |
| **TOTAL** | **3-5 tuần** | From start to live |

### Subsequent Updates

| Phase | Duration | Tasks |
|-------|----------|-------|
| **Development** | Variable | New features, bug fixes |
| **Testing** | 1-2 ngày | Test changes |
| **Build** | 1 giờ | Build new version |
| **Submit** | 30 phút | Upload & submit |
| **Review** | 1-3 ngày | Wait for approval |
| **TOTAL** | **2-5 ngày** | For updates |

---

## 🔐 Security Best Practices

### Credentials & Keys

**NEVER commit these to git**:
- ❌ Android keystore files (`*.jks`, `*.keystore`)
- ❌ `key.properties` (Android)
- ❌ iOS certificates (`*.p12`, `*.cer`)
- ❌ Provisioning profiles (`*.mobileprovision`)
- ❌ `GoogleService-Info.plist` (Firebase iOS)
- ❌ `google-services.json` (Firebase Android)
- ❌ `.env` files với secrets
- ❌ API keys, passwords

**DO backup securely**:
- ✅ Password manager (1Password, Bitwarden, LastPass)
- ✅ Encrypted cloud storage (Google Drive, Dropbox with encryption)
- ✅ Team secrets management (HashiCorp Vault, AWS Secrets Manager)
- ✅ Git-ignored local folder (as secondary backup)

### .gitignore

Đảm bảo `.gitignore` có:

```gitignore
# Android signing
android/key.properties
android/app/upload-keystore.jks
*.keystore

# iOS signing
*.p12
*.cer
*.mobileprovision
ios/exportOptions.plist

# Firebase
**/google-services.json
**/GoogleService-Info.plist

# Environment
.env
.env.local
.env.*.local

# Secrets
secrets/
*.key
*.pem
```

---

## 🛠️ Tools & Resources

### Essential Tools

**Development**:
- [Flutter](https://flutter.dev/) - Framework
- [Android Studio](https://developer.android.com/studio) - Android IDE
- [Xcode](https://developer.apple.com/xcode/) - iOS IDE (macOS only)
- [VS Code](https://code.visualstudio.com/) - Code editor

**Build & Deploy**:
- [Transporter](https://apps.apple.com/app/transporter/id1450874784) - Upload iOS builds
- [Bundletool](https://github.com/google/bundletool) - Test Android App Bundles
- [Fastlane](https://fastlane.tools/) - Automation (advanced)

**Design**:
- [Figma](https://www.figma.com/) - Design tool
- [App Icon Generator](https://appicon.co/) - Generate icon sizes
- [Screenshot Frames](https://www.appstorescreenshot.com/) - Device frames

**Monitoring**:
- [Firebase Console](https://console.firebase.google.com/) - Analytics, Crashlytics
- [Google Play Console](https://play.google.com/console)
- [App Store Connect](https://appstoreconnect.apple.com/)

### Documentation Links

**Official Docs**:
- [Flutter Deployment - Android](https://docs.flutter.dev/deployment/android)
- [Flutter Deployment - iOS](https://docs.flutter.dev/deployment/ios)
- [Google Play Policies](https://play.google.com/about/developer-content-policy/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

**Communities**:
- [Flutter Discord](https://discord.gg/flutter)
- [Flutter Dev Google Group](https://groups.google.com/g/flutter-dev)
- [r/FlutterDev](https://www.reddit.com/r/FlutterDev/)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## 📝 Checklist Tổng Hợp

### Pre-Deployment ✓
- [ ] ✅ Đọc và hoàn thành [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md)
- [ ] 🎨 Design assets prepared
- [ ] 🔐 Accounts created (Google Play + Apple Developer)
- [ ] 📄 Legal docs ready (Privacy Policy)
- [ ] 💳 Payments completed

### Build & Configuration ✓
- [ ] 📖 Đọc [Build and Release Process](./BUILD_AND_RELEASE.md)
- [ ] 📦 Package/Bundle IDs updated
- [ ] 🔑 Signing configured (Android + iOS)
- [ ] 📱 AdMob production IDs set
- [ ] 🏷️ Version numbers updated

### Testing ✓
- [ ] 🧪 Release builds tested
- [ ] 📱 Tested on real devices
- [ ] ⚡ Performance validated
- [ ] 🐛 No critical bugs

### Store Listings ✓
- [ ] 📝 [Google Play listing](./GOOGLE_PLAY_DEPLOYMENT.md) complete
- [ ] 🍎 [App Store listing](./APP_STORE_DEPLOYMENT.md) complete
- [ ] 🖼️ Screenshots uploaded
- [ ] ✍️ Descriptions written (EN + VI)
- [ ] 🔒 Privacy info completed

### Submission ✓
- [ ] ⬆️ Builds uploaded
- [ ] 📋 All store info reviewed
- [ ] ✅ Submit buttons clicked!
- [ ] 📧 Monitoring email cho review updates

---

## 🚨 Common Issues & Solutions

### "Build failed"
**Solution**: Đọc phần Troubleshooting trong [Build and Release Process](./BUILD_AND_RELEASE.md)

### "Cannot upload to Play Console"
**Solution**: Ensure:
- Using AAB (not APK)
- Version code > previous version
- Signed with correct keystore

### "iOS archive failed"
**Solution**: Ensure:
- Opened `.xcworkspace` (not `.xcodeproj`)
- Pods installed (`pod install`)
- Signing configured
- Selected "Any iOS Device"

### "App rejected"
**Solutions**:
- **Google Play**: Check policy violations, fix và resubmit
- **App Store**: Read rejection reason, respond hoặc fix và resubmit

### "Cannot create Apple Developer account"
**Solution**:
- Ensure using valid Apple ID
- Payment method is international card
- Wait for verification (có thể mất 1-2 tuần cho Organization)

---

## 📞 Support

### Cần Trợ Giúp?

**Google Play**:
- [Developer Console Help](https://support.google.com/googleplay/android-developer)
- [Developer Policy Center](https://support.google.com/googleplay/android-developer/topic/9858052)

**Apple**:
- [App Store Connect Help](https://developer.apple.com/support/app-store-connect/)
- [Developer Forums](https://developer.apple.com/forums/)

**Flutter**:
- [Flutter Discord](https://discord.gg/flutter)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- [Flutter GitHub Discussions](https://github.com/flutter/flutter/discussions)

---

## 🎓 Learning Resources

### Video Tutorials
- [Flutter Official - Publishing to Play Store](https://www.youtube.com/watch?v=g0GNuoCOtaQ)
- [Flutter Official - Publishing to App Store](https://www.youtube.com/watch?v=LZLk_zCEvZg)
- [Code with Andrea - Flutter Deployment](https://codewithandrea.com/)

### Blog Posts
- [Publishing Flutter apps to Play Store](https://flutter.dev/docs/deployment/android)
- [Publishing Flutter apps to App Store](https://flutter.dev/docs/deployment/ios)

### Courses (Optional)
- [Udemy - Flutter Complete Guide](https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/)
- [App Store Optimization Course](https://www.udemy.com/topic/app-store-optimization/)

---

## 📊 Next Steps After Launch

### Week 1 Post-Launch
- [ ] Monitor crash rates (target: < 2%)
- [ ] Check reviews daily
- [ ] Respond to user feedback
- [ ] Track downloads/installs
- [ ] Monitor performance metrics

### Month 1
- [ ] Analyze user behavior (Firebase Analytics)
- [ ] Identify top issues from reviews
- [ ] Plan first update
- [ ] A/B test store listing (screenshots, description)

### Ongoing
- [ ] Monthly updates (bug fixes, improvements)
- [ ] Quarterly feature releases
- [ ] Monitor competitors
- [ ] Improve ASO (App Store Optimization)
- [ ] Build user community

---

## 🎯 Key Takeaways

1. **Start Early**: Account verification có thể mất vài tuần
2. **Follow Checklist**: Dùng [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md) để không miss bước nào
3. **Test Thoroughly**: Test release builds trên real devices
4. **Read Guidelines**: Google Play và App Store policies
5. **Backup Everything**: Keystores, certificates, passwords
6. **Be Patient**: Review process có thể mất 1-7 ngày
7. **Monitor Post-Launch**: Track metrics và respond to users

---

## 📄 Document Version

- **Version**: 1.0.0
- **Last Updated**: 2025-10-21
- **App Version**: 1.0.0
- **Status**: Initial Release Documentation

---

## 🤝 Contributing

Nếu bạn tìm thấy lỗi hoặc có suggestions để improve documentation:

1. Open an issue
2. Submit a pull request
3. Contact team

---

## 📜 License & Legal

**App**: LifeInTheUKPrep © 2025

**Documentation**: Miễn phí sử dụng cho internal purposes

**Disclaimer**: Tài liệu này được cung cấp "as-is". Luôn refer to official documentation từ Google Play và Apple App Store cho latest requirements.

---

## 🚀 Ready to Deploy?

**Bắt đầu deployment journey của bạn**:

1. ⭐ **Bắt đầu với**: [Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md)
2. 🔨 **Sau đó**: [Build and Release Process](./BUILD_AND_RELEASE.md)
3. 🤖 **Android**: [Google Play Deployment](./GOOGLE_PLAY_DEPLOYMENT.md)
4. 🍎 **iOS**: [App Store Deployment](./APP_STORE_DEPLOYMENT.md)

---

**Chúc bạn thành công với deployment! Good luck! 🎉🚀📱**

---

## Quick Links

- [📋 Pre-Deployment Checklist](./PRE_DEPLOYMENT_CHECKLIST.md)
- [🔨 Build and Release Process](./BUILD_AND_RELEASE.md)
- [🤖 Google Play Deployment](./GOOGLE_PLAY_DEPLOYMENT.md)
- [🍎 App Store Deployment](./APP_STORE_DEPLOYMENT.md)
