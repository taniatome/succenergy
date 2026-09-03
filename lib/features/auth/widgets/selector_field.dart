import 'package:flutter/widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/icons/app_icon.dart';
import '../../../core/widgets/inputs/inline_field_error.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// A field that opens a sheet instead of taking typing.
///
/// Carries the same eyebrow, fill, radius and hairline as [AppTextField], so
/// date of birth and country sit in the registration form as fields rather
/// than as buttons that happen to be in a form.
class SelectorField extends StatelessWidget {
  const SelectorField({
    required this.label,
    required this.placeholder,
    required this.onTap,
    this.value,
    this.errorText,
    super.key,
  });

  final String label;

  /// Shown when nothing has been chosen yet.
  final String placeholder;

  /// The chosen value, already formatted for display.
  final String? value;

  final String? errorText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null;
    final bool chosen = value != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: label),
        const SizedBox(height: AppSpacing.xs),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.navyDeep.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(
                color: hasError ? AppColors.error : AppColors.hairline,
                width: AppBorders.hairline,
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    chosen ? value! : placeholder,
                    style:
                        chosen
                            ? AppTypography.bodyLarge
                            : AppTypography.bodyMedium.copyWith(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.7,
                              ),
                            ),
                  ),
                ),
                AppIcon(
                  mark: AppIconMark.chevronDown,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        InlineFieldError(message: errorText),
      ],
    );
  }
}
