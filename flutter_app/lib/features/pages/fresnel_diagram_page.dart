import 'dart:math';
import 'dart:ui' as ui;
import 'dart:convert' show base64Encode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../util/grpc_error.dart';
import '../../state/app_controller.dart';
import 'package:flutter/rendering.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:lottie/lottie.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/services/feedback_service.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/meter_client.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/widget_keys.dart';
import '../../core/export/exportable_page.dart';
import '../../core/export/export_action_button.dart';
import '../../core/export/export_registry.dart';
import '../../state/device_id_cache.dart';

/// Fresnel Diagram Page - Adapted for NG-SDK project
class FresnelDiagramPage extends StatefulWidget {
  const FresnelDiagramPage({super.key});

  @override
  State<FresnelDiagramPage> createState() => _FresnelDiagramPageState();
}

class _FresnelDiagramPageState extends State<FresnelDiagramPage>
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'fresnel';

  @override
  String get exportPageLabel => 'Fresnel Diagram';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'phases': {
          for (final e in _phases.entries)
            e.key: {
              'u': e.value.u,
              'i': e.value.i,
              'phi': e.value.phi,
            },
        },
        'lastRefresh': _lastRefresh.toIso8601String(),
      };

  // ---- Diagram capture key -------------------------------------------------
  // (kept so RepaintBoundary compiles, but capture uses PictureRecorder)
  final GlobalKey _diagramRepaintKey = GlobalKey();

  Future<String?> _captureChartAsPng() async {
    print('[Fresnel capture] Starting off-screen capture...');
    print(
        '[Fresnel capture] phases: ${_phases.keys.toList()}, uRef: $_uRef, iRef: $_iRef');
    try {
      const w = 900.0;
      // Heights for each section
      const phasorH = 520.0;
      const gap = 20.0;
      const sineH = 260.0;
      const perPhaseH = 200.0;
      const sectionLabelH = 28.0;
      const totalH = phasorH +
          gap +
          sectionLabelH +
          sineH +
          gap +
          sectionLabelH +
          perPhaseH;

      print(
          '[Fresnel capture] Creating PictureRecorder canvas ${w.toInt()}x${totalH.toInt()}');
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w, totalH));

      // White background for the whole canvas
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, totalH),
        Paint()..color = Colors.white,
      );

      // ── Section 1: Phasor diagram ──────────────────────────────────
      FresnelDiagramPainter(
        phases: _phases,
        uRef: _uRef,
        iRef: _iRef,
        includeMinidiagrams: true,
      ).paint(canvas, const Size(w, phasorH));

      double y = phasorH + gap;

      // ── Section 2: Combined sinusoidal waveforms ───────────────────
      _paintSectionLabel(canvas, 'Sinusoidal Waveforms', Offset(8, y));
      y += sectionLabelH;
      canvas.save();
      canvas.translate(0, y);
      SinusoidalPainter(phases: _phases, uRef: _uRef, iRef: _iRef)
          .paint(canvas, const Size(w, sineH));
      canvas.restore();
      y += sineH + gap;

      // ── Section 3: Per-phase sinusoidal charts ─────────────────────
      _paintSectionLabel(
          canvas, 'Per-Phase Waveforms (U solid / I dashed)', Offset(8, y));
      y += sectionLabelH;
      const phaseKeys = ['U1', 'U2', 'U3'];
      const phaseColors = [
        Color(0xFF2196F3),
        Color(0xFF4CAF50),
        Color(0xFFFF9800)
      ];
      final phaseW = (w - 2 * gap) / 3;
      for (int i = 0; i < 3; i++) {
        final phase = _phases[phaseKeys[i]];
        if (phase == null) continue;
        final offsetX = i * (phaseW + gap);
        // Draw border rect for mini chart
        canvas.drawRect(
          Rect.fromLTWH(offsetX, y, phaseW, perPhaseH),
          Paint()
            ..color = const Color(0xFFE5E7EB)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1,
        );
        // Phase label + phi
        final tp = TextPainter(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${phaseKeys[i]}  ',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: phaseColors[i]),
              ),
              TextSpan(
                text: 'φ = ${phase.phi.toStringAsFixed(2)}°',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(offsetX + 6, y + 4));

        canvas.save();
        canvas.translate(offsetX, y + 20);
        PerPhaseSinusoidalPainter(
          phase: phase,
          uRef: _uRef,
          iRef: _iRef,
          color: phaseColors[i],
        ).paint(canvas, Size(phaseW, perPhaseH - 20));
        canvas.restore();
      }

      print('[Fresnel capture] All sections painted, ending recording');
      final picture = recorder.endRecording();
      final image = await picture.toImage(w.toInt(), totalH.toInt());
      print('[Fresnel capture] toImage() done: ${image.width}x${image.height}');
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        print('[Fresnel capture] FAIL: byteData is null');
        return null;
      }
      print('[Fresnel capture] SUCCESS: ${byteData.lengthInBytes} bytes');
      return base64Encode(byteData.buffer.asUint8List());
    } catch (e, stack) {
      print('[Fresnel capture] EXCEPTION: $e');
      print('[Fresnel capture] Stack: $stack');
      return null;
    }
  }

  void _paintSectionLabel(Canvas canvas, String text, Offset position) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1976D2)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, position);
  }

  // ---------------------------------------------------------------------------

  late IMeterClient _client;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _loadInitialFresnelData();
  }

  Future<void> _loadInitialFresnelData() async {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    if (!isConnected) {
      if (mounted) setState(() => _isInitialLoading = false);
      return;
    }
    try {
      final phases = await _client.getFresnelData();
      final phasesMap = phases
          .asMap()
          .map((index, phase) => MapEntry('U${index + 1}', phase));
      if (mounted)
        setState(() {
          _phases = phasesMap;
          _isInitialLoading = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _isInitialLoading = false);
        feedback.error(extractGrpcMessage(e));
      }
    }
  }

  // Polling state
  bool _isRunning = false;

  // Reference values
  double _uRef = 230.0;
  double _iRef = 5.0;

  // Polling interval
  int _pollInterval = 1000;
  final TextEditingController _pollIntervalCtrl =
      TextEditingController(text: '1');

  // Phase data
  Map<String, PhaseData> _phases = {
    'U1': PhaseData(u: 0.0, i: 0.0, phi: 0.0),
    'U2': PhaseData(u: 0.0, i: 0.0, phi: 0.0),
    'U3': PhaseData(u: 0.0, i: 0.0, phi: 0.0)
  };

  // Last refresh time
  DateTime _lastRefresh = DateTime.now();

  @override
  void dispose() {
    _pollIntervalCtrl.dispose();
    _isRunning = false;
    super.dispose();
  }

  void _startSimulation() {
    if (_isRunning) return;
    setState(() => _isRunning = true);
    _pollLoop();
  }

  void _stopSimulation() {
    setState(() => _isRunning = false);
  }

  Future<void> _pollLoop() async {
    while (_isRunning && mounted) {
      try {
        final phases = await _client.getFresnelData();
        if (!_isRunning || !mounted) break;
        final phasesMap = phases
            .asMap()
            .map((index, phase) => MapEntry('U${index + 1}', phase));
        setState(() {
          _phases = phasesMap;
          _lastRefresh = DateTime.now();
        });
      } catch (e) {
        if (mounted) {
          _stopSimulation();
          feedback.error(extractGrpcMessage(e));
        }
        break;
      }
      if (!_isRunning || !mounted) break;
      await Future.delayed(Duration(milliseconds: _pollInterval));
    }
  }

  void _simulateStep() {
    final random = Random();
    for (var phase in _phases.values) {
      phase.u = (phase.u + (random.nextDouble() - 0.5) * 2).clamp(200.0, 250.0);
      phase.i = (phase.i + (random.nextDouble() - 0.5) * 0.2).clamp(0.1, 10.0);
      phase.phi = _clampAngle(phase.phi + (random.nextDouble() - 0.5) * 2);
    }
  }

  void _resetValues() {
    setState(() {
      _uRef = 230.0;
      _iRef = 5.0;
      _phases['U1'] = PhaseData(u: 230.0, i: 5.0, phi: 15.0);
      _phases['U2'] = PhaseData(u: 230.0, i: 4.6, phi: -25.0);
      _phases['U3'] = PhaseData(u: 230.0, i: 4.9, phi: 35.0);
    });
  }

  double _clampAngle(double deg) {
    return ((deg % 360) + 360) % 360;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fresnel Diagram'),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          ExportActionButton(
            key: const Key(FresnelDiagramKeys.exportBtn),
            pageId: exportPageId,
            pageType: 'fresnel',
            dataGetter: getExportData,
            iconColor: Colors.white,
            chartImageGetter: _captureChartAsPng,
          ),
          RefreshAppBarButton(
            key: const Key(FresnelDiagramKeys.refreshBtn),
            onPressed: () {
              _stopSimulation();
              _startSimulation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildDataSourceTable(),
                        const SizedBox(height: 16),
                        _buildConfigurationCard(),
                        const SizedBox(height: 16),
                        _buildMetricsCard(),
                        const SizedBox(height: 16),
                        _buildDiagramCard(),
                        const SizedBox(height: 16),
                        _buildSinusoidalCard(),
                      ],
                    ),
                  ),
                ),
                _buildStatusBar(),
              ],
            ),
          ),
          if (_isInitialLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: Lottie.asset(
                    'assets/animations/data.json',
                    width: 200,
                    height: 200,
                    errorBuilder: (context, err, stack) =>
                        const CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
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
                          color: DesignTokens.textSecondaryOf(context), fontSize: 13),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: DesignTokens.textSecondaryOf(context)),
                    Text(
                      'Measurements',
                      style: TextStyle(
                          color: DesignTokens.textSecondaryOf(context), fontSize: 13),
                    ),
                    Icon(Icons.chevron_right,
                        size: 16, color: DesignTokens.textSecondaryOf(context)),
                    Text(
                      'Fresnel Diagram',
                      style: TextStyle(
                          color: DesignTokens.primary600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Fresnel Diagram',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Real-time visualization of voltage and current phasors (U1, U2, U3 & I1, I2, I3)',
                  style: TextStyle(
                      fontSize: 14, color: DesignTokens.textSecondaryOf(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSourceTable() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined,
                  color: DesignTokens.primary600, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Data Sources',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: DesignTokens.primary600.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Database',
                  style: TextStyle(
                    fontSize: 11,
                    color: DesignTokens.primary600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: DesignTokens.borderOf(context),
              width: 1,
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.5),
            },
            children: [
              // Header row
              TableRow(
                decoration: BoxDecoration(
                  color: DesignTokens.surfaceAltOf(context),
                ),
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Parameter',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textPrimaryOf(context),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Value',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textPrimaryOf(context),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              // Voltage rows
              _buildTableRow('Voltage Phase 1 (U1)',
                  '${_phases['U1']!.u.toStringAsFixed(2)} V'),
              _buildTableRow('Voltage Phase 2 (U2)',
                  '${_phases['U2']!.u.toStringAsFixed(2)} V'),
              _buildTableRow('Voltage Phase 3 (U3)',
                  '${_phases['U3']!.u.toStringAsFixed(2)} V'),
              // Current rows
              _buildTableRow('Current Phase 1 (I1)',
                  '${_phases['U1']!.i.toStringAsFixed(2)} A'),
              _buildTableRow('Current Phase 2 (I2)',
                  '${_phases['U2']!.i.toStringAsFixed(2)} A'),
              _buildTableRow('Current Phase 3 (I3)',
                  '${_phases['U3']!.i.toStringAsFixed(2)} A'),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String name, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: DesignTokens.textPrimaryOf(context),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: DesignTokens.primary600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigurationCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: DesignTokens.primary600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Configuration',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Polling interval field
          Row(
            children: [
              Icon(Icons.timer_outlined,
                  size: 16, color: DesignTokens.textSecondaryOf(context)),
              const SizedBox(width: 6),
              Text(
                'Polling interval (s)',
                style:
                    TextStyle(fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 80,
                child: TextField(
                  key: const Key(FresnelDiagramKeys.pollIntervalField),
                  controller: _pollIntervalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    hintText: '1',
                  ),
                  onChanged: (v) {
                    final secs = int.tryParse(v);
                    if (secs != null && secs >= 1) {
                      setState(() => _pollInterval = secs * 1000);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ElevatedButton.icon(
                key: const Key(FresnelDiagramKeys.startBtn),
                onPressed: (_isRunning ||
                        !ProviderScope.containerOf(context, listen: false)
                            .read(appControllerProvider)
                            .isConnected ||
                        !userRights.hasRightForFeature(
                            'Get', FeatureKeys.fresnel))
                    ? null
                    : _startSimulation,
                icon: const Icon(Icons.play_arrow, size: 16),
                label: const Text('Start', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.success,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              ElevatedButton.icon(
                key: const Key(FresnelDiagramKeys.stopBtn),
                onPressed: _isRunning ? _stopSimulation : null,
                icon: const Icon(Icons.stop, size: 16),
                label: const Text('Stop', style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignTokens.danger,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: DesignTokens.primary600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Instantaneous Values',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _phases.entries.map((entry) {
              final phase = entry.value;
              final u = phase.u;
              final i = phase.i;

              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: DesignTokens.surfaceOf(context),
                    border: Border.all(color: DesignTokens.borderOf(context)),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textSecondaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'U=${u.toStringAsFixed(2)}V',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'I=${i.toStringAsFixed(2)}A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagramCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grain, color: DesignTokens.primary600),
              const SizedBox(width: 8),
              const Text(
                'Fresnel Diagram',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RepaintBoundary(
            key: _diagramRepaintKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main diagram
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: DesignTokens.surfaceOf(context),
                      border: Border.all(color: DesignTokens.borderOf(context)),
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                    child: CustomPaint(
                      size: const Size(720, 520),
                      painter: FresnelDiagramPainter(
                        phases: _phases,
                        uRef: _uRef,
                        iRef: _iRef,
                        backgroundColor: DesignTokens.surfaceOf(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Individual phase diagrams
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildIndividualPhaseDiagram(
                          'U1', _phases['U1']!, const Color(0xFF2196F3)),
                      const SizedBox(height: 12),
                      _buildIndividualPhaseDiagram(
                          'U2', _phases['U2']!, const Color(0xFF4CAF50)),
                      const SizedBox(height: 12),
                      _buildIndividualPhaseDiagram(
                          'U3', _phases['U3']!, const Color(0xFFFF9800)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualPhaseDiagram(
      String phaseName, PhaseData phase, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            phaseName,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          CustomPaint(
            size: const Size(150, 150),
            painter: SinglePhaseDiagramPainter(
              phase: phase,
              uRef: _uRef,
              iRef: _iRef,
              color: color,
              backgroundColor: DesignTokens.surfaceOf(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'φ = ${phase.phi.toStringAsFixed(2)}°',
            style: TextStyle(
              fontSize: 12,
              color: DesignTokens.textSecondaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceAltOf(context),
        border: Border(top: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceOf(context),
              border: Border.all(color: DesignTokens.borderOf(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: DesignTokens.success),
                const SizedBox(width: 4),
                const Text('Connected to meter',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceOf(context),
              border: Border.all(color: DesignTokens.borderOf(context)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Last refresh: ${_lastRefresh.hour.toString().padLeft(2, '0')}:${_lastRefresh.minute.toString().padLeft(2, '0')}:${_lastRefresh.second.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinusoidalCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: DesignTokens.primary600),
              const SizedBox(width: 8),
              const Text(
                'Sinusoidal Waveforms',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _sineLegendItem('U1', const Color(0xFF2196F3), dashed: false),
              _sineLegendItem('U2', const Color(0xFF4CAF50), dashed: false),
              _sineLegendItem('U3', const Color(0xFFFF9800), dashed: false),
              _sineLegendItem('I1', const Color(0xFF2196F3), dashed: true),
              _sineLegendItem('I2', const Color(0xFF4CAF50), dashed: true),
              _sineLegendItem('I3', const Color(0xFFFF9800), dashed: true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: DesignTokens.surfaceOf(context),
              border: Border.all(color: DesignTokens.borderOf(context)),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: SizedBox(
              height: 260,
              child: CustomPaint(
                painter: SinusoidalPainter(
                    phases: _phases, uRef: _uRef, iRef: _iRef,
                    backgroundColor: DesignTokens.surfaceOf(context)),
                child: Container(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Per-phase individual charts
          Row(
            children: [
              _buildPhaseSineChart(
                  'U1', _phases['U1']!, const Color(0xFF2196F3)),
              const SizedBox(width: 12),
              _buildPhaseSineChart(
                  'U2', _phases['U2']!, const Color(0xFF4CAF50)),
              const SizedBox(width: 12),
              _buildPhaseSineChart(
                  'U3', _phases['U3']!, const Color(0xFFFF9800)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseSineChart(String label, PhaseData phase, Color color) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: DesignTokens.surfaceOf(context),
          border: Border.all(color: DesignTokens.borderOf(context)),
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
                Text('φ = ${phase.phi.toStringAsFixed(2)}°',
                    style: TextStyle(
                        fontSize: 11, color: DesignTokens.textSecondaryOf(context))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _sineLegendItem('U', color, dashed: false),
                const SizedBox(width: 8),
                _sineLegendItem('I', color, dashed: true),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 160,
              child: CustomPaint(
                painter: PerPhaseSinusoidalPainter(
                  phase: phase,
                  uRef: _uRef,
                  iRef: _iRef,
                  color: color,
                  backgroundColor: DesignTokens.surfaceOf(context),
                ),
                child: Container(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sineLegendItem(String label, Color color, {bool dashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        dashed
            ? SizedBox(
                width: 24,
                height: 10,
                child: CustomPaint(
                  painter: _DashLinePainter(color: color),
                ),
              )
            : Container(width: 24, height: 3, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// Phase Data Model

/// Custom Painter for Fresnel Diagram
class FresnelDiagramPainter extends CustomPainter {
  final Map<String, PhaseData> phases;
  final double uRef;
  final double iRef;
  final Color backgroundColor;

  /// When true, the three per-phase mini-diagrams are painted on the right
  /// side of the canvas (used for off-screen export capture).
  final bool includeMinidiagrams;

  FresnelDiagramPainter({
    required this.phases,
    required this.uRef,
    required this.iRef,
    this.backgroundColor = Colors.white,
    this.includeMinidiagrams = false,
  });

  static const _miniColors = [
    Color(0xFF2196F3),
    Color(0xFF4CAF50),
    Color(0xFFFF9800),
  ];
  static const _miniKeys = ['U1', 'U2', 'U3'];

  @override
  void paint(Canvas canvas, Size size) {
    // Main phasor diagram occupies the left 720px (or full width if no minis)
    final mainW = includeMinidiagrams ? 720.0 : size.width;
    _paintMain(canvas, Size(mainW, size.height));

    if (includeMinidiagrams) {
      const miniSize = 160.0;
      const startX = 740.0;
      for (int i = 0; i < _miniKeys.length; i++) {
        final phase = phases[_miniKeys[i]];
        if (phase == null) continue;
        final offsetY = i * (miniSize + 10.0);
        canvas.save();
        canvas.translate(startX, offsetY);
        SinglePhaseDiagramPainter(
          phase: phase,
          uRef: uRef,
          iRef: iRef,
          color: _miniColors[i],
        ).paint(canvas, const Size(miniSize, miniSize));
        // Draw phi label below the mini diagram
        final tp = TextPainter(
          text: TextSpan(
            text: '${_miniKeys[i]}  φ = ${phase.phi.toStringAsFixed(2)}°',
            style: TextStyle(
                fontSize: 10,
                color: _miniColors[i],
                fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset((miniSize - tp.width) / 2, miniSize - 14));
        canvas.restore();
      }
    }
  }

  void _paintMain(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(size.width, size.height) * 0.42;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Draw dashed circle
    _drawDashedCircle(
        canvas,
        Offset(cx, cy),
        radius,
        Paint()
          ..color = const Color(0xFFD1D5DB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);

    // Draw axes
    final axisPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..strokeWidth = 1.5;

    canvas.drawLine(
        Offset(cx - radius - 6, cy), Offset(cx + radius + 6, cy), axisPaint);
    canvas.drawLine(
        Offset(cx, cy - radius - 6), Offset(cx, cy + radius + 6), axisPaint);

    // Draw degree labels
    _drawText(canvas, '0°', Offset(cx + radius - 18, cy - 8),
        const TextStyle(fontSize: 12, color: Color(0xFF4B5563)));
    _drawText(canvas, '90°', Offset(cx - 8, cy - radius + 16),
        const TextStyle(fontSize: 12, color: Color(0xFF4B5563)));
    _drawText(canvas, '180°', Offset(cx - radius + 6, cy - 8),
        const TextStyle(fontSize: 12, color: Color(0xFF4B5563)));
    _drawText(canvas, '270°', Offset(cx - 18, cy + radius - 6),
        const TextStyle(fontSize: 12, color: Color(0xFF4B5563)));

    // Draw guide lines (green) at 0°, 120°, 240°
    final guidePaint = Paint()
      ..color = const Color(0xFF22c55e)
      ..strokeWidth = 1.5;

    for (var angle in [0, 120, 240]) {
      final rad = angle * pi / 180;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + radius * cos(rad), cy - radius * sin(rad)),
        guidePaint,
      );
    }

    // Draw voltage phasors (blue)
    final voltagePaint = Paint()
      ..color = const Color(0xFF0b61ff)
      ..strokeWidth = 3;

    final voltageAngles = [0.0, 240.0, 120.0];
    final voltageLabels = ['U1', 'U2', 'U3'];

    for (var i = 0; i < 3; i++) {
      final phaseKey = voltageLabels[i];
      final phase = phases[phaseKey]!;
      final mag = min(1.0, phase.u / uRef);
      final angle = voltageAngles[i];

      _drawVector(
        canvas,
        Offset(cx, cy),
        angle,
        mag * radius,
        voltagePaint,
        phaseKey,
        const Color(0xFF0b61ff),
      );
    }

    // Draw current phasors (red)
    final currentPaint = Paint()
      ..color = const Color(0xFFd62728)
      ..strokeWidth = 3;

    final currentBases = [0.0, 240.0, 120.0];
    final currentLabels = ['U1', 'U2', 'U3'];

    for (var i = 0; i < 3; i++) {
      final phaseKey = currentLabels[i];
      final phase = phases[phaseKey]!;
      final mag = min(1.0, phase.i / iRef);
      final angle = _clampAngle(currentBases[i] + phase.phi);

      _drawVector(
        canvas,
        Offset(cx, cy),
        angle,
        mag * radius,
        currentPaint,
        'I${i + 1}',
        const Color(0xFFd62728),
      );
    }

    // Draw phi arc annotations between each U and I phasor
    final arcColors = [
      const Color(0xFF2196F3), // U1/I1
      const Color(0xFF4CAF50), // U2/I2
      const Color(0xFFFF9800), // U3/I3
    ];

    for (var i = 0; i < 3; i++) {
      final phaseKey = voltageLabels[i];
      final phase = phases[phaseKey]!;
      if (phase.phi.abs() < 0.5) continue;

      final uAngleDeg = voltageAngles[i];
      final iAngleDeg = _clampAngle(currentBases[i] + phase.phi);

      // Arc drawn at 55% of radius to avoid overlap with vectors
      final arcRadius = radius * 0.55;
      final arcColor = arcColors[i];
      final arcPaint = Paint()
        ..color = arcColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Flutter arc: angles measured clockwise from positive x-axis (east).
      // Our phasor angles are CCW from east, so convert: flutterAngle = -phasorAngle
      final uFlutter = -uAngleDeg * pi / 180;
      final iFlutter = -iAngleDeg * pi / 180;

      // Compute sweep so the arc always goes the short way from U to I
      double sweep = iFlutter - uFlutter;
      // Normalise to (-pi, pi]
      while (sweep > pi) sweep -= 2 * pi;
      while (sweep <= -pi) sweep += 2 * pi;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcRadius),
        uFlutter,
        sweep,
        false,
        arcPaint,
      );

      // Phi label at midpoint of arc
      final midAngleFlutter = uFlutter + sweep / 2;
      final labelR = arcRadius + 14;
      final labelPos = Offset(
        cx + labelR * cos(midAngleFlutter) - 18,
        cy + labelR * sin(midAngleFlutter) - 6,
      );
      _drawText(
        canvas,
        'φ${i + 1}=${phase.phi.toStringAsFixed(1)}°',
        labelPos,
        TextStyle(
          fontSize: 10,
          color: arcColor,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  void _drawDashedCircle(
      Canvas canvas, Offset center, double radius, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 6.0;
    double startAngle = 0;

    while (startAngle < 2 * pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashWidth / radius,
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / radius;
    }
  }

  void _drawVector(Canvas canvas, Offset start, double angleDeg, double length,
      Paint paint, String label, Color labelColor) {
    final rad = angleDeg * pi / 180;
    final end = Offset(
      start.dx + length * cos(rad),
      start.dy - length * sin(rad),
    );

    // Draw line
    canvas.drawLine(start, end, paint);

    // Draw arrow head
    _drawArrowHead(canvas, end, rad, paint.color);

    // Draw label
    _drawText(
      canvas,
      label,
      Offset(end.dx + 6, end.dy - 6),
      TextStyle(fontSize: 12, color: labelColor, fontWeight: FontWeight.w600),
    );
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    const size = 8.0;
    final paint = Paint()..color = color;

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(tip.dx - size * cos(angle) - size / 2 * sin(angle),
        tip.dy + size * sin(angle) - size / 2 * cos(angle));
    path.lineTo(tip.dx - size * cos(angle) + size / 2 * sin(angle),
        tip.dy + size * sin(angle) + size / 2 * cos(angle));
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  double _clampAngle(double deg) {
    return ((deg % 360) + 360) % 360;
  }

  @override
  bool shouldRepaint(FresnelDiagramPainter oldDelegate) => true;
}

/// Single Phase Diagram Painter
class SinglePhaseDiagramPainter extends CustomPainter {
  final PhaseData phase;
  final double uRef;
  final double iRef;
  final Color color;
  final Color backgroundColor;

  SinglePhaseDiagramPainter({
    required this.phase,
    required this.uRef,
    required this.iRef,
    required this.color,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = min(cx, cy) - 20;

    // Draw background
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw reference circles
    final circlePaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(cx, cy), radius * 0.5, circlePaint);
    canvas.drawCircle(Offset(cx, cy), radius, circlePaint);

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    canvas.drawLine(
        Offset(cx - radius, cy), Offset(cx + radius, cy), axisPaint);
    canvas.drawLine(
        Offset(cx, cy - radius), Offset(cx, cy + radius), axisPaint);

    // Draw voltage vector (in color)
    final uMag = min(1.0, phase.u / uRef);
    final uPaint = Paint()
      ..color = color
      ..strokeWidth = 3;

    _drawVector(
      canvas,
      Offset(cx, cy),
      0.0,
      uMag * radius,
      uPaint,
      'U',
      color,
    );

    // Draw current vector (red, with phase shift)
    final iMag = min(1.0, phase.i / iRef);
    final iPaint = Paint()
      ..color = const Color(0xFFd62728)
      ..strokeWidth = 2.5;

    _drawVector(
      canvas,
      Offset(cx, cy),
      phase.phi,
      iMag * radius,
      iPaint,
      'I',
      const Color(0xFFd62728),
    );

    // Draw phase angle arc
    if (phase.phi.abs() > 1) {
      final arcPaint = Paint()
        ..color = Colors.grey.shade600
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final arcRadius = radius * 0.2;
      final startAngle = phase.phi > 0 ? -phase.phi * pi / 180 : 0.0;
      final sweepAngle = (phase.phi.abs() * pi / 180);

      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: arcRadius),
        startAngle,
        sweepAngle,
        false,
        arcPaint,
      );
    }
  }

  void _drawVector(Canvas canvas, Offset start, double angleDeg, double length,
      Paint paint, String label, Color labelColor) {
    final rad = angleDeg * pi / 180;
    final end = Offset(
      start.dx + length * cos(rad),
      start.dy - length * sin(rad),
    );

    // Draw line
    canvas.drawLine(start, end, paint);

    // Draw arrow head
    _drawArrowHead(canvas, end, rad, paint.color);

    // Draw label near the arrow
    final labelOffset = Offset(
      end.dx + 8 * cos(rad),
      end.dy - 8 * sin(rad) - 8,
    );

    _drawText(
      canvas,
      label,
      labelOffset,
      TextStyle(fontSize: 11, color: labelColor, fontWeight: FontWeight.w600),
    );
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    const size = 6.0;
    final paint = Paint()..color = color;

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(tip.dx - size * cos(angle) - size / 2 * sin(angle),
        tip.dy + size * sin(angle) - size / 2 * cos(angle));
    path.lineTo(tip.dx - size * cos(angle) + size / 2 * sin(angle),
        tip.dy + size * sin(angle) + size / 2 * cos(angle));
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(SinglePhaseDiagramPainter oldDelegate) => true;
}

/// Tiny painter for the dashed legend line
class _DashLinePainter extends CustomPainter {
  final Color color;
  _DashLinePainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5;
    const dash = 4.0;
    const gap = 3.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_DashLinePainter old) => old.color != color;
}

/// Sinusoidal waveform painter — draws the 3 voltage phases (U1, U2, U3)
/// over two full cycles with their respective 120° shifts.
class SinusoidalPainter extends CustomPainter {
  final Map<String, PhaseData> phases;
  final double uRef;
  final double iRef;
  final Color backgroundColor;

  static const _phaseKeys = ['U1', 'U2', 'U3'];
  // Base angles matching the Fresnel phasor diagram: U1=0°, U2=240°, U3=120°
  static const _baseAngles = [0.0, 240.0, 120.0];
  static const _colors = [
    Color(0xFF2196F3), // U1/I1 – Blue
    Color(0xFF4CAF50), // U2/I2 – Green
    Color(0xFFFF9800), // U3/I3 – Orange
  ];

  SinusoidalPainter(
      {required this.phases, required this.uRef, required this.iRef, this.backgroundColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 46.0;
    const topPad = 18.0;
    const rightPad = 16.0;
    const bottomPad = 36.0;
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;
    final midY = topPad + plotH / 2;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Horizontal grid lines (5 steps)
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = topPad + (i / 4) * plotH;
      canvas.drawLine(
          Offset(leftPad, y), Offset(leftPad + plotW, y), gridPaint);
    }
    // Vertical grid lines (per 90°, 8 steps = 2 cycles)
    for (int i = 0; i <= 8; i++) {
      final x = leftPad + (i / 8) * plotW;
      canvas.drawLine(Offset(x, topPad), Offset(x, topPad + plotH), gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.5;
    canvas.drawLine(
        Offset(leftPad, topPad), Offset(leftPad, topPad + plotH), axisPaint);
    canvas.drawLine(
        Offset(leftPad, midY), Offset(leftPad + plotW, midY), axisPaint);

    // Draw sinusoids
    for (int i = 0; i < 3; i++) {
      final phase = phases[_phaseKeys[i]];
      if (phase == null) continue;
      final baseRad = _baseAngles[i] * pi / 180;

      // Voltage – solid line
      final uAmp = min(1.2, phase.u / (uRef > 0 ? uRef : 230.0)) * (plotH / 2);
      final uPath = Path();
      const steps = 512;
      for (int s = 0; s <= steps; s++) {
        final t = (s / steps) * 4 * pi;
        final x = leftPad + (s / steps) * plotW;
        final y = midY - uAmp * sin(t + baseRad);
        s == 0 ? uPath.moveTo(x, y) : uPath.lineTo(x, y);
      }
      canvas.drawPath(
        uPath,
        Paint()
          ..color = _colors[i]
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke,
      );

      // Current – dashed line (with phi shift)
      final iAmp = min(1.2, phase.i / (iRef > 0 ? iRef : 5.0)) * (plotH / 2);
      final iPhaseRad = baseRad + phase.phi * pi / 180;
      _drawDashedSine(
          canvas, leftPad, plotW, midY, iAmp, iPhaseRad, _colors[i]);
    }

    // X-axis labels
    const xLabels = [
      '0°',
      '90°',
      '180°',
      '270°',
      '360°',
      '450°',
      '540°',
      '630°',
      '720°'
    ];
    for (int i = 0; i <= 8; i++) {
      final x = leftPad + (i / 8) * plotW;
      _drawText(canvas, xLabels[i], Offset(x - 12, topPad + plotH + 6),
          const TextStyle(fontSize: 10, color: Color(0xFF6B7280)));
    }

    // Y-axis labels
    _drawText(canvas, '+U', Offset(4, topPad),
        const TextStyle(fontSize: 10, color: Color(0xFF6B7280)));
    _drawText(canvas, '0', Offset(8, midY - 7),
        const TextStyle(fontSize: 10, color: Color(0xFF6B7280)));
    _drawText(canvas, '-U', Offset(4, topPad + plotH - 14),
        const TextStyle(fontSize: 10, color: Color(0xFF6B7280)));
  }

  void _drawDashedSine(Canvas canvas, double leftPad, double plotW, double midY,
      double amp, double phaseRad, Color color) {
    const steps = 512;
    const dashPx = 6.0;
    const gapPx = 5.0;
    double carry = 0.0;
    bool drawing = true;

    for (int s = 0; s < steps; s++) {
      final t0 = (s / steps) * 4 * pi;
      final t1 = ((s + 1) / steps) * 4 * pi;
      final x0 = leftPad + (s / steps) * plotW;
      final x1 = leftPad + ((s + 1) / steps) * plotW;
      final y0 = midY - amp * sin(t0 + phaseRad);
      final y1 = midY - amp * sin(t1 + phaseRad);
      final segLen = sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
      if (segLen == 0) continue;

      double consumed = 0.0;
      while (consumed < segLen) {
        final budget = drawing ? dashPx : gapPx;
        final remaining = budget - carry;
        final available = segLen - consumed;
        if (remaining <= available) {
          final frac = (consumed + remaining) / segLen;
          final px = x0 + (x1 - x0) * frac;
          final py = y0 + (y1 - y0) * frac;
          if (drawing) {
            final startFrac = consumed / segLen;
            canvas.drawLine(
              Offset(x0 + (x1 - x0) * startFrac, y0 + (y1 - y0) * startFrac),
              Offset(px, py),
              Paint()
                ..color = color
                ..strokeWidth = 2.0,
            );
          }
          consumed += remaining;
          carry = 0.0;
          drawing = !drawing;
        } else {
          if (drawing) {
            final startFrac = consumed / segLen;
            canvas.drawLine(
              Offset(x0 + (x1 - x0) * startFrac, y0 + (y1 - y0) * startFrac),
              Offset(x1, y1),
              Paint()
                ..color = color
                ..strokeWidth = 2.0,
            );
          }
          carry += available;
          consumed = segLen;
        }
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(SinusoidalPainter old) =>
      old.phases != phases || old.uRef != uRef || old.iRef != iRef;
}

/// Per-phase sinusoidal painter: shows U (solid) and I (dashed) for a single
/// phase over two full cycles, with I shifted by phi relative to U.
class PerPhaseSinusoidalPainter extends CustomPainter {
  final PhaseData phase;
  final double uRef;
  final double iRef;
  final Color color;
  final Color backgroundColor;

  PerPhaseSinusoidalPainter({
    required this.phase,
    required this.uRef,
    required this.iRef,
    required this.color,
    this.backgroundColor = Colors.white,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 32.0;
    const topPad = 10.0;
    const rightPad = 8.0;
    const bottomPad = 22.0;
    final plotW = size.width - leftPad - rightPad;
    final plotH = size.height - topPad - bottomPad;
    final midY = topPad + plotH / 2;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    // Grid
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = topPad + (i / 4) * plotH;
      canvas.drawLine(
          Offset(leftPad, y), Offset(leftPad + plotW, y), gridPaint);
    }
    for (int i = 0; i <= 8; i++) {
      final x = leftPad + (i / 8) * plotW;
      canvas.drawLine(Offset(x, topPad), Offset(x, topPad + plotH), gridPaint);
    }

    // Axes
    final axisPaint = Paint()
      ..color = const Color(0xFF9CA3AF)
      ..strokeWidth = 1.2;
    canvas.drawLine(
        Offset(leftPad, topPad), Offset(leftPad, topPad + plotH), axisPaint);
    canvas.drawLine(
        Offset(leftPad, midY), Offset(leftPad + plotW, midY), axisPaint);

    const steps = 512;

    // U – solid
    final uAmp = min(1.0, phase.u / (uRef > 0 ? uRef : 230.0)) * (plotH / 2);
    final uPath = Path();
    for (int s = 0; s <= steps; s++) {
      final t = (s / steps) * 4 * pi;
      final x = leftPad + (s / steps) * plotW;
      final y = midY - uAmp * sin(t);
      s == 0 ? uPath.moveTo(x, y) : uPath.lineTo(x, y);
    }
    canvas.drawPath(
      uPath,
      Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // I – dashed, shifted by phi
    final iAmp = min(1.0, phase.i / (iRef > 0 ? iRef : 5.0)) * (plotH / 2);
    final phiRad = phase.phi * pi / 180;
    _drawDashedSine(canvas, leftPad, plotW, midY, iAmp, phiRad, color);

    // X labels
    const xLabels = ['0°', '180°', '360°', '540°', '720°'];
    for (int i = 0; i <= 4; i++) {
      final x = leftPad + (i / 4) * plotW;
      _drawText(canvas, xLabels[i], Offset(x - 10, topPad + plotH + 4),
          const TextStyle(fontSize: 9, color: Color(0xFF6B7280)));
    }

    // phi annotation – draw a small arc and label
    if (phase.phi.abs() > 1.0) {
      // find the first zero crossing of U (t=0, x=leftPad) and I (t=-phi)
      // draw vertical dashed line at I's peak vs U's peak
      final arcPaint = Paint()
        ..color = const Color(0xFF6B7280)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      // Draw a small horizontal double-arrow between x=leftPad (U peak at t=pi/2) and I peak
      final uPeakX = leftPad +
          (0.25 / 2) *
              plotW; // t = pi/2 → 1/8 of 4pi span → 1/8 * plotW... recalc:
      // t goes 0..4pi over plotW. U peak at t=pi/2 → x = leftPad + (pi/2)/(4*pi)*plotW = leftPad + plotW/8
      final uPeakXc = leftPad + plotW / 8;
      // I peak at t = pi/2 - phi (because sin(t+phi)=1 => t = pi/2 - phi)
      final iPeakT = pi / 2 - phiRad;
      final iPeakXc = leftPad + (iPeakT / (4 * pi)) * plotW;
      if (iPeakXc > leftPad &&
          iPeakXc < leftPad + plotW &&
          uPeakXc > leftPad &&
          uPeakXc < leftPad + plotW) {
        canvas.drawLine(
          Offset(uPeakXc, midY - uAmp - 6),
          Offset(iPeakXc, midY - uAmp - 6),
          arcPaint,
        );
        // small tick marks
        canvas.drawLine(Offset(uPeakXc, midY - uAmp - 10),
            Offset(uPeakXc, midY - uAmp - 2), arcPaint);
        canvas.drawLine(Offset(iPeakXc, midY - uAmp - 10),
            Offset(iPeakXc, midY - uAmp - 2), arcPaint);
      }
    }
  }

  void _drawDashedSine(Canvas canvas, double leftPad, double plotW, double midY,
      double amp, double phaseRad, Color color) {
    const steps = 512;
    const dashPx = 5.0;
    const gapPx = 4.0;
    double carry = 0.0;
    bool drawing = true;

    for (int s = 0; s < steps; s++) {
      final t0 = (s / steps) * 4 * pi;
      final t1 = ((s + 1) / steps) * 4 * pi;
      final x0 = leftPad + (s / steps) * plotW;
      final x1 = leftPad + ((s + 1) / steps) * plotW;
      final y0 = midY - amp * sin(t0 + phaseRad);
      final y1 = midY - amp * sin(t1 + phaseRad);
      final segLen = sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));
      if (segLen == 0) continue;

      double consumed = 0.0;
      while (consumed < segLen) {
        final budget = drawing ? dashPx : gapPx;
        final remaining = budget - carry;
        final available = segLen - consumed;
        if (remaining <= available) {
          final frac = (consumed + remaining) / segLen;
          final px = x0 + (x1 - x0) * frac;
          final py = y0 + (y1 - y0) * frac;
          if (drawing) {
            final startFrac = consumed / segLen;
            canvas.drawLine(
              Offset(x0 + (x1 - x0) * startFrac, y0 + (y1 - y0) * startFrac),
              Offset(px, py),
              Paint()
                ..color = color.withOpacity(0.75)
                ..strokeWidth = 1.8,
            );
          }
          consumed += remaining;
          carry = 0.0;
          drawing = !drawing;
        } else {
          if (drawing) {
            final startFrac = consumed / segLen;
            canvas.drawLine(
              Offset(x0 + (x1 - x0) * startFrac, y0 + (y1 - y0) * startFrac),
              Offset(x1, y1),
              Paint()
                ..color = color.withOpacity(0.75)
                ..strokeWidth = 1.8,
            );
          }
          carry += available;
          consumed = segLen;
        }
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(PerPhaseSinusoidalPainter old) =>
      old.phase != phase ||
      old.uRef != uRef ||
      old.iRef != iRef ||
      old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Export registry registration
// ─────────────────────────────────────────────────────────────────────────────

/// Call once at startup (e.g. in main.dart) to make the Fresnel Diagram page
/// available in the export templates screen.
void registerFresnelPage() {
  ExportRegistry.instance.register(
    const ExportedPageInfo(
      id: 'fresnel',
      label: 'Fresnel Diagram',
      icon: Icons.grain,
      builder: _buildFresnelPage,
      tokens: {
        'phases.*': 'Phase data – e.g. phases.U1.u, phases.U1.i, phases.U1.phi',
        'lastRefresh': 'ISO-8601 timestamp of last data refresh',
      },
    ),
  );
}

Widget _buildFresnelPage(BuildContext _) => const FresnelDiagramPage();
