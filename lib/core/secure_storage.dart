import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage(
  aOptions: AndroidOptions(encryptedSharedPreferences: true),
);

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

Future<void> saveTokens(String access, String refresh) async {
  await _storage.write(key: _kAccessToken, value: access);
  await _storage.write(key: _kRefreshToken, value: refresh);
}

Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);
Future<String?> readRefreshToken() => _storage.read(key: _kRefreshToken);

Future<void> clearTokens() async {
  await _storage.delete(key: _kAccessToken);
  await _storage.delete(key: _kRefreshToken);
}
