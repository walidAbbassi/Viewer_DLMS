import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_python_grpc/core/widgets/app_bottom_toolbar.dart';
import 'package:flutter_python_grpc/core/theme/design_tokens.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pbgrpc.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

// ---------------------------------------------------------------------------
// Minimal fake IMeterClient
// ---------------------------------------------------------------------------
// ignore: non_abstract_class_inherits_abstract_member
class _FakeClient extends Fake implements IMeterClient {
  final String clockResult;
  final bool clockThrows;
  _FakeClient({this.clockResult = '2026-01-01T00:00:00', this.clockThrows = false});

  @override Future<String> getClock() async {
    if (clockThrows) throw Exception('getClock error');
    return clockResult;
  }

  @override Future<bool> setClock(String d) async => true;
  @override Future<Int32Value> getTimezone() async => Int32Value()..value = 0;
  @override Future<bool> setTimezone(int v) async => true;
  @override Future<DaylightSavingsTime> getIncrementalDate() async => DaylightSavingsTime();
  @override Future<bool> setIncrementalDate(DaylightSavingsTime d) async => true;
  @override Future<DaylightSavingsTime> getDecrementalDate() async => DaylightSavingsTime();
  @override Future<bool> setDecrementalDate(DaylightSavingsTime d) async => true;
  @override Future<Int32Value> getDaylightSavingDeviation() async => Int32Value()..value = 0;
  @override Future<bool> setDaylightSavingDeviation(int v) async => true;
  @override Future<bool> getDaylightSavingActivation() async => true;
  @override Future<bool> setDaylightSavingActivation(bool v) async => true;
  @override Future<DeviceIDList> getDeviceID() async => DeviceIDList();
  @override Future<EnergyRegisterList> getEnergyRegister() async => EnergyRegisterList();
  @override Future<void> close() async {}
 @override Stream<GetLoadProfileStreamItem> getLoadProfile(
  String objectName, {
  LoadProfilePartialRead? start,
  LoadProfilePartialRead? end,
  int page = 1,
  int pageSize = 50,
}) => const Stream.empty();
  @override Future<int> getLoadProfileMaxRecords(String o) async => 0;
  @override Future<bool> setLoadProfileMaxRecords(String o, int v) async => true;
  @override Future<int> getLoadProfileRecordNumber(String o) async => 0;
  @override Future<bool> setLoadProfileRecordNumber(String o, int v) async => true;
  @override Future<int> getLoadProfileCapturePeriod(String o) async => 0;
  @override Future<bool> setLoadProfileCapturePeriod(String o, int v) async => true;
  @override Future<FirmwareVersionList> getFirmwareVersion() => throw UnimplementedError();
  @override Future<int> getBlockSize() => throw UnimplementedError();
  @override Future<bool> setBlockSize(int v) => throw UnimplementedError();
  @override Future<bool> enableImageTransfer() => throw UnimplementedError();
  @override Future<bool> initiateTransfer(String id, String path) => throw UnimplementedError();
  @override Future<ActivationDateTime> getImageTransfertActivationDateTime() => throw UnimplementedError();
  @override Future<bool> setImageTransfertActivationDateTime(int a, int b, int c, int d, int e, int f) => throw UnimplementedError();
  @override Stream<TransferUpdate> transferFile(String path, int blockSize) => throw UnimplementedError();
  @override Future<List<bool>> verifyTransfert(String path, int blockSize) => throw UnimplementedError();
  @override Future<ActivateFirmwareResponse> activateFirmware() => throw UnimplementedError();
  @override Future<List<PhaseData>> getFresnelData() => throw UnimplementedError();
  @override Future<bool> connect() => throw UnimplementedError();
  @override Future<bool> disconnect() => throw UnimplementedError();
  @override Future<bool> initMeterContext(String m) => throw UnimplementedError();
  @override Future<bool> loadDatamodel(String d) => throw UnimplementedError();
  @override Future<List<ApplicationResponse>> executeAdvancedGet(List<GetRequest> r, bool w) => throw UnimplementedError();
  @override Future<List<DatamodelObject>> getDatamodelObjects() => throw UnimplementedError();
  @override Future<List<DatamodelAttribute>> getDatamodelAttributesByObjectName(String o, String c) => throw UnimplementedError();
  @override Future<List<FrameExecutionItem>> executeGet(List<GetRequest> r, bool w) => throw UnimplementedError();
  @override Future<List<FrameExecutionItem>> executeSet(List<SetRequest> r, bool w) => throw UnimplementedError();
  @override Future<List<FrameExecutionItem>> executeAction(List<ActionRequest> r, bool w) => throw UnimplementedError();
  @override Future<List<TranslateDataItemResponse>> translateData(List<TranslateDataItemRequest> r) => throw UnimplementedError();
  @override Future<List<String>> getDatamodels() async => [];
  
