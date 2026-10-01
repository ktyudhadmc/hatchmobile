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
          // No viewInsets.bottom here: Scaffold already resizes its body for
          // the keyboard, so adding it again pushed Reset/Apply up.
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SingleChildScrollView(child: _buildFilterFields())),
              const SizedBox(height: 16),
              // Stacked top/bottom (Reset above Apply), matching
              // HistoryDateRangeFilterSheet's button layout instead of a
              // side-by-side row.
              _FilterButton.outlined(label: 'RESET', onPressed: _reset),
              const SizedBox(height: 8),
              _FilterButton.filled(label: 'APPLY', onPressed: _apply),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Status'),
        const SizedBox(height: 8),
        CheckboxGroup<BasketStatusFilter>(
          options: BasketStatusFilter.values
              .map((s) => CheckboxOption(value: s, label: s.label))
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
        const _SectionLabel('Search'),
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
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Color(0xFF7B7B7B),
        fontFamily: AppTheme.fontFamily,
      ),
    );
  }
}

/// Full-width Reset/Apply button — the two only differ in fill vs outline.
class _FilterButton extends StatelessWidget {
  const _FilterButton.outlined({required this.label, required this.onPressed})
    : _filled = false;
  const _FilterButton.filled({required this.label, required this.onPressed})
    : _filled = true;

  final String label;
  final VoidCallback onPressed;
  final bool _filled;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));
    const padding = EdgeInsets.symmetric(vertical: 16);
    final text = Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontFamily: AppTheme.fontFamily,
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: _filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: shape,
                padding: padding,
              ),
              child: text,
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.primaryColor),
                shape: shape,
                padding: padding,
              ),
              child: text,
            ),
    );
  }
}
