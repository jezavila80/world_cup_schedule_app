import 'package:flutter/material.dart';
import '../theme/app_branding.dart';
import 'app_version_badge.dart';

class WorldCupHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showVersion;
  final bool showLogo;
  final bool? showBackButton;
  final VoidCallback? onBrandingTap;
  final List<Widget>? actions;

  const WorldCupHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showVersion = true,
    this.showLogo = false,
    this.showBackButton,
    this.onBrandingTap,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.canPop(context);
    final displayBackButton = showBackButton ?? canPop;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            theme.scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (displayBackButton) ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E294B).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF1E294B),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
              GestureDetector(
                onTap: onBrandingTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showLogo) ...[
                      const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFFFD700),
                        size: AppBranding.logoSize,
                      ),
                      const SizedBox(width: AppBranding.standardSpacing),
                    ],
                    Text(
                      AppBranding.brandName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    if (showVersion) ...[
                      const SizedBox(width: AppBranding.standardSpacing),
                      const AppVersionBadge(),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              if (actions != null) ...actions!,
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ],
      ),
    );
  }
}
