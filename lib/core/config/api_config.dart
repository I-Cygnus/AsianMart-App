class ApiConfig {
  ApiConfig._();

  /// 클라우드(AWS EC2) 백엔드 기본 주소.
  /// 로컬 개발 시 빌드에 다음을 넘겨 덮어쓸 수 있다:
  ///   --dart-define=API_BASE_URL=http://localhost:8080
  static const String _cloudBaseUrl = 'http://52.78.131.171:8080';

  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl =>
      _overrideBaseUrl.isNotEmpty ? _overrideBaseUrl : _cloudBaseUrl;
}
