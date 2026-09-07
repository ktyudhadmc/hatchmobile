import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transfer/domain/entities/transfer_history/entities.dart';
import '../../../transfer/presentation/providers/transfer_history_provider.dart';
import 'history_detail_view.dart';

/// Opens [header]'s detail in a draggable bottom sheet, triggering the
/// riwayat-detail API call for its basket list via [historyDetailProvider].
Future<void> showHistoryDetailSheet(
  BuildContext context,
  WidgetRef ref,
  TransferHistory header,
) {
  ref.read(selectedTransferCodeProvider.notifier).state = header.transferCode;
  ref.read(historyDetailProvider.notifier).load(header.transferCode);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Consumer(
        builder: (context, ref, _) => HistoryDetailView(
          header: header,
          detail: ref.watch(historyDetailProvider),
          scrollController: scrollController,
        ),
      ),
    ),
  );
}
