import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:grpc/grpc.dart';
import 'generated/meter.pb.dart';
import 'generated/meter.pbgrpc.dart';

import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

Timestamp toTimestamp(DateTime dt) => Timestamp.fromDateTime(dt.toUtc());

/// Minimal interface for the methods used by date/time-related pages.
/// Extend as more pages are tested.
abstract class IMeterClient {
  Future<String> getClock();
  Future<bool> setClock(String dateTime);
  Future<Int32Value> getTimezone();
  Future<GetLteNetworkParametersResponse> getLteNetworkParameters();
  Future<GetLteQosResponse> getLteQos();
  Future<bool> setTimezone(int offset);
  Future<DaylightSavingsTime> getIncrementalDate();
  Future<bool> setIncrementalDate(DaylightSavingsTime dateTime);
  Future<DaylightSavingsTime> getDecrementalDate();
  Future<bool> setDecrementalDate(DaylightSavingsTime dateTime);
  Future<Int32Value> getDaylightSavingDeviation();
  Future<bool> setDaylightSavingDeviation(int deviation);
  Future<bool> getDaylightSavingActivation();
  Future<bool> setDaylightSavingActivation(bool active);
  Future<DeviceIDList> getDeviceID();
  Future<EnergyRegisterList> getEnergyRegister();
  Future<AverageList> getAverage();
  Future<void> close();
  Stream<GetLoadProfileStreamItem> getLoadProfile(
    String objectName, {
    LoadProfilePartialRead? start,
    LoadProfilePartialRead? end,
    int page = 1,
    int pageSize = 50,
  });
  Future<int> getLoadProfileMaxRecords(String objectName);
  Future<bool> setLoadProfileMaxRecords(String objectName, int value);
  Future<int> getLoadProfileRecordNumber(String objectName);
  Future<bool> setLoadProfileRecordNumber(String objectName, int value);
  Future<int> getLoadProfileCapturePeriod(String objectName);
  Future<bool> setLoadProfileCapturePeriod(String objectName, int value);

  // coverage:ignore-start
  // ---- Firmware version (default implementation for backward compatibility) ----
  Future<FirmwareVersionList> getFirmwareVersion() =>
      throw UnimplementedError('getFirmwareVersion');

  // ---- Firmware upgrade (default implementations for backward compatibility) ----
  Future<int> getBlockSize() => throw UnimplementedError('getBlockSize');
  Future<bool> setBlockSize(int blockSize) =>
      throw UnimplementedError('setBlockSize');
  Future<bool> enableImageTransfer() =>
      throw UnimplementedError('enableImageTransfer');
  Future<bool> initiateTransfer(String imageId, String filePath) =>
      throw UnimplementedError('initiateTransfer');
  Future<ActivationDateTime> getImageTransfertActivationDateTime() =>
      throw UnimplementedError('getImageTransfertActivationDateTime');
  Future<bool> setImageTransfertActivationDateTime(
          int year, int month, int day, int hour, int minute, int second) =>
      throw UnimplementedError('setImageTransfertActivationDateTime');
  Stream<TransferUpdate> transferFile(String filePath, int blockSize) =>
      throw UnimplementedError('transferFile');
  Stream<TransferUpdate> resendMissingChunks(String filePath, int blockSize) =>
      throw UnimplementedError('resendMissingChunks');
  Stream<TransferUpdate> resumeTransfer(
          String filePath, int blockSize, int startBlock) =>
      throw UnimplementedError('resumeTransfer');
  Future<List<bool>> verifyTransfert(String filePath, int blockSize) =>
      throw UnimplementedError('verifyTransfert');
  Future<ActivateFirmwareResponse> activateFirmware() =>
      throw UnimplementedError('activateFirmware');
  Future<BitStatusResponse> getBitStatus(
          String dataSource, String descriptionJson) =>
      throw UnimplementedError('getBitStatus');

  // ---- Fresnel diagram (default implementation for backward compatibility) ----
  Future<List<PhaseData>> getFresnelData() =>
      throw UnimplementedError('getFresnelData');

  // ---- Meter connection / data model (default implementations) ----
  Future<bool> connect() => throw UnimplementedError('connect');
  Future<bool> disconnect() => throw UnimplementedError('disconnect');
  Future<bool> initMeterContext(String moduleName) =>
      throw UnimplementedError('initMeterContext');
  Future<bool> loadDatamodel(String datamodel) =>
      throw UnimplementedError('loadDatamodel');
  Future<List<DatamodelObject>> getDatamodelObjects() =>
      throw UnimplementedError('getDatamodelObjects');
  Future<List<PushObjectItem>> getPushObjectList(String datasource) =>
      throw UnimplementedError('getPushObjectList');
  Future<void> setPushObjectList(
          String datasource, List<PushObjectItem> items) =>
      throw UnimplementedError('setPushObjectList');
  Future<int> getRandomisationStartInterval(String datasource) =>
      throw UnimplementedError('getRandomisationStartInterval');
  Future<void> setRandomisationStartInterval(String datasource, int value) =>
      throw UnimplementedError('setRandomisationStartInterval');
  Future<int> getNumberOfRetries(String datasource) =>
      throw UnimplementedError('getNumberOfRetries');
  Future<void> setNumberOfRetries(String datasource, int value) =>
      throw UnimplementedError('setNumberOfRetries');
  Future<({int min, int exponent, int max})> getRepetitionDelay(
          String datasource) =>
      throw UnimplementedError('getRepetitionDelay');
  Future<void> setRepetitionDelay(
          String datasource, int min, int exponent, int max) =>
      throw UnimplementedError('setRepetitionDelay');
  Future<String> getLastConfirmationDatetime(String datasource) =>
      throw UnimplementedError('getLastConfirmationDatetime');
  Future<void> setLastConfirmationDatetime(String datasource, String value) =>
      throw UnimplementedError('setLastConfirmationDatetime');
  Future<({int tcpService, String destination, int message})>
      getSendDestination(String datasource) =>
          throw UnimplementedError('getSendDestination');
  Future<void> setSendDestination(
          String datasource, int tcpService, String destination, int message) =>
      throw UnimplementedError('setSendDestination');
  Future<List<({String startTime, String endTime})>> getCommunicationWindow(
          String datasource) =>
      throw UnimplementedError('getCommunicationWindow');
  Future<void> setCommunicationWindow(
          String datasource,
          List<
                  ({
                    ({
                      int day,
                      int month,
                      int year,
                      int weekday,
                      int hour,
                      int minute,
                      int second
                    }) start,
                    ({
                      int day,
                      int month,
                      int year,
                      int weekday,
                      int hour,
                      int minute,
                      int second
                    }) end
                  })>
              windows) =>
      throw UnimplementedError('setCommunicationWindow');

