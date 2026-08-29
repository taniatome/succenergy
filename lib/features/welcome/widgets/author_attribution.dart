import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// The authorship block: "by Dr. Leadership Tânia Tomé" over a gold rule with
/// OFFICIAL beneath, exactly as specified in the brand handoff.
class AuthorAttribution extends StatelessWidget {
  const AuthorAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              context.tr('welcome.by'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gold,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                context.tr('welcome.author'),
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _rule(reversed: false),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                context.tr('welcome.official'),
                style: AppTypography.eyebrow.copyWith(color: AppColors.gold),
              ),
            ),
            _rule(reversed: true),
          ],
        ),
      ],
    );
  }

  Widget _rule({required bool reversed}) {
    final List<Color> colors = <Color>[
      AppColors.transparent,
      AppColors.gold.withValues(alpha: 0.55),
    ];
    return Container(
      width: 44,
      height: AppBorders.hairline,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: reversed ? colors.reversed.toList() : colors,
        ),
      ),
    );
  }
}
