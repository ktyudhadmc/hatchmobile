import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/transfer_basket.dart';
import '../providers/transfer_provider.dart';

/// Baskets this hatchery has received, straight from the backend — no
/// local/client-side tracking. A failed confirm just isn't in this list
/// until the user retries and it succeeds.
class ScannedBasketsList extends ConsumerWidget {
  const ScannedBasketsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final received = ref.watch(receivedBasketsProvider);
    final baskets = received.valueOrNull ?? const <TransferBasket>[];
    final scannedByName = ref.watch(authProvider).valueOrNull?.name;

    return Column(
      children: [
        _RecapHeader(receivedCount: baskets.length),
        Expanded(
          child: switch (received) {
            AsyncData(value: final value) when value.isEmpty => const _EmptyState(),
            AsyncError() => const _EmptyState(),
            _ when baskets.isNotEmpty => ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: baskets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 6),
                itemBuilder: (context, index) =>
                    _BasketTile(basket: baskets[index], scannedByName: scannedByName),
              ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ],
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
        style: TextStyle(color: Color(0xFF7B7B7B), fontFamily: AppTheme.fontFamily),
      ),
    );
  }
}

class _RecapHeader extends StatelessWidget {
  const _RecapHeader({required this.receivedCount});

  final int receivedCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xffF5F8FA))),
      ),
      child: Row(
        children: [
          Text(
            '$receivedCount',
            style: const TextStyle(
              color: AppTheme.successColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Keranjang diterima',
            style: TextStyle(
              color: Color(0xFF7B7B7B),
              fontSize: 12,
              fontFamily: AppTheme.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

class _BasketTile extends StatelessWidget {
  const _BasketTile({required this.basket, required this.scannedByName});

  final TransferBasket basket;
  final String? scannedByName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    basket.basketCode,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                  ),
                ],
              ),
              Text(
                basket.transfer.transferCode,
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
                  scannedByName != null ? 'Discan oleh $scannedByName' : '',
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
                basket.transfer.branch.name,
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
