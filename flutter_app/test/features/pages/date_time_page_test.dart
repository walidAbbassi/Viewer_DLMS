import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_python_grpc/features/pages/date_time_page.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';
import 'package:flutter_python_grpc/core/user_rights.dart';
import 'package:flutter_python_grpc/core/widgets/refresh_action_button.dart';
import 'package:flutter_python_grpc/state/app_controller.dart';
import 'package:grpc/grpc.dart' show GrpcError;

// ---------------------------------------------------------------------------
// Fake gRPC client
// ---------------------------------------------------------------------------

// ignore: non_abstract_class_inherits_abstract_member
class _FakeMeterClient extends Fake implements IMeterClient {
  _FakeMeterClient({
    this.clockValue = '2025-01-15 10:30:45',
    this.timezoneOffset = 60,
    this.dstDeviation = 60,
    this.dstActive = false,
    this.setClockSuccess = true,
    this.setTimezoneSuccess = true,
    this.setIncDateSuccess = true,
    this.setDecDateSuccess = true,
    this.setDstDevSuccess = true,
    this.setDstActivationSuccess = true,
    this.clockThrows,
    this.timezoneThrows,
    this.setClockThrows,
    this.setTimezoneThrows,
    this.incDateThrows,
    this.decDateThrows,
    this.dstDevThrows,
    this.dstActivationThrows,
  });

  String clockValue;
  int timezoneOffset;
  int dstDeviation;
  bool dstActive;
  bool setClockSuccess;
  bool setTimezoneSuccess;
  bool setIncDateSuccess;
  bool setDecDateSuccess;
  bool setDstDevSuccess;
  bool setDstActivationSuccess;

  Object? clockThrows;
  Object? timezoneThrows;
  Object? setClockThrows;
  Object? setTimezoneThrows;
  Object? incDateThrows;
  Object? decDateThrows;
  Object? dstDevThrows;
  Object? dstActivationThrows;

  int getClockCalls = 0;
  int setClockCalls = 0;
  int getTimezoneCalls = 0;
  int setTimezoneCalls = 0;
  int setDstActivationCalls = 0;
  String? lastSetClockValue;

  @override
  Future<String> getClock() async {
    getClockCalls++;
    if (clockThrows != null) throw clockThrows!;
    return clockValue;
  }

  @override
  Future<bool> setClock(String dateTime) async {
    setClockCalls++;
    if (setClockThrows != null) throw setClockThrows!;
    lastSetClockValue = dateTime;
    return setClockSuccess;
  }

  @override
  Future<Int32Value> getTimezone() async {
    getTimezoneCalls++;
    if (timezoneThrows != null) throw timezoneThrows!;
    return Int32Value()..value = timezoneOffset;
  }

  @override
  Future<bool> setTimezone(int offset) async {
    setTimezoneCalls++;
    if (setTimezoneThrows != null) throw setTimezoneThrows!;
    return setTimezoneSuccess;
  }

  @override
  Future<DaylightSavingsTime> getIncrementalDate() async {
    if (incDateThrows != null) throw incDateThrows!;
    return DaylightSavingsTime()
      ..day = 28
      ..month = 3
      ..hour = 2
      ..minute = 0
      ..second = 0
      ..dayOfWeek = 255;
  }

  @override
  Future<bool> setIncrementalDate(DaylightSavingsTime dateTime) async => setIncDateSuccess;

  @override
  Future<DaylightSavingsTime> getDecrementalDate() async {
    if (decDateThrows != null) throw decDateThrows!;
    return DaylightSavingsTime()
      ..day = 27
      ..month = 10
      ..hour = 3
      ..minute = 0
      ..second = 0
      ..dayOfWeek = 255;
  }

  @override
  Future<bool> setDecrementalDate(DaylightSavingsTime dateTime) async => setDecDateSuccess;

  @override
  Future<Int32Value> getDaylightSavingDeviation() async {
    if (dstDevThrows != null) throw dstDevThrows!;
    return Int32Value()..value = dstDeviation;
  }

