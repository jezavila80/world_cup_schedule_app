import 'package:flutter/material.dart';

class AppInfo {
  final String appName;
  final String version;
  final String buildNumber;
  final String versionLabel;

  AppInfo({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.versionLabel,
  });
}

class AppInfoScope extends InheritedWidget {
  final AppInfo appInfo;

  const AppInfoScope({
    super.key,
    required this.appInfo,
    required super.child,
  });

  static AppInfo? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppInfoScope>()?.appInfo;
  }

  static AppInfo of(BuildContext context) {
    final AppInfoScope? result = context.dependOnInheritedWidgetOfExactType<AppInfoScope>();
    return result?.appInfo ?? AppInfo(
      appName: 'World Cup Schedule App',
      version: 'Unknown',
      buildNumber: '',
      versionLabel: 'vUnknown',
    );
  }

  @override
  bool updateShouldNotify(AppInfoScope oldWidget) => appInfo != oldWidget.appInfo;
}
