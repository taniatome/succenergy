import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/services/external_links.dart';
import '../../../core/theme/app_spacing.dart';
import 'settings_group.dart';

/// The Succenergy group in Settings: the in-app extras and the destinations
/// that live on the web.
///
/// Every URL it opens is a placeholder from [AppConstants] until the client
/// supplies the real ones. Connect with Us opens in place rather than pushing
/// a screen, because four social links do not need one.
class SuccenergyLinksGroup extends StatefulWidget {
  const SuccenergyLinksGroup({super.key});

  @override
  State<SuccenergyLinksGroup> createState() => _SuccenergyLinksGroupState();
}

class _SuccenergyLinksGroupState extends State<SuccenergyLinksGroup> {
  bool _connectOpen = false;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: context.tr('settings.section.succenergy'),
      rows: <Widget>[
        SettingsRow(
          label: context.tr('settings.item.recharge'),
          onTap: () => context.push(Routes.recharge),
        ),
        SettingsRow(
          label: context.tr('settings.item.library'),
          value: context.tr('settings.external'),
          onTap: () => ExternalLinks.open(AppConstants.placeholderLibraryUrl),
        ),
        SettingsRow(
          label: context.tr('settings.item.booking'),
          value: context.tr('settings.external'),
          onTap: () => ExternalLinks.open(AppConstants.placeholderBookingUrl),
        ),
        SettingsRow(
          label: context.tr('settings.item.connect'),
          onTap: () => setState(() => _connectOpen = !_connectOpen),
        ),
        if (_connectOpen) ..._socialRows(context),
      ],
    );
  }

  /// The four social destinations, indented under Connect with Us.
  List<Widget> _socialRows(BuildContext context) {
    final Map<String, String> links = <String, String>{
      'settings.connect.instagram': AppConstants.placeholderInstagramUrl,
      'settings.connect.facebook': AppConstants.placeholderFacebookUrl,
      'settings.connect.linkedin': AppConstants.placeholderLinkedInUrl,
      'settings.connect.youtube': AppConstants.placeholderYouTubeUrl,
    };

    return <Widget>[
      for (final MapEntry<String, String> entry in links.entries)
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: SettingsRow(
            label: context.tr(entry.key),
            value: context.tr('settings.external'),
            onTap: () => ExternalLinks.open(entry.value),
          ),
        ),
    ];
  }
}
