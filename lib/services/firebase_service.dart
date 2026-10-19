import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isInitialized = false;
  String _statusMessage = 'Initializing Firebase...';
  String? _initError;

  bool get isInitialized => _isInitialized;
  String get statusMessage => _statusMessage;
  String? get initError => _initError;

  Future<void> initialize() async {
    try {
      if (!DefaultFirebaseOptions.isRealConfiguration) {
        _isInitialized = false;
        _statusMessage =
            'Running in Local Seed Mode. Configure Firebase for cloud synchronization.';
        debugPrint('[FirebaseService] Running in Local Seed Mode (Firebase configuration pending).');
        return;
      }

      if (Firebase.apps.isNotEmpty) {
        _isInitialized = true;
        _statusMessage = 'Firebase connected (${Firebase.app().name})';
        debugPrint('[FirebaseService] Firebase already active.');
        return;
      }

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      _isInitialized = true;
      _statusMessage = 'Connected to Firebase Cloud';
      debugPrint('[FirebaseService] Successfully connected to Firebase.');
    } catch (e) {
      _isInitialized = false;
      _initError = e.toString();
      _statusMessage =
          'Running in Local Seed Mode. Configure Firebase for cloud synchronization.';
      debugPrint('[FirebaseService] Firebase not configured yet: $e');
    }
  }
}
