import 'package:flutter/material.dart';

import '../../../core/motion/app_curves.dart';
import '../../../core/motion/app_durations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

/// The composer at the foot of the AI Coach screen.
///
/// The field lights AI Blue while focused and the send control activates only
/// when there is something to send.
class CoachInputBar extends StatefulWidget {
  const CoachInputBar({
    required this.hint,
    required this.onSend,
    required this.enabled,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onSend;

  /// False while the coach is composing, which blocks a second send.
  final bool enabled;

  @override
  State<CoachInputBar> createState() => _CoachInputBarState();
}

class _CoachInputBarState extends State<CoachInputBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    if (!_hasText || !widget.enabled) {
      return;
    }
    widget.onSend(_controller.text);
    _controller.clear();
    setState(() => _hasText = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool active = _hasText && widget.enabled;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.screenH,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.navyDeep,
        border: Border(
          top: BorderSide(
            color: AppColors.hairline,
            width: AppBorders.hairline,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Expanded(child: _field()),
            const SizedBox(width: AppSpacing.xs),
            _sendButton(active),
          ],
        ),
      ),
    );
  }

  Widget _field() {
    return AnimatedContainer(
      duration: AppDurations.fast,
      curve: AppCurves.stateChange,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.cardLarge),
        boxShadow: _focus.hasFocus ? AppShadows.blueGlow : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        minLines: 1,
        maxLines: 4,
        cursorColor: AppColors.aiBlue,
        style: AppTypography.bodyMedium,
        textInputAction: TextInputAction.send,
        onChanged: (String v) => setState(() => _hasText = v.trim().isNotEmpty),
        onSubmitted: (_) => _send(),
        decoration: InputDecoration(
          hintText: widget.hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.cardLarge),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.cardLarge),
            borderSide: BorderSide(color: AppColors.hairline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.cardLarge),
            borderSide: const BorderSide(
              color: AppColors.aiBlue,
              width: AppBorders.emphasis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sendButton(bool active) {
    return GestureDetector(
      onTap: _send,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.stateChange,
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.aiBlue : AppColors.navyElevated,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.aiBlue : AppColors.hairline,
            width: AppBorders.hairline,
          ),
          boxShadow: active ? AppShadows.blueGlow : null,
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 20,
          color: active ? AppColors.navyDeep : AppColors.textSecondary,
        ),
      ),
    );
  }
}
