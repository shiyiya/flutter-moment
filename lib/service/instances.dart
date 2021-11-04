import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:moment/service/event_bus.dart' as _e;

class Instances {
  static final EventBus eventBus = _e.eventBus;
  static final navigatorKey = GlobalKey<NavigatorState>();
  static AppLifecycleState appLifeCycleState = AppLifecycleState.resumed;

  static NavigatorState get navigatorState =>
      Instances.navigatorKey.currentState;

  static BuildContext get currentContext => navigatorState.context;

  static ThemeData get currentTheme => Theme.of(navigatorState.context);

  static Color get currentThemeColor => currentTheme.colorScheme.secondary;
}
