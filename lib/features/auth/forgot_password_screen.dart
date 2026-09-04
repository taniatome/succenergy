import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../data/repositories/auth_failure.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_failure_copy.dart';
import 'auth_validators.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/envelope_bloom.dart';

/// Password reset.
///
/// Two states on one screen rather than two screens, so the confirmation
/// resolves in place instead of the flow moving somewhere and having to come
/// back.
///
/// The confirmation is shown for any address that is well formed, whether or
/// not an account exists for it. Saying "no account for that email" would turn
/// this screen into a way of asking whether someone is a customer, which is
/// exactly what it must not be. The copy is worded to match: it says what was
/// sent *if* an account exists, and never confirms that one does.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({required this.initialEmail, super.key});

  /// Carried over from sign-in when an address was already typed there.
  final String initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  String? _emailError;
  bool _busy = false;

  /// The address the confirmation is about, held so editing the field
  /// afterwards cannot change what the confirmation says.
  String? _sentTo;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    final String? invalid = AuthValidators.email(_email.text);
    setState(
      () => _emailError = invalid == null ? null : context.trRead(invalid),
    );
    if (invalid != null) {
      return;
    }

    final AuthRepository repository = context.read<AuthRepository>();
    final String email = _email.text.trim();
    setState(() => _busy = true);

    try {
      await repository.sendPasswordReset(email);
    } on AuthException catch (error) {
      // An unknown address is not reported: the confirmation is the same
      // either way. Only a failure the user can act on — no connection, too
      // many attempts — is worth showing.
      if (_isWorthReporting(error.reason)) {
        _report(error.reason);
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }

    if (mounted) {
      setState(() => _sentTo = email);
    }
  }

  static bool _isWorthReporting(AuthFailure reason) =>
      reason == AuthFailure.network ||
      reason == AuthFailure.tooManyRequests ||
      reason == AuthFailure.unavailable;

  void _report(AuthFailure reason) {
    if (mounted) {
      setState(
        () => _emailError = context.trRead(AuthFailureCopy.keyFor(reason)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? sentTo = _sentTo;

    return AuthScaffold(
      eyebrow: context.tr('auth.action.forgot'),
      title: context.tr(
        sentTo == null ? 'auth.forgot.title' : 'auth.forgot.sentTitle',
      ),
      subtitle: context.tr(
        sentTo == null ? 'auth.forgot.subtitle' : 'auth.forgot.spam',
      ),
      onBack: _busy ? null : () => context.pop(),
      children:
          sentTo == null ? _requestState(context) : _sentState(context, sentTo),
    );
  }

  List<Widget> _requestState(BuildContext context) {
    return <Widget>[
      AppTextField(
        controller: _email,
        label: context.tr('auth.field.email'),
        hint: context.tr('auth.hint.email'),
        errorText: _emailError,
        enabled: !_busy,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        autofillHints: const <String>[AutofillHints.username],
        onChanged: (_) => setState(() => _emailError = null),
        onSubmitted: (_) => _submit(),
      ),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('auth.forgot.action'),
        isBusy: _busy,
        onPressed: _email.text.trim().isEmpty ? null : _submit,
      ),
      const SizedBox(height: AppSpacing.xxs),
      Center(
        child: TextLinkButton(
          label: context.tr('auth.forgot.backToLogin'),
          onPressed: _busy ? null : () => context.pop(),
        ),
      ),
    ];
  }

  List<Widget> _sentState(BuildContext context, String email) {
    return <Widget>[
      const Center(child: EnvelopeBloom()),
      const SizedBox(height: AppSpacing.md),
      Text(
        context.tr(
          'auth.forgot.sentBody',
          params: <String, String>{'email': email},
        ),
        textAlign: TextAlign.center,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('auth.forgot.backToLogin'),
        onPressed: () => context.pop(),
      ),
    ];
  }
}
