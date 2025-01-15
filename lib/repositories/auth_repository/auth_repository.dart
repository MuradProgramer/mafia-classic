import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/dio/dio_service.dart';

class AuthRepository {
  Future<User> signIn(String email, String password) async {

    final dataJson = jsonEncode({
      'email': email,
      'password': password,
    });

    final response = await GetIt.I<DioService>().dio.post(
      'Account/SignIn',
      data: dataJson,
    );

    switch (response.statusCode) {
      case 200:
        final data = response.data as Map<String, dynamic>;
        User user = User(
          email: data['email'], 
          nickname: data['nickname'], 
          avatarUrl: data['avatarUrl'],
          accessToken: data['accessToken'], 
          refreshToken: data['refreshToken'], 
          expirationDate: DateTime.parse(data['expiration'])
        );
        setup(user);
        return user;
      case 400:
        throw Exception('Invalid Type');
      case 401:
        throw Exception('Invalid Type');
      case 404:
        throw Exception('Not Found');
      case 500:
        throw Exception('Something Happened');
      default:
        throw Exception('Failed to send POST request');
    }

    // await Future.delayed(const Duration(seconds: 1));
    // return User(email: email, nickname: 'musayev', accessToken: 'token', avatarUrl: 'assets/avatar.jpg', refreshToken: 'refresh token', expirationDate: DateTime.now());
  }

  Future<User> signUp(String nickname, String email, String password) async {

    final dataObject = jsonEncode({
      'email': email, 
      'password': password, 
      'nickname': nickname
    });

    final response = await GetIt.I<DioService>().dio.post(
      'Account/SignUp',
      data: dataObject,
    );

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      User user = User(
        email: data['email'], 
        nickname: data['nickname'], 
        avatarUrl: data['avatarUrl'],
        accessToken: data['accessToken'], 
        refreshToken: data['refreshToken'], 
        expirationDate: DateTime.parse(data['expiration'])
      );
      setup(user);
      return user;
    } else if (response.statusCode == 404) {
      throw Exception('No user found');
    } else {
      throw Exception('Failed to sign up');
    }
  }
}