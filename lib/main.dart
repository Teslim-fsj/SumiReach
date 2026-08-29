import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/firestore_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Auto-seed Firestore if collections are empty
    final firestoreService = FirestoreService();
    await firestoreService.seedIfEmpty();
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const SumiReachApp());
}