import 'package:flutter/material.dart';
import 'package:golf_kakis/app/app_language.dart';

import '../viewmodel/profile_language_view_contract.dart';

class ProfileLanguageView extends StatelessWidget {
  const ProfileLanguageView({
    required this.state,
    required this.onUserIntent,
    super.key,
  });

  final ProfileLanguageViewState state;
  final ValueChanged<ProfileLanguageUserIntent> onUserIntent;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: AppLanguage.values
          .map(
            (language) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _LanguageOptionCard(
                title: language.label,
                subtitle: _subtitleFor(language),
                isSelected: state.selectedLanguage == language,
                onTap: () => onUserIntent(OnProfileLanguageSelected(language)),
              ),
            ),
          )
          .toList(),
    );
  }

  String _subtitleFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.english:
        return 'Default app language';
      case AppLanguage.bahasaMelayu:
        return 'Bahasa Melayu';
      case AppLanguage.chinese:
        return '中文';
    }
  }
}

class _LanguageOptionCard extends StatelessWidget {
  const _LanguageOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : Colors.black.withValues(alpha: 0.08);
    final backgroundColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF111827),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected
                    ? theme.colorScheme.primary
                    : const Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
