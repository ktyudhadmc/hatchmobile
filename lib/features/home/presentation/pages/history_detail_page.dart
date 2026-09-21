import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/domain/entities/transfer_grade.dart';
import '../../../transfer/domain/entities/transfer_history/entities.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';
import '../widgets/history_basket_filter.dart';
import 'history_basket_filter_page.dart';

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
  final _sheetController = DraggableScrollableController();

  HistoryBasketFilter _filter = const HistoryBasketFilter();

  @override
  void initState() {
    super.initState();
    // Deferred to after the first frame: writing to a provider's .state
    // synchronously inside initState happens while the widget tree is
    // still building, which Riverpod disallows (other widgets watching
    // the same provider could rebuild mid-build with inconsistent state).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(selectedTransferCodeProvider.notifier).state =
          widget.header.transferCode;
      ref.read(historyDetailProvider.notifier).load(widget.header.transferCode);
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  /// Drives the sheet by hand from a drag on the handle bar / header —
  /// that area sits outside the sheet's scrollable content, so it isn't
  /// wired into DraggableScrollableSheet's own drag-to-resize by default.
  void _onHandleDragUpdate(DragUpdateDetails details, double screenHeight) {
    final next = _sheetController.size - details.primaryDelta! / screenHeight;
    _sheetController.jumpTo(next.clamp(0.0, 1.0));
  }

  /// Snaps to whichever end (min/max) the sheet is closer to on release —
  /// mirrors DraggableScrollableSheet's own `snap: true` behavior, which
  /// only applies to drags that originate on its scrollable content.
  void _onHandleDragEnd(
    DragEndDetails details,
    double minSize,
    double maxSize,
  ) {
    final mid = (minSize + maxSize) / 2;
    final target = _sheetController.size >= mid ? maxSize : minSize;
    _sheetController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _openFilterPage() async {
    final result = await HistoryBasketFilterPage.show(
      context,
      initialFilter: _filter,
    );
    if (result != null) setState(() => _filter = result);
  }

  List<TransferHistoryDetail> _applyFilter(
    List<TransferHistoryDetail> baskets,
  ) {
    var filtered = baskets;

    if (_filter.statuses.isNotEmpty) {
      filtered = filtered.where((basket) {
        final isReceived = basket.receivedAt != null;
        return _filter.statuses.contains(
          isReceived
              ? BasketStatusFilter.received
              : BasketStatusFilter.notReceived,
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
    final screenHeight = MediaQuery.of(context).size.height;

    // Cap the sheet's drag-up at just below the AppBar, instead of nearly
    // covering it — the AppBar (back button/title) must stay reachable.
    final appBarReservedHeight =
        MediaQuery.of(context).padding.top + kToolbarHeight;

    final minSize = appBarReservedHeight + _BalanceCard.minVisibleHeight;
    final sheetMaxSize = 1 - (appBarReservedHeight / screenHeight);
    final sheetMinSize = 1 - (minSize / screenHeight);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Detail Transfer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          _BalanceCard(header: widget.header),
          Positioned.fill(
            child: DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: sheetMinSize,
              minChildSize: sheetMinSize,
              maxChildSize: sheetMaxSize,
              snap: true,
              builder: (context, scrollController) {
                return _BasketSheet(
                  detail: detail,
                  filter: _filter,
                  filteredBaskets: switch (detail) {
                    AsyncData(value: final baskets) => _applyFilter(baskets),
                    _ => const [],
                  },
                  onSearchTap: _openFilterPage,
                  scrollController: scrollController,
                  onHandleDragUpdate: (details) =>
                      _onHandleDragUpdate(details, screenHeight),
                  onHandleDragEnd: (details) =>
                      _onHandleDragEnd(details, sheetMinSize, sheetMaxSize),
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
/// the transfer's summary the way a banking app shows the balance behind
/// its transaction list.
///
/// Laid out as a 2×2 grid, everything left-aligned: Transfer Date sits
/// above Shipped in the left column, Branch sits above Received in the
/// right column.
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.header});

  final TransferHistory header;

  /// Content height below the AppBar, from the card's own top padding down
  /// past the Shipped/Received row (plus [_trailingGap]/[_adjustmentHeight]
  /// slack) — i.e. everything [HistoryDetailPage] needs to keep visible
  /// when the sheet is collapsed to its minimum. Approximate (text
  /// line-heights aren't measured), but close enough that the collapsed
  /// sheet snaps in right under the grid instead of clipping it.
  static const double minVisibleHeight =
      _topGap +
      _codeLineHeight +
      _gapAfterCode +
      _gridRowHeight +
      _gapBetweenGridRows +
      _gridRowHeight +
      _trailingGap +
      _adjustmentHeight;

  static const double _topGap = 4;
  static const double _codeLineHeight = 26; // fontSize 20, bold
  static const double _gapAfterCode = 16;
  // label(12) + gap(4) + value — shared by both grid rows even though the
  // second row's value is bigger (24 vs 16), so this stays a slight
  // over-estimate rather than needing two separate constants.
  static const double _gridRowHeight = 50;
  static const double _gapBetweenGridRows = 8;
  static const double _trailingGap = 20;
  static const double _adjustmentHeight = 64;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + kToolbarHeight + _topGap,
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
          const SizedBox(height: _gapAfterCode),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceStat(
                      label: 'Transfer Date',
                      value: DateFormatter.format(header.transferDate),
                      valueFontSize: 16,
                    ),
                    const SizedBox(height: _gapBetweenGridRows),
                    _BalanceStat(
                      label: 'Shipped',
                      value: (header.sentbasketCount ?? 0).toString(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BalanceStat(
                      label: 'Branch',
                      value: header.branch,
                      valueFontSize: 16,
                    ),
                    const SizedBox(height: _gapBetweenGridRows),
                    _BalanceStat(
                      label: 'Received',
                      value: (header.receivedBasketCount ?? 0).toString(),
                    ),
                  ],
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
  const _BalanceStat({
    required this.label,
    required this.value,
    this.valueFontSize = 24,
  });

  final String label;
  final String value;
  final double valueFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
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
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
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
    required this.onHandleDragUpdate,
    required this.onHandleDragEnd,
  });

  final AsyncValue<List<TransferHistoryDetail>> detail;
  final HistoryBasketFilter filter;
  final List<TransferHistoryDetail> filteredBaskets;
  final VoidCallback onSearchTap;
  final ScrollController scrollController;

  // The handle bar + header row sit above the ListView, outside its
  // scrollable viewport, so DraggableScrollableSheet's built-in
  // drag-to-resize (which is wired through the scroll controller) never
  // sees gestures that start here — these drive the sheet manually instead.
  final ValueChanged<DragUpdateDetails> onHandleDragUpdate;
  final ValueChanged<DragEndDetails> onHandleDragEnd;

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
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: onHandleDragUpdate,
            onVerticalDragEnd: onHandleDragEnd,
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
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
                  AsyncData() when filteredBaskets.isEmpty =>
                    const _Placeholder(
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              _StatusChip(
                label: isReceived
                    ? DateFormatter.format(basket.receivedAt!)
                    : 'Not received yet',
                color: isReceived
                    ? AppTheme.successColor
                    : AppTheme.warningColor,
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
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
