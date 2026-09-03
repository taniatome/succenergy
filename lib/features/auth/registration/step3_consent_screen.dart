import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/services/external_links.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_checkbox.dart';
import '../../../core/widgets/inputs/inline_field_error.dart';
import '../../../data/repositories/auth_failure.dart';
import '../../../data/repositories/auth_repository.dart';
import '../auth_failure_copy.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/step_indicator.dart';
import 'registration_draft.dart';
import 'widgets/registration_summary.dart';

/// Registration, step three: consent, and the one call that creates anything.
///
/// The two boxes are recorded separately because the API stores them
/// separately: accepting the terms and standing behind what you entered are
/// different commitments. Neither is pre-ticked, and the button stays disabled
/// until both are — visibly blocked rather than tapped and refused.
class Step3ConsentScreen extends StatefulWidget {
  const Step3ConsentScreen({super.key});

  @override
  State<Step3ConsentScreen> createState() => _Step3ConsentScreenState();
}

class _Step3ConsentScreenState extends State<Step3ConsentScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final RegistrationDraft draft = context.read<RegistrationDraft>();
    final AuthRepository repository = context.read<AuthRepository>();
    final AuthState session = context.read<AuthState>();
    final String language = context.read<LocaleProvider>().code;

    setState(() {
      _busy = true;
      _error = null;
    });

    // The credential and the profile are two writes, and between them
    // GET /v1/me answers 404. Holding the gate stops it sending this flow
    // back to step two while step three is still running.
    session.suspend();
    try {
      await _write(repository, draft, language);
    } on AuthException catch (error) {
      _onFailed(repository, draft, error.reason);
    } finally {
      await session.resume();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  /// Creates the account, or writes only the profile when the credential
  /// already exists — which is what a draft with no password means.
  Future<void> _write(
    AuthRepository repository,
    RegistrationDraft draft,
    String language,
  ) async {
    if (!draft.hasAccount) {
      await repository.completeProfile(
        name: draft.name,
        dateOfBirth: draft.dateOfBirth!,
        countryCode: draft.countryCode!,
        activity: draft.chosenActivity,
        preferredLanguage: language,
        acceptedTerms: draft.acceptedTerms,
        confirmedInfoTrue: draft.confirmedTruth,
      );
      return;
    }

    await repository.register(
      name: draft.name,
      email: draft.email,
      password: draft.password,
      dateOfBirth: draft.dateOfBirth!,
      countryCode: draft.countryCode!,
      activity: draft.chosenActivity,
      preferredLanguage: language,
      acceptedTerms: draft.acceptedTerms,
      confirmedInfoTrue: draft.confirmedTruth,
    );
    draft.markAccountCreated();
  }

  void _onFailed(
    AuthRepository repository,
    RegistrationDraft draft,
    AuthFailure reason,
  ) {
    if (!mounted) {
      return;
    }

    // The credential was created and only the profile write behind it failed.
    // Forgetting the password is what makes the retry write the profile
    // rather than try to create the account a second time.
    if (repository.isLoggedIn && draft.hasAccount) {
      draft.markAccountCreated();
    }

    // The address was free when it was typed at step one and taken by the
    // time it was submitted here. That belongs on the field that owns it.
    if (reason == AuthFailure.emailInUse) {
      draft.rejectAccount('auth.error.emailInUse');
      context.go(Routes.register);
      return;
    }

    setState(() => _error = context.trRead(AuthFailureCopy.keyFor(reason)));
  }

  @override
  Widget build(BuildContext context) {
    final RegistrationDraft draft = context.watch<RegistrationDraft>();

    return AuthScaffold(
      indicator: const StepIndicator(current: 3),
      eyebrow: context.tr('auth.register.eyebrow'),
      title: context.tr('auth.register.step3.title'),
      subtitle: context.tr('auth.register.step3.subtitle'),
      onBack: _busy ? null : () => context.pop(),
      children: _sections(context, draft),
    );
  }

  List<Widget> _sections(BuildContext context, RegistrationDraft draft) {
    return <Widget>[
      RegistrationSummary(activity: draft.chosenActivity),
      const SizedBox(height: AppSpacing.lg),
      AppCheckbox(
        value: draft.acceptedTerms,
        label: context.tr('auth.consent.terms'),
        linkLabel: context.tr('auth.consent.termsLink'),
        onLinkTap: () => ExternalLinks.open(AppConstants.placeholderTermsUrl),
        onChanged: (bool value) => draft.setConsent(terms: value),
      ),
      AppCheckbox(
        value: draft.confirmedTruth,
        label: context.tr('auth.consent.truth'),
        onChanged: (bool value) => draft.setConsent(truth: value),
      ),
      InlineFieldError(message: _error),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('auth.action.createAccount'),
        isBusy: _busy,
        onPressed: draft.hasConsent ? _submit : null,
      ),
    ];
  }
}
