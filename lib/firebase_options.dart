// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAjP2FONoRbVB3-9qp0f6RVDNYJS_at5Vk',
    appId: '1:858373766179:web:7ea9759e24887d70288596',
    messagingSenderId: '858373766179',
    projectId: 'flutter-sy',
    authDomain: 'flutter-sy.firebaseapp.com',
    storageBucket: 'flutter-sy.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAc_aZt8aSrigAOXh7HyMVSHp3CUUmeqJ0',
    appId: '1:858373766179:android:bd3b8a9531eb91f3288596',
    messagingSenderId: '858373766179',
    projectId: 'flutter-sy',
    storageBucket: 'flutter-sy.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAirOjuFiqimmkYiOL3quNqgKeLhfCaVlI',
    appId: '1:858373766179:ios:8179722a5175da6d288596',
    messagingSenderId: '858373766179',
    projectId: 'flutter-sy',
    storageBucket: 'flutter-sy.appspot.com',
    androidClientId:
        '858373766179-tbnvdvklttjo454l652l02qd7hh60ska.apps.googleusercontent.com',
    iosClientId:
        '858373766179-tsgkurg7tv2l45g682pktj4cnj6g9mug.apps.googleusercontent.com',
    iosBundleId: 'com.shokhrukhbek.nilu',
  );
}