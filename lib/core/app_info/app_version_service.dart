import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'app_info.dart';

class AppVersionService {
  final String? _mockVersion;
  final String? _mockBuildNumber;

  AppVersionService({String? mockVersion, String? mockBuildNumber})
      : _mockVersion = mockVersion,
        _mockBuildNumber = mockBuildNumber;

  String? _cachedVersion;
  String? _cachedBuildNumber;

  Future<void> initialize() async {
    if (_mockVersion != null && _mockBuildNumber != null) {
      _cachedVersion = _mockVersion;
      _cachedBuildNumber = _mockBuildNumber;
      return;
    }
    try {
      final info = await PackageInfo.fromPlatform();
      _cachedVersion = info.version;
      _cachedBuildNumber = info.buildNumber;
    } catch (e) {
      debugPrint('Failed to get package info: $e');
      _cachedVersion = 'Unknown';
      _cachedBuildNumber = '';
    }
  }

  Future<String> getVersion() async {
    if (_cachedVersion == null) {
      await initialize();
    }
    return _cachedVersion!;
  }

  Future<String> getBuildNumber() async {
    if (_cachedBuildNumber == null) {
      await initialize();
    }
    return _cachedBuildNumber!;
  }

  Future<String> getVersionLabel() async {
    final v = await getVersion();
    return 'v$v';
  }

  Future<String> getFullVersionLabel() async {
    final v = await getVersion();
    final b = await getBuildNumber();
    return b.isEmpty ? 'v$v' : 'v$v+$b';
  }

  AppInfo getAppInfoSync() {
    final v = _cachedVersion ?? 'Unknown';
    final b = _cachedBuildNumber ?? '';
    return AppInfo(
      appName: 'World Cup Schedule',
      version: v,
      buildNumber: b,
      versionLabel: 'v$v',
    );
  }
}
