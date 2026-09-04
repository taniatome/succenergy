import 'package:flutter/material.dart';

import '../../../core/auth/biometric_service.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/text_link_button.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The offer to enable biometric sign-in, made once after the first
/// successful password sign-in.
///
/// A sheet rather than a dialog: this is an offer, not a decision the app is
/// blocking on, and a sheet can be dismissed by dragging it away without
/// having to say no. Declining resolves the same as dismissing.
class BiometricBottomSheet extends StatelessWidget {
  const BiometricBottomSheet._({required this.kind});

  final BiometricKind kind;

  /// Shows the offer. Resolves true when the user accepts, and false when
  /// they decline or drag it away.
  static Future<bool> show({
    required BuildContext context,
    required BiometricKind kind,
  }) async {
    final bool? accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) => BiometricBottomSheet._(kind: kind),
    );
    return accepted ?? false;
  }

  /// Names the hardware where it is worth naming.
  String get _bodyKey {
    switch (kind) {
      case BiometricKind.face:
        return 'auth.biometric.bodyFace';
      case BiometricKind.fingerprint:
        return 'auth.biometric.bodyFingerprint';
      case BiometricKind.generic:
      case BiometricKind.none:
        return 'auth.biometric.bodyGeneric';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionEyebrow(
              label: context.tr('settings.section.security'),
              withRule: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.tr('auth.biometric.title'),
              style: AppTypography.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              context.tr(_bodyKey),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: context.tr('auth.biometric.enable'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Center(
              child: TextLinkButton(
                label: context.tr('auth.biometric.later'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
