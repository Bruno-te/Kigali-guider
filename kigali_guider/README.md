# 🏙️ Kigali Guider

A Flutter mobile app for browsing, adding, and reviewing services and places in Kigali, Rwanda. Built with Firebase Authentication, Cloud Firestore, Google Maps, and Provider state management.

---

## 📱 Features

- **Authentication** — Sign up, sign in, email verification, password reset
- **Directory Browse** — Search and filter all listings by category in real-time
- **CRUD Listings** — Create, Read, Update, Delete your own listings stored in Firestore
- **Map View** — See all listings plotted on Google Maps with tap-to-preview
- **Detail Page** — Full listing info, embedded map, ratings, reviews, and navigation
- **Reviews** — Star ratings and comments synced live from Firestore
- **Settings** — User profile, notification toggles, sign out
- **State Management** — Provider pattern; no direct Firestore calls in UI widgets

---

## 🚀 Setup Instructions

### Step 1 – Firebase Setup

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Create or open your project
3. Enable **Authentication** → Sign-in methods → **Email/Password**
4. Enable **Cloud Firestore** → Start in production mode
5. Upload `firestore.rules` via the Firestore Rules tab
6. Upload `firestore.indexes.json` via Firebase CLI: `firebase deploy --only firestore:indexes`

### Step 2 – Firebase Options (lib/firebase_options.dart)

**Option A (Recommended): Use FlutterFire CLI**
```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=YOUR_PROJECT_ID
```
This auto-generates `lib/firebase_options.dart` for all platforms.

**Option B: Manual**
Open `lib/firebase_options.dart` and fill in all `YOUR_*` placeholders with values from:
Firebase Console → Project Settings → General → Your apps

### Step 3 – Google Maps API Key

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Enable **Maps SDK for Android** and **Maps SDK for iOS**
3. Create an API key (restrict to your app's package name / bundle ID)

**Android** — In `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyBmSsdvF0xYZ8io5wReW0l6skKiT03SS-0"/>
```

**iOS** — In `ios/Runner/AppDelegate.swift`, add:
```swift
import GoogleMaps

// Inside didFinishLaunchingWithOptions:
GMSServices.provideAPIKey("AIzaSyBmSsdvF0xYZ8io5wReW0l6skKiT03SS-0")
```
Also add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Used to show nearby places</string>
```

### Step 4 – Android google-services.json

Download from Firebase Console → Project Settings → Android app → `google-services.json`
Place it at: `android/app/google-services.json`

### Step 5 – iOS GoogleService-Info.plist

Download from Firebase Console → Project Settings → iOS app → `GoogleService-Info.plist`
Place it at: `ios/Runner/GoogleService-Info.plist`

### Step 6 – Run the App

```bash
flutter pub get
flutter run
```

---

## 🗂️ Project Structure

```
lib/
├── main.dart                    # App entry, Firebase init, AuthGate
├── firebase_options.dart        # Firebase config (fill in your values)
├── theme.dart                   # Dark navy theme + AppCategories
├── models/
│   ├── listing.dart             # Listing data model
│   ├── user_profile.dart        # UserProfile data model
│   └── review.dart              # Review data model
├── services/
│   ├── auth_service.dart        # Firebase Auth + Firestore user ops
│   └── listings_service.dart    # Firestore CRUD for listings & reviews
├── providers/
│   ├── auth_provider.dart       # Auth state management (Provider)
│   └── listings_provider.dart   # Listings state management (Provider)
├── screens/
│   ├── home_screen.dart         # Bottom navigation shell
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   └── forgot_password_screen.dart
│   ├── directory/
│   │   └── directory_screen.dart  # Home: browse + search + filter
│   ├── listings/
│   │   ├── listing_detail_screen.dart  # Full info + map + reviews
│   │   ├── listing_form_screen.dart    # Create / Edit listing
│   │   └── my_listings_screen.dart     # User's own listings
│   ├── map/
│   │   └── map_view_screen.dart   # All listings on Google Maps
│   └── settings/
│       └── settings_screen.dart   # Profile + preferences
└── widgets/
    ├── listing_card.dart          # Reusable listing list item
    └── category_filter_row.dart   # Horizontal scrollable category chips
```

---

## 🔒 Firestore Security Rules Summary

- **users**: only the owner can read/write their profile
- **listings**: authenticated users can read all; only creator can update/delete
- **reviews**: authenticated users can read all; only creator can update/delete

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| firebase_auth | Authentication |
| cloud_firestore | Database + real-time sync |
| provider | State management |
| google_maps_flutter | Embedded maps |
| url_launcher | Open Maps / phone dialer |
| flutter_rating_bar | Star rating UI |
| geolocator | Device GPS |
| intl | Date formatting |

**LINK TO THE DEMO VIDEO** https://drive.google.com/file/d/1dEQ9-cb_8xGoT7aizIv0VwjGOnrt1C3q/view?usp=sharing 

