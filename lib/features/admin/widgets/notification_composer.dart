import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/widgets/section_eyebrow.dart';
import '../../../core/widgets/inputs/preference_choice_row.dart';

/// Composes a notification and queues it for an audience.
class NotificationComposer extends StatefulWidget {
  const NotificationComposer({required this.onQueue, super.key});

  /// Called with the audience localisation key, heading and body.
  final void Function(String audienceKey, String heading, String body) onQueue;

  @override
  State<NotificationComposer> createState() => _NotificationComposerState();
}

class _NotificationComposerState extends State<NotificationComposer> {
  static const List<String> _audienceKeys = <String>[
    'admin.notify.audience.all',
    'admin.notify.audience.free',
    'admin.notify.audience.premium',
  ];

  final TextEditingController _heading = TextEditingController();
  final TextEditingController _body = TextEditingController();
  int _audience = 0;

  @override
  void dispose() {
    _heading.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _valid =>
      _heading.text.trim().isNotEmpty && _body.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SectionEyebrow(label: context.tr('admin.notify.title'), withRule: true),
        const SizedBox(height: AppSpacing.md),
        PreferenceChoiceRow(
          label: context.tr('admin.notify.audience'),
          options: _audienceKeys.map(context.tr).toList(growable: false),
          selectedIndex: _audience,
          onSelect: (int i) => setState(() => _audience = i),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _heading,
          label: context.tr('admin.notify.heading'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _body,
          label: context.tr('admin.notify.body'),
          minLines: 3,
          maxLines: 6,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: context.tr('admin.notify.send'),
          onPressed:
              _valid
                  ? () {
                    widget.onQueue(
                      _audienceKeys[_audience],
                      _heading.text.trim(),
                      _body.text.trim(),
                    );
                    _heading.clear();
                    _body.clear();
                    setState(() {});
                  }
                  : null,
        ),
      ],
    );
  }
}
