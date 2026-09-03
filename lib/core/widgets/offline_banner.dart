import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../auth/auth_state.dart';
import '../localization/string_extensions.dart';
import '../motion/app_curves.dart';
import '../motion/app_durations.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// A strip that appears at the top of the app when the account could not be
/// read from the server.
///
/// The app keeps running on what it last knew rather than white-screening or
/// throwing the user back to Welcome, and this says so. It slides out on its
/// own the moment a call succeeds.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bool offline = context.watch<AuthState>().isOffline;

    return Stack(
      children: <Widget>[
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: AnimatedSlide(
              offset: Offset(0, offline ? 0 : -1),
              duration: AppDurations.medium,
              curve: AppCurves.stateChange,
              child: AnimatedOpacity(
                opacity: offline ? 1 : 0,
                duration: AppDurations.fast,
                child: _strip(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _strip(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.navyDeep.withValues(alpha: 0.94),
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
        bottom: AppSpacing.xs,
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Text(
        context.tr('common.offline'),
        textAlign: TextAlign.center,
        style: AppTypography.caption.copyWith(color: AppColors.gold),
      ),
    );
  }
}
