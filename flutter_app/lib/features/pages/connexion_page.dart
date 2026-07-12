import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_python_grpc/grpc/authentication_client.dart';
import 'package:flutter_python_grpc/grpc/generated/authentication.pb.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/theme_notifier.dart';
import '../../core/services/feedback_service.dart';
import '../../core/user_rights.dart';
import '../../core/widget_keys.dart';
import '../services/credential_storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Provider, Consumer, ConsumerWidget;

/// AuthenticationScreenV2
/// Parité avec authentication-screen.html :
/// - Brand panel (left, radial gradient) avec highlights
/// - Formulaire Username / Password + toggle visibilité
/// - Bouton Sign In (loading overlay simulé)
/// - Messages succès / erreur temporisés
/// - Checkbox Remember me
/// - Bouton Change Password -> modal (version simple: old/new)
/// - Section Privacy (About Viewer) en haut du corps
/// - Collapsible More info (License import + Password policy warning)
/// - Theme toggle (light/dark) global via Riverpod + SharedPreferences
/// - Inline links (Release notes / Privacy / Support / Version)
/// - Import license (FilePicker)
/// - Shake effect sur erreur d'authentification
/// - Animations d'entrée staggerées
/// Conception : réutilise DesignTokens pour cohérence visuelle.
class ConnexionPage extends ConsumerStatefulWidget {
  const ConnexionPage({super.key});
  @override
  ConsumerState<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends ConsumerState<ConnexionPage>
    with TickerProviderStateMixin {
  late final IAuthenticationClient client;
  final _credentialStorage = CredentialStorageService();
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _changeUsernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _oldPwCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  final TextEditingController _deleteUsernameCtrl = TextEditingController();
  final TextEditingController _deletePasswordCtrl = TextEditingController();

  bool _loading = false;
  bool _remember = false;
  bool _showPassword = false;
  bool _showModal = false;
  bool _showInfo = false;
  bool _signInHover = false;
  bool _signInPressed = false;
  bool _showDeleteModal = false;

  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  bool _licenseExists = false;
  String _licenseIdentifier = '';
  String _licensePath = '';
  List<LicenseInfo> _licenses = [];
  LicenseInfo? _selectedLicense;

  String? _error;
  String? _success;
  String? _changePwdError;
  String? _deleteLicensesError;

  // ── Entry animations (driven by _animCtrl) ──────────────────────────────
  late AnimationController _animCtrl;
  late Animation<double> _fade;
  late Animation<Offset> _brandSlide;
  late Animation<double> _brandFade;
  late Animation<double> _iconScale;
  late Animation<double> _privacyFade;
  late Animation<Offset> _privacySlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _btnFade;
  late Animation<Offset> _btnSlide;
  late Animation<double> _actionsFade;
  late Animation<Offset> _actionsSlide;

  // ── Shake animation (on auth error) ────────────────────────────────────
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    client = connexionClientFactory();
    _usernameFocus.addListener(_refreshFocusState);
    _passwordFocus.addListener(_refreshFocusState);

    // Entry animations — 800ms for comfortable stagger visibility
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);

