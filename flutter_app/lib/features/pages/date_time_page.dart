import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import '../../state/app_controller.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../grpc/meter_client.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/generated/meter.pbgrpc.dart';
import '../../core/export/exportable_page.dart';
import '../../core/export/export_action_button.dart';
import '../../core/widget_keys.dart';
import '../../core/export/export_registry.dart';
import '../../state/device_id_cache.dart';

/// Date Time Configuration Screen
/// Corresponds to date_time_menu.html with 4 tabs:
/// - Clock Setting (date/time, timezone, status, deviation)
/// - Daylight Savings (incremental/decremental dates, deviation, activation)
/// - Time Shift Limit (max correction value)
/// - Local Date Time (calculated local time from UTC + TZ + DST)
class DateTimePage extends StatefulWidget {
  const DateTimePage({super.key});

  @override
  State<DateTimePage> createState() => _DateTimePageState();
}

class _DateTimePageState extends State<DateTimePage>
    with SingleTickerProviderStateMixin
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'date_time';

  @override
  String get exportPageLabel => 'Date Time';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'clock': {
          'day': _selectedDay,
          'month': _selectedMonth,
          'year': _selectedYear,
          'hour': _selectedTime.hour,
          'minute': _selectedTime.minute,
          'second': _selectedSeconds,
          'timezone_offset_min': _timezoneOffset,
        },
        'dst_incremental': {
          'day': _incDay,
          'month': _incMonth,
          'hour': _incTime.hour,
          'minute': _incTime.minute,
          'second': _incSeconds,
          'day_of_week': _incDayOfWeek,
        },
        'dst_decremental': {
          'day': _decDay,
          'month': _decMonth,
          'hour': _decTime.hour,
          'minute': _decTime.minute,
          'second': _decSeconds,
          'day_of_week': _decDayOfWeek,
        },
        'dst': {
          'deviation_min': _dstDeviation,
          'active': _dstActive,
        },
      };

  // ---------------------------------------------------------------------------

  late TabController _tabController;
  late final IMeterClient client;
  bool _loading = false;
  // Clock Setting values
  int _selectedDay = DateTime.now().day;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedSeconds = DateTime.now().second;
  int _timezoneOffset = 0; // minutes

  // Daylight Savings values
  int _incDay = 28;
  int _incMonth = 3;
  TimeOfDay _incTime = const TimeOfDay(hour: 2, minute: 0);
  int _incSeconds = 0;
  int _incDayOfWeek = 255; // 1-7 or 255 (unspecified)
  int _decDay = 27;
  int _decMonth = 10;
  TimeOfDay _decTime = const TimeOfDay(hour: 3, minute: 0);
  int _decSeconds = 0;
  int _decDayOfWeek = 255; // 1-7 or 255 (unspecified)
  int _dstDeviation = 60; // minutes
  bool _dstActive = false;

  // Feedback messages
  String _clockFeedback = '';
  String _tzFeedback = '';
  String _incFeedback = '';
  String _decFeedback = '';
  String _dstDevFeedback = '';
  String _dstActiveFeedback = '';

  // Card collapse states
  final Map<String, bool> _cardStates = {
    'datetime': true,
    'timezone': true,
    'incDate': true,
    'decDate': true,
    'dstDeviation': true,
    'dstActivation': true,
  };

  @override
  void initState() {
    super.initState();
    client = meterClientFactory();
    _tabController = TabController(length: 2, vsync: this);
    // Track if tab has been loaded before
    List<bool> _tabLoaded = [false, false];
    // Listen for tab changes
    _tabController.addListener(() {
      final idx = _tabController.index;
      if (!_tabLoaded[idx]) {
        _tabLoaded[idx] = true;
        if (idx == 1) {
          // Daylight Savings tab
          _readIncremental();
          _readDecremental();
          _readDstDeviation();
          _readDstActivation();
        }
      }
    });
    // Initial load for first tab — sequential to avoid concurrent serial port access
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final isConnected = ProviderScope.containerOf(context, listen: false)
          .read(appControllerProvider)
          .isConnected;
      if (!isConnected) return;
      await _readDateTime();
      if (!mounted) return;
      await _readTimezone();
    });
    _tabLoaded[0] = true;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0f172a) : DesignTokens.background,
      appBar: AppBar(
        title: const Text('Date Time'),
        backgroundColor:
            isDark ? const Color(0xFF1e3a6e) : DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          ExportActionButton(
            pageId: exportPageId,
            pageType: 'date_time',
            dataGetter: getExportData,
            iconColor: Colors.white,
          ),
          RefreshAppBarButton(onPressed: _refreshAll),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(
              icon: Icon(Icons.schedule, size: 20),
              text: 'Clock Setting',
            ),
            Tab(
              icon: Icon(Icons.wb_sunny, size: 20),
              text: 'Daylight Savings',
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildClockTab(),
              _buildDaylightTab(),
            ],
          ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClockTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignTokens.spaceXl),
      child: Column(
        children: [
          _buildInfoAlert(
            icon: Icons.schedule,
            title: 'Clock Panel',
            description: 'View / edit date & time and time zone.',
          ),
          SizedBox(height: DesignTokens.spaceLg),
          _buildDateTimeCard(),
          SizedBox(height: DesignTokens.spaceLg),
          _buildTimeZoneCard(),
        ],
      ),
    );
  }

  Widget _buildDaylightTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(DesignTokens.spaceXl),
      child: Column(
        children: [
          _buildInfoAlert(
            icon: Icons.wb_sunny,
            title: 'Daylight Savings',
            description:
                'Configure enter/exit dates and daylight savings parameters.',
          ),
          SizedBox(height: DesignTokens.spaceLg),
          _buildIncrementalDateCard(),
          SizedBox(height: DesignTokens.spaceLg),
          _buildDecrementalDateCard(),
          SizedBox(height: DesignTokens.spaceLg),
          _buildDstDeviationCard(),
          SizedBox(height: DesignTokens.spaceLg),
          _buildDstActivationCard(),
        ],
      ),
    );
  }

  // Removed _buildShiftTab and _buildLocalTab

  Widget _buildInfoAlert({
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(DesignTokens.spaceMd),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1e3a5f).withValues(alpha: 0.4)
            : DesignTokens.infoLight,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border(
          left: BorderSide(
            color: DesignTokens.info,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: DesignTokens.info),
          SizedBox(width: DesignTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.info,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleCard({
    required String cardKey,
    required IconData icon,
    required String title,
    required String description,
    required Widget content,
    Key? toggleKey,
  }) {
    final isExpanded = _cardStates[cardKey] ?? true;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1e293b) : DesignTokens.surfaceAlt,
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : DesignTokens.gray200),
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
      ),
      child: Column(
        children: [
          InkWell(
            key: toggleKey,
            onTap: () {
              setState(() {
                _cardStates[cardKey] = !isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.spaceLg),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : DesignTokens.textSecondary,
                  ),
                  SizedBox(width: DesignTokens.spaceSm),
                  Icon(icon,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : DesignTokens.primary600),
                  SizedBox(width: DesignTokens.spaceSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFF1F5F9)
                                : DesignTokens.textPrimary,
                          ),
                        ),
                        if (description.isNotEmpty)
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : DesignTokens.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.fromLTRB(
                DesignTokens.spaceLg,
                0,
                DesignTokens.spaceLg,
                DesignTokens.spaceLg,
              ),
              child: content,
            ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard() {
    return _buildCollapsibleCard(
      cardKey: 'datetime',
      icon: Icons.calendar_today,
      title: 'Date-time',
      description: 'Read or write date & time (24h format). Strict validation.',
      toggleKey: const Key(DateTimeKeys.clockCardToggle),
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Day',
                  value: _selectedDay,
                  items: List.generate(31, (i) => i + 1),
                  onChanged: (val) => setState(() => _selectedDay = val!),
                  key: const Key(DateTimeKeys.clockDayDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildDropdown(
                  label: 'Month',
                  value: _selectedMonth,
                  items: List.generate(12, (i) => i + 1),
                  itemBuilder: (val) => '$val - ${_getMonthName(val)}',
                  onChanged: (val) => setState(() => _selectedMonth = val!),
                  key: const Key(DateTimeKeys.clockMonthDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildDropdown(
                  label: 'Year',
                  value: _selectedYear,
                  items: List.generate(100, (i) => 1970 + i),
                  onChanged: (val) => setState(() => _selectedYear = val!),
                  key: const Key(DateTimeKeys.clockYearDropdown),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spaceMd),
          _buildTimeField(key: const Key(DateTimeKeys.clockTimePicker)),
          SizedBox(height: DesignTokens.spaceMd),
          _buildActionRow([
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.clockReadBtn),
              icon: Icons.visibility,
              label: 'Read',
              onPressed: _readDateTime,
            ),
            _buildPrimaryButton(
              key: const Key(DateTimeKeys.clockWriteBtn),
              icon: Icons.save,
              label: 'Write',
              onPressed: _writeDateTime,
            ),
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.clockUpdateBtn),
              icon: Icons.refresh,
              label: 'Update',
              onPressed: _updateDateTime,
              right: 'Set',
            ),
          ]),
          if (_clockFeedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.spaceSm),
              child: Text(
                _clockFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeZoneCard() {
    return _buildCollapsibleCard(
      cardKey: 'timezone',
      icon: Icons.public,
      title: 'Time Zone',
      description: 'Offset from UTC in minutes (ex: -60 for UTC+1).',
      toggleKey: const Key(DateTimeKeys.timezoneCardToggle),
      content: Column(
        children: [
          _buildNumberField(
            label: 'Offset (min)',
            value: _timezoneOffset,
            min: -720,
            max: 840,
            onChanged: (val) => setState(() => _timezoneOffset = val),
            key: const Key(DateTimeKeys.timezoneOffsetField),
          ),
          SizedBox(height: DesignTokens.spaceMd),
          _buildActionRow([
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.timezoneReadBtn),
              icon: Icons.visibility,
              label: 'Read',
              onPressed: _readTimezone,
            ),
            _buildPrimaryButton(
              key: const Key(DateTimeKeys.timezoneWriteBtn),
              icon: Icons.save,
              label: 'Write',
              onPressed: _writeTimezone,
            ),
          ]),
          if (_tzFeedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.spaceSm),
              child: Text(
                _tzFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIncrementalDateCard() {
    return _buildCollapsibleCard(
      cardKey: 'incDate',
      icon: Icons.arrow_upward,
      title: 'Incremental Date',
      description: 'Forward switch (DST activation).',
      toggleKey: const Key(DateTimeKeys.incDateCardToggle),
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDayDropdown(
                  label: 'Day',
                  value: _incDay,
                  includeSpecial: true,
                  onChanged: (val) => setState(() => _incDay = val!),
                  key: const Key(DateTimeKeys.incDayDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildDropdown(
                  label: 'Month',
                  value: _incMonth,
                  items: List.generate(12, (i) => i + 1),
                  itemBuilder: (val) => '$val - ${_getMonthName(val)}',
                  onChanged: (val) => setState(() => _incMonth = val!),
                  key: const Key(DateTimeKeys.incMonthDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildDayOfWeekDropdown(
                  label: 'Day of Week',
                  value: _incDayOfWeek,
                  onChanged: (val) => setState(() => _incDayOfWeek = val!),
                  key: const Key(DateTimeKeys.incDayOfWeekDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                flex: 2,
                child: _buildTimePickerWithSeconds(
                  label: 'Time (HH:MM:SS)',
                  time: _incTime,
                  seconds: _incSeconds,
                  onChanged: (time, seconds) => setState(() {
                    _incTime = time;
                    _incSeconds = seconds;
                  }),
                  key: const Key(DateTimeKeys.incTimePicker),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spaceMd),
          _buildActionRow([
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.incDateReadBtn),
              icon: Icons.visibility,
              label: 'Read',
              onPressed: _readIncremental,
            ),
            _buildPrimaryButton(
              key: const Key(DateTimeKeys.incDateWriteBtn),
              icon: Icons.save,
              label: 'Write',
              onPressed: _writeIncremental,
            ),
          ]),
          if (_incFeedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.spaceSm),
              child: Text(
                _incFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDecrementalDateCard() {
    return _buildCollapsibleCard(
      cardKey: 'decDate',
      icon: Icons.arrow_downward,
      title: 'Decremental Date',
      description: 'Backward switch (DST deactivation).',
      toggleKey: const Key(DateTimeKeys.decDateCardToggle),
      content: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDayDropdown(
                  label: 'Day',
                  value: _decDay,
                  includeSpecial: true,
                  onChanged: (val) => setState(() => _decDay = val!),
                  key: const Key(DateTimeKeys.decDayDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildDropdown(
                  label: 'Month',
                  value: _decMonth,
                  items: List.generate(12, (i) => i + 1),
                  itemBuilder: (val) => '$val - ${_getMonthName(val)}',
                  onChanged: (val) => setState(() => _decMonth = val!),
                  key: const Key(DateTimeKeys.decMonthDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                child: _buildDayOfWeekDropdown(
                  label: 'Day of Week',
                  value: _decDayOfWeek,
                  onChanged: (val) => setState(() => _decDayOfWeek = val!),
                  key: const Key(DateTimeKeys.decDayOfWeekDropdown),
                ),
              ),
              SizedBox(width: DesignTokens.spaceMd),
              Expanded(
                flex: 2,
                child: _buildTimePickerWithSeconds(
                  label: 'Time (HH:MM:SS)',
                  time: _decTime,
                  seconds: _decSeconds,
                  onChanged: (time, seconds) => setState(() {
                    _decTime = time;
                    _decSeconds = seconds;
                  }),
                  key: const Key(DateTimeKeys.decTimePicker),
                ),
              ),
            ],
          ),
          SizedBox(height: DesignTokens.spaceMd),
          _buildActionRow([
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.decDateReadBtn),
              icon: Icons.visibility,
              label: 'Read',
              onPressed: _readDecremental,
            ),
            _buildPrimaryButton(
              key: const Key(DateTimeKeys.decDateWriteBtn),
              icon: Icons.save,
              label: 'Write',
              onPressed: _writeDecremental,
            ),
          ]),
          if (_decFeedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.spaceSm),
              child: Text(
                _decFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDstDeviationCard() {
    return _buildCollapsibleCard(
      cardKey: 'dstDeviation',
      icon: Icons.access_time,
      title: 'Daylight Record Deviation',
      description: 'Applied deviation (minutes) during switch.',
      toggleKey: const Key(DateTimeKeys.dstDeviationCardToggle),
      content: Column(
        children: [
          _buildNumberField(
            label: 'Deviation (min)',
            value: _dstDeviation,
            min: 0,
            max: 180,
            onChanged: (val) => setState(() => _dstDeviation = val),
            key: const Key(DateTimeKeys.dstDeviationField),
          ),
          SizedBox(height: DesignTokens.spaceMd),
          _buildActionRow([
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.dstDeviationReadBtn),
              icon: Icons.visibility,
              label: 'Read',
              onPressed: _readDstDeviation,
            ),
            _buildPrimaryButton(
              key: const Key(DateTimeKeys.dstDeviationWriteBtn),
              icon: Icons.save,
              label: 'Write',
              onPressed: _writeDstDeviation,
            ),
          ]),
          if (_dstDevFeedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.spaceSm),
              child: Text(
                _dstDevFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDstActivationCard() {
    return _buildCollapsibleCard(
      cardKey: 'dstActivation',
      icon: Icons.power_settings_new,
      title: 'Daylight Record Activation',
      description: 'Enable / disable daylight savings feature.',
      toggleKey: const Key(DateTimeKeys.dstActivationCardToggle),
      content: Column(
        children: [
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Row(
                children: [
                  Text(
                    'Active (ON/OFF)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFF1F5F9)
                          : DesignTokens.textPrimary,
                    ),
                  ),
                  SizedBox(width: DesignTokens.spaceMd),
                  Switch(
                    key: const Key(DateTimeKeys.dstActiveSwitch),
                    value: _dstActive,
                    onChanged: (val) => setState(() => _dstActive = val),
                    activeThumbColor: isDark
                        ? const Color(0xFF60A5FA)
                        : DesignTokens.primary600,
                  ),
                ],
              );
            },
          ),
          SizedBox(height: DesignTokens.spaceMd),
          _buildActionRow([
            _buildSecondaryButton(
              key: const Key(DateTimeKeys.dstActivationReadBtn),
              icon: Icons.visibility,
              label: 'Read',
              onPressed: _readDstActivation,
            ),
            _buildPrimaryButton(
              key: const Key(DateTimeKeys.dstActivationWriteBtn),
              icon: Icons.save,
              label: 'Write',
              onPressed: _writeDstActivation,
            ),
          ]),
          if (_dstActiveFeedback.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: DesignTokens.spaceSm),
              child: Text(
                _dstActiveFeedback,
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? itemBuilder,
    required ValueChanged<T?> onChanged,
    Key? key,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFF1F5F9) : DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spaceSm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e3a5f) : null,
            border: Border.all(
                color: isDark ? const Color(0xFF334155) : DesignTokens.gray300),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              key: key,
              value: items.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1e293b) : null,
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemBuilder?.call(item) ?? item.toString(),
                      style: TextStyle(
                          color: isDark ? const Color(0xFFF1F5F9) : null)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayDropdown({
    required String label,
    required int value,
    required bool includeSpecial,
    required ValueChanged<int?> onChanged,
    Key? key,
  }) {
    final items = List.generate(31, (i) => i + 1);
    if (includeSpecial) {
      items.addAll([253, 254, 255]);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFF1F5F9) : DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spaceSm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e3a5f) : null,
            border: Border.all(
                color: isDark ? const Color(0xFF334155) : DesignTokens.gray300),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              key: key,
              value: items.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1e293b) : null,
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
              items: items.map((item) {
                String displayText;
                if (item == 253) {
                  displayText = 'FD - Second-to-last day';
                } else if (item == 254) {
                  displayText = 'FE - Last day';
                } else if (item == 255) {
                  displayText = 'FF - Unspecified';
                } else {
                  displayText = item.toString();
                }
                return DropdownMenuItem<int>(
                  value: item,
                  child: Text(displayText,
                      style: TextStyle(
                          color: isDark ? const Color(0xFFF1F5F9) : null)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayOfWeekDropdown({
    required String label,
    required int value,
    required ValueChanged<int?> onChanged,
    Key? key,
  }) {
    final items = [1, 2, 3, 4, 5, 6, 7, 255];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFF1F5F9) : DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spaceSm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1e3a5f) : null,
            border: Border.all(
                color: isDark ? const Color(0xFF334155) : DesignTokens.gray300),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              key: key,
              value: items.contains(value) ? value : null,
              isExpanded: true,
              dropdownColor: isDark ? const Color(0xFF1e293b) : null,
              padding: EdgeInsets.symmetric(horizontal: DesignTokens.spaceMd),
              items: items.map((item) {
                String displayText;
                if (item == 255) {
                  displayText = 'FF - Unspecified';
                } else {
                  // 1=Monday, 2=Tuesday, ..., 7=Sunday
                  final days = [
                    'Monday',
                    'Tuesday',
                    'Wednesday',
                    'Thursday',
                    'Friday',
                    'Saturday',
                    'Sunday'
                  ];
                  displayText = '$item - ${days[item - 1]}';
                }
                return DropdownMenuItem<int>(
                  value: item,
                  child: Text(displayText),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    Key? key,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFF1F5F9) : DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spaceSm),
        TextField(
          key: key,
          controller: TextEditingController(text: value.toString()),
          keyboardType: TextInputType.number,
          style: TextStyle(color: isDark ? const Color(0xFFF1F5F9) : null),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? DesignTokens.darkFill : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                  color:
                      isDark ? DesignTokens.darkBorder : DesignTokens.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                  color:
                      isDark ? DesignTokens.darkBorder : DesignTokens.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
              borderSide: BorderSide(
                  color:
                      isDark ? DesignTokens.darkFocus : DesignTokens.primary600,
                  width: 1.2),
            ),
            contentPadding: EdgeInsets.all(DesignTokens.spaceMd),
          ),
          onChanged: (val) {
            final num = int.tryParse(val);
            if (num != null && num >= min && num <= max) {
              onChanged(num);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeField({Key? key}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time (HH:MM:SS)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? const Color(0xFFF1F5F9) : DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spaceSm),
        InkWell(
          key: key,
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (time != null && mounted) {
              final seconds =
                  await _showSecondsPickerDialog(context, _selectedSeconds);
              if (seconds != null) {
                setState(() {
                  _selectedTime = time;
                  _selectedSeconds = seconds;
                });
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1e3a5f) : null,
              border: Border.all(
                  color:
                      isDark ? const Color(0xFF334155) : DesignTokens.gray300),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:${_selectedSeconds.toString().padLeft(2, '0')}',
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFF1F5F9) : null),
                ),
                Icon(Icons.access_time,
                    color: isDark ? const Color(0xFF94A3B8) : null),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<int?> _showSecondsPickerDialog(
      BuildContext context, int initialSeconds) async {
    int selectedSeconds = initialSeconds;

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Seconds'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$selectedSeconds seconds',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                            initialItem: selectedSeconds),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedSeconds = index;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: index == selectedSeconds
                                      ? DesignTokens.primary600
                                      : Colors.grey,
                                  fontWeight: index == selectedSeconds
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                          childCount: 60,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(selectedSeconds),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTimePickerWithSeconds({
    required String label,
    required TimeOfDay time,
    required int seconds,
    required void Function(TimeOfDay, int) onChanged,
    Key? key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DesignTokens.textPrimary,
          ),
        ),
        SizedBox(height: DesignTokens.spaceSm),
        InkWell(
          key: key,
          onTap: () async {
            final newTime = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (newTime != null && mounted) {
              final newSeconds =
                  await _showSecondsPickerDialog(context, seconds);
              if (newSeconds != null) {
                onChanged(newTime, newSeconds);
              }
            }
          },
          child: Container(
            padding: EdgeInsets.all(DesignTokens.spaceMd),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.gray300),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 14),
                ),
                const Icon(Icons.access_time),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionRow(List<Widget> buttons) {
    return Wrap(
      spacing: DesignTokens.spaceSm,
      runSpacing: DesignTokens.spaceSm,
      children: buttons,
    );
  }

  Widget _buildPrimaryButton({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    return ElevatedButton.icon(
      key: key,
      onPressed:
          isConnected && userRights.hasRightForFeature('Set', FeatureKeys.clock)
              ? onPressed
              : null,
      icon: const Icon(Icons.edit, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    Key? key,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    String right = 'Get',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    // "Update" uses the Set right — restore original outlined style for it
    if (right == 'Set') {
      final buttonColor = isDark ? Colors.white : DesignTokens.primary600;
      return OutlinedButton.icon(
        key: key,
        onPressed: isConnected &&
                userRights.hasRightForFeature(right, FeatureKeys.clock)
            ? onPressed
            : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor),
          padding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spaceLg,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        ),
      );
    }
    // Read buttons — orange with eye icon
    return ElevatedButton.icon(
      key: key,
      onPressed:
          isConnected && userRights.hasRightForFeature(right, FeatureKeys.clock)
              ? onPressed
              : null,
      icon: const Icon(Icons.visibility, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.spaceLg,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
      ),
    );
  }

  // Helper Methods
  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  // Action Handlers
  void _refreshAll() {
    client.getClock().then((datetime) {
      DateTime dt = DateTime.parse(datetime.replaceAll(' ', 'T'));
      setState(() {
        _selectedDay = dt.day;
        _selectedMonth = dt.month;
        _selectedYear = dt.year;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      });
    });
  }

  Future<void> _readDateTime() async {
    setState(() {
      _loading = true;
    });
    try {
      final datetime = await client.getClock();
      final dt = DateTime.parse(datetime.replaceAll(' ', 'T'));
      setState(() {
        _selectedDay = dt.day;
        _selectedMonth = dt.month;
        _selectedYear = dt.year;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
        _selectedSeconds = dt.second;
        _clockFeedback =
            'Read: ${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _clockFeedback = 'Error reading date/time: ${_extractErrorMessage(e)}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
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

  void _writeDateTime() async {
    try {
      final dateTimeString =
          '${_selectedYear.toString().padLeft(4, '0')}-${_selectedMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')} ${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:${_selectedSeconds.toString().padLeft(2, '0')}';
      final success = await client.setClock(dateTimeString);
      if (!success) {
        throw Exception('Failed to set clock');
      }
      setState(() {
        _clockFeedback = 'Write OK: $dateTimeString';
      });
    } catch (e) {
      setState(() {
        _clockFeedback = 'Error writing date/time: ${_extractErrorMessage(e)}';
      });
    }
  }

  void _updateDateTime() {
    _readDateTime();
    setState(() {
      _clockFeedback = 'Update performed';
    });
  }

  Future<void> _readTimezone() async {
    setState(() {
      _loading = true;
    });
    try {
      final resp = await client.getTimezone();
      setState(() {
        _timezoneOffset = resp.value;
        _tzFeedback = 'Read offset: $_timezoneOffset min';
      });
    } catch (e) {
      setState(() {
        _tzFeedback = 'Error reading timezone: ${_extractErrorMessage(e)}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _writeTimezone() async {
    try {
      final success = await client.setTimezone(_timezoneOffset);
      if (!success) {
        throw Exception('Failed to set timezone');
      }
      setState(() {
        _tzFeedback = 'Offset saved';
      });
    } catch (e) {
      setState(() {
        _tzFeedback = 'Error writing timezone: ${_extractErrorMessage(e)}';
      });
    }
  }

  void _readIncremental() async {
    setState(() {
      _loading = true;
    });
    try {
      final dateTime = await client.getIncrementalDate();
      setState(() {
        _incDay = dateTime.day;
        _incMonth = dateTime.month;
        _incTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        _incSeconds = dateTime.second;
        _incDayOfWeek = dateTime.dayOfWeek;
        _incFeedback =
            'Read: ${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _incFeedback =
            'Error reading incremental date: ${_extractErrorMessage(e)}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _writeIncremental() async {
    try {
      final dateTime = DaylightSavingsTime()
        ..day = _incDay
        ..month = _incMonth
        ..hour = _incTime.hour
        ..minute = _incTime.minute
        ..second = _incSeconds
        ..dayOfWeek = _incDayOfWeek;

      final success = await client.setIncrementalDate(dateTime);
      if (!success) {
        throw Exception('Failed to set incremental date');
      }
      setState(() {
        _incFeedback =
            'Write OK: ${_incDay.toString().padLeft(2, '0')}-${_incMonth.toString().padLeft(2, '0')} ${_incTime.hour.toString().padLeft(2, '0')}:${_incTime.minute.toString().padLeft(2, '0')}:${_incSeconds.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _incFeedback =
            'Error writing incremental date: ${_extractErrorMessage(e)}';
      });
    }
  }

  void _readDecremental() async {
    setState(() {
      _loading = true;
    });
    try {
      final dateTime = await client.getDecrementalDate();
      setState(() {
        _decDay = dateTime.day;
        _decMonth = dateTime.month;
        _decTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        _decSeconds = dateTime.second;
        _decDayOfWeek = dateTime.dayOfWeek;
        _decFeedback =
            'Read: ${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _decFeedback =
            'Error reading decremental date: ${_extractErrorMessage(e)}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _writeDecremental() async {
    try {
      final dateTime = DaylightSavingsTime()
        ..day = _decDay
        ..month = _decMonth
        ..hour = _decTime.hour
        ..minute = _decTime.minute
        ..second = _decSeconds
        ..dayOfWeek = _decDayOfWeek;

      final success = await client.setDecrementalDate(dateTime);
      if (!success) {
        throw Exception('Failed to set decremental date');
      }
      setState(() {
        _decFeedback =
            'Write OK: ${_decDay.toString().padLeft(2, '0')}-${_decMonth.toString().padLeft(2, '0')} ${_decTime.hour.toString().padLeft(2, '0')}:${_decTime.minute.toString().padLeft(2, '0')}:${_decSeconds.toString().padLeft(2, '0')}';
      });
    } catch (e) {
      setState(() {
        _decFeedback =
            'Error writing decremental date: ${_extractErrorMessage(e)}';
      });
    }
  }

  void _readDstDeviation() async {
    setState(() {
      _loading = true;
    });
    try {
      final resp = await client.getDaylightSavingDeviation();
      setState(() {
        _dstDeviation = resp.value;
        _dstDevFeedback = 'Deviation read: ${_dstDeviation} min';
      });
    } catch (e) {
      setState(() {
        _dstDevFeedback = 'Error reading deviation: ${_extractErrorMessage(e)}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _writeDstDeviation() async {
    try {
      final success = await client.setDaylightSavingDeviation(_dstDeviation);
      if (!success) {
        throw Exception('Failed to set DST deviation');
      }
      setState(() {
        _dstDevFeedback = 'Deviation written';
      });
    } catch (e) {
      setState(() {
        _dstDevFeedback = 'Error writing deviation: ${_extractErrorMessage(e)}';
      });
    }
  }

  void _readDstActivation() async {
    setState(() {
      _loading = true;
    });
    try {
      final active = await client.getDaylightSavingActivation();
      setState(() {
        _dstActive = active;
        _dstActiveFeedback = 'State read';
      });
    } catch (e) {
      setState(() {
        _dstActiveFeedback =
            'Error reading activation: ${_extractErrorMessage(e)}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _writeDstActivation() async {
    try {
      final success = await client.setDaylightSavingActivation(_dstActive);
      if (!success) {
        throw Exception('Failed to set DST activation');
      }
      setState(() {
        _dstActiveFeedback = 'State written';
      });
    } catch (e) {
      setState(() {
        _dstActiveFeedback =
            'Error writing activation: ${_extractErrorMessage(e)}';
      });
    }
  }
}

/// Call once at startup (e.g. in main.dart) to make the Date Time page
/// available in the export templates screen.
void registerDateTimePage() {
  ExportRegistry.instance.register(
    const ExportedPageInfo(
      id: 'date_time',
      label: 'Date Time',
      icon: Icons.access_time_outlined,
      builder: _buildDateTimePage,
      tokens: {
        'clock.day': 'Day of month (1-31)',
        'clock.month': 'Month (1-12)',
        'clock.year': 'Year',
        'clock.hour': 'Hour (0-23)',
        'clock.minute': 'Minute (0-59)',
        'clock.second': 'Second (0-59)',
        'clock.timezone_offset_min': 'Timezone offset in minutes',
        'dst_incremental.day': 'DST start day',
        'dst_incremental.month': 'DST start month',
        'dst_incremental.day_of_week': 'DST start day of week',
        'dst_decremental.day': 'DST end day',
        'dst_decremental.month': 'DST end month',
        'dst_decremental.day_of_week': 'DST end day of week',
        'dst.deviation_min': 'DST deviation in minutes',
        'dst.active': 'DST activation flag',
      },
    ),
  );
}

Widget _buildDateTimePage(BuildContext _) => const DateTimePage();
