import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/core/user_rights.dart';

void main() {
  group('UserRights', () {
    late UserRights ur;

    setUp(() {
      ur = UserRights();
    });

    test('initial state is empty', () {
      expect(ur.role, '');
      expect(ur.rights, isEmpty);
      expect(ur.disableFeatures, isEmpty);
      expect(ur.enterprise, '');
      expect(ur.trialPeriodStart, '');
      expect(ur.trialPeriodEnd, '');
    });

    test('hasRight is case-insensitive', () {
      ur.rights = ['Get', 'Set', 'Action'];
      expect(ur.hasRight('get'), isTrue);
      expect(ur.hasRight('SET'), isTrue);
      expect(ur.hasRight('action'), isTrue);
      expect(ur.hasRight('Delete'), isFalse);
    });

    test('isFeatureDisabled is case-insensitive', () {
      ur.disableFeatures = ['FW_Update'];
      expect(ur.isFeatureDisabled('fw_update'), isTrue);
      expect(ur.isFeatureDisabled('FW_UPDATE'), isTrue);
      expect(ur.isFeatureDisabled('other'), isFalse);
    });

    test('reset clears all fields', () {
      ur.role = 'Admin';
      ur.rights = ['Get'];
      ur.disableFeatures = ['FW_Update'];
      ur.enterprise = 'Corp';
      ur.trialPeriodStart = '2026-01-01';
      ur.trialPeriodEnd = '2026-12-31';

      ur.reset();

      expect(ur.role, '');
      expect(ur.rights, isEmpty);
      expect(ur.disableFeatures, isEmpty);
      expect(ur.enterprise, '');
      expect(ur.trialPeriodStart, '');
      expect(ur.trialPeriodEnd, '');
    });
  });

  group('userRights global singleton', () {
    test('userRights is accessible and modifiable', () {
      userRights.role = 'LocalAdmin';
      userRights.rights = ['Get', 'Set'];
      expect(userRights.hasRight('get'), isTrue);

      userRights.reset();
      expect(userRights.role, '');
    });
  });
}