    _brandSlide =
        Tween<Offset>(begin: const Offset(-0.06, 0), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.0, 0.7, curve: Curves.easeOut)),
    );
    _brandFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _iconScale = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    );
    _privacyFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
    );
    _privacySlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
    );
    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _formSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
    );
    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _btnSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );
    _actionsFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );
    _actionsSlide =
        Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
      CurvedAnimation(
          parent: _animCtrl,
          curve: const Interval(0.4, 0.9, curve: Curves.easeOut)),
    );
    _animCtrl.forward();

    // Shake animation — sinusoidal horizontal oscillation on error
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));

    _checkLicense();
    _loadSavedCredentials();
  }

  void _openDeleteLicenseModal() {
    setState(() {
      _showDeleteModal = true;
    });
  }


  Future<void> _loadSavedCredentials() async {
    try {
      final remember = await _credentialStorage.isRememberMeEnabled();
      if (!remember) return;
      final creds = await _credentialStorage.loadCredentials();
      if (creds != null && mounted) {
        setState(() {
          _remember = true;
          _usernameCtrl.text = creds.username;
          _passwordCtrl.text = creds.password;
        });
      }
    } catch (e) {
      debugPrint('[ConnexionPage] Failed to load saved credentials: $e');
    }
  }

  void _refreshFocusState() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _checkLicense() async {
    try {
      final resp = await client.checkLicense();
      if (mounted) {
        setState(() {
          _licenseExists = resp.exists;
          _licenseIdentifier = resp.identifier;
          _licenses = resp.licenses;
          if (_licenses.isNotEmpty) {
              _selectedLicense = _licenses.first;
            }

          if (!resp.exists) _showInfo = true;
        });
      }
    } catch (e) {
      debugPrint('[ConnexionPage] Failed to check license: $e');
    }
  }

  void _openChangePasswordModal() {
    setState(() {
      _showModal = true;
      _changePwdError = null;
      _changeUsernameCtrl.text = _usernameCtrl.text.trim();
    });
  }

  Future<void> _handleDeleteLicenses() async {
    final username = _deleteUsernameCtrl.text.trim();
    final password = _deletePasswordCtrl.text.trim();
    try{
         setState(() {
           _deleteLicensesError = null;
        });
         await client.deleteLicenses(username, password);
         await _checkLicense();

        // 👉 Call your backend gRPC here

        setState(() {
          _showDeleteModal = false;
        });
    }
    catch(e){
      debugPrint('[ConnexionPage] Failed to delete licenses: $e');
      setState(() {
        _deleteLicensesError = 'Failed to delete licenses. Please check your credentials and try again.';
      });
      return;
    }
    
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _deleteUsernameCtrl.dispose();
    _deletePasswordCtrl.dispose();
    _shakeController.dispose();
    _usernameFocus
      ..removeListener(_refreshFocusState)
      ..dispose();
    _passwordFocus
      ..removeListener(_refreshFocusState)
      ..dispose();
    _usernameCtrl.dispose();
    _changeUsernameCtrl.dispose();
    _passwordCtrl.dispose();
    _oldPwCtrl.dispose();
    _newPwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final colors = _Palette.of(dark: isDark);
    return AnimatedTheme(
      duration: const Duration(milliseconds: 350),
      data: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
            seedColor: colors.primary,
            brightness: isDark ? Brightness.dark : Brightness.light,
            primary: colors.primary),
        scaffoldBackgroundColor: Colors.transparent,
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: isDark ? const Color(0xFF1e3a5f) : Colors.white,
          hintStyle: TextStyle(
              fontSize: 14,
              color:
                  isDark ? const Color(0xFF64748B) : const Color(0xFF757575)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: DesignTokens.brMd,
            borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0),
                width: .9),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: DesignTokens.brMd,
            borderSide: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE0E0E0),
                width: .9),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: DesignTokens.brMd,
            borderSide: BorderSide(
                color: isDark ? colors.accent : const Color(0xFF1976D2),
                width: 1.2),
          ),
        ),
      ),
      child: Scaffold(
        body: Stack(children: [
          Positioned.fill(child: _buildBackground(colors)),
          SafeArea(child: LayoutBuilder(builder: (ctx, cs) {
            final wide = cs.maxWidth > 1080;
            return Center(child: _buildShell(colors, wide, cs.maxHeight));
          })),
          if (_loading) _buildLoadingOverlay(colors),
          if (_showModal) _buildChangePasswordModal(colors),
          if (_showDeleteModal) _buildDeleteLicenseModal(colors),
        ]),
      ),
    );
  }

  Widget _buildBackground(_Palette c) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.bgStart, c.bgMid, c.bgEnd],
        ),
      ),
    );
  }

  Widget _buildShell(_Palette c, bool wide, double height) {
    final shellHeight = height.clamp(640.0, 780.0);

    Widget brandPanel(int flex) {
      final wrapped = SlideTransition(
        position: _brandSlide,
        child: FadeTransition(opacity: _brandFade, child: _buildBrandPanel(c)),
      );
      return wide
          ? SizedBox(width: 520, child: wrapped)
          : Expanded(flex: flex, child: wrapped);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: wide ? 1180 : double.infinity,
      height: shellHeight,
      margin: EdgeInsets.symmetric(horizontal: wide ? 24 : 0),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(wide ? 26 : 0),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 6))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: wide
          ? Row(children: [
              brandPanel(0),
              Expanded(child: _buildAuthPanel(c, wide))
            ])
          : Column(children: [
              brandPanel(4),
              Expanded(flex: 6, child: _buildAuthPanel(c, wide))
            ]),
    );
  }

  Widget _buildBrandPanel(_Palette c) {
    return Container(
      decoration: const BoxDecoration(
        gradient:
            RadialGradient(center: Alignment(-0.3, -0.3), radius: 1.2, colors: [
          Color(0xFF1e40af),
          Color(0xFF184b9b),
          Color(0xFF12386f),
        ]),
      ),
      child: Stack(children: [
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0, .62),
            child: Opacity(
              opacity: .22,
              child: FractionallySizedBox(
                widthFactor: .72,
                child: Image.asset('assets/images/sagemcom_logo.png',
                    fit: BoxFit.contain, alignment: Alignment.bottomCenter),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(56, 54, 56, 56),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _glassBadge(),
            const SizedBox(height: 32),
            const Text('Smart Meter Viewer',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                    color: Colors.white)),
            const SizedBox(height: 10),
            const Opacity(
                opacity: .85,
                child: Text('Viewer_NG Secure Client',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white))),
            const SizedBox(height: 24),
            _highlight('🔐',
                'Desktop application for reading, configuring, and analyzing smart meters.'),
            const SizedBox(height: 14),
            _highlight('⚡',
                'Simple and organized interface to access meter data, profiles, and events.'),
            const SizedBox(height: 14),
            _highlight('🧩',
                'Secure and reliable operations with built‑in diagnostics and import/export features.'),
            const Spacer(),
          ]),
        ),
      ]),
    );
  }

  Widget _glassBadge() => Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Colors.white.withOpacity(.15),
          border: Border.all(color: Colors.white.withOpacity(.25)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(.45),
                blurRadius: 26,
                offset: const Offset(0, 8))
          ],
        ),
        alignment: Alignment.center,
        child: Container(
          width: 40,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border:
                Border.all(color: Colors.white.withOpacity(.55), width: 1.4),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF6FF),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: const Color(0xFFBFDBFE), width: 1),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF),
                      borderRadius: BorderRadius.circular(4),
                      border:
                          Border.all(color: const Color(0xFF93C5FD), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.bolt_rounded,
                        size: 15, color: Color(0xFFFACC15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _highlight(String icon, String text) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(.15),
              borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.center,
          child: Text(icon,
              style: const TextStyle(fontSize: 16, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, height: 1.4, color: Colors.white70))),
      ]);

  Widget _buildAuthPanel(_Palette c, bool wide) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildHeader(c),
      Expanded(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              wide ? 34 : 26, 18, wide ? 34 : 26, wide ? 26 : 32),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Privacy box — staggered
            FadeTransition(
              opacity: _privacyFade,
              child: SlideTransition(
                  position: _privacySlide, child: _privacyBox(c)),
            ),
            const SizedBox(height: 20),
            // Form + Sign In button with shake wrapper
            AnimatedBuilder(
              animation: _shakeController,
              builder: (_, child) => Transform.translate(
                offset: Offset(sin(_shakeController.value * pi * 6) * 10, 0),
                child: child,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: _formSlide,
                        child: Form(key: _formKey, child: _formFields(wide)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeTransition(
                      opacity: _btnFade,
                      child: SlideTransition(
                          position: _btnSlide, child: _signInButton(c)),
                    ),
                    const SizedBox(height: 16),
                    _messages(),
                  ]),
            ),
            const SizedBox(height: 16),
            // Secondary actions — staggered
            FadeTransition(
              opacity: _actionsFade,
              child: SlideTransition(
                  position: _actionsSlide, child: _secondaryActions(c)),
            ),
            const SizedBox(height: 16),
            // License + collapsible — simple fade
            FadeTransition(
              opacity: _fade,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LicenseStatusBadge(
                        exists: _licenseExists,
                        identifier: _licenseIdentifier,
                        licensePath: _licensePath,
                        onDeletePressed: _licenseExists ? _openDeleteLicenseModal : null,
                        ),
                    const SizedBox(height: 16),
                    _licenseSection(c),
                    const SizedBox(height: 16),
                    _collapsibleInfo(c),
                    const SizedBox(height: 16),
                    _inlineLinks(c),
                  ]),
            ),
          ]),
        ),
      )
    ]);
  }

  Widget _buildDeleteLicenseModal(_Palette c) {
  return Positioned.fill(
    child: GestureDetector(
      onTap: () => setState(() => _showDeleteModal = false),
      child: Container(
        color: Colors.black54,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {},
          child: Material(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 350,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 10),
                        Text(
                          "Delete Licenses",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: c.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () =>
                              setState(() => _showDeleteModal = false),
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Username
                    TextField(
                      controller: _deleteUsernameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Username",
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Password
                    TextField(
                      controller: _deletePasswordCtrl,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Password",
                      ),
                    ),

                    const SizedBox(height: 25),
                    if (_deleteLicensesError != null)
                      _alertBox(
                          _deleteLicensesError!,
                          const [Color(0xFFfee2e2), Color(0xFFfecaca)],
                          const Color(0xFFef4444),
                          const Color(0xFFdc2626),
                          Icons.error),
                    if (_deleteLicensesError != null) const SizedBox(height: 25),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleDeleteLicenses,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text("Delete"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}


  Widget _buildHeader(_Palette c) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(36, 26, 36, 14),
      decoration: BoxDecoration(color: c.surface),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(colors: [c.primary, c.accent]),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(.45),
                  blurRadius: 30,
                  offset: const Offset(0, 8))
            ],
          ),
          alignment: Alignment.center,
          child: ScaleTransition(
            scale: _iconScale,
            child: const Text('⚡',
                style: TextStyle(fontSize: 36, color: Colors.white)),
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Authentication',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary)),
            const SizedBox(height: 6),
            Text('Access your Smart Meter platform',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: c.textSecondary)),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: c.border),
          ),
          child: Row(children: [
            _iconBtn(isDark ? Icons.light_mode : Icons.dark_mode,
                pressed: isDark,
                key: const Key(ConnexionKeys.themeToggleBtn),
                tooltip: 'Toggle theme',
                onTap: () => ref.read(themeProvider.notifier).toggle(),
                c: c),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Change language',
              child: InkWell(
                key: const Key(ConnexionKeys.languageBtn),
                onTap: () => _showSnack('Language selection (coming soon)'),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.border, width: .9),
                  ),
                  alignment: Alignment.center,
                  child: Text('EN',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: c.textSecondary,
                          letterSpacing: .5)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _iconBtn(Icons.help_outline,
                key: const Key(ConnexionKeys.helpBtn),
                tooltip: 'Documentation',
                onTap: () => _showSnack('Open docs (placeholder)'),
                c: c),
          ]),
        )
      ]),
    );
  }

  Widget _iconBtn(IconData icon,
      {required _Palette c,
      Key? key,
      bool pressed = false,
      required VoidCallback onTap,
      String? tooltip}) {
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: pressed ? c.accent : c.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: pressed ? c.accent : c.border, width: .9),
      ),
      alignment: Alignment.center,
      child:
          Icon(icon, size: 22, color: pressed ? Colors.white : c.textSecondary),
    );
    final btn = InkWell(
        key: key,
        onTap: onTap, borderRadius: BorderRadius.circular(14), child: child);
    return tooltip != null ? Tooltip(message: tooltip, child: btn) : btn;
  }

  Widget _privacyBox(_Palette c) {
    return Container(
      decoration: BoxDecoration(
        color: c.privacyBg,
        border: Border.all(color: c.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('About Viewer',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: .5,
                color: c.privacyTitle)),
        const SizedBox(height: 8),
        Text(
          'Sagemcom\nV1.0.0\nThe Viewer is provided "as is" and SAGEMCOM makes no warranty, including but not limited to any implied warranty of merchantability or fitness for any particular purpose or non infringement or of any third party intellectual property rights.\nThe User undertakes not to unlock, copy, decompile, modify, reverse engineer, disassemble or otherwise translate in whole or in part the Viewer nor permit any person or entity under its control to do so.\nCopyright © 2026 SAGEMCOM - All rights reserved',
          style: TextStyle(fontSize: 12, height: 1.45, color: c.privacyText),
        )
      ]),
    );
  }

  Widget _formFields(bool wide) {
    final row = wide
        ? Row(children: [
            Expanded(child: _fieldUser()),
            const SizedBox(width: 22),
            Expanded(child: _fieldPassword())
          ])
        : Column(children: [
            _fieldUser(),
            const SizedBox(height: 16),
            _fieldPassword()
          ]);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [row]);
  }

  Widget _inputFocusContainer({required bool focused, required Widget child}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: DesignTokens.primary600.withOpacity(.18),
                  blurRadius: 14,
                  offset: const Offset(0, 0),
                ),
              ]
            : const [],
      ),
      child: child,
    );
  }

  Widget _fieldUser() {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _LabelRow(icon: Icons.person, label: 'Username'),
      const SizedBox(height: 8),
      _inputFocusContainer(
        focused: _usernameFocus.hasFocus,
        child: TextFormField(
          key: const Key(ConnexionKeys.usernameField),
          focusNode: _usernameFocus,
          controller: _usernameCtrl,
          style:
              TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration:
              DesignTokens.inputDecoration(hint: 'Enter username').copyWith(
            fillColor: isDark ? const Color(0xFF1e3a5f) : DesignTokens.surface,
            hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF64748B) : DesignTokens.gray600),
          ),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          textInputAction: TextInputAction.next,
        ),
      )
    ]);
  }

  Widget _fieldPassword() {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _LabelRow(icon: Icons.lock, label: 'Password'),
      const SizedBox(height: 8),
      _inputFocusContainer(
        focused: _passwordFocus.hasFocus,
        child: TextFormField(
          key: const Key(ConnexionKeys.passwordField),
          focusNode: _passwordFocus,
          controller: _passwordCtrl,
          obscureText: !_showPassword,
          style:
              TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
          decoration: DesignTokens.inputDecoration(
              hint: 'Enter password',
              suffix: IconButton(
                key: const Key(ConnexionKeys.passwordVisibilityBtn),
                icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                    color: isDark ? Colors.white70 : DesignTokens.gray800),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              )).copyWith(
            fillColor: isDark ? const Color(0xFF1e3a5f) : DesignTokens.surface,
            hintStyle: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF64748B) : DesignTokens.gray600),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      )
    ]);
  }

  Widget _signInButton(_Palette c) {
    final startColor = _signInHover
        ? Color.lerp(c.primary, Colors.white, .1) ?? c.primary
        : c.primary;
    final endColor = _signInHover
        ? Color.lerp(c.accent, Colors.white, .12) ?? c.accent
        : c.accent;
    final scale =
        _signInPressed ? .98 : (_signInHover && !_loading ? 1.01 : 1.0);
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: MouseRegion(
        onEnter: (_) => setState(() => _signInHover = true),
        onExit: (_) => setState(() {
          _signInHover = false;
          _signInPressed = false;
        }),
        child: GestureDetector(
          onTapDown:
              _loading ? null : (_) => setState(() => _signInPressed = true),
          onTapUp:
              _loading ? null : (_) => setState(() => _signInPressed = false),
          onTapCancel: () => setState(() => _signInPressed = false),
          child: AnimatedScale(
            duration: Duration(milliseconds: _signInPressed ? 100 : 180),
            scale: scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [startColor, endColor]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(_signInHover ? .2 : .15),
                      blurRadius: _signInHover ? 11 : 8,
                      offset: const Offset(0, 4))
                ],
              ),
              child: ElevatedButton(
                key: const Key(ConnexionKeys.signinBtn),
                onPressed: _loading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_open, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Sign In',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white))
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _messages() {
    return Column(children: [
      if (_error != null)
        _alertBox(_error!, const [Color(0xFFfee2e2), Color(0xFFfecaca)],
            const Color(0xFFef4444), const Color(0xFFdc2626), Icons.error),
      if (_success != null)
        _alertBox(
            _success!,
            const [Color(0xFFdcfce7), Color(0xFFbbf7d0)],
            const Color(0xFF22c55e),
            const Color(0xFF059669),
            Icons.check_circle),
    ]);
  }

  Widget _alertBox(
      String msg, List<Color> gradient, Color border, Color fg, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Icon(icon, color: fg),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: TextStyle(color: fg)))
      ]),
    );
  }

  Widget _secondaryActions(_Palette c) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration:
          BoxDecoration(border: Border(top: BorderSide(color: c.border))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        InkWell(
            onTap: () => setState(() => _remember = !_remember),
            child: Row(children: [
              Checkbox(
                  key: const Key(ConnexionKeys.rememberChk),
                  value: _remember,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                  activeColor: c.accent),
              const SizedBox(width: 4),
              Text('Remember me',
                  style: TextStyle(fontSize: 13, color: c.textSecondary))
            ])),
        TextButton(
            key: const Key(ConnexionKeys.changePasswordBtn),
          onPressed: _openChangePasswordModal,
            child: Text('Change Password',
                style: TextStyle(
                    color: c.accent,
                    decoration: TextDecoration.underline,
                    fontSize: 12)))
      ]),
    );
  }

  Widget _collapsibleInfo(_Palette c) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextButton(
          onPressed: () => setState(() => _showInfo = !_showInfo),
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          child: Text(_showInfo ? 'Less info ▲' : 'More info ▼',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: c.accent))),
      AnimatedCrossFade(
        firstChild: const SizedBox.shrink(),
        secondChild: Padding(
            padding: const EdgeInsets.only(top: 6), child: _warningBox(c)),
        crossFadeState:
            _showInfo ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 400),
      )
    ]);
  }

  Widget _inlineLinks(_Palette c) {
    TextStyle link = TextStyle(
        color: c.accent, fontSize: 12, decoration: TextDecoration.underline);
    return Wrap(
        spacing: 14,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('Version: 1.0.0',
              style: TextStyle(fontSize: 12, color: c.textSecondary)),
          GestureDetector(
              onTap: () => _showSnack('Release notes placeholder'),
              child: Text('Release Notes', style: link)),
          GestureDetector(
              onTap: () => _showSnack('Privacy policy placeholder'),
              child: Text('Privacy', style: link)),
          GestureDetector(
              onTap: () => _showSnack('Support placeholder'),
              child: Text('Support', style: link)),
        ]);
  }

  Widget _licenseSection(_Palette c) {
    final bg1 = c.dark ? const Color(0xFF1a2d45) : const Color(0xFFf1f7fe);
    final bg2 = c.dark ? const Color(0xFF1e3555) : const Color(0xFFe4eef7);
    final brd = c.dark ? const Color(0xFF2d4a6a) : const Color(0xFFdbe3ee);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bg1, bg2]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: brd),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.description, size: 20, color: c.textPrimary),
          const SizedBox(width: 10),
          Text('License Management',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary))
        ]),
        const SizedBox(height: 10),
        Text(
            'Import a license provided by your administrator to activate modules.',
            style:
                TextStyle(fontSize: 13, color: c.textSecondary, height: 1.45)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              key: const Key(ConnexionKeys.importLicenseBtn),
              onPressed: _importLicense,
              style: OutlinedButton.styleFrom(
                foregroundColor: c.dark ? Colors.white : c.accent,
                side: BorderSide(color: c.dark ? Colors.white : c.accent),
              ),
              icon: const Icon(Icons.upload_file),
              label: const Text('Import')),
        )
      ]),
    );
  }

  Widget _warningBox(_Palette c) {
    final bg1 = c.dark ? const Color(0xFF2d2000) : const Color(0xFFFFF8E6);
    final bg2 = c.dark ? const Color(0xFF3d2d00) : const Color(0xFFFDECC5);
    final brd = c.dark ? const Color(0xFF78350f) : const Color(0xFFF59E0B);
    final titleColor =
        c.dark ? const Color(0xFFFCD34D) : const Color(0xFF92400e);
    final bodyColor =
        c.dark ? const Color(0xFFFBBF24) : const Color(0xFFa16207);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [bg1, bg2]),
        border: Border.all(color: brd),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.warning, color: Color(0xFFD97706), size: 24),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Password Policy',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                  fontSize: 14)),
          const SizedBox(height: 5),
          Text('Use uppercase letters, numbers & symbols. Change it regularly.',
              style: TextStyle(fontSize: 12, color: bodyColor, height: 1.35)),
        ])),
      ]),
    );
  }

  Widget _buildLoadingOverlay(_Palette c) {
    return Positioned.fill(
      child: Container(
        color: c.surface.withOpacity(.92),
        alignment: Alignment.center,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: c.accent),
          const SizedBox(height: 16),
          Text(
            'Authenticating...',
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildChangePasswordModal(_Palette c) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {
          _usernameFocus.unfocus();
          setState(() => _showModal = false);
        },
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Material(
              color: c.surface,
              elevation: 30,
              borderRadius: BorderRadius.circular(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 26, 30, 30),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Icon(Icons.lock, color: c.textPrimary),
                      const SizedBox(width: 12),
                      Text('Change Password',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: c.textPrimary)),
                      const Spacer(),
                      IconButton(
                          key: const Key(ConnexionKeys.changePwdCloseBtn),
                          onPressed: () {
                            _usernameFocus.unfocus();
                            setState(() => _showModal = false);
                          },
                          icon: Icon(Icons.close, color: c.textSecondary))
                    ]),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_licenses.length > 1) ...[
                          const SizedBox(height: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _LabelRow(icon: Icons.vpn_key, label: 'License'),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<LicenseInfo>(
                                value: _selectedLicense,
                                decoration: DesignTokens.inputDecoration(hint: 'Select license'),
                                items: _licenses.map((lic) {
                                  return DropdownMenuItem<LicenseInfo>(
                                    value: lic,
                                    child: Text(lic.label),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLicense = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        const _LabelRow(icon: Icons.person, label: 'Username'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _changeUsernameCtrl,
                          decoration: DesignTokens.inputDecoration(
                              hint: 'Enter username'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _modalField('Old Password', _oldPwCtrl, false),
                    const SizedBox(height: 20),
                    _modalField('New Password', _newPwCtrl, true),
                    const SizedBox(height: 12),
                    _PasswordStrengthPanel(controller: _newPwCtrl),
                    const SizedBox(height: 20),
                    if (_changePwdError != null)
                      _alertBox(
                          _changePwdError!,
                          const [Color(0xFFfee2e2), Color(0xFFfecaca)],
                          const Color(0xFFef4444),
                          const Color(0xFFdc2626),
                          Icons.error),
                    if (_changePwdError != null) const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          key: const Key(ConnexionKeys.changePwdOkBtn),
                          onPressed: _handleChangePassword,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: c.primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: const Text('OK',
                              style: TextStyle(color: Colors.white))),
                    )
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modalField(
      String label, TextEditingController ctrl, bool newPassword) {
    final visible = ValueNotifier<bool>(false);
    return ValueListenableBuilder<bool>(
      valueListenable: visible,
      builder: (ctx, show, _) {
        final onSurface = Theme.of(ctx).colorScheme.onSurface;
        final onSurfaceVariant = Theme.of(ctx).colorScheme.onSurfaceVariant;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500, color: onSurface)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            obscureText: !show,
            onChanged: newPassword ? (v) {} : null,
            decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: IconButton(
                  icon: Icon(show ? Icons.visibility_off : Icons.visibility,
                      color: onSurfaceVariant),
                  onPressed: () => visible.value = !show),
            ),
          )
        ]);
      },
    );
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    await Future.delayed(const Duration(seconds: 2));
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text;

    try {
      final response = await client.connexion(u, p);
      if (response.success) {
        if (_remember) {
          await _credentialStorage.setRememberMe(true);
          await _credentialStorage.saveCredentials(u, p);
        } else {
          await _credentialStorage.clearCredentials();
        }
        userRights.role = response.role;
        userRights.rights = List<String>.from(response.rights);
        userRights.disableFeatures =
            List<String>.from(response.disableFeatures);
        userRights.excludeRights = List<String>.from(response.excludeRights);
        userRights.enterprise = response.enterprise;
        userRights.trialPeriodStart = response.trialPeriodStart;
        userRights.trialPeriodEnd = response.trialPeriodEnd;
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/meter_connexion');
        }
      } else {
        setState(() => _error = response.message);
        _shakeController.forward(from: 0);
      }
    } catch (e) {
      setState(() => _error = _extractErrorMessage(e));
      _shakeController.forward(from: 0);
    }
    setState(() => _loading = false);
  }

  void _handleChangePassword() async {
    final oldPw = _oldPwCtrl.text;
    final newPw = _newPwCtrl.text;
    final username = _changeUsernameCtrl.text.trim();
    if (oldPw.isEmpty || newPw.isEmpty || username.isEmpty) {
      setState(() {
        _changePwdError = 'Please fill the required fields.';
      });
      return;
    }
    if (newPw.length < 8) {
      setState(() {
        _changePwdError = 'New password must be at least 8 characters.';
      });
      return;
    }
    if (_isWeak(newPw)) {
      setState(() {
        _changePwdError = 'Password is too weak.';
      });
      return;
    }
    if (_selectedLicense == null){
      setState(() {
        _changePwdError = 'Please select a license.';
      });
      return;
    }
    setState(() {
      _loading = true;
      _changePwdError = null;
      _success = null;
    });
    try {
      print( _selectedLicense!.file);
      final response = await client.changePassword(username, oldPw, newPw, _selectedLicense!.file);
      if (response.success) {
        _usernameFocus.unfocus();
        setState(() {
          _loading = false;
          _success = 'Password updated successfully.';
          _showModal = false;
        });
        _oldPwCtrl.clear();
        _newPwCtrl.clear();
      } else {
        setState(() {
          _loading = false;
          _changePwdError = response.message;
        });
        return;
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _changePwdError = _extractErrorMessage(e);
      });
      return;
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) return msg;
      return e.toString();
    }
    final raw = e.toString();
    return raw.replaceFirst('Exception: ', '');
  }

  bool _isWeak(String pw) {
    final patterns = [
      RegExp(r'^(password|123456|qwerty|admin|login|user)',
          caseSensitive: false),
      RegExp(r'^(.)\1{3,}')
    ];
    return pw.length < 6 || patterns.any((r) => r.hasMatch(pw));
  }

  void _importLicense() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(allowMultiple: false);
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _loading = true;
        });
        final path = result.files.single.path!;
        await client.importLicense(path);
        setState(() {
          _loading = false;
          _licensePath = path;
          _success =
              'License file "${result.files.first.name}" imported successfully!';
        });
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _success = null);
        });
        await _checkLicense();
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to import license file: ${_extractErrorMessage(e)}';
      });
      Future.delayed(const Duration(seconds: 5), () {
          if (mounted) setState(() => _error = null);
        });
    }
  }

  void _showSnack(String msg) {
    feedback.info(msg);
  }

  


}

