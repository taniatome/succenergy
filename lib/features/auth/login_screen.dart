import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/auth/auth_state.dart';
import '../../core/auth/biometric_service.dart';
import '../../core/auth/secure_session_store.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../data/repositories/auth_failure.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_failure_copy.dart';
import 'auth_validators.dart';
import 'biometric_sign_in.dart';
import 'widgets/auth_scaffold.dart';
import 'widgets/biometric_bottom_sheet.dart';
import 'widgets/password_field.dart';
import 'widgets/signing_in_overlay.dart';

/// Sign in for a returning account.
///
/// One screen, not stepped: there are two fields and nothing to break up.
/// Both sit in an [AutofillGroup] with the hints the OS password manager
/// needs, so a saved credential is offered rather than typed.
///
/// Where biometric sign-in has been enabled the prompt runs as the screen
/// opens rather than waiting for a tap on a button — the whole point is to not
/// have to do anything. Whatever happens to it, the form underneath stays
/// live: a cancelled or failed prompt leaves someone exactly where they would
/// have been.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _emailError;

  /// Both the validation message and the sign-in failure live here: they
  /// belong in the same place, and a failure never says which field was wrong.
  String? _passwordError;

  bool _busy = false;
  bool _unlocking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  BiometricSignIn get _biometric => BiometricSignIn(
    store: context.read<SecureSessionStore>(),
    service: context.read<BiometricService>(),
    repository: context.read<AuthRepository>(),
  );

  bool get _isComplete =>
      _email.text.trim().isNotEmpty && _password.text.isNotEmpty;

  /// Runs on open. A success signs in and the router moves the app; anything
  /// else leaves the form as it was, with nothing said about it.
  Future<void> _unlock() async {
    if (!mounted) {
      return;
    }
    final BiometricSignIn biometric = _biometric;
    final String reason = context.trRead('auth.biometric.reason');

    setState(() => _unlocking = true);
    await biometric.attempt(reason: reason);
    if (mounted) {
      setState(() => _unlocking = false);
    }
  }

  Future<void> _submit() async {
    if (_busy) {
      return;
    }
    setState(() {
      _emailError = _resolve(AuthValidators.email(_email.text));
      _passwordError = _resolve(
        AuthValidators.existingPassword(_password.text),
      );
    });
    if (_emailError != null || _passwordError != null) {
      return;
    }

    final AuthRepository repository = context.read<AuthRepository>();
    final AuthState session = context.read<AuthState>();
    final String email = _email.text.trim();
    final String password = _password.text;

    setState(() => _busy = true);

    // The offer to remember the credentials has to be made before the router
    // leaves this screen, so the gate is held until the sheet is done with.
    session.suspend();
    try {
      await repository.logIn(email: email, password: password);
      await _offerBiometric(email: email, password: password);
    } on AuthException catch (error) {
      _report(error.reason);
    } finally {
      await session.resume();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _offerBiometric({
    required String email,
    required String password,
  }) async {
    final BiometricSignIn biometric = _biometric;
    final BiometricKind? kind = await biometric.offerable();
    if (kind == null || !mounted) {
      return;
    }
    final bool accepted = await BiometricBottomSheet.show(
      context: context,
      kind: kind,
    );
    if (accepted) {
      await biometric.remember(email: email, password: password);
    }
  }

  void _report(AuthFailure reason) {
    if (!mounted) {
      return;
    }
    setState(
      () => _passwordError = context.trRead(AuthFailureCopy.keyFor(reason)),
    );
  }

  String? _resolve(String? key) => key == null ? null : context.trRead(key);

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: context.tr('auth.login.eyebrow'),
      title: context.tr('auth.login.title'),
      subtitle: context.tr('auth.login.subtitle'),
      onBack: _busy ? null : () => context.go(Routes.welcome),
      overlay: SigningInOverlay(visible: _unlocking),
      children: _fields(context),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      AutofillGroup(child: _credentials(context)),
      const SizedBox(height: AppSpacing.md),
      PrimaryButton(
        label: context.tr('auth.action.login'),
        isBusy: _busy,
        onPressed: _isComplete ? _submit : null,
      ),
      const SizedBox(height: AppSpacing.xxs),
      Center(
        child: TextLinkButton(
          label: context.tr('auth.login.toRegister'),
          emphasis: context.tr('auth.login.toRegisterLink'),
          onPressed: () => context.go(Routes.register),
        ),
      ),
    ];
  }

  Widget _credentials(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          controller: _email,
          label: context.tr('auth.field.email'),
          hint: context.tr('auth.hint.email'),
          errorText: _emailError,
          enabled: !_busy,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const <String>[
            AutofillHints.username,
            AutofillHints.email,
          ],
          onChanged: (_) => setState(() => _emailError = null),
        ),
        const SizedBox(height: AppSpacing.md),
        PasswordField(
          controller: _password,
          label: context.tr('auth.field.password'),
          errorText: _passwordError,
          enabled: !_busy,
          textInputAction: TextInputAction.done,
          autofillHints: const <String>[AutofillHints.password],
          onChanged: (_) => setState(() => _passwordError = null),
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextLinkButton(
            label: context.tr('auth.action.forgot'),
            // The address already typed here travels as a route extra rather
            // than in the path: an email has no business in a URL.
            onPressed:
                () => context.push(
                  Routes.forgotPassword,
                  extra: _email.text.trim(),
                ),
          ),
        ),
      ],
    );
  }
}
