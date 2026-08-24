import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/dialog_helper.dart';

/// Quick-pick shortcuts shown above the manual start/end date fields.
enum _RangeShortcut {
  today('Today'),
  yesterday('Yesterday'),
  oneWeekAgo('1 Week Ago'),
  oneMonthAgo('1 Month Ago');

  const _RangeShortcut(this.label);

  final String label;

  DateTimeRange rangeFrom(DateTime today) {
    switch (this) {
      case _RangeShortcut.today:
        return DateTimeRange(start: today, end: today);
      case _RangeShortcut.yesterday:
        final yesterday = today.subtract(const Duration(days: 1));
        return DateTimeRange(start: yesterday, end: yesterday);
      case _RangeShortcut.oneWeekAgo:
        return DateTimeRange(
          start: today.subtract(const Duration(days: 7)),
          end: today,
        );
      case _RangeShortcut.oneMonthAgo:
        return DateTimeRange(
          start: DateTime(today.year, today.month - 1, today.day),
          end: today,
        );
    }
  }
}

/// Bottom sheet for picking the Riwayat header list's date range — either a
/// quick shortcut (Today / Yesterday / 1 Week Ago / 1 Month Ago) or a manual
/// start/end pick. Returns the chosen [DateTimeRange] on Apply, or `null` if
/// dismissed without applying.
class HistoryDateRangeFilterSheet extends StatefulWidget {
  const HistoryDateRangeFilterSheet({super.key, required this.initialRange});

  final DateTimeRange initialRange;

  static Future<DateTimeRange?> show(
    BuildContext context, {
    required DateTimeRange initialRange,
  }) {
    return showModalBottomSheet<DateTimeRange>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          HistoryDateRangeFilterSheet(initialRange: initialRange),
    );
  }

  @override
  State<HistoryDateRangeFilterSheet> createState() =>
      _HistoryDateRangeFilterSheetState();
}

class _HistoryDateRangeFilterSheetState
    extends State<HistoryDateRangeFilterSheet> {
  late DateTime _start;
  late DateTime _end;

  static DateTime _today() => DateFormatter.dateOnly(DateTime.now());

  static bool _isSameDay(DateTime a, DateTime b) =>
      DateFormatter.dateOnly(a) == DateFormatter.dateOnly(b);

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange.start;
    _end = widget.initialRange.end;
  }

  void _applyShortcut(_RangeShortcut shortcut) {
    final range = shortcut.rangeFrom(_today());
    setState(() {
      _start = range.start;
      _end = range.end;
    });
  }

  bool _isShortcutActive(_RangeShortcut shortcut) {
    final range = shortcut.rangeFrom(_today());
    return _isSameDay(range.start, _start) && _isSameDay(range.end, _end);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await DialogHelper.showCupertinoDatePicker(
      context,
      initialDate: isStart ? _start : _end,
      minDate: DateTime(2000),
      maxDate: _today(),
      label: isStart ? 'Start Date' : 'End Date',
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_start.isAfter(_end)) _start = _end;
      }
    });
  }

  void _reset() {
    final range = _RangeShortcut.oneWeekAgo.rangeFrom(_today());
    setState(() {
      _start = range.start;
      _end = range.end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const Expanded(
                  child: Text(
                    'Filter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final shortcut in _RangeShortcut.values) ...[
                  if (shortcut != _RangeShortcut.values.first)
                    const SizedBox(width: 8),
                  Expanded(
                    child: _ShortcutChip(
                      shortcut: shortcut,
                      active: _isShortcutActive(shortcut),
                      onTap: () => _applyShortcut(shortcut),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Start Date',
                    date: _start,
                    onTap: () => _pickDate(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'End Date',
                    date: _end,
                    onTap: () => _pickDate(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'RESET',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(DateTimeRange(start: _start, end: _end)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'APPLY',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.shortcut,
    required this.active,
    required this.onTap,
  });

  final _RangeShortcut shortcut;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Colors.white,
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          shortcut.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD6D6D6)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7B7B7B),
                fontSize: 11,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormatter.format(date),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
