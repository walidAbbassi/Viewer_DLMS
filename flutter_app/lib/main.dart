import 'package:flutter/material.dart';
import 'core/tracing/tracing.dart';
import 'platform/python_launcher.dart';
import 'grpc/client.dart';               // your gRPC client (unchanged)
import 'grpc/generated/echo.pb.dart';    // generated
import 'grpc/generated/echo.pbgrpc.dart';
import 'grpc/admin_client.dart';
import 'app.dart';
import 'package:provider/provider.dart';
import 'features/services/auth_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider, Provider, Consumer, ConsumerWidget; // hide collisions;
import 'features/pages/configuration_page.dart' show registerConfigurationPage;
import 'features/pages/load_profile_page.dart' show registerAllLoadProfilePages;
import 'features/pages/event_logs_page.dart' show registerAllEventLogsPages;
import 'features/pages/device_id_page.dart' show registerDeviceIdPage;
import 'features/pages/firmware_version_page.dart' show registerFirmwareVersionPage;
import 'features/pages/date_time_page.dart' show registerDateTimePage;
import 'features/pages/load_profile_status_page.dart' show registerAllLoadProfileStatusPages;
import 'features/pages/energy_register_page.dart' show registerEnergyRegisterPage;
import 'features/pages/fresnel_diagram_page.dart' show registerFresnelPage;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TracingService.init();
  await windowManager.ensureInitialized();

  const WindowOptions windowOptions = WindowOptions(
    skipTaskbar: false,
    title: 'Viewer NG',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitle('Viewer NG');
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });

  // ---- Export registry ----
  registerConfigurationPage();
  registerDeviceIdPage();
  registerFirmwareVersionPage();
  registerDateTimePage();
  await registerAllLoadProfilePages();
  await registerAllLoadProfileStatusPages();
  await registerAllEventLogsPages();
  registerEnergyRegisterPage();
  registerFresnelPage();
  // add more registerXxxPage() calls here as you create new exportable pages

  PythonLauncher.instance.start(port: 50051);
  // Intercept the close button (X)
  await windowManager.setPreventClose(true);
  // Start the server EXE on desktop; wait until it’s ready.
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: ProviderScope(child:const SmartMeterApp()),
    ),
  );
}

