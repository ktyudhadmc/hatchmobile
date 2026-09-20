import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/domain/entities/transfer_history/entities.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';

/// Sliver form of the history list, meant to sit inside the [CustomScrollView]
/// that [RefreshableView] builds — so pulling down drags this content with
/// it instead of a Material spinner floating over a separate scrollable.
class HistoryHeaderList extends ConsumerWidget {
  const HistoryHeaderList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headersState = ref.watch(historyHeadersProvider);
    final headers = headersState.valueOrNull ?? const [];

    if (headersState.isLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (headersState.hasError) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _Placeholder(
          message: 'Error loading details',
          icon: Icons.error_outline,
        ),
      );
    }

    if (headers.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _Placeholder(
          message: 'This transfer is empty',
          icon: Icons.history_rounded,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      sliver: SliverList.separated(
        itemCount: headers.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) => _HeaderCard(
          header: headers[index],
          onTap: () =>
              context.push('/history-detail', extra: headers[index]),
        ),
      ),
    );
  }
}

/// Received / Partial / Not Received badge next to the transfer code —
/// lets the list be scanned at a glance without opening each detail sheet.
class _ReceivedStatusBadge extends StatelessWidget {
  const _ReceivedStatusBadge({required this.header});

  final TransferHistory header;

  @override
  Widget build(BuildContext context) {
    final sent = header.sentbasketCount ?? 0;
    final received = header.receivedBasketCount ?? 0;

    final String label;
    final Color color;
    if (received <= 0) {
      label = 'Not Received';
      color = AppTheme.errorColor;
    } else if (sent > 0 && received >= sent) {
      label = 'Received';
      color = AppTheme.successColor;
    } else {
      label = 'Partial';
      color = AppTheme.warningColor;
    }

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
          fontFamily: AppTheme.fontFamily,
        ),
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.header, required this.onTap});

  final TransferHistory header;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffF5F8FA)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Color(0x19000000), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          header.transferCode,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: AppTheme.fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _ReceivedStatusBadge(header: header),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormatter.format(header.transferDate),
                    style: const TextStyle(
                      color: Color(0xFF7B7B7B),
                      fontSize: 12,
                      fontFamily: AppTheme.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  header.branch,
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
                Text(
                  'Shipped ${header.sentbasketCount} · Received ${header.receivedBasketCount ?? 0}',
                  style: const TextStyle(
                    color: Color(0xFF7B7B7B),
                    fontSize: 12,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
