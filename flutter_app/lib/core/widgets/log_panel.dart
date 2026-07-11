import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/services/logger_provider.dart';
import '../../grpc/meter_client.dart';

/// Controls whether the log panel is visible.
final logPanelVisibleProvider = StateProvider<bool>((ref) => false);

/// Height of the persistent log panel in logical pixels.
final logPanelHeightProvider = StateProvider<double>((ref) => 280.0);

// Estimated rendered height per log line (used for scroll-to-match).
// Most lines are single-line at fontSize 12 + 3px vertical padding = ~18px.
const double _kLineHeight = 19.0;

/// Opens the Log Panel as a draggable bottom sheet.
/// Call [LogPanel.show] from anywhere you have a [BuildContext].
class LogPanel extends ConsumerStatefulWidget {
  const LogPanel({super.key});

  /// Toggles the persistent log panel (show if hidden, hide if visible).
  static void show(BuildContext context) {
    final container = ProviderScope.containerOf(context);
    final notifier = container.read(logPanelVisibleProvider.notifier);
    notifier.state = !notifier.state;
  }

  @override
  ConsumerState<LogPanel> createState() => _LogPanelState();
}

class _LogPanelState extends ConsumerState<LogPanel> {
  final ScrollController _scrollCtrl = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // ── Search state ────────────────────────────────────────────────────────────
  bool _searchVisible = false;
  bool _useRegex = false;

  /// Indices into [state.messages] that match the current query.
  List<int> _matchIndices = const [];

  /// Pointer into [_matchIndices] for the currently highlighted match.
  int _currentMatchIdx = -1;

  /// Set when the regex pattern is syntactically invalid.
  bool _regexError = false;

  // Track last-computed inputs so we only recompute when something changed.
  String _prevQuery = '';
  bool _prevRegex = false;
  int _prevMsgVersion = -1;

  // ── Translation panel state ─────────────────────────────────────────────────
  bool _showTranslationPanel = false;
  bool _translating = false;
  String? _translationXml;
  String? _translationError;

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _translateHex(String raw) async {
    final hex = raw.replaceAll(' ', '').replaceAll(':', '').trim();
    print('Translating hex: $hex');
    if (hex.isEmpty) return;
    setState(() {
      _showTranslationPanel = true;
      _translating = true;
      _translationXml = null;
      _translationError = null;
    });
    final client = meterClientFactory();
    try {
      final result = await client.dlmsTranslate(hex, false);
      if (mounted) setState(() { _translationXml = result; _translating = false; });
    } catch (e) {
      if (mounted) setState(() { _translationError = e.toString(); _translating = false; });
    } finally {
      client.close();
    }
  }

