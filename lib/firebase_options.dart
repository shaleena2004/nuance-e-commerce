
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'Firebase options are not configured for this platform. '
      'Run flutterfire configure to configure Android, iOS, '
      'and desktop platforms.',
    );
  }

  static bool get isRealConfiguration {
    try {
      final options = currentPlatform;

      return options.projectId == 'nuance-e-commerce' &&
          options.apiKey.isNotEmpty &&
          options.appId.isNotEmpty &&
          !options.apiKey.contains('Placeholder') &&
          !options.apiKey.contains('Demo') &&
          !options.apiKey.contains('YOUR_API_KEY');
    } catch (_) {
      return false;
    }
  }

  // Firebase configuration for Nuance E-Commerce Web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCpJdXhNH8-BmVUeq4nCsE4O41-ffjBYIE',
    appId: '1:158872998208:web:6ec2f7a02d54dc7b3e6aa5',
    messagingSenderId: '158872998208',
    projectId: 'nuance-e-commerce',
    authDomain: 'nuance-e-commerce.firebaseapp.com',
    storageBucket: 'nuance-e-commerce.firebasestorage.app',
    measurementId: 'G-7XRD7GEZXV',
  );
}
