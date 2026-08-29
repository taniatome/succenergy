import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// The action a goal's overflow menu resolved to.
enum GoalMenuAction { edit, delete }

/// The edit and delete affordance carried by a goal, on the card and on Goal
/// Detail.
///
/// Both entry points open the same menu, so the two surfaces never disagree
/// about what can be done to a goal. Delete takes the single error hue.
class GoalOverflowMenu extends StatelessWidget {
  const GoalOverflowMenu({required this.onSelected, super.key});

  final ValueChanged<GoalMenuAction> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GoalMenuAction>(
      onSelected: onSelected,
      tooltip: context.tr('goals.menu.tooltip'),
      padding: EdgeInsets.zero,
      splashRadius: 18,
      icon: const Icon(
        Icons.more_horiz_rounded,
        size: 18,
        color: AppColors.textSecondary,
      ),
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<GoalMenuAction>>[
            _item(
              context,
              value: GoalMenuAction.edit,
              label: context.tr('common.edit'),
              icon: Icons.edit_outlined,
              color: AppColors.textPrimary,
            ),
            _item(
              context,
              value: GoalMenuAction.delete,
              label: context.tr('common.delete'),
              icon: Icons.delete_outline_rounded,
              color: AppColors.error,
            ),
          ],
    );
  }

  PopupMenuItem<GoalMenuAction> _item(
    BuildContext context, {
    required GoalMenuAction value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return PopupMenuItem<GoalMenuAction>(
      value: value,
      height: 44,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 17, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(label, style: AppTypography.bodyMedium.copyWith(color: color)),
        ],
      ),
    );
  }
}
