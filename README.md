# ShopSphere — Flutter E-Commerce App

ShopSphere is a Flutter e-commerce app built for the Prosessed Flutter Developer Intern assignment. It uses the required DummyJSON REST API and provides authentication, product discovery, product details, cart management, checkout confirmation, profile access, responsive layouts, light/dark themes, and automated tests.

## Submission links

- **GitHub repository:** [Mayurs26/prosessed-flutter-assignment](https://github.com/Mayurs26/prosessed-flutter-assignment)
- **Release APK:** [ShopSphere v1.0.0 — GitHub Release](https://github.com/Mayurs26/prosessed-flutter-assignment/releases/tag/v1.0.0)
- **Demo video and submission files:** [Google Drive folder](https://drive.google.com/drive/folders/19Ampv2zLSNf5DXwCKnHY9D4iiArV4Ar2?usp=sharing)

## 2. Screenshots

### Phone screenshots

| Splash | Login | Products |
|---|---|---|
| ![Splash screen](assets/screenshots/splash_screen.png) | ![Login screen on phone](assets/screenshots/login_phone.png) | ![Products screen on phone](assets/screenshots/products_phone.png) |

| Product details | Cart | Profile |
|---|---|---|
| ![Product details on phone](assets/screenshots/product_details_phone.png) | ![Cart on phone](assets/screenshots/cart_phone.png) | ![Profile on phone](assets/screenshots/profile_phone.png) |

| Checkout success | Filter |
|---|---|
| ![Checkout success](assets/screenshots/checkout_success.png) | ![Filter screen](assets/screenshots/filter.png) |

### Tablet screenshots

| Login — tablet | Products — tablet |
|---|---|
| ![Login on tablet](assets/screenshots/login_tablet.png) | ![Products on tablet](assets/screenshots/products_tablet.png) |

| Cart — tablet | Profile — tablet |
|---|---|
| ![Cart on tablet](assets/screenshots/cart_tablet.png) | ![Profile on tablet](assets/screenshots/profile_tablet.png) |

| Category filter — tablet |
|---|
| ![Category filter on tablet](assets/screenshots/category_filter_tablet.png) |

## 3. Features

### Must-have requirements

- [x] Splash and login screens.
- [x] Product listing and product details screens.
- [x] Search and category-filtering UI.
- [x] Cart and checkout-success screens.
- [x] Profile screen.
- [x] Phone and tablet layouts represented in screenshots.
- [ ] Final manual verification of splash session routing and secure access/refresh-token storage.
- [ ] Final manual verification of invalid-credentials feedback and logout/session clearing.
- [ ] Final manual verification of pagination, pull-to-refresh, API-loaded categories, debounced search, sorting, loading and empty states.
- [ ] Final manual verification of product details, quantity selection, out-of-stock handling and the `/products/9999` error state.
- [ ] Final manual verification of cart updates, totals, local persistence and cart badge.
- [ ] Final manual verification that checkout calls `POST /carts/add`, shows confirmation and clears the cart only after success.
- [ ] Final manual verification of profile data from `GET /auth/me` and expired-session handling.
- [ ] Final manual verification of friendly, recoverable network error states.

### Bonus requirements

- [x] Persistent light/dark theme toggle.
- [x] GitHub Actions CI workflow.
- [ ] Verify automatic access-token refresh and retry.
- [ ] Verify locally persisted wishlist/favourites.
- [ ] Verify offline product cache and offline banner.
- [ ] Verify widget or golden tests.
- [ ] Verify English/Hindi localization.
- [ ] Verify Hero animation between product thumbnail and details image.

Mark requirements complete only after confirming their behaviour in the final build. List any incomplete mandatory requirement before submission.

## 4. Tech stack

### SDK versions

Run `flutter --version` to record the exact Flutter and Dart versions used for final verification.

### Packages and purpose

| Package / technology | Purpose |
|---|---|
| Flutter / Dart | UI and application logic. |
| `flutter_bloc` | BLoC/Cubit state management and explicit state transitions. |
| `equatable` | Value equality for states and events. |
| `dio` | HTTP requests and network error handling. |
| `get_it` | Dependency injection. |
| `go_router` | Declarative navigation and routing. |
| `flutter_secure_storage` | Secure authentication-token storage. |
| `shared_preferences` | Lightweight local preferences, including theme persistence. |
| `cached_network_image` | Network image caching and loading support. |
| `shimmer` | Loading placeholders. |
| `intl` | Formatting utilities. |
| `bloc_test` | BLoC/Cubit state-transition tests. |
| `mocktail` | Mocking dependencies in tests. |
| DummyJSON | Required public REST API. |

Confirm package names and versions against `pubspec.yaml`.

## 5. Architecture

ShopSphere uses a feature-first structure with presentation, domain and data layers.

```text
lib/
├── core/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── routing/
│   ├── storage/
│   └── theme/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── products/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── cart/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── app.dart
└── main.dart

test/
├── core/
├── features/
└── widget_test.dart
```

### Layer responsibilities

- **Presentation:** Screens, UI components and BLoC/Cubit state handling.
- **Domain:** Entities, repository contracts and use cases where implemented.
- **Data:** API/local data sources, models and repository implementations.
- **Core:** Shared networking, dependency injection, routing, storage, theme and error handling.

### Example request flow: loading products

```text
Products screen
    ↓ user action / BLoC event
Products BLoC or Cubit
    ↓
Get-products use case (where used)
    ↓
Repository contract
    ↓
Repository implementation / remote data source
    ↓
Dio client → DummyJSON API
    ↓
JSON response → model → repository result
    ↓
BLoC/Cubit emits success, empty or failure state
    ↓
UI displays products or a recoverable state
```

## 6. State management

ShopSphere uses **`flutter_bloc` (BLoC/Cubit)** for state management. It makes loading, success, empty and failure transitions explicit and testable, and keeps asynchronous business logic out of widgets. The trade-off is additional classes and boilerplate compared with simpler local state.

## 7. Error handling

ShopSphere uses the required DummyJSON API: <https://dummyjson.com>.

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/auth/login` | Sign in and receive tokens/user data. |
| `GET` | `/auth/me` | Retrieve the signed-in user. |
| `POST` | `/auth/refresh` | Request refreshed credentials. |
| `GET` | `/products?limit=20&skip=0` | Paginated product list. |
| `GET` | `/products/search?q=phone` | Search products. |
| `GET` | `/products/categories` | Retrieve categories. |
| `GET` | `/products/category/{slug}` | Retrieve products in a category. |
| `GET` | `/products/{id}` | Retrieve product details. |
| `POST` | `/carts/add` | Simulate cart/order creation. |

The app should surface user-friendly errors rather than raw exceptions. Confirm each scenario in the running app before describing its behaviour as verified.

| Scenario | How to test | Expected behaviour |
|---|---|---|
| Server error | Request `GET /http/500` if supported by the app's test setup. | Friendly error and retry; no crash or raw stack trace. |
| Missing product | Request `GET /products/9999`. | “Product not found” state and a way back. |
| Slow network | Request `GET /products?delay=3000` if supported by the app's test setup. | Loader remains visible and timeout/error is handled. |
| Invalid login | Submit an incorrect password. | Inline invalid-credentials message. |
| Invalid/expired session | Call `/auth/me` with invalid/expired credentials. | Refresh/retry if implemented; otherwise sign out with a message. |
| Invalid refresh token | Request `POST /auth/refresh` with an invalid token. | Sign out and explain that the session expired. |
| No internet | Enable airplane mode. | Offline/error message and retry; cached content only if implemented. |

## 8. Getting started

### Prerequisites

- Flutter SDK and the bundled Dart SDK.
- Git.
- Android Studio or VS Code with Flutter tooling.
- Android emulator or Android device.

### 1. Clone the repository

```bash
git clone https://github.com/Mayurs26/prosessed-flutter-assignment.git
cd prosessed-flutter-assignment
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Check the environment and devices

```bash
flutter doctor
flutter --version
flutter devices
```

### 4. Run the app

```bash
flutter run
```

To select a particular device:

```bash
flutter run -d <device_id>
```

### 5. Analyze and format

```bash
flutter analyze
dart format --output=none --set-exit-if-changed lib test
```

### 6. Build the release APK

```bash
flutter build apk --release
```

The default output is:

```text
build/app/outputs/flutter-apk/app-release.apk
```

The submission APK is named:

```text
ShopSphere_Mayur_Sonawane_v1.0.0.apk
```

Install and smoke-test the release APK on Android 8.0 (API 26) or newer. The APK is attached to the GitHub Release tagged `v1.0.0`.

## 9. Testing

Run the full test suite:

```bash
flutter test --reporter expanded
```

Generate coverage data:

```bash
flutter test --coverage
```

Coverage output is written to `coverage/lcov.info`. Record the test count and coverage percentage from the final run; earlier results should not be treated as proof of the current build.

- **Previously recorded test result:** 147 tests passed. Re-run after final code changes to confirm.
- **Current line coverage:** Recalculate using the latest `flutter test --coverage` output.
- **Test scope:** Tests are organised across core error/network/storage handling and auth, cart and product features. Confirm the final count and coverage after running the suite.

## 10. Test credentials

Use the credentials specified by the assignment:

```text
Username: emilys
Password: emilyspass
```

DummyJSON simulates cart/order write operations; responses do not represent a real-world order saved on the server. The app must persist its own cart locally.

## 11. Assumptions & trade-offs

- **Backend:** DummyJSON is the required API; no custom backend is part of this assignment.
- **Simulated checkout:** `POST /carts/add` returns a simulated response and does not place a real merchant order.
- **State management:** BLoC/Cubit provides explicit state transitions and testability, with additional boilerplate.
- **Local persistence:** Verify cart persistence across app restarts before submission.
- **Scope honesty:** Clearly list any incomplete mandatory requirements and how they would be addressed with more time.
- **Future improvements:** Add integration tests for full user journeys, improve measured coverage, and verify accessibility/font scaling and phone/tablet layouts in portrait and landscape.

### AI tool disclosure

ChatGPT was used as an assistant during development for guidance and documentation support. The implementation and submitted code are the author's responsibility to understand and verify.

## 12. Author

**Mayur Sonawane**  
Flutter Developer | MCA Graduate

- **Email:** [mayurr.2609@gmail.com](mailto:mayurr.2609@gmail.com)
- **LinkedIn:** [mayur-sonawane](https://www.linkedin.com/in/mayur-sonawane-)
- **GitHub:** [Mayurs26](https://github.com/Mayurs26)
- **Portfolio:** [mayurportfolio-eight.vercel.app](https://mayurportfolio-eight.vercel.app)

---

Built with Flutter for the Prosessed Flutter Developer Intern assignment.