// ── Palette locale adaptée à l'écran pour light/dark ─────────────────────────
class _Palette {
  final bool dark;
  final Color primary;
  final Color accent;
  final Color brandMid;
  final Color brandDeep;
  final Color bgStart;
  final Color bgMid;
  final Color bgEnd;
  final Color surface;
  final Color background;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color privacyBg;
  final Color privacyTitle;
  final Color privacyText;
  _Palette._(
      this.dark,
      this.primary,
      this.accent,
      this.brandMid,
      this.brandDeep,
      this.bgStart,
      this.bgMid,
      this.bgEnd,
      this.surface,
      this.background,
      this.border,
      this.textPrimary,
      this.textSecondary,
      this.privacyBg,
      this.privacyTitle,
      this.privacyText);
  factory _Palette.of({required bool dark}) {
    if (dark) {
      return _Palette._(
        true,
        const Color(0xFF335FC6),
        const Color(0xFF60A5FA), // accent: brighter for WCAG AA on dark bg
        const Color(0xFF2B5AB7),
        const Color(0xFF23499A),
        const Color(0xFF1E3760),
        const Color(0xFF274873),
        const Color(0xFF305A8D),
        const Color(0xFF1e293b),
        const Color(0xFF0f172a),
        const Color(0xFF334155),
        const Color(0xFFF1F5F9),
        const Color(0xFF94A3B8),
        const Color(
            0xFF263548), // privacyBg: +1 luminosity vs surface for contrast
        const Color(0xFF60A5FA), // privacyTitle: light blue readable on dark bg
        const Color(0xFFCBD5E1), // privacyText: light gray readable on dark bg
      );
    }
    return _Palette._(
      false,
      const Color(0xFF2E67CC),
      const Color(0xFF4C8EF6),
      const Color(0xFF3D79D8),
      const Color(0xFF2F62BA),
      const Color(0xFF5A8FE3),
      const Color(0xFF75A5EE),
      const Color(0xFF97C0F8),
      Colors.white,
      const Color(0xFFF4F8FF),
      const Color(0xFFdbe3ee),
      const Color(0xFF11243d),
      const Color(0xFF5b6b7c),
      const Color(0xFFE0F2FF),
      const Color(0xFF2563eb), // privacyTitle: vivid blue on light bg
      const Color(0xFF5b6b7c), // privacyText: medium gray on light bg
    );
  }
}

