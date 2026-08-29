import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import '../../data/models/coaching_session.dart';
import '../../data/repositories/coach_repository.dart';
import 'widgets/session_row.dart';

/// Past coaching sessions, grouped by the day they happened.
class CoachingHistoryScreen extends StatefulWidget {
  const CoachingHistoryScreen({super.key});

  @override
  State<CoachingHistoryScreen> createState() => _CoachingHistoryScreenState();
}

class _CoachingHistoryScreenState extends State<CoachingHistoryScreen> {
  List<CoachingSession>? _sessions;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final List<CoachingSession> sessions =
        await context.read<CoachRepository>().loadSessions();
    if (mounted) {
      setState(() => _sessions = sessions);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<CoachingSession>? sessions = _sessions;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('history.title')),
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        child: SafeArea(
          child:
              sessions == null
                  ? const Center(child: AppLoader())
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child:
                          sessions.isEmpty
                              ? EmptyState(
                                eyebrow: context.tr('history.title'),
                                title: context.tr('history.empty.title'),
                                body: context.tr('history.empty.body'),
                              )
                              : _list(context, sessions),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<CoachingSession> sessions) {
    final DateFormat dayFormat = DateFormat.yMMMMd(context.localeCode);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xl + AppSpacing.md,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      itemCount: sessions.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Text(
              context.tr('history.subtitle'),
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }
        final CoachingSession session = sessions[index - 1];
        final CoachingSession? previous =
            index >= 2 ? sessions[index - 2] : null;
        final bool newDay =
            previous == null ||
            !_sameDay(previous.startedAt, session.startedAt);

        return AnimatedReveal(
          key: ValueKey<String>(session.id),
          index: index,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (newDay) ...<Widget>[
                if (index > 1) const SizedBox(height: AppSpacing.lg),
                SectionEyebrow(label: dayFormat.format(session.startedAt)),
                const SizedBox(height: AppSpacing.sm),
              ],
              SessionRow(
                session: session,
                onTap: () => context.push(Routes.sessionDetail(session.id)),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
