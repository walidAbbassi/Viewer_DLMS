import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/breadcrumb.dart';
import '../services/push_server_provider.dart';
import '../../core/widget_keys.dart';

class PushSetupServerPage extends ConsumerStatefulWidget {
  const PushSetupServerPage({super.key});

  @override
  ConsumerState<PushSetupServerPage> createState() =>
      _PushSetupServerPageState();
}

class _PushSetupServerPageState extends ConsumerState<PushSetupServerPage> {
  late final TextEditingController _hostCtrl;
  late final TextEditingController _portCtrl;
  late String _selectedType;

  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    final s = ref.read(pushServerProvider);
    _hostCtrl = TextEditingController(text: s.host);
    _portCtrl = TextEditingController(text: s.port.toString());
    _selectedType = s.selectedType;
  }

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = SemanticColors.of(context);
    final state = ref.watch(pushServerProvider);
    final notifier = ref.read(pushServerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Setup Server'),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (state.notifications.isNotEmpty)
            IconButton(
              key: const Key(PushSetupServerKeys.clearNotificationsBtn),
              tooltip: 'Clear notifications',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: notifier.clearNotifications,
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
                segments: ['Menu', 'Push Setups', 'Push Setup Server']),
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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildConfigCard(state, notifier),
                    const SizedBox(height: 16),
                    if (state.error != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withOpacity(0.15),
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.redAccent, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.error!,
                                style: const TextStyle(
                                    color: Colors.redAccent, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(child: _buildNotificationList(state, isDark)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigCard(PushServerState state, PushServerNotifier notifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Configuration',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    key: const Key(PushSetupServerKeys.hostField),
                    controller: _hostCtrl,
                    enabled: !state.running,
                    decoration: const InputDecoration(
                      labelText: 'Host',
                      prefixIcon: Icon(Icons.dns_outlined),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: const Key(PushSetupServerKeys.portField),
                    controller: _portCtrl,
                    enabled: !state.running,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      prefixIcon: Icon(Icons.settings_ethernet),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    key: const Key(PushSetupServerKeys.typeDropdown),
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.category_outlined),
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'TCP', child: Text('TCP')),
                      DropdownMenuItem(value: 'UDP', child: Text('UDP')),
                    ],
                    onChanged: state.running
                        ? null
                        : (v) => setState(() => _selectedType = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                state.running
                    ? ElevatedButton.icon(
                        key: const Key(PushSetupServerKeys.stopBtn),
                        onPressed: state.stopping ? null : notifier.stop,
                        icon: state.stopping
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.stop_circle_outlined),
                        label:
                            Text(state.stopping ? 'Stopping...' : 'Stop Server'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      )
                    : ElevatedButton.icon(
                        key: const Key(PushSetupServerKeys.startBtn),
                        onPressed: state.starting
                            ? null
                            : () => notifier.start(
                                  _hostCtrl.text.trim(),
                                  int.tryParse(_portCtrl.text.trim()) ?? 4059,
                                  _selectedType,
                                ),
                        icon: state.starting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.play_circle_outline),
                        label:
                            Text(state.starting ? 'Starting...' : 'Start Server'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: state.running
                        ? Colors.green.withOpacity(0.15)
                        : Colors.grey.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.running ? Colors.green : Colors.grey,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.running
                            ? Icons.circle
                            : Icons.circle_outlined,
                        size: 10,
                        color: state.running ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        state.running ? 'Running' : 'Stopped',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: state.running ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(PushServerState state, bool isDark) {
    if (state.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_outlined,
                size: 56,
                color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 12),
            Text(
              state.running
                  ? 'Waiting for push notifications...'
                  : 'Start the server to receive push notifications.',
              style: TextStyle(
                  color: isDark ? Colors.white38 : Colors.black38,
                  fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'Received Notifications (${state.notifications.length})',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ListView.separated(
            controller: _scrollCtrl,
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) =>
                _NotificationCard(index: i, entry: state.notifications[i]),
          ),
        ),
      ],
    );
  }
}

// -- Notification card --------------------------------------------------------

class _NotificationCard extends StatefulWidget {
  final int index;
  final PushNotificationEntry entry;
  const _NotificationCard({required this.index, required this.entry});

  @override
  State<_NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<_NotificationCard> {
  bool _expanded = false;

  String get _timeLabel {
    final t = widget.entry.timestamp;
    return '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? const Color(0xFF1e1e2e) : const Color(0xFFF8FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: Key(PushSetupServerKeys.notificationToggle(widget.index)),
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_outlined,
                      size: 16,
                      color: isDark ? Colors.yellowAccent : Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    _timeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.entry.xml.length > 80
                          ? '${widget.entry.xml.substring(0, 80)}...'
                          : widget.entry.xml,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: Key(PushSetupServerKeys.notificationCopyBtn(widget.index)),
                    tooltip: 'Copy XML',
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 28, minHeight: 28),
                    icon: const Icon(Icons.copy, size: 14),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: widget.entry.xml)),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                widget.entry.xml,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  decoration: TextDecoration.none,
                  color: isDark
                      ? const Color(0xFFa8d8a8)
                      : const Color(0xFF1a5c1a),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
