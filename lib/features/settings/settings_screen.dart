import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/auth/secure_session_store.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/services/external_links.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/destructive_confirm_dialog.dart';
import '../../core/widgets/screen_background.dart';
import '../../data/models/subscription_plan.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/subscription_repository.dart';
import 'widgets/settings_group.dart';
import 'widgets/succenergy_links_group.dart';

/// Grouped settings, from language through to deleting the account.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometric = false;
  SubscriptionTier? _tier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final SubscriptionRepository subscriptions =
        context.read<SubscriptionRepository>();
    final SecureSessionStore store = context.read<SecureSessionStore>();

    final SubscriptionTier tier = await subscriptions.loadCurrentTier();
    final bool biometric = await store.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _tier = tier;
        _biometric = biometric;
      });
    }
  }

  /// Turning biometric sign-in off is done here; turning it on is offered at
  /// sign-in, which is the only place the password is in hand to store. So
  /// this row reports the state and can only switch it off.
  Future<void> _disableBiometric() async {
    final bool confirmed = await DestructiveConfirmDialog.show(
      context: context,
      title: context.tr('settings.item.biometric'),
      body: context.tr('settings.biometric.disable'),
      confirmLabel: context.tr('settings.biometric.turnOff'),
      isDestructive: false,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await context.read<SecureSessionStore>().clearBiometric();
    if (mounted) {
      setState(() => _biometric = false);
    }
  }

  Future<void> _logOut() async {
    final bool confirmed = await DestructiveConfirmDialog.show(
      context: context,
      title: context.tr('settings.logout.title'),
      body: context.tr('settings.logout.body'),
      confirmLabel: context.tr('settings.item.logout'),
      isDestructive: false,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await context.read<AuthRepository>().logOut();
    if (mounted) {
      context.go(Routes.welcome);
    }
  }

  Future<void> _deleteAccount() async {
    final bool confirmed = await DestructiveConfirmDialog.show(
      context: context,
      title: context.tr('settings.delete.title'),
      body: context.tr('settings.delete.body'),
      confirmLabel: context.tr('settings.delete.confirm'),
      isDestructive: true,
    );
    if (!confirmed || !mounted) {
      return;
    }
    await context.read<AuthRepository>().deleteAccount();
    if (mounted) {
      context.go(Routes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('settings.title')),
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenH,
                  AppSpacing.xl + AppSpacing.md,
                  AppSpacing.screenH,
                  AppSpacing.xxl,
                ),
                children: _groups(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _groups(BuildContext context) {
    final LocaleProvider locale = context.watch<LocaleProvider>();

    return <Widget>[
      AnimatedReveal(
        index: 0,
        child: SettingsGroup(
          title: context.tr('settings.section.general'),
          rows: <Widget>[
            SettingsRow(
              label: context.tr('settings.item.language'),
              value:
                  locale.code == 'en'
                      ? context.tr('language.englishNative')
                      : context.tr('language.portugueseNative'),
              onTap: () => locale.setLocale(locale.code == 'en' ? 'pt' : 'en'),
            ),
            SettingsRow(
              label: context.tr('settings.item.notifications'),
              onTap: () => context.push(Routes.notifications),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 1,
        child: SettingsGroup(
          title: context.tr('settings.section.account'),
          rows: <Widget>[
            SettingsRow(
              label: context.tr('settings.item.profile'),
              onTap: () => context.push(Routes.profile),
            ),
            SettingsRow(
              label: context.tr('settings.item.changePassword'),
              onTap: () => context.push(Routes.forgotPassword),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 2,
        child: SettingsGroup(
          title: context.tr('settings.section.security'),
          rows: <Widget>[
            SettingsRow(
              label: context.tr('settings.item.biometric'),
              value: context.tr(
                _biometric
                    ? 'settings.biometric.on'
                    : 'settings.biometric.atSignIn',
              ),
              onTap: _biometric ? _disableBiometric : null,
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 3,
        child: SettingsGroup(
          title: context.tr('settings.section.subscription'),
          rows: <Widget>[
            SettingsRow(
              label: context.tr('settings.item.plan'),
              value: _tier == null ? null : context.tr(_planKey(_tier!)),
              onTap: () => context.push(Routes.subscription),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      const AnimatedReveal(index: 4, child: SuccenergyLinksGroup()),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 5,
        child: SettingsGroup(
          title: context.tr('settings.section.about'),
          rows: <Widget>[
            SettingsRow(
              label: context.tr('settings.item.help'),
              onTap: () => context.push(Routes.help),
            ),
            SettingsRow(
              label: context.tr('settings.item.terms'),
              value: context.tr('settings.external'),
              onTap: () => ExternalLinks.open(AppConstants.placeholderTermsUrl),
            ),
            SettingsRow(
              label: context.tr('settings.item.privacy'),
              value: context.tr('settings.external'),
              onTap:
                  () => ExternalLinks.open(AppConstants.placeholderPrivacyUrl),
            ),
            SettingsRow(
              label: context.tr('settings.item.admin'),
              onTap: () => context.push(Routes.adminGate),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      AnimatedReveal(
        index: 6,
        child: SettingsGroup(
          title: context.tr('settings.section.account'),
          rows: <Widget>[
            SettingsRow(
              label: context.tr('settings.item.logout'),
              onTap: _logOut,
            ),
            SettingsRow(
              label: context.tr('settings.item.deleteAccount'),
              isDestructive: true,
              onTap: _deleteAccount,
            ),
          ],
        ),
      ),
    ];
  }

  String _planKey(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.trial:
        return 'subscription.plan.trial';
      case SubscriptionTier.student:
        return 'subscription.plan.student';
      case SubscriptionTier.professional:
        return 'subscription.plan.professional';
    }
  }
}
