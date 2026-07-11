import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widget_keys.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';

// ---------------------------------------------------------------------------
// Gurux-inspired DLMS Translator
// Tabs: PDU  |  Messages
// ---------------------------------------------------------------------------

class GuruxTranslatorPage extends StatefulWidget {
  const GuruxTranslatorPage({super.key});

  @override
  State<GuruxTranslatorPage> createState() => _GuruxTranslatorPageState();
}

class _GuruxTranslatorPageState extends State<GuruxTranslatorPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final IMeterClient _client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _client = meterClientFactory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DLMS Translator'),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.data_object, size: 18), text: 'PDU'),
            Tab(icon: Icon(Icons.list_alt, size: 18), text: 'Messages'),
            Tab(icon: Icon(Icons.translate, size: 18), text: 'DLMS Translate'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PduTab(client: _client),
          _MessagesTab(client: _client),
          _DlmsTranslateTab(client: _client),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DLMS Translate Tab â€” calls DlmsTranslate RPC directly
// ---------------------------------------------------------------------------

class _DlmsTranslateTab extends StatefulWidget {
  const _DlmsTranslateTab({required this.client});
  final IMeterClient client;

  @override
  State<_DlmsTranslateTab> createState() => _DlmsTranslateTabState();
}

class _DlmsTranslateTabState extends State<_DlmsTranslateTab> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final input = _inputCtrl.text.trim().replaceAll(' ', '');
    if (input.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _outputCtrl.clear();
    });

    try {
      final result = await widget.client.dlmsTranslate(input, false);
      if (!mounted) return;
      setState(() {
        _outputCtrl.text = result;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  void _copyOutput() {
    if (_outputCtrl.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _outputCtrl.text));
    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
      const SnackBar(
        content: Text('Output copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clear() {
    setState(() {
      _inputCtrl.clear();
      _outputCtrl.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignTokens.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) ...[
                  _ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                      dismissKey: const Key(
                          GuruxTranslatorKeys.dlmsDismissErrorBtn)),
                  const SizedBox(height: 16),
                ],
                LayoutBuilder(builder: (_, constraints) {
                  final wide = constraints.maxWidth > 700;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _CodePanel(
                            label: 'XDR / Hex PDU',
                            controller: _inputCtrl,
                            hint:
                                'Paste raw hex PDU, e.g.  C0 01 C1 00 00 01 00 28 FF 02',
                            readOnly: false,
                            accentColor: const Color(0xFF1565C0),
                            textFieldKey: const Key(
                                GuruxTranslatorKeys.dlmsInputField),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 80),
                          child: _loading
                              ? const SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5))
                              : FilledButton.icon(
                                  key: const Key(GuruxTranslatorKeys.dlmsTranslateBtn),
                                  onPressed: _translate,
                                  icon: const Icon(Icons.play_arrow, size: 18),
                                  label: const Text('Translate'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: DesignTokens.primary600,
                                  ),
                                ),
                        ),
                        Expanded(
                          child: _CodePanel(
                            label: 'XML',
                            controller: _outputCtrl,
                            hint: 'Translation result appears hereâ€¦',
                            readOnly: true,
                            lightBackground: true,
                            accentColor: const Color(0xFF2E7D32),
                            textFieldKey: const Key(
                                GuruxTranslatorKeys.dlmsOutputField),
                          ),
                        ),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _CodePanel(
                        label: 'XDR / Hex PDU',
                        controller: _inputCtrl,
                        hint: 'Paste raw hex PDU',
                        readOnly: false,
                        accentColor: const Color(0xFF1565C0),
                        textFieldKey:
                            const Key(GuruxTranslatorKeys.dlmsInputField),
                      ),
                      const SizedBox(height: 12),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton.icon(
                              key: const Key(GuruxTranslatorKeys.dlmsTranslateBtn),
                              onPressed: _translate,
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Translate'),
                              style: FilledButton.styleFrom(
                                backgroundColor: DesignTokens.primary600,
                              ),
                            ),
                      const SizedBox(height: 12),
                      _CodePanel(
                        label: 'XML',
                        controller: _outputCtrl,
                        hint: 'Translation result appears hereâ€¦',
                        readOnly: true,
                        lightBackground: true,
                        accentColor: const Color(0xFF2E7D32),
                        textFieldKey:
                            const Key(GuruxTranslatorKeys.dlmsOutputField),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      key: const Key(GuruxTranslatorKeys.dlmsClearBtn),
                      onPressed: _clear,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      key: const Key(GuruxTranslatorKeys.dlmsCopyBtn),
                      onPressed: _copyOutput,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy output'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PDU Tab â€” translate a single DLMS PDU (XDR hex â†” XML)
// ---------------------------------------------------------------------------

class _PduTab extends StatefulWidget {
  const _PduTab({required this.client});
  final IMeterClient client;

  @override
  State<_PduTab> createState() => _PduTabState();
}

class _PduTabState extends State<_PduTab> {
  final _inputCtrl = TextEditingController();
  final _outputCtrl = TextEditingController();
  bool _xdrToXml = true; // true = XDRâ†’XML, false = XMLâ†’XDR
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _outputCtrl.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final input = _inputCtrl.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _outputCtrl.clear();
    });

    try {
      final results = await widget.client.translateData([
        TranslateDataItemRequest()
          ..data = input
          ..isXdrInput = _xdrToXml,
      ]);

      if (!mounted) return;

      final item = results.isNotEmpty ? results.first : null;
      if (item == null || !item.success) {
        setState(() {
          _error = item?.error.isNotEmpty == true
              ? item!.error
              : 'Translation failed.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _outputCtrl.text = item.output;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  void _swap() {
    final prev = _inputCtrl.text;
    _inputCtrl.text = _outputCtrl.text;
    _outputCtrl.text = prev;
    setState(() => _xdrToXml = !_xdrToXml);
  }

  void _copyOutput() {
    if (_outputCtrl.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _outputCtrl.text));
    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
      const SnackBar(
        content: Text('Output copied to clipboard'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clear() {
    setState(() {
      _inputCtrl.clear();
      _outputCtrl.clear();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignTokens.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Direction bar
                _DirectionBar(
                  xdrToXml: _xdrToXml,
                  onToggle: () => setState(() => _xdrToXml = !_xdrToXml),
                  onSwap: _swap,
                  directionKey:
                      const Key(GuruxTranslatorKeys.pduDirectionToggle),
                  swapKey: const Key(GuruxTranslatorKeys.pduSwapBtn),
                ),
                const SizedBox(height: 16),

                // Error banner
                if (_error != null) ...[
                  _ErrorBanner(
                      message: _error!,
                      onDismiss: () => setState(() => _error = null),
                      dismissKey:
                          const Key(GuruxTranslatorKeys.pduDismissErrorBtn)),
                  const SizedBox(height: 16),
                ],

                // Input / Output side by side on wide screens
                LayoutBuilder(builder: (_, constraints) {
                  final wide = constraints.maxWidth > 700;
                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _inputPanel()),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 80),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _loading
                                  ? const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2.5))
                                  : FilledButton.icon(
                                      key: const Key(
                                          GuruxTranslatorKeys.pduTranslateBtn),
                                      onPressed: _translate,
                                      icon: const Icon(Icons.play_arrow,
                                          size: 18),
                                      label: const Text('Translate'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            DesignTokens.primary600,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        Expanded(child: _outputPanel()),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _inputPanel(),
                      const SizedBox(height: 12),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton.icon(
                              key: const Key(GuruxTranslatorKeys.pduTranslateBtn),
                              onPressed: _translate,
                              icon: const Icon(Icons.play_arrow, size: 18),
                              label: const Text('Translate'),
                              style: FilledButton.styleFrom(
                                backgroundColor: DesignTokens.primary600,
                              ),
                            ),
                      const SizedBox(height: 12),
                      _outputPanel(),
                    ],
                  );
                }),

                const SizedBox(height: 16),

                // Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      key: const Key(GuruxTranslatorKeys.pduClearBtn),
                      onPressed: _clear,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      key: const Key(GuruxTranslatorKeys.pduCopyBtn),
                      onPressed: _copyOutput,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copy output'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputPanel() {
    return _CodePanel(
      label: _xdrToXml ? 'XDR / Hex PDU' : 'XML',
      controller: _inputCtrl,
      hint: _xdrToXml
          ? 'Paste raw hex PDU, e.g.  C0 01 C1 00 00 01 00 28 FF 02'
          : '<GetRequest>\n  ...\n</GetRequest>',
      readOnly: false,
      accentColor: const Color(0xFF1565C0),
      textFieldKey: const Key(GuruxTranslatorKeys.pduInputField),
    );
  }

  Widget _outputPanel() {
    return _CodePanel(
      label: _xdrToXml ? 'XML' : 'XDR / Hex',
      controller: _outputCtrl,
      hint: 'Translation result appears hereâ€¦',
      readOnly: true,
      accentColor: const Color(0xFF2E7D32),
      textFieldKey: const Key(GuruxTranslatorKeys.pduOutputField),
    );
  }
}

// ---------------------------------------------------------------------------
// Messages Tab â€” decode multiple frames sequentially
// ---------------------------------------------------------------------------

class _MessagesTab extends StatefulWidget {
  const _MessagesTab({required this.client});
  final IMeterClient client;

  @override
  State<_MessagesTab> createState() => _MessagesTabState();
}

class _DecodedMessage {
  final String input;
  final String output;
  final bool success;
  final String? error;
  const _DecodedMessage({
    required this.input,
    required this.output,
    required this.success,
    this.error,
  });
}

class _MessagesTabState extends State<_MessagesTab> {
  final _inputCtrl = TextEditingController();
  bool _xdrToXml = true;
  bool _loading = false;
  String? _error;
  final List<_DecodedMessage> _messages = [];

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    // Split lines, skip empty / comments
    final lines = _inputCtrl.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('#'))
        .toList();

    if (lines.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _messages.clear();
    });

    try {
      final requests = lines
          .map((line) => TranslateDataItemRequest()
            ..data = line
            ..isXdrInput = _xdrToXml)
          .toList();

      final results = await widget.client.translateData(requests);

      if (!mounted) return;

      final decoded = <_DecodedMessage>[];
      for (int i = 0; i < results.length; i++) {
        final r = results[i];
        decoded.add(_DecodedMessage(
          input: lines.length > i ? lines[i] : r.input,
          output: r.output,
          success: r.success && r.output.isNotEmpty,
          error: r.success ? null : r.error,
        ));
      }

      setState(() {
        _messages.addAll(decoded);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  void _clear() {
    setState(() {
      _inputCtrl.clear();
      _messages.clear();
      _error = null;
    });
  }

  void _copyAll() {
    if (_messages.isEmpty) return;
    final buf = StringBuffer();
    for (int i = 0; i < _messages.length; i++) {
      final m = _messages[i];
      buf.writeln('<!-- Message ${i + 1} -->');
      buf.writeln(m.success ? m.output : '<!-- ERROR: ${m.error} -->');
      buf.writeln();
    }
    Clipboard.setData(ClipboardData(text: buf.toString()));
    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
      const SnackBar(
        content: Text('All decoded messages copied'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignTokens.background,
      child: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: DesignTokens.surface,
            child: Row(
              children: [
                // Direction toggle
                SegmentedButton<bool>(
                  key: const Key(
                      GuruxTranslatorKeys.messagesDirectionToggle),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: DesignTokens.primary600,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: DesignTokens.textSecondary,
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: true, label: Text('XDR â†’ XML')),
                    ButtonSegment(value: false, label: Text('XML â†’ XDR')),
                  ],
                  selected: {_xdrToXml},
                  onSelectionChanged: (s) =>
                      setState(() => _xdrToXml = s.first),
                ),
                const Spacer(),
                // Actions
                TextButton.icon(
                  key: const Key(GuruxTranslatorKeys.messagesClearBtn),
                  onPressed: _clear,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  key: const Key(GuruxTranslatorKeys.messagesCopyAllBtn),
                  onPressed: _messages.isEmpty ? null : _copyAll,
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy all'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  key: const Key(GuruxTranslatorKeys.messagesTranslateAllBtn),
                  onPressed: _loading ? null : _translate,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow, size: 18),
                  label: Text(_loading ? 'Translatingâ€¦' : 'Translate all'),
                  style: FilledButton.styleFrom(
                      backgroundColor: DesignTokens.primary600),
                ),
              ],
            ),
          ),

          // Error banner
          if (_error != null)
            _ErrorBanner(
              message: _error!,
              onDismiss: () => setState(() => _error = null),
              dismissKey: const Key(
                  GuruxTranslatorKeys.messagesDismissErrorBtn),
            ),

          // Body: input on left, decoded list on right
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Input panel (fixed width or flexible)
                  SizedBox(
                    width: 340,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PanelHeader(
                          label: _xdrToXml ? 'Raw Hex Frames' : 'XML Frames',
                          icon: Icons.input,
                          color: const Color(0xFF1565C0),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'One frame per line. Lines starting with # are ignored.',
                          style: TextStyle(
                              fontSize: 11, color: DesignTokens.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: DesignTokens.brMd,
                              border: Border.all(color: DesignTokens.gray200),
                            ),
                            child: TextField(
                              key: const Key(
                                  GuruxTranslatorKeys.messagesInputField),
                              controller: _inputCtrl,
                              maxLines: null,
                              expands: true,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(12),
                                border: InputBorder.none,
                                hintText: _xdrToXml
                                    ? '# Request\nC0 01 C1 00 00 01...\n# Response\nC4 01 C1...'
                                    : '<GetRequest>...</GetRequest>\n<GetResponse>...</GetResponse>',
                                hintStyle: const TextStyle(
                                    color: Colors.black38, fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Decoded messages list
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _PanelHeader(
                          label: 'Decoded Messages (${_messages.length})',
                          icon: Icons.checklist_rtl,
                          color: const Color(0xFF2E7D32),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _messages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.inbox,
                                          size: 48,
                                          color: DesignTokens.gray400),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Paste frames on the left and press "Translate all"',
                                        style: TextStyle(
                                            color: DesignTokens.textSecondary,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _messages.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (_, i) => _MessageCard(
                                    index: i + 1,
                                    message: _messages[i],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared widgets
// ---------------------------------------------------------------------------

class _DirectionBar extends StatelessWidget {
  const _DirectionBar({
    required this.xdrToXml,
    required this.onToggle,
    required this.onSwap,
    this.directionKey,
    this.swapKey,
  });
  final bool xdrToXml;
  final VoidCallback onToggle;
  final VoidCallback onSwap;
  final Key? directionKey;
  final Key? swapKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: DesignTokens.brMd,
        border: Border.all(color: DesignTokens.gray200),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz,
              color: DesignTokens.textSecondary, size: 18),
          const SizedBox(width: 10),
          const Text('Direction:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 12),
          SegmentedButton<bool>(
            key: directionKey,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: DesignTokens.primary600,
              selectedForegroundColor: Colors.white,
              foregroundColor: DesignTokens.textSecondary,
              textStyle: const TextStyle(fontSize: 13),
            ),
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, label: Text('XDR â†’ XML')),
              ButtonSegment(value: false, label: Text('XML â†’ XDR')),
            ],
            selected: {xdrToXml},
            onSelectionChanged: (s) => onToggle(),
          ),
          const Spacer(),
          Tooltip(
            message: 'Swap input and output',
            child: OutlinedButton.icon(
              key: swapKey,
              onPressed: onSwap,
              icon: const Icon(Icons.swap_vert, size: 16),
              label: const Text('Swap'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodePanel extends StatelessWidget {
  const _CodePanel({
    required this.label,
    required this.controller,
    required this.hint,
    required this.readOnly,
    required this.accentColor,
    this.lightBackground,
    this.textFieldKey,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Color accentColor;
  final bool? lightBackground;
  final Key? textFieldKey;

  @override
  Widget build(BuildContext context) {
    final isLight = lightBackground ?? !readOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PanelHeader(
            label: label,
            icon: readOnly ? Icons.output : Icons.input,
            color: accentColor),
        const SizedBox(height: 8),
        Container(
          height: 340,
          decoration: BoxDecoration(
            color: isLight ? Colors.white : const Color(0xFF1E1E1E),
            borderRadius: DesignTokens.brMd,
            border: Border.all(color: DesignTokens.gray300),
          ),
          child: TextField(
            key: textFieldKey,
            controller: controller,
            maxLines: null,
            expands: true,
            readOnly: readOnly,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12.5,
              color: isLight ? Colors.black : const Color(0xFFD4D4D4),
              height: 1.5,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color:
                    isLight ? Colors.black38 : Colors.white.withOpacity(0.25),
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PanelHeader extends StatelessWidget {
  const _PanelHeader(
      {required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(
      {required this.message, required this.onDismiss, this.dismissKey});
  final String message;
  final VoidCallback onDismiss;
  final Key? dismissKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: DesignTokens.danger.withOpacity(0.1),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: DesignTokens.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: DesignTokens.danger, fontSize: 13)),
          ),
          IconButton(
            key: dismissKey,
            icon: const Icon(Icons.close, size: 16),
            color: DesignTokens.danger,
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  const _MessageCard({required this.index, required this.message});
  final int index;
  final _DecodedMessage message;

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  bool _expanded = true;

  void _copy() {
    Clipboard.setData(ClipboardData(text: widget.message.output));
    ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
      SnackBar(
        content: Text('Message ${widget.index} copied'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ok = widget.message.success;
    final badgeColor = ok ? const Color(0xFF2E7D32) : DesignTokens.danger;
    final badgeBg =
        ok ? const Color(0xFFE8F5E9) : DesignTokens.danger.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        borderRadius: DesignTokens.brMd,
        border: Border.all(
            color: ok
                ? const Color(0xFF4CAF5040)
                : DesignTokens.danger.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${widget.index}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: badgeColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message.input,
                      style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: DesignTokens.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (ok)
                    IconButton(
                      icon: const Icon(Icons.copy, size: 15),
                      tooltip: 'Copy output',
                      onPressed: _copy,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: DesignTokens.textSecondary,
                  ),
                ],
              ),
            ),
          ),

          // Body
          if (_expanded)
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: ok
                    ? SelectableText(
                        widget.message.output,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: Color(0xFFD4D4D4),
                          height: 1.5,
                        ),
                      )
                    : Text(
                        widget.message.error ?? 'Unknown error',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: DesignTokens.danger.withOpacity(0.85),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

