import 'package:flutter/material.dart';
import 'package:asian_mart_app/main.dart';
import 'package:asian_mart_app/core/l10n/app_localizations.dart';
import 'package:asian_mart_app/core/theme/app_theme.dart';

class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  static const _languages = [
    _LanguageOption(locale: Locale('ko'), name: '한국어', emoji: '🇰🇷'),
    _LanguageOption(locale: Locale('en'), name: 'English', emoji: '🇺🇸'),
    _LanguageOption(locale: Locale('th'), name: 'ภาษาไทย', emoji: '🇹🇭'),
    _LanguageOption(locale: Locale('vi'), name: 'Tiếng Việt', emoji: '🇻🇳'),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppTheme.textPrimary,
        scrolledUnderElevation: 0.5,
        title: Text(
          l10n.languageSettings,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              l10n.selectLanguage,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textTertiary,
                letterSpacing: 0.3,
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppTheme.surface,
              child: ListView.separated(
                itemCount: _languages.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1),
                ),
                itemBuilder: (context, index) {
                  final option = _languages[index];
                  final isSelected = currentLocale.languageCode ==
                      option.locale.languageCode;
                  return InkWell(
                    onTap: () {
                      AsiaMartApp.setLocale(context, option.locale);
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        children: [
                          Text(
                            option.emoji,
                            style: const TextStyle(fontSize: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? AppTheme.primary
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_rounded,
                              color: AppTheme.primary,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption({
    required this.locale,
    required this.name,
    required this.emoji,
  });

  final Locale locale;
  final String name;
  final String emoji;
}
