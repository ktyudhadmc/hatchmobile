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
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _SummaryCard(header: header),
        const SizedBox(height: 16),
        Text('Daftar Basket', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        switch (detail) {
          AsyncError() => const _Placeholder(
            message: 'Gagal memuat detail riwayat',
            icon: Icons.error_outline,
          ),
          AsyncData(value: final baskets) when baskets.isEmpty =>
            const _Placeholder(
              message: 'Belum ada basket diterima',
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _infoRow('Transfer date', DateFormatter.format(header.transferDate)),
          _infoRow('Farm', header.branch),
          _infoRow('Shipped', (header.sentbasketCount ?? 0).toString()),
          _infoRow('Received', (header.sentbasketCount ?? 0).toString()),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffF5F8FA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                basket.basketCode,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                basket.receivedAt != null
                    ? DateFormatter.format(basket.receivedAt!)
                    : 'Belum diterima',
                style: TextStyle(
                  color: basket.receivedAt != null
                      ? AppTheme.successColor
                      : AppTheme.warningColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...basket.grades.map(_buildGradeRow),
        ],
      ),
    );
  }

  Widget _buildGradeRow(TransferGrade grade) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Grade ${grade.grade}',
            style: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 12),
          ),
          Text(
            'Dikirim ${grade.quantity} · Diterima ${grade.receivedQuantity ?? 0}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
