import 'package:flutter/widgets.dart';

import '../../theme/app_spacing.dart';
import '../progress_indicators.dart';
import '../section_eyebrow.dart';

/// The thin gold rule across the top of a question sequence, with the step
/// count beside it.
///
/// Shared by the pre-registration quiz and the onboarding assessment, so the
/// two halves of the same set of questions carry one treatment.
class QuestionProgressBar extends StatelessWidget {
  const QuestionProgressBar({
    required this.progress,
    required this.label,
    super.key,
  });

  /// 0 to 1 completion of the assessment.
  final double progress;

  /// Already-localised "Question 2 of 3" line.
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
