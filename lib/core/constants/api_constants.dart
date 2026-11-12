class ApiConstants {
  const ApiConstants._();

  /// Same URL for Chrome and a physical phone. PC and phone must share Wi-Fi.
  /// Do not append `/api` — request paths already start with `/api/...`.
  static const String baseUrl = 'http://192.168.31.178:3000';

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);
}
