import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Notifier updated by [appRouteObserver] whenever the active route changes.
final ValueNotifier<String?> currentRouteNotifier = ValueNotifier<String?>(null);

/// Global [RouteObserver] used to receive route lifecycle events.
/// Register it in [MaterialApp.navigatorObservers] and subscribe via
/// [RouteAware] in any [State] that needs to react to route changes.
final AppRouteObserver appRouteObserver = AppRouteObserver();

class AppRouteObserver extends RouteObserver<ModalRoute<void>> {
  void _update(Route<dynamic>? route) {
    final name = route?.settings.name;
    // Defer the notifier update so it never fires during a build phase.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      currentRouteNotifier.value = name;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _update(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _update(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _update(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _update(previousRoute);
    }
  }
}
