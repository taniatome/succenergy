import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// Four compact shortcuts to the areas the Dashboard does not itself hold.
///
/// Kept deliberately quiet: outline tiles, no bloom, so they support the ring
/// and today's action rather than compete with them.
class QuickAccessRow extends StatelessWidget {
  const QuickAccessRow({required this.items, super.key});

  /// Already-localised label, icon and destination for each shortcut.
  final List<QuickAccessItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppSpacing.xs),
          Expanded(child: _tile(items[i])),
        ],
      ],
    );
  }

  Widget _tile(QuickAccessItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.navyElevated.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: AppColors.hairline,
            width: AppBorders.hairline,
          ),
        ),
        child: Column(
          children: <Widget>[
            Icon(item.icon, size: 18, color: AppColors.gold),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// One shortcut in a [QuickAccessRow].
class QuickAccessItem {
  const QuickAccessItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
}
