import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loader.dart';

/// The veil drawn over the sign-in form while a biometric unlock resolves.
///
/// Biometric sign-in starts on its own as the screen opens, so without this
/// the form would sit there looking as though it were waiting for typing. It
/// fades rather than appears, because a flash of scrim on a screen that has
/// only just arrived reads as a fault.
class SigningInOverlay extends StatelessWidget {
  const SigningInOverlay({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: AppDurations.fast,
        child: ColoredBox(
          color: AppColors.scrim,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const AppLoader(size: 48),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.tr('auth.login.signingIn'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
