import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/domain/entities/transfer_grade.dart';
import '../../../transfer/domain/entities/transfer_history/entities.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';
import '../widgets/history_basket_filter.dart';
import '../widgets/history_basket_filter_sheet.dart';

/// Full-page Riwayat detail — a "balance + transaction history" layout
/// (à la a banking app's saldo page): [header]'s summary pinned at the top
/// as a colored card, with the basket list living in a [DraggableScrollableSheet]
/// the user can drag up for more room or down to a minimum peek height,
/// never fully hidden.
class HistoryDetailPage extends ConsumerStatefulWidget {
  const HistoryDetailPage({super.key, required this.header});

  final TransferHistory header;

  @override
  ConsumerState<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends ConsumerState<HistoryDetailPage> {
  static const double _sheetMinSize = 0.4;
  static const double _sheetInitialSize = 0.62;
  static const double _sheetMaxSize = 0.94;

  HistoryBasketFilter _filter = const HistoryBasketFilter();

  @override
  void initState() {
    super.initState();
    ref.read(selectedTransferCodeProvider.notifier).state =
        widget.header.transferCode;
    ref.read(historyDetailProvider.notifier).load(widget.header.transferCode);
  }

  Future<void> _openFilterSheet() async {
    final result = await HistoryBasketFilterSheet.show(
      context,
      initialFilter: _filter,
    );
    if (result != null) setState(() => _filter = result);
  }

  List<TransferHistoryDetail> _applyFilter(List<TransferHistoryDetail> baskets) {
    var filtered = baskets;

    if (_filter.statuses.isNotEmpty) {
      filtered = filtered.where((basket) {
        final isReceived = basket.receivedAt != null;
        return _filter.statuses.contains(
          isReceived ? BasketStatusFilter.received : BasketStatusFilter.notReceived,
        );
      }).toList();
    }

    if (_filter.query.isNotEmpty) {
      final query = _filter.query.toLowerCase();
      filtered = filtered
          .where((basket) => basket.basketCode.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(historyDetailProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Transfer', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          _BalanceCard(header: widget.header),
          Positioned.fill(
            child: DraggableScrollableSheet(
              initialChildSize: _sheetInitialSize,
              minChildSize: _sheetMinSize,
              maxChildSize: _sheetMaxSize,
              snap: true,
              // min/maxChildSize are already implicit snap points — listing
              // them again in snapSizes trips DraggableScrollableSheet's
              // "no duplicates of min/max" assertion, so only the initial
              // (middle) size goes here.
              snapSizes: const [_sheetInitialSize],
              builder: (context, scrollController) {
                return _BasketSheet(
                  detail: detail,
                  filter: _filter,
                  filteredBaskets: switch (detail) {
                    AsyncData(value: final baskets) => _applyFilter(baskets),
                    _ => const [],
                  },
                  onSearchTap: _openFilterSheet,
                  scrollController: scrollController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// The "saldo" card — colored, pinned behind the draggable sheet, showing
/// the transfer's summary (code/date/branch/shipped/received) the way a
/// banking app shows the balance behind its transaction list.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.header});

  final TransferHistory header;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + kToolbarHeight + 4,
        20,
        32,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, Color(0xff1F4433)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header.transferCode,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormatter.format(header.transferDate)} · ${header.branch}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _BalanceStat(
                  label: 'Shipped',
                  value: (header.sentbasketCount ?? 0).toString(),
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              Expanded(
                child: _BalanceStat(
                  label: 'Received',
                  value: (header.receivedBasketCount ?? 0).toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  const _BalanceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

/// The draggable "riwayat transaksi"-style sheet holding the basket list —
/// a handle bar up top, the section header with the filter button, then
/// the (filtered) list itself.
class _BasketSheet extends StatelessWidget {
  const _BasketSheet({
    required this.detail,
    required this.filter,
    required this.filteredBaskets,
    required this.onSearchTap,
    required this.scrollController,
  });

  final AsyncValue<List<TransferHistoryDetail>> detail;
  final HistoryBasketFilter filter;
  final List<TransferHistoryDetail> filteredBaskets;
  final VoidCallback onSearchTap;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 12)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD6D6D6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 4),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'List of Basket',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: filter.isActive
                        ? AppTheme.primaryColor
                        : Colors.black87,
                  ),
                  tooltip: 'Search / filter basket',
                  onPressed: onSearchTap,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                switch (detail) {
                  AsyncError() => const _Placeholder(
                    message: 'Error loading details',
                    icon: Icons.error_outline,
                  ),
                  AsyncData(value: final baskets) when baskets.isEmpty =>
                    const _Placeholder(
                      message: 'This transfer is empty',
                      icon: Icons.inventory_2_outlined,
                    ),
                  AsyncData() when filteredBaskets.isEmpty => const _Placeholder(
                    message: 'No basket matches your filter',
                    icon: Icons.search_off_rounded,
                  ),
                  AsyncData() => Column(
                    children: filteredBaskets
                        .map((basket) => _BasketCard(basket: basket))
                        .toList(),
                  ),
                  _ => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                },
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF7B7B7B)),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7B7B7B),
                fontFamily: AppTheme.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasketCard extends StatelessWidget {
  const _BasketCard({required this.basket});

  final TransferHistoryDetail basket;

  @override
  Widget build(BuildContext context) {
    final isReceived = basket.receivedAt != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffF5F8FA)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                basket.basketCode,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              _StatusChip(
                label: isReceived
                    ? DateFormatter.format(basket.receivedAt!)
                    : 'Not received yet',
                color: isReceived ? AppTheme.successColor : AppTheme.warningColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...basket.grades.map(
            (grade) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: _buildGradeRow(grade),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeRow(TransferGrade grade) {
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            grade.grade,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            grade.henhouse ?? '-',
            style: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 11),
          ),
        ),
        Text(
          'Shipped ${grade.quantity} · Received ${grade.receivedQuantity ?? 0}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}
