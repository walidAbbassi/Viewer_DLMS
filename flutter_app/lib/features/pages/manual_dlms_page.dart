import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../util/grpc_error.dart';
import '../../grpc/manual_dlms_client.dart';
import '../../grpc/generated/manual_dlms.pb.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Page root
// ─────────────────────────────────────────────────────────────────────────────

class ManualDlmsPage extends StatefulWidget {
  const ManualDlmsPage({super.key});

  @override
  State<ManualDlmsPage> createState() => _ManualDlmsPageState();
}

class _ManualDlmsPageState extends State<ManualDlmsPage>
    with SingleTickerProviderStateMixin {
  late final ManualDlmsClient _client;
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _client = manualDlmsClientFactory();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = SemanticColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual DLMS'),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.send), text: 'Normal'),
            Tab(icon: Icon(Icons.list), text: 'With List'),
            Tab(icon: Icon(Icons.developer_board), text: 'Raw Frame'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const Breadcrumb(segments: ['Menu', 'Manual DLMS']),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _NormalTab(client: _client),
                _WithListTab(client: _client),
                _RawFrameTab(client: _client),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Dark-mode-aware monospace output box.
class _OutputBox extends StatelessWidget {
  const _OutputBox({required this.text, this.label = 'Output'});
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = DesignTokens.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark
                      ? DesignTokens.darkTextSecondary
                      : DesignTokens.textSecondary)),
          const SizedBox(width: 6),
          if (text.isNotEmpty)
            GestureDetector(
              onTap: () => Clipboard.setData(ClipboardData(text: text)),
              child: Icon(Icons.copy,
                  size: 14,
                  color: dark
                      ? DesignTokens.darkTextSecondary
                      : DesignTokens.textSecondary),
            ),
        ]),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 72, maxHeight: 220),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: dark ? DesignTokens.darkBackground : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              text.isEmpty ? '—' : text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Color(0xFFD4D4D4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Small labelled text field.
class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint = '',
    this.width,
    this.keyboardType,
    this.inputFormatters,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final double? width;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final dark = DesignTokens.isDark(context);
    final field = TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
          fontSize: 13,
          color:
              dark ? DesignTokens.darkTextPrimary : DesignTokens.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
    if (width != null) return SizedBox(width: width, child: field);
    return field;
  }
}

/// Primary action button.
class _Btn extends StatelessWidget {
  const _Btn({required this.label, required this.onPressed, this.loading = false, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Icon(icon ?? Icons.play_arrow, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
      ),
    );
  }
}

/// Secondary (outlined) button.
class _OutBtn extends StatelessWidget {
  const _OutBtn({required this.label, required this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.code, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
      ),
    );
  }
}

void _showSnack(BuildContext context, String msg, {bool error = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? DesignTokens.danger : DesignTokens.success,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      duration: Duration(seconds: error ? 8 : 3),
    ));
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 – Normal (GET / SET / ACTION + ENCODE / DECODE)
// ─────────────────────────────────────────────────────────────────────────────

class _NormalTab extends StatefulWidget {
  const _NormalTab({required this.client});
  final ManualDlmsClient client;

  @override
  State<_NormalTab> createState() => _NormalTabState();
}

class _NormalTabState extends State<_NormalTab> {
  final _classCtrl = TextEditingController(text: '8');
  final _obisCtrl = TextEditingController(text: '0000010000FF');
  final _attrCtrl = TextEditingController(text: '2');
  final _inputCtrl = TextEditingController();

  bool _loading = false;
  String _output = '';
  String _outputLabel = 'Response';