  // ---- Push action / Schedule (default implementations) ----
  Future<List<String>> getExecutionTime(String datasource) =>
      throw UnimplementedError('getExecutionTime');
  Future<void> setExecutionTime(
          String datasource,
          List<
                  ({
                    int day,
                    int month,
                    int year,
                    int weekday,
                    int hour,
                    int minute,
                    int second
                  })>
              times) =>
      throw UnimplementedError('setExecutionTime');
  Future<int> getScheduleType(String datasource) =>
      throw UnimplementedError('getScheduleType');
  Future<int> getPushActionType(String datasource) =>
      throw UnimplementedError('getPushActionType');
  Future<({int scriptSelector, String scriptTable})>
      getPushActionExecutedScript(String datasource) =>
          throw UnimplementedError('getPushActionExecutedScript');
  Future<void> setPushActionExecutedScript(
          String datasource, int scriptSelector, String scriptTable) =>
      throw UnimplementedError('setPushActionExecutedScript');
  Future<GetScriptTableResponse> getScriptTable(String datasource) =>
      throw UnimplementedError('getScriptTable');
  Future<GetPushSelectiveCaptureObjectsResponse> getPushSelectiveCaptureObjects(
          String datasource) =>
      throw UnimplementedError('getPushSelectiveCaptureObjects');
  Future<GetPushRecoveryObjectsResponse> getPushRecoveryObjects(
          List<GetPushRecoveryObjectsRequestItem> items) =>
      throw UnimplementedError('getPushRecoveryObjects');
  Future<void> pushSetupPush(String datasource) =>
      throw UnimplementedError('pushSetupPush');
  Future<void> pushSetupReset(String datasource) =>
      throw UnimplementedError('pushSetupReset');
  Future<void> executeScriptTable(String datasource) =>
      throw UnimplementedError('executeScriptTable');
  Future<void> setScriptTable(String datasource, String value) =>
      throw UnimplementedError('setScriptTable');
  Future<({int selector, String scriptText})> getScriptSelector(
          String datasource) =>
      throw UnimplementedError('getScriptSelector');
  Future<void> setScriptSelector(
          String datasource, int selector, String scriptText) =>
      throw UnimplementedError('setScriptSelector');
  Future<List<ApplicationResponse>> executeAdvancedGet(
          List<GetRequest> requests, bool withList) =>
      throw UnimplementedError('executeAdvancedGet');
  Future<List<String>> getDatamodels() =>
      throw UnimplementedError('getDatamodels');

  // ---- Super Manual Tool (default implementations) ----
  Future<List<DatamodelAttribute>> getDatamodelAttributesByObjectName(
          String objectName, String clientName) =>
      throw UnimplementedError('getDatamodelAttributesByObjectName');
  Future<List<FrameExecutionItem>> executeGet(
          List<GetRequest> requests, bool withList) =>
      throw UnimplementedError('executeGet');
  Future<List<FrameExecutionItem>> executeSet(
          List<SetRequest> requests, bool withList) =>
      throw UnimplementedError('executeSet');
  Future<List<FrameExecutionItem>> executeAction(
          List<ActionRequest> requests, bool withList) =>
      throw UnimplementedError('executeAction');
  Future<List<TranslateDataItemResponse>> translateData(
          List<TranslateDataItemRequest> items) =>
      throw UnimplementedError('translateData');
  Future<String> dlmsTranslate(String data, bool isXml) =>
      throw UnimplementedError('dlmsTranslate');
  Future<bool> exportData(
          {required String pageId,
          required String type,
          required String data,
          required String folderPath,
          String pageType = '',
          String fileNameSuffix = ''}) =>
      throw UnimplementedError('exportData');

  // ---- SIM Config (P2P Setup) ----
  Future<ModemConfigResponse> getModemConfig() =>
      throw UnimplementedError('getModemConfig');
  Future<bool> setApn(String apn) => throw UnimplementedError('setApn');
  Future<bool> setPinCode(int pinCode) =>
      throw UnimplementedError('setPinCode');
  Future<bool> setPppAuth(String username, String password) =>
      throw UnimplementedError('setPppAuth');
  Future<IpAddressResponse> getIpAddress() =>
      throw UnimplementedError('getIpAddress');
  Future<bool> setIpAddress(String address, bool isIpv6) =>
      throw UnimplementedError('setIpAddress');
  Future<CellularDiagResponse> getCellularDiag() =>
      throw UnimplementedError('getCellularDiag');
  Future<bool> setCellularField(
          int attribute, String stringValue, int enumValue) =>
      throw UnimplementedError('setCellularField');
  Future<CellInfoResponse> getCellInfo() =>
      throw UnimplementedError('getCellInfo');
  Future<bool> setCellInfoEntry(int entryIndex, String value, bool isLte) =>
      throw UnimplementedError('setCellInfoEntry');
  Future<GetQosResponse> getQos() => throw UnimplementedError('getQos');
  Future<bool> setQos(QosEntry profile, int profileIndex) =>
      throw UnimplementedError('setQos');

  // ---- Mobile Network Identifier (P2P Setup) ----
  Future<MobileNetworkIdentifiersResponse> getMobileNetworkIdentifiers() =>
      throw UnimplementedError('getMobileNetworkIdentifiers');
  Future<bool> setImsi(String value) => throw UnimplementedError('setImsi');
  Future<bool> setMsisdn(String value) => throw UnimplementedError('setMsisdn');
  Future<bool> setImei(String value) => throw UnimplementedError('setImei');
  Future<bool> setIccid(String value) => throw UnimplementedError('setIccid');
  Future<ModemStatusResponse> getModemStatus() =>
      throw UnimplementedError('getModemStatus');
  Future<bool> setModemStatus(bool isActive) =>
      throw UnimplementedError('setModemStatus');
  Future<bool> restartModem() => throw UnimplementedError('restartModem');
  Future<MniRightsResponse> getMniRights() =>
      throw UnimplementedError('getMniRights');

