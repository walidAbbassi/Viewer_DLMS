
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../util/xml_util.dart';
import '../theme/design_tokens.dart';

// Résultat du dialog (valeur principale + encodage éventuel)
class AttributeEditResult {
  final String value; // valeur "plain" (vide si unknown)
  final String? encoded; // encodé (renseigné si panneau encodage)
  AttributeEditResult({required this.value, this.encoded});
}

enum _InputKind { integer, string, boolean, date, time, datetime, unknown }

class AttributeEditDialog extends StatefulWidget {
  final DatamodelAttribute attr;
  final String? initialValue;
  /// Afficher le panneau d’encodage (xdr/xml/hex)
  /// Pour unknown, on affiche l’Encoded box en mode "encoded-only".
  final bool showEncodingPanel;
  /// Hooks facultatifs pour encoder / décoder
  final Future<String> Function(String plain, DatamodelAttribute attr)? onEncode;
  final Future<String> Function(String encoded, DatamodelAttribute attr)? onDecode;
  /// Pour boolean: "yes"/"no" si true, sinon "true"/"false"
  final bool booleanAsYesNo;
  /// Valeur initiale encodée (utile si tu veux pré-remplir l’Encoded box)
  final String? initialEncoded;

  const AttributeEditDialog({
    super.key,
    required this.attr,
    this.initialValue,
    this.showEncodingPanel = false,
    this.onEncode,
    this.onDecode,
    this.booleanAsYesNo = true,
    this.initialEncoded,
  });

  /// API pour afficher le dialog
  static Future<AttributeEditResult?> show(
    BuildContext context,
    DatamodelAttribute attr, {
    String? initialValue,
    String? initialEncoded,
    bool showEncodingPanel = false,
    Future<String> Function(String plain, DatamodelAttribute attr)? onEncode,
    Future<String> Function(String encoded, DatamodelAttribute attr)? onDecode,
    bool booleanAsYesNo = true,
  }) {
    return showDialog<AttributeEditResult>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.9,
            height: MediaQuery.of(ctx).size.height * 0.8,
            child: AttributeEditDialog(
              attr: attr,
              initialValue: initialValue,
              initialEncoded: initialEncoded,
              showEncodingPanel: showEncodingPanel,
              onEncode: onEncode,
              onDecode: onDecode,
              booleanAsYesNo: booleanAsYesNo,
            ),
          ),
        );
      },
    );
  }

  @override
  State<AttributeEditDialog> createState() => _AttributeEditDialogState();
}

class _AttributeEditDialogState extends State<AttributeEditDialog> {
  late final TextEditingController _textController; // pour string/integer
  late final TextEditingController _encodedController; // pour panneau encodage
  bool _boolValue = false;
  DateTime? _date;
  TimeOfDay? _time;
  late final _InputKind _kind;
  late final bool _unsigned;

  bool get _encodingOnly => _kind == _InputKind.unknown;
  /// ✅ Afficher l’Encoded box si unknown OU si demandé
  bool get _shouldShowEncoding => _encodingOnly || widget.showEncodingPanel;

  @override
  void initState() {
    super.initState();
    _kind = _detectKind(widget.attr.type);
    _unsigned = widget.attr.type.toLowerCase().contains('unsigned');
    _textController = TextEditingController(text: widget.initialValue ?? '');
    _encodedController = TextEditingController(text: widget.initialEncoded ?? '');

    if (_kind == _InputKind.boolean) {
      final v = (widget.initialValue ?? '').toLowerCase();
      _boolValue = v == 'yes' || v == 'true' || v == '1';
    } else if (_kind == _InputKind.date ||
        _kind == _InputKind.time ||
        _kind == _InputKind.datetime) {
      _parseInitialDateTime(widget.initialValue ?? '');
    }
    _updateEncodedFromPlain(); // mise en cohérence initiale
  }

  @override
  void dispose() {
    _textController.dispose();
    _encodedController.dispose();
    super.dispose();
  }

