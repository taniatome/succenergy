import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/localization/string_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/animated_reveal.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/buttons/primary_button.dart';
import '../../core/widgets/inputs/app_switch.dart';
import '../../core/widgets/inputs/app_text_field.dart';
import '../../core/widgets/inputs/preference_choice_row.dart';
import '../../core/widgets/screen_background.dart';
import '../../core/widgets/section_eyebrow.dart';
import '../../data/models/onboarding_response.dart';
import '../../data/models/user.dart';
import '../../data/repositories/user_repository.dart';
import 'widgets/coaching_profile_section.dart';

/// Name, language, coaching preferences and the onboarding answers behind
/// them, all editable.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();

  User? _user;
  OnboardingResponse? _response;
  CoachingTone _tone = CoachingTone.direct;
  CheckInRhythm _rhythm = CheckInRhythm.daily;
  bool _reminders = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final UserRepository users = context.read<UserRepository>();
    final User user = await users.loadUser();
    final OnboardingResponse response = await users.loadOnboardingResponse();
    if (!mounted) {
      return;
    }
    setState(() {
      _user = user;
      _response = response;
      _name.text = user.name;
      _email.text = user.email;
      _tone = user.tone;
      _rhythm = user.rhythm;
      _reminders = user.remindersEnabled;
    });
  }

  Future<void> _save() async {
    final UserRepository users = context.read<UserRepository>();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String confirmation = context.tr('profile.saved');
    await users.updateProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      tone: _tone,
      rhythm: _rhythm,
      remindersEnabled: _reminders,
    );
    messenger.showSnackBar(SnackBar(content: Text(confirmation)));
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _user;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(context.tr('profile.title')),
      ),
      extendBodyBehindAppBar: true,
      body: ScreenBackground(
        glowTint: AppColors.gold,
        glowAlignment: const Alignment(0, -0.95),
        child: SafeArea(
          child:
              user == null
                  ? const Center(child: AppLoader())
                  : Center(
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
                        children: _sections(context, user),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }

  List<Widget> _sections(BuildContext context, User user) {
    return <Widget>[
      AnimatedReveal(index: 0, child: _account(context, user)),
      const SizedBox(height: AppSpacing.xl),
      AnimatedReveal(index: 1, child: _preferences(context)),
      const SizedBox(height: AppSpacing.xl),
      if (_response != null)
        AnimatedReveal(
          index: 2,
          child: CoachingProfileSection(response: _response!),
        ),
      const SizedBox(height: AppSpacing.xl),
      AnimatedReveal(
        index: 3,
        child: PrimaryButton(
          label: context.tr('common.saveChanges'),
          onPressed: _save,
        ),
      ),
    ];
  }

  Widget _account(BuildContext context, User user) {
    final String joined = DateFormat.yMMMM(
      context.localeCode,
    ).format(user.joinedAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(
          label: context.tr('profile.section.account'),
          withRule: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _name,
          label: context.tr('profile.field.name'),
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: _email,
          label: context.tr('profile.field.email'),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.md),
        _languageRow(context),
        const SizedBox(height: AppSpacing.sm),
        Text(
          context.tr(
            'profile.memberSince',
            params: <String, String>{'date': joined},
          ),
          style: AppTypography.caption,
        ),
      ],
    );
  }

  Widget _languageRow(BuildContext context) {
    final LocaleProvider locale = context.watch<LocaleProvider>();
    return PreferenceChoiceRow(
      label: context.tr('profile.field.language'),
      options: <String>[
        context.tr('language.englishNative'),
        context.tr('language.portugueseNative'),
      ],
      selectedIndex: locale.code == 'en' ? 0 : 1,
      onSelect: (int index) => locale.setLocale(index == 0 ? 'en' : 'pt'),
    );
  }

  Widget _preferences(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SectionEyebrow(
          label: context.tr('profile.section.preferences'),
          withRule: true,
        ),
        const SizedBox(height: AppSpacing.md),
        PreferenceChoiceRow(
          label: context.tr('profile.pref.tone'),
          options: <String>[
            context.tr('profile.pref.tone.direct'),
            context.tr('profile.pref.tone.warm'),
            context.tr('profile.pref.tone.challenging'),
          ],
          selectedIndex: _tone.index,
          onSelect: (int i) => setState(() => _tone = CoachingTone.values[i]),
        ),
        const SizedBox(height: AppSpacing.md),
        PreferenceChoiceRow(
          label: context.tr('profile.pref.checkIn'),
          options: <String>[
            context.tr('profile.pref.checkIn.daily'),
            context.tr('profile.pref.checkIn.everyOther'),
            context.tr('profile.pref.checkIn.weekly'),
          ],
          selectedIndex: _rhythm.index,
          onSelect:
              (int i) => setState(() => _rhythm = CheckInRhythm.values[i]),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                context.tr('profile.pref.reminders'),
                style: AppTypography.bodyLarge,
              ),
            ),
            AppSwitch(
              value: _reminders,
              onChanged: (bool v) => setState(() => _reminders = v),
            ),
          ],
        ),
      ],
    );
  }
}
