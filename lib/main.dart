import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'app.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent uncaught Flutter framework errors from crashing the app
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('[FlutterError] ${details.exceptionAsString()}');
    };

    // Prevent uncaught asynchronous platform errors from exiting
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('[PlatformDispatcher Error] $error\n$stack');
      return true; // Return true to mark the error as handled
    };

    // Run the app UI immediately
    runApp(const SumiReachApp());

    // Non-blocking Firebase and Firestore initialization in the background
    _initializeFirebaseInBackground();
  }, (error, stack) {
    debugPrint('[Root Zone Error] $error\n$stack');
  });
}

Future<void> _initializeFirebaseInBackground() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));

    final firestoreService = FirestoreService();
    firestoreService.seedIfEmpty().ignore();
  } catch (e) {
    debugPrint('[Firebase Init Notice] Firebase running in offline/local fallback mode: $e');
  }
}