class _LabelRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _LabelRow({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 8),
      Text(label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: color))
    ]);
  }
}

class _LicenseStatusBadge extends StatelessWidget {
  final bool exists;
  final String identifier;
  final String licensePath;
  final VoidCallback? onDeletePressed;
  const _LicenseStatusBadge(
      {required this.exists, required this.identifier, this.licensePath = '',this.onDeletePressed,});


  

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF14532d) : const Color(0xFFdcfce7);
    final bdColor = isDark ? const Color(0xFF16a34a) : const Color(0xFF22c55e);
    final iconColor =
        isDark ? const Color(0xFF4ade80) : const Color(0xFF16a34a);
    final titleColor =
        isDark ? const Color(0xFF86efac) : const Color(0xFF15803d);
    final idColor = isDark ? const Color(0xFF86efac) : const Color(0xFF065f46);

    if (!exists) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: bdColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.verified, size: 15, color: iconColor),
            const SizedBox(width: 6),
            Text('Application identifier',
                style: TextStyle(
                    fontSize: 12,
                    color: titleColor,
                    fontWeight: FontWeight.w700)),
          ]),
          if (identifier.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                child: SelectableText(
                  identifier,
                  style: TextStyle(
                      fontSize: 12,
                      color: idColor,
                      fontFamily: 'monospace',
                      letterSpacing: .5),
                ),
              ),
              const SizedBox(width: 4),
              Tooltip(
                message: 'Copy identifier',
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: identifier));
                    feedback.info('Identifier copied');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.copy, size: 15, color: iconColor),
                  ),
                ),
              ),
            ]),
          ],
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: bdColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.verified, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text('License imported',
              style: TextStyle(
                  fontSize: 12,
                  color: titleColor,
                  fontWeight: FontWeight.w700)),
          
          const Spacer(),

              // ✅ Delete button
              IconButton(
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                onPressed: this.onDeletePressed,
              )

        ]),
        if (licensePath.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.folder_open, size: 13, color: idColor),
            const SizedBox(width: 4),
            Expanded(
              child: SelectableText(
                licensePath,
                style: TextStyle(
                    fontSize: 11,
                    color: idColor,
                    fontFamily: 'monospace',
                    letterSpacing: .4),
              ),
            ),
          ]),
        ],
      ]),
    );
  }
}

