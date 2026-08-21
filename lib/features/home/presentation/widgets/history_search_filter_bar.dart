import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transfer/presentation/providers/transfer_provider.dart';

const _monthOptions = [1, 3, 6];

/// Search field (transfer code / branch) + "last N months" filter, opened
/// via a bottom sheet. Both write straight into [historySearchQueryProvider]
/// / [historyMonthsFilterProvider], which [filteredHistoryHeadersProvider]
/// combines.
class HistorySearchFilterBar extends ConsumerWidget {
  const HistorySearchFilterBar({super.key});

  Future<void> _openMonthsFilter(BuildContext context, WidgetRef ref) async {
    final current = ref.read(historyMonthsFilterProvider);

    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (context) => _MonthsFilterSheet(selected: current),
    );

    if (selected != null) {
      ref.read(historyMonthsFilterProvider.notifier).state = selected;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final months = ref.watch(historyMonthsFilterProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) =>
                  ref.read(historySearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Cari kode transfer atau cabang',
                hintStyle: const TextStyle(color: Color(0xFF7B7B7B)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF7B7B7B)),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _openMonthsFilter(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD6D6D6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.filter_list,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$months Bln',
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
        ],
      ),
    );
  }
}

class _MonthsFilterSheet extends StatelessWidget {
  const _MonthsFilterSheet({required this.selected});

  final int selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Data Terakhir',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 4),
            for (final months in _monthOptions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '$months Bulan Terakhir',
                  style: const TextStyle(fontFamily: AppTheme.fontFamily),
                ),
                trailing: months == selected
                    ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                    : const Icon(Icons.circle_outlined, color: Color(0xFFD6D6D6)),
                onTap: () => Navigator.of(context).pop(months),
              ),
          ],
        ),
      ),
    );
  }
}