  // ---- Modem Config (P2P Setup) ----
  Future<ModemConfigSettingsResponse> getModemConfigSettings() =>
      throw UnimplementedError('getModemConfigSettings');
  Future<bool> setCommSpeed(int speedIndex) =>
      throw UnimplementedError('setCommSpeed');
  Future<bool> setModemProfile(String profile) =>
      throw UnimplementedError('setModemProfile');
  Future<bool> setInitStrings(List<ModemInitStringEntry> entries) =>
      throw UnimplementedError('setInitStrings');
  Future<AutoConnectResponse> getAutoConnect() =>
      throw UnimplementedError('getAutoConnect');
  Future<bool> setAutoConnect(SetAutoConnectRequest req) =>
      throw UnimplementedError('setAutoConnect');
  Future<bool> modemConnect() => throw UnimplementedError('modemConnect');
  Future<AutoAnswerResponse> getAutoAnswer() =>
      throw UnimplementedError('getAutoAnswer');
  Future<bool> setAutoAnswer(SetAutoAnswerRequest req) =>
      throw UnimplementedError('setAutoAnswer');
  Future<TcpUdpSetupResponse> getTcpUdpSetup() =>
      throw UnimplementedError('getTcpUdpSetup');
  Future<bool> setTcpUdpSetup(SetTcpUdpSetupRequest req) =>
      throw UnimplementedError('setTcpUdpSetup');
  Future<String> getObjectWriteRights(int classId) =>
      throw UnimplementedError('getObjectWriteRights');
  Stream<RetryStatusUpdate> watchRetryStatus() =>
      throw UnimplementedError('watchRetryStatus');
  // coverage:ignore-end

  // ---- Activity Calendar (DLMS Class 20 + Class 11) ----
  Future<ActivityCalendarData> getActiveCalendar() =>
      throw UnimplementedError('getActiveCalendar');
  Future<ActivityCalendarData> getPassiveCalendar() =>
      throw UnimplementedError('getPassiveCalendar');

  /// Read only Day Profiles (DLMS Attr 9) from the passive calendar.
  Future<ActivityCalendarData> getPassiveDayProfiles() =>
      throw UnimplementedError('getPassiveDayProfiles');

  /// Read only Week Profiles (DLMS Attr 8) from the passive calendar.
  Future<ActivityCalendarData> getPassiveWeekProfiles() =>
      throw UnimplementedError('getPassiveWeekProfiles');

  /// Read only Season Profiles (DLMS Attr 7) from the passive calendar.
  Future<ActivityCalendarData> getPassiveSeasonProfiles() =>
      throw UnimplementedError('getPassiveSeasonProfiles');

  Future<bool> setPassiveCalendar(ActivityCalendarData data) =>
      throw UnimplementedError('setPassiveCalendar');

  /// Write only Day Profiles (DLMS Attr 9) to the passive calendar.
  Future<bool> setPassiveDayProfiles(ActivityCalendarData data) =>
      throw UnimplementedError('setPassiveDayProfiles');

  /// Write only Week Profiles (DLMS Attr 8) to the passive calendar.
  Future<bool> setPassiveWeekProfiles(ActivityCalendarData data) =>
      throw UnimplementedError('setPassiveWeekProfiles');

  /// Write Calendar Name + Season Profiles (DLMS Attrs 6+7) to the passive calendar.

  Future<bool> setPassiveSeasonProfiles(ActivityCalendarData data) =>
      throw UnimplementedError('setPassiveSeasonProfiles');
  Future<SpecialDayTable> getSpecialDays() =>
      throw UnimplementedError('getSpecialDays');
  Future<SpecialDayTable> getPassiveSpecialDays() =>
      throw UnimplementedError('getPassiveSpecialDays');
  Future<bool> setPassiveSpecialDays(SpecialDayTable table) =>
      throw UnimplementedError('setPassiveSpecialDays');
  Future<bool> activatePassiveCalendar() =>
      throw UnimplementedError('activatePassiveCalendar');
  // coverage:ignore-end

  // ---- Push Setup Server ----
  Stream<PushNotification> startPushSetupServer(
          String host, int port, String type) =>
      throw UnimplementedError('startPushSetupServer');
  Future<void> stopPushSetupServer() =>
      throw UnimplementedError('stopPushSetupServer');
  Future<void> sendTestNotification() =>
      throw UnimplementedError('sendTestNotification');

  Future<int> getPrimaryCt() => throw UnimplementedError('getPrimaryCt');
  Future<void> setPrimaryCt(int value) =>
      throw UnimplementedError('setPrimaryCt');
  Future<int> getSecondaryCt() => throw UnimplementedError('getSecondaryCt');
  Future<void> setSecondaryCt(int value) =>
      throw UnimplementedError('setSecondaryCt');
  Future<int> getPrimaryVt() => throw UnimplementedError('getPrimaryVt');
  Future<void> setPrimaryVt(int value) =>
      throw UnimplementedError('setPrimaryVt');
  Future<int> getRatioValueVt() => throw UnimplementedError('getRatioValueVt');
  Future<void> setRatioValueVt(int value) =>
      throw UnimplementedError('setRatioValueVt');

  Future<List<QualityObject>> getQualityObjects(List<String> objects) => throw UnimplementedError('getQualityObjects');
  Future<void> updateQualityObject(String datasource,double value,int scaler)=> throw UnimplementedError('updateQualityObject');
  Future<List<QualityConfigValue>> readQualityConfig(String datasource) => throw UnimplementedError('readQualityConfig');
  Future<void> WriteQualityConfig(String dataSource, List<QualityConfigValue> items,bool isStructure)=> throw UnimplementedError('readQualityConfig');

}

@visibleForTesting
IMeterClient Function() meterClientFactory = () => MeterClient();

class MeterClient implements IMeterClient {
  final String host;
  final int port;

  ClientChannel? _channel;
  MeterServiceClient? _stub;

  MeterClient({
    this.host = '127.0.0.1',
    this.port = 50051,
  });

