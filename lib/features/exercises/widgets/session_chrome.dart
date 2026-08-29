import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/text_link_button.dart';
import '../../../core/widgets/progress_indicators.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// The fixed frame around a guided session: the advancing progress rule and
/// step count at the top, the advance and back controls at the foot.
class SessionChrome extends StatelessWidget {
  const SessionChrome.header({
    required this.progress,
    required this.stepLabel,
    required this.onClose,
    super.key,
  }) : _isHeader = true,
       advanceLabel = '',
       onAdvance = null,
       onBack = null;

  const SessionChrome.footer({
    required this.advanceLabel,
    required this.onAdvance,
    required this.onBack,
    super.key,
  }) : _isHeader = false,
       progress = 0,
       stepLabel = '',
       onClose = null;

  final bool _isHeader;

  /// 0 to 1 completion across the session's screens.
  final double progress;

  /// Already-localised "Step 2 of 4" line.
  final String stepLabel;

  final VoidCallback? onClose;

  /// Already-localised label for the advance action.
  final String advanceLabel;

  final VoidCallback? onAdvance;

  /// Null on the first screen, where there is nothing to go back to.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return _isHeader ? _header(context) : _footer(context);
  }

  Widget _header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.md,
        AppSpacing.screenH,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AppProgress.bar(value: progress, thickness: 3),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(child: SectionEyebrow(label: stepLabel)),
              TextLinkButton(
                label: context.tr('common.close'),
                onPressed: onClose,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Column(
        children: <Widget>[
          PrimaryButton(label: advanceLabel, onPressed: onAdvance),
          if (onBack != null)
            TextLinkButton(label: context.tr('common.back'), onPressed: onBack),
        ],
      ),
    );
  }
}
