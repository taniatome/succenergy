import 'package:flutter/material.dart';

import '../localization/string_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'buttons/primary_button.dart';
import 'buttons/text_link_button.dart';

/// The confirmation dialog for any action the user cannot take back.
///
/// Used by Settings for logging out and deleting an account, and by Goals for
/// deleting a goal. Destructive variants take the single error hue and state
/// plainly what is lost; the wording is not softened, because the action
/// cannot be undone.
class DestructiveConfirmDialog extends StatelessWidget {
  const DestructiveConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.isDestructive,
    super.key,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final bool isDestructive;

  /// Presents the dialog and resolves true when the user confirms.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String body,
    required String confirmLabel,
    required bool isDestructive,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) => DestructiveConfirmDialog(
            title: title,
            body: body,
            confirmLabel: confirmLabel,
            isDestructive: isDestructive,
          ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.navyElevated,
          borderRadius: BorderRadius.circular(AppRadii.cardLarge),
          border: Border.all(
            color:
                isDestructive
                    ? AppColors.error.withValues(alpha: 0.4)
                    : AppColors.hairline,
            width: AppBorders.hairline,
          ),
          boxShadow:
              isDestructive ? AppShadows.errorGlow : AppShadows.elevation,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isDestructive) ...<Widget>[
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            Text(title, style: AppTypography.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _confirmButton(context),
            Center(
              child: TextLinkButton(
                label: context.tr('common.cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton(BuildContext context) {
    if (!isDestructive) {
      return PrimaryButton(
        label: confirmLabel,
        onPressed: () => Navigator.of(context).pop(true),
      );
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(true),
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: AppColors.error,
            width: AppBorders.hairline,
          ),
        ),
        child: Text(
          confirmLabel,
          style: AppTypography.label.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
