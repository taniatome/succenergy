import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_reveal.dart';
import '../../../core/widgets/branding/succenergy_logo.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The shared frame for log in, registration and password reset.
///
/// Keeps the three screens visually identical above the fold so moving
/// between them feels like one flow rather than three pages.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  /// Form fields and actions, revealed in sequence beneath the heading.
  final List<Widget> children;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.95),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenH,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (onBack != null) _backRow(),
                    const AnimatedReveal(
                      index: 0,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SuccenergyLogo(size: 56),
                      ),
                    ),
                    AnimatedReveal(
                      index: 1,
                      child: SectionEyebrow(label: eyebrow),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AnimatedReveal(
                      index: 2,
                      child: Text(title, style: AppTypography.displayMedium),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AnimatedReveal(
                      index: 3,
                      child: Text(
                        subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    for (int i = 0; i < children.length; i++)
                      AnimatedReveal(index: 4 + i, child: children[i]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _backRow() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: onBack,
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
