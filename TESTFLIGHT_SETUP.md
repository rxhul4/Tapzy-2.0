# TestFlight Deployment Setup - Completed

## iOS Configuration for Codemagic TestFlight Upload

### ✅ Completed Configurations

#### 1. **Info.plist** (`ios/Runner/Info.plist`)
Added the following permissions and configurations:

- **Background Modes for Push Notifications:**
  - `fetch` - Background fetch capability
  - `remote-notification` - Push notification background mode

- **Existing Permissions (Already Configured):**
  - Camera Usage (`NSCameraUsageDescription`)
  - Photo Library Usage (`NSPhotoLibraryUsageDescription`)
  - NFC Reader Usage (`NFCReaderUsageDescription`)
  - Associated Domains (Deep linking)
  - NFC Felica System Codes
  - NFC ISO7816 Select Identifiers

#### 2. **Runner.entitlements** (`ios/Runner.entitlements`)
Added the following entitlements:

- **Push Notifications:**
  - `aps-environment` set to `development` (Codemagic will handle production)
  
- **Associated Domains:**
  - Configured for deep linking support
  
- **NFC Reader Session:**
  - TAG format support (already configured)

#### 3. **Podfile** (`ios/Podfile`)
Already configured with:
- Camera permission enabled (`PERMISSION_CAMERA=1`)
- Photos permission enabled (`PERMISSION_PHOTOS=1`)
- Permission handler setup

#### 4. **Dependencies** (`pubspec.yaml`)
Already includes:
- `firebase_core: ^2.32.0`
- `firebase_messaging: ^14.9.0`
- `permission_handler: ^11.3.0`

---

## Codemagic Configuration Checklist

When configuring in Codemagic Editor, ensure:

### 1. **iOS Code Signing**
- [ ] Add iOS Distribution Certificate
- [ ] Add Provisioning Profile (App Store profile)
- [ ] Enable "Automatic code signing" or configure manual signing

### 2. **App Store Connect API Key**
- [ ] Add App Store Connect API key for TestFlight upload
- [ ] Ensure the key has "App Manager" or "Developer" role

### 3. **Build Configuration**
- [ ] Set build mode to `release`
- [ ] Set iOS version target (minimum iOS 12.0 recommended)
- [ ] Enable "Build for iOS"

### 4. **Push Notification Certificates**
- [ ] Ensure APNs certificates are configured in Firebase Console
- [ ] Upload APNs Auth Key or Certificate to Firebase
- [ ] Update `GoogleService-Info.plist` if needed

### 5. **Capabilities in Apple Developer Portal**
Ensure the following capabilities are enabled for your App ID:
- [ ] Push Notifications
- [ ] Associated Domains
- [ ] NFC Tag Reading
- [ ] Background Modes (Remote notifications)

### 6. **TestFlight Upload Settings**
- [ ] Enable "Publish to App Store Connect"
- [ ] Set "Submit to TestFlight" option
- [ ] Configure build versioning (auto-increment recommended)

### 7. **Environment Variables** (if needed)
- [ ] `FIREBASE_TOKEN` (if using Firebase CLI)
- [ ] Any custom API keys or secrets

---

## Important Notes

1. **aps-environment**: Currently set to `development` in entitlements. Codemagic will automatically switch this to `production` when building for release/TestFlight.

2. **GoogleService-Info.plist**: Already present in `ios/Runner/`. Ensure it matches your Firebase project.

3. **Bundle Identifier**: Make sure it matches across:
   - Xcode project settings
   - Apple Developer Portal App ID
   - Firebase project
   - Codemagic configuration

4. **Version & Build Number**: Currently at `1.4.0+15`. Codemagic can auto-increment build numbers.

5. **Associated Domains**: Update `applinks:example.com` in both Info.plist and entitlements to your actual domain.

---

## Testing Before Upload

Before uploading to TestFlight, test locally:

```bash
# Clean build
flutter clean
cd ios
pod install
cd ..

# Build for iOS
flutter build ios --release

# Or build IPA
flutter build ipa --release
```

---

## Post-Upload Steps

After successful TestFlight upload:

1. Go to App Store Connect
2. Navigate to TestFlight tab
3. Add test information (What to Test notes)
4. Add internal/external testers
5. Submit for Beta App Review (for external testing)

---

## Troubleshooting

**If push notifications don't work:**
- Verify APNs certificate in Firebase Console
- Check `aps-environment` is set to `production` in final build
- Ensure device has granted notification permissions

**If NFC doesn't work:**
- Verify NFC capability is enabled in App ID
- Check device supports NFC (iPhone 7 and later)

**If build fails on Codemagic:**
- Check code signing configuration
- Verify all certificates are valid and not expired
- Check Xcode version compatibility
