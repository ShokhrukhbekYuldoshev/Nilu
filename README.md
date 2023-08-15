# Nilu

## Easily manage your sales, income and products

Nilu is a simple and easy to use application to manage your sales, income and products. It is built with [Flutter](https://flutter.dev/) and [Firebase](https://firebase.google.com/).

## Features

- Manage your sales
- Manage your income
- Manage your products
- Manage your customers
- Create and manage your own categories
- Search
- Dark mode
- Multi language support (English, Spanish, Russian, Uzbek)
- Multi currency support

## Built With

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [GetX](https://pub.dev/packages/get)

## Dependencies

- [badges](https://pub.dev/packages/badges)
- [cached_network_image](https://pub.dev/packages/cached_network_image)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [firebase_core](https://pub.dev/packages/firebase_core)
- [firebase_storage](https://pub.dev/packages/firebase_storage)
- [firebase_storage_web](https://pub.dev/packages/firebase_storage_web)
- [flutter_barcode_scanner](https://pub.dev/packages/flutter_barcode_scanner)
- [flutter_image_compress](https://pub.dev/packages/flutter_image_compress)
- [flutter_libphonenumber](https://pub.dev/packages/flutter_libphonenumber)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)
- [get](https://pub.dev/packages/get)
- [http](https://pub.dev/packages/http)
- [image_picker](https://pub.dev/packages/image_picker)
- [intl](https://pub.dev/packages/intl)
- [package_info_plus](https://pub.dev/packages/package_info_plus)
- [path_provider](https://pub.dev/packages/path_provider)
- [pattern_formatter](https://pub.dev/packages/pattern_formatter)
- [pinput](https://pub.dev/packages/pinput)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [sticky_headers](https://pub.dev/packages/sticky_headers)
- [url_launcher](https://pub.dev/packages/url_launcher)

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Firebase](https://firebase.google.com/docs/flutter/setup)

### Installation

1. Clone the repo
   ```sh
   git clone
   ```
2. Install packages

   ```sh
   flutter pub get
   ```

3. Create a new project in the [Firebase console](https://console.firebase.google.com/)

4. Create Flutter app in the Firebase console and follow the setup steps

5. Firebase console > Authentication > Sign-in method > Enable Phone sign-in method and follow the setup steps

6. Firebase console > Cloud Firestore > Create database > Start in test mode

7. Firebase console > Storage > Create bucket > Start in test mode

8. Run the app
   ```sh
   flutter run
   ```

## Note

Code is not well structured and not well documented. This is my first project with Flutter and I was just learning. Maybe I will try to improve it in the future.

## Screenshots

|        Home Screen         |     |          Products Screen           |         Sales Screen         |
| :------------------------: | :-- | :--------------------------------: | :--------------------------: |
| ![Home Screen][home-image] |     | ![Products Screen][products-image] | ![Sales Screen][sales-image] |

|          New Sale Screen           |     |          Product Info           |           Statistics Screen            |
| :--------------------------------: | :-- | :-----------------------------: | :------------------------------------: |
| ![New Sale Screen][new-sale-image] |     | ![Products][product-info-image] | ![Statistics Screen][statistics-image] |

<!-- Variables -->

[home-image]: https://user-images.githubusercontent.com/72590392/171840715-98b68954-6e46-4368-abd2-d6ebc545ae14.png
[products-image]: https://user-images.githubusercontent.com/72590392/172306854-6ff1aee8-631e-45d1-8b66-e9f1ab89cc62.png
[sales-image]: https://user-images.githubusercontent.com/72590392/171840741-852a52f2-079f-47ae-9724-cfb7fd3195b4.png
[new-sale-image]: https://user-images.githubusercontent.com/72590392/171840747-2683db9b-ce8b-4639-9cf6-6394fce31404.png
[product-info-image]: https://user-images.githubusercontent.com/72590392/171840742-62da59ba-39aa-45bd-aa65-0b2f827d7549.png
[statistics-image]: https://user-images.githubusercontent.com/72590392/171840749-9e9797a1-0bc8-424d-b106-76bbf3648bcc.png