  // coverage:ignore-start
  void _ensureClient() {
    _channel ??= ClientChannel(
      host,
      port: port,
      options: const ChannelOptions(
        credentials: ChannelCredentials.insecure(),
      ),
    );
    _stub ??= MeterServiceClient(_channel!);
  }

  MeterServiceClient get _client {
    _ensureClient();
    return _stub!;
  }
  // coverage:ignore-end

  Future<void> close() async {
    try {
      final ch = _channel;
      if (ch != null) {
        await ch.shutdown(); // coverage:ignore-line
      }
    } catch (_) {
      // coverage:ignore-start
      // Ignore shutdown errors (e.g. already closed).
    } // coverage:ignore-end
  }

  /// Run query with progress streaming
  // coverage:ignore-start
  Future<bool> initMeterContext(String moduleName) async {
    final resp = await _client
        .initMeterContext(InitMeterContextRequest()..modulename = moduleName);
    return resp.value;
  }

  Future<bool> connect() async {
    final resp = await _client.connect(Empty());
    return resp.value;
  }

  Future<bool> disconnect() async {
    final resp = await _client.disconnect(Empty());
    return resp.value;
  }

  Future<List<FrameExecutionItem>> executeGet(
      List<GetRequest> requests, bool withList) async {
    final resp = await _client.executeGet(GetRequestList()
      ..requests.addAll(requests)
      ..withList = withList);
    return resp.items;
  }

  Future<List<FrameExecutionItem>> executeSet(
      List<SetRequest> requests, bool withList) async {
    final resp = await _client.executeSet(SetRequestList()
      ..requests.addAll(requests)
      ..withList = withList);
    return resp.items;
  }

  Future<List<FrameExecutionItem>> executeAction(
      List<ActionRequest> requests, bool withList) async {
    final resp = await _client.executeAction(ActionRequestList()
      ..requests.addAll(requests)
      ..withList = withList);
    return resp.items;
  }

  Future<List<ApplicationResponse>> executeAdvancedGet(
      List<GetRequest> requests, bool withList) async {
    final resp = await _client.executeAdvancedGet(GetRequestList()
      ..requests.addAll(requests)
      ..withList = withList);
    return resp.responses;
  }

  Future<List<ApplicationResponse>> executeAdvancedSet(
      List<SetRequest> requests, bool withList) async {
    final resp = await _client.executeAdvancedSet(SetRequestList()
      ..requests.addAll(requests)
      ..withList = withList);
    return resp.responses;
  }

  Future<List<ApplicationResponse>> executeAdvancedAction(
      List<ActionRequest> requests, bool withList) async {
    final resp = await _client.executeAdvancedAction(ActionRequestList()
      ..requests.addAll(requests)
      ..withList = withList);
    return resp.responses;
  }

  // Firmware upgrade

  Future<int> getBlockSize() async {
    final resp = await _client.getBlockSize(Empty());
    return resp.value;
  }

  Future<bool> setBlockSize(int blockSize) async {
    final resp = await _client.setBlockSize(Int32Value()..value = blockSize);
    return resp.value;
  }

  Future<bool> enableImageTransfer() async {
    final resp = await _client.enableImageTransfer(Empty());
    return resp.value;
  }

  Future<bool> initiateTransfer(String imageId, String filePath) async {
    final resp = await _client.initiateTransfer(InitiateTransferRequest()
      ..imageId = imageId
      ..pathFile = filePath);
    return resp.value;
  }

  Future<ActivationDateTime> getImageTransfertActivationDateTime() async {
    final resp = await _client.getImageTransfertActivationDateTime(Empty());
    return resp;
  }

  Future<bool> setImageTransfertActivationDateTime(
      int year, int month, int day, int hour, int minute, int second) async {
    final req = ActivationDateTime()
      ..year = year
      ..month = month
      ..day = day
      ..hour = hour
      ..minute = minute
      ..second = second;
    final resp = await _client.setImageTransfertActivationDateTime(req);
    return resp.value;
  }

  Stream<TransferUpdate> transferFile(String filePath, int blockSize) {
    final req = TransferFileRequest()
      ..pathFile = filePath
      ..blockSize = blockSize;
    return _client.transferFile(req);
  }

  Future<List<bool>> verifyTransfert(String filePath, int blockSize) async {
    final req = VerifyTransfertRequest()
      ..pathFile = filePath
      ..blockSize = blockSize;
    final resp = await _client.verifyTransfert(req);
    return resp.chunksOk;
  }

  Stream<TransferUpdate> resendMissingChunks(String filePath, int blockSize) {
    final req = ResendMissingChunksRequest()
      ..pathFile = filePath
      ..blockSize = blockSize;
    return _client.resendMissingChunks(req);
  }

  Stream<TransferUpdate> resumeTransfer(
      String filePath, int blockSize, int startBlock) {
    final req = ResumeTransferRequest()
      ..pathFile = filePath
      ..blockSize = blockSize
      ..startBlock = startBlock;
    return _client.resumeTransfer(req);
  }

  Future<ActivateFirmwareResponse> activateFirmware() async {
    return await _client.activateFirmware(Empty());
  }

  Future<BitStatusResponse> getBitStatus(
      String dataSource, String descriptionJson) async {
    final req = BitStatusRequest()
      ..dataSource = dataSource
      ..descriptionJson = descriptionJson;
    return await _client.getBitStatus(req);
  }

  Future<List<DatamodelObject>> getDatamodelObjects() async {
    final req = GetDatamodelObjectsRequest()..withAttributes = false;
    final resp = await _client.getDatamodelObjects(req);
    return resp.objects;
  }

  Future<List<PushObjectItem>> getPushObjectList(String datasource) async {
    final req = GetPushObjectListRequest()..datasource = datasource;
    final resp = await _client.getPushObjectList(req);
    return resp.items;
  }

  Future<void> setPushObjectList(
      String datasource, List<PushObjectItem> items) async {
    final req = SetPushObjectListRequest()
      ..datasource = datasource
      ..items.addAll(items);
    await _client.setPushObjectList(req);
  }

  Future<int> getRandomisationStartInterval(String datasource) async {
    final req = GetRandomisationStartIntervalRequest()..datasource = datasource;
    final resp = await _client.getRandomisationStartInterval(req);
    return resp.result;
  }

