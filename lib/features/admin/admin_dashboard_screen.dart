import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/inputs/preference_choice_row.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/exercise.dart';
import '../../data/models/user.dart';
import '../../data/repositories/exercises_repository.dart';
import '../../data/repositories/notifications_repository.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/admin_stat_strip.dart';
import 'widgets/content_library_panel.dart';
import 'widgets/notification_composer.dart';
import 'widgets/user_directory_panel.dart';

/// The management console: accounts, content and outbound notifications.
///
/// Deliberately denser and more utilitarian than the user app, on the same
/// palette so it still reads as part of the product.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _search = TextEditingController();

  List<User> _users = const <User>[];
  List<Exercise> _exercises = const <Exercise>[];
  Map<String, String> _stats = const <String, String>{};
  int _tab = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final UserRepository users = context.read<UserRepository>();
    final ExercisesRepository exercises = context.read<ExercisesRepository>();
    final List<User> directory = await users.loadDirectory();
    final Map<String, String> stats = await users.loadPlatformStats();
    final List<Exercise> library = await exercises.loadExercises();
    if (!mounted) {
      return;
    }
    setState(() {
      _users = directory;
      _stats = stats;
      _exercises = library;
      _loading = false;
    });
  }

  Future<void> _queue(String audienceKey, String heading, String body) async {
    final NotificationsRepository repo =
        context.read<NotificationsRepository>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String confirmation = context.tr(
      'admin.notify.queued',
      params: <String, String>{'audience': context.tr(audienceKey)},
    );
    await repo.queueBroadcast(
      audienceKey: audienceKey,
      heading: heading,
      body: body,
    );
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }

  List<User> get _filtered {
    final String query = _search.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _users;
    }
    return _users
        .where(
          (User u) =>
              u.name.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.go(Routes.settings)),
        title: Text(
          context.tr('admin.title'),
          style: AppTypography.aiTitle.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
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
                          _controls(context),
                          Expanded(child: _panel(context)),
                        ],
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  Widget _controls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.md,
      ),
      child: Column(
        children: <Widget>[
          AdminStatStrip(stats: _stats),
          const SizedBox(height: AppSpacing.md),
          PreferenceChoiceRow(
            options: <String>[
              context.tr('admin.tab.users'),
              context.tr('admin.tab.content'),
              context.tr('admin.tab.notify'),
            ],
            selectedIndex: _tab,
            onSelect: (int i) => setState(() => _tab = i),
          ),
        ],
      ),
    );
  }

  Widget _panel(BuildContext context) {
    switch (_tab) {
      case 1:
        return ContentLibraryPanel(exercises: _exercises);
      case 2:
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenH,
            0,
            AppSpacing.screenH,
            AppSpacing.xxl,
          ),
          child: NotificationComposer(onQueue: _queue),
        );
      default:
        return UserDirectoryPanel(
          users: _filtered,
          search: _search,
          onSearchChanged: (_) => setState(() {}),
        );
    }
  }
}