class _PasswordStrengthPanel extends StatefulWidget {
  final TextEditingController controller;
  const _PasswordStrengthPanel({required this.controller});

  @override
  State<_PasswordStrengthPanel> createState() => _PasswordStrengthPanelState();
}

class _PasswordStrengthPanelState extends State<_PasswordStrengthPanel> {
  String _pw = '';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() => _pw = widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  bool get _hasMinLen => _pw.length >= 8;
  bool get _hasUpper => _pw.contains(RegExp(r'[A-Z]'));
  bool get _hasLower => _pw.contains(RegExp(r'[a-z]'));
  bool get _hasDigit => _pw.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial =>
      _pw.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_=+\[\\\];]'));

  int get _score => [_hasMinLen, _hasUpper, _hasLower, _hasDigit, _hasSpecial]
      .where((c) => c)
      .length;

  Color get _barColor {
    if (_score <= 1) return Colors.red;
    if (_score == 2) return Colors.orange;
    if (_score == 3) return Colors.amber;
    if (_score == 4) return Colors.lightGreen;
    return Colors.green;
  }

  String get _strengthLabel {
    if (_score <= 1) return 'Very weak';
    if (_score == 2) return 'Weak';
    if (_score == 3) return 'Fair';
    if (_score == 4) return 'Strong';
    return 'Very strong';
  }

  @override
  Widget build(BuildContext context) {
    if (_pw.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _score / 5.0,
                  backgroundColor: const Color(0xFFE0E0E0),
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _strengthLabel,
              style: TextStyle(
                  fontSize: 12, color: _barColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _criterion('At least 8 characters', _hasMinLen),
        _criterion('Uppercase letter (A–Z)', _hasUpper),
        _criterion('Lowercase letter (a–z)', _hasLower),
        _criterion('Number (0–9)', _hasDigit),
        _criterion('Special character (!@#…)', _hasSpecial),
      ],
    );
  }

  Widget _criterion(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: met ? Colors.green : const Color(0xFFBDBDBD),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: met ? Colors.green.shade700 : const Color(0xFF9E9E9E),
            ),
          ),
        ],
      ),
    );
  }
}
