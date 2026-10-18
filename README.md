# 🛍️ ShopSphere — Flutter E-Commerce App

A modern e-commerce mobile application built with **Flutter and Dart**, focused on clean architecture, predictable state management, secure authentication, and a maintainable codebase.

ShopSphere is developed as part of a Flutter Developer Internship assignment for **Prosessed.ai**. The project demonstrates practical implementation of REST API integration, authentication flows, product discovery, shopping cart management, and automated testing.

[Features](#-features) · [Tech Stack](#-tech-stack) · [Architecture](#-architecture) · [Getting Started](#-getting-started) · [Testing](#-testing)

---

## ✨ Overview

ShopSphere is designed to provide a structured e-commerce experience while following Flutter development best practices.

The application uses a feature-first project structure with separate data, domain, and presentation layers. BLoC handles application state, Dio manages HTTP requests, and dependency injection helps keep components loosely coupled and testable.

### 🎯 Project Goals

- Build a maintainable Flutter application using Clean Architecture principles.
- Integrate REST APIs for authentication and product data.
- Implement predictable state management using BLoC.
- Handle authentication tokens and API failures appropriately.
- Support shopping cart operations and local persistence.
- Write automated tests for important application behavior.

---

## 🚀 Features

### 🔐 Authentication
- Login screen with username and password fields.
- Form validation with inline error messages.
- Password visibility toggle.
- Loading and authentication state handling.
- Access-token and refresh-token handling.
- Session restoration and logout flows.

### 🛒 Product Discovery
- Product listing and product data retrieval.
- Search and category-based filtering.
- Product pagination.
- Product loading and error-state handling.

### 🧺 Shopping Cart
- Add and remove products.
- Update product quantities.
- Prevent quantities from exceeding available stock.
- Handle out-of-stock products.
- Calculate subtotal, discounts, and grand total.
- Persist cart data locally.

### 👤 Application Experience
- Material 3-based Flutter UI.
- Feature-based code organization.
- Centralized dependency injection.
- Reusable networking and error-handling components.
- Automated tests for core application logic.

> Note: Feature descriptions represent the project's intended and implemented scope. Verify individual screens, API integrations, and platform-specific behavior before treating every feature as production-ready.

---

## 🧰 Tech Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform UI development |
| Dart | Application programming language |
| flutter_bloc | State management |
| Equatable | Value equality for states and events |
| Dio | HTTP client and API integration |
| GetIt | Dependency injection |
| GoRouter | Application navigation |
| flutter_secure_storage | Secure token storage |
| SharedPreferences | Lightweight local persistence |
| cached_network_image | Network image loading and caching |
| Shimmer | Loading placeholders |
| intl | Formatting and localization utilities |
| bloc_test | BLoC testing |
| mocktail | Mocking and unit-test support |
| DummyJSON | E-commerce API and sample data |

---

## 🏗️ Architecture

ShopSphere follows a **feature-first structure with Clean Architecture-inspired layers**.

```text
lib/
├── core/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── routing/
│   ├── storage/
│   └── theme/
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── products/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── cart/
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── main.dart

test/
├── core/
├── features/
└── widget_test.dart
```

*The tree illustrates the intended organization; individual folders and files may differ in the current repository.*

### Architectural Principles

- **Separation of concerns:** UI, business logic, and data access are kept in distinct layers.
- **Feature-first organization:** Related files are grouped by application feature.
- **BLoC-based state management:** UI reacts to explicit state transitions.
- **Dependency injection:** Dependencies can be supplied and mocked for testing.
- **Centralized networking:** API communication and authentication interception are managed in shared networking components.
- **Testability:** Business logic and important user interactions can be tested independently.

---

## 🌐 API Integration

ShopSphere uses the DummyJSON API for sample e-commerce data.

**Base URL:** `https://dummyjson.com`

| Endpoint | Purpose |
|---|---|
| `POST /auth/login` | Authenticate a user |
| `GET /auth/me` | Retrieve the authenticated user |
| `POST /auth/refresh` | Refresh an access token |
| `GET /products` | Retrieve products |
| `GET /products/search?q={query}` | Search products |
| `GET /products/categories` | Retrieve product categories |
| `GET /products/category/{category}` | Retrieve products by category |
| `GET /products/{id}` | Retrieve a product by ID |
| `POST /carts/add` | Submit a cart addition request |

Full endpoint behavior and request/response handling should be verified against the current implementation and the API documentation.

API reference: [DummyJSON Documentation](https://dummyjson.com/docs)

---

## ⚙️ Getting Started

### Prerequisites

Install the following before running the application:

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- Dart SDK compatible with the project's `pubspec.yaml`
- Android Studio or VS Code
- Android emulator, physical device, or supported desktop/browser environment
- Git

### 1. Clone the Repository

```bash
git clone https://github.com/Mayurs26/prosessed-flutter-assignment.git
```

### 2. Open the Project

```bash
cd prosessed-flutter-assignment
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Check Available Devices

```bash
flutter devices
```

### 5. Run the Application

```bash
flutter run
```

To run on a specific device:

```bash
flutter run -d <device_id>
```

Replace `<device_id>` with an ID shown by `flutter devices`.

### 6. Run Static Analysis

```bash
flutter analyze
```

---

## 🧪 Testing

Automated tests cover important application behavior across authentication, products, cart operations, and app startup.

### Run the Complete Test Suite

```bash
flutter test --reporter expanded
```

### Run Authentication UI Tests

```bash
flutter test test/features/auth/presentation/pages/login_page_test.dart --reporter expanded
```

### Generate Coverage Data

```bash
flutter test --coverage
```

### Current Verified Test Results

- **48 tests passed** in the complete test suite during the latest recorded run.
- **5 login page tests passed**, covering form rendering, validation, password visibility, and trimmed credential submission.

Test results describe the recorded run and should be reproduced against the latest code before a release.

---

## 📁 Repository Structure

```text
shopsphere/
├── android/
├── assets/
├── lib/
│   ├── core/
│   ├── features/
│   └── main.dart
├── test/
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

This is a high-level overview. Refer to the repository for the exact current file structure.

---

## 🔒 Security & Error Handling

The project includes authentication-related networking and storage components.

Key areas include:

- Secure storage for authentication tokens.
- Authentication interception for API requests.
- Token refresh and request retry behavior.
- Handling missing or failed refresh credentials.
- Loading, success, and failure states in application logic.

For production deployment, additional review is required for token lifecycle management, sensitive-data handling, platform security, and API-specific error behavior.

---

## 🛣️ Future Improvements

Potential areas for further development include:

- Complete end-to-end verification of authentication and session restoration.
- Improve responsive layouts across supported screen sizes and platforms.
- Expand unit and widget test coverage.
- Add integration tests for login, product discovery, and cart workflows.
- Verify release builds and platform-specific API behavior.
- Improve accessibility and automated UI feedback.
- Add screenshots and a short application demo to the repository.

---

## 👨‍💻 Author

**Mayur Sonawane**

Flutter Developer | MCA Graduate

Interested in building maintainable mobile applications with Flutter, Dart, REST APIs, and clean architecture.

- **GitHub:** [Mayurs26](https://github.com/Mayurs26)
- **Portfolio:** [mayurportfolio-eight.vercel.app](https://mayurportfolio-eight.vercel.app)

---

## 📄 Project Context

ShopSphere is an internship assignment project created to demonstrate Flutter development skills, application architecture, REST API integration, state management, and automated testing.

This repository is intended for learning, technical evaluation, and demonstration of development practices.

---

<p align="center">
  Built with Flutter 💙
</p>
