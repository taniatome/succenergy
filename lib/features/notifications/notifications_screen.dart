import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/buttons/text_link_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/inputs/preference_choice_row.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/notifications_repository.dart';
import 'widgets/notification_preference_list.dart';
import 'widgets/notification_row.dart';

/// The notification inbox and the switches that control what arrives.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const List<String> _preferenceKeys = <String>[
    'notifications.pref.goalNudges',
    'notifications.pref.principleOfDay',
    'notifications.pref.reengagement',
    'notifications.pref.exerciseReminders',
    'notifications.pref.quietHours',
  ];

  List<AppNotification> _items = const <AppNotification>[];
  Map<String, bool> _preferences = const <String, bool>{};
  int _tab = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final NotificationsRepository repo =
        context.read<NotificationsRepository>();
    final List<AppNotification> items = await repo.loadNotifications();
    final Map<String, bool> preferences = await repo.loadPreferences();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = items;
      _preferences = preferences;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    final List<AppNotification> items =
        await context.read<NotificationsRepository>().loadNotifications();
    if (mounted) {
      setState(() => _items = items);
    }
  }

  Future<void> _markRead(String id) async {
    await context.read<NotificationsRepository>().markRead(id);
    await _refresh();
  }

  Future<void> _markAllRead() async {
    await context.read<NotificationsRepository>().markAllRead();
    await _refresh();
  }

  Future<void> _setPreference(String key, bool value) async {
    setState(() {
      _preferences = <String, bool>{..._preferences, key: value};
    });
    await context.read<NotificationsRepository>().setPreference(
      key: key,
      enabled: value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('notifications.title')),
        actions: <Widget>[
          if (_tab == 0)
            TextLinkButton(
              label: context.tr('notifications.markAllRead'),
              onPressed: _markAllRead,
            ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        child: SafeArea(
          child:
              _loading
                  ? const Center(child: AppLoader())
                  : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: AppConstants.maxContentWidth,
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: AppSpacing.xl + AppSpacing.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.screenH,
                            ),
                            child: PreferenceChoiceRow(
                              options: <String>[
                                context.tr('notifications.tab.inbox'),
                                context.tr('notifications.tab.preferences'),
                              ],
                              selectedIndex: _tab,
                              onSelect: (int i) => setState(() => _tab = i),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Expanded(
                            child:
                                _tab == 0
                                    ? _inbox(context)
                                    : NotificationPreferenceList(
                                      preferenceKeys: _preferenceKeys,
                                      values: _preferences,
                                      onChanged: _setPreference,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _inbox(BuildContext context) {
    if (_items.isEmpty) {
      return EmptyState(
        eyebrow: context.tr('notifications.title'),
        title: context.tr('notifications.empty.title'),
        body: context.tr('notifications.empty.body'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        0,
        AppSpacing.screenH,
        AppSpacing.xxl,
      ),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final AppNotification item = _items[index];
        return AnimatedReveal(
          key: ValueKey<String>(item.id),
          index: index,
          child: NotificationRow(
            notification: item,
            onTap: () => _markRead(item.id),
          ),
        );
      },
    );
  }
}