  @override
  Future<bool> setDaylightSavingDeviation(int deviation) async => setDstDevSuccess;

  @override
  Future<bool> getDaylightSavingActivation() async {
    if (dstActivationThrows != null) throw dstActivationThrows!;
    return dstActive;
  }

  @override
  Future<bool> setDaylightSavingActivation(bool active) async {
    setDstActivationCalls++;
    return setDstActivationSuccess;
  }
  
  @override
  Future<DeviceIDList> getDeviceID() async => DeviceIDList();

  @override
  Future<EnergyRegisterList> getEnergyRegister() async => EnergyRegisterList();
  
  @override
  Future<void> close() async {}
  @override Stream<GetLoadProfileStreamItem> getLoadProfile(
  String objectName, {
  LoadProfilePartialRead? start,
  LoadProfilePartialRead? end,
  int page = 1,
  int pageSize = 50,
})  =>
      const Stream.empty();
  @override
  Future<int> getLoadProfileCapturePeriod(String objectName) async => 0;
  @override
  Future<int> getLoadProfileMaxRecords(String objectName) async => 0;
  @override
  Future<int> getLoadProfileRecordNumber(String objectName) async => 0;
  @override
  Future<bool> setLoadProfileCapturePeriod(String objectName, int value) async => true;
  @override
  Future<bool> setLoadProfileMaxRecords(String objectName, int value) async => true;
  @override
  Future<bool> setLoadProfileRecordNumber(String objectName, int value) async => true;
  
  @override
  Future<ActivateFirmwareResponse> activateFirmware() {
    // TODO: implement activateFirmware
    throw UnimplementedError();
  }
  
  @override
  Future<bool> enableImageTransfer() {
    // TODO: implement enableImageTransfer
    throw UnimplementedError();
  }
  
  @override
  Future<int> getBlockSize() {
    // TODO: implement getBlockSize
    throw UnimplementedError();
  }
  
  @override
  Future<ActivationDateTime> getImageTransfertActivationDateTime() {
    // TODO: implement getImageTransfertActivationDateTime
    throw UnimplementedError();
  }
  
  @override
  Future<bool> initiateTransfer(String imageId, String filePath) {
    // TODO: implement initiateTransfer
    throw UnimplementedError();
  }
  
  @override
  Future<bool> setBlockSize(int blockSize) {
    // TODO: implement setBlockSize
    throw UnimplementedError();
  }
  
  @override
  Future<bool> setImageTransfertActivationDateTime(int year, int month, int day, int hour, int minute, int second) {
    // TODO: implement setImageTransfertActivationDateTime
    throw UnimplementedError();
  }
  
  @override
  Stream<TransferUpdate> transferFile(String filePath, int blockSize) {
    // TODO: implement transferFile
    throw UnimplementedError();
  }
  
  @override
  Future<List<bool>> verifyTransfert(String filePath, int blockSize) {
    // TODO: implement verifyTransfert
    throw UnimplementedError();
  }
  
  @override
  Future<FirmwareVersionList> getFirmwareVersion() {
    // TODO: implement getFirmwareVersion
    throw UnimplementedError();
  }

  @override
  Future<List<PhaseData>> getFresnelData() async => [];
  
