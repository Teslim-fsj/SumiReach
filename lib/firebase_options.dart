// File generated for sumireach-prod
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBDwDZdqF1W22l5ncXcDy6DM5mtl505MEw',
    appId: '1:770770436971:web:311a872b072da8c945022e',
    messagingSenderId: '770770436971',
    projectId: 'sumireach-prod',
    authDomain: 'sumireach-prod.firebaseapp.com',
    storageBucket: 'sumireach-prod.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBDwDZdqF1W22l5ncXcDy6DM5mtl505MEw',
    appId: '1:770770436971:android:311a872b072da8c945022e',
    messagingSenderId: '770770436971',
    projectId: 'sumireach-prod',
    storageBucket: 'sumireach-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDwDZdqF1W22l5ncXcDy6DM5mtl505MEw',
    appId: '1:770770436971:ios:311a872b072da8c945022e',
    messagingSenderId: '770770436971',
    projectId: 'sumireach-prod',
    storageBucket: 'sumireach-prod.firebasestorage.app',
    iosBundleId: 'com.sumireach.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBDwDZdqF1W22l5ncXcDy6DM5mtl505MEw',
    appId: '1:770770436971:web:311a872b072da8c945022e',
    messagingSenderId: '770770436971',
    projectId: 'sumireach-prod',
    authDomain: 'sumireach-prod.firebaseapp.com',
    storageBucket: 'sumireach-prod.firebasestorage.app',
  );
}