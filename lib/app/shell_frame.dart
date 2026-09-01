import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/localization/string_extensions.dart';
import '../core/widgets/app_bottom_nav.dart';
import '../core/widgets/icons/app_icon.dart';

/// Wraps the five main destinations with the persistent navigation bar.
///
/// Lives beside the route table rather than inside it: it is the only widget
/// the routing layer owns, and `router.dart` is a route table.
class ShellFrame extends StatelessWidget {
  const ShellFrame({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: shell),
        AppBottomNav(
          currentIndex: shell.currentIndex,
          onSelect:
              (int index) => shell.goBranch(
                index,
                initialLocation: index == shell.currentIndex,
              ),
          labels: <String>[
            context.tr('nav.home'),
            context.tr('nav.goals'),
            context.tr('nav.coach'),
            context.tr('nav.exercises'),
            context.tr('nav.progress'),
          ],
          marks: const <AppIconMark>[
            AppIconMark.cycle,
            AppIconMark.target,
            AppIconMark.signal,
            AppIconMark.steps,
            AppIconMark.rise,
          ],
        ),
      ],
    );
  }
}
