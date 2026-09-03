import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/text_link_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../auth_validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/password_field.dart';
import '../widgets/step_indicator.dart';
import 'registration_draft.dart';

/// Registration, step one: the credential.
///
/// Nothing is created here. The three fields are checked and kept on the
/// draft, and the Firebase account is not opened until the user has agreed to
/// the terms at step three — signing someone up before they consent, and
/// deleting the account if they back out, is the worse trade.
///
/// The confirmation field stays out of the way until there is a password to
/// confirm: asking someone to repeat a value they have not chosen yet is two
/// empty boxes where one would do.
class Step1AccountScreen extends StatefulWidget {
  const Step1AccountScreen({super.key});

  @override
  State<Step1AccountScreen> createState() => _Step1AccountScreenState();
}

class _Step1AccountScreenState extends State<Step1AccountScreen> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _confirm;

  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  /// Set once the password field has been left, which is what turns the
  /// confirmation field's live check on.
  bool _passwordSettled = false;

  @override
  void initState() {
    super.initState();
    final RegistrationDraft draft = context.read<RegistrationDraft>();
    _email = TextEditingController(text: draft.email);
    _password = TextEditingController(text: draft.password);
    _confirm = TextEditingController(text: draft.password);

    // An address claimed between here and step three is reported on the field
    // that owns it, which is this one.
    final String? key = draft.accountErrorKey;
    _emailError = key == null ? null : context.trRead(key);
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _isComplete =>
      _email.text.trim().isNotEmpty &&
      _password.text.isNotEmpty &&
      _confirm.text.isNotEmpty;

  void _continue() {
    final RegistrationDraft draft = context.read<RegistrationDraft>();
    setState(() {
      _emailError = _resolve(AuthValidators.email(_email.text));
      _passwordError = _resolve(AuthValidators.newPassword(_password.text));
      _confirmError = _resolve(
        AuthValidators.confirmPassword(_password.text, _confirm.text),
      );
    });
    if (_emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }

    draft.setAccount(email: _email.text.trim(), password: _password.text);
    context.push(Routes.registerAbout);
  }

  /// The confirmation field is the one place a check runs as the user types,
  /// and only once the password above it has been left. Immediate feedback
  /// there saves retyping both.
  void _onConfirmChanged() {
    setState(() {
      if (_passwordSettled) {
        _confirmError = _resolve(
          AuthValidators.confirmPassword(_password.text, _confirm.text),
        );
      }
    });
  }

  void _onPasswordChanged() {
    setState(() {
      if (_passwordError != null &&
          AuthValidators.newPassword(_password.text) == null) {
        _passwordError = null;
      }
      if (_passwordSettled && _confirm.text.isNotEmpty) {
        _confirmError = _resolve(
          AuthValidators.confirmPassword(_password.text, _confirm.text),
        );
      }
    });
  }

  void _onEmailChanged() {
    context.read<RegistrationDraft>().clearAccountError();
    setState(() {
      if (_emailError != null && AuthValidators.email(_email.text) == null) {
        _emailError = null;
      }
    });
  }

  String? _resolve(String? key) => key == null ? null : context.trRead(key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      indicator: const StepIndicator(current: 1),
      eyebrow: context.tr('auth.register.eyebrow'),
      title: context.tr('auth.register.step1.title'),
      subtitle: context.tr('auth.register.step1.subtitle'),
      onBack: () => context.go(Routes.quiz),
      children: _fields(context),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      AppTextField(
        controller: _email,
        label: context.tr('auth.field.email'),
        hint: context.tr('auth.hint.email'),
        errorText: _emailError,
        isValid: AuthValidators.email(_email.text) == null,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const <String>[AutofillHints.newUsername],
        onChanged: (_) => _onEmailChanged(),
      ),
      const SizedBox(height: AppSpacing.md),
      PasswordField(
        controller: _password,
        label: context.tr('auth.field.password'),
        hint: context.tr('auth.hint.newPassword'),
        errorText: _passwordError,
        isValid:
            _password.text.isNotEmpty &&
            AuthValidators.newPassword(_password.text) == null,
        textInputAction: TextInputAction.next,
        autofillHints: const <String>[AutofillHints.newPassword],
        onChanged: (_) => _onPasswordChanged(),
        onFocusLost: () => setState(() => _passwordSettled = true),
      ),
      if (_password.text.isNotEmpty) ...<Widget>[
        const SizedBox(height: AppSpacing.md),
        PasswordField(
          controller: _confirm,
          label: context.tr('auth.field.confirmPassword'),
          errorText: _confirmError,
          isValid:
              _passwordSettled &&
              _confirm.text.isNotEmpty &&
              _confirm.text == _password.text,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.newPassword],
          onChanged: (_) => _onConfirmChanged(),
          onSubmitted: (_) => _continue(),
        ),
      ],
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('common.continue'),
        onPressed: _isComplete ? _continue : null,
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