  // ── Scroll helpers ──────────────────────────────────────────────────────────

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIdx < 0 || _currentMatchIdx >= _matchIndices.length) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      final target = (_matchIndices[_currentMatchIdx] * _kLineHeight)
          .clamp(0.0, _scrollCtrl.position.maxScrollExtent);
      _scrollCtrl.animateTo(target,
          duration: const Duration(milliseconds: 150), curve: Curves.easeOut);
    });
  }

  // ── Search logic ────────────────────────────────────────────────────────────

  List<int> _computeMatches(List<String> msgs, String query, bool useRegex) {
    _regexError = false;
    if (query.isEmpty) return const [];
    final result = <int>[];
    if (useRegex) {
      RegExp re;
      try {
        re = RegExp(query, caseSensitive: false);
      } catch (_) {
        _regexError = true;
        return const [];
      }
      for (int i = 0; i < msgs.length; i++) {
        if (re.hasMatch(msgs[i])) result.add(i);
      }
    } else {
      final lower = query.toLowerCase();
      for (int i = 0; i < msgs.length; i++) {
        if (msgs[i].toLowerCase().contains(lower)) result.add(i);
      }
    }
    return result;
  }

  void _goToNext() {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatchIdx = (_currentMatchIdx + 1) % _matchIndices.length;
    });
    _scrollToCurrentMatch();
  }

  void _goToPrev() {
    if (_matchIndices.isEmpty) return;
    setState(() {
      _currentMatchIdx =
          (_currentMatchIdx - 1 + _matchIndices.length) % _matchIndices.length;
    });
    _scrollToCurrentMatch();
  }

  void _openSearch() {
    setState(() => _searchVisible = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _closeSearch() {
    setState(() {
      _searchVisible = false;
      _searchCtrl.clear();
      _matchIndices = const [];
      _currentMatchIdx = -1;
      _prevQuery = '';
    });
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loggerProvider);
    final notifier = ref.read(loggerProvider.notifier);
    final messages = state.messages;
    final query = _searchCtrl.text;

    // Recompute matches whenever the query, regex flag, or messages change.
    final queryChanged = query != _prevQuery || _useRegex != _prevRegex;
    final msgsChanged = state.version != _prevMsgVersion;

    if (queryChanged || msgsChanged) {
      _prevQuery = query;
      _prevRegex = _useRegex;
      _prevMsgVersion = state.version;

      if (query.isNotEmpty) {
        final newMatches = _computeMatches(messages.toList(), query, _useRegex);
        if (queryChanged) {
          // New query: jump to first match.
          _matchIndices = newMatches;
          _currentMatchIdx = newMatches.isNotEmpty ? 0 : -1;
          _scrollToCurrentMatch();
        } else {
          // Same query, new messages: extend matches, keep current position.
          _matchIndices = newMatches;
          if (_currentMatchIdx >= newMatches.length) {
            _currentMatchIdx =
                newMatches.isNotEmpty ? newMatches.length - 1 : -1;
          }
        }
      } else {
        _matchIndices = const [];
        _currentMatchIdx = -1;
        _regexError = false;
        // Auto-scroll to bottom only when not searching.
        if (msgsChanged) _scrollToBottom();
      }
    }

    final panelHeight = ref.watch(logPanelHeightProvider);

    return SizedBox(
      height: panelHeight,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1e1e2e),
            border: Border(top: BorderSide(color: Colors.white12, width: 1)),
          ),
          child: Column(
            children: [
              // ── Resize handle ────────────────────────────────────────────
              GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                final newH = (ref.read(logPanelHeightProvider) - details.delta.dy)
                    .clamp(50.0, MediaQuery.of(context).size.height * 0.85);
                ref.read(logPanelHeightProvider.notifier).state = newH;
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeUpDown,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),

              // ── Title bar ────────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      state.isConnected ? Icons.wifi : Icons.wifi_off,
                      color: state.isConnected
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Server Logs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    // Search toggle
                    IconButton(
                      tooltip: 'Search (Ctrl+F)',
                      icon: Icon(
                        Icons.search,
                        color:
                            _searchVisible ? Colors.yellowAccent : Colors.white54,
                      ),
                      onPressed: _searchVisible ? _closeSearch : _openSearch,
                    ),
                    // Start / Stop
                    IconButton(
                      tooltip: state.isConnected ? 'Stop' : 'Start',
                      icon: Icon(
                        state.isConnected
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                        color: state.isConnected
                            ? Colors.redAccent
                            : Colors.greenAccent,
                      ),
                      onPressed:
                          state.isConnected ? notifier.stop : notifier.start,
                    ),
                    // Clear
                    IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.white54),
                      onPressed: notifier.clear,
                    ),
                    // Hide panel
                    IconButton(
                      tooltip: 'Hide',
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                      onPressed: () {
                        ref.read(logPanelVisibleProvider.notifier).state = false;
                      },
                    ),
                  ],
                ),
              ),

              // ── Search bar ───────────────────────────────────────────────
              if (_searchVisible) _buildSearchBar(),

              const Divider(color: Colors.white12, height: 1),

              // ── Error banner ─────────────────────────────────────────────
              if (state.error != null)
                Container(
                  width: double.infinity,
                  color: Colors.red.shade900.withOpacity(0.7),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'Error: ${state.error}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),

              // ── Log list ─────────────────────────────────────────────────
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Text(
                          'No logs yet. Press ▶ to start streaming.',
                          style:
                              TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: SelectionArea(
                              contextMenuBuilder: (context, selectableRegionState) {
                                return _TranslateButton(
                                  anchor: selectableRegionState,
                                  onTranslate: _translateHex,
                                );
                              },
                              child: ListView.builder(
                                controller: _scrollCtrl,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                itemCount: messages.length,
                                itemBuilder: (_, i) => _LogLine(
                                  index: i,
                                  message: messages[i],
                                  query: query,
                                  useRegex: _useRegex,
                                  isCurrentMatch: _matchIndices.isNotEmpty &&
                                      _currentMatchIdx >= 0 &&
                                      _matchIndices[_currentMatchIdx] == i,
                                ),
                              ),
                            ),
                          ),
                          if (_showTranslationPanel) ..._buildTranslationPanel(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTranslationPanel() {
    return [
      const VerticalDivider(color: Colors.white12, width: 1, thickness: 1),
      SizedBox(
        width: 420,
        child: Container(
          color: const Color(0xFF1e1e2e),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFF2a2a3e),
                child: Row(
                  children: [
                    const Icon(Icons.translate, color: Colors.white70, size: 15),
                    const SizedBox(width: 8),
                    const Text(
                      'DLMS Translation',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (_translationXml != null)
                      IconButton(
                        tooltip: 'Copy XML',
                        icon: const Icon(Icons.copy, size: 14, color: Colors.white38),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _translationXml!));
                        },
                      ),
                    IconButton(
                      tooltip: 'Close panel',
                      icon: const Icon(Icons.close, size: 15, color: Colors.white38),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                      onPressed: () => setState(() => _showTranslationPanel = false),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: _translating
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white54,
                          strokeWidth: 2,
                        ),
                      )
                    : _translationError != null
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _translationError!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(12),
                            child: SelectableText(
                              _translationXml ?? '',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                decoration: TextDecoration.none,
                                color: Color(0xFFa8d8a8),
                                height: 1.5,
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildSearchBar() {
    final hasMatches = _matchIndices.isNotEmpty;
    final countLabel = _regexError
        ? 'invalid regex'
        : _searchCtrl.text.isEmpty
            ? ''
            : hasMatches
                ? '${_currentMatchIdx + 1} / ${_matchIndices.length}'
                : 'no results';

    return Container(
      color: const Color(0xFF2a2a3e),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          // Query input
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (e) {
                if (e is KeyDownEvent &&
                    e.logicalKey == LogicalKeyboardKey.escape) {
                  _closeSearch();
                }
              },
              child: TextField(
                controller: _searchCtrl,
                focusNode: _searchFocus,
                style: const TextStyle(
                    color: Colors.black, fontSize: 13, fontFamily: 'monospace'),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: _useRegex ? 'Regex pattern…' : 'Search…',
                  hintStyle:
                      const TextStyle(color: Colors.white30, fontSize: 13),
                  isDense: true,
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _goToNext(),
              ),
            ),
          ),
          // Match counter
          if (_searchCtrl.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                countLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: _regexError
                      ? Colors.redAccent
                      : hasMatches
                          ? Colors.yellowAccent
                          : Colors.white38,
                ),
              ),
            ),
          // Regex toggle
          Tooltip(
            message: 'Use regular expression',
            child: InkWell(
              onTap: () => setState(() => _useRegex = !_useRegex),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _useRegex
                      ? Colors.yellowAccent.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _useRegex ? Colors.yellowAccent : Colors.white24,
                  ),
                ),
                child: Text(
                  '.*',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: _useRegex ? Colors.yellowAccent : Colors.white38,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Previous match
          IconButton(
            tooltip: 'Previous match',
            icon: const Icon(Icons.keyboard_arrow_up, size: 18),
            color: hasMatches ? Colors.white70 : Colors.white24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: hasMatches ? _goToPrev : null,
          ),
          // Next match
          IconButton(
            tooltip: 'Next match (Enter)',
            icon: const Icon(Icons.keyboard_arrow_down, size: 18),
            color: hasMatches ? Colors.white70 : Colors.white24,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: hasMatches ? _goToNext : null,
          ),
          // Close search
          IconButton(
            tooltip: 'Close search (Esc)',
            icon: const Icon(Icons.close, size: 16),
            color: Colors.white38,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: _closeSearch,
          ),
        ],
      ),
    );
  }
}

