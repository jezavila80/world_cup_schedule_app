import 'package:flutter/material.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../core/i18n/locale_helper.dart';
import '../../../../core/settings/app_language.dart';
import '../../../../core/settings/locale_controller.dart';
import '../../matches/data/match_repository.dart';
import '../../matches/data/flag_style_repository.dart';
import '../../tournament_engine/screens/tournament_validation_screen.dart';
import '../../../../core/widgets/world_cup_header.dart';

class SettingsScreen extends StatelessWidget {
  final LocaleController localeController;
  final MatchRepository matchRepository;
  final FlagStyleRepository flagStyleRepository;

  const SettingsScreen({
    super.key,
    required this.localeController,
    required this.matchRepository,
    required this.flagStyleRepository,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: localeController,
      builder: (context, _) {
        final lang = LocaleHelper.supportedLanguageCode(context);

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                WorldCupHeader(
                  title: AppTranslations.translate('settingsTitle', lang),
                  showVersion: true,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    children: [
                      // Language section title
                      Text(
                        AppTranslations.translate('languageSectionTitle', lang),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Card with radio options
                      Card(
                        child: Column(
                          children: [
                            RadioListTile<AppLanguage>(
                              value: AppLanguage.system,
                              groupValue: localeController.selectedLanguage,
                              title: Text(
                                AppTranslations.translate('system', lang),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                if (val != null) {
                                  localeController.changeLanguage(val);
                                }
                              },
                            ),
                            Divider(color: Colors.white.withOpacity(0.05), height: 1),
                            RadioListTile<AppLanguage>(
                              value: AppLanguage.spanish,
                              groupValue: localeController.selectedLanguage,
                              title: Text(
                                AppTranslations.translate('spanish', lang),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                if (val != null) {
                                  localeController.changeLanguage(val);
                                }
                              },
                            ),
                            Divider(color: Colors.white.withOpacity(0.05), height: 1),
                            RadioListTile<AppLanguage>(
                              value: AppLanguage.english,
                              groupValue: localeController.selectedLanguage,
                              title: Text(
                                AppTranslations.translate('english', lang),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              activeColor: theme.colorScheme.primary,
                              onChanged: (val) {
                                if (val != null) {
                                  localeController.changeLanguage(val);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Developer Section
                      Text(
                        (lang == 'es' ? 'VALIDACIÓN' : 'VALIDATION'),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.analytics_outlined, color: Colors.orangeAccent),
                          title: Text(
                            AppTranslations.translate('tournamentValidation', lang),
                            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TournamentValidationScreen(
                                  matchRepository: matchRepository,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