  Future<void> setRandomisationStartInterval(
      String datasource, int value) async {
    final req = SetRandomisationStartIntervalRequest()
      ..datasource = datasource
      ..value = value;
    await _client.setRandomisationStartInterval(req);
  }

  Future<int> getNumberOfRetries(String datasource) async {
    final req = GetNumberOfRetriesRequest()..datasource = datasource;
    final resp = await _client.getNumberOfRetries(req);
    return resp.result;
  }

  Future<void> setNumberOfRetries(String datasource, int value) async {
    final req = SetNumberOfRetriesRequest()
      ..datasource = datasource
      ..value = value;
    await _client.setNumberOfRetries(req);
  }

  Future<({int min, int exponent, int max})> getRepetitionDelay(
      String datasource) async {
    final req = GetRepetitionDelayRequest()..datasource = datasource;
    final resp = await _client.getRepetitionDelay(req);
    return (min: resp.min, exponent: resp.exponent, max: resp.max);
  }

  Future<void> setRepetitionDelay(
      String datasource, int min, int exponent, int max) async {
    final req = SetRepetitionDelayRequest()
      ..datasource = datasource
      ..min = min
      ..exponent = exponent
      ..max = max;
    await _client.setRepetitionDelay(req);
  }

  Future<String> getLastConfirmationDatetime(String datasource) async {
    final req = GetLastConfirmationDatetimeRequest()..datasource = datasource;
    final resp = await _client.getLastConfirmationDatetime(req);
    return resp.result;
  }

  Future<void> setLastConfirmationDatetime(
      String datasource, String value) async {
    final req = SetLastConfirmationDatetimeRequest()
      ..datasource = datasource
      ..value = value;
    await _client.setLastConfirmationDatetime(req);
  }

  Future<({int tcpService, String destination, int message})>
      getSendDestination(String datasource) async {
    final req = GetSendDestinationRequest()..datasource = datasource;
    final resp = await _client.getSendDestination(req);
    return (
      tcpService: resp.tcpService,
      destination: resp.destination,
      message: resp.message
    );
  }

  Future<void> setSendDestination(String datasource, int tcpService,
      String destination, int message) async {
    final req = SetSendDestinationRequest()
      ..datasource = datasource
      ..tcpService = tcpService
      ..destination = destination
      ..message = message;
    await _client.setSendDestination(req);
  }

  Future<List<({String startTime, String endTime})>> getCommunicationWindow(
      String datasource) async {
    final req = GetCommunicationWindowRequest()..datasource = datasource;
    final resp = await _client.getCommunicationWindow(req);
    return resp.windows
        .map((w) => (startTime: w.startTime, endTime: w.endTime))
        .toList();
  }

  Future<void> setCommunicationWindow(
      String datasource,
      List<
              ({
                ({
                  int day,
                  int month,
                  int year,
                  int weekday,
                  int hour,
                  int minute,
                  int second
                }) start,
                ({
                  int day,
                  int month,
                  int year,
                  int weekday,
                  int hour,
                  int minute,
                  int second
                }) end
              })>
          windows) async {
    final req = SetCommunicationWindowRequest()..datasource = datasource;
    for (final w in windows) {
      req.windows.add(SetCommunicationWindowEntry()
        ..startTime = (CosemDateTimeEntry()
          ..day = w.start.day
          ..month = w.start.month
          ..year = w.start.year
          ..weekday = w.start.weekday
          ..hour = w.start.hour
          ..minute = w.start.minute
          ..second = w.start.second)
        ..endTime = (CosemDateTimeEntry()
          ..day = w.end.day
          ..month = w.end.month
          ..year = w.end.year
          ..weekday = w.end.weekday
          ..hour = w.end.hour
          ..minute = w.end.minute
          ..second = w.end.second));
    }
    await _client.setCommunicationWindow(req);
  }

  Future<List<DatamodelAttribute>> getDatamodelAttributesByObjectName(
      String objectName, String clientName) async {
    final req = GetDatamodelAttributesByObjectNameRequest()
      ..objectName = objectName
      ..clientName = clientName;
    final resp = await _client.getDatamodelAttributesByObjectName(req);
    return resp.attributes;
  }

  Future<List<TranslateDataItemResponse>> translateData(
      List<TranslateDataItemRequest> items) async {
    final req = TranslateDataRequest()..requests.addAll(items);
    final resp = await _client.translateData(req);
    return resp.items;
  }

  Future<String> dlmsTranslate(String data, bool isXml) async {
    final req = DlmsTranslateRequest()
      ..data = data
      ..isxml = isXml;
    final resp = await _client.dlmsTranslate(req);
    return resp.value;
  }

  // ---- Push action / Schedule ----
  @override
  Future<List<String>> getExecutionTime(String datasource) async {
    final req = GetExecutionTimeRequest()..datasource = datasource;
    final resp = await _client.getExecutionTime(req);
    return resp.items;
  }
  // ---- LTE Monitoring(LTE Parameters) ----

 

  @override
  Future<void> setExecutionTime(
      String datasource,
      List<
              ({
                int day,
                int month,
                int year,
                int weekday,
                int hour,
                int minute,
                int second
              })>
          times) async {
    final req = SetExecutionTimeRequest()..datasource = datasource;
    for (final t in times) {
      req.times.add(CosemDateTimeEntry()
        ..day = t.day
        ..month = t.month
        ..year = t.year
        ..weekday = t.weekday
        ..hour = t.hour
        ..minute = t.minute
        ..second = t.second);
    }
    await _client.setExecutionTime(req);
  }

  @override
  Future<int> getScheduleType(String datasource) =>
      throw UnimplementedError('getScheduleType');

  @override
  Future<int> getPushActionType(String datasource) async {
    final req = GetPushActionTypeRequest()..datasource = datasource;
    final resp = await _client.getPushActionType(req);
    return resp.value;
  }

  @override
  Future<({int scriptSelector, String scriptTable})>
      getPushActionExecutedScript(String datasource) async {
    final req = GetPushActionExecutedScriptRequest()..datasource = datasource;
    final resp = await _client.getPushActionExecutedScript(req);
    return (scriptSelector: resp.scriptSelector, scriptTable: resp.scriptTable);
  }

