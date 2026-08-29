import 'package:flutter/widgets.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/progress_indicators.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The thin gold rule across the top of the assessment, with the step count
/// beside it.
class OnboardingProgressBar extends StatelessWidget {
  const OnboardingProgressBar({
    required this.progress,
    required this.label,
    super.key,
  });

  /// 0 to 1 completion of the assessment.
  final double progress;

  /// Already-localised "Question 3 of 7" line.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppProgress.bar(value: progress, thickness: 3),
        const SizedBox(height: AppSpacing.sm),
        SectionEyebrow(label: label),
      ],
    );
  }
}
