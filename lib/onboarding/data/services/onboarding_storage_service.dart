import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding and user data storage
class OnboardingStorageService {
  static const String _keyOnboardingComplete = 'onboarding_complete';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserPassword = 'user_password';
  static const String _keyUserName = 'user_name';
  static const String _keyUserNickname = 'user_nickname';
  static const String _keyProfileImagePath = 'profile_image_path';
  static const String _keySelectedLanguage = 'selected_language';

  final SharedPreferences _prefs;

  OnboardingStorageService(this._prefs);

  // Onboarding Status
  Future<void> setOnboardingComplete(bool value) async {
    await _prefs.setBool(_keyOnboardingComplete, value);
  }

  bool isOnboardingComplete() {
    return _prefs.getBool(_keyOnboardingComplete) ?? false;
  }

  // Login Status
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyIsLoggedIn, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // User Credentials
  Future<void> saveCredentials(String phone, String password) async {
    await _prefs.setString(_keyUserPhone, phone);
    await _prefs.setString(_keyUserPassword, password);
  }

  String? getUserPhone() {
    return _prefs.getString(_keyUserPhone);
  }

  String? getUserPassword() {
    return _prefs.getString(_keyUserPassword);
  }

  // Profile Data
  Future<void> saveProfileData({
    required String name,
    required String nickname,
    String? imagePath,
  }) async {
    await _prefs.setString(_keyUserName, name);
    await _prefs.setString(_keyUserNickname, nickname);
    if (imagePath != null) {
      await _prefs.setString(_keyProfileImagePath, imagePath);
    }
  }

  String? getUserName() {
    return _prefs.getString(_keyUserName);
  }

  String? getUserNickname() {
    return _prefs.getString(_keyUserNickname);
  }

  String? getProfileImagePath() {
    return _prefs.getString(_keyProfileImagePath);
  }

  File? getProfileImageFile() {
    final path = getProfileImagePath();
    if (path != null && path.isNotEmpty) {
      return File(path);
    }
    return null;
  }

  // Language
  Future<void> saveLanguage(String languageCode) async {
    await _prefs.setString(_keySelectedLanguage, languageCode);
  }

  String getSelectedLanguage() {
    return _prefs.getString(_keySelectedLanguage) ?? 'en';
  }

  // Clear all data (Logout)
  Future<void> clearAllData() async {
    await _prefs.clear();
  }

  // Clear only login session
  Future<void> logout() async {
    await _prefs.setBool(_keyIsLoggedIn, false);
  }
}
