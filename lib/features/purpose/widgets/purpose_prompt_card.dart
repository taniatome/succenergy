import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/buttons/text_link_button.dart';
import '../../../core/widgets/cards/glow_card.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/section_eyebrow.dart';

/// One Purpose prompt, shown either as a saved answer with an edit
/// affordance, or as an open field when being worked on.
class PurposePromptCard extends StatefulWidget {
  const PurposePromptCard({
    required this.title,
    required this.question,
    required this.answer,
    required this.onSave,
    super.key,
  });

  final String title;
  final String question;
  final String answer;
  final ValueChanged<String> onSave;

  @override
  State<PurposePromptCard> createState() => _PurposePromptCardState();
}

class _PurposePromptCardState extends State<PurposePromptCard> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.answer,
  );
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _answered => widget.answer.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: _answered ? GlowAccent.gold : GlowAccent.none,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: SectionEyebrow(label: widget.title)),
              Text(
                context.tr(
                  _answered ? 'purpose.answered' : 'purpose.unanswered',
                ),
                style: AppTypography.caption.copyWith(
                  color: _answered ? AppColors.gold : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(widget.question, style: AppTypography.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          if (_editing) _editor(context) else _readout(context),
        ],
      ),
    );
  }

  Widget _readout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (_answered)
          Text(
            widget.answer,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: AppSpacing.xs),
        Align(
          alignment: Alignment.centerLeft,
          child: TextLinkButton(
            label: context.tr(_answered ? 'common.edit' : 'purpose.saveAnswer'),
            onPressed: () => setState(() => _editing = true),
          ),
        ),
      ],
    );
  }

  Widget _editor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AppTextField(
          controller: _controller,
          minLines: 3,
          maxLines: 6,
          autofocus: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: PrimaryButton(
                label: context.tr('common.save'),
                onPressed: () {
                  widget.onSave(_controller.text);
                  setState(() => _editing = false);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextLinkButton(
              label: context.tr('common.cancel'),
              onPressed: () {
                _controller.text = widget.answer;
                setState(() => _editing = false);
              },
            ),
          ],
        ),
      ],
    );
  }
}
