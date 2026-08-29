import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/chat_message.dart';
import 'coach_provider.dart';
import 'widgets/ambient_drift.dart';
import 'widgets/coach_input_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/suggested_replies.dart';
import 'widgets/thinking_indicator.dart';

/// The AI Coach conversation.
///
/// The one screen built around AI Blue. Messages arrive individually, coach
/// replies are preceded by the thinking indicator, and the background drifts
/// slowly so the screen feels awake between turns.
class AiCoachScreen extends StatefulWidget {
  const AiCoachScreen({super.key});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final ScrollController _scroll = ScrollController();

  /// Ids already animated in. A message rises once, then stays put when the
  /// list recycles it during scrolling.
  final Set<String> _revealed = <String>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<CoachProvider>().load();
      _scrollToEnd();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send(String text) async {
    final CoachProvider provider = context.read<CoachProvider>();
    _scrollToEnd();
    await provider.send(text);
    _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    final CoachProvider p = context.watch<CoachProvider>();

    return Scaffold(
      backgroundColor: AppColors.deepNavy,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const ScreenBackground(child: SizedBox.expand()),
          const AmbientDrift(),
          SafeArea(
            bottom: false,
            child: Column(
              children: <Widget>[
                _header(context, p),
                Expanded(child: _conversation(context, p)),
                if (p.showSuggestions) ...<Widget>[
                  SuggestedReplies(
                    suggestionKeys: p.suggestionKeys,
                    onSelect: _send,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                CoachInputBar(
                  hint: context.tr('coach.inputHint'),
                  enabled: !p.thinking,
                  onSend: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, CoachProvider p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(context.tr('coach.title'), style: AppTypography.aiTitle),
                const SizedBox(height: 2),
                Text(
                  context.tr('coach.subtitle'),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.tr('coach.history'),
            onPressed: () => context.push(Routes.coachingHistory),
            icon: const Icon(
              Icons.history_rounded,
              color: AppColors.textSecondary,
            ),
          ),
          IconButton(
            tooltip: context.tr('coach.newSession'),
            onPressed: () async {
              await p.startNewSession();
              _scrollToEnd();
            },
            icon: const Icon(
              Icons.add_comment_outlined,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _conversation(BuildContext context, CoachProvider p) {
    if (p.loading) {
      return const Center(child: AppLoader(useAiAccent: true));
    }
    final String locale = context.localeCode;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.maxContentWidth,
        ),
        child: ListView.separated(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            AppSpacing.sm,
            AppSpacing.screenH,
            AppSpacing.md,
          ),
          itemCount: p.messages.length + (p.thinking ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (BuildContext context, int index) {
            if (index >= p.messages.length) {
              return Align(
                alignment: Alignment.centerLeft,
                child: ThinkingIndicator(label: context.tr('coach.thinking')),
              );
            }
            final ChatMessage message = p.messages[index];
            final bool showAvatar =
                index == 0 || !p.messages[index - 1].isCoach;
            final Widget bubble = MessageBubble(
              message: message,
              localeCode: locale,
              showAvatar: showAvatar,
            );
            if (_revealed.contains(message.id)) {
              return bubble;
            }
            _revealed.add(message.id);
            return AnimatedReveal(
              key: ValueKey<String>(message.id),
              offset: 10,
              child: bubble,
            );
          },
        ),
      ),
    );
  }
}