  // ---- Détection du type d'input à partir du libellé 'type' ----
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
    // Rien de reconnu → unknown
    return _InputKind.unknown;
  }

  void _parseInitialDateTime(String s) {
    try {
      if (_kind == _InputKind.date && s.isNotEmpty) {
        final parts = s.split('-'); // "2025-12-03"
        if (parts.length == 3) {
          _date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        }
      } else if (_kind == _InputKind.time && s.isNotEmpty) {
        final parts = s.split(':'); // "13:45:00"
        if (parts.length >= 2) {
          _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      } else if (_kind == _InputKind.datetime && s.isNotEmpty) {
        final split = s.split('T');
        if (split.length == 2) {
          final d = split[0].split('-');
          final tm = split[1].split(':');
          if (d.length == 3 && tm.length >= 2) {
            _date = DateTime(int.parse(d[0]), int.parse(d[1]), int.parse(d[2]));
            _time = TimeOfDay(hour: int.parse(tm[0]), minute: int.parse(tm[1]));
          }
        }
      }
    } catch (_) {
      // ignore
    }
  }

  // Formatters (sans intl)
  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String _fmtTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';
  String _fmtDateTime(DateTime d, TimeOfDay t) => '${_fmtDate(d)}T${_fmtTime(t)}';

  String? _validateInteger(String input) {
    if (input.trim().isEmpty) return 'Champ requis';
    final n = int.tryParse(input);
    if (n == null) return 'Nombre invalide';
    if (_unsigned && n < 0) return 'Doit être non signé (>= 0)';
    return null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (result != null) {
      setState(() => _date = result);
      _updateEncodedFromPlain(); // auto XML après sélection
    }
  }

  Future<void> _pickTime() async {
    final initial = _time ?? TimeOfDay.now();
    final result = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (result != null) {
      setState(() => _time = result);
      _updateEncodedFromPlain(); // auto XML après sélection
    }
  }

  // ---- Auto XML encoding from plain value ----
  String _plainValueForType() {
    switch (_kind) {
      case _InputKind.integer:
      case _InputKind.string:
        return _textController.text;
      case _InputKind.boolean:
        return widget.booleanAsYesNo ? (_boolValue ? 'yes' : 'no') : (_boolValue ? 'true' : 'false');
      case _InputKind.date:
        return _date != null ? _fmtDate(_date!) : '';
      case _InputKind.time:
        return _time != null ? _fmtTime(_time!) : '';
      case _InputKind.datetime:
        if (_date != null && _time != null) return _fmtDateTime(_date!, _time!);
        return '';
      case _InputKind.unknown:
        return ''; // coverage:ignore-line
    }
  }

  String _xmlEscape(String s) {
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  // bytes -> hex
  String _toHex(List<int> bytes) {
    final sb = StringBuffer();
    for (final b in bytes) {
      sb.write(b.toRadixString(16).padLeft(2, '0'));
    }
    return sb.toString();
  }

  void _updateEncodedFromPlain() {
    // ✅ Encoded auto-seulement pour types connus et si le panneau est visible
    if (_encodingOnly) return; // unknown -> pas d'auto XML
    if (!_shouldShowEncoding) return; // panneau encodage non visible

    final plain = _plainValueForType();
    final typeTag = widget.attr.type.toLowerCase().replaceAll('_', '-'); // e.g., visible-string

    String xml;
    if (_kind == _InputKind.string) {
      // Encode en hex (UTF-8) + ajout attribut size = longueur de l'hex
      final bytes = utf8.encode(plain);
      final hex = _toHex(bytes);
      final size = hex.length~/2; // longueur de la chaîne hexadécimale
      xml = '<$typeTag size="$size">$hex</$typeTag>';
    } else {
      final escaped = _xmlEscape(plain);
      xml = '<$typeTag>$escaped</$typeTag>';
    }

    if (_encodedController.text != xml) {
      _encodedController.text = xml;
    }
  }

  // ---- Zones UI ----
  Widget _buildInputArea() {
    switch (_kind) {
      case _InputKind.integer:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('attr_edit_integer_field'),
                controller: _textController,
                keyboardType: TextInputType.number,
                inputFormatters: _unsigned
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [FilteringTextInputFormatter.allow(RegExp(r'[\-0-9]'))],
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: DesignTokens.inputDecoration(),
                onChanged: (_) => _updateEncodedFromPlain(), // auto XML
              ),
            ),
          ],
        );
      case _InputKind.string:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                key: const Key('attr_edit_string_field'),
                controller: _textController,
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
                decoration: DesignTokens.inputDecoration(),
                onChanged: (_) => _updateEncodedFromPlain(), // auto XML
              ),
            ),
          ],
        );
      case _InputKind.boolean:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              key: const Key('attr_edit_boolean_chk'),
              title: const Text('Yes'),
              value: _boolValue,
              onChanged: (v) {
                setState(() => _boolValue = v ?? false);
                _updateEncodedFromPlain(); // auto XML
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const Expanded(child: SizedBox()),
          ],
        );
      case _InputKind.date:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ElevatedButton(key: const Key('attr_edit_date_pick_btn'), onPressed: _pickDate, child: const Text('Choisir une date')),
              const SizedBox(width: 12),
              Text(_date != null ? _fmtDate(_date!) : '—'),
            ]),
            const SizedBox(height: 8),
            const Expanded(child: SizedBox()),
          ],
        );
      case _InputKind.time:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ElevatedButton(key: const Key('attr_edit_time_pick_btn'), onPressed: _pickTime, child: const Text('Choisir une heure')),
              const SizedBox(width: 12),
              Text(_time != null ? _fmtTime(_time!) : '—'),
            ]),
            const SizedBox(height: 8),
            const Expanded(child: SizedBox()),
          ],
        );
      case _InputKind.datetime:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              ElevatedButton(key: const Key('attr_edit_datetime_date_btn'), onPressed: _pickDate, child: const Text('Choisir une date')),
              const SizedBox(width: 12),
              Text(_date != null ? _fmtDate(_date!) : '—'),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton(key: const Key('attr_edit_datetime_time_btn'), onPressed: _pickTime, child: const Text('Choisir une heure')),
              const SizedBox(width: 12),
              Text(_time != null ? _fmtTime(_time!) : '—'),
            ]),
            const SizedBox(height: 8),
            const Expanded(child: SizedBox()),
          ],
        );
      case _InputKind.unknown:
        // unknown : ne rien rendre dans l'input principal
        return const SizedBox.shrink(); // coverage:ignore-line
    }
  }

  Widget _buildEncodingPanel({required bool fullHeight}) {
    final encodedField = TextField(
      key: const Key('attr_edit_encoded_field'),
      controller: _encodedController,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      decoration: DesignTokens.inputDecoration(),
      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Encodage (xdr/xml/hex)',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Expanded(child: encodedField),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: [
            // ✅ Boutons visibles même en unknown
            if (widget.onEncode != null)
              _btn(
                'Encode',
                Icons.code,
                () async {
                  final out = await widget.onEncode!(_encodedController.text, widget.attr);
                  setState(() => _encodedController.text = out);
                },
                color: DesignTokens.gray100,
                fg: DesignTokens.primary600,
              ),
            if (widget.onDecode != null)
              _btn(
                'Decode',
                Icons.code_off,
                () async {
                  final enc = _encodedController.text;
                  final out = await widget.onDecode!(enc, widget.attr);
                  final entry = parseSingleElement(out);
                  _setPlainValue(entry!.value); // si decode produit une valeur plain
                  _updateEncodedFromPlain(); // recalcule XML si connu
                },
                color: DesignTokens.warning,
              ),
            _btn(
              'Clear',
              Icons.backspace,
              () => setState(() => _encodedController.clear()),
              color: DesignTokens.danger,
            ),
          ],
        ),
      ],
    );
  }

  // Valeur "plain" courante (alias)
  String _getCurrentPlainValue() => _plainValueForType(); // coverage:ignore-line

  void _setPlainValue(String v) {
    switch (_kind) {
      case _InputKind.integer:
      case _InputKind.string:
        setState(() => _textController.text = v);
        break;
      case _InputKind.boolean:
        final low = v.toLowerCase();
        setState(() => _boolValue = (low == 'yes' || low == 'true' || low == '1'));
        break;
      case _InputKind.date:
        setState(() {
          try {
            final p = v.split('-');
            _date = DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
          } catch (_) {}
        });
        break;
      case _InputKind.time:
        setState(() {
          try {
            final p = v.split(':');
            _time = TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
          } catch (_) {}
        });
        break;
      case _InputKind.datetime:
        setState(() {
          try {
            final sp = v.split('T');
            final d = sp[0].split('-');
            final t = sp[1].split(':');
            _date = DateTime(int.parse(d[0]), int.parse(d[1]), int.parse(d[2]));
            _time = TimeOfDay(hour: int.parse(t[0]), minute: int.parse(t[1]));
          } catch (_) {}
        });
        break;
      case _InputKind.unknown:
        // rien
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Modifier ${widget.attr.name} (${widget.attr.type})",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Zone de contenu
          Expanded(
            child: _encodingOnly
                // ✅ MODE UNKNOWN: seulement l'Encoded box, plein écran contenu
                ? _buildEncodingPanel(fullHeight: true)
                // MODE NORMAL: input spécifique + panneau encodage éventuel
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input spécifique au type
                      Expanded(child: _buildInputArea()),
                      // Panneau d'encodage optionnel (prend l'autre moitié)
                      if (_shouldShowEncoding)
                        Expanded(child: _buildEncodingPanel(fullHeight: false)),
                    ],
                  ),
          ),
          const SizedBox(height: 16),
          // Footer (pinned)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('attr_edit_cancel_btn'),
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('attr_edit_confirm_btn'),
                onPressed: () {
                  // Validation minimale
                  if (_kind == _InputKind.integer) {
                    final err = _validateInteger(_textController.text);
                    if (err != null) {
                      ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                      return;
                    }
                  }
                  // Unknown -> value vide, encoded présent (puisque panel affiché)
                  final plain = _encodingOnly ? '' : _plainValueForType();
                  final encoded = _shouldShowEncoding ? _encodedController.text : null;
                  Navigator.pop(
                    context,
                    AttributeEditResult(value: plain, encoded: encoded),
                  );
                },
                child: const Text("Valider"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---- Bouton utilitaire (adapte à ton DS) ----
Widget _btn(
  String label,
  IconData icon,
  VoidCallback onPressed, {
  Color? color,
  Color? fg,
}) {
  return ElevatedButton.icon(
    icon: Icon(icon),
    label: Text(label),
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: fg,
    ),
  );
}
