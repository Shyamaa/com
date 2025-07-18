# 🔥 Firebase Setup Guide for Ecom App

This guide will help you set up Firebase for your SwiftUI e-commerce application.

## 📋 Prerequisites

- Xcode 14.0+
- iOS 16.0+
- Apple Developer Account
- Firebase Console access

## 🚀 Step-by-Step Setup

### 1. Firebase Console Setup

1. **Go to Firebase Console**: [https://console.firebase.google.com/project/ecom-33109/overview](https://console.firebase.google.com/project/ecom-33109/overview)

2. **Enable Authentication**:
   - Go to **Authentication** → **Sign-in method**
   - Enable **Email/Password** authentication
   - Enable **Phone** authentication (for OTP)
   - Configure authorized domains

3. **Set up Firestore Database**:
   - Go to **Firestore Database**
   - Create database in **production mode**
   - Choose a location (preferably close to your users)
   - Set up security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Products can be read by all authenticated users
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Orders can be read/written by authenticated users
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

4. **Set up Storage**:
   - Go to **Storage**
   - Create storage bucket
   - Set up security rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can upload their own profile images
    match /profile_images/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Product images can be read by all users
    match /product_images/{imageId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}
```

5. **Enable Analytics**:
   - Go to **Analytics**
   - Enable Google Analytics for Firebase
   - Configure events tracking

### 2. Xcode Project Setup

#### Add Firebase Dependencies

1. **Open your Xcode project**
2. **Go to File** → **Add Package Dependencies**
3. **Add Firebase SDK**:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
4. **Select these Firebase products**:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseAnalytics

#### Update Bundle Identifier

1. **Select your project** in Xcode
2. **Go to target settings**
3. **Update Bundle Identifier** to match your `GoogleService-Info.plist`:
   ```
   Shyam.Ecom
   ```

### 3. Configuration Files

#### GoogleService-Info.plist
Your `GoogleService-Info.plist` is already configured for the `ecom-33109` project:

```xml
<key>PROJECT_ID</key>
<string>ecom-33109</string>
<key>BUNDLE_ID</key>
<string>Shyam.Ecom</string>
```

#### App Configuration
The app is already configured in `EcomApp.swift`:

```swift
@main
struct EcomApp: App {
    init() {
        FirebaseApp.configure()
        print("Firebase configured: \(FirebaseApp.app() != nil)")
    }
    // ...
}
```

### 4. Firebase Services Integration

#### Authentication
- ✅ Email/Password authentication
- ✅ Phone number verification (OTP)
- ✅ User profile management
- ✅ Secure token storage

#### Firestore Database
- ✅ User profiles storage
- ✅ Real-time data synchronization
- ✅ Offline persistence
- ✅ Security rules

#### Storage
- ✅ Profile image upload
- ✅ Product image storage
- ✅ Secure file access

#### Analytics
- ✅ User engagement tracking
- ✅ Custom events
- ✅ User properties

## 🔧 Testing Firebase Integration

### 1. Test Authentication

```swift
// Test login
let authService = AuthService.shared
do {
    let user = try await authService.authenticateAsync(username: "test@example.com", password: "password123")
    print("Login successful: \(user.username)")
} catch {
    print("Login failed: \(error.localizedDescription)")
}
```

### 2. Test Firestore

```swift
// Test user profile creation
let firebaseManager = FirebaseManager.shared
do {
    let user = User(username: "testuser", email: "test@example.com")
    try await firebaseManager.saveUserToFirestore(user)
    print("User saved to Firestore")
} catch {
    print("Failed to save user: \(error.localizedDescription)")
}
```

### 3. Test Storage

```swift
// Test image upload
do {
    let imageData = Data() // Your image data
    let imageURL = try await firebaseManager.uploadProfileImage(userId: "user123", imageData: imageData)
    print("Image uploaded: \(imageURL)")
} catch {
    print("Failed to upload image: \(error.localizedDescription)")
}
```

## 📊 Firebase Console Monitoring

### Authentication Dashboard
- Monitor user sign-ups and sign-ins
- View authentication methods usage
- Check for failed authentication attempts

### Firestore Dashboard
- Monitor database usage
- View collection and document counts
- Check query performance

### Storage Dashboard
- Monitor file uploads and downloads
- View storage usage
- Check for large files

### Analytics Dashboard
- View user engagement metrics
- Monitor custom events
- Track user properties

## 🔐 Security Best Practices

### 1. Authentication
- Use strong password policies
- Enable email verification
- Implement rate limiting
- Monitor suspicious activities

### 2. Database
- Use proper security rules
- Validate data on client and server
- Implement proper indexing
- Monitor query performance

### 3. Storage
- Validate file types and sizes
- Use secure download URLs
- Implement proper access controls
- Monitor storage usage

## 🚨 Troubleshooting

### Common Issues

1. **Firebase not configured**
   - Ensure `GoogleService-Info.plist` is in the project
   - Check that `FirebaseApp.configure()` is called

2. **Authentication errors**
   - Verify email/password authentication is enabled
   - Check authorized domains in Firebase Console

3. **Firestore permission errors**
   - Review security rules
   - Check user authentication status

4. **Storage upload failures**
   - Verify storage rules
   - Check file size limits
   - Ensure proper file format

### Debug Mode

Enable Firebase debug mode in your app:

```swift
// Add to your app initialization
#if DEBUG
FirebaseConfiguration.shared.setLoggerLevel(.debug)
#endif
```

## 📞 Support

For Firebase-specific issues:
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firebase Support](https://firebase.google.com/support)

For app-specific issues:
- Check the project README.md
- Review the code comments
- Contact MMI Softwares Pvt Ltd

## ✅ Verification Checklist

- [ ] Firebase project created and configured
- [ ] Authentication methods enabled
- [ ] Firestore database created with security rules
- [ ] Storage bucket configured
- [ ] Analytics enabled
- [ ] Dependencies added to Xcode project
- [ ] Bundle identifier matches GoogleService-Info.plist
- [ ] FirebaseApp.configure() called in app initialization
- [ ] Test authentication flow
- [ ] Test database operations
- [ ] Test storage operations
- [ ] Monitor Firebase Console for data

Your Firebase integration is now complete! 🎉 