import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../../core/auth/secure_session_store.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/widgets/destructive_confirm_dialog.dart';
import 'settings_group.dart';

/// The biometric sign-in row.
///
/// It can only be switched off here. Turning it on needs the password, which
/// is in hand exactly once — at sign-in, where the offer is made — so a switch
/// that appeared to turn it on from Settings would either be a lie or a second
/// place to ask for a password. The row says where it is turned on instead.
class BiometricSettingRow extends StatefulWidget {
  const BiometricSettingRow({super.key});

  @override
  State<BiometricSettingRow> createState() => _BiometricSettingRowState();
}

class _BiometricSettingRowState extends State<BiometricSettingRow> {
  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final bool enabled =
        await context.read<SecureSessionStore>().isBiometricEnabled();
    if (mounted) {
      setState(() => _enabled = enabled);
    }
  }

  Future<void> _disable() async {
    final SecureSessionStore store = context.read<SecureSessionStore>();
    final bool confirmed = await DestructiveConfirmDialog.show(
      context: context,
      title: context.tr('settings.item.biometric'),
      body: context.tr('settings.biometric.disable'),
      confirmLabel: context.tr('settings.biometric.turnOff'),
      isDestructive: false,
    );
    if (!confirmed) {
      return;
    }
    await store.clearBiometric();
    if (mounted) {
      setState(() => _enabled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      label: context.tr('settings.item.biometric'),
      value: context.tr(
        _enabled ? 'settings.biometric.on' : 'settings.biometric.atSignIn',
      ),
      onTap: _enabled ? _disable : null,
    );
  }
}
