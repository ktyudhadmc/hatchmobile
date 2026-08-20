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
  static const String transferBasket =
      '$_api/hatchery/egg-receive/app/get-detail-basket';

  static const String confirmTransferBasket = '$_api/transfer-baskets/confirm';
  // Guessed, same as the others above — confirm against the real backend
  // route. Expected to list baskets this hatchery has already received.
  static const String receivedBaskets = '$_api/transfer-baskets/received';
}