// ── Log line widget ───────────────────────────────────────────────────────────

class _LogLine extends StatelessWidget {
  final int index;
  final String message;
  final String query;
  final bool useRegex;
  final bool isCurrentMatch;

  const _LogLine({
    required this.index,
    required this.message,
    required this.query,
    required this.useRegex,
    required this.isCurrentMatch,
  });

  Color _levelColor(String msg) {
    final lower = msg.toLowerCase();
    if (lower.contains('error') || lower.contains('critical')) {
      return Colors.redAccent;
    } else if (lower.contains('warn')) {
      return Colors.orangeAccent;
    } else if (lower.contains('debug')) {
      return Colors.cyanAccent;
    }
    return const Color(0xFFa8d8a8);
  }

  /// Returns all [start, end) ranges that match [query] inside [text].
  List<(int, int)> _findRanges(String text, String query, bool useRegex) {
    if (query.isEmpty) return const [];
    final ranges = <(int, int)>[];
    if (useRegex) {
      try {
        for (final m in RegExp(query, caseSensitive: false).allMatches(text)) {
          ranges.add((m.start, m.end));
        }
      } catch (_) {}
    } else {
      final lower = text.toLowerCase();
      final qLower = query.toLowerCase();
      int pos = 0;
      while (pos < lower.length) {
        final idx = lower.indexOf(qLower, pos);
        if (idx < 0) break;
        ranges.add((idx, idx + qLower.length));
        pos = idx + qLower.length;
      }
    }
    return ranges;
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = _levelColor(message);
    final ranges = _findRanges(message, query, useRegex);

    Widget textWidget;
    if (ranges.isEmpty) {
      textWidget = Text(
        message,
        style: TextStyle(
            color: baseColor, fontSize: 12, fontFamily: 'monospace'),
      );
    } else {
      final spans = <TextSpan>[];
      int pos = 0;
      for (final (start, end) in ranges) {
        if (start > pos) {
          spans.add(TextSpan(
              text: message.substring(pos, start),
              style: TextStyle(color: baseColor)));
        }
        spans.add(TextSpan(
          text: message.substring(start, end),
          style: TextStyle(
            color: Colors.black,
            backgroundColor:
                isCurrentMatch ? Colors.orange : Colors.yellowAccent,
            fontWeight: FontWeight.bold,
          ),
        ));
        pos = end;
      }
      if (pos < message.length) {
        spans.add(TextSpan(
            text: message.substring(pos),
            style: TextStyle(color: baseColor)));
      }
      textWidget = Text.rich(
        TextSpan(children: spans),
        style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
      );
    }

    return Container(
      // Highlight the entire row for the current match.
      color: isCurrentMatch ? Colors.orange.withOpacity(0.08) : null,
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                  fontFamily: 'monospace'),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: textWidget),
        ],
      ),
    );
  }
}

// ── Translate button (appears in selection toolbar) ──────────────────────────

class _TranslateButton extends StatelessWidget {
  const _TranslateButton({required this.anchor, required this.onTranslate});
  final SelectableRegionState anchor;
  final void Function(String raw) onTranslate;

  @override
  Widget build(BuildContext context) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: anchor.contextMenuAnchors,
      buttonItems: [
        ...anchor.contextMenuButtonItems,
        ContextMenuButtonItem(
          label: 'Translate',
          onPressed: () {
            anchor.contextMenuButtonItems
                .where((i) => i.type == ContextMenuButtonType.copy)
                .firstOrNull
                ?.onPressed
                ?.call();
            ContextMenuController.removeAny();
            Clipboard.getData(Clipboard.kTextPlain).then((data) {
              //print("is mounted ${context.mounted}");
              //if (!context.mounted) return;
              final raw = data?.text ?? '';
              print("raw.trim().isEmpty ${raw.trim().isEmpty}");
              if (raw.trim().isEmpty) return;
              onTranslate(raw.startsWith("0x") ? raw.substring(2) : raw);
            });
          },
        ),
      ],
    );
  }
}


