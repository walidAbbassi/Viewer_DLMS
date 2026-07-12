import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../grpc/meter_client.dart';
import '../../core/widget_keys.dart';

class DlmsTranslatorPage extends StatefulWidget {
  const DlmsTranslatorPage({super.key});

  @override
  State<DlmsTranslatorPage> createState() => _DlmsTranslatorPageState();
}

class _DlmsTranslatorPageState extends State<DlmsTranslatorPage> {
  late final IMeterClient _client;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sc = SemanticColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DLMS Translator'),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const Breadcrumb(segments: ['Menu', 'DLMS Translator']),
          ),
          Expanded(child: _DlmsTranslateBody(client: _client)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DLMS Translate Body — calls DlmsTranslate RPC directly
// ---------------------------------------------------------------------------

class _DlmsTranslateBody extends StatefulWidget {
  const _DlmsTranslateBody({required this.client});
  final IMeterClient client;

  @override
  State<_DlmsTranslateBody> createState() => _DlmsTranslateBodyState();
}

class _DlmsTranslateBodyState extends State<_DlmsTranslateBody> {
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
      color: DesignTokens.backgroundOf(context),
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
                      dismissKey: const Key(DlmsTranslatorKeys.dismissErrorBtn),
                      onDismiss: () => setState(() => _error = null)),
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
                            textFieldKey: const Key(DlmsTranslatorKeys.inputField),
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
                                  key: const Key(DlmsTranslatorKeys.translateBtn),
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
                            hint: 'Translation result appears here…',
                            readOnly: true,
                            accentColor: const Color(0xFF2E7D32),
                            textFieldKey: const Key(DlmsTranslatorKeys.outputField),
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
                        textFieldKey: const Key(DlmsTranslatorKeys.inputField),
                      ),
                      const SizedBox(height: 12),
                      _loading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton.icon(
                              key: const Key(DlmsTranslatorKeys.translateBtn),
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
                        hint: 'Translation result appears here…',
                        readOnly: true,
                        accentColor: const Color(0xFF2E7D32),
                        textFieldKey: const Key(DlmsTranslatorKeys.outputField),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      key: const Key(DlmsTranslatorKeys.clearBtn),
                      onPressed: _clear,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text('Clear'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      key: const Key(DlmsTranslatorKeys.copyOutputBtn),
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
// Shared widgets
// ---------------------------------------------------------------------------

class _CodePanel extends StatelessWidget {
  const _CodePanel({
    required this.label,
    required this.controller,
    required this.hint,
    required this.readOnly,
    required this.accentColor,
    this.textFieldKey,
  });
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool readOnly;
  final Color accentColor;
  final Key? textFieldKey;

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
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
            color: DesignTokens.surfaceOf(context),
            borderRadius: DesignTokens.brMd,
            border: Border.all(color: DesignTokens.borderOf(context)),
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
              color: DesignTokens.textPrimaryOf(context),
              height: 1.5,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? DesignTokens.darkHint : Colors.black38,
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
    final isDark = DesignTokens.isDark(context);
    // Lighten accent color for dark mode readability
    final fg = isDark ? Color.lerp(color, Colors.white, 0.55) ?? color : color;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: fg.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 15, color: fg),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss, this.dismissKey});
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
