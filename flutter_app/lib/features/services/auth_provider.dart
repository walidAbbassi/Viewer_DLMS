import 'package:flutter/material.dart';
import '../../grpc/authentication_client.dart';

// droits frontend
import '../../core/user_rights.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;
  bool _isLoggedIn = false;

  String _role = "";
  List<String> _rights = [];
  List<String> _disableFeatures = [];
  String _enterprise = "";
  String _trialPeriodStart = "";
  String _trialPeriodEnd = "";

  String? get username => _username;
  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  List<String> get rights => _rights;
  List<String> get disableFeatures => _disableFeatures;
  String get enterprise => _enterprise;
  String get trialPeriodStart => _trialPeriodStart;
  String get trialPeriodEnd => _trialPeriodEnd;

  bool hasRight(String right) =>
      _rights.any((r) => r.toLowerCase() == right.toLowerCase());

  bool isFeatureDisabled(String key) =>
      _disableFeatures.any((f) => f.toLowerCase() == key.toLowerCase());

  // LOGIN complet avec appel gRPC backend
  Future<String?> login(String username, String password) async {
    try {
      final client = AuthenticationClient();

      final response = await client.connexion(username, password);

      if (!response.success) return response.message;

      // Alimentation du provider
      _username = username;
      _role = response.role;
      _rights = List<String>.from(response.rights);
      _disableFeatures = List<String>.from(response.disableFeatures);
      _enterprise = response.enterprise;
      _trialPeriodStart = response.trialPeriodStart;
      _trialPeriodEnd = response.trialPeriodEnd;

      // Alimentation du userRights global utilisé dans l'IHM
      userRights.role = response.role;
      userRights.rights = List<String>.from(response.rights);
      userRights.disableFeatures = List<String>.from(response.disableFeatures);
      userRights.excludeRights = List<String>.from(response.excludeRights);
      userRights.enterprise = response.enterprise;
      userRights.trialPeriodStart = response.trialPeriodStart;
      userRights.trialPeriodEnd = response.trialPeriodEnd;

      // DEBUG — vérifier ce que le backend envoie
      print("===== LOGIN DEBUG =====");
      print("  role:            ${userRights.role}");
      print("  rights:          ${userRights.rights}");
      print("  disableFeatures: ${userRights.disableFeatures}");
      print("  excludeRights:   ${userRights.excludeRights}");
      print("  enterprise:      ${userRights.enterprise}");
      print("=======================");

      _isLoggedIn = true;
      notifyListeners();
      return null; // null = success, no error
    } catch (e) {
      print("Login ERROR: $e");
      return e.toString();
    }
  }

  // logout
  void logout() {
    _username = null;
    _isLoggedIn = false;

    _role = "";
    _rights = [];
    _disableFeatures = [];
    _enterprise = "";
    _trialPeriodStart = "";
    _trialPeriodEnd = "";

    userRights.reset();
    notifyListeners();
  }
}
