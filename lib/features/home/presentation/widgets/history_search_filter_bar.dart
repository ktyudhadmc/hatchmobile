import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';
import 'history_date_range_filter_sheet.dart';

/// Date-range filter for the Riwayat header list, opened via a bottom
/// sheet. Writes straight into [historyDateRangeProvider].
class HistorySearchFilterBar extends ConsumerWidget {
  const HistorySearchFilterBar({super.key});

  Future<void> _openDateRangeFilter(BuildContext context, WidgetRef ref) async {
    final current = ref.read(historyDateRangeProvider);

    final selected = await HistoryDateRangeFilterSheet.show(
      context,
      initialRange: current,
    );

    if (selected != null) {
      ref.read(historyDateRangeProvider.notifier).state = selected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(historyDateRangeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: GestureDetector(
        onTap: () => _openDateRangeFilter(context, ref),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD6D6D6)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.filter_list,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormatter.format(range.start)} - '
                '${DateFormatter.format(range.end)}',
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
