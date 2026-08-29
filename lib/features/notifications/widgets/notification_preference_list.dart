import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_reveal.dart';
import '../../../core/widgets/inputs/app_switch.dart';

/// The delivery preferences behind the inbox, one switch per notification
/// type plus quiet hours.
class NotificationPreferenceList extends StatelessWidget {
  const NotificationPreferenceList({
    required this.preferenceKeys,
    required this.values,
    required this.onChanged,
    super.key,
  });

  /// Localisation keys for each preference, in display order. The description
  /// line resolves from the same key with a `.desc` suffix.
  final List<String> preferenceKeys;

  final Map<String, bool> values;
  final void Function(String key, bool enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        for (int i = 0; i < preferenceKeys.length; i++)
          AnimatedReveal(index: i, child: _row(context, preferenceKeys[i])),
      ],
    );
  }

  Widget _row(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(context.tr(key), style: AppTypography.bodyLarge),
                const SizedBox(height: 2),
                Text(context.tr('$key.desc'), style: AppTypography.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          AppSwitch(
            value: values[key] ?? false,
            onChanged: (bool v) => onChanged(key, v),
          ),
        ],
      ),
    );
  }
}
