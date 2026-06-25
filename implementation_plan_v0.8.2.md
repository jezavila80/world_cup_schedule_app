# Implementation Plan: Centralized App Branding & Version Management (v0.8.2)

Refactor the application to manage the app version, branding headers, and version badges from a single source of truth (`pubspec.yaml` using `package_info_plus`). Eliminate all hardcoded version strings and unify the layout structure across all pages using reusable UI components.

## User Review Required

> [!NOTE]
> `package_info_plus` will be added to `pubspec.yaml`. The app version in `pubspec.yaml` will be updated to `0.8.2+15`.

> [!IMPORTANT]
> The app version details will be initialized at startup in `main.dart` and cached in a new `AppInfo` model. This `AppInfo` will be shared down the widget tree using standard Flutter `InheritedWidget` (`AppInfoScope`), avoiding redundant asynchronous calls or `FutureBuilder` redraw jitter on screens.

---

## Proposed Changes

### Component: Version & Branding Infrastructure

#### [NEW] [app_info.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/app_info/app_info.dart)
A model holding application version details.
```dart
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
```

#### [NEW] [app_version_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/app_info/app_version_service.dart)
A service that interfaces with `package_info_plus` and caches results. It supports mock inputs for testing.
```dart
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
    if (_cachedVersion == null) await initialize();
    return _cachedVersion!;
  }

  Future<String> getBuildNumber() async {
    if (_cachedBuildNumber == null) await initialize();
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
```

#### [NEW] [app_branding.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/theme/app_branding.dart)
Central branding definitions to avoid magic numbers.
```dart
import 'package:flutter/material.dart';

class AppBranding {
  static const String appName = 'World Cup 2026 Schedule';
  static const String brandName = 'FIFA WORLD CUP';
  static const String primaryHeader = 'FIFA WORLD CUP';
  static const String applicationMotto = 'United as One';

  static const double defaultHeaderHeight = 80.0;
  static const double logoSize = 24.0;

  // Version Badge Style
  static const Color versionBadgeBgColor = Color(0xFF1E294B);
  static const Color versionBadgeBorderColor = Color(0xFF00FF87);
  static const Color versionBadgeTextColor = Color(0xFF00FF87);
  static const double versionBadgeBorderWidth = 0.8;
  static const double versionBadgeRadius = 8.0;

  // Spacing and Margins
  static const double standardSpacing = 8.0;
  static const double standardMargin = 16.0;
}
```

---

### Component: Shared UI Components

#### [NEW] [app_version_badge.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/widgets/app_version_badge.dart)
A pill-shaped widget displaying the cached version. Never throws and shows empty state placeholder if loading.

#### [NEW] [world_cup_header.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/widgets/world_cup_header.dart)
A reusable header displaying:
- `FIFA WORLD CUP` brand name (customizable).
- Dynamically embedded `AppVersionBadge`.
- Title and optional subtitle.
- Optional actions (e.g. settings buttons, filter triggers).
- Back button integration for nested screen sub-appbars.

---

### Component: Application Integration & Refactoring

#### [MODIFY] [pubspec.yaml](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/pubspec.yaml)
- Add `package_info_plus` to dependencies.
- Update version metadata to `0.8.2+15`.

#### [MODIFY] [README.md](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/README.md)
- Update roadmap/history sections to document `v0.8.2`.

#### [MODIFY] [main.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/main.dart)
- Pre-initialize `AppVersionService`.
- Expose `AppInfo` by passing it to `WorldCupApp`.

#### [MODIFY] [app.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/app.dart)
- Wrap root widget with `AppInfoScope` (an InheritedWidget).

#### [MODIFY] Screen Headers:
Replace hardcoded layouts and static strings with `WorldCupHeader`:
- **[match_list_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/matches/screens/match_list_screen.dart)**
- **[group_standings_dashboard_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/standings/screens/group_standings_dashboard_screen.dart)**
- **[knockout_dashboard_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/screens/knockout_dashboard_screen.dart)**
- **[settings_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/settings/screens/settings_screen.dart)**
- **[tournament_validation_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/screens/tournament_validation_screen.dart)**
  - Also append Developer Information card displaying App, Version, Build, Platform, Locale, Theme.
- **[about_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/matches/screens/about_screen.dart)**
  - Upgrade UI to show logo, centralized version label, build code, description, and feature list.

---

## Verification Plan

### Automated Tests

#### [NEW] [app_version_service_test.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/test/core/app_info/app_version_service_test.dart)
Unit tests covering:
- Correct retrieval of PackageInfo fields.
- Returning version string.
- Returning build number.
- Verified usage of cached values (no redundant reads).
- Gracious handling of platform exceptions (returning `'Unknown'`).

#### [NEW] [world_cup_header_test.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/test/core/widgets/world_cup_header_test.dart)
Widget tests covering:
- Renders `FIFA WORLD CUP` brand text.
- Renders version badge dynamically.
- Renders specified screen title.
- Renders without subtitle correctly.
- Renders without actions correctly.

### Manual Verification
1. Run `flutter test` to verify zero regression across the suite.
2. Run `flutter run` on the target device to test compile safety and verify consistent visual display of headers and badges.
