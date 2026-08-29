import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Log in for a returning account. Any well-formed input succeeds and lands
/// on the Dashboard.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _emailError = _validateEmail(_email.text);
      _passwordError = _validatePassword(_password.text);
    });
    if (_emailError != null || _passwordError != null) {
      return;
    }
    setState(() => _busy = true);
    await context.read<AuthRepository>().logIn(
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    context.go(Routes.dashboard);
  }

  String? _validateEmail(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return context.tr('auth.error.emailRequired');
    }
    if (!trimmed.contains('@') || !trimmed.contains('.')) {
      return context.tr('auth.error.emailInvalid');
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) {
      return context.tr('auth.error.passwordRequired');
    }
    if (value.length < AppConstants.minPasswordLength) {
      return context.tr('auth.error.passwordShort');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: context.tr('auth.login.eyebrow'),
      title: context.tr('auth.login.title'),
      subtitle: context.tr('auth.login.subtitle'),
      onBack: () => context.go(Routes.welcome),
      children: <Widget>[
        AppTextField(
          controller: _email,
          label: context.tr('auth.field.email'),
          hint: 'marisa.chissano@lumeconsult.co.mz',
          errorText: _emailError,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _password,
          label: context.tr('auth.field.password'),
          errorText: _passwordError,
          obscure: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerRight,
          child: TextLinkButton(
            label: context.tr('auth.action.forgot'),
            onPressed: () => context.push(Routes.forgotPassword),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        PrimaryButton(
          label: context.tr('auth.action.login'),
          isBusy: _busy,
          onPressed: _submit,
        ),
        const SizedBox(height: AppSpacing.xs),
        Center(
          child: TextLinkButton(
            label: context.tr('auth.toRegister'),
            onPressed: () => context.go(Routes.register),
          ),
        ),
      ],
    );
  }
}
