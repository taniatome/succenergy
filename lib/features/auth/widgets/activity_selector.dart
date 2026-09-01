import 'package:flutter/widgets.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/widgets/inputs/preference_choice_row.dart';
import '../../../data/models/user.dart';

/// The two-option activity picker.
///
/// This is the answer that sets the monthly rate after the trial, so it is
/// asked once, here, and read from the account everywhere else.
class ActivitySelector extends StatelessWidget {
  const ActivitySelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final UserActivity value;
  final ValueChanged<UserActivity> onChanged;

  @override
  Widget build(BuildContext context) {
    return PreferenceChoiceRow(
      label: context.tr('auth.field.activity'),
      options: <String>[
        context.tr('auth.activity.student'),
        context.tr('auth.activity.professional'),
      ],
      selectedIndex: value == UserActivity.studentMinorities ? 0 : 1,
      onSelect:
          (int index) => onChanged(
            index == 0
                ? UserActivity.studentMinorities
                : UserActivity.professional,
          ),
    );
  }
}
