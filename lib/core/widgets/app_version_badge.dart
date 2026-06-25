import 'package:flutter/material.dart';
import '../app_info/app_info.dart';
import '../theme/app_branding.dart';

class AppVersionBadge extends StatelessWidget {
  const AppVersionBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final appInfo = AppInfoScope.maybeOf(context);
    final label = appInfo?.versionLabel ?? 'vUnknown';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: AppBranding.versionBadgeBgColor,
        borderRadius: BorderRadius.circular(AppBranding.versionBadgeRadius),
        border: Border.all(
          color: AppBranding.versionBadgeBorderColor,
          width: AppBranding.versionBadgeBorderWidth,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppBranding.versionBadgeTextColor,
        ),
      ),
    );
  }
}
