# Firebase Setup Guide for NUANCE Clothing Brand Mobile App

This Flutter mobile app is built with a **Dual-Mode Data Architecture**:
1. **Local Luxury Seed Mode (Active by default)**: Allows you to immediately run and test the app without needing any Firebase keys or configuration upfront.
2. **Cloud Firestore & Firebase Auth Mode**: Automatically active once you link your Firebase project via the FlutterFire CLI.


## 1. Quick Setup with FlutterFire CLI

The recommended and fastest way to configure Firebase is using the official `flutterfire_cli`:

### Step 1: Install Firebase CLI (if not already installed)
```bash
npm install -g firebase-tools
```

### Step 2: Log into your Google account
```bash
firebase login
```

### Step 3: Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### Step 4: Run configuration inside this project
```bash
flutterfire configure
```
This command will prompt you to select an existing Firebase project (or create a new one) and will automatically generate the real `lib/firebase_options.dart` and download platform credentials (`google-services.json` for Android and `GoogleService-Info.plist` for iOS/macOS).

---

## 2. Enable Firebase Services in Firebase Console

Open the [Firebase Console](https://console.firebase.google.com):

### A. Authentication
1. Go to **Authentication** > **Sign-in method**.
2. Enable **Email/Password**.
3. Enable **Anonymous** (for guest explorers).

### B. Cloud Firestore
1. Go to **Firestore Database** > **Create database**.
2. Select your preferred server location.
3. Start in **Test mode** (or apply the Security Rules below).

---

## 3. Cloud Firestore Collections & Data Schema

The app is pre-architected with the following collections:

### 1. `products`
| Field | Type | Description |
|---|---|---|
| `id` | string | Unique product ID (e.g. `prod_001`) |
| `name` | string | Product title (e.g. `Nuance Editorial Double-Breasted Suit`) |
| `brand` | string | Brand name (`NUANCE`) |
| `category` | string | Category (`Outerwear`, `Tailored Suits`, `Linen & Resort`, etc.) |
| `description` | string | Garment story, materials, and care details |
| `price` | number | Current retail price in LKR |
| `originalPrice` | number (optional) | Original price before discount |
| `images` | array<string> | Image URLs or local asset paths |
| `sizes` | array<string> | Available sizes (`['XS', 'S', 'M', 'L', 'XL']`) |
| `colors` | array<map> | Color names and hex values (`[{name: "Black", colorValue: 4279901460}]`) |
| `rating` | number | Average review rating (e.g. `4.9`) |
| `reviewsCount` | number | Total customer reviews |
| `isFeatured` | boolean | Appears in Curated Essentials on Home |
| `isNew` | boolean | New Arrivals badge indicator |
| `inStock` | boolean | Stock availability flag |

### 2. `categories`
| Field | Type | Description |
|---|---|---|
| `id` | string | Unique category ID |
| `name` | string | Category display name |
| `itemCount` | number | Number of available apparel pieces |

### 3. `orders`
| Field | Type | Description |
|---|---|---|
| `id` | string | Order reference number (e.g. `ORD-8921`) |
| `userId` | string | Customer UID from Firebase Auth |
| `items` | array<map> | Array of ordered items with selected size and color |
| `subtotal` | number | Items price subtotal |
| `shippingFee` | number | Shipping fee ($0 if order > $250) |
| `discount` | number | Applied voucher deduction |
| `totalAmount` | number | Final total paid |
| `shippingAddress` | string | Customer destination address |
| `paymentMethod` | string | Chosen payment method (`Apple Pay`, `Credit Card`, `Cash on Delivery`) |
| `status` | string | `placed`, `processing`, `shipped`, `delivered` |
| `createdAt` | timestamp / string | Order timestamp |

---

## 4. One-Click Database Seeding

Once connected to your Firebase project, open the app, go to **Profile > Firebase Integration Guide**, and tap **SEED FIRESTORE DATA**. The app will batch-upload the complete luxury clothing catalog into your Firestore database!

---

## 5. Recommended Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Anyone can view products and categories
    match /products/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    match /categories/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    // Users can read and write their own orders
    match /orders/{orderId} {
      allow create: if true;
      allow read, update: if request.auth != null;
    }
  }
}
```
