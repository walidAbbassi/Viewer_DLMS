import 'dart:async';
import 'dart:async' show StreamController, StreamSubscription;
import 'dart:convert' show base64Encode;
import 'dart:math' show max;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:lottie/lottie.dart';
import '../../state/app_controller.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../load_profile/load_profile_config.dart';
import '../load_profile/load_profile_service.dart';
import '../../core/export/exportable_page.dart';
import '../../state/device_id_cache.dart';
import '../../core/export/export_registry.dart';
import '../../core/export/export_action_button.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/services/feedback_service.dart';

import '../widgets/class7_info_widget.dart';
import '../widgets/partial_read_widget.dart';
import '../widgets/profile_generic_chart_widget.dart';
import '../../util/profile_status.dart';
import '../../state/class7_cache.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/widget_keys.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/breadcrumb.dart';

class LoadProfilePage extends StatefulWidget {
  final LoadProfileConfig config;

  const LoadProfilePage({super.key, required this.config});

  @override
  State<LoadProfilePage> createState() => _LoadProfilePageState();
}

class _LoadProfilePageState extends State<LoadProfilePage>
    with SingleTickerProviderStateMixin
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'load_profile_${widget.config.id}';

  @override
  String get exportPageLabel => widget.config.name;

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'id': widget.config.id,
        'name': widget.config.name,
        'description': widget.config.description,
        'dataSource': widget.config.dataSource,
        'columns': _columns,
        'rowCount': _data.length,
        'data': _data,
      };

  // ---------------------------------------------------------------------------

  int? _maxRecord;
  int? _recordNumber;
  int? _capturePeriod;

  // Partial read configuration — initialised to the same defaults as
  // PartialReadWidget so validation never incorrectly rejects them.
  DateTime _partialReadStartDate =
      DateTime.now().subtract(const Duration(days: 7));
  DateTime _partialReadEndDate = DateTime.now();
  String? _partialReadStartDeviation;
  String? _partialReadEndDeviation;
  String? _partialReadStartStatus;
  String? _partialReadEndStatus;

  // True while the current table content was loaded by a partial read.
  // Page navigation must re-send the same date range so the backend keeps
  // filtering from the meter instead of falling back to the full cache.
  bool _isPartialReadActive = false;

  /// Builds the start/end objects required for a partial-read gRPC call.
  /// Returns null when we are in full-read mode.
  ({LoadProfilePartialRead start, LoadProfilePartialRead end})?
      _partialReadParams() {
    if (!_isPartialReadActive) return null;
    final start = LoadProfilePartialRead()
      ..datetime = toTimestamp(_partialReadStartDate)
      ..deviationHex = _partialReadStartDeviation ?? '8000'
      ..status = _partialReadStartStatus ?? 'Default';
    final end = LoadProfilePartialRead()
      ..datetime = toTimestamp(_partialReadEndDate)
      ..deviationHex = _partialReadEndDeviation ?? '8000'
      ..status = _partialReadEndStatus ?? 'Default';
    return (start: start, end: end);
  }

  // Pagination
  int _currentPage = 1;
  int _pageSize = 50;
  int _totalPages = 1;
  int _totalEntries = 0;

  List<List<String>> _data = [];
  List<String> _columns = [];
  late IMeterClient client;
  String? _executionMessage;
  int? _downloadPercent;
  DownloadProgress? _downloadProgress;
  Stream<GetLoadProfileStreamItem>? _stream;
  StreamController<GetLoadProfileStreamItem>? _streamController;
  StreamSubscription<GetLoadProfileStreamItem>? _gRpcSubscription;
  final ScrollController _horizontalHeaderController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();
  final Map<int, double> _columnWidths = {};
  int _profileStatusColIndex = -1;
  bool _isSyncingScroll = false;
  late final TabController _tabController;

  // ---- Chart full-dataset (all pages) -------------------------------------
  List<List<String>> _chartData = [];
  List<String> _chartColumns = [];
  bool _chartDataLoadPending = false;

  // ---- Chart capture key ---------------------------------------------------
  final GlobalKey _chartRepaintKey = GlobalKey();

  Future<String?> _captureChartAsPng() async {
    print('[Chart capture] Starting capture...');
    print('[Chart capture] Key: $_chartRepaintKey');
    print('[Chart capture] Key context: ${_chartRepaintKey.currentContext}');
    try {
      final renderObject = _chartRepaintKey.currentContext?.findRenderObject();
      print(
          '[Chart capture] RenderObject: $renderObject (type: ${renderObject?.runtimeType})');
      final boundary = renderObject as RenderRepaintBoundary?;
      if (boundary == null) {
        print(
            '[Chart capture] FAIL: boundary is null — widget not in tree or key not attached');
        return null;
      }
      print('[Chart capture] Boundary size: ${boundary.size}');
      print(
          '[Chart capture] Boundary debugNeedsPaint: ${boundary.debugNeedsPaint}');
      final image = await boundary.toImage(pixelRatio: 2.0);
      print('[Chart capture] Image size: ${image.width}x${image.height}');
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('[Chart capture] FAIL: byteData is null after toByteData()');
        return null;
      }
      print(
          '[Chart capture] SUCCESS: ${byteData.lengthInBytes} bytes captured');
      return base64Encode(byteData.buffer.asUint8List());
    } catch (e, stack) {
      print('[Chart capture] EXCEPTION: $e');
      print('[Chart capture] Stack: $stack');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Auto-read Class 7 attributes sequentially, then start the stream
    client = meterClientFactory();
    _initSequential();
    // Pre-fill from cache for instant display
    final cached = Class7Cache.get(widget.config.dataSource);
    if (cached != null) {
      _columns = List.from(cached.headers);
      _data = List.from(cached.data);
      _profileStatusColIndex = findProfileStatusColumnIndex(_columns);
      _calculateColumnWidths(_data, _columns);
    }
    // Sync horizontal scrolling between header and body with throttling
    _horizontalHeaderController.addListener(_syncHeaderToBody);
    _horizontalBodyController.addListener(_syncBodyToHeader);
    // Initialize stream only if a data source is configured.
    // page=0 tells the backend: "do a full read, then show me the LAST page"
    // (most recent entries first)
  }

  Future<void> _initSequential() async {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    if (!isConnected) return;
    await _readClass7Attributes();
    if (!mounted) return;
    if (widget.config.dataSource.isNotEmpty) {
      _initStream(client.getLoadProfile(widget.config.dataSource,
          page: 0, pageSize: _pageSize));
    }
  }

  void _syncHeaderToBody() {
    if (_isSyncingScroll) return;
    if (_horizontalHeaderController.hasClients &&
        _horizontalBodyController.hasClients) {
      final offset = _horizontalHeaderController.offset;
      if ((_horizontalBodyController.offset - offset).abs() > 1.0) {
        _isSyncingScroll = true;
        _horizontalBodyController.jumpTo(offset);
        Future.microtask(() => _isSyncingScroll = false);
      }
    }
  }

  void _syncBodyToHeader() {
    if (_isSyncingScroll) return;
    if (_horizontalBodyController.hasClients &&
        _horizontalHeaderController.hasClients) {
      final offset = _horizontalBodyController.offset;
      if ((_horizontalHeaderController.offset - offset).abs() > 1.0) {
        _isSyncingScroll = true;
        _horizontalHeaderController.jumpTo(offset);
        Future.microtask(() => _isSyncingScroll = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _gRpcSubscription?.cancel();
    _streamController?.close();
    unawaited(client.close());
    _setMeterOpInProgress(false);
    _horizontalHeaderController.removeListener(_syncHeaderToBody);
    _horizontalBodyController.removeListener(_syncBodyToHeader);
    _horizontalHeaderController.dispose();
    _horizontalBodyController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  /// Sets or clears the global meter-operation-in-progress flag so the
  /// navigation drawer can block page switches while data is being retrieved.
  void _setMeterOpInProgress(bool v) {
    if (!mounted) return;
    ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider.notifier)
        .setMeterOperationInProgress(v);
  }

  /// Sets up a stream without calling setState (safe for initState).
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

  /// Cancels any running read and starts a new one, rebuilding the widget.
  void _startRead(Stream<GetLoadProfileStreamItem> grpcStream) {
    _setMeterOpInProgress(true);
    _gRpcSubscription?.cancel();
    _streamController?.close();
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

  /// Resets the chart full-dataset whenever a new read starts.
  void _resetChartData() {
    _chartData = [];
    _chartColumns = [];
    _chartDataLoadPending = false;
  }

  /// Fetches ALL profile entries in a single gRPC call (served instantly from
  /// the backend's server-side cache) and stores them in [_chartData].
  /// Only called when [_totalPages] > 1.
  Future<void> _loadAllChartData() async {
    // Abort immediately if a partial read is already in progress.
    if (_isPartialReadActive) return;
    final targetSize = _totalEntries;
    if (targetSize <= 0 || !mounted) return;
    try {
      final allStream = client.getLoadProfile(
        widget.config.dataSource,
        page: 1,
        pageSize: targetSize,
      );
      await for (final item in allStream) {
        // If a partial read started while we were waiting, stop immediately
        // so we don't send RST_STREAM while the new gRPC stream is being set up.
        if (_isPartialReadActive) break;
        if (item.whichItem() == GetLoadProfileStreamItem_Item.result) {
          if (!mounted || _isPartialReadActive) return;
          setState(() {
            _chartColumns =
                item.result.headerTypes.map((h) => h.toString()).toList();
            _chartData = item.result.values
                .map((sl) => sl.items.map((v) => v.toString()).toList())
                .toList();
          });
          break;
        }
      }
    } catch (_) {
      // Silently fall back – chart will use current page data.
    } finally {
      // Don't reset the pending flag if a partial read took over –
      // _resetChartData() already cleared it.
      if (mounted && !_isPartialReadActive)
        setState(() => _chartDataLoadPending = false);
    }
  }

  /// Cancels the current read and hides the loading overlay.
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

  void _showErrorMessage(BuildContext context, String message) {
    feedback.error(message);
  }

  void _showSuccessMessage(BuildContext context, String message) {
    feedback.success(message);
  }

  String _formatBytesPerSec(double bytesPerSec) {
    if (bytesPerSec >= 1024 * 1024) {
      return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    } else if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(2)} KB/s';
    } else {
      return '${bytesPerSec.toStringAsFixed(2)} B/s';
    }
  }

  String _calculateEstimatedTime(DownloadProgress progress) {
    if (!progress.hasBytesTotal() ||
        !progress.hasBytesRead() ||
        !progress.hasRateBytesPerSec() ||
        progress.rateBytesPerSec <= 0) {
      return 'Calculating...';
    }

    final bytesTotal = progress.bytesTotal.toInt();
    final bytesRead = progress.bytesRead.toInt();
    final bytesRemaining = bytesTotal - bytesRead;

    if (bytesRemaining <= 0) {
      return 'Almost done...';
    }

    final secondsRemaining = bytesRemaining / progress.rateBytesPerSec;
    final duration = Duration(seconds: secondsRemaining.toInt());

    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours.remainder(24)}h ${duration.inMinutes.remainder(60)}m';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m ${duration.inSeconds.remainder(60)}s';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
    } else {
      return '${duration.inSeconds}s';
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
      return await client.getLoadProfileMaxRecords(widget.config.dataSource);
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
      rethrow;
    }
  }

  Future<void> _setMaxRecord(int value) async {
    try {
      final success = await client.setLoadProfileMaxRecords(
          widget.config.dataSource, value);
      if (!success) {
        throw Exception('Failed to set max record');
      }
      setState(() {
        _maxRecord = value;
      });
      if (mounted) {
        _showSuccessMessage(context, 'Max record set successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
      rethrow;
    }
  }

  Future<int> _readRecordNumber() async {
    try {
      return await client.getLoadProfileRecordNumber(widget.config.dataSource);
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
      rethrow;
    }
  }

  Future<void> _setRecordNumber(int value) async {
    try {
      final success = await client.setLoadProfileRecordNumber(
          widget.config.dataSource, value);
      if (!success) {
        throw Exception('Failed to set record number');
      }
      setState(() {
        _recordNumber = value;
      });
      if (mounted) {
        _showSuccessMessage(context, 'Record number set successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
      rethrow;
    }
  }

  Future<int> _readCapturePeriod() async {
    try {
      return await client.getLoadProfileCapturePeriod(widget.config.dataSource);
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
      rethrow;
    }
  }

  Future<void> _setCapturePeriod(int value) async {
    try {
      final success = await client.setLoadProfileCapturePeriod(
          widget.config.dataSource, value);
      if (!success) {
        throw Exception('Failed to set capture period');
      }
      setState(() {
        _capturePeriod = value;
      });
      if (mounted) {
        _showSuccessMessage(context, 'Capture period set successfully');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
      rethrow;
    }
  }

  void _performPartialRead() {
    try {
      // Create LoadProfilePartialRead objects
      final start = LoadProfilePartialRead()
        ..datetime = toTimestamp(_partialReadStartDate)
        ..deviationHex = _partialReadStartDeviation ?? '8000'
        ..status = _partialReadStartStatus ?? 'Default';

      final end = LoadProfilePartialRead()
        ..datetime = toTimestamp(_partialReadEndDate)
        ..deviationHex = _partialReadEndDeviation ?? '8000'
        ..status = _partialReadEndStatus ?? 'Default';

      // Cancel and null out the previous subscription/controller before
      // starting a fresh one.  Keeping stale non-null references would cause
      // _startRead to call cancel() a second time on an already-cancelled
      // subscription, which can race with the new stream setup.
      _gRpcSubscription?.cancel();
      _gRpcSubscription = null;
      _streamController?.close();
      _streamController = null;
      _isPartialReadActive = true;
      setState(() {
        _stream = null;
        _data.clear();
        _columns.clear();
        _resetChartData();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startRead(client.getLoadProfile(
          widget.config.dataSource,
          start: start,
          end: end,
          page: 0, // last page (most recent entries first)
          pageSize: _pageSize,
        ));
      });

      _showSuccessMessage(context, 'Partial read started');
    } catch (e) {
      _showErrorMessage(context, _extractErrorMessage(e));
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages || page == _currentPage) return;
    // For full reads: backend serves from cache instantly.
    // For partial reads: re-send the same date range so the backend keeps
    // filtering from the meter instead of falling back to the full cache.
    final params = _partialReadParams();
    setState(() {
      _currentPage = page;
      _stream = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _stream = client.getLoadProfile(
          widget.config.dataSource,
          start: params?.start,
          end: params?.end,
          page: page,
          pageSize: _pageSize,
        );
      });
    });
  }

  void _calculateColumnWidths(List<List<String>> data, List<String> columns) {
    final textStyle = const TextStyle(fontSize: 14);
    final headerStyle =
        const TextStyle(fontSize: 14, fontWeight: FontWeight.bold);

    for (int col = 0; col < columns.length; col++) {
      double maxWidth = 0;

      // Measure header
      final headerText = TextPainter(
        text: TextSpan(text: columns[col], style: headerStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      maxWidth = headerText.size.width;

      // Measure sample data cells (check first 100 rows for performance)
      final sampleSize = data.length > 100 ? 100 : data.length;
      for (int row = 0; row < sampleSize; row++) {
        if (row < data.length && col < data[row].length) {
          final cellText = TextPainter(
            text: TextSpan(text: data[row][col], style: textStyle),
            textDirection: TextDirection.ltr,
          )..layout();
          if (cellText.size.width > maxWidth) {
            maxWidth = cellText.size.width;
          }
        }
      }

      // Add padding: header always wins — never cap below full header width.
      final headerMinWidth = headerText.size.width + 24;
      final dataWidth = (maxWidth + 24).clamp(100.0, 400.0);
      _columnWidths[col] = max(headerMinWidth, dataWidth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GetLoadProfileStreamItem>(
      stream: _stream,
      builder: (context, snapshot) {
        String? currentExecutionMessage = _executionMessage;
        int? currentDownloadPercent = _downloadPercent;
        List<List<String>> currentData = _data;
        List<String> currentColumns = _columns;

        // Process stream items
        if (snapshot.hasData) {
          final item = snapshot.data!;
          final itemType = item.whichItem();
          switch (itemType) {
            case GetLoadProfileStreamItem_Item.exec:
              final exec = item.exec;
              if (exec.hasMessage() && exec.message.isNotEmpty) {
                currentExecutionMessage = exec.message;
                _executionMessage = currentExecutionMessage;
              }
              break;
            case GetLoadProfileStreamItem_Item.download:
              _downloadProgress = item.download;
              _downloadPercent = _downloadProgress?.percent;
              currentDownloadPercent = _downloadPercent;
              break;
            case GetLoadProfileStreamItem_Item.result:
              final response = item.result;
              _columns = response.headerTypes.map((h) => h.toString()).toList();
              _data = response.values
                  .map((stringList) =>
                      stringList.items.map((v) => v.toString()).toList())
                  .toList();
              // --- Pagination metadata ---
              _totalEntries = response.totalEntries;
              _currentPage = response.currentPage;
              _totalPages = response.totalPages;
              currentColumns = _columns;
              currentData = _data;
              _profileStatusColIndex = findProfileStatusColumnIndex(_columns);
              _calculateColumnWidths(currentData, currentColumns);
              // Save to cache for instant display on next visit
              Class7Cache.put(widget.config.dataSource, _columns, _data);
              // ---- Update chart full-dataset --------------------------------
              if (_totalPages <= 1) {
                // Single page: all data is already here.
                _chartColumns = _columns;
                _chartData = _data;
              } else if (_chartData.isEmpty &&
                  !_chartDataLoadPending &&
                  !_isPartialReadActive) {
                // Multi-page: request all rows in one shot from backend cache.
                // Guard: don't start while a partial read is being set up, because
                // the concurrent gRPC stream + its cancellation (break) disturbs
                // the shared HTTP/2 connection and kills the partial-read stream.
                _chartDataLoadPending = true;
                _loadAllChartData();
              }
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
                    currentColumns.isEmpty));

        final String? _currentModuleName =
            ProviderScope.containerOf(context, listen: false)
                .read(appControllerProvider)
                .moduleName;
        final bool _isLocalManagement = _currentModuleName == 'LocalManagement';
        final bool _isConnected =
            ProviderScope.containerOf(context, listen: false)
                .read(appControllerProvider)
                .isConnected;

        final sc = SemanticColors.of(context);
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(widget.config.name),
                backgroundColor: sc.primary,
                foregroundColor: Colors.white,
                automaticallyImplyLeading: false,
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(
                        key: Key(LoadProfileKeys.tableTabBtn),
                        icon: Icon(Icons.table_chart, size: 18),
                        text: 'Table'),
                    Tab(
                        key: Key(LoadProfileKeys.chartTabBtn),
                        icon: Icon(Icons.show_chart, size: 18),
                        text: 'Chart'),
                  ],
                ),
                actions: [
                  ExportActionButton(
                    key: const Key(LoadProfileKeys.exportBtn),
                    pageId: exportPageId,
                    pageType: 'load_profile',
                    dataGetter: getExportData,
                    iconColor: Colors.white,
                    chartImageGetter: _captureChartAsPng,
                    onChartTabRequested: () => _tabController.animateTo(1),
                  ),
                  RefreshAppBarButton(
                    key: const Key(LoadProfileKeys.refreshBtn),
                    onPressed: () {
                      setState(() {
                        _stream = null;
                        _data.clear();
                        _columns.clear();
                        _resetChartData();
                        _isPartialReadActive = false;
                        _gRpcSubscription?.cancel();
                        _streamController?.close();
                      });
                      Class7Cache.invalidate(widget.config.dataSource);
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _startRead(client.getLoadProfile(
                            widget.config.dataSource,
                            page: 0,
                            pageSize: _pageSize));
                      });
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
                    child: Breadcrumb(
                        segments: ['Menu', 'Load Profiles', widget.config.name]),
                  ),
                  Expanded(
                    child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 0: Data Table ──────────────────────────────────────────────
                  CustomScrollView(slivers: [
                    // --- Class 7 Info Widget and Partial Read Widget in the same row ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Class7InfoWidget(
                                featureKey: FeatureKeys.loadProfile,
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
                                featureKey: FeatureKeys.loadProfile,
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
                      ),
                    ),
                    // Description section
                    SliverToBoxAdapter(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: DesignTokens.surfaceOf(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.config.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: DesignTokens.textSecondaryOf(context),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Total records: ${currentData.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondaryOf(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Full Read button row — directly above the table, right-aligned
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              key: const Key(LoadProfileKeys.fullReadBtn),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Full Read'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              onPressed: (_isConnected &&
                                      userRights.hasRightForFeature(
                                          'Get', FeatureKeys.loadProfile))
                                  ? () {
                                      setState(() {
                                        _stream = null;
                                        _data.clear();
                                        _columns.clear();
                                        _resetChartData();
                                        _isPartialReadActive = false;
                                        _gRpcSubscription?.cancel();
                                        _streamController?.close();
                                      });
                                      Class7Cache.invalidate(
                                          widget.config.dataSource);
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        _startRead(client.getLoadProfile(
                                            widget.config.dataSource,
                                            page: 0,
                                            pageSize: _pageSize));
                                      });
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Table + pagination fill the remaining viewport
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: Column(
                        children: [
                          Expanded(
                            child:
                                _buildVirtualTable(currentData, currentColumns),
                          ),
                          if (_totalPages > 0) _buildPaginationBar(),
                        ],
                      ),
                    ),
                  ]),
                  // ── Tab 1: Chart ───────────────────────────────────────────────────
                  RepaintBoundary(
                    key: _chartRepaintKey,
                    child: ProfileGenericChartWidget(
                      columns: _chartColumns.isNotEmpty
                          ? _chartColumns
                          : currentColumns,
                      data: _chartData.isNotEmpty ? _chartData : currentData,
                    ),
                  ),
                ],
              ),
                  ),
                ],
              ),
            ),
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
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
                          // Execution message
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
                          // Download progress
                          if (currentDownloadPercent != null &&
                              _downloadProgress != null) ...[
                            const SizedBox(height: 24),
                            // Check if rowsTotal == 0 (packet count mode)
                            if (!_downloadProgress!.hasRowsTotal() ||
                                _downloadProgress!.rowsTotal.toInt() == 0) ...[
                              // Only show percent (packet count) without progress bar
                              Text(
                                'Packets received: $currentDownloadPercent',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              // Normal download progress with progress bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Downloading: $currentDownloadPercent%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF1976D2),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: 300,
                                      child: LinearProgressIndicator(
                                        value: currentDownloadPercent / 100.0,
                                        backgroundColor: Colors.grey.shade300,
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Color(0xFF1976D2)),
                                        minHeight: 8,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    if (_downloadProgress!
                                            .hasRateBytesPerSec() &&
                                        _downloadProgress!.rateBytesPerSec >
                                            0) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'Rate: ${_formatBytesPerSec(_downloadProgress!.rateBytesPerSec)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                    if (_downloadProgress!.hasBytesTotal() &&
                                        _downloadProgress!.hasBytesRead() &&
                                        _downloadProgress!
                                            .hasRateBytesPerSec() &&
                                        _downloadProgress!.rateBytesPerSec >
                                            0) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Estimated time: ${_calculateEstimatedTime(_downloadProgress!)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ], // Abort button
                          const SizedBox(height: 28),
                          ElevatedButton.icon(
                            key: const Key(LoadProfileKeys.abortBtn),
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

  Widget _buildVirtualTable(List<List<String>> data, List<String> columns) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Account for border width (1px on each side = 2px total)
        final borderWidth = 2.0;
        final availableWidth = constraints.maxWidth - borderWidth;
        final totalWidth = _columnWidths.isEmpty
            ? 0.0
            : _columnWidths.values.fold(0.0, (sum, width) => sum + width);
        final needsHorizontalScroll =
            totalWidth > availableWidth && totalWidth > 0;
        final tableWidth = needsHorizontalScroll ? totalWidth : availableWidth;

        // Adjust column widths to fill available space if no horizontal scroll needed
        final adjustedColumnWidths = Map<int, double>.from(_columnWidths);
        if (!needsHorizontalScroll && _columnWidths.isNotEmpty) {
          final currentTotal = totalWidth;
          if (currentTotal > 0) {
            // Calculate ratio to fit exactly within available width
            final ratio = availableWidth / currentTotal;
            double adjustedTotal = 0.0;

            // Scale all columns proportionally
            for (int i = 0; i < adjustedColumnWidths.length; i++) {
              adjustedColumnWidths[i] = (adjustedColumnWidths[i]! * ratio);
              adjustedTotal += adjustedColumnWidths[i]!;
            }

            // Adjust for any rounding differences to ensure exact fit
            final difference = availableWidth - adjustedTotal;
            if (difference.abs() > 0.01 && adjustedColumnWidths.isNotEmpty) {
              // Distribute the difference to the last column
              final lastIndex = adjustedColumnWidths.length - 1;
              adjustedColumnWidths[lastIndex] =
                  adjustedColumnWidths[lastIndex]! + difference;
            }
          }
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: DesignTokens.surfaceOf(context),
            border: Border.all(color: DesignTokens.borderOf(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Fixed header with horizontal scroll
              _buildTableHeader(columns, adjustedColumnWidths, tableWidth,
                  needsHorizontalScroll),
              // Scrollable body with virtual scrolling - vertical scrollbar always at right edge
              Expanded(
                child: Scrollbar(
                  controller: _verticalScrollController,
                  thumbVisibility: true,
                  thickness: 12.0,
                  radius: const Radius.circular(6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Content area with horizontal scrolling
                      Expanded(
                        child: needsHorizontalScroll
                            ? Scrollbar(
                                controller: _horizontalBodyController,
                                thumbVisibility: true,
                                thickness: 12.0,
                                radius: const Radius.circular(6),
                                child: SingleChildScrollView(
                                  controller: _horizontalBodyController,
                                  scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    width: tableWidth,
                                    child: _buildTableBody(
                                        data, columns, adjustedColumnWidths),
                                  ),
                                ),
                              )
                            : _buildTableBody(
                                data, columns, adjustedColumnWidths),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaginationBar() {
    final textColor = DesignTokens.textPrimaryOf(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceAltOf(context),
        border: Border(top: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Total entries info
          Text(
            '$_totalEntries entries',
            style: TextStyle(
                fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
          ),
          const SizedBox(width: 24),
          // First page button
          IconButton(
            key: const Key(LoadProfileKeys.firstPageBtn),
            icon: Icon(Icons.first_page, color: textColor),
            onPressed: _currentPage > 1 ? () => _goToPage(1) : null,
            tooltip: 'First page',
          ),
          // Previous button
          IconButton(
            key: const Key(LoadProfileKeys.prevPageBtn),
            icon: Icon(Icons.chevron_left, color: textColor),
            onPressed:
                _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
            tooltip: 'Previous',
          ),
          // Page indicator
          Text(
            'Page $_currentPage / $_totalPages',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
          ),
          // Next button
          IconButton(
            key: const Key(LoadProfileKeys.nextPageBtn),
            icon: Icon(Icons.chevron_right, color: textColor),
            onPressed: _currentPage < _totalPages
                ? () => _goToPage(_currentPage + 1)
                : null,
            tooltip: 'Next',
          ),
          // Last page button
          IconButton(
            key: const Key(LoadProfileKeys.lastPageBtn),
            icon: Icon(Icons.last_page, color: textColor),
            onPressed: _currentPage < _totalPages
                ? () => _goToPage(_totalPages)
                : null,
            tooltip: 'Last page (most recent)',
          ),
          const SizedBox(width: 24),
          // Page size selector
          Text('Page size: ', style: TextStyle(fontSize: 13, color: textColor)),
          DropdownButton<int>(
            key: const Key(LoadProfileKeys.pageSizeDropdown),
            value: _pageSize,
            dropdownColor: DesignTokens.surfaceOf(context),
            style: TextStyle(fontSize: 13, color: textColor),
            items: const [
              DropdownMenuItem(value: 25, child: Text('25')),
              DropdownMenuItem(value: 50, child: Text('50')),
              DropdownMenuItem(value: 100, child: Text('100')),
              DropdownMenuItem(value: 200, child: Text('200')),
            ],
            onChanged: (value) {
              if (value != null && value != _pageSize) {
                final params = _partialReadParams();
                setState(() {
                  _pageSize = value;
                  _currentPage = 0; // last page of new size
                  _stream = null;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _stream = client.getLoadProfile(
                      widget.config.dataSource,
                      start: params?.start,
                      end: params?.end,
                      page: 0,
                      pageSize: _pageSize,
                    );
                  });
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTableBody(List<List<String>> data, List<String> columns,
      Map<int, double> columnWidths) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView.builder(
          controller: _verticalScrollController,
          itemCount: data.length,
          cacheExtent: 50,
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          shrinkWrap: false,
          itemExtent: 40.0,
          itemBuilder: (context, index) {
            return SizedBox(
              width: constraints.maxWidth,
              child: _TableRowWidget(
                key: ValueKey('row_$index'),
                row: data[index],
                index: index,
                isEven: index % 2 == 0,
                columns: columns,
                columnWidths: columnWidths,
                totalRows: data.length,
                profileStatusColIndex: _profileStatusColIndex,
              ),
            );
          },
        );
      },
    );
  }

  /// Parses a header string of the form "Name ( obis ) unit" into two lines.
  /// Returns (objectName, obisAndUnit). If no parentheses, returns (column, '').
  (String, String) _parseColumnHeader(String column) {
    final parenStart = column.indexOf(' ( ');
    if (parenStart == -1) return (column, '');
    final name = column.substring(0, parenStart).trim();
    final rest = column.substring(parenStart + 3);
    final parenEnd = rest.indexOf(' )');
    if (parenEnd == -1) return (name, rest.trim());
    final obis = rest.substring(0, parenEnd).trim();
    final unit = rest.substring(parenEnd + 2).trim();
    return (name, unit.isNotEmpty ? '($obis)  $unit' : '($obis)');
  }

  Widget _buildTableHeader(List<String> columns, Map<int, double> columnWidths,
      double tableWidth, bool needsHorizontalScroll) {
    final isDark = DesignTokens.isDark(context);
    final headerTextColor = isDark ? Colors.white : const Color(0xFF1976D2);
    final headerBorder = DesignTokens.borderOf(context);
    final headerRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: columns.asMap().entries.map((entry) {
        final index = entry.key;
        final column = entry.value;
        final width = columnWidths[index] ?? 150.0;
        return Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: headerBorder,
                width: index < columns.length - 1 ? 1 : 0,
              ),
            ),
          ),
          child: Tooltip(
            message: column,
            child: Builder(builder: (context) {
              final (objectName, obisAndUnit) = _parseColumnHeader(column);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    objectName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: headerTextColor,
                      height: 1.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (obisAndUnit.isNotEmpty)
                    Text(
                      obisAndUnit,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 11,
                        color: headerTextColor.withOpacity(0.75),
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              );
            }),
          ),
        );
      }).toList(),
    );

    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DesignTokens.darkSurfaceAlt : const Color(0xFFE3F2FD),
        ),
        child: needsHorizontalScroll
            ? Scrollbar(
                controller: _horizontalHeaderController,
                thumbVisibility: true,
                thickness: 12.0,
                radius: const Radius.circular(6),
                child: SingleChildScrollView(
                  controller: _horizontalHeaderController,
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: tableWidth, child: headerRow),
                ),
              )
            : SizedBox(
                width: double.infinity,
                child: headerRow,
              ),
      ),
    );
  }
}

// Extracted row widget for better performance and recycling
class _TableRowWidget extends StatelessWidget {
  final List<String> row;
  final int index;
  final bool isEven;
  final List<String> columns;
  final Map<int, double> columnWidths;
  final int totalRows;
  final int profileStatusColIndex;

  const _TableRowWidget({
    super.key,
    required this.row,
    required this.index,
    required this.isEven,
    required this.columns,
    required this.columnWidths,
    required this.totalRows,
    this.profileStatusColIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    final surface = DesignTokens.surfaceOf(context);
    final surfaceAlt = DesignTokens.surfaceAltOf(context);
    final border = DesignTokens.borderOf(context);
    final textColor = DesignTokens.textPrimaryOf(context);
    return ClipRect(
      child: Container(
        color: isEven ? surface : surfaceAlt,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(columns.length, (colIndex) {
            final width = columnWidths[colIndex] ?? 150.0;
            final cellValue = colIndex < row.length ? row[colIndex] : '';

            return Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: border,
                    width: colIndex < columns.length - 1 ? 1 : 0,
                  ),
                  bottom: BorderSide(
                    color: border,
                    width: index < totalRows - 1 ? 1 : 0,
                  ),
                ),
              ),
              child: colIndex == profileStatusColIndex
                  ? ProfileStatusCell(value: cellValue)
                  : Text(
                      cellValue,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            );
          }),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Registration helper — awaited in main()
// ---------------------------------------------------------------------------

/// Loads all [LoadProfileConfig] from assets and registers each one
/// in [ExportRegistry] so [TemplateConfigPage] lists them.
Future<void> registerAllLoadProfilePages() async {
  final configs = await LoadProfileService.loadConfig();
  for (final config in configs) {
    ExportRegistry.instance.register(
      ExportedPageInfo(
        id: 'load_profile_${config.id}',
        label: config.name,
        icon: Icons.bar_chart,
        builder: (_) => LoadProfilePage(config: config),
        tokens: const {
          'name': 'Report / page name',
          'description': 'Page description',
          'dataSource': 'DLMS data source reference',
          'columns': 'List of column headers',
          'rowCount': 'Total number of data rows',
          'data': 'List of rows; each row is a list of string values',
          'deviceId.*': 'Device ID field – e.g. deviceId.Logical_Device_Name',
        },
      ),
    );
  }
}
