import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/repositories/auth_repository/auth_repository.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthService {
  static Future<bool> hasValidSession() async {
    final accessToken = SharedPrefsService.getAccessToken();
    final refreshToken = SharedPrefsService.getRefreshToken();
    final expiryUtc = SharedPrefsService.getAccessTokenExpiryUtc();

    if (accessToken == null || refreshToken == null || expiryUtc == null) {
      return false;
    }

    final nowUtc = DateTime.now().toUtc();

    final isExpired = DateTime.now().toLocal().isAfter(
      expiryUtc.toLocal().subtract(const Duration(seconds: 30)),
    );

    if (!isExpired) {
      return true;
    }

    // 🔁 refresh if expired
    return await _refresh();
  }

  static Future<bool> _refresh() async {
    try {
      log(
        '@@@@@@@@Access token expired. Attempting to refresh... AuthService@@@@@@@@',
      );
      await GetIt.I<ApiService>()
          .refreshToken();
      log(
        '@@@@@@@@Refreshed token succesfuly... AuthService@@@@@@@@',
      );
      return true;
    } catch (e) {
      await SharedPrefsService.clearAuth();
      return false;
    }
  }

  static Future<void> logout() async {
    await SharedPrefsService.clearAuth();
  }
}


class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = SharedPrefsService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await AuthService.hasValidSession();

      if (refreshed) {
        final token = SharedPrefsService.getAccessToken();
        err.requestOptions.headers['Authorization'] =
            'Bearer $token';

        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      }
    }

    handler.reject(err);
  }
}