  @override
  Future<void> setPushActionExecutedScript(
      String datasource, int scriptSelector, String scriptTable) async {
    final req = SetPushActionExecutedScriptRequest()
      ..datasource = datasource
      ..scriptSelector = scriptSelector
      ..scriptTable = scriptTable;
    await _client.setPushActionExecutedScript(req);
  }

  @override
  Future<GetScriptTableResponse> getScriptTable(String datasource) async {
    final req = GetScriptTableRequest()..datasource = datasource;
    return await _client.getScriptTable(req);
  }

  @override
  Future<GetPushSelectiveCaptureObjectsResponse> getPushSelectiveCaptureObjects(
      String datasource) async {
    final req = GetPushSelectiveCaptureObjectsRequest()
      ..datasource = datasource;
    return await _client.getPushSelectiveCaptureObjects(req);
  }

  @override
  Future<GetPushRecoveryObjectsResponse> getPushRecoveryObjects(
      List<GetPushRecoveryObjectsRequestItem> items) async {
    final req = GetPushRecoveryObjectsRequest()..items.addAll(items);
    return await _client.getPushRecoveryObjects(req);
  }

  @override
  Future<void> pushSetupPush(String datasource) async {
    final req = PushSetupPushRequest()..datasource = datasource;
    await _client.pushSetupPush(req);
  }

  @override
  Future<void> pushSetupReset(String datasource) async {
    final req = PushSetupResetRequest()..datasource = datasource;
    await _client.pushSetupReset(req);
  }

  @override
  Future<void> executeScriptTable(String datasource) async {
    final req = ExecuteScriptTableRequest()..datasource = datasource;
    await _client.executeScriptTable(req);
  }

  @override
  Future<void> setScriptTable(String datasource, String value) =>
      throw UnimplementedError('setScriptTable');

  @override
  Future<({int selector, String scriptText})> getScriptSelector(
          String datasource) =>
      throw UnimplementedError('getScriptSelector');

  @override
  Future<void> setScriptSelector(
          String datasource, int selector, String scriptText) =>
      throw UnimplementedError('setScriptSelector');

  // Clock

  Future<String> getClock() async {
    final resp = await _client.getClock(Empty());
    return resp.value;
  }

  Future<bool> setClock(String dateTime) async {
    final resp = await _client.setClock(StringValue()..value = dateTime);
    return resp.value;
  }

  Future<DaylightSavingsTime> getIncrementalDate() async {
    final resp = await _client.getIncrementalDate(Empty());
    return resp;
  }

  Future<bool> setIncrementalDate(DaylightSavingsTime dateTime) async {
    final resp = await _client.setIncrementalDate(dateTime);
    return resp.value;
  }

  Future<DaylightSavingsTime> getDecrementalDate() async {
    final resp = await _client.getDecrementalDate(Empty());
    return resp;
  }

  Future<bool> setDecrementalDate(DaylightSavingsTime dateTime) async {
    final resp = await _client.setDecrementalDate(dateTime);
    return resp.value;
  }

  Future<List<String>> getDatamodels() async {
    final resp = await _client.getDatamodels(Empty());
    return resp.items;
  }

  Future<bool> loadDatamodel(String datamodel) async {
    final resp = await _client
        .loadDatamodel(LoadDatamodelRequest()..datamodel = datamodel);
    return resp.value;
  }

  Stream<GetLoadProfileStreamItem> getLoadProfile(
    String objectName, {
    LoadProfilePartialRead? start,
    LoadProfilePartialRead? end,
    int page = 1,
    int pageSize = 50,
  }) {
    final request = GetLoadProfileRequest()
      ..objectName = objectName
      ..page = page
      ..pageSize = pageSize;
    if (start != null) {
      request.start = start;
    }
    if (end != null) {
      request.end = end;
    }
    return _client.getLoadProfile(request);
  }

  Future<int> getLoadProfileMaxRecords(String objectName) async {
    final resp = await _client.getLoadProfileParam(GetLoadProfileParamRequest()
      ..objectName = objectName
      ..param = LoadProfileParam.MAX_RECORD);
    return resp.value;
  }

  Future<int> getLoadProfileRecordNumber(String objectName) async {
    final resp = await _client.getLoadProfileParam(GetLoadProfileParamRequest()
      ..objectName = objectName
      ..param = LoadProfileParam.RECORD_NUMBER);
    return resp.value;
  }

  Future<int> getLoadProfileCapturePeriod(String objectName) async {
    final resp = await _client.getLoadProfileParam(GetLoadProfileParamRequest()
      ..objectName = objectName
      ..param = LoadProfileParam.CAPTURE_PERIOD);
    return resp.value;
  }

  Future<bool> setLoadProfileMaxRecords(String objectName, int value) async {
    final resp = await _client.setLoadProfileParam(SetLoadProfileParamRequest()
      ..objectName = objectName
      ..param = LoadProfileParam.MAX_RECORD
      ..value = value);
    return resp.value;
  }

  Future<bool> setLoadProfileRecordNumber(String objectName, int value) async {
    final resp = await _client.setLoadProfileParam(SetLoadProfileParamRequest()
      ..objectName = objectName
      ..param = LoadProfileParam.RECORD_NUMBER
      ..value = value);
    return resp.value;
  }

  Future<bool> setLoadProfileCapturePeriod(String objectName, int value) async {
    final resp = await _client.setLoadProfileParam(SetLoadProfileParamRequest()
      ..objectName = objectName
      ..param = LoadProfileParam.CAPTURE_PERIOD
      ..value = value);
    return resp.value;
  }

  Future<List<PhaseData>> getFresnelData() async {
    final resp = await _client.getFresnelData(Empty());
    return resp.phases;
  }

  Future<DeviceIDList> getDeviceID() async {
    print("getting device ID");
    final resp = await _client.getDeviceID(Empty());
    print("response received: $resp");
    return resp;
  }

  Future<FirmwareVersionList> getFirmwareVersion() async {
    final resp = await _client.getFirmwareVersion(Empty());
    return resp;
  }

  Future<EnergyRegisterList> getEnergyRegister() async {
    final resp = await _client.getEnergyRegister(Empty());
    return resp;
  }

  Future<AverageList> getAverage() async {
    final resp = await _client.getAverage(Empty());
    return resp;
  }

  // ---- SIM Config (P2P Setup) ----

