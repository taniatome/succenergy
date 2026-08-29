import 'package:flutter/material.dart';

import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../data/models/user.dart';
import 'admin_user_row.dart';

/// The searchable account list in the management console.
class UserDirectoryPanel extends StatelessWidget {
  const UserDirectoryPanel({
    required this.users,
    required this.search,
    required this.onSearchChanged,
    super.key,
  });

  /// Already-filtered rows.
  final List<User> users;

  final TextEditingController search;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: AppTextField(
            controller: search,
            hint: context.tr('admin.users.search'),
            onChanged: onSearchChanged,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenH,
              0,
              AppSpacing.screenH,
              AppSpacing.xxl,
            ),
            itemCount: users.length,
            itemBuilder:
                (BuildContext context, int index) =>
                    AdminUserRow(user: users[index]),
          ),
        ),
      ],
    );
  }
}
