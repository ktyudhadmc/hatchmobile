import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../transfer/domain/entities/transfer_info.dart';

/// Pill row built from history headers — filled when selected, outlined
/// otherwise. Tapping a pill hands the tapped `transferCode` back to the
/// caller, which is responsible for updating selection + loading detail.
class HistoryFilterPills extends StatelessWidget {
  const HistoryFilterPills({
    super.key,
    required this.headers,
    required this.selectedTransferCode,
    required this.onSelect,
  });

  final List<TransferInfo> headers;
  final String? selectedTransferCode;
  final void Function(String transferCode) onSelect;

  @override
  Widget build(BuildContext context) {
    if (headers.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: headers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final header = headers[index];
          final isSelected = header.transferCode == selectedTransferCode;

          return _Pill(
            label: header.transferCode,
            isSelected: isSelected,
            onTap: () => onSelect(header.transferCode),
          );
        },
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }
}
