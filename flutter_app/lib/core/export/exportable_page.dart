/// Mixin applied to a [State] that exposes its data for the export system.
///
/// Usage:
/// ```dart
/// class _MyPageState extends State<MyPage>
///     with ... implements ExportablePage {
///   @override
///   String get exportPageId => 'my_page';
///
///   @override
///   String get exportPageLabel => 'My Page';
///
///   @override
///   Map<String, dynamic> getExportData() => {'field': value};
/// }
/// ```
abstract mixin class ExportablePage {
  /// Stable, unique identifier used by [ExportRegistry] and routing.
  String get exportPageId;

  /// Human-readable label shown in [TemplateConfigPage].
  String get exportPageLabel;

  /// Snapshot of the current UI state as a plain [Map].
  /// Keys should be stable dotted-path strings (e.g. `'security.session_type'`).
  Map<String, dynamic> getExportData();
}
