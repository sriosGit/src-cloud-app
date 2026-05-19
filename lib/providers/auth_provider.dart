import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api.dart';
import '../core/secure_storage.dart';
import '../models/user.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus status = AuthStatus.loading;
  User? user;

  AuthProvider() {
    _tryRestoreSession();
  }

  Future<void> _tryRestoreSession() async {
    final token = await readAccessToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final resp = await dio.get('/api/auth/me');
      user = User.fromJson(resp.data as Map<String, dynamic>);
      status = AuthStatus.authenticated;
    } catch (_) {
      await _tryRefresh();
    }
    notifyListeners();
  }

  Future<void> _tryRefresh() async {
    final refresh = await readRefreshToken();
    if (refresh == null) {
      status = AuthStatus.unauthenticated;
      return;
    }
    try {
      final resp = await Dio(BaseOptions(baseUrl: getApiUrl())).post(
        '/api/auth/refresh',
        data: {'refresh_token': refresh},
      );
      await saveTokens(
        resp.data['access_token'] as String,
        resp.data['refresh_token'] as String,
      );
      final me = await dio.get('/api/auth/me');
      user = User.fromJson(me.data as Map<String, dynamic>);
      status = AuthStatus.authenticated;
    } catch (_) {
      await clearTokens();
      status = AuthStatus.unauthenticated;
    }
  }

  Future<void> login(String email, String password) async {
    final resp = await dio.post(
      '/api/auth/login',
      data: 'username=${Uri.encodeComponent(email)}&password=${Uri.encodeComponent(password)}',
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    await saveTokens(
      resp.data['access_token'] as String,
      resp.data['refresh_token'] as String,
    );
    final me = await dio.get('/api/auth/me');
    user = User.fromJson(me.data as Map<String, dynamic>);
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    try {
      await dio.post('/api/auth/logout');
    } catch (_) {}
    await clearTokens();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
