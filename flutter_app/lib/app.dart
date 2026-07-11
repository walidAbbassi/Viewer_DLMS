import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'routes/app_routes.dart';
import 'platform/python_launcher.dart';
import 'package:window_manager/window_manager.dart';
import 'package:lottie/lottie.dart';
import 'core/widgets/app_scaffold_wrapper.dart';
import 'core/widgets/idle_timeout_wrapper.dart';
import 'core/navigation/app_route_observer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider, Provider, Consumer, ConsumerWidget;
import 'core/theme/theme_notifier.dart';

class SmartMeterApp extends ConsumerStatefulWidget {
  const SmartMeterApp({super.key});

  @override
  ConsumerState<SmartMeterApp> createState() => _SmartMeterAppState();
}

class _SmartMeterAppState extends ConsumerState<SmartMeterApp> {
  _WindowListener _listener = _WindowListener();
  @override
  void initState() {
    super.initState();
    windowManager.addListener(_listener);
  }

  @override
  void dispose() {
    windowManager.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: PythonLauncher.instance.ready,
        builder: (_, isReady, __) {
          if (isReady)
            return MaterialApp(
              navigatorKey: AppRoutes.navigatorKey,
              title: 'Smart Meter Application',
              debugShowCheckedModeBanner: false,
              themeMode: ref.watch(themeProvider),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1e40af),
                  brightness: Brightness.dark,
                  surface: const Color(0xFF1E293B),
                  onSurface: const Color(0xFFF1F5F9),
                ),
                useMaterial3: true,
                fontFamily: 'SegoeUI',
                scaffoldBackgroundColor: const Color(0xFF0F172A),

                // ── AppBar ────────────────────────────────────────────────────────────
                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Color(0xFF1e3a6e),
                  foregroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),

                // ── Elevated buttons ──────────────────────────────────────────────────
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // ── Input fields ──────────────────────────────────────────────────────
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: const Color(0xFF1E3A5F),
                  hintStyle:
                      const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF334155), width: 1.4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF334155), width: 1.4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF60A5FA), width: 2),
                  ),
                ),

                // ── Cards ─────────────────────────────────────────────────────────────
                cardTheme: CardThemeData(
                  elevation: 2,
                  color: const Color(0xFF1E293B),
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                // ── Divider ───────────────────────────────────────────────────────────
                dividerTheme: const DividerThemeData(color: Color(0xFF334155)),

                // ── CheckBox / Switch accent ──────────────────────────────────────────
                checkboxTheme: CheckboxThemeData(
                  fillColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? const Color(0xFF60A5FA)
                        : null,
                  ),
                ),
                switchTheme: SwitchThemeData(
                  thumbColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? const Color(0xFF60A5FA)
                        : null,
                  ),
                  trackColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? const Color(0xFF60A5FA).withOpacity(.4)
                        : null,
                  ),
                ),

                // ── Page transitions ─────────────────────────────────────────────────
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.windows: _FadePageTransitionsBuilder(),
                    TargetPlatform.linux: _FadePageTransitionsBuilder(),
                    TargetPlatform.macOS: _FadePageTransitionsBuilder(),
                    TargetPlatform.android: _FadePageTransitionsBuilder(),
                    TargetPlatform.iOS: _FadePageTransitionsBuilder(),
                  },
                ),

                // ── SnackBar ──────────────────────────────────────────────────────────
                // Floating globally so notifications always appear above dialogs,
                // bottom sheets and other overlays regardless of screen size.
                snackBarTheme: const SnackBarThemeData(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF1e40af),
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
                fontFamily: 'SegoeUI',

                // Custom theme configurations
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 2,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFe5e7eb), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFFe5e7eb), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: Color(0xFF3b82f6), width: 2),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                ),

                cardTheme: CardThemeData(
                  elevation: 4,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0)),

                checkboxTheme: CheckboxThemeData(
                  fillColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? const Color(0xFF1976D2)
                        : null,
                  ),
                ),
                switchTheme: SwitchThemeData(
                  thumbColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? const Color(0xFF1976D2)
                        : null,
                  ),
                  trackColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? const Color(0xFF1976D2).withOpacity(.4)
                        : null,
                  ),
                ),

                appBarTheme: const AppBarTheme(
                  elevation: 0,
                  backgroundColor: Color(0xFF1e40af),
                  foregroundColor: Colors.white,
                  systemOverlayStyle: SystemUiOverlayStyle.light,
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.windows: _FadePageTransitionsBuilder(),
                    TargetPlatform.linux: _FadePageTransitionsBuilder(),
                    TargetPlatform.macOS: _FadePageTransitionsBuilder(),
                    TargetPlatform.android: _FadePageTransitionsBuilder(),
                    TargetPlatform.iOS: _FadePageTransitionsBuilder(),
                  },
                ),

                // ── SnackBar ──────────────────────────────────────────────────────────
                // Floating globally so notifications always appear above dialogs,
                // bottom sheets and other overlays regardless of screen size.
                snackBarTheme: const SnackBarThemeData(
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  insetPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              builder: (context, child) {
                if (child == null) return const SizedBox.shrink();
                // Ajouter automatiquement la toolbar pour les autres pages
                return IdleTimeoutWrapper(
                    child: AppScaffoldWrapper(child: child));
              },

              // Routes
              initialRoute: AppRoutes.connexion,
              routes: AppRoutes.routes,
              onGenerateRoute: AppRoutes.onGenerateRoute,
              navigatorObservers: [appRouteObserver],
            );
          return const SplashScreen();
        });
  }
}

class _WindowListener with WindowListener {
  // coverage:ignore-start
  @override
  Future<void> onWindowClose() async {
    await _cleanup();
    print("closed server");
    await windowManager.setPreventClose(false);
    await windowManager.close(); // actually close
  }

  Future<void> _cleanup() async {
    // ✅ this runs when the app is closed
    print("closing server");

    // fallback kill if needed (rare, but safe)
    await PythonLauncher.instance.stop();
  }
  // coverage:ignore-end
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // minimal shell so we can render before MyApp
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          backgroundColor: const Color(0xFF0E1116),
          body: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: Lottie.asset('assets/animations/grid.json',
                  width: 200,
                  height: 200,
                  errorBuilder: (context, err, stack) => // coverage:ignore-line
                      const Text('Failed to load animation',
                          style: TextStyle(
                              color: Colors.white)) // coverage:ignore-line
                  ),
            ),
          )),
    );
  }
}

/// Simple 200 ms fade transition used for all page navigations.
class _FadePageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }
}
