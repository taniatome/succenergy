import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/inputs/app_checkbox.dart';

/// The two statements the user has to agree to before an account is created.
///
/// Two separate boxes, not one combined line: accepting the terms and
/// standing behind what you entered are different commitments, and the client
/// asked for them to be ticked separately.
class ConsentBlock extends StatelessWidget {
  const ConsentBlock({
    required this.acceptedTerms,
    required this.confirmedTruth,
    required this.onTermsChanged,
    required this.onTruthChanged,
    this.errorText,
    super.key,
  });

  final bool acceptedTerms;
  final bool confirmedTruth;
  final ValueChanged<bool> onTermsChanged;
  final ValueChanged<bool> onTruthChanged;

  /// Shown when the form was submitted with either box unticked.
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppCheckbox(
          value: acceptedTerms,
          label: context.tr('auth.consent.terms'),
          onChanged: onTermsChanged,
        ),
        AppCheckbox(
          value: confirmedTruth,
          label: context.tr('auth.consent.truth'),
          onChanged: onTruthChanged,
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            errorText!,
            style: AppTypography.caption.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}
