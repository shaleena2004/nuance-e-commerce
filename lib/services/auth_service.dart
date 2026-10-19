import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firebase_service.dart';

class AuthService {
  final FirebaseService _firebaseService = FirebaseService();

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _restoreActiveSession();
  }

  void _restoreActiveSession() {
    if (_firebaseService.isInitialized) {
      final fbUser = FirebaseAuth.instance.currentUser;
      if (fbUser != null) {
        _currentUser = UserModel(
          id: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName ?? fbUser.email?.split('@').first ?? 'Member',
          photoUrl: fbUser.photoURL ?? '',
          address: '',
        );
        _fetchUserProfile(fbUser.uid);
      } else {
        _currentUser = null;
      }
    } else {
      _currentUser = null;
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    if (!_firebaseService.isInitialized) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 6));

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _currentUser = UserModel(
          id: uid,
          email: data['email'] ?? _currentUser?.email ?? '',
          displayName: data['displayName'] ?? _currentUser?.displayName ?? 'Member',
          photoUrl: data['photoUrl'] ?? '',
          phoneNumber: data['phoneNumber'] ?? '',
          address: data['address'] ?? '',
        );
        debugPrint('[AuthService] Restored profile from Firestore for $uid');
      }
    } catch (e) {
      debugPrint('[AuthService] Error fetching user profile from Firestore: $e');
    }
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPass = password.trim();

    // 1. Enterprise Administrator Direct Authentication
    if ((cleanEmail == 'admin@nuance.com' || cleanEmail == 'admin')) {
      if (cleanPass == 'admin123' || cleanPass == 'nuance2026') {
        _currentUser = const UserModel(
          id: 'admin_nuance_master',
          email: 'admin@nuance.com',
          displayName: 'Atelier Admin',
          phoneNumber: '+1 (800) 555-0199',
          address: 'Nuance Atelier Headquarters, Fifth Avenue',
        );
        return _currentUser!;
      } else {
        throw 'Access Denied: Invalid administrator password.';
      }
    }

    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw 'Invalid email address. Please enter a valid email format.';
    }
    if (cleanPass.isEmpty) {
      throw 'Password cannot be empty.';
    }

    if (_firebaseService.isInitialized) {
      try {
        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        String displayName = fbUser.displayName ?? cleanEmail.split('@').first;
        String phoneNumber = '';
        String address = '';

        // Fetch or create user doc in Firestore
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(fbUser.uid)
              .get()
              .timeout(const Duration(seconds: 6));

          if (userDoc.exists && userDoc.data() != null) {
            final data = userDoc.data()!;
            displayName = data['displayName'] ?? displayName;
            phoneNumber = data['phoneNumber'] ?? '';
            address = data['address'] ?? '';
          } else {
            // Document doesn't exist yet, create it in Firestore
            await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
              'id': fbUser.uid,
              'email': cleanEmail,
              'displayName': displayName,
              'phoneNumber': '',
              'address': '',
              'createdAt': FieldValue.serverTimestamp(),
            }).timeout(const Duration(seconds: 6));
          }
        } catch (e) {
          debugPrint('[AuthService] Firestore sync during sign-in: $e');
        }

        _currentUser = UserModel(
          id: fbUser.uid,
          email: fbUser.email ?? cleanEmail,
          displayName: displayName,
          photoUrl: fbUser.photoURL ?? '',
          phoneNumber: phoneNumber,
          address: address,
        );
        return _currentUser!;
      } on FirebaseAuthException catch (e) {
        debugPrint('[AuthService] Firebase login error: ${e.code}');
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw 'Wrong password entered. Please check and try again.';
        } else if (e.code == 'invalid-email') {
          throw 'Invalid email address format.';
        } else if (e.code == 'user-not-found') {
          throw 'No user account found with this email.';
        } else if (e.code == 'user-disabled') {
          throw 'This user account has been disabled.';
        } else {
          throw e.message ?? 'Login failed. Please check your credentials.';
        }
      } catch (e) {
        throw 'Authentication error: $e';
      }
    } else {
      // Local fallback
      if (password.length < 6) {
        throw 'Wrong password. Password must be at least 6 characters.';
      }
      _currentUser = UserModel(
        id: 'user_${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        displayName: cleanEmail.split('@').first.toUpperCase(),
      );
      return _currentUser!;
    }
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    final cleanEmail = email.trim();
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw 'Invalid email address. Please enter a valid email format.';
    }
    if (password.length < 6) {
      throw 'Password is too weak. Please use at least 6 characters.';
    }

    if (_firebaseService.isInitialized) {
      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        final fbUser = credential.user!;
        await fbUser.updateDisplayName(name);

        final initialAddress = address ?? '';
        final initialPhone = phone ?? '';

        // SAVE SIGNUP DETAILS DIRECTLY TO FIRESTORE
        try {
          await FirebaseFirestore.instance.collection('users').doc(fbUser.uid).set({
            'id': fbUser.uid,
            'displayName': name,
            'email': cleanEmail,
            'phoneNumber': initialPhone,
            'address': initialAddress,
            'createdAt': FieldValue.serverTimestamp(),
          }).timeout(const Duration(seconds: 8));
          debugPrint('[AuthService] Saved signup details to Firestore users/${fbUser.uid}');
        } catch (e) {
          debugPrint('[AuthService] Error writing user to Firestore: $e');
        }

        _currentUser = UserModel(
          id: fbUser.uid,
          email: cleanEmail,
          displayName: name,
          phoneNumber: initialPhone,
          address: initialAddress,
        );
        return _currentUser!;
      } on FirebaseAuthException catch (e) {
        debugPrint('[AuthService] Firebase registration error: ${e.code}');
        if (e.code == 'email-already-in-use') {
          throw 'This email is already registered. Please sign in instead.';
        } else if (e.code == 'invalid-email') {
          throw 'Invalid email address format.';
        } else if (e.code == 'weak-password') {
          throw 'Password is too weak. Please use at least 6 characters.';
        } else {
          throw e.message ?? 'Registration failed. Please try again.';
        }
      } catch (e) {
        throw 'Registration error: $e';
      }
    } else {
      _currentUser = UserModel(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: cleanEmail,
        displayName: name,
        phoneNumber: phone ?? '',
        address: address ?? '',
      );
      return _currentUser!;
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(
      displayName: name,
      phoneNumber: phone,
      address: address,
    );

    if (_firebaseService.isInitialized) {
      try {
        final updateData = <String, dynamic>{
          'updatedAt': FieldValue.serverTimestamp(),
        };
        if (name != null) updateData['displayName'] = name;
        if (phone != null) updateData['phoneNumber'] = phone;
        if (address != null) updateData['address'] = address;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.id)
            .set(updateData, SetOptions(merge: true))
            .timeout(const Duration(seconds: 8));
        debugPrint('[AuthService] Updated profile & shipping details in Firestore.');
      } catch (e) {
        debugPrint('[AuthService] Error updating user in Firestore: $e');
      }
    }
  }

  Future<void> signOut() async {
    if (_firebaseService.isInitialized) {
      await FirebaseAuth.instance.signOut();
    }
    _currentUser = null;
  }
}
