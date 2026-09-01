import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/string_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/buttons/primary_button.dart';
import '../../../core/widgets/section_eyebrow.dart';
import 'dob_wheel.dart';

/// The date of birth picker.
///
/// Deliberately not `showDatePicker`: a Material calendar arrives with its own
/// surface, type and accent and reads as another app's dialog. Three wheels on
/// the navy sheet, the selected row held in a gold band, the app's own type
/// throughout.
///
/// Month names come from the active locale rather than the string tables, so
/// Portuguese reads "Março" without twelve more keys to keep in step.
class DobPickerSheet extends StatefulWidget {
  const DobPickerSheet._({required this.initial});

  final DateTime initial;

  /// Opens the picker and resolves to the chosen date, or null if dismissed.
  static Future<DateTime?> show({
    required BuildContext context,
    DateTime? initial,
  }) {
    final DateTime now = DateTime.now();
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      builder:
          (BuildContext context) => DobPickerSheet._(
            initial:
                initial ??
                DateTime(
                  now.year - AppConstants.minimumAgeYears,
                  now.month,
                  now.day,
                ),
          ),
    );
  }

  @override
  State<DobPickerSheet> createState() => _DobPickerSheetState();
}

class _DobPickerSheetState extends State<DobPickerSheet> {
  late int _day = widget.initial.day;
  late int _month = widget.initial.month;
  late int _year = widget.initial.year;

  /// Newest year offered: anyone younger cannot register.
  static int get _lastYear =>
      DateTime.now().year - AppConstants.minimumAgeYears;

  static int get _firstYear => DateTime.now().year - AppConstants.maxAgeYears;

  int get _daysInMonth => DateTime(_year, _month + 1, 0).day;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SectionEyebrow(label: context.tr('auth.field.dob'), withRule: true),
            const SizedBox(height: AppSpacing.md),
            Row(children: _wheels(context)),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: context.tr('common.done'),
              onPressed:
                  () =>
                      Navigator.of(context).pop(DateTime(_year, _month, _day)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _wheels(BuildContext context) {
    return <Widget>[
      Expanded(
        flex: 2,
        child: DobWheel(
          label: context.tr('auth.dob.day'),
          values: <String>[for (int d = 1; d <= _daysInMonth; d++) '$d'],
          selected: _day - 1,
          onSelected: (int i) => setState(() => _day = i + 1),
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        flex: 3,
        child: DobWheel(
          label: context.tr('auth.dob.month'),
          values: _monthNames(context.localeCode),
          selected: _month - 1,
          onSelected: _selectMonth,
        ),
      ),
      const SizedBox(width: AppSpacing.xs),
      Expanded(
        flex: 2,
        child: DobWheel(
          label: context.tr('auth.dob.year'),
          values: <String>[for (int y = _lastYear; y >= _firstYear; y--) '$y'],
          selected: _lastYear - _year,
          onSelected:
              (int i) => setState(() {
                _year = _lastYear - i;
                _day = _day.clamp(1, _daysInMonth);
              }),
        ),
      ),
    ];
  }

  void _selectMonth(int index) {
    setState(() {
      _month = index + 1;
      _day = _day.clamp(1, _daysInMonth);
    });
  }

  /// Month names in the active language, capitalised: Portuguese lowercases
  /// them and this is a column heading, not a sentence.
  List<String> _monthNames(String localeCode) {
    final DateFormat format = DateFormat.MMMM(localeCode);
    return <String>[
      for (int m = 1; m <= 12; m++)
        _capitalised(format.format(DateTime(2000, m))),
    ];
  }

  String _capitalised(String value) =>
      value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
}
