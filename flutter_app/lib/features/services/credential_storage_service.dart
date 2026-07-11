import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles credential persistence for the "Remember me" feature.
/// - Username and remember-me flag are stored in [SharedPreferences].
/// - Password is stored encrypted via [FlutterSecureStorage] (Windows Credential Manager).
class CredentialStorageService {
  static const _keyRememberMe = 'remember_me';
  static const _keyUsername = 'saved_username';
  static const _keyPassword = 'saved_password';

  final FlutterSecureStorage _secureStorage;

  CredentialStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Persist the remember-me flag.
  Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRememberMe, value);
  }

  /// Read the persisted remember-me flag.
  Future<bool> isRememberMeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRememberMe) ?? false;
  }

  /// Save username and password for later pre-fill.
  Future<void> saveCredentials(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await _secureStorage.write(key: _keyPassword, value: password);
  }

  /// Load previously saved credentials, or `null` if none exist.
  Future<({String username, String password})?> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(_keyUsername);
    final password = await _secureStorage.read(key: _keyPassword);
    if (username == null || password == null) return null;
    return (username: username, password: password);
  }

  /// Remove all saved credentials and reset the remember-me flag.
  Future<void> clearCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyRememberMe);
    await _secureStorage.delete(key: _keyPassword);
  }
}
