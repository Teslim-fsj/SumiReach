import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run app immediately so splash and UI display instantly
  runApp(const SumiReachApp());

  // Non-blocking Firebase and Firestore initialization in background
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 4));

    final firestoreService = FirestoreService();
    firestoreService.seedIfEmpty().ignore();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }
}