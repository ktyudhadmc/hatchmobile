import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hatchmobile/features/transfer/data/models/transfer_info_model.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/api_service.dart';
import '../models/transfer_basket_model.dart';
import '../models/transfer_history_detail_model.dart';
import '../models/transfer_recent/transfer_recent_model.dart';

import '../../domain/repositories/mock_basket_response.dart';

final transferRemoteDatasourceProvider = Provider<TransferRemoteDatasource>((
  ref,
) {
  return TransferRemoteDatasource(ref.watch(apiServiceProvider));
});

class TransferRemoteDatasource {
  TransferRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<TransferBasketModel> getBasketByCode(String code) async {
    // GET ONE BY BASKET CODE
    // final response = await _apiService.get(
    //   ApiEndpoints.transferBasketByCode(code),
    // );
    // final data = response.data as Map<String, dynamic>;
    // return TransferBasketModel.fromJson(data['data'] as Map<String, dynamic>);

    // GET ONE BY ADJUSTMENT [BE]
    final qs = {'basket_code': code};

    final response = await _apiService.get(
      ApiEndpoints.transferBasket,
      queryParameters: qs,
    );

    final data = response.data as Map<String, dynamic>;
    final basketData = data['data'];

    if (data['status'] != true || basketData is! Map<String, dynamic>) {
      throw NotFoundException(
        (data['message'] as String?) ?? 'Kode basket tidak ditemukan',
      );
    }

    return TransferBasketModel.fromJson(basketData);
    // return TransferBasketModel.fromJson(
    //   mockBasketResponseJson['data'] as Map<String, dynamic>,
    // );
  }

  Future<void> confirmReceive({
    required int transferId,
    required int transferBasketId,
    required List<({int id, int receivedQuantity})> grades,
  }) async {
    await _apiService.post(
      ApiEndpoints.confirmTransferBasket,
      data: {
        'transfer_id': transferId,
        'transfer_basket_id': transferBasketId,
        'grades': grades
            .map((g) => {'id': g.id, 'received_quantity': g.receivedQuantity})
            .toList(),
      },
    );
  }

  Future<void> createReceive({required String basketCode}) async {
    await _apiService.post(
      ApiEndpoints.createReceive,
      data: {'basket_code': basketCode},
    );
  }

  Future<void> confirmReceiveBasket({required int basketCode}) async {
    await _apiService.post(
      ApiEndpoints.confirmTransferBasket,
      data: {'transfer_id': basketCode},
    );
  }

  Future<List<TransferBasketModel>> getReceivedBaskets() async {
    final response = await _apiService.get(ApiEndpoints.receivedBaskets);
    final data = response.data as Map<String, dynamic>;
    return TransferBasketModel.fromJsonList(data['data'] as List);

    // final data = mockReceivedBasketsResponseJson;
    // return (data['data'] as List)
    //     .map((e) => TransferBasketModel.fromJson(e as Map<String, dynamic>))
    //     .toList();
  }

  Future<List<TransferInfoModel>> getAllHistoryHeaderReceive() async {
    // final response = await _apiService.get(
    //   ApiEndpoints.getAllHistoryHeaderReceive,
    // );
    // final data = response.data as Map<String, dynamic>;
    // return (data['data'] as List)
    //     .map((e) => TransferInfoModel.fromJson(e as Map<String, dynamic>))
    //     .toList();

    final data = mockAllHistoryHeaderReceiveResponseJson;
    return TransferInfoModel.fromJsonList(data['data'] as List);
  }

  Future<TransferHistoryDetailModel> getHistoryDetailReceive(
    String transferCode,
  ) async {
    final response = await _apiService.get(
      ApiEndpoints.getHistoryDetailReceive,
      queryParameters: {'id_transfer': transferCode},
    );
    final data = response.data as Map<String, dynamic>;
    final detailData = data['data'];
    if (data['status'] != true || detailData is! Map<String, dynamic>) {
      throw NotFoundException(
        (data['message'] as String?) ?? 'Riwayat tidak ditemukan',
      );
    }
    return TransferHistoryDetailModel.fromJson(detailData);

    // final data = mockHistoryDetailReceiveResponseJson;
    // final detailData = data['data'];

    // if (data['status'] != true || detailData is! Map<String, dynamic>) {
    //   throw NotFoundException(
    //     (data['message'] as String?) ?? 'Riwayat tidak ditemukan',
    //   );
    // }

    // return TransferHistoryDetailModel.fromJson(detailData);
  }

  Future<List<TransferRecentModel>> getRecentsReceive() async {
    final response = await _apiService.get(ApiEndpoints.getRecentsReceive);
    final data = response.data as Map<String, dynamic>;

    return TransferRecentModel.fromJsonList(data['data'] as List);
  }
}
