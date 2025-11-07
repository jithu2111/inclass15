# Inventory Management App

A Flutter-based inventory management application with Firebase integration for real-time data synchronization and user authentication.

## Project Overview

This application allows users to manage inventory items with full CRUD (Create, Read, Update, Delete) operations. The app features role-based access control and advanced search/filtering capabilities.

## Features

### Core Functionality
- **CRUD Operations**: Create, read, update, and delete inventory items
- **Real-time Synchronization**: Firebase Firestore integration for live data updates
- **Item Management**: Track item name, quantity, price, and category
- **Responsive UI**: Clean Material Design interface with proper state management

### Enhanced Features (2 Implemented)

#### 1. Role-Based UI & Access Control
Implements a comprehensive role-based authentication system with differentiated access levels:

**User Roles:**
- **Admin**: Full access to all CRUD operations
  - Login: `admin@inventory.com`
  - Password: `admin123`
  - Permissions: Create, Edit, Delete items

- **Viewer**: Read-only access
  - Any user who signs up gets Viewer role
  - Permissions: View items only (no create/edit/delete)

**Implementation Details:**
- Firebase Authentication for user management
- Firestore for storing user profiles and roles
- Role-based UI rendering (FloatingActionButton and edit access hidden for viewers)
- Secure login/signup screens with form validation
- Display name shown in AppBar for personalization

**Files:**
- `lib/models/user_role.dart` - UserRole enum with permission extensions
- `lib/services/auth_service.dart` - Authentication logic
- `lib/services/user_service.dart` - User profile management
- `lib/screens/login_screen.dart` - Login interface
- `lib/screens/signup_screen.dart` - User registration
- `lib/screens/inventory_home_page.dart` - Role-based UI restrictions

#### 2. Advanced Search & Filtering
Provides multiple ways to filter and search through inventory items with real-time results:

**Search Features:**
- **Text Search**: Real-time search by item name or category (case-insensitive)
- **Category Filter**: Dropdown to filter by specific categories (dynamically populated from existing items)
- **Stock Status Filter**: Filter items by availability with smart thresholds:
  - **In Stock**: Items with quantity > 10 (displayed with green chip)
  - **Low Stock**: Items with quantity between 1-10 (displayed with orange chip - needs reordering)
  - **Out of Stock**: Items with quantity = 0 (displayed with red chip - urgent attention needed)
- **Combined Filtering**: All filters work together using AND logic (search AND category AND stock status)
- **Clear Filters**: One-click button to reset all filters at once



**Filtering Examples:**
- Search "laptop" + Category "Electronics" + Stock "Low Stock" → Shows only electronics containing "laptop" with 1-10 items
- Search "" + Category "All" + Stock "Out of Stock" → Shows all items that are out of stock across all categories
- Search "food" + Category "Food" + Stock "All" → Shows all food items regardless of stock level

**UI Components:**
- Search bar with search icon and clear button (appears when typing)
- Category dropdown with category icon and dynamic list
- Stock status filter chips with color coding:
  - Green for In Stock
  - Orange for Low Stock
  - Red for Out of Stock
- "No items found" empty state with helpful message
- Clear filters button (red icon, only visible when filters are active)
- Real-time results as you type or change filters

**Files:**
- `lib/screens/inventory_home_page.dart` - Complete search and filter UI/logic (lines 340-358 for filtering logic)

## Technology Stack

- **Framework**: Flutter 3.9.0
- **Backend**: Firebase
  - Firebase Core 3.3.0
  - Cloud Firestore 5.2.1
  - Firebase Auth 5.1.4
- **State Management**: StatefulWidget with setState()
- **UI**: Material Design

## Project Structure

```
lib/
├── models/
│   ├── item.dart              # Item data model
│   └── user_role.dart         # UserRole enum
├── services/
│   ├── auth_service.dart      # Authentication logic
│   ├── firestore_service.dart # Firestore CRUD operations
│   └── user_service.dart      # User profile management
├── screens/
│   ├── login_screen.dart      # Login UI
│   ├── signup_screen.dart     # Registration UI
│   ├── inventory_home_page.dart  # Main inventory list
│   └── add_edit_item_screen.dart # Add/Edit item form
└── main.dart                  # App entry point
```

## Setup Instructions

1. **Prerequisites:**
   - Flutter SDK (3.9.0 or higher)
   - Firebase project with Firestore and Authentication enabled
   - Android Studio / VS Code with Flutter extensions

2. **Installation:**
   ```bash
   git clone <repository-url>
   cd inclass15
   flutter pub get
   ```

3. **Firebase Configuration:**
   - Create a Firebase project
   - Enable Email/Password authentication
   - Create Firestore database
   - Download and add configuration files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`
     - `lib/firebase_options.dart`

4. **Run the app:**
   ```bash
   flutter run
   ```

## Usage

### Admin Access
1. Launch the app
2. Use admin credentials shown on login screen
3. Full access to create, edit, and delete items

### Viewer Access
1. Click "Sign Up" on login screen
2. Enter your details to create an account
3. View-only access to inventory items

### Managing Inventory
- **Add Item**: Tap the + button (Admin only)
- **Edit Item**: Tap on any item card (Admin only)
- **Delete Item**: Open item details and tap delete (Admin only)
- **Search**: Use the search bar to find items by name/category
- **Filter**: Select category or stock status to narrow results

## Database Schema

### Items Collection (`items`)
```dart
{
  'name': String,
  'quantity': int,
  'price': double,
  'category': String,
  'createdAt': Timestamp
}
```

### Users Collection (`users`)
```dart
{
  'email': String,
  'displayName': String,
  'role': String, // 'admin' or 'viewer'
  'createdAt': Timestamp
}
```
