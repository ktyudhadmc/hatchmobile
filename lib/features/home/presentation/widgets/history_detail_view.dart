import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/domain/entities/transfer_grade.dart';
import '../../../transfer/domain/entities/transfer_history_basket.dart';
import '../../../transfer/domain/entities/transfer_history_detail.dart';

class HistoryDetailView extends StatelessWidget {
  const HistoryDetailView({
    super.key,
    required this.detail,
    required this.hasHeaders,
  });

  final AsyncValue<TransferHistoryDetail?> detail;
  final bool hasHeaders;

  @override
  Widget build(BuildContext context) {
    return switch (detail) {
      AsyncError() => const _FillScrollView(
        child: _Placeholder(
          message: 'Gagal memuat detail riwayat',
          icon: Icons.error_outline,
        ),
      ),
      AsyncData(value: null) => _FillScrollView(
        child: _Placeholder(
          message: hasHeaders
              ? 'Pilih riwayat transfer untuk melihat detail'
              : 'Belum ada riwayat transfer',
          icon: Icons.history_rounded,
        ),
      ),
      AsyncData(value: final value) => _DetailContent(detail: value!),
      _ => const _FillScrollView(
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Makes non-list states (loading/empty/error) scrollable too, filling the
/// available height — so [RefreshIndicator]'s pull gesture has a
/// [Scrollable] to attach to even when there's no list to naturally scroll.
class _FillScrollView extends StatelessWidget {
  const _FillScrollView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: constraints.maxHeight, child: child),
          ],
        );
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
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
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final TransferHistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _SummaryCard(detail: detail),
        const SizedBox(height: 16),
        Text(
          'Daftar Basket',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ...detail.baskets.map((basket) => _BasketCard(basket: basket)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.detail});

  final TransferHistoryDetail detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffF5F8FA)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.transferCode,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          _infoRow('Tanggal', DateFormatter.format(detail.transferDate)),
          _infoRow('Cabang', detail.branch.name),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: 'Dikirim',
                  value: detail.basketSendCount,
                  color: AppTheme.primaryColor,
                ),
              ),
              Expanded(
                child: _StatTile(
                  label: 'Diterima',
                  value: detail.basketReceiveCount,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),
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
          Text(label, style: const TextStyle(color: Color(0xFF7B7B7B))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7B7B7B),
            fontSize: 12,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ],
    );
  }
}

class _BasketCard extends StatelessWidget {
  const _BasketCard({required this.basket});

  final TransferHistoryBasket basket;

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