  @override
  Future<bool> exportData({required String pageId, required String type, required String data, required String folderPath, String pageType = '', String fileNameSuffix = ''}) {
    // TODO: implement exportData
    throw UnimplementedError();
  }
  
  @override
  Future<String> dlmsTranslate(String data, bool isXml) {
    // TODO: implement dlmsTranslate
    throw UnimplementedError();
  }
  
  @override
  Future<AverageList> getAverage() async => AverageList();
  @override
  Future<GetLteNetworkParametersResponse> getLteNetworkParameters() async =>
      GetLteNetworkParametersResponse();
  @override
  Future<GetLteQosResponse> getLteQos() async => GetLteQosResponse();

  @override
  Future<BitStatusResponse> getBitStatus(String dataSource, String descriptionJson) {
    // TODO: implement getBitStatus
    throw UnimplementedError();
  }
}

// Client that blocks getClock until a Completer resolves
class _SlowClient extends _FakeClient {
  final Completer<String> _completer;
  _SlowClient(this._completer);
  @override
  Future<String> getClock() => _completer.future;
}

// ---------------------------------------------------------------------------
// Helper – injects a fake client via the global factory
// ---------------------------------------------------------------------------
void _injectClient(_FakeClient client) {
  meterClientFactory = () => client;
  addTearDown(() { meterClientFactory = () => MeterClient(); });
}

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------
Widget _buildToolbar({
  Future<void> Function()? onDisconnect,
  bool isConnected = false,
  Map<String, WidgetBuilder>? extraRoutes,
}) {
  return MaterialApp(
    routes: {
      '/': (_) => Scaffold(
            body: AppBottomToolbar(
              onDisconnect: onDisconnect,
              isConnected: isConnected,
            ),
          ),
      '/configuration': (_) => const Scaffold(body: Text('Configuration')),
      ...?extraRoutes,
    },
    initialRoute: '/',
  );
}