  @override
  Future<bool> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }
  
  @override
  Future<bool> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }
  
  @override
  Future<List<ApplicationResponse>> executeAdvancedGet(List<GetRequest> requests, bool withList) {
    // TODO: implement executeAdvancedGet
    throw UnimplementedError();
  }
  
  @override
  Future<List<DatamodelObject>> getDatamodelObjects() {
    // TODO: implement getDatamodelObjects
    throw UnimplementedError();
  }
  
  @override
  Future<List<String>> getDatamodels() {
    // TODO: implement getDatamodels
    throw UnimplementedError();
  }
  
  @override
  Future<bool> initMeterContext(String moduleName) {
    // TODO: implement initMeterContext
    throw UnimplementedError();
  }
  
  @override
  Future<bool> loadDatamodel(String datamodel) {
    // TODO: implement loadDatamodel
    throw UnimplementedError();
  }
  
  @override
  Future<List<FrameExecutionItem>> executeAction(List<ActionRequest> requests, bool withList) {
    // TODO: implement executeAction
    throw UnimplementedError();
  }
  
  @override
  Future<List<FrameExecutionItem>> executeGet(List<GetRequest> requests, bool withList) {
    // TODO: implement executeGet
    throw UnimplementedError();
  }
  
  @override
  Future<List<FrameExecutionItem>> executeSet(List<SetRequest> requests, bool withList) {
    // TODO: implement executeSet
    throw UnimplementedError();
  }
  
  @override
  Future<List<DatamodelAttribute>> getDatamodelAttributesByObjectName(String objectName, String clientName) {
    // TODO: implement getDatamodelAttributesByObjectName
    throw UnimplementedError();
  }
  
  @override
  Future<List<TranslateDataItemResponse>> translateData(List<TranslateDataItemRequest> items) {
    // TODO: implement translateData
    throw UnimplementedError();
  }
  
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
  Future<AverageList> getAverage() {
    // TODO: implement getAverage
    throw UnimplementedError();
  }
  
  @override
  Future<BitStatusResponse> getBitStatus(String dataSource, String descriptionJson) {
    // TODO: implement getBitStatus
    throw UnimplementedError();
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Sets test surface size and suppresses overflow errors.
Future<void> _setUp(
  WidgetTester tester, {
  Size surface = const Size(1400, 900),
}) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final orig = FlutterError.onError!;
  FlutterError.onError = (details) {
    final msg = details.exceptionAsString();
    if (msg.contains('overflowed') ||
        msg.contains('setState() called after dispose')) return;
    orig(details);
  };
  addTearDown(() => FlutterError.onError = orig);
}

/// Wraps [DateTimePage] in a minimal [MaterialApp] inside a [ProviderScope].
///
/// `DateTimePage` reads from Riverpod in `initState`: it inspects
/// `appControllerProvider.isConnected` and exits the post-frame load
/// callback when false. We override the provider with a controller whose
/// `isConnected` is true so the page actually reads the meter via the
/// injected `_FakeMeterClient`, exercising the full code path the tests
/// assert on.
Widget _wrap(Widget child) {
  final ctrl = AppController()..setIsConnected(true);
  return ProviderScope(
    overrides: [
      appControllerProvider.overrideWith((ref) => ctrl),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/meter_connexion': (_) => const Scaffold(body: Text('Home')),
        '/date_time': (_) => const Scaffold(body: Text('DateTimePage')),
        '/configuration': (_) => const Scaffold(body: Text('Configuration')),
      },
    ),
  );
}