  Future<ModemConfigResponse> getModemConfig() async {
    return await _client.getModemConfig(Empty());
  }

  Future<bool> setApn(String apn) async {
    final req = SetApnRequest()..value = apn;
    final resp = await _client.setApn(req);
    return resp.value;
  }

  Future<bool> setPinCode(int pinCode) async {
    final req = SetPinCodeRequest()..pinCode = pinCode;
    final resp = await _client.setPinCode(req);
    return resp.value;
  }

  Future<bool> setPppAuth(String username, String password) async {
    final req = SetPppAuthRequest()
      ..username = username
      ..password = password;
    final resp = await _client.setPppAuth(req);
    return resp.value;
  }

  Future<IpAddressResponse> getIpAddress() async {
    return await _client.getIpAddress(Empty());
  }

  Future<bool> setIpAddress(String address, bool isIpv6) async {
    final req = SetIpAddressRequest()
      ..address = address
      ..isIpv6 = isIpv6;
    final resp = await _client.setIpAddress(req);
    return resp.value;
  }

  Future<CellularDiagResponse> getCellularDiag() async {
    return await _client.getCellularDiag(Empty());
  }

  Future<bool> setCellularField(
      int attribute, String stringValue, int enumValue) async {
    final req = SetCellularFieldRequest()
      ..attribute = attribute
      ..stringValue = stringValue
      ..enumValue = enumValue;
    final resp = await _client.setCellularField(req);
    return resp.value;
  }

  Future<CellInfoResponse> getCellInfo() async {
    return await _client.getCellInfo(Empty());
  }

  Future<bool> setCellInfoEntry(
      int entryIndex, String value, bool isLte) async {
    final req = SetCellInfoEntryRequest()
      ..entryIndex = entryIndex
      ..value = value
      ..isLte = isLte;
    final resp = await _client.setCellInfoEntry(req);
    return resp.value;
  }

  Future<GetQosResponse> getQos() async {
    return await _client.getQos(Empty());
  }

  Future<bool> setQos(QosEntry profile, int profileIndex) async {
    final req = SetQosRequest()
      ..profile = profile
      ..profileIndex = profileIndex;
    final resp = await _client.setQos(req);
    return resp.value;
  }

  // ---- Mobile Network Identifier (P2P Setup) ----

  Future<MobileNetworkIdentifiersResponse> getMobileNetworkIdentifiers() async {
    return await _client.getMobileNetworkIdentifiers(Empty());
  }

  Future<bool> setImsi(String value) async {
    final resp = await _client.setImsi(SetMniFieldRequest()..value = value);
    return resp.value;
  }

  Future<bool> setMsisdn(String value) async {
    final resp = await _client.setMsisdn(SetMniFieldRequest()..value = value);
    return resp.value;
  }

  Future<bool> setImei(String value) async {
    final resp = await _client.setImei(SetMniFieldRequest()..value = value);
    return resp.value;
  }

  Future<bool> setIccid(String value) async {
    final resp = await _client.setIccid(SetMniFieldRequest()..value = value);
    return resp.value;
  }

  Future<ModemStatusResponse> getModemStatus() async {
    return await _client.getModemStatus(Empty());
  }

  Future<bool> setModemStatus(bool isActive) async {
    final resp = await _client.setModemStatus(BoolValue()..value = isActive);
    return resp.value;
  }

  Future<bool> restartModem() async {
    final resp = await _client.restartModem(Empty());
    return resp.value;
  }

  Future<MniRightsResponse> getMniRights() async {
    return await _client.getMniRights(Empty());
  }

  // ---- Modem Config (P2P Setup) ----

  Future<ModemConfigSettingsResponse> getModemConfigSettings() async {
    return await _client.getModemConfigSettings(Empty());
  }

  Future<bool> setCommSpeed(int speedIndex) async {
    final resp = await _client
        .setCommSpeed(SetCommSpeedRequest()..speedIndex = speedIndex);
    return resp.value;
  }

  Future<bool> setModemProfile(String profile) async {
    final resp = await _client
        .setModemProfile(SetModemProfileRequest()..profile = profile);
    return resp.value;
  }

  Future<bool> setInitStrings(List<ModemInitStringEntry> entries) async {
    final req = SetInitStringsRequest()..entries.addAll(entries);
    final resp = await _client.setInitStrings(req);
    return resp.value;
  }

  Future<AutoConnectResponse> getAutoConnect() async {
    return await _client.getAutoConnect(Empty());
  }

  Future<bool> setAutoConnect(SetAutoConnectRequest req) async {
    final resp = await _client.setAutoConnect(req);
    return resp.value;
  }

  Future<bool> modemConnect() async {
    final resp = await _client.modemConnect(Empty());
    return resp.value;
  }

  Future<AutoAnswerResponse> getAutoAnswer() async {
    return await _client.getAutoAnswer(Empty());
  }

  Future<bool> setAutoAnswer(SetAutoAnswerRequest req) async {
    final resp = await _client.setAutoAnswer(req);
    return resp.value;
  }

  Future<TcpUdpSetupResponse> getTcpUdpSetup() async {
    return await _client.getTcpUdpSetup(Empty());
  }

  Future<bool> setTcpUdpSetup(SetTcpUdpSetupRequest req) async {
    final resp = await _client.setTcpUdpSetup(req);
    return resp.value;
  }

  Future<String> getObjectWriteRights(int classId) async {
    final resp =
        await _client.getObjectWriteRights(Int32Value()..value = classId);
    return resp.value;
  }

  Stream<RetryStatusUpdate> watchRetryStatus() {
    return _client.watchRetryStatus(Empty());
  }

  Future<bool> exportData({
    required String pageId,
    required String type,
    required String data,
    required String folderPath,
    String pageType = '',
    String fileNameSuffix = '',
  }) async {
    final req = ExportDataRequest()
      ..pageId = pageId
      ..type = type
      ..data = data
      ..folderPath = folderPath
      ..pageType = pageType
      ..fileNameSuffix = fileNameSuffix;
    final resp = await _client.exportData(req);
    return resp.success;
  }

  Future<Int32Value> getDaylightSavingDeviation() async {
    return await _client.getDaylightSavingDeviation(Empty());
  }

