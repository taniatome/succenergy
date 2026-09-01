import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/cards/glow_card.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../data/repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Password reset request. Resolves into a confirmation panel rather than
/// leaving the screen, so the flow stays in one place.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _email = TextEditingController();
  String? _emailError;
  bool _busy = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final String email = _email.text.trim();
    setState(() {
      _emailError =
          email.isEmpty
              ? context.trRead('auth.error.emailRequired')
              : (!email.contains('@') || !email.contains('.'))
              ? context.trRead('auth.error.emailInvalid')
              : null;
    });
    if (_emailError != null) {
      return;
    }
    setState(() => _busy = true);
    await context.read<AuthRepository>().sendPasswordReset(email);
    if (!mounted) {
      return;
    }
    setState(() {
      _busy = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      eyebrow: context.tr('auth.action.forgot'),
      title: context.tr('auth.forgot.title'),
      subtitle: context.tr('auth.forgot.subtitle'),
      onBack: () => context.pop(),
      children: _sent ? _confirmation(context) : _form(context),
    );
  }

  List<Widget> _form(BuildContext context) {
    return <Widget>[
      AppTextField(
        controller: _email,
        label: context.tr('auth.field.email'),
        hint: context.tr('auth.hint.email'),
        errorText: _emailError,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr('auth.forgot.action'),
        isBusy: _busy,
        onPressed: _submit,
      ),
    ];
  }

  List<Widget> _confirmation(BuildContext context) {
    return <Widget>[
      GlowCard(
        accent: GlowAccent.gold,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.mark_email_read_outlined,
              color: AppColors.gold,
              size: 26,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr('auth.forgot.sentTitle'),
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr('auth.forgot.sentBody'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      Center(
        child: TextLinkButton(
          label: context.tr('auth.forgot.backToLogin'),
          onPressed: () => context.pop(),
        ),
      ),
    ];
  }
}
