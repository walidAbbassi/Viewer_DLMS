import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/core/theme/design_tokens.dart';

void main() {
  // ---------------------------------------------------------------------------
  // DesignTokens – Color constants
  // ---------------------------------------------------------------------------
  group('DesignTokens – Primary colors', () {
    test('primary600 has correct hex value', () {
      expect(DesignTokens.primary600, equals(const Color(0xFF1976D2)));
    });
    test('primary500 has correct hex value', () {
      expect(DesignTokens.primary500, equals(const Color(0xFF2196F3)));
    });
    test('primary100 has correct hex value', () {
      expect(DesignTokens.primary100, equals(const Color(0xFFBBDEFB)));
    });
    test('primary50 has correct hex value', () {
      expect(DesignTokens.primary50, equals(const Color(0xFFE3F2FD)));
    });
  });

  group('DesignTokens – Semantic colors', () {
    test('success is green', () {
      expect(DesignTokens.success, equals(const Color(0xFF4CAF50)));
    });
    test('successLight is semi-transparent green', () {
      expect(DesignTokens.successLight, equals(const Color(0x1A4CAF50)));
    });
    test('warning is orange', () {
      expect(DesignTokens.warning, equals(const Color(0xFFFF9800)));
    });
    test('warningLight is semi-transparent orange', () {
      expect(DesignTokens.warningLight, equals(const Color(0x1AFF9800)));
    });
    test('danger is red', () {
      expect(DesignTokens.danger, equals(const Color(0xFFF44336)));
    });
    test('dangerLight is semi-transparent red', () {
      expect(DesignTokens.dangerLight, equals(const Color(0x1AF44336)));
    });
    test('info matches primary500', () {
      expect(DesignTokens.info, equals(const Color(0xFF2196F3)));
    });
    test('infoLight is semi-transparent blue', () {
      expect(DesignTokens.infoLight, equals(const Color(0x1A2196F3)));
    });
  });

  group('DesignTokens – Gray scale', () {
    test('gray50', () => expect(DesignTokens.gray50, equals(const Color(0xFFFAFAFA))));
    test('gray100', () => expect(DesignTokens.gray100, equals(const Color(0xFFF5F5F5))));
    test('gray200', () => expect(DesignTokens.gray200, equals(const Color(0xFFEEEEEE))));
    test('gray300', () => expect(DesignTokens.gray300, equals(const Color(0xFFE0E0E0))));
    test('gray400', () => expect(DesignTokens.gray400, equals(const Color(0xFFBDBDBD))));
    test('gray600', () => expect(DesignTokens.gray600, equals(const Color(0xFF757575))));
    test('gray800', () => expect(DesignTokens.gray800, equals(const Color(0xFF424242))));
    test('gray900', () => expect(DesignTokens.gray900, equals(const Color(0xFF212121))));
  });

  group('DesignTokens – Surfaces and text', () {
    test('background color', () {
      expect(DesignTokens.background, equals(const Color(0xFFF7F9FC)));
    });
    test('surface is white', () {
      expect(DesignTokens.surface, equals(Colors.white));
    });
    test('surfaceAlt color', () {
      expect(DesignTokens.surfaceAlt, equals(const Color(0xFFF5F7FA)));
    });
    test('textPrimary color', () {
      expect(DesignTokens.textPrimary, equals(const Color(0xFF1A1A1A)));
    });
    test('textSecondary color', () {
      expect(DesignTokens.textSecondary, equals(const Color(0xFF6B7280)));
    });
    test('textDisabled color', () {
      expect(DesignTokens.textDisabled, equals(const Color(0xFF9CA3AF)));
    });
  });

  // ---------------------------------------------------------------------------
  // DesignTokens – Radii constants
  // ---------------------------------------------------------------------------
  group('DesignTokens – Radius constants', () {
    test('radiusSm is 6', () => expect(DesignTokens.radiusSm, equals(6.0)));
    test('radiusMd is 12', () => expect(DesignTokens.radiusMd, equals(12.0)));
    test('radiusLg is 16', () => expect(DesignTokens.radiusLg, equals(16.0)));
    test('radiusXl is 20', () => expect(DesignTokens.radiusXl, equals(20.0)));
  });

  group('DesignTokens – BorderRadius helpers', () {
    test('brSm matches circular(6)', () {
      expect(DesignTokens.brSm, equals(BorderRadius.circular(DesignTokens.radiusSm)));
    });
    test('brMd matches circular(12)', () {
      expect(DesignTokens.brMd, equals(BorderRadius.circular(DesignTokens.radiusMd)));
    });
    test('brLg matches circular(16)', () {
      expect(DesignTokens.brLg, equals(BorderRadius.circular(DesignTokens.radiusLg)));
    });
    test('brXl matches circular(20)', () {
      expect(DesignTokens.brXl, equals(BorderRadius.circular(DesignTokens.radiusXl)));
    });
  });

  // ---------------------------------------------------------------------------
  // DesignTokens – Shadow constants
  // ---------------------------------------------------------------------------
  group('DesignTokens – Shadows', () {
    test('shadowSm has 1 shadow', () {
      expect(DesignTokens.shadowSm.length, equals(1));
    });
    test('shadowSm blurRadius is 6', () {
      expect(DesignTokens.shadowSm[0].blurRadius, equals(6.0));
    });
    test('shadowSm offset is (0, 2)', () {
      expect(DesignTokens.shadowSm[0].offset, equals(const Offset(0, 2)));
    });
    test('shadowMd has 1 shadow', () {
      expect(DesignTokens.shadowMd.length, equals(1));
    });
    test('shadowMd blurRadius is 14', () {
      expect(DesignTokens.shadowMd[0].blurRadius, equals(14.0));
    });
    test('shadowMd offset is (0, 4)', () {
      expect(DesignTokens.shadowMd[0].offset, equals(const Offset(0, 4)));
    });
    test('shadowLg has 1 shadow', () {
      expect(DesignTokens.shadowLg.length, equals(1));
    });
    test('shadowLg blurRadius is 24', () {
      expect(DesignTokens.shadowLg[0].blurRadius, equals(24.0));
    });
    test('shadowLg offset is (0, 8)', () {
      expect(DesignTokens.shadowLg[0].offset, equals(const Offset(0, 8)));
    });
  });

  // ---------------------------------------------------------------------------
  // DesignTokens – Spacing constants
  // ---------------------------------------------------------------------------
  group('DesignTokens – Spacing scale', () {
    test('spaceXs is 4', () => expect(DesignTokens.spaceXs, equals(4.0)));
    test('spaceSm is 8', () => expect(DesignTokens.spaceSm, equals(8.0)));
    test('spaceMd is 16', () => expect(DesignTokens.spaceMd, equals(16.0)));
    test('spaceLg is 24', () => expect(DesignTokens.spaceLg, equals(24.0)));
    test('spaceXl is 32', () => expect(DesignTokens.spaceXl, equals(32.0)));
    test('space2xl is 48', () => expect(DesignTokens.space2xl, equals(48.0)));
  });

  // ---------------------------------------------------------------------------
  // DesignTokens.inputDecoration
  // ---------------------------------------------------------------------------
  group('DesignTokens.inputDecoration', () {
    test('returns InputDecoration without hint or suffix', () {
      final dec = DesignTokens.inputDecoration();
      expect(dec, isA<InputDecoration>());
      expect(dec.hintText, isNull);
      expect(dec.suffixIcon, isNull);
    });

    test('hintText is set when hint is provided', () {
      final dec = DesignTokens.inputDecoration(hint: 'Enter value');
      expect(dec.hintText, equals('Enter value'));
    });

    test('suffixIcon is set when suffix widget is provided', () {
      const icon = Icon(Icons.search);
      final dec = DesignTokens.inputDecoration(suffix: icon);
      expect(dec.suffixIcon, equals(icon));
    });

    test('filled is true', () {
      final dec = DesignTokens.inputDecoration();
      expect(dec.filled, isTrue);
    });

    test('fillColor is white (surface)', () {
      final dec = DesignTokens.inputDecoration();
      expect(dec.fillColor, equals(DesignTokens.surface));
    });

    test('contentPadding is set', () {
      final dec = DesignTokens.inputDecoration();
      expect(dec.contentPadding,
          equals(const EdgeInsets.symmetric(horizontal: 14, vertical: 12)));
    });

    test('border is OutlineInputBorder', () {
      final dec = DesignTokens.inputDecoration();
      expect(dec.border, isA<OutlineInputBorder>());
    });

    test('enabledBorder is OutlineInputBorder with gray300', () {
      final dec = DesignTokens.inputDecoration();
      final border = dec.enabledBorder as OutlineInputBorder;
      expect(border.borderSide.color, equals(DesignTokens.gray300));
      expect(border.borderSide.width, closeTo(0.9, 0.01));
    });

    test('focusedBorder is OutlineInputBorder with primary600', () {
      final dec = DesignTokens.inputDecoration();
      final border = dec.focusedBorder as OutlineInputBorder;
      expect(border.borderSide.color, equals(DesignTokens.primary600));
      expect(border.borderSide.width, closeTo(1.2, 0.01));
    });

    test('both hint and suffix can be set simultaneously', () {
      const icon = Icon(Icons.clear);
      final dec = DesignTokens.inputDecoration(hint: 'Search...', suffix: icon);
      expect(dec.hintText, equals('Search...'));
      expect(dec.suffixIcon, equals(icon));
    });
  });

  // ---------------------------------------------------------------------------
  // StatusBadge widget
  // ---------------------------------------------------------------------------
  group('StatusBadge – rendering', () {
    testWidgets('renders label text without icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(label: 'Active', color: Colors.green),
          ),
        ),
      );
      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders with icon when icon is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
                label: 'OK', color: Colors.blue, icon: Icons.check_circle),
          ),
        ),
      );
      expect(find.text('OK'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('compact=false uses default padding and font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
                label: 'Warning', color: Colors.orange, compact: false),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Warning'));
      expect(text.style?.fontSize, equals(12.0));
    });

    testWidgets('compact=true uses smaller padding and font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
                label: 'Error',
                color: Colors.red,
                icon: Icons.error,
                compact: true),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Error'));
      expect(text.style?.fontSize, equals(10.0));
      // Icon is rendered with compact size
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('no icon rendered when icon is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(label: 'None', color: Colors.grey),
          ),
        ),
      );
      // No Icon widget in tree
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('container uses color with opacity for background', (tester) async {
      const testColor = Color(0xFF4CAF50);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(label: 'Success', color: testColor),
          ),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(StatusBadge),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      // Background is color.withOpacity(.12)
      expect(decoration.color, equals(testColor.withOpacity(.12)));
    });

    testWidgets('compact icon has size 12', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
                label: 'Compact',
                color: Colors.purple,
                icon: Icons.star,
                compact: true),
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.size, equals(12.0));
    });

    testWidgets('non-compact icon has size 14', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
                label: 'Full',
                color: Colors.teal,
                icon: Icons.star,
                compact: false),
          ),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.size, equals(14.0));
    });

    testWidgets('text has correct font weight and letter spacing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(label: 'Check', color: Colors.indigo),
          ),
        ),
      );
      final text = tester.widget<Text>(find.text('Check'));
      expect(text.style?.fontWeight, equals(FontWeight.w600));
      expect(text.style?.letterSpacing, closeTo(0.4, 0.001));
    });

    testWidgets('StatusBadge can be used with DesignToken colors', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(
                label: 'Danger', color: DesignTokens.danger, icon: Icons.warning),
          ),
        ),
      );
      expect(find.text('Danger'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
  });
}