  Future<bool> setDaylightSavingDeviation(int deviation) async {
    final resp = await _client
        .setDaylightSavingDeviation(Int32Value()..value = deviation);
    return resp.value;
  }

  Future<bool> getDaylightSavingActivation() async {
    final resp = await _client.getDaylightSavingActivation(Empty());
    return resp.value;
  }

  Future<bool> setDaylightSavingActivation(bool active) async {
    final resp =
        await _client.setDaylightSavingActivation(BoolValue()..value = active);
    return resp.value;
  }

  Future<Int32Value> getTimezone() async {
    return await _client.getTimezone(Empty());
  }

  Future<bool> setTimezone(int offset) async {
    final resp = await _client.setTimezone(Int32Value()..value = offset);
    return resp.value;
  }
  // coverage:ignore-end

  // ---- Activity Calendar ----
  // coverage:ignore-start
  Future<ActivityCalendarData> getActiveCalendar() async {
    return await _client.getActiveCalendar(Empty());
  }

  Future<ActivityCalendarData> getPassiveCalendar() async {
    return await _client.getPassiveCalendar(Empty());
  }

  Future<ActivityCalendarData> getPassiveDayProfiles() async {
    return await _client.getPassiveDayProfiles(Empty());
  }

  Future<ActivityCalendarData> getPassiveWeekProfiles() async {
    return await _client.getPassiveWeekProfiles(Empty());
  }

  Future<ActivityCalendarData> getPassiveSeasonProfiles() async {
    return await _client.getPassiveSeasonProfiles(Empty());
  }

  Future<bool> setPassiveCalendar(ActivityCalendarData data) async {
    final resp = await _client.setPassiveCalendar(data);
    return resp.value;
  }

  Future<bool> setPassiveDayProfiles(ActivityCalendarData data) async {
    final req = ActivityCalendarData(
      calendarName: '#day#${data.calendarName}',
      dayProfiles: data.dayProfiles,
    );
    final resp = await _client.setPassiveCalendar(req);
    return resp.value;
  }

  Future<bool> setPassiveWeekProfiles(ActivityCalendarData data) async {
    final req = ActivityCalendarData(
      calendarName: '#week#${data.calendarName}',
      weekProfiles: data.weekProfiles,
    );
    final resp = await _client.setPassiveCalendar(req);
    return resp.value;
  }

  Future<bool> setPassiveSeasonProfiles(ActivityCalendarData data) async {
    final req = ActivityCalendarData(
      calendarName: '#season#${data.calendarName}',
      seasonProfiles: data.seasonProfiles,
    );
    final resp = await _client.setPassiveCalendar(req);
    return resp.value;
  }

  Future<SpecialDayTable> getSpecialDays() async {
    return await _client.getSpecialDays(Empty());
  }

  Future<SpecialDayTable> getPassiveSpecialDays() async {
    return await _client.getPassiveSpecialDays(Empty());
  }

  Future<bool> setPassiveSpecialDays(SpecialDayTable table) async {
    final resp = await _client.setPassiveSpecialDays(table);
    return resp.value;
  }

  Future<bool> activatePassiveCalendar() async {
    final resp = await _client.activatePassiveCalendar(Empty());
    return resp.value;
  }

  @override
  Stream<PushNotification> startPushSetupServer(
      String host, int port, String type) {
    final req = StartPushSetupServerRequest()
      ..host = host
      ..port = port
      ..type = type;
    return _client.startPushSetupServer(req);
  }

  @override
  Future<void> stopPushSetupServer() async {
    await _client.stopPushSetupServer(Empty());
  }

  @override
  Future<void> sendTestNotification() async {
    await _client.sendTestNotification(Empty());
  }

  @override
  Future<int> getPrimaryCt() async {
    final resp = await _client.getPrimaryCt(Empty());
    return resp.value;
  }

  @override
  Future<void> setPrimaryCt(int value) async {
    await _client.setPrimaryCt(Int32Value()..value = value);
  }

  @override
  Future<int> getSecondaryCt() async {
    final resp = await _client.getSecondaryCt(Empty());
    return resp.value;
  }

  @override
  Future<void> setSecondaryCt(int value) async {
    await _client.setSecondaryCt(Int32Value()..value = value);
  }

  @override
  Future<int> getPrimaryVt() async {
    final resp = await _client.getPrimaryVt(Empty());
    return resp.value;
  }

  @override
  Future<void> setPrimaryVt(int value) async {
    await _client.setPrimaryVt(Int32Value()..value = value);
  }

  @override
  Future<int> getRatioValueVt() async {
    final resp = await _client.getRatioValueVt(Empty());
    return resp.value;
  }

  @override
  Future<void> setRatioValueVt(int value) async {
    await _client.setRatioValueVt(Int32Value()..value = value);
  }
  
  @override
  Future<GetLteNetworkParametersResponse> getLteNetworkParameters() {
    // TODO: implement getLteNetworkParameters
    throw UnimplementedError();
  }
  
  @override
  Future<GetLteQosResponse> getLteQos() {
    // TODO: implement getLteQos
    throw UnimplementedError();
  }
  
  @override
  Future<List<QualityObject>> getQualityObjects(List<String> objects) async {
    final resp = await _client.getQualityObjects(GetQualityObjectsRequest()..objects.addAll(  objects));
    return resp.objects;
  }
  
  @override
  Future<void> updateQualityObject(String datasource, double value, int scaler) async {
    await _client.updateQualityObject(UpdateQualityObjectRequest()..value = value..datasource = datasource..scaler = scaler);
  }
  
  @override
  Future<void> WriteQualityConfig(String dataSource, List<QualityConfigValue> items, bool isStructure) async {
    
    final request = WriteQualityConfigRequest()
        ..dataSource = dataSource;

      if (!isStructure) {
        request.value = items.first;
      } else {
        request.values = (QualityConfigValues()
          ..values.addAll(items));
      }

      await _client.writeQualityConfig(request);

  }
  
  @override
  Future<List<QualityConfigValue>> readQualityConfig(
  String dataSource,
) async {
    final response = await _client.readQualityConfig(
      ReadQualityConfigRequest()
        ..dataSource = dataSource,
    );

    if (response.hasValue()) {
      return [response.value];
    }

    if (response.hasValues()) {
      return response.values.values.toList();
    }

    return [];
  }

  // coverage:ignore-end
}
