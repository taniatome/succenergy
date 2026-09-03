import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/inputs/inline_field_error.dart';
import '../../../data/mock/country_data.dart';
import '../../../data/models/country.dart';
import '../../../data/models/user.dart';
import '../auth_validators.dart';
import '../widgets/activity_selector_card.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/country_picker_sheet.dart';
import '../widgets/dob_picker_sheet.dart';
import '../widgets/selector_field.dart';
import '../widgets/step_indicator.dart';
import 'registration_draft.dart';

/// Registration, step two: who the person is.
///
/// Date of birth and country open sheets rather than dropdowns — three wheels
/// on the app's own navy for the date, and the full country list filtered as
/// you type, because two hundred entries in a menu is not a list anyone can
/// read. Activity is two cards rather than a toggle, because it is the answer
/// that sets the monthly rate and deserves the room to say so.
class Step2AboutYouScreen extends StatefulWidget {
  const Step2AboutYouScreen({super.key});

  @override
  State<Step2AboutYouScreen> createState() => _Step2AboutYouScreenState();
}

class _Step2AboutYouScreenState extends State<Step2AboutYouScreen> {
  late final TextEditingController _name;

  String? _nameError;
  String? _dobError;
  String? _countryError;
  String? _activityError;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<RegistrationDraft>().name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _continue() {
    final RegistrationDraft draft = context.read<RegistrationDraft>();
    setState(() {
      _nameError = _resolve(AuthValidators.name(_name.text));
      _dobError = _resolve(AuthValidators.dateOfBirth(draft.dateOfBirth));
      _countryError = _resolve(AuthValidators.country(draft.countryCode));
      _activityError =
          draft.activity == null
              ? context.trRead('auth.error.activityRequired')
              : null;
    });
    if (_nameError != null ||
        _dobError != null ||
        _countryError != null ||
        _activityError != null) {
      return;
    }

    draft.setAboutYou(
      name: _name.text.trim(),
      dateOfBirth: draft.dateOfBirth!,
      countryCode: draft.countryCode!,
      activity: draft.activity!,
    );
    context.push(Routes.registerConsent);
  }

  String? _resolve(String? key) => key == null ? null : context.trRead(key);

  Future<void> _pickDateOfBirth(RegistrationDraft draft) async {
    final DateTime? chosen = await DobPickerSheet.show(
      context: context,
      initial: draft.dateOfBirth,
    );
    if (chosen == null || !mounted) {
      return;
    }
    draft.setDateOfBirth(chosen);
    setState(() => _dobError = null);
  }

  Future<void> _pickCountry(RegistrationDraft draft) async {
    final Country? chosen = await CountryPickerSheet.show(context);
    if (chosen == null || !mounted) {
      return;
    }
    draft.setCountry(chosen.code);
    setState(() => _countryError = null);
  }

  @override
  Widget build(BuildContext context) {
    final RegistrationDraft draft = context.watch<RegistrationDraft>();

    return AuthScaffold(
      indicator: const StepIndicator(current: 2),
      eyebrow: context.tr('auth.register.eyebrow'),
      title: context.tr('auth.register.step2.title'),
      subtitle: context.tr('auth.register.step2.subtitle'),
      // A draft with no credential was entered here by the router, so there is
      // no step one behind this one to go back to.
      onBack: draft.hasAccount ? () => context.pop() : null,
      children: _fields(context, draft),
    );
  }

  List<Widget> _fields(BuildContext context, RegistrationDraft draft) {
    return <Widget>[
      AppTextField(
        controller: _name,
        label: context.tr('auth.field.name'),
        hint: context.tr('auth.hint.name'),
        errorText: _nameError,
        isValid: AuthValidators.name(_name.text) == null,
        textInputAction: TextInputAction.done,
        autofillHints: const <String>[AutofillHints.name],
        onChanged: (_) => setState(() => _nameError = null),
      ),
      const SizedBox(height: AppSpacing.md),
      SelectorField(
        label: context.tr('auth.field.dob'),
        placeholder: context.tr('auth.dob.placeholder'),
        value: _formattedDate(draft.dateOfBirth),
        errorText: _dobError,
        onTap: () => _pickDateOfBirth(draft),
      ),
      const SizedBox(height: AppSpacing.md),
      SelectorField(
        label: context.tr('auth.field.country'),
        placeholder: context.tr('auth.country.placeholder'),
        value: CountryData.byCode(
          draft.countryCode,
        )?.nameFor(context.localeCode),
        errorText: _countryError,
        onTap: () => _pickCountry(draft),
      ),
      const SizedBox(height: AppSpacing.md),
      ActivitySelectorCard(
        value: draft.activity,
        onChanged: (UserActivity value) {
          draft.setActivity(value);
          setState(() => _activityError = null);
        },
      ),
      // The activity cards have no field of their own to hang a message
      // under, so the error sits below the pair.
      InlineFieldError(message: _activityError),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('common.continue'),
        onPressed: _isComplete(draft) ? _continue : null,
      ),
    ];
  }

  bool _isComplete(RegistrationDraft draft) =>
      _name.text.trim().isNotEmpty &&
      draft.dateOfBirth != null &&
      draft.countryCode != null &&
      draft.activity != null;

  String? _formattedDate(DateTime? value) =>
      value == null
          ? null
          : DateFormat.yMMMMd(context.localeCode).format(value);
}
