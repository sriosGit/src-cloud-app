import 'package:dio/dio.dart';
import 'secure_storage.dart';

// ── Base URL detection ───────────────────────────────────────────────────────

String getApiUrl() {
  // Override via compile-time constant: --dart-define=API_URL=https://...
  const env = String.fromEnvironment('API_URL', defaultValue: '');
  if (env.isNotEmpty) return env;
  return 'http://localhost:8000';
}

// ── Dio client ───────────────────────────────────────────────────────────────

final dio = _buildDio();

Dio _buildDio() {
  final d = Dio(BaseOptions(
    baseUrl: getApiUrl(),
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  d.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (err, handler) async {
      if (err.response?.statusCode == 401) {
        final refreshToken = await readRefreshToken();
        if (refreshToken != null) {
          try {
            final resp = await Dio(BaseOptions(baseUrl: getApiUrl())).post(
              '/api/auth/refresh',
              data: {'refresh_token': refreshToken},
            );
            final newAccess = resp.data['access_token'] as String;
            final newRefresh = resp.data['refresh_token'] as String;
            await saveTokens(newAccess, newRefresh);

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccess';
            final retry = await d.fetch(opts);
            return handler.resolve(retry);
          } catch (_) {
            await clearTokens();
          }
        }
      }
      handler.next(err);
    },
  ));

  return d;
}
