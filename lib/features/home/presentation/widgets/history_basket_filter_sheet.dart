import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import 'history_basket_filter.dart';

/// Filter sheet for "List of Basket" — status checkboxes on top, search
/// field at the bottom, Reset/Apply pinned below. Returns the applied
/// [HistoryBasketFilter], or `null` if dismissed without applying.
class HistoryBasketFilterSheet extends StatefulWidget {
  const HistoryBasketFilterSheet({super.key, required this.initialFilter});

  final HistoryBasketFilter initialFilter;

  static Future<HistoryBasketFilter?> show(
    BuildContext context, {
    required HistoryBasketFilter initialFilter,
  }) {
    return showModalBottomSheet<HistoryBasketFilter>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          HistoryBasketFilterSheet(initialFilter: initialFilter),
    );
  }

  @override
  State<HistoryBasketFilterSheet> createState() =>
      _HistoryBasketFilterSheetState();
}

class _HistoryBasketFilterSheetState extends State<HistoryBasketFilterSheet> {
  late final TextEditingController _searchController;
  late Set<BasketStatusFilter> _statuses;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialFilter.query);
    _statuses = {...widget.initialFilter.statuses};
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleStatus(BasketStatusFilter status, bool? checked) {
    setState(() {
      if (checked ?? false) {
        _statuses.add(status);
      } else {
        _statuses.remove(status);
      }
    });
  }

  void _reset() {
    setState(() {
      _statuses.clear();
      _searchController.clear();
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      HistoryBasketFilter(
        query: _searchController.text.trim(),
        statuses: _statuses,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 4,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Basket',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Status',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF7B7B7B),
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            ...BasketStatusFilter.values.map(
              (status) => CheckboxListTile(
                value: _statuses.contains(status),
                onChanged: (checked) => _toggleStatus(status, checked),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
                activeColor: AppTheme.primaryColor,
                title: Text(
                  status.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Search',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF7B7B7B),
                fontFamily: AppTheme.fontFamily,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              style: const TextStyle(fontSize: 13, fontFamily: AppTheme.fontFamily),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Search basket code...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFD6D6D6)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
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
          ],
        ),
      ),
    );
  }
}
