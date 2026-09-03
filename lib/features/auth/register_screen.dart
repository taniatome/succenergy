import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/consent_block.dart';
import 'widgets/register_identity_fields.dart';

/// Account creation. A successful registration continues to the trial screen
/// and, from there, into the four remaining onboarding questions.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  DateTime? _dob;
  String? _countryCode;
  UserActivity _activity = UserActivity.professional;
  bool _acceptedTerms = false;
  bool _confirmedTruth = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _dobError;
  String? _countryError;
  String? _consentError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(_validate);
    if (<String?>[
      _nameError,
      _emailError,
      _passwordError,
      _confirmError,
      _dobError,
      _countryError,
      _consentError,
    ].any((String? error) => error != null)) {
      return;
    }
    setState(() => _busy = true);
    await context.read<AuthRepository>().register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      dateOfBirth: _dob!,
      countryCode: _countryCode!,
      activity: _activity,
      preferredLanguage: context.read<LocaleProvider>().code,
      acceptedTerms: _acceptedTerms,
      confirmedInfoTrue: _confirmedTruth,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    context.go(Routes.trial);
  }

  void _validate() {
    final String email = _email.text.trim();
    _nameError =
        _name.text.trim().isEmpty
            ? context.trRead('auth.error.nameRequired')
            : null;
    _emailError =
        email.isEmpty
            ? context.trRead('auth.error.emailRequired')
            : (!email.contains('@') || !email.contains('.'))
            ? context.trRead('auth.error.emailInvalid')
            : null;
    _passwordError =
        _password.text.isEmpty
            ? context.trRead('auth.error.passwordRequired')
            : _password.text.length < AppConstants.minPasswordLength
            ? context.trRead('auth.error.passwordShort')
            : null;
    _confirmError =
        _confirm.text == _password.text
            ? null
            : context.trRead('auth.error.passwordMatch');
    _dobError =
        _dob == null
            ? context.trRead('auth.error.dobRequired')
            : _ageOn(_dob!) < AppConstants.minimumAgeYears
            ? context.trRead('auth.error.dobTooYoung')
            : null;
    _countryError =
        _countryCode == null
            ? context.trRead('auth.error.countryRequired')
            : null;
    _consentError =
        _acceptedTerms && _confirmedTruth
            ? null
            : context.trRead('auth.error.consentRequired');
  }

  /// Completed years between [dob] and today.
  int _ageOn(DateTime dob) {
    final DateTime now = DateTime.now();
    final bool beforeBirthday =
        now.month < dob.month || (now.month == dob.month && now.day < dob.day);
    return now.year - dob.year - (beforeBirthday ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: context.tr('auth.register.eyebrow'),
      title: context.tr('auth.register.title'),
      subtitle: context.tr('auth.register.subtitle'),
      onBack: () => context.go(Routes.quiz),
      children: _fields(context),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      AppTextField(
        controller: _name,
        label: context.tr('auth.field.name'),
        hint: context.tr('auth.hint.name'),
        errorText: _nameError,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _email,
        label: context.tr('auth.field.email'),
        hint: context.tr('auth.hint.email'),
        errorText: _emailError,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      RegisterIdentityFields(
        dateOfBirth: _dob,
        countryCode: _countryCode,
        activity: _activity,
        dobError: _dobError,
        countryError: _countryError,
        onDateOfBirthChanged:
            (DateTime value) => setState(() {
              _dob = value;
              _dobError = null;
            }),
        onCountryChanged:
            (String code) => setState(() {
              _countryCode = code;
              _countryError = null;
            }),
        onActivityChanged:
            (UserActivity value) => setState(() => _activity = value),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _password,
        label: context.tr('auth.field.password'),
        errorText: _passwordError,
        obscure: true,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _confirm,
        label: context.tr('auth.field.confirmPassword'),
        errorText: _confirmError,
        obscure: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      const SizedBox(height: AppSpacing.md),
      ConsentBlock(
        acceptedTerms: _acceptedTerms,
        confirmedTruth: _confirmedTruth,
        errorText: _consentError,
        onTermsChanged: (bool v) => setState(() => _acceptedTerms = v),
        onTruthChanged: (bool v) => setState(() => _confirmedTruth = v),
      ),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('auth.action.register'),
        isBusy: _busy,
        onPressed: _submit,
      ),
      const SizedBox(height: AppSpacing.xs),
      Center(
        child: TextLinkButton(
          label: context.tr('auth.toLogin'),
          onPressed: () => context.go(Routes.login),
        ),
      ),
    ];
  }
}
