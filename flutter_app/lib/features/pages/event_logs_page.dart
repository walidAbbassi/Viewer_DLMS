import 'dart:async';
import 'dart:convert' show base64Encode;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import '../../state/app_controller.dart';
import '../../core/export/exportable_page.dart';
import '../../state/device_id_cache.dart';
import '../../core/export/export_registry.dart';
import '../../core/export/export_action_button.dart';
import '../../core/widget_keys.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../core/services/feedback_service.dart';
import '../event_logs/event_logs_config.dart';
import '../event_logs/event_logs_service.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../event_logs/event_code_description_service.dart';
import '../widgets/class7_info_widget.dart';
import '../widgets/partial_read_widget.dart';
import '../widgets/event_log_bar_chart_widget.dart';
import '../../state/class7_cache.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';

class EventLogsPage extends StatefulWidget {
  final EventLogsConfig? config;

  const EventLogsPage({super.key, this.config});

  @override
  State<EventLogsPage> createState() => _EventLogsPageState();
}

class _EventLogsPageState extends State<EventLogsPage>
    with SingleTickerProviderStateMixin
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'event_logs_${widget.config?.id ?? 'default'}';

  @override
  String get exportPageLabel => widget.config?.name ?? 'Event Logs';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'id': widget.config?.id,
        'name': widget.config?.name,
        'description': widget.config?.description,
        'dataSource': widget.config?.dataSource,
        'rowCount': eventsData.length,
        'columns': _streamHeader,
        'data': _streamData,
      };

  // ---------------------------------------------------------------------------

  bool get _isLocalManagement =>
      ProviderScope.containerOf(context, listen: false)
          .read(appControllerProvider)
          .moduleName ==
      'LocalManagement';

  bool get _isConnected => ProviderScope.containerOf(context, listen: false)
      .read(appControllerProvider)
      .isConnected;

  late TabController _tabController;

  // ---- Chart capture key ---------------------------------------------------
  final GlobalKey _chartRepaintKey = GlobalKey();

  Future<String?> _captureChartAsPng() async {
    try {
      final boundary = _chartRepaintKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      return base64Encode(byteData.buffer.asUint8List());
    } catch (_) {
      return null;
    }
  }

  // Class 7 attributes
  int? _maxRecord;
  int? _recordNumber;
  int? _capturePeriod;

  // Partial read configuration
  DateTime? _partialReadStartDate;
  DateTime? _partialReadEndDate;
  String? _partialReadStartDeviation;
  String? _partialReadEndDeviation;
  String? _partialReadStartStatus;
  String? _partialReadEndStatus;

  // Data
  List<EventLogEntry> eventsData = [];
  int? selectedStatValue;

  // Stream loading (reuse load profile mechanisms)
  late IMeterClient _client;
  Stream<GetLoadProfileStreamItem>? _stream;
  StreamController<GetLoadProfileStreamItem>? _streamController;
  StreamSubscription<GetLoadProfileStreamItem>? _gRpcSubscription;
  String? _executionMessage;
  int? _downloadPercent;
  DownloadProgress? _downloadProgress;
  List<String> _streamHeader = [];
  List<List<String>> _streamData = [];

  // Pagination
  int currentPage = 1;
  int pageSize = 50;

  // Reading state
  bool isReading = false;
  double readingProgress = 0.0;
  int readCount = 0;
  int totalToRead = 0;
  int _totalPages = 1;
  int _totalEntries = 0;

  // Filters
  DateTime? dateStart;
  DateTime? dateEnd;

  // Console logs
  List<ConsoleLogEntry> consoleLogs = [];

  // Statistics
  int statCritical = 0;
  int statWarning = 0;
  int statInfo = 0;
  int statTotal = 0;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _tabController = TabController(length: 2, vsync: this);
    dateStart = DateTime(2025, 12, 15);
    dateEnd = DateTime(2025, 12, 18, 23, 59);
    _initSequential();
    // Pre-fill from cache for instant display
    if (widget.config?.dataSource != null) {
      final cached = Class7Cache.get(widget.config!.dataSource);
      if (cached != null) {
        _streamHeader = List.from(cached.headers);
        _streamData = List.from(cached.data);
      }
    }

    // Initialize stream for event logs if a data source is provided
  }

  Future<void> _initSequential() async {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    if (!isConnected) return;
    await _readClass7Attributes();
    if (!mounted) return;
    if (widget.config?.dataSource != null &&
        widget.config!.dataSource.isNotEmpty) {
      _initStream(_client.getLoadProfile(widget.config!.dataSource,
          page: 0, pageSize: pageSize));
    }
  }

  Future<void> _readClass7Attributes() async {
    try {
      final max = await _readMaxRecord();

      if (mounted) setState(() => _maxRecord = max);
    } catch (_) {}
    try {
      final rec = await _readRecordNumber();
      if (mounted) setState(() => _recordNumber = rec);
    } catch (_) {}
    try {
      final period = await _readCapturePeriod();
      if (mounted) setState(() => _capturePeriod = period);
    } catch (_) {}
  }

  Future<int> _readMaxRecord() async {
    try {
      if (widget.config?.dataSource == null) {
        throw Exception('Data source not configured');
      }
      return await _client.getLoadProfileMaxRecords(widget.config!.dataSource);
    } catch (e) {
      if (mounted) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      }
      rethrow;
    }
  }

  Future<void> _setMaxRecord(int value) async {
    try {
      if (widget.config?.dataSource == null) {
        throw Exception('Data source not configured');
      }
      final success = await _client.setLoadProfileMaxRecords(
          widget.config!.dataSource, value);
      if (!success) {
        throw Exception('Failed to set max record');
      }
      setState(() {
        _maxRecord = value;
      });
      if (mounted) {
        _showResultSnackBar(context, 'Max record set successfully', true);
      }
    } catch (e) {
      if (mounted) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      }
      rethrow;
    }
  }

  Future<int> _readRecordNumber() async {
    try {
      if (widget.config?.dataSource == null) {
        throw Exception('Data source not configured');
      }
      return await _client
          .getLoadProfileRecordNumber(widget.config!.dataSource);
    } catch (e) {
      if (mounted) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      }
      rethrow;
    }
  }

  Future<void> _setRecordNumber(int value) async {
    try {
      if (widget.config?.dataSource == null) {
        throw Exception('Data source not configured');
      }
      final success = await _client.setLoadProfileRecordNumber(
          widget.config!.dataSource, value);
      if (!success) {
        throw Exception('Failed to set record number');
      }
      setState(() {
        _recordNumber = value;
      });
      if (mounted) {
        _showResultSnackBar(context, 'Record number set successfully', true);
      }
    } catch (e) {
      if (mounted) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      }
      rethrow;
    }
  }

  Future<int> _readCapturePeriod() async {
    try {
      if (widget.config?.dataSource == null) {
        throw Exception('Data source not configured');
      }
      return await _client
          .getLoadProfileCapturePeriod(widget.config!.dataSource);
    } catch (e) {
      if (mounted) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      }
      rethrow;
    }
  }

  Future<void> _setCapturePeriod(int value) async {
    try {
      if (widget.config?.dataSource == null) {
        throw Exception('Data source not configured');
      }
      final success = await _client.setLoadProfileCapturePeriod(
          widget.config!.dataSource, value);
      if (!success) {
        throw Exception('Failed to set capture period');
      }
      setState(() {
        _capturePeriod = value;
      });
      if (mounted) {
        _showResultSnackBar(context, 'Capture period set successfully', true);
      }
    } catch (e) {
      if (mounted) {
        _showResultSnackBar(context, _extractErrorMessage(e), false);
      }
      rethrow;
    }
  }

  void _performPartialRead() {
    try {
      if (widget.config?.dataSource == null) {
        _showResultSnackBar(context, 'Data source not configured', false);
        return;
      }

      if (_partialReadStartDate == null || _partialReadEndDate == null) {
        _showResultSnackBar(
            context, 'Please select start and end dates', false);
        return;
      }

      // Create LoadProfilePartialRead objects
      final start = LoadProfilePartialRead()
        ..datetime = toTimestamp(_partialReadStartDate!)
        ..deviationHex = _partialReadStartDeviation ?? '8000'
        ..status = _partialReadStartStatus ?? 'Default';

      final end = LoadProfilePartialRead()
        ..datetime = toTimestamp(_partialReadEndDate!)
        ..deviationHex = _partialReadEndDeviation ?? '8000'
        ..status = _partialReadEndStatus ?? 'Default';

      // Update stream with partial read parameters
      _gRpcSubscription?.cancel();
      _streamController?.close();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startRead(_client.getLoadProfile(
          widget.config!.dataSource,
          start: start,
          end: end,
        ));
      });

      addConsoleLog('INFO',
          'Partial read initiated from ${_partialReadStartDate} to ${_partialReadEndDate}');
      _showResultSnackBar(context, 'Partial read started', true);
    } catch (e) {
      _showResultSnackBar(context, _extractErrorMessage(e), false);
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == currentPage) return;
    if (widget.config?.dataSource == null) return;
    // Backend caches all data after the first full read.
    // Subsequent page navigations are served instantly from cache.
    setState(() {
      currentPage = page;
      _stream = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _stream = _client.getLoadProfile(
          widget.config!.dataSource,
          page: page,
          pageSize: pageSize,
        );
      });
    });
  }

  Widget _buildPaginationBar() {
    return Builder(builder: (context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceAltOf(context),
          border:
              Border(top: BorderSide(color: DesignTokens.borderOf(context))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$_totalEntries entries',
              style: TextStyle(
                  fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
            ),
            const SizedBox(width: 24),
            IconButton(
              key: const Key(EventLogsKeys.firstPageBtn),
              icon: const Icon(Icons.first_page),
              onPressed: currentPage > 1 ? () => _goToPage(1) : null,
              tooltip: 'First page',
            ),
            IconButton(
              key: const Key(EventLogsKeys.prevPageBtn),
              icon: const Icon(Icons.chevron_left),
              onPressed:
                  currentPage > 1 ? () => _goToPage(currentPage - 1) : null,
              tooltip: 'Previous',
            ),
            Text(
              'Page $currentPage / $_totalPages',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            IconButton(
              key: const Key(EventLogsKeys.nextPageBtn),
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < _totalPages
                  ? () => _goToPage(currentPage + 1)
                  : null,
              tooltip: 'Next',
            ),
            IconButton(
              key: const Key(EventLogsKeys.lastPageBtn),
              icon: const Icon(Icons.last_page),
              onPressed: currentPage < _totalPages
                  ? () => _goToPage(_totalPages)
                  : null,
              tooltip: 'Last page (most recent)',
            ),
            const SizedBox(width: 24),
            const Text('Page size: ', style: TextStyle(fontSize: 13)),
            DropdownButton<int>(
              key: const Key(EventLogsKeys.pageSizeDropdown),
              value: pageSize,
              items: const [
                DropdownMenuItem(value: 25, child: Text('25')),
                DropdownMenuItem(value: 50, child: Text('50')),
                DropdownMenuItem(value: 100, child: Text('100')),
                DropdownMenuItem(value: 200, child: Text('200')),
              ],
              onChanged: (value) {
                if (value != null && value != pageSize) {
                  setState(() {
                    pageSize = value;
                    // When page size changes, jump to the last page of the new size
                    // so the user sees the most recent entries
                    currentPage = 0;
                    _stream = null;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _stream = _client.getLoadProfile(
                        widget.config!.dataSource,
                        page: 0, // last page (backend recalculates from cache)
                        pageSize: pageSize,
                      );
                    });
                  });
                }
              },
            ),
          ],
        ),
      );
    }); // Builder
  }

  void _showResultSnackBar(
      BuildContext context, String message, bool isSuccess) {
    if (isSuccess) {
      feedback.success(message);
    } else {
      feedback.error(message);
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      return e.toString();
    }
    final raw = e.toString();
    return raw.replaceFirst('Exception: ', '');
  }

  void _initStream(Stream<GetLoadProfileStreamItem> grpcStream) {
    _setMeterOpInProgress(true);
    final controller = StreamController<GetLoadProfileStreamItem>();
    _streamController = controller;
    _gRpcSubscription = grpcStream.listen(
      (event) {
        if (!controller.isClosed) controller.add(event);
      },
      onError: (e) {
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
          _setMeterOpInProgress(false);
        }
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
        _setMeterOpInProgress(false);
      },
    );
    _stream = controller.stream;
  }

  void _startRead(Stream<GetLoadProfileStreamItem> grpcStream) {
    _gRpcSubscription?.cancel();
    _streamController?.close();
    _setMeterOpInProgress(true);
    final controller = StreamController<GetLoadProfileStreamItem>();
    _streamController = controller;
    _gRpcSubscription = grpcStream.listen(
      (event) {
        if (!controller.isClosed) controller.add(event);
      },
      onError: (e) {
        if (!controller.isClosed) {
          controller.addError(e);
          controller.close();
          _setMeterOpInProgress(false);
        }
      },
      onDone: () {
        if (!controller.isClosed) controller.close();
        _setMeterOpInProgress(false);
      },
    );
    setState(() {
      _stream = controller.stream;
      _executionMessage = null;
      _downloadPercent = null;
      _downloadProgress = null;
    });
  }

  void _abortRead() {
    _gRpcSubscription?.cancel();
    _gRpcSubscription = null;
    _streamController?.close();
    _streamController = null;
    _setMeterOpInProgress(false);
    setState(() {
      _stream = null;
      _executionMessage = null;
      _downloadPercent = null;
      _downloadProgress = null;
    });
  }

  /// Sets or clears the global meter-operation-in-progress flag so the
  /// navigation drawer can block page switches while data is being retrieved.
  void _setMeterOpInProgress(bool v) {
    if (!mounted) return;
    ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider.notifier)
        .setMeterOperationInProgress(v);
  }

  @override
  void dispose() {
    _gRpcSubscription?.cancel();
    _streamController?.close();
    unawaited(_client.close());
    _setMeterOpInProgress(false);
    _tabController.dispose();
    super.dispose();
  }

  void generateSampleData() {
    // Real DLMS/COSEM event types (IEC 62056-21 Standard)
    final eventTypes = [
      EventType(
          code: '1',
          severity: EventSeverity.critical,
          desc: 'Power failure detected',
          status: ['PDN', 'ERR'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '2',
          severity: EventSeverity.info,
          desc: 'Power restored',
          status: ['PDN'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '3',
          severity: EventSeverity.info,
          desc: 'Daylight saving time changed',
          status: ['DST'],
          obis: '0.0.96.15.3.255'),
      EventType(
          code: '4',
          severity: EventSeverity.warning,
          desc: 'Clock adjusted - old time',
          status: ['CAD'],
          obis: '0.0.1.0.0.255'),
      EventType(
          code: '5',
          severity: EventSeverity.info,
          desc: 'Clock adjusted - new time',
          status: ['CAD'],
          obis: '0.0.1.0.0.255'),
      EventType(
          code: '6',
          severity: EventSeverity.critical,
          desc: 'Clock invalid detected',
          status: ['CIV', 'ERR'],
          obis: '0.0.1.0.0.255'),
      EventType(
          code: '50',
          severity: EventSeverity.warning,
          desc: 'Terminal cover opened',
          status: [],
          obis: '0.0.96.15.4.255'),
      EventType(
          code: '51',
          severity: EventSeverity.info,
          desc: 'Terminal cover closed',
          status: [],
          obis: '0.0.96.15.4.255'),
      EventType(
          code: '52',
          severity: EventSeverity.critical,
          desc: 'Strong DC magnetic field detected',
          status: ['ERR'],
          obis: '0.0.96.15.4.255'),
      EventType(
          code: '53',
          severity: EventSeverity.info,
          desc: 'No strong DC magnetic field',
          status: [],
          obis: '0.0.96.15.4.255'),
      EventType(
          code: '100',
          severity: EventSeverity.critical,
          desc: 'Voltage sag on phase L1',
          status: ['DNV'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '101',
          severity: EventSeverity.critical,
          desc: 'Voltage sag on phase L2',
          status: ['DNV'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '102',
          severity: EventSeverity.critical,
          desc: 'Voltage sag on phase L3',
          status: ['DNV'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '103',
          severity: EventSeverity.warning,
          desc: 'Voltage swell on phase L1',
          status: ['DNV'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '104',
          severity: EventSeverity.warning,
          desc: 'Voltage swell on phase L2',
          status: ['DNV'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '105',
          severity: EventSeverity.warning,
          desc: 'Voltage swell on phase L3',
          status: ['DNV'],
          obis: '0.0.96.15.1.255'),
      EventType(
          code: '255',
          severity: EventSeverity.warning,
          desc: 'Event log cleared',
          status: [],
          obis: '0.0.96.15.3.255'),
      EventType(
          code: '506',
          severity: EventSeverity.warning,
          desc: 'Local disconnection relay 1',
          status: [],
          obis: '0.0.96.15.2.255'),
      EventType(
          code: '507',
          severity: EventSeverity.warning,
          desc: 'Local disconnection relay 2',
          status: [],
          obis: '0.0.96.15.2.255'),
      EventType(
          code: '508',
          severity: EventSeverity.info,
          desc: 'Local reconnection relay 1',
          status: [],
          obis: '0.0.96.15.2.255'),
      EventType(
          code: '509',
          severity: EventSeverity.info,
          desc: 'Local reconnection relay 2',
          status: [],
          obis: '0.0.96.15.2.255'),
    ];

    eventsData = List.generate(60, (i) {
      final date = DateTime(2025, 12, 15 + i ~/ 20, 23 - i ~/ 3, 59 - i);
      final eventType = eventTypes[i % eventTypes.length];

      return EventLogEntry(
        id: eventType.code,
        timestamp: date,
        severity: eventType.severity,
        code: eventType.code,
        obis: eventType.obis,
        description: eventType.desc,
        profileStatus: eventType.status,
      );
    });

    updateStats();
  }

  void updateStats() {
    setState(() {
      statCritical =
          eventsData.where((e) => e.severity == EventSeverity.critical).length;
      statWarning =
          eventsData.where((e) => e.severity == EventSeverity.warning).length;
      statInfo =
          eventsData.where((e) => e.severity == EventSeverity.info).length;
      statTotal = eventsData.length;
    });
  }

  void addConsoleLog(String type, String message) {
    setState(() {
      consoleLogs.add(ConsoleLogEntry(
        time: DateTime.now(),
        type: type,
        message: message,
      ));
    });
  }

  void simulateReading(int count) {
    setState(() {
      isReading = true;
      readCount = 0;
      totalToRead = count;
      readingProgress = 0.0;
    });

    addConsoleLog('INFO', 'Reading $count entries...');

    // Simulate reading with periodic updates
    Future.delayed(const Duration(milliseconds: 100), _updateReadingProgress);
  }

  void _updateReadingProgress() {
    if (!isReading) return;

    setState(() {
      readCount += (10 + (readCount % 5));
      if (readCount >= totalToRead) {
        readCount = totalToRead;
        readingProgress = 1.0;
        isReading = false;
        final duration = (0.5 + (totalToRead / 100)).toStringAsFixed(1);
        addConsoleLog('OK', '$totalToRead events loaded in ${duration}s');
      } else {
        readingProgress = readCount / totalToRead;
        Future.delayed(
            const Duration(milliseconds: 100), _updateReadingProgress);
      }
    });
  }

  void interruptReading() {
    setState(() {
      isReading = false;
    });
    addConsoleLog('WARN', 'Reading interrupted by user');
  }

  void _showErrorMessage(BuildContext context, String message) {
    feedback.error(message);
  }

  String _headerLabel(int index, String fallback) {
    if (_streamHeader.length > index && _streamHeader[index].isNotEmpty) {
      return _streamHeader[index];
    }
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GetLoadProfileStreamItem>(
      stream: _stream,
      builder: (context, snapshot) {
        // ...existing code...
        if (snapshot.hasData) {
          final item = snapshot.data!;
          switch (item.whichItem()) {
            case GetLoadProfileStreamItem_Item.exec:
              final exec = item.exec;
              if (exec.hasMessage() && exec.message.isNotEmpty) {
                _executionMessage = exec.message;
              }
              break;
            case GetLoadProfileStreamItem_Item.download:
              _downloadProgress = item.download;
              _downloadPercent = _downloadProgress?.percent;
              break;
            case GetLoadProfileStreamItem_Item.result:
              final response = item.result;
              _streamHeader =
                  response.headerTypes.map((h) => h.toString()).toList();
              _streamData = response.values
                  .map((stringList) =>
                      stringList.items.map((v) => v.toString()).toList())
                  .toList();
              // --- Pagination metadata ---
              _totalEntries = response.totalEntries;
              currentPage =
                  response.currentPage > 0 ? response.currentPage : currentPage;
              _totalPages = response.totalPages > 0 ? response.totalPages : 1;
              // Save to cache for instant display on next visit
              if (widget.config?.dataSource != null) {
                Class7Cache.put(
                    widget.config!.dataSource, _streamHeader, _streamData);
              }
              // Reset loading info
              _executionMessage = null;
              _downloadPercent = null;
              _downloadProgress = null;
              break;
            case GetLoadProfileStreamItem_Item.notSet:
              break;
          }
        }

        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showErrorMessage(context, _extractErrorMessage(snapshot.error!));
          });
        }

        final bool isLoading = !snapshot.hasError &&
            (snapshot.connectionState == ConnectionState.waiting ||
                (snapshot.connectionState == ConnectionState.active &&
                    _streamHeader.isEmpty));

        final sc = SemanticColors.of(context);

        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(widget.config?.name ?? 'Event Logs'),
                backgroundColor: sc.primary,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: [
                  ExportActionButton(
                    key: const Key(EventLogsKeys.exportBtn),
                    pageId: exportPageId,
                    pageType: 'event_logs',
                    dataGetter: getExportData,
                    iconColor: Colors.white,
                    chartImageGetter: _captureChartAsPng,
                    onChartTabRequested: () => _tabController.animateTo(1),
                  ),
                  RefreshAppBarButton(
                    onPressed: () {
                      _gRpcSubscription?.cancel();
                      _streamController?.close();
                      if (widget.config?.dataSource != null) {
                        Class7Cache.invalidate(widget.config!.dataSource);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _startRead(_client.getLoadProfile(
                            widget.config!.dataSource,
                            page: 0,
                            pageSize: pageSize,
                          ));
                        });
                      }
                      generateSampleData();
                      addConsoleLog('INFO', 'Data refreshed');
                    },
                  ),
                ],
              ),
              drawer: const AppDrawer(),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Breadcrumb(segments: [
                      'Menu',
                      'Event Logs',
                      widget.config?.name ?? 'Event Logs',
                    ]),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            DesignTokens.backgroundOf(context),
                            DesignTokens.surfaceOf(context),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildHeader(),
                          _buildTabBar(),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildEventsTab(),
                                _buildChartTab(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/animations/data.json',
                            width: 200,
                            height: 200,
                            errorBuilder: (context, err, stack) => const Text(
                              'Failed to load animation',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          if (_executionMessage != null &&
                              _executionMessage!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              _executionMessage!,
                              key: ValueKey(_executionMessage),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (_downloadPercent != null &&
                              _downloadProgress != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: DesignTokens.surfaceOf(context),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Downloading: $_downloadPercent%',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: DesignTokens.primary600,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: 300,
                                    child: LinearProgressIndicator(
                                      value: _downloadPercent! / 100.0,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Color(0xFF1976D2)),
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            key: const Key(EventLogsKeys.abortBtn),
                            onPressed: _abortRead,
                            icon: const Icon(Icons.stop_circle_outlined),
                            label: const Text('Abort'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 28, vertical: 12),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                          color: DesignTokens.textSecondaryOf(context),
                          fontSize: 13),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: DesignTokens.textSecondaryOf(context)),
                    Text(
                      'Diagnostics',
                      style: TextStyle(
                          color: DesignTokens.textSecondaryOf(context),
                          fontSize: 13),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: DesignTokens.textSecondaryOf(context)),
                    Text(
                      widget.config?.name ?? 'Event Logs',
                      style: TextStyle(
                        color: DesignTokens.primary600,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.config?.name ?? 'Event Logs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.config?.description ??
                      'Complete DLMS/COSEM Event Logs Management (Class 7)',
                  style: TextStyle(
                    fontSize: 14,
                    color: DesignTokens.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DesignTokens.borderOf(context), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: DesignTokens.primary600,
        unselectedLabelColor: DesignTokens.textSecondaryOf(context),
        indicatorColor: DesignTokens.primary600,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.list),
            text: 'Events',
          ),
          Tab(
            icon: Icon(Icons.bar_chart),
            text: 'Chart',
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    final config = widget.config;

    final statColumnName = config?.statColumnName ?? 'Statistics';
    final List<dynamic> configStatColumns = config?.statColumns ?? [];

    // Find the index of the statColumn in the header
    int statColIndex = -1;
    if (statColumnName.isNotEmpty) {
      statColIndex = _streamHeader.indexWhere((h) => h == statColumnName);
    }

    // Build a map of value -> StatColumn from config
    Map<String, StatColumn> statColumnMap = {};
    for (var col in configStatColumns) {
      statColumnMap[col.value.toString()] = col;
    }

    // Collect all unique values from data for statColumnName
    Set<String> allStatValues = {};
    if (statColIndex != -1) {
      for (var row in _streamData) {
        if (row.length > statColIndex) {
          allStatValues.add(row[statColIndex]);
        }
      }
    }

    // Build stat columns: use config if present, else build from data, always include all unique values
    List<StatColumn> statColumns = [];
    for (var value in allStatValues) {
      if (statColumnMap.containsKey(value)) {
        statColumns.add(statColumnMap[value]!);
      } else {
        // Fallback for missing config: label = value, color = gray
        int fallbackInt;
        try {
          fallbackInt = int.parse(value);
        } catch (_) {
          fallbackInt = -1;
        }
        statColumns.add(
            StatColumn(value: fallbackInt, label: value, color: '#888888'));
      }
    }
    // Sort statColumns by value for consistency
    statColumns.sort((a, b) => a.value.compareTo(b.value));

    // Count occurrences for each statColumn value in your table data
    Map<int, int> statCounts = {};
    for (var col in statColumns) {
      statCounts[col.value] = 0;
    }
    if (statColIndex != -1) {
      for (var row in _streamData) {
        if (row.length > statColIndex) {
          final v = row[statColIndex];
          int vInt;
          try {
            vInt = int.parse(v);
          } catch (_) {
            vInt = -1;
          }
          if (statCounts.containsKey(vInt)) {
            statCounts[vInt] = (statCounts[vInt] ?? 0) + 1;
          }
        }
      }
    }

    // Filtered table data based on selected stat value
    List<List<String>> filteredTableData = selectedStatValue == null
        ? _streamData
        : _streamData.where((row) {
            if (statColIndex == -1 || row.length <= statColIndex) return false;
            int vInt;
            try {
              vInt = int.parse(row[statColIndex]);
            } catch (_) {
              vInt = -1;
            }
            return vInt == selectedStatValue;
          }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Class7InfoWidget(
                  featureKey: FeatureKeys.eventLogs,
                  maxRecord: _maxRecord,
                  recordNumber: _recordNumber,
                  capturePeriod: _capturePeriod,
                  onReadMaxRecord: _readMaxRecord,
                  onSetMaxRecord: _setMaxRecord,
                  maxRecordWriteEnabled: !_isLocalManagement,
                  onReadRecordNumber: _readRecordNumber,
                  onSetRecordNumber: _setRecordNumber,
                  recordNumberWriteEnabled: !_isLocalManagement,
                  onReadCapturePeriod: _readCapturePeriod,
                  onSetCapturePeriod: _setCapturePeriod,
                  allDisabled: !_isConnected,
                  initiallyExpanded: false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: PartialReadWidget(
                  featureKey: FeatureKeys.eventLogs,
                  startDate: _partialReadStartDate,
                  endDate: _partialReadEndDate,
                  startDeviation: _partialReadStartDeviation,
                  endDeviation: _partialReadEndDeviation,
                  startStatus: _partialReadStartStatus,
                  endStatus: _partialReadEndStatus,
                  onStartChanged: (date, deviation, status) {
                    setState(() {
                      _partialReadStartDate = date;
                      _partialReadStartDeviation = deviation;
                      _partialReadStartStatus = status;
                    });
                  },
                  onEndChanged: (date, deviation, status) {
                    setState(() {
                      _partialReadEndDate = date;
                      _partialReadEndDeviation = deviation;
                      _partialReadEndStatus = status;
                    });
                  },
                  onRead: _isConnected
                      ? () {
                          _performPartialRead();
                        }
                      : null,
                  initiallyExpanded: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            statColumnName,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignTokens.textPrimaryOf(context)),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: use Wrap for stat cards
              return Wrap(
                spacing: 16, // horizontal margin between cards
                runSpacing: 16, // vertical margin between rows
                children: statColumns.map((col) {
                  final count = statCounts[col.value] ?? 0;
                  final color =
                      Color(int.parse(col.color.replaceFirst('#', '0xFF')));
                  final isSelected = selectedStatValue == col.value;
                  final tabText = '${col.label} (${col.value})';
                  return SizedBox(
                    width: constraints.maxWidth < 600
                        ? constraints.maxWidth / 2 - 12
                        : constraints.maxWidth / statColumns.length - 16,
                    child: GestureDetector(
                      key: Key(EventLogsKeys.statCardKey(col.value)),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedStatValue = null;
                          } else {
                            selectedStatValue = col.value;
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: _buildStatCard(
                          context,
                          tabText,
                          count,
                          isSelected ? color : color.withOpacity(0.7),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          // Info Alert
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkSurfaceAlt
                  : DesignTokens.primary50,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: DesignTokens.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fast reading enabled',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        'Recent entries are loaded in <2 seconds. Use "Full Reading" to load all.',
                        style: TextStyle(
                            fontSize: 13,
                            color: DesignTokens.textSecondaryOf(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Actions
          Row(
            children: [
              ElevatedButton.icon(
                key: const Key(EventLogsKeys.partialReadBtn),
                onPressed: (_isConnected &&
                        userRights.hasRightForFeature(
                            'Get', FeatureKeys.eventLogs))
                    ? () => simulateReading(50)
                    : null,
                icon: const Icon(Icons.preview),
                label: const Text('Partial Reading (last 50)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.surfaceOf(context),
                  foregroundColor: DesignTokens.primary600,
                  elevation: 1,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress
          if (isReading) ...[
            Column(
              children: [
                LinearProgressIndicator(
                  value: readingProgress,
                  backgroundColor: DesignTokens.borderOf(context),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(DesignTokens.primary600),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '$readCount / $totalToRead entries',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Full Read button — directly above the table, right-aligned
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                key: const Key(EventLogsKeys.fullReadBtn),
                onPressed: (_isConnected &&
                        userRights.hasRightForFeature(
                            'Get', FeatureKeys.eventLogs))
                    ? () {
                        _gRpcSubscription?.cancel();
                        _streamController?.close();
                        if (widget.config?.dataSource != null) {
                          Class7Cache.invalidate(widget.config!.dataSource);
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _startRead(_client.getLoadProfile(
                            widget.config!.dataSource,
                            page: 0,
                            pageSize: pageSize,
                          ));
                        });
                      }
                    : null,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Full Reading'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primary600,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Table from stream data
          _buildEventsTableWithData(filteredTableData),
          if (_totalPages > 0) _buildPaginationBar(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      BuildContext context, String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: DesignTokens.textSecondaryOf(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTableWithData(List<List<String>> tableData) {
    if (_streamHeader.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: DesignTokens.borderOf(context)),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        child: Center(
          child: Text(
            '—',
            style: TextStyle(
                fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
          ),
        ),
      );
    }

    final config = widget.config;
    final statColumns = config?.statColumns ?? [];
    // Find the index of the statColumn in the header
    int statColIndex = -1;
    if (config?.statColumnName != null) {
      statColIndex = _streamHeader
          .indexWhere((h) => h.startsWith(config!.statColumnName!));
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.borderOf(context)),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                  dataTextStyle: TextStyle(
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                  columnSpacing: 24,
                  columns: [
                    ...List.generate(_streamHeader.length, (index) {
                      // If this is the statColumn, show as 'Label (value)'
                      if (index == statColIndex && statColumns.isNotEmpty) {
                        return DataColumn(
                          label: Tooltip(
                            message: '${config!.statColumnName} (Label/Value)',
                            child: Text(
                              '${config!.statColumnName} (Label/Value)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }
                      return DataColumn(
                        label: Tooltip(
                          message: _streamHeader[index],
                          child: Text(
                            _streamHeader[index],
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      );
                    }),
                    const DataColumn(
                      label: Tooltip(
                        message: 'Description',
                        child: Text(
                          'Description',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                  rows: tableData
                      .map(
                        (row) => DataRow(
                          cells: [
                            ...List.generate(
                              _streamHeader.length,
                              (index) {
                                if (index == statColIndex &&
                                    statColumns.isNotEmpty) {
                                  // Find the statColumn object for this value
                                  final statValue =
                                      index < row.length ? row[index] : '';
                                  int fallbackValue;
                                  try {
                                    fallbackValue = int.parse(statValue);
                                  } catch (_) {
                                    fallbackValue = -1;
                                  }
                                  final statCol = statColumns.firstWhere(
                                    (col) => col.value.toString() == statValue,
                                    orElse: () => StatColumn(
                                        value: fallbackValue,
                                        label: statValue,
                                        color: '#888888'),
                                  );
                                  // Always return DataCell with label (value)
                                  return DataCell(Text(
                                      '${statCol.label} (${statCol.value})',
                                      overflow: TextOverflow.ellipsis));
                                }
                                return DataCell(
                                  Text(
                                    index < row.length ? row[index] : '',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                            DataCell(
                              _EventCodeDescriptionCell(
                                statColIndex: statColIndex,
                                row: row,
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Previous rich event row kept for reference but no longer used

  // ── Chart tab ─────────────────────────────────────────────────────────────

  Widget _buildChartTab() {
    return RepaintBoundary(
      key: _chartRepaintKey,
      child: EventLogBarChartWidget(
        columns: _streamHeader,
        data: _streamData,
        statColumnName: widget.config?.statColumnName,
        eventColorMap: widget.config?.statColumns != null
            ? {
                for (final sc in widget.config!.statColumns!)
                  sc.value:
                      Color(int.parse(sc.color.replaceFirst('#', '0xFF'))),
              }
            : null,
      ),
    );
  }

  Widget _buildConsoleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.terminal, color: DesignTokens.success),
              const SizedBox(width: 8),
              Text(
                'DLMS Session Console',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkSurfaceAlt
                  : DesignTokens.primary50,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: DesignTokens.info),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                          fontSize: 13,
                          color: DesignTokens.textSecondaryOf(context)),
                      children: [
                        TextSpan(
                            text: 'Session statistics\n',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: DesignTokens.textPrimaryOf(context))),
                        TextSpan(text: 'GET: '),
                        TextSpan(
                            text: '0',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' | SET: '),
                        TextSpan(
                            text: '0',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' | ACTION: '),
                        TextSpan(
                            text: '0',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: ' | Exceptions: '),
                        TextSpan(
                            text: '0',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 400,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: ListView.builder(
              itemCount: consoleLogs.length,
              itemBuilder: (context, index) {
                final log = consoleLogs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 13),
                      children: [
                        TextSpan(
                          text: '[${DateFormat('HH:mm:ss').format(log.time)}] ',
                          style: const TextStyle(color: Color(0xFF9CA3AF)),
                        ),
                        TextSpan(
                          text: log.type.padRight(7),
                          style: TextStyle(
                            color: _getConsoleColor(log.type),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${log.message}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                key: const Key(EventLogsKeys.consoleClearBtn),
                onPressed: () {
                  setState(() {
                    consoleLogs.clear();
                  });
                },
                icon: const Icon(Icons.delete_sweep),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.surfaceOf(context),
                  foregroundColor: DesignTokens.primary600,
                  elevation: 1,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key(EventLogsKeys.consoleExportBtn),
                onPressed: () {
                  // Export console logic
                },
                icon: const Icon(Icons.download),
                label: const Text('Export Console'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.primary600,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getConsoleColor(String type) {
    switch (type.toUpperCase()) {
      case 'INFO':
        return DesignTokens.info;
      case 'SUCCESS':
      case 'OK':
      case 'GET':
        return DesignTokens.success;
      case 'WARN':
        return DesignTokens.warning;
      case 'ERROR':
        return DesignTokens.danger;
      default:
        return Colors.white;
    }
  }

  Widget _buildExportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_download, color: DesignTokens.primary600),
              const SizedBox(width: 8),
              Text(
                'Secure Data Export',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkSurfaceAlt
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: DesignTokens.warning),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Secure export with signature',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: DesignTokens.textPrimaryOf(context)),
                      ),
                      Text(
                        'Exports include digital signature, meter ID, user ID and timestamp.',
                        style: TextStyle(
                            fontSize: 13,
                            color: DesignTokens.textSecondaryOf(context)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Export Format',
                    border: OutlineInputBorder(),
                  ),
                  value: 'csv',
                  items: const [
                    DropdownMenuItem(value: 'csv', child: Text('CSV (Excel)')),
                    DropdownMenuItem(
                        value: 'xml', child: Text('XML (Structured)')),
                    DropdownMenuItem(value: 'pdf', child: Text('PDF (Report)')),
                    DropdownMenuItem(value: 'json', child: Text('JSON (API)')),
                  ],
                  onChanged: (value) {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Anonymization',
                    border: OutlineInputBorder(),
                  ),
                  value: 'none',
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None')),
                    DropdownMenuItem(
                        value: 'partial', child: Text('Partial (hashed IDs)')),
                    DropdownMenuItem(value: 'full', child: Text('Full (GDPR)')),
                  ],
                  onChanged: (value) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          CheckboxListTile(
            value: true,
            onChanged: (value) {},
            title: const Text('Include RSA-2048 digital signature'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: true,
            onChanged: (value) {},
            title: const Text('Include metadata (user, timestamp, session)'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            value: true,
            onChanged: (value) {},
            title: const Text('Log export operation (audit trail)'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ElevatedButton.icon(
                key: const Key(EventLogsKeys.secureExportBtn),
                onPressed: () {
                  addConsoleLog('INFO', 'Starting secure export...');
                  Future.delayed(const Duration(seconds: 1), () {
                    addConsoleLog(
                        'SUCCESS', 'Export completed with RSA-2048 signature');
                  });
                },
                icon: const Icon(Icons.lock),
                label: const Text('Secure Export'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.success,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key(EventLogsKeys.zipExportBtn),
                onPressed: () {
                  addConsoleLog('INFO', 'Creating ZIP archive...');
                  Future.delayed(const Duration(seconds: 1), () {
                    addConsoleLog(
                        'SUCCESS', 'ZIP created with signature and metadata');
                  });
                },
                icon: const Icon(Icons.folder_zip),
                label: const Text('ZIP Export with Signature'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.warning,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            children: [
              Icon(Icons.history, color: DesignTokens.warning),
              const SizedBox(width: 8),
              Text(
                'Export Audit Log',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExportAuditTable(),
        ],
      ),
    );
  }

  Widget _buildExportAuditTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkSurfaceAlt
                  : DesignTokens.gray100,
              border: Border(
                  bottom: BorderSide(color: DesignTokens.borderOf(context))),
            ),
            child: Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Timestamp',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimaryOf(context)))),
                Expanded(
                    flex: 2,
                    child: Text('User',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimaryOf(context)))),
                Expanded(
                    flex: 1,
                    child: Text('Format',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimaryOf(context)))),
                Expanded(
                    flex: 2,
                    child: Text('Events',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimaryOf(context)))),
                Expanded(
                    flex: 1,
                    child: Text('Signature',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimaryOf(context)))),
                Expanded(
                    flex: 1,
                    child: Text('Actions',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textPrimaryOf(context)))),
              ],
            ),
          ),
          _buildAuditRow('2025-12-18 14:30:00', 'jean.dupont@company.com',
              'CSV', '60 events'),
          _buildAuditRow('2025-12-17 10:15:00', 'marie.martin@company.com',
              'XML', '235 events'),
        ],
      ),
    );
  }

  Widget _buildAuditRow(
      String timestamp, String user, String format, String events) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(timestamp,
                  style: TextStyle(
                      fontSize: 13,
                      color: DesignTokens.textPrimaryOf(context)))),
          Expanded(
              flex: 2,
              child: Text(user,
                  style: TextStyle(
                      fontSize: 13,
                      color: DesignTokens.textPrimaryOf(context)))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignTokens.isDark(context)
                    ? DesignTokens.darkSurfaceAlt
                    : DesignTokens.gray200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                format,
                style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: DesignTokens.textPrimaryOf(context)),
              ),
            ),
          ),
          Expanded(
              flex: 2,
              child: Text(events,
                  style: TextStyle(
                      fontSize: 13,
                      color: DesignTokens.textPrimaryOf(context)))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DesignTokens.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle,
                      color: DesignTokens.success, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'SIGNED',
                    style: TextStyle(
                      color: DesignTokens.success,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.download, size: 18),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

// ===== DATA MODELS =====

enum EventSeverity { critical, warning, info }

class EventLogEntry {
  final String id;
  final DateTime timestamp;
  final EventSeverity severity;
  final String code;
  final String obis;
  final String description;
  final List<String> profileStatus;

  EventLogEntry({
    required this.id,
    required this.timestamp,
    required this.severity,
    required this.code,
    required this.obis,
    required this.description,
    required this.profileStatus,
  });
}

class EventType {
  final String code;
  final EventSeverity severity;
  final String desc;
  final List<String> status;
  final String obis;

  EventType({
    required this.code,
    required this.severity,
    required this.desc,
    required this.status,
    required this.obis,
  });
}

class ConsoleLogEntry {
  final DateTime time;
  final String type;
  final String message;

  ConsoleLogEntry({
    required this.time,
    required this.type,
    required this.message,
  });
}

// ===== PROFILE STATUS FLAGS =====

class ProfileStatusInfo {
  final String name;
  final Color color;
  final String tooltip;

  ProfileStatusInfo({
    required this.name,
    required this.color,
    required this.tooltip,
  });
}

class ProfileStatusFlags {
  static final Map<String, ProfileStatusInfo> _flags = {
    'PDN': ProfileStatusInfo(
      name: 'Power Down',
      color: DesignTokens.danger,
      tooltip: 'Power outage detected',
    ),
    'CAD': ProfileStatusInfo(
      name: 'Clock Adjusted',
      color: DesignTokens.info,
      tooltip: 'Clock adjusted',
    ),
    'DST': ProfileStatusInfo(
      name: 'Daylight Saving',
      color: const Color(0xFF9C27B0),
      tooltip: 'Daylight saving time change',
    ),
    'DNV': ProfileStatusInfo(
      name: 'Data Not Valid',
      color: DesignTokens.warning,
      tooltip: 'Data not valid',
    ),
    'CIV': ProfileStatusInfo(
      name: 'Clock Invalid',
      color: const Color(0xFFFF5722),
      tooltip: 'Clock invalid',
    ),
    'ERR': ProfileStatusInfo(
      name: 'Error',
      color: const Color(0xFF757575),
      tooltip: 'Generic error',
    ),
  };

  static ProfileStatusInfo getInfo(String flag) {
    return _flags[flag] ??
        ProfileStatusInfo(
          name: flag,
          color: Colors.grey,
          tooltip: 'Unknown flag',
        );
  }
}

// ===== OBIS MAPPING =====

class ObisInfo {
  final String desc;
  final String short;
  final String unit;

  ObisInfo({
    required this.desc,
    required this.short,
    required this.unit,
  });
}

class ObisMapping {
  static final Map<String, ObisInfo> _mapping = {
    '0.0.96.15.3.255':
        ObisInfo(desc: 'Standard Event Log', short: '0-0:96.15.3', unit: '-'),
    '1.0.99.98.0.255': ObisInfo(
        desc: 'Energy Load Profile', short: '1-0:99.98.0', unit: 'kWh'),
    '0.0.96.15.4.255':
        ObisInfo(desc: 'Fraud Event Log', short: '0-0:96.15.4', unit: '-'),
    '0.0.96.15.1.255':
        ObisInfo(desc: 'Quality Event Log', short: '0-0:96.15.1', unit: '-'),
    '0.0.96.15.2.255': ObisInfo(
        desc: 'Communication Event Log', short: '0-0:96.15.2', unit: '-'),
    '0.0.1.0.0.255':
        ObisInfo(desc: 'Meter Clock', short: '0-0:1.0.0', unit: 'DateTime'),
    '0.0.96.1.0.255':
        ObisInfo(desc: 'Serial Number', short: '0-0:96.1.0', unit: '-'),
    '1.0.1.8.0.255': ObisInfo(
        desc: 'Active Energy Imported', short: '1-0:1.8.0', unit: 'kWh'),
    '1.0.2.8.0.255': ObisInfo(
        desc: 'Active Energy Exported', short: '1-0:2.8.0', unit: 'kWh'),
  };

  static ObisInfo getInfo(String obisCode) {
    return _mapping[obisCode] ??
        ObisInfo(
          desc: 'DLMS Object',
          short: obisCode,
          unit: '-',
        );
  }
}
// ===== EVENT CODE DESCRIPTION CELL =====

class _EventCodeDescriptionCell extends StatelessWidget {
  const _EventCodeDescriptionCell({
    required this.statColIndex,
    required this.row,
  });

  final int statColIndex;
  final List<String> row;

  @override
  Widget build(BuildContext context) {
    if (statColIndex >= 0 && statColIndex < row.length) {
      final code = int.tryParse(row[statColIndex]);
      if (code != null) {
        final desc = EventCodeDescriptionService.instance.describe(code);
        return Tooltip(
          message: desc,
          child: Text(
            desc,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12, color: DesignTokens.textPrimaryOf(context)),
          ),
        );
      }
    }
    return const Text('-');
  }
}

// ===== EVENT CODE MAPPING =====

class EventCodeMapping {
  static final Map<String, String> _mapping = {
    '1': 'Power failure - Main power outage',
    '2': 'Power restored - Main power back',
    '3': 'Daylight saving time change',
    '4': 'Clock adjusted (old date/time)',
    '5': 'Clock adjusted (new date/time)',
    '6': 'Clock invalid',
    '50': 'Terminal cover opened',
    '51': 'Terminal cover closed',
    '52': 'Strong DC magnetic field detected',
    '53': 'No strong DC magnetic field',
    '100': 'Voltage sag L1',
    '101': 'Voltage sag L2',
    '102': 'Voltage sag L3',
    '103': 'Voltage swell L1',
    '104': 'Voltage swell L2',
    '105': 'Voltage swell L3',
    '255': 'Event log cleared',
    '506': 'Local disconnection for relay 1',
    '507': 'Local disconnection for relay 2',
    '508': 'Local reconnection for relay 1',
    '509': 'Local reconnection for relay 2',
  };

  static String getTooltip(String code) {
    return _mapping[code] ?? 'DLMS Event Code $code';
  }
}

// ---------------------------------------------------------------------------
// Registration helper — awaited in main()
// ---------------------------------------------------------------------------

/// Loads all [EventLogsConfig] from assets and registers each one
/// in [ExportRegistry] so [TemplateConfigPage] lists them.
Future<void> registerAllEventLogsPages() async {
  await EventCodeDescriptionService.instance.load();
  final configs = await EventLogsService.loadConfig();
  for (final config in configs) {
    ExportRegistry.instance.register(
      ExportedPageInfo(
        id: 'event_logs_${config.id}',
        label: config.name,
        icon: Icons.event_note,
        builder: (_) => EventLogsPage(config: config),
        tokens: const {
          'id': 'Event log config ID',
          'name': 'Event log name',
          'description': 'Event log description',
          'dataSource': 'DLMS data source reference',
          'columns': 'List of column headers',
          'rowCount': 'Total number of log entries',
          'data': 'List of rows; each row is a list of string values',
          'deviceId.*': 'Device ID field – e.g. deviceId.Logical_Device_Name',
        },
      ),
    );
  }
}
