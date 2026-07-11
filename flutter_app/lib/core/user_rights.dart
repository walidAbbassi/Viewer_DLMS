class UserRights {
  String role = "";
  List<String> rights = [];
  List<String> disableFeatures = [];
  List<String> excludeRights = [];
  String enterprise = "";
  String trialPeriodStart = "";
  String trialPeriodEnd = "";

  bool hasRight(String right) {
    return rights.any((r) => r.toLowerCase() == right.toLowerCase());
  }

  /// Returns true if [right] is globally granted AND this [featureKey]
  /// is not explicitly excluded from that right (via ExcludeRightXml).
  bool hasRightForFeature(String right, String featureKey) {
    if (!hasRight(right)) return false;
    final target = '${featureKey.toLowerCase()}:${right.toLowerCase()}';
    return !excludeRights.any((e) => e.toLowerCase() == target);
  }

  bool isFeatureDisabled(String feature) {
    return disableFeatures.any((f) => f.toLowerCase() == feature.toLowerCase());
  }

  void reset() {
    role = "";
    rights = [];
    disableFeatures = [];
    excludeRights = [];
    enterprise = "";
    trialPeriodStart = "";
    trialPeriodEnd = "";
  }
}

// Instance globale accessible dans toute l'application
UserRights userRights = UserRights();
