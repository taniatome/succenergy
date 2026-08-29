import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/widgets/destructive_confirm_dialog.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/principle.dart';
import '../goals_provider.dart';
import 'goal_sheet.dart';

/// The sheets and dialogs a goal can be acted on through.
///
/// Both the Goals list and Goal Detail open the same edit sheet and the same
/// delete confirmation, so the two surfaces cannot drift apart. Neither
/// screen holds this plumbing itself.
class GoalActions {
  const GoalActions._();

  /// Opens the goal sheet pre-filled and saves through [provider].
  static Future<void> edit({
    required BuildContext context,
    required GoalsProvider provider,
    required Goal goal,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (BuildContext sheetContext) => GoalSheet(
            goal: goal,
            onSubmit: (String title, String why, Principle principle) {
              provider.edit(
                goal: goal,
                title: title,
                why: why,
                principle: principle,
              );
            },
          ),
    );
  }

  /// Opens the sheet empty and creates through [provider].
  static Future<void> create({
    required BuildContext context,
    required GoalsProvider provider,
    required Duration defaultHorizon,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder:
          (BuildContext sheetContext) => GoalSheet(
            onSubmit: (String title, String why, Principle principle) {
              provider.create(
                title: title,
                why: why,
                principle: principle,
                targetDate: DateTime.now().add(defaultHorizon),
              );
            },
          ),
    );
  }

  /// Asks before deleting. Resolves true only when the user confirms.
  static Future<bool> confirmDelete(BuildContext context) {
    return DestructiveConfirmDialog.show(
      context: context,
      title: context.tr('goals.delete.title'),
      body: context.tr('goals.delete.body'),
      confirmLabel: context.tr('goals.delete.confirm'),
      isDestructive: true,
    );
  }
}
