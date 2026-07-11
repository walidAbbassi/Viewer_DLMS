// This is a generated file - do not edit.
//
// Generated from meter.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;

import 'meter.pb.dart' as $0;

export 'meter.pb.dart';

/// ==========================
/// Service
/// ==========================
@$pb.GrpcServiceName('meter.MeterService')
class MeterServiceClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  MeterServiceClient(super.channel, {super.options, super.interceptors});

  /// Export page data to a file in the given folder.
  $grpc.ResponseFuture<$0.ExportDataResponse> exportData(
    $0.ExportDataRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$exportData, request, options: options);
  }

  /// Initialize meter context using a string input named `modulename`.
  $grpc.ResponseFuture<$0.BoolValue> initMeterContext(
    $0.InitMeterContextRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$initMeterContext, request, options: options);
  }

  /// Connect / disconnect to meter transport.
  $grpc.ResponseFuture<$0.BoolValue> connect(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$connect, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> disconnect(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$disconnect, request, options: options);
  }

  /// ---------- Advanced execution (old behavior) ----------
  /// Keeps the old signature and returns ApplicationResponseList.
  $grpc.ResponseFuture<$0.ApplicationResponseList> executeAdvancedGet(
    $0.GetRequestList request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeAdvancedGet, request, options: options);
  }

  $grpc.ResponseFuture<$0.ApplicationResponseList> executeAdvancedSet(
    $0.SetRequestList request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeAdvancedSet, request, options: options);
  }

  $grpc.ResponseFuture<$0.ApplicationResponseList> executeAdvancedAction(
    $0.ActionRequestList request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeAdvancedAction, request, options: options);
  }

  /// ---------- New execution with XML/XDR result ----------
  /// Input: *List* + with_list flag (inside Get/Set/ActionRequestList)
  /// Output: list of items (request, xml_xdr, xdr, success, error).
  $grpc.ResponseFuture<$0.FrameExecutionList> executeGet(
    $0.GetRequestList request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeGet, request, options: options);
  }

  $grpc.ResponseFuture<$0.FrameExecutionList> executeSet(
    $0.SetRequestList request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeSet, request, options: options);
  }

  $grpc.ResponseFuture<$0.FrameExecutionList> executeAction(
    $0.ActionRequestList request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeAction, request, options: options);
  }

  /// ---------- Existing RPCs ----------
  /// Return current block size from meter (or configured SDK value).
  $grpc.ResponseFuture<$0.Int32Value> getBlockSize(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBlockSize, request, options: options);
  }

  /// NEW: Set block size
  $grpc.ResponseFuture<$0.BoolValue> setBlockSize(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setBlockSize, request, options: options);
  }

  /// Enable image transfer mode on the meter/SDK.
  $grpc.ResponseFuture<$0.BoolValue> enableImageTransfer(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$enableImageTransfer, request, options: options);
  }

  /// Initiate a transfer session with file path + imageId.
  $grpc.ResponseFuture<$0.BoolValue> initiateTransfer(
    $0.InitiateTransferRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$initiateTransfer, request, options: options);
  }

  /// Transfer a file in blocks; server streams progress updates.
  $grpc.ResponseStream<$0.TransferUpdate> transferFile(
    $0.TransferFileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$transferFile, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// ---------- NEW RPCs ----------
  /// Verify transferred chunks; returns an array of booleans (per-chunk OK).
  $grpc.ResponseFuture<$0.VerifyTransfertResponse> verifyTransfert(
    $0.VerifyTransfertRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$verifyTransfert, request, options: options);
  }

  /// Resend missing/failed chunks discovered by verification; streams updates.
  $grpc.ResponseStream<$0.TransferUpdate> resendMissingChunks(
    $0.ResendMissingChunksRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$resendMissingChunks, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseStream<$0.TransferUpdate> resumeTransfer(
    $0.ResumeTransferRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$resumeTransfer, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Activate firmware once transfer/verification is done.
  $grpc.ResponseFuture<$0.ActivateFirmwareResponse> activateFirmware(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$activateFirmware, request, options: options);
  }

  /// ---------- Datamodel Browsing (NEW) ----------
  /// List DLMS/COSEM objects; optionally include attributes depending on `withAttributes`.
  $grpc.ResponseFuture<$0.GetDatamodelObjectsResponse> getDatamodelObjects(
    $0.GetDatamodelObjectsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDatamodelObjects, request, options: options);
  }

  /// List attributes for a specific object (by name) and client context.
  $grpc.ResponseFuture<$0.GetDatamodelAttributesByObjectNameResponse>
      getDatamodelAttributesByObjectName(
    $0.GetDatamodelAttributesByObjectNameRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDatamodelAttributesByObjectName, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.TranslateDataResponse> translateData(
    $0.TranslateDataRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$translateData, request, options: options);
  }

  $grpc.ResponseFuture<$0.StringValue> dlmsTranslate(
    $0.DlmsTranslateRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$dlmsTranslate, request, options: options);
  }

  $grpc.ResponseFuture<$0.StringValue> getClock(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getClock, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setClock(
    $0.StringValue request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setClock, request, options: options);
  }

  $grpc.ResponseFuture<$0.StringList> getDatamodels(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDatamodels, request, options: options);
  }

  /// Output: BoolValue (true if loaded successfully)
  $grpc.ResponseFuture<$0.BoolValue> loadDatamodel(
    $0.LoadDatamodelRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$loadDatamodel, request, options: options);
  }

  /// Returns load profile table for the given object name:
  /// - headerTypes: list of column headers/types
  /// - values: list of rows; each row is a list of strings
  $grpc.ResponseStream<$0.GetLoadProfileStreamItem> getLoadProfile(
    $0.GetLoadProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$getLoadProfile, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Get / Set a single load-profile parameter (one info per call).
  $grpc.ResponseFuture<$0.Int32Value> getLoadProfileParam(
    $0.GetLoadProfileParamRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLoadProfileParam, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setLoadProfileParam(
    $0.SetLoadProfileParamRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setLoadProfileParam, request, options: options);
  }

  /// Empty request → returns a list of PhaseData.
  $grpc.ResponseFuture<$0.FresnelResponse> getFresnelData(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFresnelData, request, options: options);
  }

  /// Get device identification data (factory number, COSEM logical device name, and device IDs 2-5)
  $grpc.ResponseFuture<$0.DeviceIDList> getDeviceID(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDeviceID, request, options: options);
  }

  /// Get firmware version data
  $grpc.ResponseFuture<$0.FirmwareVersionList> getFirmwareVersion(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getFirmwareVersion, request, options: options);
  }

  /// Returns the currently configured activation datetime (UTC).
  $grpc.ResponseFuture<$0.ActivationDateTime>
      getImageTransfertActivationDateTime(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getImageTransfertActivationDateTime, request,
        options: options);
  }

  /// Sets the activation datetime (expects UTC Timestamp); returns success.
  $grpc.ResponseFuture<$0.BoolValue> setImageTransfertActivationDateTime(
    $0.ActivationDateTime request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setImageTransfertActivationDateTime, request,
        options: options);
  }

  /// Get/Set incremental date for daylight savings (DST activation)
  $grpc.ResponseFuture<$0.DaylightSavingsTime> getIncrementalDate(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getIncrementalDate, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setIncrementalDate(
    $0.DaylightSavingsTime request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setIncrementalDate, request, options: options);
  }

  /// Get/Set decremental date for daylight savings (DST deactivation)
  $grpc.ResponseFuture<$0.DaylightSavingsTime> getDecrementalDate(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDecrementalDate, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setDecrementalDate(
    $0.DaylightSavingsTime request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setDecrementalDate, request, options: options);
  }

  /// Get/Set daylight saving deviation (minutes)
  $grpc.ResponseFuture<$0.Int32Value> getDaylightSavingDeviation(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDaylightSavingDeviation, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setDaylightSavingDeviation(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setDaylightSavingDeviation, request,
        options: options);
  }

  /// Get/Set daylight saving activation (enabled/disabled)
  $grpc.ResponseFuture<$0.BoolValue> getDaylightSavingActivation(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getDaylightSavingActivation, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setDaylightSavingActivation(
    $0.BoolValue request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setDaylightSavingActivation, request,
        options: options);
  }

  /// Get/Set timezone (minutes offset from UTC)
  $grpc.ResponseFuture<$0.Int32Value> getTimezone(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTimezone, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setTimezone(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setTimezone, request, options: options);
  }

  /// Get energy register objects
  $grpc.ResponseFuture<$0.EnergyRegisterList> getEnergyRegister(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getEnergyRegister, request, options: options);
  }

  /// Get average voltage and current objects
  $grpc.ResponseFuture<$0.AverageList> getAverage(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAverage, request, options: options);
  }

  /// Get load profile bit status
  $grpc.ResponseFuture<$0.BitStatusResponse> getBitStatus(
    $0.BitStatusRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getBitStatus, request, options: options);
  }

  /// Get push object list for a given data source
  $grpc.ResponseFuture<$0.GetPushObjectListResponse> getPushObjectList(
    $0.GetPushObjectListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPushObjectList, request, options: options);
  }

  /// ---- Activity Calendar (DLMS Class 20 + Class 11) ----
  /// Read the currently active calendar (Attr 2..5 of Class 20).
  $grpc.ResponseFuture<$0.ActivityCalendarData> getActiveCalendar(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getActiveCalendar, request, options: options);
  }

  /// Read the passive (staging) calendar (Attr 6..9 of Class 20).
  $grpc.ResponseFuture<$0.ActivityCalendarData> getPassiveCalendar(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPassiveCalendar, request, options: options);
  }

  /// Read only the passive day profile table (Attr 9 of Class 20).
  $grpc.ResponseFuture<$0.ActivityCalendarData> getPassiveDayProfiles(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPassiveDayProfiles, request, options: options);
  }

  /// Read only the passive week profile table (Attr 8 of Class 20).
  $grpc.ResponseFuture<$0.ActivityCalendarData> getPassiveWeekProfiles(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPassiveWeekProfiles, request,
        options: options);
  }

  /// Read only the passive season profile table (Attr 7 of Class 20).
  $grpc.ResponseFuture<$0.ActivityCalendarData> getPassiveSeasonProfiles(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPassiveSeasonProfiles, request,
        options: options);
  }

  /// Write the passive calendar to the meter (Attr 6..9 of Class 20).
  $grpc.ResponseFuture<$0.BoolValue> setPassiveCalendar(
    $0.ActivityCalendarData request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPassiveCalendar, request, options: options);
  }

  /// Read the active special-days table (Class 11 for Active calendar).
  $grpc.ResponseFuture<$0.SpecialDayTable> getSpecialDays(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSpecialDays, request, options: options);
  }

  /// Read the passive special-days table (Class 11 for Passive calendar).
  $grpc.ResponseFuture<$0.SpecialDayTable> getPassiveSpecialDays(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPassiveSpecialDays, request, options: options);
  }

  /// Write the passive special-days table (Class 11 for Passive calendar).
  $grpc.ResponseFuture<$0.BoolValue> setPassiveSpecialDays(
    $0.SpecialDayTable request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPassiveSpecialDays, request, options: options);
  }

  /// Execute Method 1 on Class 20 – immediately activate the passive calendar.
  $grpc.ResponseFuture<$0.BoolValue> activatePassiveCalendar(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$activatePassiveCalendar, request,
        options: options);
  }

  /// Set push object list for a given data source
  $grpc.ResponseFuture<$1.Empty> setPushObjectList(
    $0.SetPushObjectListRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPushObjectList, request, options: options);
  }

  /// Get randomisation start interval for a given data source
  $grpc.ResponseFuture<$0.GetRandomisationStartIntervalResponse>
      getRandomisationStartInterval(
    $0.GetRandomisationStartIntervalRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRandomisationStartInterval, request,
        options: options);
  }

  /// Set randomisation start interval for a given data source
  $grpc.ResponseFuture<$1.Empty> setRandomisationStartInterval(
    $0.SetRandomisationStartIntervalRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setRandomisationStartInterval, request,
        options: options);
  }

  /// Get number of retries for a given data source
  $grpc.ResponseFuture<$0.GetNumberOfRetriesResponse> getNumberOfRetries(
    $0.GetNumberOfRetriesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getNumberOfRetries, request, options: options);
  }

  /// Set number of retries for a given data source
  $grpc.ResponseFuture<$1.Empty> setNumberOfRetries(
    $0.SetNumberOfRetriesRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setNumberOfRetries, request, options: options);
  }

  /// Get repetition delay (min, exponent, max) for a given data source
  $grpc.ResponseFuture<$0.GetRepetitionDelayResponse> getRepetitionDelay(
    $0.GetRepetitionDelayRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRepetitionDelay, request, options: options);
  }

  /// Set repetition delay for a given data source
  $grpc.ResponseFuture<$1.Empty> setRepetitionDelay(
    $0.SetRepetitionDelayRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setRepetitionDelay, request, options: options);
  }

  /// Get last confirmation datetime for a given data source
  $grpc.ResponseFuture<$0.GetLastConfirmationDatetimeResponse>
      getLastConfirmationDatetime(
    $0.GetLastConfirmationDatetimeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getLastConfirmationDatetime, request,
        options: options);
  }

  /// Set last confirmation datetime for a given data source
  $grpc.ResponseFuture<$1.Empty> setLastConfirmationDatetime(
    $0.SetLastConfirmationDatetimeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setLastConfirmationDatetime, request,
        options: options);
  }

  /// Get send destination (transport service, destination, message) for a given data source
  $grpc.ResponseFuture<$0.GetSendDestinationResponse> getSendDestination(
    $0.GetSendDestinationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSendDestination, request, options: options);
  }

  /// Set send destination for a given data source
  $grpc.ResponseFuture<$1.Empty> setSendDestination(
    $0.SetSendDestinationRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setSendDestination, request, options: options);
  }

  /// Get communication window (list of start/end time pairs) for a given data source
  $grpc.ResponseFuture<$0.GetCommunicationWindowResponse>
      getCommunicationWindow(
    $0.GetCommunicationWindowRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCommunicationWindow, request,
        options: options);
  }

  /// Set communication window for a given data source
  $grpc.ResponseFuture<$1.Empty> setCommunicationWindow(
    $0.SetCommunicationWindowRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCommunicationWindow, request,
        options: options);
  }

  /// Get execution time (list of datetime strings) for a given data source
  $grpc.ResponseFuture<$0.StringList> getExecutionTime(
    $0.GetExecutionTimeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getExecutionTime, request, options: options);
  }

  /// Set execution time for a given data source
  $grpc.ResponseFuture<$1.Empty> setExecutionTime(
    $0.SetExecutionTimeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setExecutionTime, request, options: options);
  }

  /// Get push action type for a given data source
  $grpc.ResponseFuture<$0.Int32Value> getPushActionType(
    $0.GetPushActionTypeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPushActionType, request, options: options);
  }

  /// Get executed script content for a given data source
  $grpc.ResponseFuture<$0.GetPushActionExecutedScriptResponse>
      getPushActionExecutedScript(
    $0.GetPushActionExecutedScriptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPushActionExecutedScript, request,
        options: options);
  }

  /// Set executed script content for a given data source
  $grpc.ResponseFuture<$1.Empty> setPushActionExecutedScript(
    $0.SetPushActionExecutedScriptRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPushActionExecutedScript, request,
        options: options);
  }

  /// Get script table entries for a given data source
  $grpc.ResponseFuture<$0.GetScriptTableResponse> getScriptTable(
    $0.GetScriptTableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getScriptTable, request, options: options);
  }

  /// Get capture objects for a given data source
  $grpc.ResponseFuture<$0.GetPushSelectiveCaptureObjectsResponse>
      getPushSelectiveCaptureObjects(
    $0.GetPushSelectiveCaptureObjectsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPushSelectiveCaptureObjects, request,
        options: options);
  }

  /// Get push recovery objects: pass array of (datasource, attribute) pairs, returns array of string results
  $grpc.ResponseFuture<$0.GetPushRecoveryObjectsResponse>
      getPushRecoveryObjects(
    $0.GetPushRecoveryObjectsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPushRecoveryObjects, request,
        options: options);
  }

  /// Trigger push for a given data source
  $grpc.ResponseFuture<$1.Empty> pushSetupPush(
    $0.PushSetupPushRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pushSetupPush, request, options: options);
  }

  /// Reset push setup for a given data source
  $grpc.ResponseFuture<$1.Empty> pushSetupReset(
    $0.PushSetupResetRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$pushSetupReset, request, options: options);
  }

  /// ==========================
  /// SIM Config RPCs (P2P Setup)
  /// ==========================
  $grpc.ResponseFuture<$0.ModemConfigResponse> getModemConfig(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getModemConfig, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setApn(
    $0.SetApnRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setApn, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setPinCode(
    $0.SetPinCodeRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPinCode, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setPppAuth(
    $0.SetPppAuthRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPppAuth, request, options: options);
  }

  $grpc.ResponseFuture<$0.IpAddressResponse> getIpAddress(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getIpAddress, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setIpAddress(
    $0.SetIpAddressRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setIpAddress, request, options: options);
  }

  $grpc.ResponseFuture<$0.CellularDiagResponse> getCellularDiag(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCellularDiag, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setCellularField(
    $0.SetCellularFieldRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCellularField, request, options: options);
  }

  $grpc.ResponseFuture<$0.CellInfoResponse> getCellInfo(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getCellInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setCellInfoEntry(
    $0.SetCellInfoEntryRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCellInfoEntry, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetQosResponse> getQos(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getQos, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setQos(
    $0.SetQosRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setQos, request, options: options);
  }

  /// ==========================
  /// Mobile Network Identifier RPCs (P2P Setup)
  /// ==========================
  $grpc.ResponseFuture<$0.MobileNetworkIdentifiersResponse>
      getMobileNetworkIdentifiers(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMobileNetworkIdentifiers, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setImsi(
    $0.SetMniFieldRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setImsi, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setMsisdn(
    $0.SetMniFieldRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setMsisdn, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setImei(
    $0.SetMniFieldRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setImei, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setIccid(
    $0.SetMniFieldRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setIccid, request, options: options);
  }

  $grpc.ResponseFuture<$0.ModemStatusResponse> getModemStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getModemStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setModemStatus(
    $0.BoolValue request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setModemStatus, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> restartModem(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$restartModem, request, options: options);
  }

  $grpc.ResponseFuture<$0.MniRightsResponse> getMniRights(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getMniRights, request, options: options);
  }

  /// ==========================
  /// Modem Config RPCs (P2P Setup)
  /// ==========================
  $grpc.ResponseFuture<$0.ModemConfigSettingsResponse> getModemConfigSettings(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getModemConfigSettings, request,
        options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setCommSpeed(
    $0.SetCommSpeedRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setCommSpeed, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setModemProfile(
    $0.SetModemProfileRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setModemProfile, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setInitStrings(
    $0.SetInitStringsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setInitStrings, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutoConnectResponse> getAutoConnect(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAutoConnect, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setAutoConnect(
    $0.SetAutoConnectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setAutoConnect, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> modemConnect(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$modemConnect, request, options: options);
  }

  $grpc.ResponseFuture<$0.AutoAnswerResponse> getAutoAnswer(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getAutoAnswer, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setAutoAnswer(
    $0.SetAutoAnswerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setAutoAnswer, request, options: options);
  }

  $grpc.ResponseFuture<$0.TcpUdpSetupResponse> getTcpUdpSetup(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTcpUdpSetup, request, options: options);
  }

  $grpc.ResponseFuture<$0.BoolValue> setTcpUdpSetup(
    $0.SetTcpUdpSetupRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setTcpUdpSetup, request, options: options);
  }

  /// Returns a JSON map {attr_id: can_write} for a COSEM object class.
  $grpc.ResponseFuture<$0.StringValue> getObjectWriteRights(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getObjectWriteRights, request, options: options);
  }

  /// Execute script table for a given data source
  $grpc.ResponseFuture<$1.Empty> executeScriptTable(
    $0.ExecuteScriptTableRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$executeScriptTable, request, options: options);
  }

  /// ==========================
  /// Push Setup Server RPCs
  /// ==========================
  /// Start a local TCP server to receive push notifications from the meter.
  /// Streams push notifications as XML strings as they arrive.
  $grpc.ResponseStream<$0.PushNotification> startPushSetupServer(
    $0.StartPushSetupServerRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$startPushSetupServer, $async.Stream.fromIterable([request]),
        options: options);
  }

  /// Stop the running push setup server.
  $grpc.ResponseFuture<$1.Empty> stopPushSetupServer(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$stopPushSetupServer, request, options: options);
  }

  /// Send a test push notification through the push setup server.
  $grpc.ResponseFuture<$1.Empty> sendTestNotification(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendTestNotification, request, options: options);
  }

  /// Stream retry status updates from the ng_sdk communication layer.
  /// The server pushes one update per retry attempt and a final update when
  /// all attempts fail. The stream stays open until the client disconnects.
  $grpc.ResponseStream<$0.RetryStatusUpdate> watchRetryStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$watchRetryStatus, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Int32Value> getPrimaryCt(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPrimaryCt, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> setPrimaryCt(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPrimaryCt, request, options: options);
  }

  $grpc.ResponseFuture<$0.Int32Value> getSecondaryCt(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getSecondaryCt, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> setSecondaryCt(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setSecondaryCt, request, options: options);
  }

  $grpc.ResponseFuture<$0.Int32Value> getPrimaryVt(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getPrimaryVt, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> setPrimaryVt(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setPrimaryVt, request, options: options);
  }

  $grpc.ResponseFuture<$0.Int32Value> getRatioValueVt(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getRatioValueVt, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> setRatioValueVt(
    $0.Int32Value request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setRatioValueVt, request, options: options);
  }

  /// Read ImageTransfer attribute 6: image_transfer_status enum.
  $grpc.ResponseFuture<$0.ImageTransferStatusResponse> getImageTransferStatus(
    $1.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getImageTransferStatus, request,
        options: options);
  }

  /// Quality
  $grpc.ResponseFuture<$0.GetQualityObjectsResponse> getQualityObjects(
    $0.GetQualityObjectsRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getQualityObjects, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> updateQualityObject(
    $0.UpdateQualityObjectRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$updateQualityObject, request, options: options);
  }

  $grpc.ResponseFuture<$0.ReadQualityConfigResponse> readQualityConfig(
    $0.ReadQualityConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$readQualityConfig, request, options: options);
  }

  $grpc.ResponseFuture<$1.Empty> writeQualityConfig(
    $0.WriteQualityConfigRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$writeQualityConfig, request, options: options);
  }

  // method descriptors

  static final _$exportData =
      $grpc.ClientMethod<$0.ExportDataRequest, $0.ExportDataResponse>(
          '/meter.MeterService/ExportData',
          ($0.ExportDataRequest value) => value.writeToBuffer(),
          $0.ExportDataResponse.fromBuffer);
  static final _$initMeterContext =
      $grpc.ClientMethod<$0.InitMeterContextRequest, $0.BoolValue>(
          '/meter.MeterService/InitMeterContext',
          ($0.InitMeterContextRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$connect = $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
      '/meter.MeterService/Connect',
      ($1.Empty value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$disconnect = $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
      '/meter.MeterService/Disconnect',
      ($1.Empty value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$executeAdvancedGet =
      $grpc.ClientMethod<$0.GetRequestList, $0.ApplicationResponseList>(
          '/meter.MeterService/ExecuteAdvancedGet',
          ($0.GetRequestList value) => value.writeToBuffer(),
          $0.ApplicationResponseList.fromBuffer);
  static final _$executeAdvancedSet =
      $grpc.ClientMethod<$0.SetRequestList, $0.ApplicationResponseList>(
          '/meter.MeterService/ExecuteAdvancedSet',
          ($0.SetRequestList value) => value.writeToBuffer(),
          $0.ApplicationResponseList.fromBuffer);
  static final _$executeAdvancedAction =
      $grpc.ClientMethod<$0.ActionRequestList, $0.ApplicationResponseList>(
          '/meter.MeterService/ExecuteAdvancedAction',
          ($0.ActionRequestList value) => value.writeToBuffer(),
          $0.ApplicationResponseList.fromBuffer);
  static final _$executeGet =
      $grpc.ClientMethod<$0.GetRequestList, $0.FrameExecutionList>(
          '/meter.MeterService/ExecuteGet',
          ($0.GetRequestList value) => value.writeToBuffer(),
          $0.FrameExecutionList.fromBuffer);
  static final _$executeSet =
      $grpc.ClientMethod<$0.SetRequestList, $0.FrameExecutionList>(
          '/meter.MeterService/ExecuteSet',
          ($0.SetRequestList value) => value.writeToBuffer(),
          $0.FrameExecutionList.fromBuffer);
  static final _$executeAction =
      $grpc.ClientMethod<$0.ActionRequestList, $0.FrameExecutionList>(
          '/meter.MeterService/ExecuteAction',
          ($0.ActionRequestList value) => value.writeToBuffer(),
          $0.FrameExecutionList.fromBuffer);
  static final _$getBlockSize = $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
      '/meter.MeterService/GetBlockSize',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Int32Value.fromBuffer);
  static final _$setBlockSize = $grpc.ClientMethod<$0.Int32Value, $0.BoolValue>(
      '/meter.MeterService/SetBlockSize',
      ($0.Int32Value value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$enableImageTransfer =
      $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
          '/meter.MeterService/EnableImageTransfer',
          ($1.Empty value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$initiateTransfer =
      $grpc.ClientMethod<$0.InitiateTransferRequest, $0.BoolValue>(
          '/meter.MeterService/InitiateTransfer',
          ($0.InitiateTransferRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$transferFile =
      $grpc.ClientMethod<$0.TransferFileRequest, $0.TransferUpdate>(
          '/meter.MeterService/TransferFile',
          ($0.TransferFileRequest value) => value.writeToBuffer(),
          $0.TransferUpdate.fromBuffer);
  static final _$verifyTransfert =
      $grpc.ClientMethod<$0.VerifyTransfertRequest, $0.VerifyTransfertResponse>(
          '/meter.MeterService/VerifyTransfert',
          ($0.VerifyTransfertRequest value) => value.writeToBuffer(),
          $0.VerifyTransfertResponse.fromBuffer);
  static final _$resendMissingChunks =
      $grpc.ClientMethod<$0.ResendMissingChunksRequest, $0.TransferUpdate>(
          '/meter.MeterService/ResendMissingChunks',
          ($0.ResendMissingChunksRequest value) => value.writeToBuffer(),
          $0.TransferUpdate.fromBuffer);
  static final _$resumeTransfer =
      $grpc.ClientMethod<$0.ResumeTransferRequest, $0.TransferUpdate>(
          '/meter.MeterService/ResumeTransfer',
          ($0.ResumeTransferRequest value) => value.writeToBuffer(),
          $0.TransferUpdate.fromBuffer);
  static final _$activateFirmware =
      $grpc.ClientMethod<$1.Empty, $0.ActivateFirmwareResponse>(
          '/meter.MeterService/ActivateFirmware',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivateFirmwareResponse.fromBuffer);
  static final _$getDatamodelObjects = $grpc.ClientMethod<
          $0.GetDatamodelObjectsRequest, $0.GetDatamodelObjectsResponse>(
      '/meter.MeterService/GetDatamodelObjects',
      ($0.GetDatamodelObjectsRequest value) => value.writeToBuffer(),
      $0.GetDatamodelObjectsResponse.fromBuffer);
  static final _$getDatamodelAttributesByObjectName = $grpc.ClientMethod<
          $0.GetDatamodelAttributesByObjectNameRequest,
          $0.GetDatamodelAttributesByObjectNameResponse>(
      '/meter.MeterService/GetDatamodelAttributesByObjectName',
      ($0.GetDatamodelAttributesByObjectNameRequest value) =>
          value.writeToBuffer(),
      $0.GetDatamodelAttributesByObjectNameResponse.fromBuffer);
  static final _$translateData =
      $grpc.ClientMethod<$0.TranslateDataRequest, $0.TranslateDataResponse>(
          '/meter.MeterService/TranslateData',
          ($0.TranslateDataRequest value) => value.writeToBuffer(),
          $0.TranslateDataResponse.fromBuffer);
  static final _$dlmsTranslate =
      $grpc.ClientMethod<$0.DlmsTranslateRequest, $0.StringValue>(
          '/meter.MeterService/DlmsTranslate',
          ($0.DlmsTranslateRequest value) => value.writeToBuffer(),
          $0.StringValue.fromBuffer);
  static final _$getClock = $grpc.ClientMethod<$1.Empty, $0.StringValue>(
      '/meter.MeterService/GetClock',
      ($1.Empty value) => value.writeToBuffer(),
      $0.StringValue.fromBuffer);
  static final _$setClock = $grpc.ClientMethod<$0.StringValue, $0.BoolValue>(
      '/meter.MeterService/SetClock',
      ($0.StringValue value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$getDatamodels = $grpc.ClientMethod<$1.Empty, $0.StringList>(
      '/meter.MeterService/GetDatamodels',
      ($1.Empty value) => value.writeToBuffer(),
      $0.StringList.fromBuffer);
  static final _$loadDatamodel =
      $grpc.ClientMethod<$0.LoadDatamodelRequest, $0.BoolValue>(
          '/meter.MeterService/LoadDatamodel',
          ($0.LoadDatamodelRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getLoadProfile =
      $grpc.ClientMethod<$0.GetLoadProfileRequest, $0.GetLoadProfileStreamItem>(
          '/meter.MeterService/GetLoadProfile',
          ($0.GetLoadProfileRequest value) => value.writeToBuffer(),
          $0.GetLoadProfileStreamItem.fromBuffer);
  static final _$getLoadProfileParam =
      $grpc.ClientMethod<$0.GetLoadProfileParamRequest, $0.Int32Value>(
          '/meter.MeterService/GetLoadProfileParam',
          ($0.GetLoadProfileParamRequest value) => value.writeToBuffer(),
          $0.Int32Value.fromBuffer);
  static final _$setLoadProfileParam =
      $grpc.ClientMethod<$0.SetLoadProfileParamRequest, $0.BoolValue>(
          '/meter.MeterService/SetLoadProfileParam',
          ($0.SetLoadProfileParamRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getFresnelData =
      $grpc.ClientMethod<$1.Empty, $0.FresnelResponse>(
          '/meter.MeterService/GetFresnelData',
          ($1.Empty value) => value.writeToBuffer(),
          $0.FresnelResponse.fromBuffer);
  static final _$getDeviceID = $grpc.ClientMethod<$1.Empty, $0.DeviceIDList>(
      '/meter.MeterService/GetDeviceID',
      ($1.Empty value) => value.writeToBuffer(),
      $0.DeviceIDList.fromBuffer);
  static final _$getFirmwareVersion =
      $grpc.ClientMethod<$1.Empty, $0.FirmwareVersionList>(
          '/meter.MeterService/GetFirmwareVersion',
          ($1.Empty value) => value.writeToBuffer(),
          $0.FirmwareVersionList.fromBuffer);
  static final _$getImageTransfertActivationDateTime =
      $grpc.ClientMethod<$1.Empty, $0.ActivationDateTime>(
          '/meter.MeterService/GetImageTransfertActivationDateTime',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivationDateTime.fromBuffer);
  static final _$setImageTransfertActivationDateTime =
      $grpc.ClientMethod<$0.ActivationDateTime, $0.BoolValue>(
          '/meter.MeterService/SetImageTransfertActivationDateTime',
          ($0.ActivationDateTime value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getIncrementalDate =
      $grpc.ClientMethod<$1.Empty, $0.DaylightSavingsTime>(
          '/meter.MeterService/GetIncrementalDate',
          ($1.Empty value) => value.writeToBuffer(),
          $0.DaylightSavingsTime.fromBuffer);
  static final _$setIncrementalDate =
      $grpc.ClientMethod<$0.DaylightSavingsTime, $0.BoolValue>(
          '/meter.MeterService/SetIncrementalDate',
          ($0.DaylightSavingsTime value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getDecrementalDate =
      $grpc.ClientMethod<$1.Empty, $0.DaylightSavingsTime>(
          '/meter.MeterService/GetDecrementalDate',
          ($1.Empty value) => value.writeToBuffer(),
          $0.DaylightSavingsTime.fromBuffer);
  static final _$setDecrementalDate =
      $grpc.ClientMethod<$0.DaylightSavingsTime, $0.BoolValue>(
          '/meter.MeterService/SetDecrementalDate',
          ($0.DaylightSavingsTime value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getDaylightSavingDeviation =
      $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
          '/meter.MeterService/GetDaylightSavingDeviation',
          ($1.Empty value) => value.writeToBuffer(),
          $0.Int32Value.fromBuffer);
  static final _$setDaylightSavingDeviation =
      $grpc.ClientMethod<$0.Int32Value, $0.BoolValue>(
          '/meter.MeterService/SetDaylightSavingDeviation',
          ($0.Int32Value value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getDaylightSavingActivation =
      $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
          '/meter.MeterService/GetDaylightSavingActivation',
          ($1.Empty value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setDaylightSavingActivation =
      $grpc.ClientMethod<$0.BoolValue, $0.BoolValue>(
          '/meter.MeterService/SetDaylightSavingActivation',
          ($0.BoolValue value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getTimezone = $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
      '/meter.MeterService/GetTimezone',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Int32Value.fromBuffer);
  static final _$setTimezone = $grpc.ClientMethod<$0.Int32Value, $0.BoolValue>(
      '/meter.MeterService/SetTimezone',
      ($0.Int32Value value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$getEnergyRegister =
      $grpc.ClientMethod<$1.Empty, $0.EnergyRegisterList>(
          '/meter.MeterService/GetEnergyRegister',
          ($1.Empty value) => value.writeToBuffer(),
          $0.EnergyRegisterList.fromBuffer);
  static final _$getAverage = $grpc.ClientMethod<$1.Empty, $0.AverageList>(
      '/meter.MeterService/GetAverage',
      ($1.Empty value) => value.writeToBuffer(),
      $0.AverageList.fromBuffer);
  static final _$getBitStatus =
      $grpc.ClientMethod<$0.BitStatusRequest, $0.BitStatusResponse>(
          '/meter.MeterService/GetBitStatus',
          ($0.BitStatusRequest value) => value.writeToBuffer(),
          $0.BitStatusResponse.fromBuffer);
  static final _$getPushObjectList = $grpc.ClientMethod<
          $0.GetPushObjectListRequest, $0.GetPushObjectListResponse>(
      '/meter.MeterService/GetPushObjectList',
      ($0.GetPushObjectListRequest value) => value.writeToBuffer(),
      $0.GetPushObjectListResponse.fromBuffer);
  static final _$getActiveCalendar =
      $grpc.ClientMethod<$1.Empty, $0.ActivityCalendarData>(
          '/meter.MeterService/GetActiveCalendar',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivityCalendarData.fromBuffer);
  static final _$getPassiveCalendar =
      $grpc.ClientMethod<$1.Empty, $0.ActivityCalendarData>(
          '/meter.MeterService/GetPassiveCalendar',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivityCalendarData.fromBuffer);
  static final _$getPassiveDayProfiles =
      $grpc.ClientMethod<$1.Empty, $0.ActivityCalendarData>(
          '/meter.MeterService/GetPassiveDayProfiles',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivityCalendarData.fromBuffer);
  static final _$getPassiveWeekProfiles =
      $grpc.ClientMethod<$1.Empty, $0.ActivityCalendarData>(
          '/meter.MeterService/GetPassiveWeekProfiles',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivityCalendarData.fromBuffer);
  static final _$getPassiveSeasonProfiles =
      $grpc.ClientMethod<$1.Empty, $0.ActivityCalendarData>(
          '/meter.MeterService/GetPassiveSeasonProfiles',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ActivityCalendarData.fromBuffer);
  static final _$setPassiveCalendar =
      $grpc.ClientMethod<$0.ActivityCalendarData, $0.BoolValue>(
          '/meter.MeterService/SetPassiveCalendar',
          ($0.ActivityCalendarData value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getSpecialDays =
      $grpc.ClientMethod<$1.Empty, $0.SpecialDayTable>(
          '/meter.MeterService/GetSpecialDays',
          ($1.Empty value) => value.writeToBuffer(),
          $0.SpecialDayTable.fromBuffer);
  static final _$getPassiveSpecialDays =
      $grpc.ClientMethod<$1.Empty, $0.SpecialDayTable>(
          '/meter.MeterService/GetPassiveSpecialDays',
          ($1.Empty value) => value.writeToBuffer(),
          $0.SpecialDayTable.fromBuffer);
  static final _$setPassiveSpecialDays =
      $grpc.ClientMethod<$0.SpecialDayTable, $0.BoolValue>(
          '/meter.MeterService/SetPassiveSpecialDays',
          ($0.SpecialDayTable value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$activatePassiveCalendar =
      $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
          '/meter.MeterService/ActivatePassiveCalendar',
          ($1.Empty value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setPushObjectList =
      $grpc.ClientMethod<$0.SetPushObjectListRequest, $1.Empty>(
          '/meter.MeterService/SetPushObjectList',
          ($0.SetPushObjectListRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getRandomisationStartInterval = $grpc.ClientMethod<
          $0.GetRandomisationStartIntervalRequest,
          $0.GetRandomisationStartIntervalResponse>(
      '/meter.MeterService/GetRandomisationStartInterval',
      ($0.GetRandomisationStartIntervalRequest value) => value.writeToBuffer(),
      $0.GetRandomisationStartIntervalResponse.fromBuffer);
  static final _$setRandomisationStartInterval =
      $grpc.ClientMethod<$0.SetRandomisationStartIntervalRequest, $1.Empty>(
          '/meter.MeterService/SetRandomisationStartInterval',
          ($0.SetRandomisationStartIntervalRequest value) =>
              value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getNumberOfRetries = $grpc.ClientMethod<
          $0.GetNumberOfRetriesRequest, $0.GetNumberOfRetriesResponse>(
      '/meter.MeterService/GetNumberOfRetries',
      ($0.GetNumberOfRetriesRequest value) => value.writeToBuffer(),
      $0.GetNumberOfRetriesResponse.fromBuffer);
  static final _$setNumberOfRetries =
      $grpc.ClientMethod<$0.SetNumberOfRetriesRequest, $1.Empty>(
          '/meter.MeterService/SetNumberOfRetries',
          ($0.SetNumberOfRetriesRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getRepetitionDelay = $grpc.ClientMethod<
          $0.GetRepetitionDelayRequest, $0.GetRepetitionDelayResponse>(
      '/meter.MeterService/GetRepetitionDelay',
      ($0.GetRepetitionDelayRequest value) => value.writeToBuffer(),
      $0.GetRepetitionDelayResponse.fromBuffer);
  static final _$setRepetitionDelay =
      $grpc.ClientMethod<$0.SetRepetitionDelayRequest, $1.Empty>(
          '/meter.MeterService/SetRepetitionDelay',
          ($0.SetRepetitionDelayRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getLastConfirmationDatetime = $grpc.ClientMethod<
          $0.GetLastConfirmationDatetimeRequest,
          $0.GetLastConfirmationDatetimeResponse>(
      '/meter.MeterService/GetLastConfirmationDatetime',
      ($0.GetLastConfirmationDatetimeRequest value) => value.writeToBuffer(),
      $0.GetLastConfirmationDatetimeResponse.fromBuffer);
  static final _$setLastConfirmationDatetime =
      $grpc.ClientMethod<$0.SetLastConfirmationDatetimeRequest, $1.Empty>(
          '/meter.MeterService/SetLastConfirmationDatetime',
          ($0.SetLastConfirmationDatetimeRequest value) =>
              value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getSendDestination = $grpc.ClientMethod<
          $0.GetSendDestinationRequest, $0.GetSendDestinationResponse>(
      '/meter.MeterService/GetSendDestination',
      ($0.GetSendDestinationRequest value) => value.writeToBuffer(),
      $0.GetSendDestinationResponse.fromBuffer);
  static final _$setSendDestination =
      $grpc.ClientMethod<$0.SetSendDestinationRequest, $1.Empty>(
          '/meter.MeterService/SetSendDestination',
          ($0.SetSendDestinationRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getCommunicationWindow = $grpc.ClientMethod<
          $0.GetCommunicationWindowRequest, $0.GetCommunicationWindowResponse>(
      '/meter.MeterService/GetCommunicationWindow',
      ($0.GetCommunicationWindowRequest value) => value.writeToBuffer(),
      $0.GetCommunicationWindowResponse.fromBuffer);
  static final _$setCommunicationWindow =
      $grpc.ClientMethod<$0.SetCommunicationWindowRequest, $1.Empty>(
          '/meter.MeterService/SetCommunicationWindow',
          ($0.SetCommunicationWindowRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getExecutionTime =
      $grpc.ClientMethod<$0.GetExecutionTimeRequest, $0.StringList>(
          '/meter.MeterService/GetExecutionTime',
          ($0.GetExecutionTimeRequest value) => value.writeToBuffer(),
          $0.StringList.fromBuffer);
  static final _$setExecutionTime =
      $grpc.ClientMethod<$0.SetExecutionTimeRequest, $1.Empty>(
          '/meter.MeterService/SetExecutionTime',
          ($0.SetExecutionTimeRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getPushActionType =
      $grpc.ClientMethod<$0.GetPushActionTypeRequest, $0.Int32Value>(
          '/meter.MeterService/GetPushActionType',
          ($0.GetPushActionTypeRequest value) => value.writeToBuffer(),
          $0.Int32Value.fromBuffer);
  static final _$getPushActionExecutedScript = $grpc.ClientMethod<
          $0.GetPushActionExecutedScriptRequest,
          $0.GetPushActionExecutedScriptResponse>(
      '/meter.MeterService/GetPushActionExecutedScript',
      ($0.GetPushActionExecutedScriptRequest value) => value.writeToBuffer(),
      $0.GetPushActionExecutedScriptResponse.fromBuffer);
  static final _$setPushActionExecutedScript =
      $grpc.ClientMethod<$0.SetPushActionExecutedScriptRequest, $1.Empty>(
          '/meter.MeterService/SetPushActionExecutedScript',
          ($0.SetPushActionExecutedScriptRequest value) =>
              value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getScriptTable =
      $grpc.ClientMethod<$0.GetScriptTableRequest, $0.GetScriptTableResponse>(
          '/meter.MeterService/GetScriptTable',
          ($0.GetScriptTableRequest value) => value.writeToBuffer(),
          $0.GetScriptTableResponse.fromBuffer);
  static final _$getPushSelectiveCaptureObjects = $grpc.ClientMethod<
          $0.GetPushSelectiveCaptureObjectsRequest,
          $0.GetPushSelectiveCaptureObjectsResponse>(
      '/meter.MeterService/GetPushSelectiveCaptureObjects',
      ($0.GetPushSelectiveCaptureObjectsRequest value) => value.writeToBuffer(),
      $0.GetPushSelectiveCaptureObjectsResponse.fromBuffer);
  static final _$getPushRecoveryObjects = $grpc.ClientMethod<
          $0.GetPushRecoveryObjectsRequest, $0.GetPushRecoveryObjectsResponse>(
      '/meter.MeterService/GetPushRecoveryObjects',
      ($0.GetPushRecoveryObjectsRequest value) => value.writeToBuffer(),
      $0.GetPushRecoveryObjectsResponse.fromBuffer);
  static final _$pushSetupPush =
      $grpc.ClientMethod<$0.PushSetupPushRequest, $1.Empty>(
          '/meter.MeterService/PushSetupPush',
          ($0.PushSetupPushRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$pushSetupReset =
      $grpc.ClientMethod<$0.PushSetupResetRequest, $1.Empty>(
          '/meter.MeterService/PushSetupReset',
          ($0.PushSetupResetRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$getModemConfig =
      $grpc.ClientMethod<$1.Empty, $0.ModemConfigResponse>(
          '/meter.MeterService/GetModemConfig',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ModemConfigResponse.fromBuffer);
  static final _$setApn = $grpc.ClientMethod<$0.SetApnRequest, $0.BoolValue>(
      '/meter.MeterService/SetApn',
      ($0.SetApnRequest value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$setPinCode =
      $grpc.ClientMethod<$0.SetPinCodeRequest, $0.BoolValue>(
          '/meter.MeterService/SetPinCode',
          ($0.SetPinCodeRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setPppAuth =
      $grpc.ClientMethod<$0.SetPppAuthRequest, $0.BoolValue>(
          '/meter.MeterService/SetPppAuth',
          ($0.SetPppAuthRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getIpAddress =
      $grpc.ClientMethod<$1.Empty, $0.IpAddressResponse>(
          '/meter.MeterService/GetIpAddress',
          ($1.Empty value) => value.writeToBuffer(),
          $0.IpAddressResponse.fromBuffer);
  static final _$setIpAddress =
      $grpc.ClientMethod<$0.SetIpAddressRequest, $0.BoolValue>(
          '/meter.MeterService/SetIpAddress',
          ($0.SetIpAddressRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getCellularDiag =
      $grpc.ClientMethod<$1.Empty, $0.CellularDiagResponse>(
          '/meter.MeterService/GetCellularDiag',
          ($1.Empty value) => value.writeToBuffer(),
          $0.CellularDiagResponse.fromBuffer);
  static final _$setCellularField =
      $grpc.ClientMethod<$0.SetCellularFieldRequest, $0.BoolValue>(
          '/meter.MeterService/SetCellularField',
          ($0.SetCellularFieldRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getCellInfo =
      $grpc.ClientMethod<$1.Empty, $0.CellInfoResponse>(
          '/meter.MeterService/GetCellInfo',
          ($1.Empty value) => value.writeToBuffer(),
          $0.CellInfoResponse.fromBuffer);
  static final _$setCellInfoEntry =
      $grpc.ClientMethod<$0.SetCellInfoEntryRequest, $0.BoolValue>(
          '/meter.MeterService/SetCellInfoEntry',
          ($0.SetCellInfoEntryRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getQos = $grpc.ClientMethod<$1.Empty, $0.GetQosResponse>(
      '/meter.MeterService/GetQos',
      ($1.Empty value) => value.writeToBuffer(),
      $0.GetQosResponse.fromBuffer);
  static final _$setQos = $grpc.ClientMethod<$0.SetQosRequest, $0.BoolValue>(
      '/meter.MeterService/SetQos',
      ($0.SetQosRequest value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$getMobileNetworkIdentifiers =
      $grpc.ClientMethod<$1.Empty, $0.MobileNetworkIdentifiersResponse>(
          '/meter.MeterService/GetMobileNetworkIdentifiers',
          ($1.Empty value) => value.writeToBuffer(),
          $0.MobileNetworkIdentifiersResponse.fromBuffer);
  static final _$setImsi =
      $grpc.ClientMethod<$0.SetMniFieldRequest, $0.BoolValue>(
          '/meter.MeterService/SetImsi',
          ($0.SetMniFieldRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setMsisdn =
      $grpc.ClientMethod<$0.SetMniFieldRequest, $0.BoolValue>(
          '/meter.MeterService/SetMsisdn',
          ($0.SetMniFieldRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setImei =
      $grpc.ClientMethod<$0.SetMniFieldRequest, $0.BoolValue>(
          '/meter.MeterService/SetImei',
          ($0.SetMniFieldRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setIccid =
      $grpc.ClientMethod<$0.SetMniFieldRequest, $0.BoolValue>(
          '/meter.MeterService/SetIccid',
          ($0.SetMniFieldRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getModemStatus =
      $grpc.ClientMethod<$1.Empty, $0.ModemStatusResponse>(
          '/meter.MeterService/GetModemStatus',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ModemStatusResponse.fromBuffer);
  static final _$setModemStatus =
      $grpc.ClientMethod<$0.BoolValue, $0.BoolValue>(
          '/meter.MeterService/SetModemStatus',
          ($0.BoolValue value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$restartModem = $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
      '/meter.MeterService/RestartModem',
      ($1.Empty value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$getMniRights =
      $grpc.ClientMethod<$1.Empty, $0.MniRightsResponse>(
          '/meter.MeterService/GetMniRights',
          ($1.Empty value) => value.writeToBuffer(),
          $0.MniRightsResponse.fromBuffer);
  static final _$getModemConfigSettings =
      $grpc.ClientMethod<$1.Empty, $0.ModemConfigSettingsResponse>(
          '/meter.MeterService/GetModemConfigSettings',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ModemConfigSettingsResponse.fromBuffer);
  static final _$setCommSpeed =
      $grpc.ClientMethod<$0.SetCommSpeedRequest, $0.BoolValue>(
          '/meter.MeterService/SetCommSpeed',
          ($0.SetCommSpeedRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setModemProfile =
      $grpc.ClientMethod<$0.SetModemProfileRequest, $0.BoolValue>(
          '/meter.MeterService/SetModemProfile',
          ($0.SetModemProfileRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$setInitStrings =
      $grpc.ClientMethod<$0.SetInitStringsRequest, $0.BoolValue>(
          '/meter.MeterService/SetInitStrings',
          ($0.SetInitStringsRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getAutoConnect =
      $grpc.ClientMethod<$1.Empty, $0.AutoConnectResponse>(
          '/meter.MeterService/GetAutoConnect',
          ($1.Empty value) => value.writeToBuffer(),
          $0.AutoConnectResponse.fromBuffer);
  static final _$setAutoConnect =
      $grpc.ClientMethod<$0.SetAutoConnectRequest, $0.BoolValue>(
          '/meter.MeterService/SetAutoConnect',
          ($0.SetAutoConnectRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$modemConnect = $grpc.ClientMethod<$1.Empty, $0.BoolValue>(
      '/meter.MeterService/ModemConnect',
      ($1.Empty value) => value.writeToBuffer(),
      $0.BoolValue.fromBuffer);
  static final _$getAutoAnswer =
      $grpc.ClientMethod<$1.Empty, $0.AutoAnswerResponse>(
          '/meter.MeterService/GetAutoAnswer',
          ($1.Empty value) => value.writeToBuffer(),
          $0.AutoAnswerResponse.fromBuffer);
  static final _$setAutoAnswer =
      $grpc.ClientMethod<$0.SetAutoAnswerRequest, $0.BoolValue>(
          '/meter.MeterService/SetAutoAnswer',
          ($0.SetAutoAnswerRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getTcpUdpSetup =
      $grpc.ClientMethod<$1.Empty, $0.TcpUdpSetupResponse>(
          '/meter.MeterService/GetTcpUdpSetup',
          ($1.Empty value) => value.writeToBuffer(),
          $0.TcpUdpSetupResponse.fromBuffer);
  static final _$setTcpUdpSetup =
      $grpc.ClientMethod<$0.SetTcpUdpSetupRequest, $0.BoolValue>(
          '/meter.MeterService/SetTcpUdpSetup',
          ($0.SetTcpUdpSetupRequest value) => value.writeToBuffer(),
          $0.BoolValue.fromBuffer);
  static final _$getObjectWriteRights =
      $grpc.ClientMethod<$0.Int32Value, $0.StringValue>(
          '/meter.MeterService/GetObjectWriteRights',
          ($0.Int32Value value) => value.writeToBuffer(),
          $0.StringValue.fromBuffer);
  static final _$executeScriptTable =
      $grpc.ClientMethod<$0.ExecuteScriptTableRequest, $1.Empty>(
          '/meter.MeterService/ExecuteScriptTable',
          ($0.ExecuteScriptTableRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$startPushSetupServer =
      $grpc.ClientMethod<$0.StartPushSetupServerRequest, $0.PushNotification>(
          '/meter.MeterService/StartPushSetupServer',
          ($0.StartPushSetupServerRequest value) => value.writeToBuffer(),
          $0.PushNotification.fromBuffer);
  static final _$stopPushSetupServer = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/meter.MeterService/StopPushSetupServer',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$sendTestNotification = $grpc.ClientMethod<$1.Empty, $1.Empty>(
      '/meter.MeterService/SendTestNotification',
      ($1.Empty value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$watchRetryStatus =
      $grpc.ClientMethod<$1.Empty, $0.RetryStatusUpdate>(
          '/meter.MeterService/WatchRetryStatus',
          ($1.Empty value) => value.writeToBuffer(),
          $0.RetryStatusUpdate.fromBuffer);
  static final _$getPrimaryCt = $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
      '/meter.MeterService/GetPrimaryCt',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Int32Value.fromBuffer);
  static final _$setPrimaryCt = $grpc.ClientMethod<$0.Int32Value, $1.Empty>(
      '/meter.MeterService/SetPrimaryCt',
      ($0.Int32Value value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getSecondaryCt = $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
      '/meter.MeterService/GetSecondaryCt',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Int32Value.fromBuffer);
  static final _$setSecondaryCt = $grpc.ClientMethod<$0.Int32Value, $1.Empty>(
      '/meter.MeterService/SetSecondaryCt',
      ($0.Int32Value value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getPrimaryVt = $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
      '/meter.MeterService/GetPrimaryVt',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Int32Value.fromBuffer);
  static final _$setPrimaryVt = $grpc.ClientMethod<$0.Int32Value, $1.Empty>(
      '/meter.MeterService/SetPrimaryVt',
      ($0.Int32Value value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getRatioValueVt = $grpc.ClientMethod<$1.Empty, $0.Int32Value>(
      '/meter.MeterService/GetRatioValueVt',
      ($1.Empty value) => value.writeToBuffer(),
      $0.Int32Value.fromBuffer);
  static final _$setRatioValueVt = $grpc.ClientMethod<$0.Int32Value, $1.Empty>(
      '/meter.MeterService/SetRatioValueVt',
      ($0.Int32Value value) => value.writeToBuffer(),
      $1.Empty.fromBuffer);
  static final _$getImageTransferStatus =
      $grpc.ClientMethod<$1.Empty, $0.ImageTransferStatusResponse>(
          '/meter.MeterService/GetImageTransferStatus',
          ($1.Empty value) => value.writeToBuffer(),
          $0.ImageTransferStatusResponse.fromBuffer);
  static final _$getQualityObjects = $grpc.ClientMethod<
          $0.GetQualityObjectsRequest, $0.GetQualityObjectsResponse>(
      '/meter.MeterService/GetQualityObjects',
      ($0.GetQualityObjectsRequest value) => value.writeToBuffer(),
      $0.GetQualityObjectsResponse.fromBuffer);
  static final _$updateQualityObject =
      $grpc.ClientMethod<$0.UpdateQualityObjectRequest, $1.Empty>(
          '/meter.MeterService/UpdateQualityObject',
          ($0.UpdateQualityObjectRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
  static final _$readQualityConfig = $grpc.ClientMethod<
          $0.ReadQualityConfigRequest, $0.ReadQualityConfigResponse>(
      '/meter.MeterService/ReadQualityConfig',
      ($0.ReadQualityConfigRequest value) => value.writeToBuffer(),
      $0.ReadQualityConfigResponse.fromBuffer);
  static final _$writeQualityConfig =
      $grpc.ClientMethod<$0.WriteQualityConfigRequest, $1.Empty>(
          '/meter.MeterService/WriteQualityConfig',
          ($0.WriteQualityConfigRequest value) => value.writeToBuffer(),
          $1.Empty.fromBuffer);
}

@$pb.GrpcServiceName('meter.MeterService')
abstract class MeterServiceBase extends $grpc.Service {
  $core.String get $name => 'meter.MeterService';

  MeterServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ExportDataRequest, $0.ExportDataResponse>(
        'ExportData',
        exportData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ExportDataRequest.fromBuffer(value),
        ($0.ExportDataResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InitMeterContextRequest, $0.BoolValue>(
        'InitMeterContext',
        initMeterContext_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InitMeterContextRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'Connect',
        connect_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'Disconnect',
        disconnect_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetRequestList, $0.ApplicationResponseList>(
            'ExecuteAdvancedGet',
            executeAdvancedGet_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetRequestList.fromBuffer(value),
            ($0.ApplicationResponseList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetRequestList, $0.ApplicationResponseList>(
            'ExecuteAdvancedSet',
            executeAdvancedSet_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetRequestList.fromBuffer(value),
            ($0.ApplicationResponseList value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ActionRequestList, $0.ApplicationResponseList>(
            'ExecuteAdvancedAction',
            executeAdvancedAction_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.ActionRequestList.fromBuffer(value),
            ($0.ApplicationResponseList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRequestList, $0.FrameExecutionList>(
        'ExecuteGet',
        executeGet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetRequestList.fromBuffer(value),
        ($0.FrameExecutionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetRequestList, $0.FrameExecutionList>(
        'ExecuteSet',
        executeSet_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetRequestList.fromBuffer(value),
        ($0.FrameExecutionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ActionRequestList, $0.FrameExecutionList>(
        'ExecuteAction',
        executeAction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ActionRequestList.fromBuffer(value),
        ($0.FrameExecutionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetBlockSize',
        getBlockSize_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $0.BoolValue>(
        'SetBlockSize',
        setBlockSize_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'EnableImageTransfer',
        enableImageTransfer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.InitiateTransferRequest, $0.BoolValue>(
        'InitiateTransfer',
        initiateTransfer_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.InitiateTransferRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TransferFileRequest, $0.TransferUpdate>(
        'TransferFile',
        transferFile_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.TransferFileRequest.fromBuffer(value),
        ($0.TransferUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VerifyTransfertRequest,
            $0.VerifyTransfertResponse>(
        'VerifyTransfert',
        verifyTransfert_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.VerifyTransfertRequest.fromBuffer(value),
        ($0.VerifyTransfertResponse value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.ResendMissingChunksRequest, $0.TransferUpdate>(
            'ResendMissingChunks',
            resendMissingChunks_Pre,
            false,
            true,
            ($core.List<$core.int> value) =>
                $0.ResendMissingChunksRequest.fromBuffer(value),
            ($0.TransferUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ResumeTransferRequest, $0.TransferUpdate>(
        'ResumeTransfer',
        resumeTransfer_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.ResumeTransferRequest.fromBuffer(value),
        ($0.TransferUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivateFirmwareResponse>(
        'ActivateFirmware',
        activateFirmware_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivateFirmwareResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDatamodelObjectsRequest,
            $0.GetDatamodelObjectsResponse>(
        'GetDatamodelObjects',
        getDatamodelObjects_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDatamodelObjectsRequest.fromBuffer(value),
        ($0.GetDatamodelObjectsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDatamodelAttributesByObjectNameRequest,
            $0.GetDatamodelAttributesByObjectNameResponse>(
        'GetDatamodelAttributesByObjectName',
        getDatamodelAttributesByObjectName_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetDatamodelAttributesByObjectNameRequest.fromBuffer(value),
        ($0.GetDatamodelAttributesByObjectNameResponse value) =>
            value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.TranslateDataRequest, $0.TranslateDataResponse>(
            'TranslateData',
            translateData_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.TranslateDataRequest.fromBuffer(value),
            ($0.TranslateDataResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DlmsTranslateRequest, $0.StringValue>(
        'DlmsTranslate',
        dlmsTranslate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DlmsTranslateRequest.fromBuffer(value),
        ($0.StringValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.StringValue>(
        'GetClock',
        getClock_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.StringValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StringValue, $0.BoolValue>(
        'SetClock',
        setClock_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.StringValue.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.StringList>(
        'GetDatamodels',
        getDatamodels_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.StringList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.LoadDatamodelRequest, $0.BoolValue>(
        'LoadDatamodel',
        loadDatamodel_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.LoadDatamodelRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetLoadProfileRequest,
            $0.GetLoadProfileStreamItem>(
        'GetLoadProfile',
        getLoadProfile_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.GetLoadProfileRequest.fromBuffer(value),
        ($0.GetLoadProfileStreamItem value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.GetLoadProfileParamRequest, $0.Int32Value>(
            'GetLoadProfileParam',
            getLoadProfileParam_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.GetLoadProfileParamRequest.fromBuffer(value),
            ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetLoadProfileParamRequest, $0.BoolValue>(
        'SetLoadProfileParam',
        setLoadProfileParam_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetLoadProfileParamRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.FresnelResponse>(
        'GetFresnelData',
        getFresnelData_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.FresnelResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.DeviceIDList>(
        'GetDeviceID',
        getDeviceID_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.DeviceIDList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.FirmwareVersionList>(
        'GetFirmwareVersion',
        getFirmwareVersion_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.FirmwareVersionList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivationDateTime>(
        'GetImageTransfertActivationDateTime',
        getImageTransfertActivationDateTime_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivationDateTime value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ActivationDateTime, $0.BoolValue>(
        'SetImageTransfertActivationDateTime',
        setImageTransfertActivationDateTime_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ActivationDateTime.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.DaylightSavingsTime>(
        'GetIncrementalDate',
        getIncrementalDate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.DaylightSavingsTime value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DaylightSavingsTime, $0.BoolValue>(
        'SetIncrementalDate',
        setIncrementalDate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DaylightSavingsTime.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.DaylightSavingsTime>(
        'GetDecrementalDate',
        getDecrementalDate_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.DaylightSavingsTime value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DaylightSavingsTime, $0.BoolValue>(
        'SetDecrementalDate',
        setDecrementalDate_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.DaylightSavingsTime.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetDaylightSavingDeviation',
        getDaylightSavingDeviation_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $0.BoolValue>(
        'SetDaylightSavingDeviation',
        setDaylightSavingDeviation_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'GetDaylightSavingActivation',
        getDaylightSavingActivation_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BoolValue, $0.BoolValue>(
        'SetDaylightSavingActivation',
        setDaylightSavingActivation_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BoolValue.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetTimezone',
        getTimezone_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $0.BoolValue>(
        'SetTimezone',
        setTimezone_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.EnergyRegisterList>(
        'GetEnergyRegister',
        getEnergyRegister_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.EnergyRegisterList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.AverageList>(
        'GetAverage',
        getAverage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.AverageList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BitStatusRequest, $0.BitStatusResponse>(
        'GetBitStatus',
        getBitStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BitStatusRequest.fromBuffer(value),
        ($0.BitStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPushObjectListRequest,
            $0.GetPushObjectListResponse>(
        'GetPushObjectList',
        getPushObjectList_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetPushObjectListRequest.fromBuffer(value),
        ($0.GetPushObjectListResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivityCalendarData>(
        'GetActiveCalendar',
        getActiveCalendar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivityCalendarData value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivityCalendarData>(
        'GetPassiveCalendar',
        getPassiveCalendar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivityCalendarData value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivityCalendarData>(
        'GetPassiveDayProfiles',
        getPassiveDayProfiles_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivityCalendarData value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivityCalendarData>(
        'GetPassiveWeekProfiles',
        getPassiveWeekProfiles_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivityCalendarData value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ActivityCalendarData>(
        'GetPassiveSeasonProfiles',
        getPassiveSeasonProfiles_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ActivityCalendarData value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ActivityCalendarData, $0.BoolValue>(
        'SetPassiveCalendar',
        setPassiveCalendar_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ActivityCalendarData.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.SpecialDayTable>(
        'GetSpecialDays',
        getSpecialDays_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.SpecialDayTable value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.SpecialDayTable>(
        'GetPassiveSpecialDays',
        getPassiveSpecialDays_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.SpecialDayTable value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SpecialDayTable, $0.BoolValue>(
        'SetPassiveSpecialDays',
        setPassiveSpecialDays_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SpecialDayTable.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'ActivatePassiveCalendar',
        activatePassiveCalendar_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetPushObjectListRequest, $1.Empty>(
        'SetPushObjectList',
        setPushObjectList_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetPushObjectListRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRandomisationStartIntervalRequest,
            $0.GetRandomisationStartIntervalResponse>(
        'GetRandomisationStartInterval',
        getRandomisationStartInterval_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetRandomisationStartIntervalRequest.fromBuffer(value),
        ($0.GetRandomisationStartIntervalResponse value) =>
            value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetRandomisationStartIntervalRequest, $1.Empty>(
            'SetRandomisationStartInterval',
            setRandomisationStartInterval_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetRandomisationStartIntervalRequest.fromBuffer(value),
            ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNumberOfRetriesRequest,
            $0.GetNumberOfRetriesResponse>(
        'GetNumberOfRetries',
        getNumberOfRetries_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetNumberOfRetriesRequest.fromBuffer(value),
        ($0.GetNumberOfRetriesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetNumberOfRetriesRequest, $1.Empty>(
        'SetNumberOfRetries',
        setNumberOfRetries_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetNumberOfRetriesRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRepetitionDelayRequest,
            $0.GetRepetitionDelayResponse>(
        'GetRepetitionDelay',
        getRepetitionDelay_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetRepetitionDelayRequest.fromBuffer(value),
        ($0.GetRepetitionDelayResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetRepetitionDelayRequest, $1.Empty>(
        'SetRepetitionDelay',
        setRepetitionDelay_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetRepetitionDelayRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetLastConfirmationDatetimeRequest,
            $0.GetLastConfirmationDatetimeResponse>(
        'GetLastConfirmationDatetime',
        getLastConfirmationDatetime_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetLastConfirmationDatetimeRequest.fromBuffer(value),
        ($0.GetLastConfirmationDatetimeResponse value) =>
            value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetLastConfirmationDatetimeRequest, $1.Empty>(
            'SetLastConfirmationDatetime',
            setLastConfirmationDatetime_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetLastConfirmationDatetimeRequest.fromBuffer(value),
            ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetSendDestinationRequest,
            $0.GetSendDestinationResponse>(
        'GetSendDestination',
        getSendDestination_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetSendDestinationRequest.fromBuffer(value),
        ($0.GetSendDestinationResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetSendDestinationRequest, $1.Empty>(
        'SetSendDestination',
        setSendDestination_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetSendDestinationRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetCommunicationWindowRequest,
            $0.GetCommunicationWindowResponse>(
        'GetCommunicationWindow',
        getCommunicationWindow_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetCommunicationWindowRequest.fromBuffer(value),
        ($0.GetCommunicationWindowResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetCommunicationWindowRequest, $1.Empty>(
        'SetCommunicationWindow',
        setCommunicationWindow_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetCommunicationWindowRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetExecutionTimeRequest, $0.StringList>(
        'GetExecutionTime',
        getExecutionTime_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetExecutionTimeRequest.fromBuffer(value),
        ($0.StringList value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetExecutionTimeRequest, $1.Empty>(
        'SetExecutionTime',
        setExecutionTime_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetExecutionTimeRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPushActionTypeRequest, $0.Int32Value>(
        'GetPushActionType',
        getPushActionType_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetPushActionTypeRequest.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPushActionExecutedScriptRequest,
            $0.GetPushActionExecutedScriptResponse>(
        'GetPushActionExecutedScript',
        getPushActionExecutedScript_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetPushActionExecutedScriptRequest.fromBuffer(value),
        ($0.GetPushActionExecutedScriptResponse value) =>
            value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$0.SetPushActionExecutedScriptRequest, $1.Empty>(
            'SetPushActionExecutedScript',
            setPushActionExecutedScript_Pre,
            false,
            false,
            ($core.List<$core.int> value) =>
                $0.SetPushActionExecutedScriptRequest.fromBuffer(value),
            ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetScriptTableRequest,
            $0.GetScriptTableResponse>(
        'GetScriptTable',
        getScriptTable_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetScriptTableRequest.fromBuffer(value),
        ($0.GetScriptTableResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPushSelectiveCaptureObjectsRequest,
            $0.GetPushSelectiveCaptureObjectsResponse>(
        'GetPushSelectiveCaptureObjects',
        getPushSelectiveCaptureObjects_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetPushSelectiveCaptureObjectsRequest.fromBuffer(value),
        ($0.GetPushSelectiveCaptureObjectsResponse value) =>
            value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetPushRecoveryObjectsRequest,
            $0.GetPushRecoveryObjectsResponse>(
        'GetPushRecoveryObjects',
        getPushRecoveryObjects_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetPushRecoveryObjectsRequest.fromBuffer(value),
        ($0.GetPushRecoveryObjectsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PushSetupPushRequest, $1.Empty>(
        'PushSetupPush',
        pushSetupPush_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PushSetupPushRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PushSetupResetRequest, $1.Empty>(
        'PushSetupReset',
        pushSetupReset_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.PushSetupResetRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ModemConfigResponse>(
        'GetModemConfig',
        getModemConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ModemConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetApnRequest, $0.BoolValue>(
        'SetApn',
        setApn_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetApnRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetPinCodeRequest, $0.BoolValue>(
        'SetPinCode',
        setPinCode_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetPinCodeRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetPppAuthRequest, $0.BoolValue>(
        'SetPppAuth',
        setPppAuth_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetPppAuthRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.IpAddressResponse>(
        'GetIpAddress',
        getIpAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.IpAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetIpAddressRequest, $0.BoolValue>(
        'SetIpAddress',
        setIpAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetIpAddressRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.CellularDiagResponse>(
        'GetCellularDiag',
        getCellularDiag_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.CellularDiagResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetCellularFieldRequest, $0.BoolValue>(
        'SetCellularField',
        setCellularField_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetCellularFieldRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.CellInfoResponse>(
        'GetCellInfo',
        getCellInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.CellInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetCellInfoEntryRequest, $0.BoolValue>(
        'SetCellInfoEntry',
        setCellInfoEntry_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetCellInfoEntryRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.GetQosResponse>(
        'GetQos',
        getQos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.GetQosResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetQosRequest, $0.BoolValue>(
        'SetQos',
        setQos_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SetQosRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod(
        $grpc.ServiceMethod<$1.Empty, $0.MobileNetworkIdentifiersResponse>(
            'GetMobileNetworkIdentifiers',
            getMobileNetworkIdentifiers_Pre,
            false,
            false,
            ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
            ($0.MobileNetworkIdentifiersResponse value) =>
                value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetMniFieldRequest, $0.BoolValue>(
        'SetImsi',
        setImsi_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetMniFieldRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetMniFieldRequest, $0.BoolValue>(
        'SetMsisdn',
        setMsisdn_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetMniFieldRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetMniFieldRequest, $0.BoolValue>(
        'SetImei',
        setImei_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetMniFieldRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetMniFieldRequest, $0.BoolValue>(
        'SetIccid',
        setIccid_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetMniFieldRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ModemStatusResponse>(
        'GetModemStatus',
        getModemStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ModemStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BoolValue, $0.BoolValue>(
        'SetModemStatus',
        setModemStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BoolValue.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'RestartModem',
        restartModem_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.MniRightsResponse>(
        'GetMniRights',
        getMniRights_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.MniRightsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ModemConfigSettingsResponse>(
        'GetModemConfigSettings',
        getModemConfigSettings_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ModemConfigSettingsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetCommSpeedRequest, $0.BoolValue>(
        'SetCommSpeed',
        setCommSpeed_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetCommSpeedRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetModemProfileRequest, $0.BoolValue>(
        'SetModemProfile',
        setModemProfile_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetModemProfileRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetInitStringsRequest, $0.BoolValue>(
        'SetInitStrings',
        setInitStrings_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetInitStringsRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.AutoConnectResponse>(
        'GetAutoConnect',
        getAutoConnect_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.AutoConnectResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetAutoConnectRequest, $0.BoolValue>(
        'SetAutoConnect',
        setAutoConnect_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetAutoConnectRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.BoolValue>(
        'ModemConnect',
        modemConnect_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.AutoAnswerResponse>(
        'GetAutoAnswer',
        getAutoAnswer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.AutoAnswerResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetAutoAnswerRequest, $0.BoolValue>(
        'SetAutoAnswer',
        setAutoAnswer_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetAutoAnswerRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.TcpUdpSetupResponse>(
        'GetTcpUdpSetup',
        getTcpUdpSetup_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.TcpUdpSetupResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SetTcpUdpSetupRequest, $0.BoolValue>(
        'SetTcpUdpSetup',
        setTcpUdpSetup_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.SetTcpUdpSetupRequest.fromBuffer(value),
        ($0.BoolValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $0.StringValue>(
        'GetObjectWriteRights',
        getObjectWriteRights_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($0.StringValue value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ExecuteScriptTableRequest, $1.Empty>(
        'ExecuteScriptTable',
        executeScriptTable_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ExecuteScriptTableRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.StartPushSetupServerRequest,
            $0.PushNotification>(
        'StartPushSetupServer',
        startPushSetupServer_Pre,
        false,
        true,
        ($core.List<$core.int> value) =>
            $0.StartPushSetupServerRequest.fromBuffer(value),
        ($0.PushNotification value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'StopPushSetupServer',
        stopPushSetupServer_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $1.Empty>(
        'SendTestNotification',
        sendTestNotification_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.RetryStatusUpdate>(
        'WatchRetryStatus',
        watchRetryStatus_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.RetryStatusUpdate value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetPrimaryCt',
        getPrimaryCt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $1.Empty>(
        'SetPrimaryCt',
        setPrimaryCt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetSecondaryCt',
        getSecondaryCt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $1.Empty>(
        'SetSecondaryCt',
        setSecondaryCt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetPrimaryVt',
        getPrimaryVt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $1.Empty>(
        'SetPrimaryVt',
        setPrimaryVt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.Int32Value>(
        'GetRatioValueVt',
        getRatioValueVt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.Int32Value value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Int32Value, $1.Empty>(
        'SetRatioValueVt',
        setRatioValueVt_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Int32Value.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$1.Empty, $0.ImageTransferStatusResponse>(
        'GetImageTransferStatus',
        getImageTransferStatus_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $1.Empty.fromBuffer(value),
        ($0.ImageTransferStatusResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetQualityObjectsRequest,
            $0.GetQualityObjectsResponse>(
        'GetQualityObjects',
        getQualityObjects_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.GetQualityObjectsRequest.fromBuffer(value),
        ($0.GetQualityObjectsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UpdateQualityObjectRequest, $1.Empty>(
        'UpdateQualityObject',
        updateQualityObject_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.UpdateQualityObjectRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ReadQualityConfigRequest,
            $0.ReadQualityConfigResponse>(
        'ReadQualityConfig',
        readQualityConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.ReadQualityConfigRequest.fromBuffer(value),
        ($0.ReadQualityConfigResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.WriteQualityConfigRequest, $1.Empty>(
        'WriteQualityConfig',
        writeQualityConfig_Pre,
        false,
        false,
        ($core.List<$core.int> value) =>
            $0.WriteQualityConfigRequest.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.ExportDataResponse> exportData_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExportDataRequest> $request) async {
    return exportData($call, await $request);
  }

  $async.Future<$0.ExportDataResponse> exportData(
      $grpc.ServiceCall call, $0.ExportDataRequest request);

  $async.Future<$0.BoolValue> initMeterContext_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InitMeterContextRequest> $request) async {
    return initMeterContext($call, await $request);
  }

  $async.Future<$0.BoolValue> initMeterContext(
      $grpc.ServiceCall call, $0.InitMeterContextRequest request);

  $async.Future<$0.BoolValue> connect_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return connect($call, await $request);
  }

  $async.Future<$0.BoolValue> connect($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> disconnect_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return disconnect($call, await $request);
  }

  $async.Future<$0.BoolValue> disconnect(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ApplicationResponseList> executeAdvancedGet_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetRequestList> $request) async {
    return executeAdvancedGet($call, await $request);
  }

  $async.Future<$0.ApplicationResponseList> executeAdvancedGet(
      $grpc.ServiceCall call, $0.GetRequestList request);

  $async.Future<$0.ApplicationResponseList> executeAdvancedSet_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetRequestList> $request) async {
    return executeAdvancedSet($call, await $request);
  }

  $async.Future<$0.ApplicationResponseList> executeAdvancedSet(
      $grpc.ServiceCall call, $0.SetRequestList request);

  $async.Future<$0.ApplicationResponseList> executeAdvancedAction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ActionRequestList> $request) async {
    return executeAdvancedAction($call, await $request);
  }

  $async.Future<$0.ApplicationResponseList> executeAdvancedAction(
      $grpc.ServiceCall call, $0.ActionRequestList request);

  $async.Future<$0.FrameExecutionList> executeGet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetRequestList> $request) async {
    return executeGet($call, await $request);
  }

  $async.Future<$0.FrameExecutionList> executeGet(
      $grpc.ServiceCall call, $0.GetRequestList request);

  $async.Future<$0.FrameExecutionList> executeSet_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetRequestList> $request) async {
    return executeSet($call, await $request);
  }

  $async.Future<$0.FrameExecutionList> executeSet(
      $grpc.ServiceCall call, $0.SetRequestList request);

  $async.Future<$0.FrameExecutionList> executeAction_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ActionRequestList> $request) async {
    return executeAction($call, await $request);
  }

  $async.Future<$0.FrameExecutionList> executeAction(
      $grpc.ServiceCall call, $0.ActionRequestList request);

  $async.Future<$0.Int32Value> getBlockSize_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getBlockSize($call, await $request);
  }

  $async.Future<$0.Int32Value> getBlockSize(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setBlockSize_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setBlockSize($call, await $request);
  }

  $async.Future<$0.BoolValue> setBlockSize(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.BoolValue> enableImageTransfer_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return enableImageTransfer($call, await $request);
  }

  $async.Future<$0.BoolValue> enableImageTransfer(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> initiateTransfer_Pre($grpc.ServiceCall $call,
      $async.Future<$0.InitiateTransferRequest> $request) async {
    return initiateTransfer($call, await $request);
  }

  $async.Future<$0.BoolValue> initiateTransfer(
      $grpc.ServiceCall call, $0.InitiateTransferRequest request);

  $async.Stream<$0.TransferUpdate> transferFile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TransferFileRequest> $request) async* {
    yield* transferFile($call, await $request);
  }

  $async.Stream<$0.TransferUpdate> transferFile(
      $grpc.ServiceCall call, $0.TransferFileRequest request);

  $async.Future<$0.VerifyTransfertResponse> verifyTransfert_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.VerifyTransfertRequest> $request) async {
    return verifyTransfert($call, await $request);
  }

  $async.Future<$0.VerifyTransfertResponse> verifyTransfert(
      $grpc.ServiceCall call, $0.VerifyTransfertRequest request);

  $async.Stream<$0.TransferUpdate> resendMissingChunks_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ResendMissingChunksRequest> $request) async* {
    yield* resendMissingChunks($call, await $request);
  }

  $async.Stream<$0.TransferUpdate> resendMissingChunks(
      $grpc.ServiceCall call, $0.ResendMissingChunksRequest request);

  $async.Stream<$0.TransferUpdate> resumeTransfer_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ResumeTransferRequest> $request) async* {
    yield* resumeTransfer($call, await $request);
  }

  $async.Stream<$0.TransferUpdate> resumeTransfer(
      $grpc.ServiceCall call, $0.ResumeTransferRequest request);

  $async.Future<$0.ActivateFirmwareResponse> activateFirmware_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return activateFirmware($call, await $request);
  }

  $async.Future<$0.ActivateFirmwareResponse> activateFirmware(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.GetDatamodelObjectsResponse> getDatamodelObjects_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetDatamodelObjectsRequest> $request) async {
    return getDatamodelObjects($call, await $request);
  }

  $async.Future<$0.GetDatamodelObjectsResponse> getDatamodelObjects(
      $grpc.ServiceCall call, $0.GetDatamodelObjectsRequest request);

  $async.Future<$0.GetDatamodelAttributesByObjectNameResponse>
      getDatamodelAttributesByObjectName_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.GetDatamodelAttributesByObjectNameRequest>
              $request) async {
    return getDatamodelAttributesByObjectName($call, await $request);
  }

  $async.Future<$0.GetDatamodelAttributesByObjectNameResponse>
      getDatamodelAttributesByObjectName($grpc.ServiceCall call,
          $0.GetDatamodelAttributesByObjectNameRequest request);

  $async.Future<$0.TranslateDataResponse> translateData_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.TranslateDataRequest> $request) async {
    return translateData($call, await $request);
  }

  $async.Future<$0.TranslateDataResponse> translateData(
      $grpc.ServiceCall call, $0.TranslateDataRequest request);

  $async.Future<$0.StringValue> dlmsTranslate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DlmsTranslateRequest> $request) async {
    return dlmsTranslate($call, await $request);
  }

  $async.Future<$0.StringValue> dlmsTranslate(
      $grpc.ServiceCall call, $0.DlmsTranslateRequest request);

  $async.Future<$0.StringValue> getClock_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getClock($call, await $request);
  }

  $async.Future<$0.StringValue> getClock(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setClock_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.StringValue> $request) async {
    return setClock($call, await $request);
  }

  $async.Future<$0.BoolValue> setClock(
      $grpc.ServiceCall call, $0.StringValue request);

  $async.Future<$0.StringList> getDatamodels_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getDatamodels($call, await $request);
  }

  $async.Future<$0.StringList> getDatamodels(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> loadDatamodel_Pre($grpc.ServiceCall $call,
      $async.Future<$0.LoadDatamodelRequest> $request) async {
    return loadDatamodel($call, await $request);
  }

  $async.Future<$0.BoolValue> loadDatamodel(
      $grpc.ServiceCall call, $0.LoadDatamodelRequest request);

  $async.Stream<$0.GetLoadProfileStreamItem> getLoadProfile_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetLoadProfileRequest> $request) async* {
    yield* getLoadProfile($call, await $request);
  }

  $async.Stream<$0.GetLoadProfileStreamItem> getLoadProfile(
      $grpc.ServiceCall call, $0.GetLoadProfileRequest request);

  $async.Future<$0.Int32Value> getLoadProfileParam_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetLoadProfileParamRequest> $request) async {
    return getLoadProfileParam($call, await $request);
  }

  $async.Future<$0.Int32Value> getLoadProfileParam(
      $grpc.ServiceCall call, $0.GetLoadProfileParamRequest request);

  $async.Future<$0.BoolValue> setLoadProfileParam_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetLoadProfileParamRequest> $request) async {
    return setLoadProfileParam($call, await $request);
  }

  $async.Future<$0.BoolValue> setLoadProfileParam(
      $grpc.ServiceCall call, $0.SetLoadProfileParamRequest request);

  $async.Future<$0.FresnelResponse> getFresnelData_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getFresnelData($call, await $request);
  }

  $async.Future<$0.FresnelResponse> getFresnelData(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.DeviceIDList> getDeviceID_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getDeviceID($call, await $request);
  }

  $async.Future<$0.DeviceIDList> getDeviceID(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.FirmwareVersionList> getFirmwareVersion_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getFirmwareVersion($call, await $request);
  }

  $async.Future<$0.FirmwareVersionList> getFirmwareVersion(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ActivationDateTime> getImageTransfertActivationDateTime_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getImageTransfertActivationDateTime($call, await $request);
  }

  $async.Future<$0.ActivationDateTime> getImageTransfertActivationDateTime(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setImageTransfertActivationDateTime_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ActivationDateTime> $request) async {
    return setImageTransfertActivationDateTime($call, await $request);
  }

  $async.Future<$0.BoolValue> setImageTransfertActivationDateTime(
      $grpc.ServiceCall call, $0.ActivationDateTime request);

  $async.Future<$0.DaylightSavingsTime> getIncrementalDate_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getIncrementalDate($call, await $request);
  }

  $async.Future<$0.DaylightSavingsTime> getIncrementalDate(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setIncrementalDate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DaylightSavingsTime> $request) async {
    return setIncrementalDate($call, await $request);
  }

  $async.Future<$0.BoolValue> setIncrementalDate(
      $grpc.ServiceCall call, $0.DaylightSavingsTime request);

  $async.Future<$0.DaylightSavingsTime> getDecrementalDate_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getDecrementalDate($call, await $request);
  }

  $async.Future<$0.DaylightSavingsTime> getDecrementalDate(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setDecrementalDate_Pre($grpc.ServiceCall $call,
      $async.Future<$0.DaylightSavingsTime> $request) async {
    return setDecrementalDate($call, await $request);
  }

  $async.Future<$0.BoolValue> setDecrementalDate(
      $grpc.ServiceCall call, $0.DaylightSavingsTime request);

  $async.Future<$0.Int32Value> getDaylightSavingDeviation_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getDaylightSavingDeviation($call, await $request);
  }

  $async.Future<$0.Int32Value> getDaylightSavingDeviation(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setDaylightSavingDeviation_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setDaylightSavingDeviation($call, await $request);
  }

  $async.Future<$0.BoolValue> setDaylightSavingDeviation(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.BoolValue> getDaylightSavingActivation_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getDaylightSavingActivation($call, await $request);
  }

  $async.Future<$0.BoolValue> getDaylightSavingActivation(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setDaylightSavingActivation_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.BoolValue> $request) async {
    return setDaylightSavingActivation($call, await $request);
  }

  $async.Future<$0.BoolValue> setDaylightSavingActivation(
      $grpc.ServiceCall call, $0.BoolValue request);

  $async.Future<$0.Int32Value> getTimezone_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getTimezone($call, await $request);
  }

  $async.Future<$0.Int32Value> getTimezone(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setTimezone_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setTimezone($call, await $request);
  }

  $async.Future<$0.BoolValue> setTimezone(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.EnergyRegisterList> getEnergyRegister_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getEnergyRegister($call, await $request);
  }

  $async.Future<$0.EnergyRegisterList> getEnergyRegister(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.AverageList> getAverage_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getAverage($call, await $request);
  }

  $async.Future<$0.AverageList> getAverage(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BitStatusResponse> getBitStatus_Pre($grpc.ServiceCall $call,
      $async.Future<$0.BitStatusRequest> $request) async {
    return getBitStatus($call, await $request);
  }

  $async.Future<$0.BitStatusResponse> getBitStatus(
      $grpc.ServiceCall call, $0.BitStatusRequest request);

  $async.Future<$0.GetPushObjectListResponse> getPushObjectList_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetPushObjectListRequest> $request) async {
    return getPushObjectList($call, await $request);
  }

  $async.Future<$0.GetPushObjectListResponse> getPushObjectList(
      $grpc.ServiceCall call, $0.GetPushObjectListRequest request);

  $async.Future<$0.ActivityCalendarData> getActiveCalendar_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getActiveCalendar($call, await $request);
  }

  $async.Future<$0.ActivityCalendarData> getActiveCalendar(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ActivityCalendarData> getPassiveCalendar_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPassiveCalendar($call, await $request);
  }

  $async.Future<$0.ActivityCalendarData> getPassiveCalendar(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ActivityCalendarData> getPassiveDayProfiles_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPassiveDayProfiles($call, await $request);
  }

  $async.Future<$0.ActivityCalendarData> getPassiveDayProfiles(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ActivityCalendarData> getPassiveWeekProfiles_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPassiveWeekProfiles($call, await $request);
  }

  $async.Future<$0.ActivityCalendarData> getPassiveWeekProfiles(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ActivityCalendarData> getPassiveSeasonProfiles_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPassiveSeasonProfiles($call, await $request);
  }

  $async.Future<$0.ActivityCalendarData> getPassiveSeasonProfiles(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setPassiveCalendar_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ActivityCalendarData> $request) async {
    return setPassiveCalendar($call, await $request);
  }

  $async.Future<$0.BoolValue> setPassiveCalendar(
      $grpc.ServiceCall call, $0.ActivityCalendarData request);

  $async.Future<$0.SpecialDayTable> getSpecialDays_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getSpecialDays($call, await $request);
  }

  $async.Future<$0.SpecialDayTable> getSpecialDays(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.SpecialDayTable> getPassiveSpecialDays_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPassiveSpecialDays($call, await $request);
  }

  $async.Future<$0.SpecialDayTable> getPassiveSpecialDays(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setPassiveSpecialDays_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SpecialDayTable> $request) async {
    return setPassiveSpecialDays($call, await $request);
  }

  $async.Future<$0.BoolValue> setPassiveSpecialDays(
      $grpc.ServiceCall call, $0.SpecialDayTable request);

  $async.Future<$0.BoolValue> activatePassiveCalendar_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return activatePassiveCalendar($call, await $request);
  }

  $async.Future<$0.BoolValue> activatePassiveCalendar(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> setPushObjectList_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetPushObjectListRequest> $request) async {
    return setPushObjectList($call, await $request);
  }

  $async.Future<$1.Empty> setPushObjectList(
      $grpc.ServiceCall call, $0.SetPushObjectListRequest request);

  $async.Future<$0.GetRandomisationStartIntervalResponse>
      getRandomisationStartInterval_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.GetRandomisationStartIntervalRequest>
              $request) async {
    return getRandomisationStartInterval($call, await $request);
  }

  $async.Future<$0.GetRandomisationStartIntervalResponse>
      getRandomisationStartInterval($grpc.ServiceCall call,
          $0.GetRandomisationStartIntervalRequest request);

  $async.Future<$1.Empty> setRandomisationStartInterval_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetRandomisationStartIntervalRequest> $request) async {
    return setRandomisationStartInterval($call, await $request);
  }

  $async.Future<$1.Empty> setRandomisationStartInterval(
      $grpc.ServiceCall call, $0.SetRandomisationStartIntervalRequest request);

  $async.Future<$0.GetNumberOfRetriesResponse> getNumberOfRetries_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetNumberOfRetriesRequest> $request) async {
    return getNumberOfRetries($call, await $request);
  }

  $async.Future<$0.GetNumberOfRetriesResponse> getNumberOfRetries(
      $grpc.ServiceCall call, $0.GetNumberOfRetriesRequest request);

  $async.Future<$1.Empty> setNumberOfRetries_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetNumberOfRetriesRequest> $request) async {
    return setNumberOfRetries($call, await $request);
  }

  $async.Future<$1.Empty> setNumberOfRetries(
      $grpc.ServiceCall call, $0.SetNumberOfRetriesRequest request);

  $async.Future<$0.GetRepetitionDelayResponse> getRepetitionDelay_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetRepetitionDelayRequest> $request) async {
    return getRepetitionDelay($call, await $request);
  }

  $async.Future<$0.GetRepetitionDelayResponse> getRepetitionDelay(
      $grpc.ServiceCall call, $0.GetRepetitionDelayRequest request);

  $async.Future<$1.Empty> setRepetitionDelay_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetRepetitionDelayRequest> $request) async {
    return setRepetitionDelay($call, await $request);
  }

  $async.Future<$1.Empty> setRepetitionDelay(
      $grpc.ServiceCall call, $0.SetRepetitionDelayRequest request);

  $async.Future<$0.GetLastConfirmationDatetimeResponse>
      getLastConfirmationDatetime_Pre($grpc.ServiceCall $call,
          $async.Future<$0.GetLastConfirmationDatetimeRequest> $request) async {
    return getLastConfirmationDatetime($call, await $request);
  }

  $async.Future<$0.GetLastConfirmationDatetimeResponse>
      getLastConfirmationDatetime($grpc.ServiceCall call,
          $0.GetLastConfirmationDatetimeRequest request);

  $async.Future<$1.Empty> setLastConfirmationDatetime_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetLastConfirmationDatetimeRequest> $request) async {
    return setLastConfirmationDatetime($call, await $request);
  }

  $async.Future<$1.Empty> setLastConfirmationDatetime(
      $grpc.ServiceCall call, $0.SetLastConfirmationDatetimeRequest request);

  $async.Future<$0.GetSendDestinationResponse> getSendDestination_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetSendDestinationRequest> $request) async {
    return getSendDestination($call, await $request);
  }

  $async.Future<$0.GetSendDestinationResponse> getSendDestination(
      $grpc.ServiceCall call, $0.GetSendDestinationRequest request);

  $async.Future<$1.Empty> setSendDestination_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetSendDestinationRequest> $request) async {
    return setSendDestination($call, await $request);
  }

  $async.Future<$1.Empty> setSendDestination(
      $grpc.ServiceCall call, $0.SetSendDestinationRequest request);

  $async.Future<$0.GetCommunicationWindowResponse> getCommunicationWindow_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetCommunicationWindowRequest> $request) async {
    return getCommunicationWindow($call, await $request);
  }

  $async.Future<$0.GetCommunicationWindowResponse> getCommunicationWindow(
      $grpc.ServiceCall call, $0.GetCommunicationWindowRequest request);

  $async.Future<$1.Empty> setCommunicationWindow_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetCommunicationWindowRequest> $request) async {
    return setCommunicationWindow($call, await $request);
  }

  $async.Future<$1.Empty> setCommunicationWindow(
      $grpc.ServiceCall call, $0.SetCommunicationWindowRequest request);

  $async.Future<$0.StringList> getExecutionTime_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetExecutionTimeRequest> $request) async {
    return getExecutionTime($call, await $request);
  }

  $async.Future<$0.StringList> getExecutionTime(
      $grpc.ServiceCall call, $0.GetExecutionTimeRequest request);

  $async.Future<$1.Empty> setExecutionTime_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetExecutionTimeRequest> $request) async {
    return setExecutionTime($call, await $request);
  }

  $async.Future<$1.Empty> setExecutionTime(
      $grpc.ServiceCall call, $0.SetExecutionTimeRequest request);

  $async.Future<$0.Int32Value> getPushActionType_Pre($grpc.ServiceCall $call,
      $async.Future<$0.GetPushActionTypeRequest> $request) async {
    return getPushActionType($call, await $request);
  }

  $async.Future<$0.Int32Value> getPushActionType(
      $grpc.ServiceCall call, $0.GetPushActionTypeRequest request);

  $async.Future<$0.GetPushActionExecutedScriptResponse>
      getPushActionExecutedScript_Pre($grpc.ServiceCall $call,
          $async.Future<$0.GetPushActionExecutedScriptRequest> $request) async {
    return getPushActionExecutedScript($call, await $request);
  }

  $async.Future<$0.GetPushActionExecutedScriptResponse>
      getPushActionExecutedScript($grpc.ServiceCall call,
          $0.GetPushActionExecutedScriptRequest request);

  $async.Future<$1.Empty> setPushActionExecutedScript_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.SetPushActionExecutedScriptRequest> $request) async {
    return setPushActionExecutedScript($call, await $request);
  }

  $async.Future<$1.Empty> setPushActionExecutedScript(
      $grpc.ServiceCall call, $0.SetPushActionExecutedScriptRequest request);

  $async.Future<$0.GetScriptTableResponse> getScriptTable_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetScriptTableRequest> $request) async {
    return getScriptTable($call, await $request);
  }

  $async.Future<$0.GetScriptTableResponse> getScriptTable(
      $grpc.ServiceCall call, $0.GetScriptTableRequest request);

  $async.Future<$0.GetPushSelectiveCaptureObjectsResponse>
      getPushSelectiveCaptureObjects_Pre(
          $grpc.ServiceCall $call,
          $async.Future<$0.GetPushSelectiveCaptureObjectsRequest>
              $request) async {
    return getPushSelectiveCaptureObjects($call, await $request);
  }

  $async.Future<$0.GetPushSelectiveCaptureObjectsResponse>
      getPushSelectiveCaptureObjects($grpc.ServiceCall call,
          $0.GetPushSelectiveCaptureObjectsRequest request);

  $async.Future<$0.GetPushRecoveryObjectsResponse> getPushRecoveryObjects_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetPushRecoveryObjectsRequest> $request) async {
    return getPushRecoveryObjects($call, await $request);
  }

  $async.Future<$0.GetPushRecoveryObjectsResponse> getPushRecoveryObjects(
      $grpc.ServiceCall call, $0.GetPushRecoveryObjectsRequest request);

  $async.Future<$1.Empty> pushSetupPush_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PushSetupPushRequest> $request) async {
    return pushSetupPush($call, await $request);
  }

  $async.Future<$1.Empty> pushSetupPush(
      $grpc.ServiceCall call, $0.PushSetupPushRequest request);

  $async.Future<$1.Empty> pushSetupReset_Pre($grpc.ServiceCall $call,
      $async.Future<$0.PushSetupResetRequest> $request) async {
    return pushSetupReset($call, await $request);
  }

  $async.Future<$1.Empty> pushSetupReset(
      $grpc.ServiceCall call, $0.PushSetupResetRequest request);

  $async.Future<$0.ModemConfigResponse> getModemConfig_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getModemConfig($call, await $request);
  }

  $async.Future<$0.ModemConfigResponse> getModemConfig(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setApn_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetApnRequest> $request) async {
    return setApn($call, await $request);
  }

  $async.Future<$0.BoolValue> setApn(
      $grpc.ServiceCall call, $0.SetApnRequest request);

  $async.Future<$0.BoolValue> setPinCode_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetPinCodeRequest> $request) async {
    return setPinCode($call, await $request);
  }

  $async.Future<$0.BoolValue> setPinCode(
      $grpc.ServiceCall call, $0.SetPinCodeRequest request);

  $async.Future<$0.BoolValue> setPppAuth_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetPppAuthRequest> $request) async {
    return setPppAuth($call, await $request);
  }

  $async.Future<$0.BoolValue> setPppAuth(
      $grpc.ServiceCall call, $0.SetPppAuthRequest request);

  $async.Future<$0.IpAddressResponse> getIpAddress_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getIpAddress($call, await $request);
  }

  $async.Future<$0.IpAddressResponse> getIpAddress(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setIpAddress_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetIpAddressRequest> $request) async {
    return setIpAddress($call, await $request);
  }

  $async.Future<$0.BoolValue> setIpAddress(
      $grpc.ServiceCall call, $0.SetIpAddressRequest request);

  $async.Future<$0.CellularDiagResponse> getCellularDiag_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getCellularDiag($call, await $request);
  }

  $async.Future<$0.CellularDiagResponse> getCellularDiag(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setCellularField_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetCellularFieldRequest> $request) async {
    return setCellularField($call, await $request);
  }

  $async.Future<$0.BoolValue> setCellularField(
      $grpc.ServiceCall call, $0.SetCellularFieldRequest request);

  $async.Future<$0.CellInfoResponse> getCellInfo_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getCellInfo($call, await $request);
  }

  $async.Future<$0.CellInfoResponse> getCellInfo(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setCellInfoEntry_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetCellInfoEntryRequest> $request) async {
    return setCellInfoEntry($call, await $request);
  }

  $async.Future<$0.BoolValue> setCellInfoEntry(
      $grpc.ServiceCall call, $0.SetCellInfoEntryRequest request);

  $async.Future<$0.GetQosResponse> getQos_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getQos($call, await $request);
  }

  $async.Future<$0.GetQosResponse> getQos(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setQos_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.SetQosRequest> $request) async {
    return setQos($call, await $request);
  }

  $async.Future<$0.BoolValue> setQos(
      $grpc.ServiceCall call, $0.SetQosRequest request);

  $async.Future<$0.MobileNetworkIdentifiersResponse>
      getMobileNetworkIdentifiers_Pre(
          $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getMobileNetworkIdentifiers($call, await $request);
  }

  $async.Future<$0.MobileNetworkIdentifiersResponse>
      getMobileNetworkIdentifiers($grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setImsi_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetMniFieldRequest> $request) async {
    return setImsi($call, await $request);
  }

  $async.Future<$0.BoolValue> setImsi(
      $grpc.ServiceCall call, $0.SetMniFieldRequest request);

  $async.Future<$0.BoolValue> setMsisdn_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetMniFieldRequest> $request) async {
    return setMsisdn($call, await $request);
  }

  $async.Future<$0.BoolValue> setMsisdn(
      $grpc.ServiceCall call, $0.SetMniFieldRequest request);

  $async.Future<$0.BoolValue> setImei_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetMniFieldRequest> $request) async {
    return setImei($call, await $request);
  }

  $async.Future<$0.BoolValue> setImei(
      $grpc.ServiceCall call, $0.SetMniFieldRequest request);

  $async.Future<$0.BoolValue> setIccid_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetMniFieldRequest> $request) async {
    return setIccid($call, await $request);
  }

  $async.Future<$0.BoolValue> setIccid(
      $grpc.ServiceCall call, $0.SetMniFieldRequest request);

  $async.Future<$0.ModemStatusResponse> getModemStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getModemStatus($call, await $request);
  }

  $async.Future<$0.ModemStatusResponse> getModemStatus(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setModemStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.BoolValue> $request) async {
    return setModemStatus($call, await $request);
  }

  $async.Future<$0.BoolValue> setModemStatus(
      $grpc.ServiceCall call, $0.BoolValue request);

  $async.Future<$0.BoolValue> restartModem_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return restartModem($call, await $request);
  }

  $async.Future<$0.BoolValue> restartModem(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.MniRightsResponse> getMniRights_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getMniRights($call, await $request);
  }

  $async.Future<$0.MniRightsResponse> getMniRights(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.ModemConfigSettingsResponse> getModemConfigSettings_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getModemConfigSettings($call, await $request);
  }

  $async.Future<$0.ModemConfigSettingsResponse> getModemConfigSettings(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setCommSpeed_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetCommSpeedRequest> $request) async {
    return setCommSpeed($call, await $request);
  }

  $async.Future<$0.BoolValue> setCommSpeed(
      $grpc.ServiceCall call, $0.SetCommSpeedRequest request);

  $async.Future<$0.BoolValue> setModemProfile_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetModemProfileRequest> $request) async {
    return setModemProfile($call, await $request);
  }

  $async.Future<$0.BoolValue> setModemProfile(
      $grpc.ServiceCall call, $0.SetModemProfileRequest request);

  $async.Future<$0.BoolValue> setInitStrings_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetInitStringsRequest> $request) async {
    return setInitStrings($call, await $request);
  }

  $async.Future<$0.BoolValue> setInitStrings(
      $grpc.ServiceCall call, $0.SetInitStringsRequest request);

  $async.Future<$0.AutoConnectResponse> getAutoConnect_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getAutoConnect($call, await $request);
  }

  $async.Future<$0.AutoConnectResponse> getAutoConnect(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setAutoConnect_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetAutoConnectRequest> $request) async {
    return setAutoConnect($call, await $request);
  }

  $async.Future<$0.BoolValue> setAutoConnect(
      $grpc.ServiceCall call, $0.SetAutoConnectRequest request);

  $async.Future<$0.BoolValue> modemConnect_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return modemConnect($call, await $request);
  }

  $async.Future<$0.BoolValue> modemConnect(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.AutoAnswerResponse> getAutoAnswer_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getAutoAnswer($call, await $request);
  }

  $async.Future<$0.AutoAnswerResponse> getAutoAnswer(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setAutoAnswer_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetAutoAnswerRequest> $request) async {
    return setAutoAnswer($call, await $request);
  }

  $async.Future<$0.BoolValue> setAutoAnswer(
      $grpc.ServiceCall call, $0.SetAutoAnswerRequest request);

  $async.Future<$0.TcpUdpSetupResponse> getTcpUdpSetup_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getTcpUdpSetup($call, await $request);
  }

  $async.Future<$0.TcpUdpSetupResponse> getTcpUdpSetup(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.BoolValue> setTcpUdpSetup_Pre($grpc.ServiceCall $call,
      $async.Future<$0.SetTcpUdpSetupRequest> $request) async {
    return setTcpUdpSetup($call, await $request);
  }

  $async.Future<$0.BoolValue> setTcpUdpSetup(
      $grpc.ServiceCall call, $0.SetTcpUdpSetupRequest request);

  $async.Future<$0.StringValue> getObjectWriteRights_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return getObjectWriteRights($call, await $request);
  }

  $async.Future<$0.StringValue> getObjectWriteRights(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$1.Empty> executeScriptTable_Pre($grpc.ServiceCall $call,
      $async.Future<$0.ExecuteScriptTableRequest> $request) async {
    return executeScriptTable($call, await $request);
  }

  $async.Future<$1.Empty> executeScriptTable(
      $grpc.ServiceCall call, $0.ExecuteScriptTableRequest request);

  $async.Stream<$0.PushNotification> startPushSetupServer_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.StartPushSetupServerRequest> $request) async* {
    yield* startPushSetupServer($call, await $request);
  }

  $async.Stream<$0.PushNotification> startPushSetupServer(
      $grpc.ServiceCall call, $0.StartPushSetupServerRequest request);

  $async.Future<$1.Empty> stopPushSetupServer_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return stopPushSetupServer($call, await $request);
  }

  $async.Future<$1.Empty> stopPushSetupServer(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> sendTestNotification_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return sendTestNotification($call, await $request);
  }

  $async.Future<$1.Empty> sendTestNotification(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Stream<$0.RetryStatusUpdate> watchRetryStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async* {
    yield* watchRetryStatus($call, await $request);
  }

  $async.Stream<$0.RetryStatusUpdate> watchRetryStatus(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.Int32Value> getPrimaryCt_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPrimaryCt($call, await $request);
  }

  $async.Future<$0.Int32Value> getPrimaryCt(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> setPrimaryCt_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setPrimaryCt($call, await $request);
  }

  $async.Future<$1.Empty> setPrimaryCt(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.Int32Value> getSecondaryCt_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getSecondaryCt($call, await $request);
  }

  $async.Future<$0.Int32Value> getSecondaryCt(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> setSecondaryCt_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setSecondaryCt($call, await $request);
  }

  $async.Future<$1.Empty> setSecondaryCt(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.Int32Value> getPrimaryVt_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getPrimaryVt($call, await $request);
  }

  $async.Future<$0.Int32Value> getPrimaryVt(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> setPrimaryVt_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setPrimaryVt($call, await $request);
  }

  $async.Future<$1.Empty> setPrimaryVt(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.Int32Value> getRatioValueVt_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getRatioValueVt($call, await $request);
  }

  $async.Future<$0.Int32Value> getRatioValueVt(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$1.Empty> setRatioValueVt_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Int32Value> $request) async {
    return setRatioValueVt($call, await $request);
  }

  $async.Future<$1.Empty> setRatioValueVt(
      $grpc.ServiceCall call, $0.Int32Value request);

  $async.Future<$0.ImageTransferStatusResponse> getImageTransferStatus_Pre(
      $grpc.ServiceCall $call, $async.Future<$1.Empty> $request) async {
    return getImageTransferStatus($call, await $request);
  }

  $async.Future<$0.ImageTransferStatusResponse> getImageTransferStatus(
      $grpc.ServiceCall call, $1.Empty request);

  $async.Future<$0.GetQualityObjectsResponse> getQualityObjects_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.GetQualityObjectsRequest> $request) async {
    return getQualityObjects($call, await $request);
  }

  $async.Future<$0.GetQualityObjectsResponse> getQualityObjects(
      $grpc.ServiceCall call, $0.GetQualityObjectsRequest request);

  $async.Future<$1.Empty> updateQualityObject_Pre($grpc.ServiceCall $call,
      $async.Future<$0.UpdateQualityObjectRequest> $request) async {
    return updateQualityObject($call, await $request);
  }

  $async.Future<$1.Empty> updateQualityObject(
      $grpc.ServiceCall call, $0.UpdateQualityObjectRequest request);

  $async.Future<$0.ReadQualityConfigResponse> readQualityConfig_Pre(
      $grpc.ServiceCall $call,
      $async.Future<$0.ReadQualityConfigRequest> $request) async {
    return readQualityConfig($call, await $request);
  }

  $async.Future<$0.ReadQualityConfigResponse> readQualityConfig(
      $grpc.ServiceCall call, $0.ReadQualityConfigRequest request);

  $async.Future<$1.Empty> writeQualityConfig_Pre($grpc.ServiceCall $call,
      $async.Future<$0.WriteQualityConfigRequest> $request) async {
    return writeQualityConfig($call, await $request);
  }

  $async.Future<$1.Empty> writeQualityConfig(
      $grpc.ServiceCall call, $0.WriteQualityConfigRequest request);
}
