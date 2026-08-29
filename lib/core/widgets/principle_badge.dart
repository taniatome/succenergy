import 'package:flutter/widgets.dart';

import '../../data/models/principle.dart';
import '../localization/string_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// The gold pill that tags content with the principle it belongs to.
///
/// Appears on goal cards, exercise cards and session rows. The principle
/// names stay in their canonical form in both languages.
class PrincipleBadge extends StatelessWidget {
  const PrincipleBadge({
    required this.principle,
    this.showPosition = false,
    super.key,
  });

  final Principle principle;

  /// Prefixes the badge with the principle's position in the cycle.
  final bool showPosition;

  @override
  Widget build(BuildContext context) {
    final String name = context.tr(principle.labelKey);
    final String label =
        showPosition
            ? '${principle.position.toString().padLeft(2, '0')}  $name'
            : name;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.24),
          width: AppBorders.hairline,
        ),
      ),
      child: Text(label.toUpperCase(), style: AppTypography.principleBadge),
    );
  }
}
