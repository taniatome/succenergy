import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// The dense counter strip across the top of the management console.
///
/// Deliberately more utilitarian than the user app: tighter padding, no
/// bloom, hairline dividers.
class AdminStatStrip extends StatelessWidget {
  const AdminStatStrip({required this.stats, super.key});

  /// Localisation key to already-formatted value.
  final Map<String, String> stats;

  @override
  Widget build(BuildContext context) {
    final List<String> keys = stats.keys.toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyElevated.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(
          color: AppColors.hairline,
          width: AppBorders.hairline,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < keys.length; i++) ...<Widget>[
            if (i > 0)
              Container(
                width: AppBorders.hairline,
                height: 28,
                color: AppColors.hairline,
              ),
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    stats[keys[i]] ?? '',
                    style: AppTypography.metricValueSmall.copyWith(
                      fontSize: 15,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr(keys[i]),
                    style: AppTypography.metricLabel.copyWith(fontSize: 7.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
