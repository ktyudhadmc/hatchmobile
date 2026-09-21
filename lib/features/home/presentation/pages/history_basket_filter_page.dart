import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/molecules/checkbox_group.dart';
import '../widgets/history_basket_filter.dart';

/// Full-page filter for "List of Basket" — status checkboxes on top,
/// search field below, Reset/Apply pinned at the bottom. A full page
/// instead of a modal sheet on purpose: [HistoryDetailPage] already shows
/// the basket list in a [DraggableScrollableSheet], and stacking a modal
/// sheet on top of that sheet reads as a confusing double bottom-sheet.
/// Returns the applied [HistoryBasketFilter] via [Navigator.pop], or
/// `null` if dismissed without applying.
class HistoryBasketFilterPage extends StatefulWidget {
  const HistoryBasketFilterPage({super.key, required this.initialFilter});

  final HistoryBasketFilter initialFilter;

  static Future<HistoryBasketFilter?> show(
    BuildContext context, {
    required HistoryBasketFilter initialFilter,
  }) {
    return Navigator.of(context).push<HistoryBasketFilter>(
      MaterialPageRoute(
        builder: (context) =>
            HistoryBasketFilterPage(initialFilter: initialFilter),
      ),
    );
  }

  @override
  State<HistoryBasketFilterPage> createState() =>
      _HistoryBasketFilterPageState();
}

class _HistoryBasketFilterPageState extends State<HistoryBasketFilterPage> {
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
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Basket')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Status',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF7B7B7B),
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              CheckboxGroup<BasketStatusFilter>(
                options: BasketStatusFilter.values
                    .map(
                      (status) => CheckboxOption(
                        value: status,
                        label: status.label,
                      ),
                    )
                    .toList(),
                selected: _statuses,
                onChanged: (next) => setState(() => _statuses = next),
                // Vertical (one status per row) with a small gap — swap
                // `direction`/`spacing` here if this list ever wants to
                // read as a horizontal row of chips-like checkboxes instead.
                direction: Axis.vertical,
                spacing: 4,
              ),
              const SizedBox(height: 16),
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
              const Spacer(),
              // Stacked top/bottom (Reset above Apply), matching
              // HistoryDateRangeFilterSheet's button layout instead of a
              // side-by-side row.
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
        ),
      ),
    );
  }
}
