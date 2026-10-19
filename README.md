# NUANCE Atelier — Luxury Clothing Brand Mobile App

A modern, high-end e-commerce mobile application built for luxury and contemporary clothing brands using **Flutter** and **Firebase**.

Designed with editorial aesthetics inspired by contemporary fashion lookbooks (warm ivory, champagne gold accents, obsidian noir), fluid micro-animations, and a robust dual-mode Firebase architecture.

---

## Key Features

- **Editorial Home Showcase**:
  - Full-width hero seasonal campaigns with high-fashion lookbook imagery.
  - Interactive category selector pills.
  - "New Arrivals" horizontal showcase with quick size/color preview.
  - Flash privilege promotion banners with discount codes.
  - "Curated Essentials" 2-column responsive product grid.

- **Catalogue & Real-Time Filtering**:
  - Instant live keyword search (jackets, suits, silk, linen, cashmere).
  - Price range slider filter (LKR 50 – LKR 600).
  - Bottom sheet sorting (Featured, Price: Low to High, Price: High to Low, Rating, Newest).
  - Category filters with item counts.

- **Product Details Atelier**:
  - Multi-image editorial gallery slider with pagination dots.
  - Interactive size selection (`XS`, `S`, `M`, `L`, `XL`, `XXL`).
  - Color swatch selector with dynamic hex color badges and check indicators.
  - Interactive Size & Measurement Guide modal.
  - Garment composition, fabric care, and sustainability notes.
  - Complimentary shipping and 30-day return policy badges.
  - Sticky bottom action bar with quantity incrementer and instant Bag addition.

- **Shopping Bag & Checkout**:
  - Variant-aware cart items (tracks selected size and color combinations).
  - Quantity controls (+ / -) with instant price recalculation.
  - Voucher / Promo code support (`NUANCE10` for 10% off, `VOGUE25` for LKR 25 off).
  - Free shipping calculation on orders above LKR 250.
  - Multi-step checkout with delivery address editing, courier service options (Standard vs. White-Glove Same-Day), and payment methods (Apple Pay, Credit Card, Cash on Delivery).
  - High-touch Order Success screen with reference number and delivery tracking date.

- **Order Tracking & Purchase History**:
  - Chronological past order list.
  - Order status badges: `ORDER PLACED`, `PROCESSING`, `SHIPPED`, `DELIVERED`.
  - Detailed product breakdown and shipping address per order.

- **Wishlist & Saved Pieces**:
  - Save favorite items with animated heart icons.
  - Persistent badge counters on navigation bar.

- **Membership & Profile**:
  - Tier Noir VIP membership badge.
  - Dark Mode / Light Mode toggle (Obsidian Noir & Alabaster Light).
  - Dual-mode database status indicator.
  - In-app interactive **Firebase Cloud Database Guide** with schema definitions.
  - Pre-configured demo login (`alex.vance@nuance-atelier.com`) & Guest mode.

---

## Technology Stack

- **Framework**: Flutter 3.47+ (Dart 3.13+)
- **State Management**: Provider (MultiProvider architecture)
- **Database & Backend**: Firebase Core, Firebase Authentication, Cloud Firestore
- **Typography**: Google Fonts (Outfit)
- **Icons**: Cupertino Icons & Material Design 3 Icons
- **Formatting & IDs**: `intl`, `uuid`

---

## Dual-Mode Firebase Architecture

The app works seamlessly in two modes:
1. **Local Luxury Seed Mode**: The app starts with a complete catalog of editorial clothing items, sizes, colors, and mock orders. No Firebase keys or login required for immediate testing.
2. **Cloud Firestore Mode**: When you connect your Firebase project, all products, orders, and authentication seamlessly stream from Google Cloud Firestore.

See [FIREBASE_SETUP.md](file:///Users/shaleenasamadhushi/Downloads/E-Commerce/FIREBASE_SETUP.md) for full setup instructions.

---

## Running the Project

### 1. Check Connected Devices
```bash
flutter devices
```

### 2. Run on Chrome (Web)
```bash
flutter run -d chrome
```

### 3. Run on macOS Desktop
```bash
flutter run -d macos
```

### 4. Run on Android / iOS Simulator
Ensure your simulator/emulator is booted, then run:
```bash
flutter run
```

### 5. Run Tests
```bash
flutter test
flutter analyze
```

---

## Voucher Codes for Testing
- `NUANCE10`: 10% off your entire bag
- `VOGUE25`: LKR 25 flat reduction

---

## Administrator Access & Credentials

The application features a unified authentication system. Entering the administrator credentials on the main **Atelier Sign In** screen automatically unlocks the enterprise **Admin Dashboard**:

| Role | Username / Email | Password | Access Level |
| :--- | :--- | :--- | :--- |
| **Administrator** | `admin@nuance.com` *(or `admin`)* | `admin123` *(or `nuance2026`)* | Full Enterprise Dashboard (Live Orders, Dispatch & Courier CRUD, Inventory & PNG Upload, Clients, Revenue) |
| **Customer** | Registered Email (e.g., `shaleena@gmail.com`) | Customer Password | Customer Boutique, Bag, Checkout, Live Tracking & Courier Contact |

### Admin Dashboard Highlights:
- **Revenue & KPIs**: Real-time gross revenue calculation directly from Cloud Firestore verified orders.
- **Dispatch & Courier Management**: Edit Courier Service Name (DHL Express, Nuance White Glove, FedEx, UPS), Courier Hotline Contact Number, and tracking IDs directly on order cards with real-time customer screen synchronization.
- **Real-Life Inventory Management with PNG Upload**: Add garments with custom SKU codes, units in stock, retail & MSRP pricing, size matrices, and direct local PNG image file upload.
- **Catalog Management (CRUD)**: Add bespoke garments, update prices and stock availability, or delete items from Cloud Firestore.
- **Client Directory**: Real-time list of registered customer accounts, customer phone numbers, and delivery addresses.
- **Quick Switcher**: Seamlessly switch between the Admin Dashboard and the Customer Boutique at any time via the boutique icon.

