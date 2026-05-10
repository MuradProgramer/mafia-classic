import 'package:flutter/material.dart';

abstract class TokenAwareService {
  Future<String> getAccessToken();
  Future<void> refreshToken();
  Future<bool> refreshTokenBoolean();
  bool isTokenExpired();

  Future<void> executeWithTokenCheck(Function apiMethod) async {
    if (isTokenExpired()) {
      await refreshToken();
    }
    final accessToken = await getAccessToken();
    await apiMethod(accessToken);
  }
}