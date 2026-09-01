import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/mock/country_data.dart';
import '../../../data/models/country.dart';

/// The country selector: the full list, filtered as the user types.
///
/// A sheet rather than a dropdown, because two hundred entries in a menu is
/// not a list anyone can read. Names are matched in both languages, so
/// searching "Moza" finds Moçambique with Portuguese selected.
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet._();

  /// Opens the selector and resolves to the chosen country, or null if
  /// dismissed.
  static Future<Country?> show(BuildContext context) {
    return showModalBottomSheet<Country>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => const CountryPickerSheet._(),
    );
  }

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<Country> _matches(String localeCode) {
    final String term = _query.text.trim().toLowerCase();
    final List<Country> all = CountryData.sortedFor(localeCode);
    if (term.isEmpty) {
      return all;
    }
    return all
        .where(
          (Country c) =>
              c.en.toLowerCase().contains(term) ||
              c.pt.toLowerCase().contains(term),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final String locale = context.localeCode;
    final List<Country> matches = _matches(locale);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SectionEyebrow(
                label: context.tr('auth.field.country'),
                withRule: true,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _query,
                hint: context.tr('auth.country.search'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(child: _list(context, matches, locale)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<Country> matches, String locale) {
    if (matches.isEmpty) {
      return Center(
        child: Text(
          context.tr('auth.country.empty'),
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      itemCount: matches.length,
      separatorBuilder:
          (BuildContext context, int index) =>
              Container(height: AppBorders.hairline, color: AppColors.hairline),
      itemBuilder: (BuildContext context, int index) {
        final Country country = matches[index];
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).pop(country),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    country.nameFor(locale),
                    style: AppTypography.bodyLarge,
                  ),
                ),
                Text(country.code, style: AppTypography.metricLabel),
              ],
            ),
          ),
        );
      },
    );
  }
}
