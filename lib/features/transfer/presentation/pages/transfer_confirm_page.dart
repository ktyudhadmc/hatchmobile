import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/mixins/async_state_handler_mixin.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/dialog_helper.dart';
import '../../domain/entities/transfer_basket.dart';
import '../../domain/entities/transfer_grade.dart';
import '../providers/transfer_provider.dart';

class TransferConfirmPage extends ConsumerStatefulWidget {
  const TransferConfirmPage({super.key, required this.basket});

  final TransferBasket basket;

  @override
  ConsumerState<TransferConfirmPage> createState() =>
      _TransferConfirmPageState();
}

class _TransferConfirmPageState extends ConsumerState<TransferConfirmPage>
    with AsyncStateHandlerMixin {
  late final Map<int, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();

    _controllers = {
      for (final grade in widget.basket.grades)
        grade.id: TextEditingController(
          text: (grade.receivedQuantity ?? grade.quantity).toString(),
        ),
    };

    listenAsync(
      provider: confirmReceiveProvider,
      loadingMessage: 'Menyimpan...',
      onData: (_) {
        unawaited(ref.read(receivedBasketsProvider.notifier).fetch());
        ToastHelper.success('Basket berhasil dikonfirmasi');
        context.pushReplacement('/profile');
      },
      onError: (err, stack) {
        ToastHelper.error(err.toString());
        context.pushReplacement('/profile');
      },
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onConfirm() {
    final grades = widget.basket.grades.map((grade) {
      final input = int.tryParse(_controllers[grade.id]!.text) ?? 0;
      return (id: grade.id, receivedQuantity: input);
    }).toList();

    ref
        .read(confirmReceiveProvider.notifier)
        .confirm(
          transferId: widget.basket.transfer.id,
          transferBasketId: widget.basket.id,
          grades: grades,
        );
  }

  @override
  Widget build(BuildContext context) {
    final basket = widget.basket;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Penerimaan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildInfoCard(basket),
          const SizedBox(height: 20),
          Text(
            'Jumlah Diterima per Grade',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...basket.grades.map(_buildGradeRow),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: screenHeight * 0.08,
        ),
        child: _buildConfirmButton(),
      ),
    );
  }

  Widget _buildInfoCard(TransferBasket basket) {
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
            basket.basketCode,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          _infoRow('Kode Transfer', basket.transfer.transferCode),
          _infoRow(
            'Tanggal',
            DateFormatter.format(basket.transfer.transferDate),
          ),
          _infoRow('Farm', basket.transfer.branch.name),
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

  Widget _buildGradeRow(TransferGrade grade) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffF5F8FA)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grade ${grade.grade}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dikirim: ${grade.quantity}',
                  style: const TextStyle(
                    color: Color(0xFF7B7B7B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: _controllers[grade.id],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: 'Diterima',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: _onConfirm,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: ShapeDecoration(
          color: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: const Text(
          'KONFIRMASI',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontFamily: AppTheme.fontFamily,
          ),
        ),
      ),
    );
  }
}
