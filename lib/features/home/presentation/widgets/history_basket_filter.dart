/// Per-basket received status, checkable in [HistoryBasketFilterSheet].
enum BasketStatusFilter {
  received('Received'),
  notReceived('Not Received');

  const BasketStatusFilter(this.label);

  final String label;
}

/// Search text + status checkboxes applied to the "List of Basket" section
/// on [HistoryDetailPage]. An empty [statuses] set means "no status filter"
/// (show every basket), matching the sheet's default state.
class HistoryBasketFilter {
  const HistoryBasketFilter({
    this.query = '',
    this.statuses = const {},
  });

  final String query;
  final Set<BasketStatusFilter> statuses;

  bool get isActive => query.isNotEmpty || statuses.isNotEmpty;

  HistoryBasketFilter copyWith({String? query, Set<BasketStatusFilter>? statuses}) {
    return HistoryBasketFilter(
      query: query ?? this.query,
      statuses: statuses ?? this.statuses,
    );
  }
}
