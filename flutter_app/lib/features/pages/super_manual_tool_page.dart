import 'dart:convert';
import 'package:flutter/material.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../core/widgets/attribute_edit_dialog.dart';
import '../../core/widgets/selective_access_tab.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/generated/meter.pbgrpc.dart';
import '../super_manual/super_manual_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../util/bytes_util.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/widget_keys.dart';

/// Super Manuel Tool (portage de super-manuel-tool.html)
/// Fonctionnalités:
/// - Onglets: Send DLMS Commands / Selective Access / Simulation (placeholder)
/// - Liste dictionnaires (objets DLMS) avec filtre
/// - Sélection d'objet => attributs (logical_name, value, scaler_unit)
/// - Get / Set / Action simulés + encode/decode xdr xml
/// - Sélective Access (Class 7) : objets profil + capture info + opérateur sélectif (mock)
class SuperManualToolPage extends ConsumerStatefulWidget {
  const SuperManualToolPage({super.key});
  @override
  ConsumerState<SuperManualToolPage> createState() =>
      _SuperManualToolPageState();
}

enum _InputKind { integer, string, boolean, date, time, datetime, unknown }

class _SuperManualToolPageState extends ConsumerState<SuperManualToolPage>
    with SingleTickerProviderStateMixin {
  final tabs = ['send', 'selective', 'simu'];
  String activeTab = 'send';
  late IMeterClient client;
  String? _dlmsClient = null;
  bool _isConnected = false;
  bool _isLoading = false;
  final _dtFormat = DateFormat('yyyy-MM-dd HH:mm');
  String _opExpression = '';
  List<TerminalLine> _outputInfo = [];
  // ----- Modèle général (Send DLMS Commands) -----
  bool _isLoadingGeneral = false;
  List<DatamodelObject> generalObjects = [];
  String filterGeneral = '';
  DatamodelObject? currentGeneral;
  List<DatamodelAttribute> selectedObjectAttributes = [];
  bool decimalFormat = false;
  final Map<String, AttrState> attrStates = {}; // key -> state
  final List<String> selectedAttrs = [];

  // Terminal (Send)
  final List<TermEntry> terminalSend = [];
  final ScrollController termSendCtrl = ScrollController();
  String encodedBox = '';

  // ----- Sélective Access (Class 7) -----
  List<DatamodelObject> selectiveObjects = [];
  String filterSelective = '';
  DatamodelObject? currentSelective;
  final List<TermEntry> terminalSelective = [];
  final ScrollController termSelCtrl = ScrollController();
  String? opType = null;
  String opExpression = '';
  String selOutput = '';
  String selInputParams = '';
  String selectiveEncodedBox = '';

  // For range descriptor
  DateTime? startDate;
  DateTime? endDate;

  // For entry descriptor
  int? entryStart;
  int? entryEnd;
  int? selectedStart;
  int? selectedEnd;

  int _recordMax = 0;
  int _recordNum = 0;
  int _capturePeriod = 0;

  @override
  void dispose() {
    termSendCtrl.dispose();
    termSelCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    client = meterClientFactory();
    _dlmsClient = ref.read(appControllerProvider).moduleName;
    if (!ref.read(appControllerProvider).isConnected) {
      super.initState();
      return;
    }
    setState(() => _isLoadingGeneral = true);
    client.getDatamodelObjects().then((objects) {
      setState(() {
        _isLoadingGeneral = false;
        generalObjects = objects;
        selectiveObjects = objects.where((o) => o.classId == 7).toList();
      });
    }).catchError((error, stackTrace) {
      setState(() => _isLoadingGeneral = false);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(extractGrpcMessage(error)),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 8),
            ),
          );
      }
    });
    super.initState();
  }

  // ---------------- Terminal helpers ----------------
  // coverage:ignore-start
  void _addTerm(
      List<TermEntry> list, ScrollController ctrl, String tag, String msg,
      {String kind = ''}) {
    setState(() {
      list.add(TermEntry(tag, msg, kind));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ctrl.hasClients) ctrl.jumpTo(ctrl.position.maxScrollExtent);
    });
  }
  // coverage:ignore-end

  // ---------------- General object selection ----------------
  void _selectGeneral(DatamodelObject obj) async {
    final attributes = await client.getDatamodelAttributesByObjectName(
        obj.name, _dlmsClient ?? '');
    setState(() {
      currentGeneral = obj;
      selectedObjectAttributes = attributes;
      attrStates.clear();
      selectedAttrs.clear();
      for (int i = 0; i < attributes.length; i++) {
        final a = attributes[i];
        attrStates[a.id.toString()] =
            AttrState(original: "", current: "", index: i + 1);
      }
    });
  }

  void _toggleAttr(String key, bool sel) {
    setState(() {
      if (sel) {
        if (!selectedAttrs.contains(key)) selectedAttrs.add(key);
      } else {
        selectedAttrs.remove(key);
      }
    });
  }

  // coverage:ignore-start
  void _onAttrChanged(String key, String val) {
    final st = attrStates[key];
    if (st == null) return;
    setState(() => st.current = val);
  }
  // coverage:ignore-end

  // Status pills (Send tab) – kept for future use but not currently called
  // coverage:ignore-start
  final List<_Pill> pills = [];
  void _addPill(String kind, String text) {
    setState(() {
      pills.insert(0, _Pill(kind, text));
      if (pills.length > 6) pills.removeLast();
    });
  }
  // coverage:ignore-end

  // Show message at bottom using SnackBar
  void _showMessage(String message, bool isSuccess) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor:
              isSuccess ? DesignTokens.success : DesignTokens.danger,
          duration: Duration(seconds: isSuccess ? 3 : 8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
  }

  String _extractErrorMessage(Object e) {
    // coverage:ignore-start
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      return e.toString();
    }
    // coverage:ignore-end
    final raw = e.toString();
    return raw.replaceFirst('Exception: ', '');
  }

  // ---------------- Operations (Send) ----------------
  bool _requireGeneral() {
    if (currentGeneral == null) {
      return false;
    }
    return true;
  }

  void _doGet() async {
    if (!_requireGeneral()) return;
    if (selectedAttrs.isEmpty) {
      _showMessage('Please select at least one attribute', false);
      return;
    }
    setState(() {
      _isLoading = true;
      encodedBox = ''; // clear previous results before new read
    });

    final requests = selectedObjectAttributes
        .where((attr) => selectedAttrs.contains(attr.id.toString()))
        .map((attr) {
      return GetRequest()
        ..class_1 = currentGeneral!.classId
        ..obiscode = currentGeneral!.logicalNameHex
        ..attribute = attr.id;
    }).toList();

    try {
      final responses = await client.executeGet(requests, true);
      final List<String> newEncodedBox = [];
      bool hasError = false;
      for (final response in responses) {
        newEncodedBox.add(response.xmlXdr);
        if (!response.success) {
          hasError = true;
          final errorMsg =
              response.error.isNotEmpty ? response.error : 'Unknown error';
          _showMessage(errorMsg, false);
        }
      }
      setState(() {
        encodedBox =
            newEncodedBox.join('\n-------------------------------------------');
        _isLoading = false;
      });
      if (!hasError) {}
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage(_extractErrorMessage(e), false);
    }
  }

  // ---------- Helpers pour Set/Action : type, XML et XDR ----------
  // coverage:ignore-start
  _InputKind _detectKind(String type) {
    final t = type.toLowerCase();
    if (t.contains('datetime')) return _InputKind.datetime;
    if (t.contains('date') && !t.contains('time')) return _InputKind.date;
    if (t.contains('time') && !t.contains('date')) return _InputKind.time;
    if (t.contains('bool')) return _InputKind.boolean;
    if (t.contains('string')) return _InputKind.string;
    if (t.contains('int') || t.contains('long') || t.contains('unsigned')) {
      return _InputKind.integer;
    }
    return _InputKind.unknown;
  }

  String _xmlEscape(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _toHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  /// Construit l'XML pour une valeur "plain" d'un type connu.
  /// Pour STRING: hex UTF-8 + size = longueur chaine hex ; sinon: plain échappé.
  String _buildXmlForAttrValue(DatamodelAttribute attr, String plain) {
    final typeTag = attr.type.toLowerCase().replaceAll('_', '-');
    final kind = _detectKind(attr.type);

    if (kind == _InputKind.string) {
      final hex = _toHex(utf8.encode(plain));
      final size = hex
          .length; // si tu veux le nombre d'octets: utf8.encode(plain).length
      return '<$typeTag size="$size">$hex</$typeTag>';
    }

    final escaped = _xmlEscape(plain);
    return '<$typeTag>$escaped</$typeTag>';
  }

  /// Résout le payload XDR hex à partir de la valeur stockée (plain, xml ou hex).
  Future<String> _resolvePayloadHex(
      DatamodelAttribute attr, String value) async {
    final v = value.trim();
    if (v.isEmpty) return '';
    // coverage:ignore-end

    // coverage:ignore-start
    // Determine if input is XML or plain value
    String xml;
    if (v.startsWith('<')) {
      // Already XML, use it directly
      xml = v;
    } else {
      // Plain value, build XML
      xml = _buildXmlForAttrValue(attr, v);
    }
    print("xml $xml");
    final req = TranslateDataItemRequest()
      ..data = xml
      ..isXdrInput = false; // XML -> XDR
    final responses = await client.translateData([req]);

    if (responses.isNotEmpty && responses[0].success) {
      return responses[0].output;
    }
    throw Exception('translateData failed for XML: $xml');
  }
  // coverage:ignore-end

  void _doSet() async {
    if (!_requireGeneral()) return;
    if (selectedAttrs.isEmpty) {
      _showMessage('Please select at least one attribute', false);
      return;
    }
    setState(() {
      _isLoading = true;
      encodedBox = ''; // clear previous results before new set
    });

    final changed =
        attrStates.values.where((s) => s.current != s.original).toList();
    if (changed.isEmpty) {
      setState(() => _isLoading = false);
      _showMessage('No changes detected', false);
      return;
    }

    // coverage:ignore-start
    try {
      final attrsToSet = selectedObjectAttributes
          .where((attr) => selectedAttrs.contains(attr.id.toString()))
          .toList();

      // Check if any selected attribute has data filled
      bool hasData = false;
      for (final attr in attrsToSet) {
        final st = attrStates[attr.id.toString()];
        final raw = st?.current.trim() ?? '';
        if (raw.isNotEmpty) {
          hasData = true;
          break;
        }
      }

      if (!hasData) {
        setState(() => _isLoading = false);
        _showMessage('Please fill at least one selected attribute', false);
        return;
      }

      final List<SetRequest> requests = [];
      for (final attr in attrsToSet) {
        final st = attrStates[attr.id.toString()];
        final raw = st?.current.trim() ?? '';
        if (raw.isEmpty) continue;
        print(raw);
        final xdrHex = await _resolvePayloadHex(attr, raw);
        print(xdrHex);

        requests.add(
          SetRequest()
            ..class_1 = currentGeneral!.classId
            ..obiscode = currentGeneral!.logicalNameHex
            ..attribute = attr.id
            ..payload = xdrHex,
        );
      }
      print('Executing Set for ${requests}');
      final responses = await client.executeSet(requests, true);
      bool hasError = false;
      for (final response in responses) {
        if (!response.success) {
          hasError = true;
          final errorMsg =
              response.error.isNotEmpty ? response.error : 'Unknown error';
          _showMessage(errorMsg, false);
        }
      }
      if (!hasError) {
        for (final c in changed) {
          c.original = c.current;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage(_extractErrorMessage(e), false);
    }
    // coverage:ignore-end
  }

  void _doAction() async {
    if (!_requireGeneral()) return;
    if (selectedAttrs.isEmpty) {
      _showMessage('Please select at least one attribute', false);
      return;
    }
    setState(() {
      _isLoading = true;
      encodedBox = ''; // clear previous results before new action
    });

    // coverage:ignore-start
    try {
      final attrsToAct = selectedObjectAttributes
          .where((attr) => selectedAttrs.contains(attr.id.toString()))
          .toList();

      final List<ActionRequest> requests = [];
      for (final attr in attrsToAct) {
        final st = attrStates[attr.id.toString()];
        final raw = st?.current.trim() ?? '';
        if (raw.isEmpty) continue;

        final xdrHex = await _resolvePayloadHex(attr, raw);

        requests.add(
          ActionRequest()
            ..class_1 = currentGeneral!.classId
            ..obiscode = currentGeneral!.logicalNameHex
            ..attribute = attr.id
            ..payload = xdrHex,
        );
      }

      final responses = await client.executeAction(requests, true);

      bool hasError = false;
      for (final response in responses) {
        if (!response.success) {
          hasError = true;
          final errorMsg =
              response.error.isNotEmpty ? response.error : 'Unknown error';

          _showMessage(errorMsg, false);
        }
      }

      if (!hasError) {
        final changed =
            attrStates.values.where((s) => s.current != s.original).toList();
        for (final c in changed) {
          c.original = c.current;
        }
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage(_extractErrorMessage(e), false);
    }
    // coverage:ignore-end
  }

  // coverage:ignore-start
  void _encodeAttrs() async {
    Map<String, String> toEncode = {};
    for (final selectedAttr in selectedAttrs) {
      final attrState = attrStates[selectedAttr];
      if (attrState!.current != "" && !isHex(attrState!.current)) {
        toEncode[selectedAttr] = attrState!.current;
      }
    }
    if (toEncode.isEmpty) {
      return;
    }
    final List<TranslateDataItemRequest> requests = [];
    for (final key in toEncode.keys) {
      requests.add(TranslateDataItemRequest()
        ..data = toEncode[key]!
        ..isXdrInput = false);
    }
    try {
      final responses = await client.translateData(requests);
      setState(() {
        for (int index = 0; index < responses.length; index++) {
          if (responses[index].success) {
            attrStates[toEncode.keys.toList()[index]!]!.current =
                responses[index].output;
          }
        }
      });
    } catch (_) {
      _showMessage('Encoding failed', false);
    }
  }

  void _decodeAttrs() async {
    Map<String, String> toEncode = {};
    for (final selectedAttr in selectedAttrs) {
      final attrState = attrStates[selectedAttr];
      if (attrState!.current != "" && isHex(attrState!.current)) {
        toEncode[selectedAttr] = attrState!.current;
      }
    }
    if (toEncode.isEmpty) {
      return;
    }
    final List<TranslateDataItemRequest> requests = [];
    for (final key in toEncode.keys) {
      requests.add(TranslateDataItemRequest()
        ..data = toEncode[key]!
        ..isXdrInput = true);
    }
    try {
      final responses = await client.translateData(requests);
      setState(() {
        for (int index = 0; index < responses.length; index++) {
          if (responses[index].success) {
            attrStates[toEncode.keys.toList()[index]!]!.current =
                responses[index].output;
          }
        }
      });
    } catch (_) {
      _showMessage('Decoding failed', false);
    }
  }
  // coverage:ignore-end

  void _encode() async {
    if (encodedBox.trim().isEmpty) {
      return;
    }
    if (isHex(encodedBox.trim())) {
      return;
    }
    // coverage:ignore-start
    const separator = '-------------------------------------------';
    final List<TranslateDataItemRequest> requests = [];
    final parts = encodedBox.split(separator);
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].trim().isNotEmpty) {
        requests.add(TranslateDataItemRequest()
          ..data = parts[i]
          ..isXdrInput = false);
      }
    }
    try {
      final responses = await client.translateData(requests);
      final List<String> newEncodedBox = [];
      for (final response in responses) {
        newEncodedBox.add(response.output);
      }
      setState(() => encodedBox = newEncodedBox.join("\n" + separator));
    } catch (_) {
      _showMessage('Encoding failed', false);
    }
    // coverage:ignore-end
  }

  void _decode() async {
    if (encodedBox.trim().isEmpty) {
      return;
    }
    if (!isHex(encodedBox.trim())) {
      return;
    }
    // coverage:ignore-start
    const separator = '-------------------------------------------';
    final List<TranslateDataItemRequest> requests = [];
    final parts = encodedBox.split(separator);
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].trim().isNotEmpty) {
        requests.add(TranslateDataItemRequest()
          ..data = parts[i]
          ..isXdrInput = true);
      }
    }
    try {
      final responses = await client.translateData(requests);
      List<String> newEncodedBox = [];
      for (final response in responses) {
        newEncodedBox.add(response.output);
      }
      setState(() => encodedBox = newEncodedBox.join("\n" + separator));
    } catch (_) {
      _showMessage('Decoding failed', false);
    }
    // coverage:ignore-end
  }

  void _clearEncoding() {
    setState(() => encodedBox = '');
  }

  void _encodeSelective() async {
    if (selectiveEncodedBox.trim().isEmpty) {
      return;
    }
    if (isHex(selectiveEncodedBox.trim())) {
      return;
    }
    // coverage:ignore-start
    const separator = '-------------------------------------------';
    final List<TranslateDataItemRequest> requests = [];
    final parts = selectiveEncodedBox.split(separator);
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].trim().isNotEmpty) {
        requests.add(TranslateDataItemRequest()
          ..data = parts[i]
          ..isXdrInput = false);
      }
    }
    try {
      final responses = await client.translateData(requests);
      final List<String> newEncodedBox = [];
      for (final response in responses) {
        newEncodedBox.add(response.output);
      }
      setState(
          () => selectiveEncodedBox = newEncodedBox.join("\n" + separator));
    } catch (_) {
      _showMessage('Encoding failed', false);
    }
    // coverage:ignore-end
  }

  void _decodeSelective() async {
    if (selectiveEncodedBox.trim().isEmpty) {
      return;
    }
    if (!isHex(selectiveEncodedBox.trim())) {
      return;
    }
    // coverage:ignore-start
    const separator = '-------------------------------------------';
    final List<TranslateDataItemRequest> requests = [];
    final parts = selectiveEncodedBox.split(separator);
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].trim().isNotEmpty) {
        requests.add(TranslateDataItemRequest()
          ..data = parts[i]
          ..isXdrInput = true);
      }
    }
    try {
      final responses = await client.translateData(requests);
      List<String> newEncodedBox = [];
      for (final response in responses) {
        newEncodedBox.add(response.output);
      }
      setState(
          () => selectiveEncodedBox = newEncodedBox.join("\n" + separator));
    } catch (_) {
      _showMessage('Decoding failed', false);
    }
    // coverage:ignore-end
  }

  void _clearSelectiveEncoding() {
    setState(() => selectiveEncodedBox = '');
  }

  // ---------------- Selective Access ops ----------------
  void _selectSelective(DatamodelObject obj) {
    setState(() {
      currentSelective = obj;
    });
  }

  void _selReadBasic() async {
    if (currentSelective == null) {
      _showMessage('Please select an object', false);
      return;
    }
    setState(() {
      _isLoading = true;
      selectiveEncodedBox = '';
    });
    try {
      final req = GetRequest()
        ..class_1 = currentSelective!.classId
        ..obiscode = currentSelective!.logicalNameHex
        ..attribute = 2;

      final responses = await client.executeGet([req], false);
      if (responses.isNotEmpty) {
        if (!responses[0].success) {
          final errorMsg = responses[0].error.isNotEmpty
              ? responses[0].error
              : 'Unknown error';
          _showMessage(errorMsg, false);
        } else {
          setState(() {
            _outputInfo = [
              TerminalLine(
                timestamp: DateTime.now().toIso8601String(),
                tag: 'INFO',
                message: responses[0].xmlXdr,
                kind: 'system',
              )
            ];
            selectiveEncodedBox = responses[0].xmlXdr;
          });
        }
      }
    } catch (e) {
      _showMessage(_extractErrorMessage(e), false);
    }
    setState(() => _isLoading = false);
  }

  // coverage:ignore-start
  void _opConfig() {
    if (currentSelective == null) {
      return;
    }
  }

  void _opDecode() {
    if (opExpression.trim().isEmpty) {
      return;
    }
    try {
      jsonDecode(opExpression);
    } catch (_) {}
  }

  void _opEncode() {
    if (currentSelective == null) {
      return;
    }
  }
  // coverage:ignore-end

  void _opRead() async {
    if (currentSelective == null) {
      _showMessage('Please select an object', false);
      return;
    }
    setState(() {
      _isLoading = true;
      selectiveEncodedBox = '';
    });
    //selective read
    GetRequest req;
    if (this.opType == 'range descriptor') {
      if (startDate == null || endDate == null) {
        setState(() => _isLoading = false);
        _showMessage('Please select start and end dates', false);
        return;
      }
      // coverage:ignore-start
      req = GetRequest()
        ..class_1 = currentSelective!.classId
        ..obiscode = currentSelective!.logicalNameHex
        ..attribute = 2
        ..datetimeSelector = (DateTimeRangeSelector()
          ..start = toTimestamp(startDate!)
          ..end = toTimestamp(endDate!));
      // coverage:ignore-end
    } else if (this.opType == 'entry descriptor') {
      req = GetRequest()
        ..class_1 = currentSelective!.classId
        ..obiscode = currentSelective!.logicalNameHex
        ..attribute = 2
        ..entrySelector = (EntrySelector()
          ..entryFrom = entryStart ?? 0
          ..entryTo = entryEnd ?? 1
          ..selectedFrom = selectedStart ?? 0
          ..selectedTo = selectedEnd ?? 1);
    } else {
      req = GetRequest()
        ..class_1 = currentSelective!.classId
        ..obiscode = currentSelective!.logicalNameHex
        ..attribute = 2;
    }
    try {
      final responses = await client.executeGet([req], false);
      if (responses.isNotEmpty) {
        if (!responses[0].success) {
          final errorMsg = responses[0].error.isNotEmpty
              ? responses[0].error
              : 'Unknown error';
          _showMessage(errorMsg, false);
        } else {
          setState(() {
            _outputInfo = [
              TerminalLine(
                timestamp: DateTime.now().toIso8601String(),
                tag: 'INFO',
                message: responses[0].xmlXdr,
                kind: 'system',
              )
            ];
            selectiveEncodedBox = responses[0].xmlXdr;
          });
        }
      }
    } catch (e) {
      _showMessage(_extractErrorMessage(e), false);
    }
    setState(() => _isLoading = false);
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    _isConnected = ref.watch(appControllerProvider).isConnected;
    return Stack(children: [
      Scaffold(
        backgroundColor: DesignTokens.backgroundOf(context),
        appBar: AppBar(
          title: const Text("Super Manual Tool"),
          backgroundColor: DesignTokens.primary600,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            RefreshAppBarButton(
              onPressed: () {
                setState(() => _isLoadingGeneral = true);
                client.getDatamodelObjects().then((objects) {
                  setState(() {
                    _isLoadingGeneral = false;
                    generalObjects = objects;
                    selectiveObjects =
                        objects.where((o) => o.classId == 7).toList();
                  });
                }).catchError((error, stackTrace) {
                  setState(() => _isLoadingGeneral = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(extractGrpcMessage(error)),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 8),
                        ),
                      );
                  }
                });
              },
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(children: [
          _tabsBar(),
          Expanded(
              child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildActiveTab(),
          )),
        ]),
      ),
      if (_isLoading)
        Positioned.fill(
            child: AbsorbPointer(
          absorbing: true, // block touches below
          child: Container(
            color: Colors.black.withOpacity(0.3), // semi-transparent background
            child: Center(
              //child: CircularProgressIndicator(),
              // Or your Lottie here:
              child: Lottie.asset('assets/animations/data.json',
                  width: 200,
                  height: 200,
                  errorBuilder: (context, err, stack) => // coverage:ignore-line
                      const Text('Failed to load animation',
                          style: TextStyle(
                              color: Colors.white)) // coverage:ignore-line
                  ),
            ),
          ),
        ))
    ]);
  }

  Widget _tabsBar() {
    Widget tab(String key, String label) {
      final active = key == activeTab;
      return InkWell(
        key: Key(SuperManualToolKeys.tabBtn(key)),
        onTap: () => setState(() => activeTab = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      width: 3,
                      color: active
                          ? DesignTokens.primary600
                          : Colors.transparent)),
              color: active
                  ? DesignTokens.surfaceAltOf(context)
                  : DesignTokens.surfaceOf(context)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active
                      ? DesignTokens.primary600
                      : DesignTokens.textSecondaryOf(context))),
        ),
      );
    }

    return Container(
      color: DesignTokens.surfaceOf(context),
      child: Row(children: [
        tab('send', 'Send DLMS Commands'),
        tab('selective', 'Selective Access')
      ]),
    );
  }

  Widget _buildActiveTab() {
    switch (activeTab) {
      case 'send':
        return _tabSend();
      case 'selective':
        // Use the same panel/layout style as the Send DLMS Commands tab
        // by reusing the dedicated selective tab builder.
        return _tabSelective();
      default:
        return const SizedBox();
    }
  }

  // ---- SEND TAB ----
  Widget _tabSend() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth > 1250; // 3 colonnes sinon 2/1
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              width: 300,
              child: _panelWithListView(
                _panelHeader('Dictionaries'),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                    key: const Key(SuperManualToolKeys.dictFilterField),
                        decoration:
                            DesignTokens.inputDecoration(hint: 'Filter'),
                        onChanged: (v) {
                          setState(() => filterGeneral = v);
                        }),
                    const SizedBox(height: 10),
                    Expanded(child: _dictionaryList()),
                  ],
                ),
              )),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _panelNoExpand(_panelHeader('Description'), [
                  _descriptionSectionContent(),
                ]),
                const SizedBox(height: 20),
                Expanded(
                  child: _panel(_panelHeader('Attributes & Actions'), [
                    const SizedBox(height: 8),
                    _attributesGrid(),
                    const SizedBox(height: 12),
                    Wrap(spacing: 10, runSpacing: 10, children: [
                      _btn('Get', Icons.visibility, _doGet,
                          key: const Key(SuperManualToolKeys.getBtn),
                          color: const Color(0xFFFF9800),
                          enabled: _isConnected &&
                              userRights.hasRightForFeature(
                                  'Get', FeatureKeys.superManual)),
                      _btn('Set', Icons.edit, _doSet,
                          key: const Key(SuperManualToolKeys.setBtn),
                          color: const Color(0xFF1976D2),
                          enabled: _isConnected &&
                              userRights.hasRightForFeature(
                                  'Set', FeatureKeys.superManual)),
                      _btn('Action', Icons.play_arrow, _doAction,
                          key: const Key(SuperManualToolKeys.actionBtn),
                          color: DesignTokens.success,
                          enabled: _isConnected &&
                              userRights.hasRightForFeature(
                                  'Action', FeatureKeys.superManual)),
                    ]),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          if (wide)
            SizedBox(
                width: 380,
                child: _panelWithExpandedField(
                  _panelHeader('Results'),
                  'Encoding (xdr xml)',
                  encodedBox,
                  (v) => encodedBox = v,
                  [
                    _btn('Encode', Icons.code, _encode,
                        key: const Key(SuperManualToolKeys.encodeBtn),
                        color: DesignTokens.gray100,
                        fg: DesignTokens.primary600),
                    _btn('Decode', Icons.code_off, _decode,
                        key: const Key(SuperManualToolKeys.decodeBtn),
                        color: DesignTokens.warning),
                    _btn('Clear', Icons.backspace, _clearEncoding,
                        key: const Key(SuperManualToolKeys.clearEncodingBtn),
                        color: DesignTokens.danger),
                  ],
                ))
          else
            SizedBox(
                width: 320,
                child: _panelWithExpandedField(
                  _panelHeader('Results'),
                  'Encoding (xdr xml)',
                  encodedBox,
                  (v) => encodedBox = v, // coverage:ignore-line
                  [
                    _btn('Encode', Icons.code, _encode,
                        key: const Key(SuperManualToolKeys.encodeBtn),
                        color: DesignTokens.gray100,
                        fg: DesignTokens.primary600),
                    _btn('Decode', Icons.code_off, _decode,
                        key: const Key(SuperManualToolKeys.decodeBtn),
                        color: DesignTokens.warning),
                    _btn('Clear', Icons.backspace, _clearEncoding,
                        key: const Key(SuperManualToolKeys.clearEncodingBtn),
                        color: DesignTokens.danger),
                  ],
                  terminalWidget: SizedBox(
                      height: 180,
                      child: _terminalView(
                          terminalSend, termSendCtrl)), // coverage:ignore-line
                )),
        ]);
      }),
    );
  }

  Widget _dictionaryList() {
    // 1️⃣ While loading → show loader
    if (_isLoadingGeneral) {
      return ClipRRect(
        borderRadius: DesignTokens.brMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.borderOf(context)),
            color: DesignTokens.surfaceOf(context),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    // 2️⃣ When not loading → filter data (memoize filter)
    final filterLower = filterGeneral.toLowerCase();
    final data = filterGeneral.isEmpty
        ? generalObjects
        : generalObjects.where((o) {
            final nameLower = o.name.toLowerCase();
            return nameLower.contains(filterLower) ||
                o.logicalName.contains(filterGeneral);
          }).toList();

    // Avoid negative itemCount when there are no results
    if (data.isEmpty) {
      return ClipRRect(
        borderRadius: DesignTokens.brMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.borderOf(context)),
            color: DesignTokens.surfaceOf(context),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Center(
            child: Text(
              'No results',
              style: TextStyle(
                  fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: DesignTokens.brMd,
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.borderOf(context)),
            color: DesignTokens.surfaceOf(context)),
        child: ListView.builder(
          // items + separators, guarded to stay >= 0
          itemCount: data.isEmpty ? 0 : data.length * 2 - 1,
          cacheExtent: 100, // Very small cache for fast scrolling
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: true,
          itemBuilder: (context, index) {
            if (index.isOdd) {
              // Separator
              return Divider(height: 1, color: DesignTokens.borderOf(context));
            }
            final i = index ~/ 2;
            final o = data[i];
            final active = o == currentGeneral;
            return DictionaryListItem(
              key: ValueKey('${o.name}_${o.logicalName}'),
              object: o,
              active: active,
              onTap: () => _selectGeneral(o),
            );
          },
        ),
      ),
    );
  }

  Widget _attributesGrid() {
    if (currentGeneral == null) {
      return Text('Select an object.',
          style: TextStyle(
              fontSize: 12, color: DesignTokens.textSecondaryOf(context)));
    }
    final attrs = selectedObjectAttributes;
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final col = width < 420
          ? 1
          : width < 720
              ? 2
              : 3;
      final itemW = (width - (col - 1) * 16) / col;
      return Wrap(spacing: 16, runSpacing: 16, children: [
        for (int i = 0; i < attrs.length; i++) _attrCard(attrs[i], itemW)
      ]);
    });
  }

  Widget _attrCard(DatamodelAttribute attr, double w) {
    final st = attrStates[attr.id.toString()];
    final selected = selectedAttrs.contains(attr.id.toString());
    final changed = st != null && st.current != st.original;
    return Container(
      width: w,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(
          color:
              changed ? DesignTokens.warning : DesignTokens.borderOf(context),
          width: 1,
        ),
        borderRadius: DesignTokens.brMd,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Checkbox(
              key: Key(SuperManualToolKeys.attrCheckbox(attr.id)),
              value: selected,
              onChanged: (v) => _toggleAttr(attr.id.toString(), v ?? false),
            ),
            Expanded(
              child: Text("${attr.name}: ${attr.description}",
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          // Remplace le TextField par un bouton
          ElevatedButton(
            key: Key(SuperManualToolKeys.attrSetValueBtn(attr.id)),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignTokens.primary600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.brMd),
            ),
            onPressed: _isConnected
                ? () {
                    _openValueModal(attr, st?.current ?? "");
                  }
                : null,
            child: Text(
              st?.current?.isNotEmpty == true ? st!.current : 'Set value',
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Méthode pour ouvrir le modal
  // coverage:ignore-start
  Future<void> _openValueModal(
      DatamodelAttribute attr, String currentValue) async {
    final result = await AttributeEditDialog.show(
      context,
      attr,
      initialValue: currentValue,
      showEncodingPanel: true, // laisse visible pour unknown
      onEncode: (plain, a) async {
        final List<TranslateDataItemRequest> requests = [];
        requests.add(TranslateDataItemRequest()
          ..data = plain
          ..isXdrInput = false);
        try {
          final responses = await client.translateData(requests);
          return responses[0].output;
        } catch (e) {
          print(e);
          return Future.value("");
        }
      },
      onDecode: (encoded, a) async {
        final List<TranslateDataItemRequest> requests = [];
        requests.add(TranslateDataItemRequest()
          ..data = encoded
          ..isXdrInput = true);
        try {
          final responses = await client.translateData(requests);
          return responses[0].output;
        } catch (e) {
          print(e);
          return Future.value("");
        }
      },
      booleanAsYesNo: false, // "yes"/"no" pour l’UI, sinon "true"/"false"
    );

    if (result != null) {
      // Known type => valeur plain; Unknown => XML (encoded)
      final isUnknown = result.value.trim().isEmpty &&
          (result.encoded?.trim().isNotEmpty ?? false);
      final toStore = isUnknown ? (result.encoded ?? '') : result.value;
      _onAttrChanged(attr.id.toString(), toStore);
    }
  }
  // coverage:ignore-end

  Widget _descriptionSectionContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: DesignTokens.surfaceAltOf(context),
              border: Border.all(color: DesignTokens.borderOf(context)),
              borderRadius: DesignTokens.brMd),
          child: Text(currentGeneral?.description ?? 'No selection.',
              style: const TextStyle(fontSize: 12, height: 1.4))),
      const SizedBox(height: 12),
      Wrap(spacing: 20, runSpacing: 10, children: [
        _miniField('Class', currentGeneral?.classId.toString() ?? '-'),
        _miniField(
            'Logic Name',
            currentGeneral == null
                ? '-'
                : (decimalFormat
                    ? currentGeneral!.logicalNameHex
                    : currentGeneral!.logicalName)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Checkbox(
              key: const Key(SuperManualToolKeys.decimalFormatChk),
              value: decimalFormat,
              onChanged: (v) => setState(() => decimalFormat = v ?? false)),
          const Text('Decimal Logic Name', style: TextStyle(fontSize: 12))
        ]),
      ])
    ]);
  }

  Widget _miniField(String label, String value) => SizedBox(
      width: 180,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textSecondaryOf(context))),
        const SizedBox(height: 4),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: DesignTokens.surfaceOf(context),
                border: Border.all(color: DesignTokens.borderOf(context)),
                borderRadius: DesignTokens.brSm),
            child: Text(value, style: const TextStyle(fontSize: 12)))
      ]));

  // coverage:ignore-start
  Widget _pillsRow() {
    return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pills.map((p) {
          Color c;
          switch (p.kind) {
            case 'ok':
              c = DesignTokens.success;
              break;
            case 'warn':
              c = DesignTokens.warning;
              break;
            case 'err':
              c = DesignTokens.danger;
              break;
            case 'info':
              c = DesignTokens.info;
              break;
            default:
              c = DesignTokens.gray600;
          }
          return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: c.withOpacity(.12),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: c.withOpacity(.4))),
              child: Text(p.text,
                  style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600, color: c)));
        }).toList());
  }
  // coverage:ignore-end

  Widget _terminalView(List<TermEntry> data, ScrollController ctrl) {
    return Scrollbar(
      controller: ctrl,
      thumbVisibility: true,
      child: ListView.builder(
          controller: ctrl,
          itemCount: data.length,
          itemBuilder: (_, i) {
            // coverage:ignore-line
            // coverage:ignore-start
            final e = data[i];
            Color tagBg = const Color(0xFF1e3a8a);
            Color tagFg = const Color(0xFF93c5fd);
            if (e.kind == 'req') {
              tagBg = const Color(0xFF312e81);
              tagFg = const Color(0xFFc7d2fe);
            } else if (e.kind == 'err') {
              tagBg = const Color(0xFF7f1d1d);
              tagFg = const Color(0xFFfca5a5);
            }
            return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: tagBg,
                              borderRadius: BorderRadius.circular(14)),
                          child: Text(e.tag,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: tagFg,
                                  letterSpacing: .5))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(e.msg,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'monospace'))),
                    ]));
            // coverage:ignore-end
          }),
    );
  }

  // ---- SELECTIVE TAB ----
  Widget _tabSelective() {
    return Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(builder: (context, c) {
          final wide = c.maxWidth > 1250;
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(
              width: 300,
              child: _panel(_panelHeader('Dictionaries list of Class 7'), [
                TextField(
                    key: const Key(SuperManualToolKeys.selFilterField),
                    decoration: DesignTokens.inputDecoration(hint: 'Filter'),
                    onChanged: (v) => setState(() => filterSelective = v)),
                const SizedBox(height: 10),
                _selectiveList(), // no Expanded
              ]),
            ),
            const SizedBox(width: 20),
            Expanded(
                child: Column(
              children: [
                Expanded(
                    child: _panel(_panelHeader('Capture Information'), [
                  _captureInfo(),
                ])),
                const SizedBox(height: 20),
                Expanded(
                    child: _panel(_panelHeader('Selective Access Operator'), [
                  _operatorForm(),
                ])),
              ],
            )),
            const SizedBox(width: 20),
            if (wide)
              SizedBox(
                  width: 380,
                  child: _panelWithExpandedField(
                    _panelHeader('Results'),
                    'Encoding (xdr xml)',
                    selectiveEncodedBox,
                    (v) => selectiveEncodedBox = v,
                    [
                      _btn('Encode', Icons.code, _encodeSelective,
                          key: const Key(SuperManualToolKeys.selectiveEncodeBtn),
                          color: DesignTokens.gray100,
                          fg: DesignTokens.primary600),
                      _btn('Decode', Icons.code_off, _decodeSelective,
                          key: const Key(SuperManualToolKeys.selectiveDecodeBtn),
                          color: DesignTokens.warning),
                      _btn('Clear', Icons.backspace, _clearSelectiveEncoding,
                          key: const Key(SuperManualToolKeys.selectiveClearBtn),
                          color: DesignTokens.danger),
                    ],
                  ))
            else
              SizedBox(
                  width: 320,
                  child: _panelWithExpandedField(
                    _panelHeader('Results'),
                    'Encoding (xdr xml)',
                    selectiveEncodedBox,
                    (v) => selectiveEncodedBox = v, // coverage:ignore-line
                    [
                      _btn('Encode', Icons.code, _encodeSelective,
                          key: const Key(SuperManualToolKeys.selectiveEncodeBtn),
                          color: DesignTokens.gray100,
                          fg: DesignTokens.primary600),
                      _btn('Decode', Icons.code_off, _decodeSelective,
                          key: const Key(SuperManualToolKeys.selectiveDecodeBtn),
                          color: DesignTokens.warning),
                      _btn('Clear', Icons.backspace, _clearSelectiveEncoding,
                          key: const Key(SuperManualToolKeys.selectiveClearBtn),
                          color: DesignTokens.danger),
                    ],
                    terminalWidget: SizedBox(
                        height: 180,
                        child: _terminalView(terminalSelective,
                            termSelCtrl)), // coverage:ignore-line
                  ))
          ]);
        }));
  }

  // coverage:ignore-start
  Widget _buildSelectiveAccessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1100) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: _buildSelectiveDictionariesPanel(),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 350,
                  child: _buildCaptureInfoPanel(),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSelectiveOperatorPanel(),
                ),
              ],
            );
          } else if (constraints.maxWidth > 860) {
            return Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      child: _buildSelectiveDictionariesPanel(),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildCaptureInfoPanel(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSelectiveOperatorPanel(),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSelectiveDictionariesPanel(),
                const SizedBox(height: 20),
                _buildCaptureInfoPanel(),
                const SizedBox(height: 20),
                _buildSelectiveOperatorPanel(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSelectiveDictionariesPanel() {
    final data = selectiveObjects
        .where((o) =>
            filterSelective.isEmpty ||
            o.name.toLowerCase().contains(filterSelective.toLowerCase()) ||
            o.logicalName.contains(filterSelective))
        .toList();
    return buildPanel(
      title: 'Dictionaries List of Class 7',
      children: [
        TextField(
          decoration: const InputDecoration(
            labelText: 'Filter',
            hintText: 'Filter...',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (value) {
            setState(() {
              filterSelective = value;
            });
          },
        ),
        const SizedBox(height: 14),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.gray800),
            borderRadius: BorderRadius.circular(8),
            color: DesignTokens.surfaceOf(context),
          ),
          constraints: const BoxConstraints(maxHeight: 480),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (context, index) {
              final obj = data[index];
              final isActive = currentSelective?.name == obj.name;
              return Container(
                decoration: BoxDecoration(
                  color: isActive
                      ? (DesignTokens.isDark(context)
                          ? DesignTokens.darkSurfaceAlt
                          : const Color(0xFFDBEAFE))
                      : DesignTokens.surfaceOf(context),
                  border: Border(
                    bottom: BorderSide(
                      color: index < data.length - 1
                          ? DesignTokens.gray800
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    obj.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w500 : FontWeight.normal,
                      color:
                          isActive ? DesignTokens.primary600 : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    obj.logicalName,
                    style: TextStyle(fontSize: 11, color: DesignTokens.gray800),
                  ),
                  onTap: () => _selectSelective(obj),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureInfoPanel() {
    return buildPanel(
      title: 'Capture Information',
      children: [
        buildReadonlyField('Logic Name', currentSelective?.logicalName ?? '-'),
        const SizedBox(height: 14),
        buildReadonlyField('Class', '7'),
        const SizedBox(height: 14),
        buildNumberField('Record (Max)', _recordMax, (value) {
          setState(() {
            _recordMax = value;
          });
        }),
        const SizedBox(height: 14),
        buildNumberField('Record (Num)', _recordNum, (value) {
          setState(() {
            _recordNum = value;
          });
        }),
        const SizedBox(height: 14),
        buildNumberField('Capture Period (s)', _capturePeriod, (value) {
          setState(() {
            _capturePeriod = value;
          });
        }),
        const SizedBox(height: 14),
        buildButton('Read', DesignTokens.gray800, _selReadBasic),
      ],
    );
  }

  Widget _buildSelectiveOperatorPanel() {
    return buildPanel(
      title: 'Selective Access Operator',
      children: [
        DropdownButtonFormField<String>(
          key: const Key(SuperManualToolKeys.opTypeDropdown),
          value: opType,
          decoration: const InputDecoration(
            labelText: 'Operator Type',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          items: const [
            DropdownMenuItem(value: '', child: Text('Select Access Operator')),
            DropdownMenuItem(
                value: 'range descriptor', child: Text('Range descriptor')),
            DropdownMenuItem(
                value: 'entry descriptor', child: Text('Entry descriptor')),
          ],
          onChanged: (value) {
            setState(() {
              opType = value!;
            });
          },
        ),
        const SizedBox(height: 14),
        // -------------------- CONDITIONAL CONTENT HERE --------------------
        if (opType == 'range descriptor') _rangeDescriptorInputs(),
        if (opType == 'entry descriptor') _entryDescriptorInputs(),
        const SizedBox(height: 14),
        TextField(
          key: const Key(SuperManualToolKeys.opExpressionField),
          controller: TextEditingController(text: _opExpression)
            ..selection = TextSelection.collapsed(offset: _opExpression.length),
          maxLines: 4,
          style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
          decoration: const InputDecoration(
            labelText: 'Operator (JSON / expression)',
            hintText:
                'Ex: {"from":"2025-01-01T00:00:00Z","to":"2025-01-01T01:00:00Z"}',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(10),
          ),
          onChanged: (value) {
            setState(() {
              _opExpression = value;
            });
          },
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            buildButton('Decode', DesignTokens.warning, _opDecode),
            buildOutlineButton('Encode', _opEncode),
            buildButton('Read', DesignTokens.success, _opRead),
          ],
        ),
        const Divider(height: 32),
        const Text(
          'Results Output',
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DesignTokens.primary600),
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Output Information',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF111927),
                  border: Border.all(color: const Color(0xFF1E293B)),
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints:
                    const BoxConstraints(minHeight: 400, maxHeight: 600),
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: _outputInfo.isEmpty
                        ? const Text(
                            'Selective access results will appear here...',
                            style: TextStyle(
                                color: Color(0xFF64748B), fontSize: 12),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _outputInfo
                                .map((line) => buildTerminalLine(line))
                                .toList(),
                          ),
                  ),
                )),
          ],
        ),
      ],
    );
  }
  // coverage:ignore-end

  Widget _selectiveList() {
    // 1️⃣ While loading → show loader
    if (_isLoadingGeneral) {
      return ClipRRect(
        borderRadius: DesignTokens.brMd,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.borderOf(context)),
            color: DesignTokens.surfaceOf(context),
          ),
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    // 2️⃣ When not loading → filter data
    final data = selectiveObjects
        .where((o) =>
            filterSelective.isEmpty ||
            o.name.toLowerCase().contains(filterSelective.toLowerCase()) ||
            o.logicalName.contains(filterSelective))
        .toList();
    return ClipRRect(
        borderRadius: DesignTokens.brMd,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.borderOf(context)),
              color: DesignTokens.surfaceOf(context)),
          child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: DesignTokens.borderOf(context)),
              itemBuilder: (_, i) {
                final o = data[i];
                final active = o == currentSelective;
                return InkWell(
                  key: Key(SuperManualToolKeys.selItemBtn(o.logicalName)),
                  onTap: () => _selectSelective(o),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      color: active
                          ? (DesignTokens.isDark(context)
                              ? DesignTokens.darkSurfaceAlt
                              : DesignTokens.primary100)
                          : DesignTokens.surfaceOf(context),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(o.name,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: active
                                        ? DesignTokens.primary600
                                        : DesignTokens.textPrimaryOf(context))),
                            const SizedBox(height: 4),
                            Text(o.logicalName,
                                style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        DesignTokens.textSecondaryOf(context))),
                          ])),
                );
              }),
        ));
  }

  Widget _captureInfo() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 16, runSpacing: 16, children: [
        _capField('Logic Name', currentSelective?.logicalName ?? '-'),
        _capField('Class', '7'),
        _numField('Record (Max)', '0', key: const Key(SuperManualToolKeys.recordMaxField)),
        _numField('Record (Num)', '0', key: const Key(SuperManualToolKeys.recordNumField)),
        _numField('Capture Period (s)', '0', key: const Key(SuperManualToolKeys.capturePeriodField)),
        SizedBox(
          width: 180,
          child: DropdownButtonFormField<String>(
              key: const Key(SuperManualToolKeys.captureTypeDropdown),
              isExpanded: true,
              value: 'Auto',
              items: const ['Auto', 'INTEGER', 'OCTET STRING', 'STRUCTURE']
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e, style: TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: (_) {},
              decoration: DesignTokens.inputDecoration()),
        )
      ]),
      const SizedBox(height: 14),
      _btn('Read', Icons.visibility, _selReadBasic,
          key: const Key(SuperManualToolKeys.selReadBtn),
          color: DesignTokens.gray100,
          fg: DesignTokens.primary600,
          enabled: _isConnected)
    ]);
  }

  // coverage:ignore-start
  /// Avoid Expanded in vertical (single) mode to prevent unbounded-height issues.
  Widget _resultsSplit() {
    return LayoutBuilder(builder: (context, c) {
      final single = c.maxWidth < 700;
      if (single) {
        // Vertical stack: give each area a fixed height so it can show content
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 180,
              child: _labeledArea('Output Informations', selOutput,
                  readonly: true, onChanged: (_) {}),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: _labeledArea('Input Parameters', selInputParams,
                  onChanged: (v) => setState(() => selInputParams = v)),
            ),
          ],
        );
      } else {
        // Horizontal split: expand horizontally only (safe)
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _labeledArea('Output Informations', selOutput,
                  readonly: true, onChanged: (_) {}),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _labeledArea('Input Parameters', selInputParams,
                  onChanged: (v) => setState(() => selInputParams = v)),
            ),
          ],
        );
      }
    });
  }
  // coverage:ignore-end

  Widget _operatorForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          key: const Key(SuperManualToolKeys.operatorTypeDropdown),
          value: opType,
          items: const ["", 'range descriptor', 'entry descriptor']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) => setState(() => opType = v),
          decoration: DesignTokens.inputDecoration(hint: 'Operator type'),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key(SuperManualToolKeys.opExpressionField),
          minLines: 4,
          maxLines: 6,
          decoration: DesignTokens.inputDecoration(
              hint: 'Operator (JSON / expression)'),
          onChanged: (v) => opExpression = v,
        ),
        const SizedBox(height: 16),
        // -------------------- CONDITIONAL CONTENT HERE --------------------
        if (opType == 'range descriptor') _rangeDescriptorInputs(),
        if (opType == 'entry descriptor') _entryDescriptorInputs(),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _btn('Config', Icons.settings, _opConfig,
                key: const Key(SuperManualToolKeys.opConfigBtn),
                color: DesignTokens.primary600),
            _btn('Decode', Icons.code_off, _opDecode,
                key: const Key(SuperManualToolKeys.opDecodeBtn),
                color: DesignTokens.warning),
            _btn('Encode', Icons.code, _opEncode,
                key: const Key(SuperManualToolKeys.opEncodeBtn),
                color: DesignTokens.gray100, fg: DesignTokens.primary600),
            _btn('Read', Icons.play_arrow, _opRead,
                key: const Key(SuperManualToolKeys.opReadBtn),
                color: DesignTokens.success, enabled: _isConnected),
          ],
        ),
      ],
    );
  }

  Widget _rangeDescriptorInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Start date"),
        const SizedBox(height: 8),
        _dateTimePicker(
          label: "Select start",
          value: startDate,
          onChanged: (v) => setState(() => startDate = v),
        ),
        const SizedBox(height: 16),
        const Text("End date"),
        const SizedBox(height: 8),
        _dateTimePicker(
          label: "Select end",
          value: endDate,
          onChanged: (v) => setState(() => endDate = v),
        ),
      ],
    );
  }

  Widget _dateTimePicker({
    required String label,
    required DateTime? value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      key: Key(SuperManualToolKeys.dateTimePicker(label)),
      onTap: () async {
        // coverage:ignore-start
        // 1️⃣ Pick date
        final initial = value ?? DateTime.now();
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate == null) return;
        // 2️⃣ Pick time
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initial),
        );
        if (pickedTime == null) return;
        // 3️⃣ Combine date + time
        final combined = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onChanged(combined);
        // coverage:ignore-end
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                value != null ? _dtFormat.format(value) : label,
                style: const TextStyle(fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _entryDescriptorInputs() {
    return Column(
      children: [
        _rangeRow(
          label: "Entry",
          startValue: entryStart,
          endValue: entryEnd,
          onStartChanged: (v) => setState(() => entryStart = v),
          onEndChanged: (v) => setState(() => entryEnd = v),
          startKey: const Key(SuperManualToolKeys.entryStartField),
          endKey: const Key(SuperManualToolKeys.entryEndField),
        ),
        const SizedBox(height: 14),
        _rangeRow(
          label: "Selected",
          startValue: selectedStart,
          endValue: selectedEnd,
          onStartChanged: (v) => setState(() => selectedStart = v),
          onEndChanged: (v) => setState(() => selectedEnd = v),
          startKey: const Key(SuperManualToolKeys.selectedStartField),
          endKey: const Key(SuperManualToolKeys.selectedEndField),
        ),
      ],
    );
  }

  Widget _rangeRow({
    required String label,
    required int? startValue,
    required int? endValue,
    required ValueChanged<int> onStartChanged,
    required ValueChanged<int> onEndChanged,
    Key? startKey,
    Key? endKey,
  }) {
    return Row(
      children: [
        SizedBox(width: 80, child: Text(label)),
        // Start input
        Expanded(
          child: TextField(
            key: startKey,
            keyboardType: TextInputType.number,
            decoration: DesignTokens.inputDecoration(hint: "Start"),
            onChanged: (v) => onStartChanged(int.tryParse(v) ?? 0),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text("to"),
        ),
        // End input
        Expanded(
          child: TextField(
            key: endKey,
            keyboardType: TextInputType.number,
            decoration: DesignTokens.inputDecoration(hint: "End"),
            onChanged: (v) => onEndChanged(int.tryParse(v) ?? 0),
          ),
        ),
      ],
    );
  }

  // ---- Generic UI helpers ----
  Widget _panel(Widget header, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: DesignTokens.brLg,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          header,
          // body scrolls
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: _ScrollablePanelContent(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelWithListView(Widget header, Widget listView) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: DesignTokens.brLg,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          header,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: listView,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelNoExpand(Widget header, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: DesignTokens.brLg,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelHeader(String title) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(color: DesignTokens.borderOf(context)))),
      child: Text(title,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: DesignTokens.primary600)));

  Widget _panelWithExpandedField(
    Widget header,
    String fieldLabel,
    String fieldValue,
    ValueChanged<String> onFieldChanged,
    List<Widget> buttons, {
    Widget? terminalWidget,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: DesignTokens.brLg,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        children: [
          header,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (terminalWidget != null) ...[
                    terminalWidget,
                    const SizedBox(height: 10),
                  ],
                  Text(
                    fieldLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: DesignTokens.surfaceOf(context),
                        borderRadius: DesignTokens.brMd,
                        border:
                            Border.all(color: DesignTokens.borderOf(context)),
                      ),
                      child: TextField(
                        controller: TextEditingController(text: fieldValue),
                        onChanged: onFieldChanged,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(spacing: 10, children: buttons),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _btn(String label, IconData icon, VoidCallback? onTap,
          {Color? color, Color? fg, bool enabled = true, Key? key}) =>
      ElevatedButton.icon(
          key: key,
          onPressed: enabled ? onTap : null,
          icon: Icon(icon, size: 16),
          label: Text(label),
          style: ElevatedButton.styleFrom(
              backgroundColor: color ?? DesignTokens.primary600,
              foregroundColor: fg ?? Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: DesignTokens.brMd)));

  Widget _capField(String label, String value) => SizedBox(
      width: 180,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textSecondaryOf(context))),
        const SizedBox(height: 4),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: DesignTokens.surfaceOf(context),
                border: Border.all(color: DesignTokens.borderOf(context)),
                borderRadius: DesignTokens.brSm),
            child: Text(value, style: const TextStyle(fontSize: 12)))
      ]));

  Widget _numField(String label, String value, {Key? key}) => SizedBox(
      width: 180,
      child: TextField(
          key: key,
          controller: TextEditingController(text: value),
          decoration: DesignTokens.inputDecoration(hint: label)));

  /// Removed internal Expanded to avoid unbounded-height assertion.
  // coverage:ignore-start
  Widget _labeledArea(String label, String value,
          {required ValueChanged<String> onChanged, bool readonly = false}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
            controller: TextEditingController(text: value),
            readOnly: readonly,
            minLines: 6,
            maxLines: 12,
            onChanged: onChanged,
            decoration: DesignTokens.inputDecoration())
      ]);
  // coverage:ignore-end
}

// Separate StatefulWidget to manage ScrollController lifecycle
class _ScrollablePanelContent extends StatefulWidget {
  final List<Widget> children;

  const _ScrollablePanelContent({required this.children});

  @override
  State<_ScrollablePanelContent> createState() =>
      _ScrollablePanelContentState();
}

class _ScrollablePanelContentState extends State<_ScrollablePanelContent> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.children,
        ),
      ),
    );
  }
}

// Local pill model kept here (UI concern only).
class _Pill {
  _Pill(this.kind, this.text);
  final String kind;
  final String text;
}
