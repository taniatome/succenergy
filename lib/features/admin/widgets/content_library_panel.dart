import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/exercise.dart';

/// The exercise library as the management console sees it: title, principle
/// and publication state, in a dense table.
class ContentLibraryPanel extends StatelessWidget {
  const ContentLibraryPanel({required this.exercises, super.key});

  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    final String locale = context.localeCode;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      itemCount: exercises.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SectionEyebrow(
              label: context.tr('admin.content.exercises'),
              withRule: true,
            ),
          );
        }
        return _row(context, exercises[index - 1], locale);
      },
    );
  }

  Widget _row(BuildContext context, Exercise exercise, String locale) {
    final bool published = exercise.isCompleted;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.hairline,
            width: AppBorders.hairline,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  exercise.titleFor(locale),
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  context.tr(exercise.principle.labelKey).toUpperCase(),
                  style: AppTypography.metricLabel,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              context
                  .tr(
                    published
                        ? 'admin.content.published'
                        : 'admin.content.draft',
                  )
                  .toUpperCase(),
              style: AppTypography.metricLabel.copyWith(
                color: published ? AppColors.gold : AppColors.textSecondary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
