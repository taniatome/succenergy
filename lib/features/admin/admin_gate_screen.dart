import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';

/// The gate in front of the management console.
///
/// Mock only: it checks a fixed code so the console can be demonstrated
/// without standing up an authorisation layer.
class AdminGateScreen extends StatefulWidget {
  const AdminGateScreen({super.key});

  @override
  State<AdminGateScreen> createState() => _AdminGateScreenState();
}

class _AdminGateScreenState extends State<AdminGateScreen> {
  final TextEditingController _code = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final bool valid =
        _code.text.trim().toUpperCase() == AppConstants.adminAccessCode;
    if (!valid) {
      setState(() => _error = context.tr('admin.gate.error'));
      return;
    }
    context.go(Routes.adminConsole);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    AnimatedReveal(
                      index: 0,
                      child: SectionEyebrow(
                        label: context.tr('admin.gate.eyebrow'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AnimatedReveal(
                      index: 1,
                      child: Text(
                        context.tr('admin.gate.title'),
                        style: AppTypography.displayMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AnimatedReveal(
                      index: 2,
                      child: Text(
                        context.tr('admin.gate.body'),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AnimatedReveal(
                      index: 3,
                      child: AppTextField(
                        controller: _code,
                        label: context.tr('admin.gate.field'),
                        hint: AppConstants.adminAccessCode,
                        errorText: _error,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AnimatedReveal(
                      index: 4,
                      child: PrimaryButton(
                        label: context.tr('admin.gate.action'),
                        onPressed: _submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
