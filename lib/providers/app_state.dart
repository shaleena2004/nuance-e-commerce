import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AppStateProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  bool isDarkTheme(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  bool get isFirebaseConnected => _firebaseService.isInitialized;
  String get firebaseStatus => _firebaseService.statusMessage;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> refreshFirebaseStatus() async {
    await _firebaseService.initialize();
    notifyListeners();
  }
}
