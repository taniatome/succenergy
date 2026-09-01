import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/mock/country_data.dart';
import '../../../data/models/country.dart';
import '../../../data/models/user.dart';
import 'activity_selector.dart';
import 'country_picker_sheet.dart';
import 'dob_picker_sheet.dart';
import 'selector_field.dart';

/// Date of birth, country and activity, in the order the form asks for them.
///
/// The three fields that open sheets or hold a choice rather than take typing,
/// grouped so the registration screen stays a form and not a pile of pickers.
class RegisterIdentityFields extends StatelessWidget {
  const RegisterIdentityFields({
    required this.dateOfBirth,
    required this.countryCode,
    required this.activity,
    required this.onDateOfBirthChanged,
    required this.onCountryChanged,
    required this.onActivityChanged,
    this.dobError,
    this.countryError,
    super.key,
  });

  final DateTime? dateOfBirth;
  final String? countryCode;
  final UserActivity activity;

  final ValueChanged<DateTime> onDateOfBirthChanged;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<UserActivity> onActivityChanged;

  final String? dobError;
  final String? countryError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SelectorField(
          label: context.tr('auth.field.dob'),
          placeholder: context.tr('auth.dob.placeholder'),
          value:
              dateOfBirth == null
                  ? null
                  : DateFormat.yMMMMd(context.localeCode).format(dateOfBirth!),
          errorText: dobError,
          onTap: () => _pickDob(context),
        ),
        const SizedBox(height: AppSpacing.md),
        SelectorField(
          label: context.tr('auth.field.country'),
          placeholder: context.tr('auth.country.placeholder'),
          value: CountryData.byCode(countryCode)?.nameFor(context.localeCode),
          errorText: countryError,
          onTap: () => _pickCountry(context),
        ),
        const SizedBox(height: AppSpacing.md),
        ActivitySelector(value: activity, onChanged: onActivityChanged),
      ],
    );
  }

  Future<void> _pickDob(BuildContext context) async {
    final DateTime? chosen = await DobPickerSheet.show(
      context: context,
      initial: dateOfBirth,
    );
    if (chosen != null) {
      onDateOfBirthChanged(chosen);
    }
  }

  Future<void> _pickCountry(BuildContext context) async {
    final Country? chosen = await CountryPickerSheet.show(context);
    if (chosen != null) {
      onCountryChanged(chosen.code);
    }
  }
}
