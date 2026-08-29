import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// A titled group of settings rows.
///
/// The letterspaced eyebrow above each group is what keeps a long settings list
/// legible without dividers everywhere.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.title, required this.rows, super.key});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(label: title, withRule: true),
        const SizedBox(height: AppSpacing.sm),
        GlowCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < rows.length; i++) ...<Widget>[
                if (i > 0)
                  Container(
                    height: AppBorders.hairline,
                    color: AppColors.hairline,
                  ),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A single tappable settings row with an optional value and trailing widget.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.label,
    this.value,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    super.key,
  });

  final String label;

  /// Right-aligned current value, such as the active language.
  final String? value;

  /// Replaces the value and chevron, for switches.
  final Widget? trailing;

  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final Color labelColor =
        isDestructive ? AppColors.error : AppColors.textPrimary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodyLarge.copyWith(color: labelColor),
              ),
            ),
            if (trailing != null)
              trailing!
            else ...<Widget>[
              if (value != null) Text(value!, style: AppTypography.caption),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color:
                    isDestructive ? AppColors.error : AppColors.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
