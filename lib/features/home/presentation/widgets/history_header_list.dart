import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transfer/domain/entities/transfer_history/entities.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';
import 'history_detail_sheet.dart';

class HistoryHeaderList extends ConsumerWidget {
  const HistoryHeaderList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headersState = ref.watch(historyHeadersProvider);
    final headers = ref.watch(filteredHistoryHeadersProvider);

    if (headersState.isLoading) {
      return const _FillScrollView(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (headersState.hasError) {
      return const _FillScrollView(
        child: _Placeholder(
          message: 'Gagal memuat riwayat transfer',
          icon: Icons.error_outline,
        ),
      );
    }

    if (headers.isEmpty) {
      final hasAnyHeaders = (headersState.valueOrNull ?? const []).isNotEmpty;
      return _FillScrollView(
        child: _Placeholder(
          message: hasAnyHeaders
              ? 'Tidak ada riwayat yang cocok'
              : 'Belum ada riwayat transfer',
          icon: Icons.history_rounded,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: headers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _HeaderCard(
        header: headers[index],
        onTap: () => showHistoryDetailSheet(context, ref, headers[index]),
      ),
    );
  }
}

class _FillScrollView extends StatelessWidget {
  const _FillScrollView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [SizedBox(height: constraints.maxHeight, child: child)],
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
          boxShadow: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    header.transferCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.fontFamily,
                    ),
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
                  'Received: ${header.receivedBasketCount ?? 0}',
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
