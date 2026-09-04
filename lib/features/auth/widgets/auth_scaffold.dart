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
/// Keeps every auth screen visually identical above the fold, so moving
/// between them feels like one flow rather than a handful of pages: the same
/// navy gradient, the same gold bloom behind the heading, the same staggered
/// reveal of whatever sits below it.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
    this.indicator,
    this.overlay,
    super.key,
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  /// Form fields and actions, revealed in sequence beneath the heading.
  final List<Widget> children;

  final VoidCallback? onBack;

  /// Sits above the heading. Registration puts its step indicator here so all
  /// three steps carry it in the same place.
  final Widget? indicator;

  /// Covers the whole screen. Sign-in puts the biometric veil here, so it sits
  /// over the form rather than inside the scroll view with it.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          overlay == null
              ? _content()
              : Stack(
                fit: StackFit.expand,
                children: <Widget>[_content(), overlay!],
              ),
    );
  }

  Widget _content() {
    return ScreenBackground(
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
                  if (indicator != null) ...<Widget>[
                    AnimatedReveal(index: 0, child: indicator!),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  const AnimatedReveal(
                    index: 1,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SuccenergyLogo(size: 56),
                    ),
                  ),
                  AnimatedReveal(
                    index: 2,
                    child: SectionEyebrow(label: eyebrow),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedReveal(
                    index: 3,
                    child: Text(title, style: AppTypography.displayMedium),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedReveal(
                    index: 4,
                    child: Text(
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  for (int i = 0; i < children.length; i++)
                    AnimatedReveal(index: 5 + i, child: children[i]),
                ],
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
