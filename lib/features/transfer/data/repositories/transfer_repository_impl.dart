import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/transfer_basket.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../datasources/transfer_remote_datasource.dart';

final transferRepositoryProvider = Provider<TransferRepository>((ref) {
  return TransferRepositoryImpl(ref.watch(transferRemoteDatasourceProvider));
});

class TransferRepositoryImpl implements TransferRepository {
  TransferRepositoryImpl(this._remote);

  final TransferRemoteDatasource _remote;

  @override
  Future<TransferBasket> getBasketByCode(String code) async {
    try {
      return await _remote.getBasketByCode(code);
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<void> confirmReceive({
    required int transferId,
    required int transferBasketId,
    required List<({int id, int receivedQuantity})> grades,
  }) async {
    try {
      await _remote.confirmReceive(
        transferId: transferId,
        transferBasketId: transferBasketId,
        grades: grades,
      );
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  @override
  Future<List<TransferBasket>> getReceivedBaskets() async {
    try {
      return await _remote.getReceivedBaskets();
    } on DioException catch (e) {
      throw _unwrap(e);
    }
  }

  AppException _unwrap(DioException e) {
    return e.error is AppException ? e.error as AppException : const AppException('Terjadi kesalahan');
  }
}
