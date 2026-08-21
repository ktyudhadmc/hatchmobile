class ApiEndpoints {
  ApiEndpoints._();

  static const String _api = '/api';
  // static const String _v1 = '$_api/v1';

  // Auth
  static const String login = '$_api/auth/login';
  static const String logout = '$_api/auth/logout';
  static const String profile = '$_api/auth/me';

  // Transfer basket
  static String transferBasketByCode(String code) =>
      '$_api/transfer-baskets/$code';
  static const String confirmTransferBasket = '$_api/transfer-baskets/confirm';
  static const String receivedBaskets = '$_api/transfer-baskets/received';
  static const String getReceived = '$_api/hatchery/egg-receive/app/riwayat';

  // [BE]
  static const String transferBasket =
      '$_api/hatchery/egg-receive/app/get-detail-basket';

  static const String createReceive =
      '$_api/hatchery/egg-receive/app/receive-basket';

  static const String getRecentsReceive =
      '$_api/hatchery/egg-receive/app/ongoing';
  static const String getAllHistoryHeaderReceive =
      '$_api/hatchery/egg-receive/app/riwayat-header';
  static const String getHistoryDetailReceive =
      '$_api/hatchery/egg-receive/app/riwayat-detail';
}
