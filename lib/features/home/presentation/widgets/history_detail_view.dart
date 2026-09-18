import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/domain/entities/transfer_grade.dart';
import '../../../transfer/domain/entities/transfer_history/entities.dart';

/// Detail panel for one Riwayat header. [header] is already in hand from
/// the list that was tapped, so the summary (code/date/branch/counts)
/// renders immediately; [detail] is the riwayat-detail API call in flight
/// for [header.transferCode]'s received baskets.
class HistoryDetailView extends StatelessWidget {
  const HistoryDetailView({
    super.key,
    required this.header,
    required this.detail,
    this.scrollController,
  });

  final TransferHistory header;
  final AsyncValue<List<TransferHistoryDetail>> detail;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    // header comes straight from props (already in hand before this widget
    // even builds), so it's safe to pin it outside the scroll area — only
    // the basket list, which depends on the in-flight detail fetch, needs
    // to scroll.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryCard(header: header),
              const SizedBox(height: 16),
              Text(
                'List of Basket',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          // showModalBottomSheet doesn't add safe-area insets on its own
          // (useSafeArea defaults to false), and on gesture-nav Android
          // MediaQuery.padding.bottom often reports 0 — so `minimum` is
          // what actually keeps the last card clear of the system nav bar.
          child: SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 16),
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
                  AsyncData(value: final baskets) => Column(
                    children: baskets
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
        ),
      ],
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.header});

  final TransferHistory header;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header.transferCode,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 6),
          _infoRow('Transfer date', DateFormatter.format(header.transferDate)),
          _infoRow('Farm', header.branch),
          _infoRow('Shipped', (header.sentbasketCount ?? 0).toString()),
          _infoRow('Received', (header.receivedBasketCount ?? 0).toString()),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ],
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