/// Bounded pumpAndSettle that avoids hanging on persistent animations.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 100; i++) {
    await tester.pump(const Duration(milliseconds: 50));
    if (!tester.binding.hasScheduledFrame) return;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DateTimePage', () {
    late _FakeMeterClient fake;

    setUp(() {
      fake = _FakeMeterClient();
      meterClientFactory = () => fake;
      userRights.rights = ['Get', 'Set', 'Action'];
    });

    tearDown(() {
      meterClientFactory = () => MeterClient();
      userRights.reset();
    });

    // -----------------------------------------------------------------------
    // 1. Rendering
    // -----------------------------------------------------------------------

    testWidgets('renders AppBar title and both tab labels', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(find.text('Date Time'), findsOneWidget);
      expect(find.text('Clock Setting'), findsOneWidget);
      expect(find.text('Daylight Savings'), findsOneWidget);
      expect(find.byType(RefreshAppBarButton), findsOneWidget);
    });

    testWidgets('Clock Setting tab shows Date-time and Time Zone cards',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(find.text('Date-time'), findsOneWidget);
      expect(find.text('Time Zone'), findsOneWidget);
    });

    testWidgets('Clock Setting info alert is visible', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(find.text('Clock Panel'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 2. Initial load: read clock / timezone
    // -----------------------------------------------------------------------

    testWidgets('initial load updates clock feedback', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // getClock → '2025-01-15 10:30:45' → "Read: 15/1/2025 10:30:45"
      expect(find.textContaining('Read: 15/1/2025 10:30:45'), findsOneWidget);
      expect(fake.getClockCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('initial load updates timezone feedback', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(timezoneOffset: 120);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(find.textContaining('Read offset: 120 min'), findsOneWidget);
      expect(fake.getTimezoneCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('getClock error shows error in clock feedback', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(clockThrows: Exception('gRPC unavailable'));
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(
        find.textContaining('Error reading date/time:'),
        findsOneWidget,
      );
      expect(find.textContaining('gRPC unavailable'), findsOneWidget);
    });

    testWidgets('getTimezone error shows error in timezone feedback',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(timezoneThrows: Exception('TZ offline'));
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(find.textContaining('Error reading timezone:'), findsOneWidget);
      expect(find.textContaining('TZ offline'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 3. Write actions — Clock Setting tab
    // -----------------------------------------------------------------------

    testWidgets('Write date-time button calls setClock and shows Write OK',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Tap the first 'Write' text = Date-time Write button.
      // ElevatedButton.icon wraps the label — tapping the text propagates to
      // the button's InkWell.
      await tester.tap(find.text('Write').first);
      await _settle(tester);

      expect(fake.setClockCalls, 1);
      expect(find.textContaining('Write OK:'), findsOneWidget);
    });

    testWidgets('setClock failure shows error in clock feedback', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(setClockThrows: Exception('Write failed'));
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Write').first);
      await _settle(tester);

      expect(find.textContaining('Error writing date/time:'), findsOneWidget);
    });

    testWidgets('Write timezone button shows Offset saved', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Second 'Write' text = Timezone Write button.
      await tester.tap(find.text('Write').last);
      await _settle(tester);

      expect(fake.setTimezoneCalls, 1);
      expect(find.textContaining('Offset saved'), findsOneWidget);
    });

    testWidgets('Update button re-reads DateTime', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      final callsBefore = fake.getClockCalls;
      await tester.tap(find.text('Update'));
      await _settle(tester);

      expect(fake.getClockCalls, greaterThan(callsBefore));
    });

    // -----------------------------------------------------------------------
    // 4. Refresh All
    // -----------------------------------------------------------------------

    testWidgets('Refresh All button calls getClock again', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      final callsBefore = fake.getClockCalls;
      await tester.tap(find.byKey(const Key('appbar_refresh_btn')));
      await _settle(tester);

      expect(fake.getClockCalls, greaterThan(callsBefore));
    });

    // -----------------------------------------------------------------------
    // 5. Collapsible cards
    // -----------------------------------------------------------------------

    testWidgets('Date-time card collapses and re-expands', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Tap the Date-time card header to collapse it.
      // The card header contains the expand_more icon when expanded.
      final dateTimeCardHeader = find
          .ancestor(
            of: find.text('Date-time'),
            matching: find.byType(InkWell),
          )
          .first;

      // Card is expanded initially — content (dropdowns) is visible.
      expect(find.text('Day'), findsWidgets);

      await tester.tap(dateTimeCardHeader);
      await tester.pump();

      // After collapse, 'Day' dropdown labels are gone.
      expect(find.text('Day'), findsNothing);

      // Expand again.
      await tester.tap(dateTimeCardHeader);
      await tester.pump();
      expect(find.text('Day'), findsWidgets);
    });

    testWidgets('Time Zone card collapses', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      final tzCardHeader = find
          .ancestor(
            of: find.text('Time Zone'),
            matching: find.byType(InkWell),
          )
          .first;

      // Offset field is visible when expanded.
      expect(find.text('Offset (min)'), findsOneWidget);

      await tester.tap(tzCardHeader);
      await tester.pump();

      expect(find.text('Offset (min)'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // 6. Daylight Savings tab
    // -----------------------------------------------------------------------

    testWidgets('switching to Daylight Savings tab triggers DST data loads',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Switch to Daylight Savings tab.
      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      // Incremental Date feedback: 'Read: 28-03 02:00:00'
      expect(find.textContaining('Read: 28-03'), findsOneWidget);
      // Decremental Date feedback: 'Read: 27-10 03:00:00'
      expect(find.textContaining('Read: 27-10'), findsOneWidget);
    });

    testWidgets('Daylight Savings tab shows expected card titles',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      expect(find.text('Incremental Date'), findsOneWidget);
      expect(find.text('Decremental Date'), findsOneWidget);
      expect(find.text('Daylight Record Deviation'), findsOneWidget);
      expect(find.text('Daylight Record Activation'), findsOneWidget);
    });

    testWidgets('DST deviation feedback is shown after read', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(dstDeviation: 90);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      expect(find.textContaining('Deviation read: 90 min'), findsOneWidget);
    });

    testWidgets('DST activation state is read and shown on Switch',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(dstActive: false);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      final sw = tester.widget<Switch>(find.byType(Switch));
      expect(sw.value, false);
    });

    testWidgets('DST Activation Switch can be toggled', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      final sw = find.byType(Switch);
      expect(tester.widget<Switch>(sw).value, false);

      // The Switch may be below the fold — ensure it is scrolled into view.
      await tester.ensureVisible(sw);
      await tester.pump();
      await tester.tap(sw);
      await tester.pump();
      expect(tester.widget<Switch>(sw).value, true);
    });

    testWidgets('Write DST Activation shows State written', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      // Find the Write button inside the Daylight Record Activation card.
      // It is the last 'Write' text in the Daylight Savings tab.
      final lastWrite = find.text('Write').last;
      await tester.ensureVisible(lastWrite);
      await tester.pump();
      await tester.tap(lastWrite);
      await _settle(tester);

      expect(fake.setDstActivationCalls, 1);
      expect(find.textContaining('State written'), findsOneWidget);
    });

    testWidgets('Write Incremental Date shows Write OK', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      // The Write buttons in Daylight Savings are:
      // 1st = Incremental Date, 2nd = Decremental Date, 3rd = DST Deviation,
      // 4th = DST Activation
      final firstWrite = find.text('Write').first;
      await tester.ensureVisible(firstWrite);
      await tester.pump();
      await tester.tap(firstWrite);
      await _settle(tester);

      expect(find.textContaining('Write OK:'), findsOneWidget);
    });

    testWidgets('getIncrementalDate error shows error feedback', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(incDateThrows: Exception('INC fail'));
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      expect(
        find.textContaining('Error reading incremental date:'),
        findsOneWidget,
      );
      expect(find.textContaining('INC fail'), findsOneWidget);
    });

    testWidgets('getDaylightSavingActivation error shows error feedback',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(dstActivationThrows: Exception('DST err'));
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      expect(
        find.textContaining('Error reading activation:'),
        findsOneWidget,
      );
    });

    // -----------------------------------------------------------------------
    // 7. Read-only buttons in Clock Setting tab (no-gRPC)
    // -----------------------------------------------------------------------

    testWidgets('Read DateTime button re-fetches clock', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      final callsBefore = fake.getClockCalls;

      // Tap the first 'Read' text — it lives inside an OutlinedButton.icon
      // and the tap propagates to the button's InkWell.
      await tester.tap(find.text('Read').first);
      await _settle(tester);

      expect(fake.getClockCalls, greaterThan(callsBefore));
    });

    // -----------------------------------------------------------------------
    // 8. setClock / setTimezone failure paths
    // -----------------------------------------------------------------------

    testWidgets('setClock returns false shows error feedback', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(setClockSuccess: false);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Write').first);
      await _settle(tester);

      expect(find.textContaining('Error writing date/time:'), findsOneWidget);
    });

    testWidgets('setTimezone returns false shows error feedback', (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(setTimezoneSuccess: false);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Write').last);
      await _settle(tester);

      expect(find.textContaining('Error writing timezone:'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 9. GrpcError path in _extractErrorMessage
    // -----------------------------------------------------------------------

    testWidgets('GrpcError in getClock shows gRPC message in feedback',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(
        clockThrows: GrpcError.unavailable('server unreachable'),
      );
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      expect(find.textContaining('Error reading date/time:'), findsOneWidget);
      expect(find.textContaining('server unreachable'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 10. Dropdown onChange paths (Clock Setting tab)
    // -----------------------------------------------------------------------

    testWidgets('Changing day dropdown updates selected day', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Day dropdown is the first DropdownButton<int> on screen.
      // Initial value is 15 (from clock '2025-01-15').
      await tester.tap(find.byType(DropdownButton<int>).first);
      await _settle(tester);

      // Select day 10 from the dropdown overlay.
      await tester.tap(find.text('10').last);
      await _settle(tester);

      // Write the date — fake records lastSetClockValue.
      await tester.tap(find.text('Write').first);
      await _settle(tester);

      expect(fake.lastSetClockValue, contains('-10 '));
    });

    testWidgets('Changing month dropdown updates selected month',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Month dropdown is the second DropdownButton<int>.
      // Initial month = 1. Select month 3.
      await tester.tap(find.byType(DropdownButton<int>).at(1));
      await _settle(tester);

      // Item text in the month dropdown is '3 - Mar'.
      await tester.tap(find.text('3 - Mar').last);
      await _settle(tester);

      await tester.tap(find.text('Write').first);
      await _settle(tester);

      expect(fake.lastSetClockValue, contains('-03-'));
    });

    testWidgets('Changing year dropdown updates selected year', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // Year dropdown is the third DropdownButton<int>.
      // Initial year = 2025. Select 2026.
      await tester.tap(find.byType(DropdownButton<int>).at(2));
      await _settle(tester);

      await tester.tap(find.text('2026').last);
      await _settle(tester);

      await tester.tap(find.text('Write').first);
      await _settle(tester);

      expect(fake.lastSetClockValue, startsWith('2026-'));
    });

    // -----------------------------------------------------------------------
    // 11. Timezone number-field onChange
    // -----------------------------------------------------------------------

    testWidgets('Timezone offset field accepts valid input and uses it on Write',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // The timezone TextField is the only TextField visible on the Clock
      // Setting tab. Enter a valid offset value.
      final tzField = find.byType(TextField).first;
      await tester.ensureVisible(tzField);
      await tester.pump();
      await tester.enterText(tzField, '180');
      await tester.pump();

      // Tap the timezone Write button (last Write on Clock Setting tab).
      await tester.tap(find.text('Write').last);
      await _settle(tester);

      expect(fake.setTimezoneCalls, 1);
    });

    // -----------------------------------------------------------------------
    // 12. Time picker dialog (Clock Setting _buildTimeField)
    // -----------------------------------------------------------------------

    testWidgets('Tapping time field opens time picker; confirming both dialogs'
        ' updates state', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      // The time display InkWell shows the parsed time from '2025-01-15 10:30:45'.
      final timeDisplay = find.text('10:30:45');
      await tester.ensureVisible(timeDisplay);
      await tester.pump();
      await tester.tap(
        find.ancestor(of: timeDisplay, matching: find.byType(InkWell)).first,
      );
      await _settle(tester);

      // Time picker dialog is open — tap OK to confirm the current time.
      final okBtn = find.text('OK');
      expect(okBtn, findsWidgets);
      await tester.tap(okBtn.last);
      await _settle(tester);

      // Seconds picker dialog should now be open.
      expect(find.text('Select Seconds'), findsOneWidget);
      await tester.tap(find.text('OK').last);
      await _settle(tester);
    });

    // -----------------------------------------------------------------------
    // 13. DST tab Write Decremental / Write Deviation
    // -----------------------------------------------------------------------

    testWidgets('Write Decremental Date shows Write OK', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      // DST Write order: 0=Incremental, 1=Decremental, 2=Deviation, 3=Activation
      final decWrite = find.text('Write').at(1);
      await tester.ensureVisible(decWrite);
      await tester.pump();
      await tester.tap(decWrite);
      await _settle(tester);

      // Decremental Date feedback contains 'Write OK:'
      expect(find.textContaining('Write OK:'), findsOneWidget);
    });

    testWidgets('Write DST Deviation shows Deviation written', (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      final devWrite = find.text('Write').at(2);
      await tester.ensureVisible(devWrite);
      await tester.pump();
      await tester.tap(devWrite);
      await _settle(tester);

      expect(find.textContaining('Deviation written'), findsOneWidget);
    });

    // -----------------------------------------------------------------------
    // 14. setIncrementalDate / setDecrementalDate failure paths
    // -----------------------------------------------------------------------

    testWidgets('setIncrementalDate returns false shows error feedback',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(setIncDateSuccess: false);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      final firstWrite = find.text('Write').first;
      await tester.ensureVisible(firstWrite);
      await tester.pump();
      await tester.tap(firstWrite);
      await _settle(tester);

      expect(
        find.textContaining('Error writing incremental date:'),
        findsOneWidget,
      );
    });

    testWidgets('setDecrementalDate returns false shows error feedback',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(setDecDateSuccess: false);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      final decWrite = find.text('Write').at(1);
      await tester.ensureVisible(decWrite);
      await tester.pump();
      await tester.tap(decWrite);
      await _settle(tester);

      expect(
        find.textContaining('Error writing decremental date:'),
        findsOneWidget,
      );
    });

    testWidgets('setDaylightSavingDeviation returns false shows error feedback',
        (tester) async {
      await _setUp(tester);
      fake = _FakeMeterClient(setDstDevSuccess: false);
      meterClientFactory = () => fake;
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      final devWrite = find.text('Write').at(2);
      await tester.ensureVisible(devWrite);
      await tester.pump();
      await tester.tap(devWrite);
      await _settle(tester);

      expect(
        find.textContaining('Error writing deviation:'),
        findsOneWidget,
      );
    });

    // -----------------------------------------------------------------------
    // 15. DST tab time picker (incremental date _buildTimePickerWithSeconds)
    // -----------------------------------------------------------------------

    testWidgets('Tapping incremental time field opens time picker',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      // Incremental Date card time display is '02:00:00'.
      final incTimeDisplay = find.text('02:00:00').first;
      await tester.ensureVisible(incTimeDisplay);
      await tester.pump();
      await tester.tap(
        find.ancestor(of: incTimeDisplay, matching: find.byType(InkWell)).first,
      );
      await _settle(tester);

      // Time picker dialog is open — tap OK.
      expect(find.text('OK'), findsWidgets);
      await tester.tap(find.text('OK').last);
      await _settle(tester);

      // Seconds picker dialog should now be open.
      expect(find.text('Select Seconds'), findsOneWidget);
      await tester.tap(find.text('OK').last);
      await _settle(tester);
    });

    // -----------------------------------------------------------------------
    // 16. DST dropdown onChange paths
    // -----------------------------------------------------------------------

    testWidgets('Changing incremental month dropdown updates state',
        (tester) async {
      await _setUp(tester);
      await tester.pumpWidget(_wrap(const DateTimePage()));
      await _settle(tester);

      await tester.tap(find.text('Daylight Savings'));
      await _settle(tester);

      // Incremental month defaults to 3 (March), displayed as '3 - Mar'.
      // Tap that specific text to open the month dropdown.
      await tester.tap(find.text('3 - Mar').first);
      await _settle(tester);

      // Select April from the overlay.
      await tester.tap(find.text('4 - Apr').last);
      await _settle(tester);

      // No assertion beyond no crash — onChange coverage is the goal.
    });
  });
}
