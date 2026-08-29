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

/// Account creation. A successful registration continues into the seven
/// onboarding questions.
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

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
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
    if (_nameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmError != null) {
      return;
    }
    setState(() => _busy = true);
    await context.read<AuthRepository>().register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    context.go(Routes.onboarding);
  }

  void _validate() {
    final String email = _email.text.trim();
    _nameError =
        _name.text.trim().isEmpty
            ? context.tr('auth.error.nameRequired')
            : null;
    _emailError =
        email.isEmpty
            ? context.tr('auth.error.emailRequired')
            : (!email.contains('@') || !email.contains('.'))
            ? context.tr('auth.error.emailInvalid')
            : null;
    _passwordError =
        _password.text.isEmpty
            ? context.tr('auth.error.passwordRequired')
            : _password.text.length < AppConstants.minPasswordLength
            ? context.tr('auth.error.passwordShort')
            : null;
    _confirmError =
        _confirm.text == _password.text
            ? null
            : context.tr('auth.error.passwordMatch');
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: context.tr('auth.register.eyebrow'),
      title: context.tr('auth.register.title'),
      subtitle: context.tr('auth.register.subtitle'),
      onBack: () => context.go(Routes.language),
      children: <Widget>[
        AppTextField(
          controller: _name,
          label: context.tr('auth.field.name'),
          hint: 'Marisa Chissano',
          errorText: _nameError,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
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
      ],
    );
  }
}