void main() {
  // suppress RenderFlex overflows from test viewports
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('RenderFlex overflowed')) return;
    FlutterError.dumpErrorToConsole(details);
  };

  // ---------------------------------------------------------------------------
  // Rendering basics
  // ---------------------------------------------------------------------------
  group('AppBottomToolbar – rendering', () {
    testWidgets('renders all 5 toolbar buttons', (tester) async {
      await tester.pumpWidget(_buildToolbar());
      expect(find.text('Date/Time'), findsOneWidget);
      expect(find.text('Super Manual'), findsOneWidget);
      expect(find.text('Manual DLMS'), findsOneWidget);
      expect(find.text('Configuration'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);
    });

    testWidgets('container renders with height 64', (tester) async {
      await tester.pumpWidget(_buildToolbar());
      final size = tester.getSize(find.byType(AppBottomToolbar));
      expect(size.height, equals(64.0));
    });

    testWidgets('toolbar renders inside Scaffold without crash', (tester) async {
      await tester.pumpWidget(_buildToolbar());
      expect(find.byType(AppBottomToolbar), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // _ToolbarButton – enabled / disabled / loading states
  // ---------------------------------------------------------------------------
  group('_ToolbarButton – states', () {
    testWidgets('Disconnect button disabled when isConnected=false', (tester) async {
      await tester.pumpWidget(_buildToolbar(
        isConnected: false,
        onDisconnect: () async {},
      ));
      // Icon should be gray when disabled
      final disconnectIcon = tester.widget<Icon>(
        find.descendant(
          of: find.widgetWithText(InkWell, 'Disconnect').first,
          matching: find.byIcon(Icons.power_settings_new),
        ),
      );
      expect(disconnectIcon.color, equals(DesignTokens.gray400));
    });

    testWidgets('Disconnect button disabled when onDisconnect=null', (tester) async {
      await tester.pumpWidget(_buildToolbar(isConnected: true));
      final disconnectIcon = tester.widget<Icon>(
        find.byIcon(Icons.power_settings_new),
      );
      expect(disconnectIcon.color, equals(DesignTokens.gray400));
    });

    testWidgets('Disconnect button enabled when isConnected=true and onDisconnect provided',
        (tester) async {
      await tester.pumpWidget(_buildToolbar(
        isConnected: true,
        onDisconnect: () async {},
      ));
      final disconnectIcon = tester.widget<Icon>(find.byIcon(Icons.power_settings_new));
      expect(disconnectIcon.color, equals(DesignTokens.primary600));
    });

    testWidgets('Date/Time, Configuration and Logs icons are always enabled (primary600)',
        (tester) async {
      await tester.pumpWidget(_buildToolbar());
      expect(
        tester.widget<Icon>(find.byIcon(Icons.access_time)).color,
        equals(DesignTokens.primary600),
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.settings_outlined)).color,
        equals(DesignTokens.primary600),
      );
      expect(
        tester.widget<Icon>(find.byIcon(Icons.terminal)).color,
        equals(DesignTokens.primary600),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------
  group('AppBottomToolbar – navigation', () {
    testWidgets('tapping Configuration navigates to /configuration', (tester) async {
      await tester.pumpWidget(_buildToolbar());
      await tester.tap(find.text('Configuration'));
      await tester.pumpAndSettle();
      expect(find.text('Configuration'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Date/Time button (_onGetMeterTime)
  // ---------------------------------------------------------------------------
  group('AppBottomToolbar – Date/Time (_onGetMeterTime)', () {
    testWidgets('tapping Date/Time shows loading SnackBar first', (tester) async {
      // Use a Completer so getClock never resolves → loading SnackBar stays visible
      final completer = Completer<String>();
      final slow = _SlowClient(completer);
      meterClientFactory = () => slow;
      addTearDown(() { meterClientFactory = () => MeterClient(); });

      await tester.pumpWidget(_buildToolbar());
      await tester.tap(find.text('Date/Time'));
      await tester.pump(); // flush tap + showSnackBar
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Reading clock from meter...'), findsOneWidget);

      // Unblock so the widget doesn't leak
      completer.completeError(Exception('abort'));
      await tester.pumpAndSettle();
    });

    testWidgets('getClock throws → shows error SnackBar', (tester) async {
      _injectClient(_FakeClient(clockThrows: true));
      await tester.pumpWidget(_buildToolbar());

      await tester.tap(find.text('Date/Time'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Failed to read meter clock'), findsOneWidget);
    });

    testWidgets('getClock succeeds → shows Meter Clock SnackBar', (tester) async {
      _injectClient(_FakeClient(clockResult: '2026-02-25T12:00:00'));
      await tester.pumpWidget(_buildToolbar());

      await tester.tap(find.text('Date/Time'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Meter Clock: 2026-02-25T12:00:00'), findsOneWidget);
    });
  });

  // ---------------------------------------------------------------------------
  // Disconnect button (_onDisconnect)
  // ---------------------------------------------------------------------------
  group('AppBottomToolbar – Disconnect (_onDisconnect)', () {
    testWidgets('tapping Disconnect when disabled does nothing', (tester) async {
      await tester.pumpWidget(_buildToolbar(isConnected: false));
      await tester.tap(find.text('Disconnect'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('tapping Disconnect calls onDisconnect and shows success SnackBar',
        (tester) async {
      bool called = false;
      await tester.pumpWidget(_buildToolbar(
        isConnected: true,
        onDisconnect: () async { called = true; },
      ));

      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(find.text('Disconnected successfully'), findsOneWidget);
    });

    testWidgets('onDisconnect throws → shows error SnackBar', (tester) async {
      await tester.pumpWidget(_buildToolbar(
        isConnected: true,
        onDisconnect: () async { throw Exception('disconnect boom'); },
      ));

      await tester.tap(find.text('Disconnect'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Disconnect error'), findsOneWidget);
    });
  });
}
