import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/refreshable_view.dart';
import '../../../../shared/widgets/sheets/expandable_bottom_sheet.dart';
import '../../domain/entities/transfer_recent/entities.dart';
import '../providers/transfer_provider.dart';

typedef _ReceivedEntry = ({TransferRecent transfer, TransferRecentBasket basket});

/// Baskets this hatchery has received, straight from the backend — no
/// local/client-side tracking. A failed confirm just isn't in this list
/// until the user retries and it succeeds. Collapsed to just its title by
/// default; the user drags it up to see the list.
class ScannedBasketsList extends ConsumerWidget {
  const ScannedBasketsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentsReceiveProvider);
    final transfers = recents.valueOrNull ?? const <TransferRecent>[];
    final entries = <_ReceivedEntry>[
      for (final transfer in transfers)
        for (final basket in transfer.baskets ?? const <TransferRecentBasket>[])
          (transfer: transfer, basket: basket),
    ];

    final screenHeight = MediaQuery.of(context).size.height;

    final minSizeFraction = (screenHeight * 0.18 / screenHeight);
    final maxSizeFraction = (screenHeight * 0.5 / screenHeight);
    return ExpandableInfoSheet(
      title: 'Keranjang diterima',
      minSizeFraction: minSizeFraction,
      maxSizeFraction: maxSizeFraction,
      // Deliberately not using the scrollController the sheet builder hands
      // out: attaching it to a scrollable opts into DraggableScrollableSheet's
      // own scroll-linked resize, which intercepts the pull-down gesture at
      // the top of the list to resize the sheet instead of letting it reach
      // RefreshIndicator as an overscroll. Resize is already fully handled
      // by the header's own GestureDetector, so the content list gets its
      // own independent controller and behaves like a normal refreshable list.
      contentBuilder: (context, scrollController) {
        return RefreshableView(
          onRefresh: () => ref.read(recentsReceiveProvider.notifier).fetch(),
          child: entries.isNotEmpty
              ? ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) => _BasketTile(
                    transfer: entries[index].transfer,
                    basket: entries[index].basket,
                  ),
                )
              : ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 200,
                      child: recents is AsyncLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const _EmptyState(),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Belum ada basket yang di-scan',
        style: TextStyle(
          color: Color(0xFF7B7B7B),
          fontFamily: AppTheme.fontFamily,
        ),
      ),
    );
  }
}

class _BasketTile extends StatelessWidget {
  const _BasketTile({required this.transfer, required this.basket});

  final TransferRecent transfer;
  final TransferRecentBasket basket;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.successColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    basket.basketCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
              Text(
                transfer.transferCode,
                style: const TextStyle(
                  color: Color(0xFF7B7B7B),
                  fontSize: 11,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Discan oleh ${basket.blamed.receivedBy}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7B7B7B),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
              Text(
                transfer.branch,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.fontFamily,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
