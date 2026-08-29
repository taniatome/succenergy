import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// The approved tagline, with the two emphasised phrases in gold.
///
/// Copy is fixed by the brand handoff: "Activate your Energy and discover all
/// your success within you."
class WelcomeTagline extends StatelessWidget {
  const WelcomeTagline({super.key});

  @override
  Widget build(BuildContext context) {
    final TextStyle base = AppTypography.bodyLarge.copyWith(height: 1.5);
    final TextStyle accent = base.copyWith(
      color: AppColors.gold,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: <TextSpan>[
          TextSpan(text: context.tr('welcome.taglineLead')),
          TextSpan(text: context.tr('welcome.taglineEnergy'), style: accent),
          TextSpan(text: context.tr('welcome.taglineMid')),
          TextSpan(text: context.tr('welcome.taglineSuccess'), style: accent),
          TextSpan(text: context.tr('welcome.taglineEnd')),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
