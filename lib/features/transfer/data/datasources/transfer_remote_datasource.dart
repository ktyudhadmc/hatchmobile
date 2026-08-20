import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_service.dart';
import '../models/transfer_basket_model.dart';

// import '../../domain/repositories/mock_basket_response.dart';

final transferRemoteDatasourceProvider = Provider<TransferRemoteDatasource>((
  ref,
) {
  return TransferRemoteDatasource(ref.watch(apiServiceProvider));
});

class TransferRemoteDatasource {
  TransferRemoteDatasource(this._apiService);

  final ApiService _apiService;

  Future<TransferBasketModel> getBasketByCode(String code) async {
    final response = await _apiService.get(
      ApiEndpoints.transferBasketByCode(code),
    );
    final data = response.data as Map<String, dynamic>;
    return TransferBasketModel.fromJson(data['data'] as Map<String, dynamic>);
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

  Future<List<TransferBasketModel>> getReceivedBaskets() async {
    final response = await _apiService.get(ApiEndpoints.receivedBaskets);
    final data = response.data as Map<String, dynamic>;
    return (data['data'] as List)
        .map((e) => TransferBasketModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
