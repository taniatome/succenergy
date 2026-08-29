import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/principle_badge.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import '../../data/models/chat_message.dart';
import '../../data/models/coaching_session.dart';
import '../../data/repositories/coach_repository.dart';
import 'widgets/transcript_bubble.dart';

/// The full transcript of one past coaching session.
class SessionDetailScreen extends StatefulWidget {
  const SessionDetailScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  CoachingSession? _session;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final CoachingSession? session = await context
        .read<CoachRepository>()
        .loadSession(widget.sessionId);
    if (mounted) {
      setState(() => _session = session);
    }
  }

  @override
  Widget build(BuildContext context) {
    final CoachingSession? session = _session;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('history.transcript')),
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        child: SafeArea(
          child:
              session == null
                  ? const Center(child: AppLoader())
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: _transcript(context, session),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _transcript(BuildContext context, CoachingSession session) {
    final String locale = context.localeCode;
    final String date = DateFormat.yMMMMd(locale).format(session.startedAt);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xl + AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      itemCount: session.messages.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _header(context, session, date);
        }
        final ChatMessage message = session.messages[index - 1];
        return AnimatedReveal(
          key: ValueKey<String>(message.id),
          index: index,
          child: TranscriptBubble(message: message, localeCode: locale),
        );
      },
    );
  }

  Widget _header(BuildContext context, CoachingSession session, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              PrincipleBadge(principle: session.principle),
              const Spacer(),
              Text(
                context.tr(
                  'history.duration',
                  params: <String, String>{
                    'minutes': '${session.durationMinutes}',
                  },
                ),
                style: AppTypography.caption,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SectionEyebrow(label: date),
          const SizedBox(height: AppSpacing.xs),
          Text(
            session.summaryFor(context.localeCode),
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
