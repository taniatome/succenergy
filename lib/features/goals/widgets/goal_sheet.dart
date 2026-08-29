import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/principle_badge.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/principle.dart';

/// The sheet that opens a goal: what, why, and the principle leading it.
///
/// One sheet serves both jobs. Pass [goal] to edit an existing one, in which
/// case the fields arrive pre-filled and the sheet retitles itself; leave it
/// null to create.
class GoalSheet extends StatefulWidget {
  const GoalSheet({required this.onSubmit, this.goal, super.key});

  /// Called with the entered values. The sheet closes itself afterwards.
  final void Function(String title, String why, Principle principle) onSubmit;

  /// The goal being edited, or null when creating a new one.
  final Goal? goal;

  @override
  State<GoalSheet> createState() => _GoalSheetState();
}

class _GoalSheetState extends State<GoalSheet> {
  late final TextEditingController _title;
  late final TextEditingController _why;
  late Principle _principle;

  bool get _isEditing => widget.goal != null;

  @override
  void initState() {
    super.initState();
    final Goal? goal = widget.goal;
    _title = TextEditingController(text: goal?.title['en'] ?? '');
    _why = TextEditingController(text: goal?.why['en'] ?? '');
    _principle = goal?.principle ?? Principle.purpose;
  }

  @override
  void dispose() {
    _title.dispose();
    _why.dispose();
    super.dispose();
  }

  bool get _valid => _title.text.trim().isNotEmpty;

  void _submit() {
    widget.onSubmit(_title.text.trim(), _why.text.trim(), _principle);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _fields(context),
        ),
      ),
    );
  }

  List<Widget> _fields(BuildContext context) {
    return <Widget>[
      _grabber(),
      const SizedBox(height: AppSpacing.lg),
      Text(
        context.tr(_isEditing ? 'goals.edit.title' : 'goals.create.title'),
        style: AppTypography.headlineMedium,
      ),
      const SizedBox(height: AppSpacing.lg),
      AppTextField(
        controller: _title,
        label: context.tr('goals.create.name'),
        hint: context.tr('goals.create.nameHint'),
        onChanged: (_) => setState(() {}),
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _why,
        label: context.tr('goals.create.why'),
        hint: context.tr('goals.create.whyHint'),
        minLines: 2,
        maxLines: 4,
      ),
      const SizedBox(height: AppSpacing.md),
      SectionEyebrow(label: context.tr('goals.create.principle')),
      const SizedBox(height: AppSpacing.xs),
      _principlePicker(),
      const SizedBox(height: AppSpacing.lg),
      PrimaryButton(
        label: context.tr(
          _isEditing ? 'goals.edit.submit' : 'goals.create.submit',
        ),
        onPressed: _valid ? _submit : null,
      ),
    ];
  }

  Widget _grabber() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }

  Widget _principlePicker() {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: <Widget>[
        for (final Principle p in Principle.values)
          GestureDetector(
            onTap: () => setState(() => _principle = p),
            child: Opacity(
              opacity: _principle == p ? 1 : 0.42,
              child: PrincipleBadge(principle: p),
            ),
          ),
      ],
    );
  }
}