  @override
  void dispose() {
    _classCtrl.dispose();
    _obisCtrl.dispose();
    _attrCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  int get _classId => int.tryParse(_classCtrl.text.trim()) ?? 0;
  String get _obis => _obisCtrl.text.trim();
  int get _attribute => int.tryParse(_attrCtrl.text.trim()) ?? 0;
  String get _inputData => _inputCtrl.text.trim();

  void _setOutput(String val, String label) =>
      setState(() { _output = val; _outputLabel = label; });

  Future<void> _doGet() async {
    setState(() { _loading = true; _output = ''; });
    try {
      final r = await widget.client.cosemGet(
          classId: _classId, obis: _obis, attribute: _attribute);
      if (!mounted) return;
      if (r.success) {
        _inputCtrl.text = r.xml.isNotEmpty ? r.xml : r.xdr;
        _setOutput(r.xml.isNotEmpty ? r.xml : r.xdr, 'GET response');
      } else {
        _setOutput('ERROR: ${r.error}', 'GET response');
        _showSnack(context, r.error, error: true);
      }
    } catch (e) {
      if (mounted) {
        _setOutput(extractGrpcMessage(e), 'GET error');
        _showSnack(context, extractGrpcMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doSet() async {
    if (_inputData.length < 2) {
      _showSnack(context, 'Input too short', error: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final r = await widget.client.cosemSet(
          classId: _classId, obis: _obis, attribute: _attribute,
          inputData: _inputData);
      if (!mounted) return;
      _setOutput(r.success ? 'SET OK' : 'ERROR: ${r.error}', 'SET response');
      _showSnack(context, r.success ? 'SET OK' : r.error, error: !r.success);
    } catch (e) {
      if (mounted) {
        _setOutput(extractGrpcMessage(e), 'SET error');
        _showSnack(context, extractGrpcMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doAction() async {
    setState(() { _loading = true; _output = ''; });
    try {
      final r = await widget.client.cosemAction(
          classId: _classId, obis: _obis, attribute: _attribute,
          inputData: _inputData);
      if (!mounted) return;
      final out = r.success
          ? (r.xml.isNotEmpty ? r.xml : (r.xdr.isNotEmpty ? r.xdr : 'ACTION OK'))
          : 'ERROR: ${r.error}';
      _setOutput(out, 'ACTION response');
      _showSnack(context, r.success ? 'ACTION OK' : r.error,
          error: !r.success);
    } catch (e) {
      if (mounted) {
        _setOutput(extractGrpcMessage(e), 'ACTION error');
        _showSnack(context, extractGrpcMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doEncode() async {
    final xml = _inputData;
    if (!xml.contains('<') && !xml.contains('>')) {
      _showSnack(context, 'Input does not look like XML', error: true);
      return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final r = await widget.client.encode(xml);
      if (!mounted) return;
      if (r.success) {
        _inputCtrl.text = r.output;
        _setOutput(r.output, 'Encoded (XDR hex)');
      } else {
        _setOutput('ERROR: ${r.error}', 'Encode error');
        _showSnack(context, r.error, error: true);
      }
    } catch (e) {
      if (mounted) {
        _setOutput(extractGrpcMessage(e), 'Encode error');
        _showSnack(context, extractGrpcMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _doDecode() async {
    final hex = _inputData;
    if (hex.contains('<') || hex.contains('>')) {
      _showSnack(context, 'Input looks like XML — already decoded', error: true);
      return;
    }
    if (hex.length < 2) {
      _showSnack(context, 'Input too short', error: true); return;
    }
    setState(() { _loading = true; _output = ''; });
    try {
      final r = await widget.client.decode(hex);
      if (!mounted) return;
      if (r.success) {
        _inputCtrl.text = r.output;
        _setOutput(r.output, 'Decoded (XML)');
      } else {
        _setOutput('ERROR: ${r.error}', 'Decode error');
        _showSnack(context, r.error, error: true);
      }
    } catch (e) {
      if (mounted) {
        _setOutput(extractGrpcMessage(e), 'Decode error');
        _showSnack(context, extractGrpcMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── COSEM descriptor row ──────────────────────────────────────────
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _Field(controller: _classCtrl, label: 'Class ID', hint: '8',
              width: 80, keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(width: 8),
          Expanded(
              child: _Field(
                  controller: _obisCtrl,
                  label: 'Logical Name (hex)',
                  hint: '0000010000FF')),
          const SizedBox(width: 8),
          _Field(
              controller: _attrCtrl,
              label: 'Attribute',
              hint: '2',
              width: 80,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        ]),
        const SizedBox(height: 12),
        // ── Command buttons ───────────────────────────────────────────────
        Wrap(spacing: 8, runSpacing: 8, children: [
          _Btn(label: 'Get', icon: Icons.download, loading: _loading,
              onPressed: _doGet),
          _Btn(label: 'Set', icon: Icons.upload, loading: _loading,
              onPressed: _doSet),
          _Btn(label: 'Action', icon: Icons.play_circle, loading: _loading,
              onPressed: _doAction),
          _OutBtn(label: 'Encode', icon: Icons.compress, onPressed: _doEncode),
          _OutBtn(label: 'Decode', icon: Icons.expand, onPressed: _doDecode),
        ]),
        const SizedBox(height: 12),
        // ── Input / output text area ──────────────────────────────────────
        Row(children: [
          Text('Input data',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.isDark(context)
                      ? DesignTokens.darkTextSecondary
                      : DesignTokens.textSecondary)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() => _inputCtrl.clear()),
            icon: const Icon(Icons.clear, size: 14),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 4),
        TextField(
          controller: _inputCtrl,
          maxLines: 8,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          decoration: InputDecoration(
            hintText:
                'XML:  <Unsigned8>42</Unsigned8>\n'
                'or XDR hex:  1142',
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusSm)),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
        const SizedBox(height: 12),
        _OutputBox(text: _output, label: _outputLabel),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 – With List
// ─────────────────────────────────────────────────────────────────────────────

/// One row in the object list (Get / Set / Action).
class _WLItem {
  _WLItem({
    required this.classId,
    required this.obis,
    required this.attribute,
    this.inputData = '',
    this.resultXdr = '',
    this.resultXml = '',
    this.errorCode = '',
  });
  int classId;
  String obis;
  int attribute;
  String inputData;
  // result fields
  String resultXdr;
  String resultXml;
  String errorCode;
}

class _WithListTab extends StatefulWidget {
  const _WithListTab({required this.client});
  final ManualDlmsClient client;

  @override
  State<_WithListTab> createState() => _WithListTabState();
}

class _WithListTabState extends State<_WithListTab> {
  final List<_WLItem> _items = [];
  // Add form controllers
  final _addClassCtrl = TextEditingController(text: '8');
  final _addObisCtrl = TextEditingController(text: '0000010000FF');
  final _addAttrCtrl = TextEditingController(text: '2');
  final _addValueCtrl = TextEditingController();

  // 0 = Get, 1 = Set, 2 = Action
  int _mode = 0;
  bool _loading = false;

  static const _modeLabels = ['Get With List', 'Set With List', 'Action With List'];
  static const _modeIcons = [Icons.download, Icons.upload, Icons.play_circle];

  @override
  void dispose() {
    _addClassCtrl.dispose();
    _addObisCtrl.dispose();
    _addAttrCtrl.dispose();
    _addValueCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    final classId = int.tryParse(_addClassCtrl.text.trim()) ?? 0;
    final obis = _addObisCtrl.text.trim();
    final attr = int.tryParse(_addAttrCtrl.text.trim()) ?? 0;
    final value = _addValueCtrl.text.trim();
    if (obis.isEmpty) {
      _showSnack(context, 'Logical Name is required', error: true);
      return;
    }
    setState(() {
      _items.add(_WLItem(
          classId: classId, obis: obis, attribute: attr, inputData: value));
    });
  }

  void _removeItem(int index) =>
      setState(() => _items.removeAt(index));

  void _clearAll() => setState(() => _items.clear());

  Future<void> _execute() async {
    if (_items.isEmpty) {
      _showSnack(context, 'Add at least one object', error: true);
      return;
    }
    setState(() { _loading = true; });
    try {
      WithListResult result;
      switch (_mode) {
        case 0: // GET
          result = await widget.client.getWithList(_items
              .map((i) => WithListGetItem(
                  classId: i.classId, obis: i.obis, attribute: i.attribute))
              .toList());
        case 1: // SET
          result = await widget.client.setWithList(_items
              .map((i) => WithListSetItem(
                  classId: i.classId,
                  obis: i.obis,
                  attribute: i.attribute,
                  inputData: i.inputData))
              .toList());
        default: // ACTION
          result = await widget.client.actionWithList(_items
              .map((i) => WithListActionItem(
                  classId: i.classId,
                  obis: i.obis,
                  attribute: i.attribute,
                  inputData: i.inputData))
              .toList());
      }
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < result.items.length && i < _items.length; i++) {
          final r = result.items[i];
          _items[i].resultXdr = r.xdr;
          _items[i].resultXml = r.xml;
          _items[i].errorCode = r.success ? 'OK' : r.error;
        }
      });
      final ok = result.globalSuccess;
      _showSnack(context,
          ok ? '${_modeLabels[_mode]} — Success' : result.error.isNotEmpty ? result.error : 'One or more errors',
          error: !ok);
    } catch (e) {
      if (mounted) _showSnack(context, extractGrpcMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = DesignTokens.isDark(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // ── Mode selector ──────────────────────────────────────────────────
      Container(
        color: dark ? DesignTokens.darkSurface : DesignTokens.gray100,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          for (int i = 0; i < 3; i++) ...[
            ChoiceChip(
              label: Text(_modeLabels[i], style: const TextStyle(fontSize: 12)),
              avatar: Icon(_modeIcons[i], size: 14),
              selected: _mode == i,
              onSelected: (_) => setState(() { _mode = i; _clearAll(); }),
            ),
            if (i < 2) const SizedBox(width: 8),
          ],
        ]),
      ),
      // ── Add form ───────────────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: DesignTokens.gray200))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _Field(controller: _addClassCtrl, label: 'Class', width: 64,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(width: 8),
          Expanded(child: _Field(controller: _addObisCtrl,
              label: 'Logical Name', hint: '0000010000FF')),
          const SizedBox(width: 8),
          _Field(controller: _addAttrCtrl, label: 'Attr', width: 56,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          if (_mode != 0) ...[
            const SizedBox(width: 8),
            Expanded(child: _Field(controller: _addValueCtrl,
                label: 'Value (XML or HEX)', hint: '<Unsigned8>1</Unsigned8>')),
          ],
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Add to list',
            icon: const Icon(Icons.add),
            onPressed: _addItem,
            style: IconButton.styleFrom(
                backgroundColor: DesignTokens.primary600,
                foregroundColor: Colors.white),
          ),
        ]),
      ),
      // ── Object list ────────────────────────────────────────────────────
      Expanded(
        child: _items.isEmpty
            ? Center(
                child: Text('No objects added yet.',
                    style: TextStyle(
                        color: dark
                            ? DesignTokens.darkTextSecondary
                            : DesignTokens.textSecondary)))
            : ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (ctx, i) {
                  final item = _items[i];
                  final hasResult = item.errorCode.isNotEmpty;
                  final isOk = item.errorCode == 'OK';
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusSm),
                      side: BorderSide(
                          color: hasResult
                              ? (isOk
                                  ? DesignTokens.success
                                  : DesignTokens.danger)
                              : DesignTokens.gray200)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(children: [
                        // Index badge
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                              color: DesignTokens.primary100,
                              borderRadius: BorderRadius.circular(4)),
                          alignment: Alignment.center,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: DesignTokens.primary600)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'C${item.classId}  ${item.obis}  Attr ${item.attribute}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                if (item.inputData.isNotEmpty)
                                  Text(item.inputData,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace')),
                                if (hasResult) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                      isOk
                                          ? (item.resultXml.isNotEmpty
                                              ? item.resultXml
                                              : item.resultXdr)
                                          : item.errorCode,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'monospace',
                                          color: isOk
                                              ? DesignTokens.success
                                              : DesignTokens.danger)),
                                ],
                              ]),
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete_outline, size: 18),
                          tooltip: 'Remove',
                          color: DesignTokens.danger,
                          onPressed: () => _removeItem(i),
                        ),
                      ]),
                    ),
                  );
                },
              ),
      ),
      // ── Bottom action bar ──────────────────────────────────────────────
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: dark ? DesignTokens.darkSurface : DesignTokens.gray50,
          border: Border(top: BorderSide(color: DesignTokens.gray200)),
        ),
        child: Row(children: [
          Text('${_items.length} object(s)',
              style: TextStyle(
                  fontSize: 12,
                  color: dark
                      ? DesignTokens.darkTextSecondary
                      : DesignTokens.textSecondary)),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _items.isEmpty ? null : _clearAll,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 10),
          _Btn(
            label: _modeLabels[_mode],
            icon: _modeIcons[_mode],
            loading: _loading,
            onPressed: _execute,
          ),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 – Raw Frame
// ─────────────────────────────────────────────────────────────────────────────

class _RawFrameTab extends StatefulWidget {
  const _RawFrameTab({required this.client});
  final ManualDlmsClient client;

  @override
  State<_RawFrameTab> createState() => _RawFrameTabState();
}

class _RawFrameTabState extends State<_RawFrameTab> {
  final _frameCtrl = TextEditingController();
  String _response = '';
  bool _loading = false;
  bool? _lastSuccess;

  static const _knownTags = {'C0', 'C1', 'C3'};

  @override
  void dispose() {
    _frameCtrl.dispose();
    super.dispose();
  }

  String? _validateTag(String hex) {
    final tag = hex.length >= 2 ? hex.substring(0, 2).toUpperCase() : '';
    if (tag.isNotEmpty && !_knownTags.contains(tag)) {
      return 'Warning: tag 0x$tag is not a standard DLMS response tag '
          '(expected C0, C1 or C3). Frame will be sent anyway.';
    }
    return null;
  }

  Future<void> _send() async {
    final frame = _frameCtrl.text.trim().replaceAll(' ', '');
    if (frame.length < 2) {
      _showSnack(context, 'Frame too short', error: true);
      return;
    }
    final warn = _validateTag(frame);
    if (warn != null && mounted) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Unknown frame tag'),
          content: Text(warn),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Send anyway')),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    setState(() { _loading = true; _response = ''; _lastSuccess = null; });
    try {
      final r = await widget.client.sendRawFrame(frame);
      if (!mounted) return;
      setState(() {
        _response = r.xdr.isNotEmpty ? r.xdr : 'D80101';
        _lastSuccess = r.success;
      });
    } catch (e) {
      if (mounted) {
        setState(() { _response = extractGrpcMessage(e); _lastSuccess = false; });
        _showSnack(context, extractGrpcMessage(e), error: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = DesignTokens.isDark(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Description ────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: dark ? DesignTokens.darkFill : DesignTokens.infoLight,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          ),
          child: Row(children: [
            Icon(Icons.info_outline,
                size: 16,
                color: dark ? DesignTokens.darkFocus : DesignTokens.info),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Enter a raw DLMS APDU as a hex string.  '
                'Valid start bytes: C0 (GET-resp), C1 (SET-resp), C3 (ACTION-resp).',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        // ── Input ──────────────────────────────────────────────────────
        Row(children: [
          Text('Frame to send (hex)',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: dark
                      ? DesignTokens.darkTextSecondary
                      : DesignTokens.textSecondary)),
          const Spacer(),
          TextButton.icon(
            onPressed: () => setState(() { _frameCtrl.clear(); _response = ''; }),
            icon: const Icon(Icons.clear, size: 14),
            label: const Text('Clear', style: TextStyle(fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 4),
        TextField(
          controller: _frameCtrl,
          maxLines: 6,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: InputDecoration(
            hintText: 'C0 01 C1 00 14 00 00 0D 00 02 FF 0A 00',
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusSm)),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
        const SizedBox(height: 12),
        // ── Send button ────────────────────────────────────────────────
        _Btn(
            label: 'Send Frame',
            icon: Icons.send,
            loading: _loading,
            onPressed: _send),
        const SizedBox(height: 16),
        // ── Response ───────────────────────────────────────────────────
        if (_response.isNotEmpty) ...[
          Row(children: [
            Icon(
              _lastSuccess == true
                  ? Icons.check_circle
                  : Icons.error_outline,
              size: 16,
              color: _lastSuccess == true
                  ? DesignTokens.success
                  : DesignTokens.danger,
            ),
            const SizedBox(width: 6),
            Text(
              _lastSuccess == true ? 'Response received' : 'Error',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _lastSuccess == true
                      ? DesignTokens.success
                      : DesignTokens.danger),
            ),
          ]),
          const SizedBox(height: 6),
          _OutputBox(text: _response, label: 'Response (hex)'),
        ],
      ]),
    );
  }
}
