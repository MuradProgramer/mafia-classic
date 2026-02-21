import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/dio/dio_service.dart';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';
import 'package:mafia_classic/services/tcp/general_service.dart';

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
          id: data['id'],
          email: data['email'], 
          nickname: data['nickname'], 
          avatarUrl: data['avatarUrl'],
          accessToken: data['accessToken'], 
          refreshToken: data['refreshToken'], 
          expirationDate: DateTime.parse(data['expiration']).toUtc()
        );
        await SharedPrefsService.saveTokens(
          accessToken: user.accessToken,
          refreshToken: user.refreshToken,
          expiration: user.expirationDate,
          nickname: user.nickname,
          avatarUrl: user.avatarUrl,
          email: user.email,
          id: user.id,
        );
        setup(user);
        await GeneralService(user).init();
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

    log('-------------- FLAG1 --------------');

    Response<dynamic>? response;
    int? statusCodeOfResponse;
    String? responseData = '';

    try {
      response = await GetIt.I<DioService>().dio.post(
        'Account/SignUp',
        data: dataObject,
      );
      statusCodeOfResponse = 200;
    } on DioException catch (e) {
      if (e.response != null) {
        
        statusCodeOfResponse = e.response?.statusCode;
        final statusMessage = e.response?.statusMessage;

        log('HTTP Error: $statusCodeOfResponse - $statusMessage');
        log('Response data: ${e.response?.data}');
        responseData = e.response?.data.toString();

        if (statusCodeOfResponse == 400) {
          log('Unauthorized');
        } else if (statusCodeOfResponse == 404) {
          log('Not found');
        } else if (statusCodeOfResponse == 500) {
          log('Server error');
        }
      }
    }

    // log('DATA: ${response!.data}');
    // log('STATUS MESSAGE: ${response.statusMessage}');
    // log('HEADERS: ${response.headers}');

    if (statusCodeOfResponse == 200) {
      final data = response!.data as Map<String, dynamic>;
      User user = User(
        id: data['id'],
        email: data['email'], 
        nickname: data['nickname'], 
        avatarUrl: data['avatarUrl'],
        accessToken: data['accessToken'], 
        refreshToken: data['refreshToken'], 
        expirationDate: DateTime.parse(data['expiration']).toUtc()
      );
      setup(user);
      await SharedPrefsService.saveTokens(
        accessToken: user.accessToken,
        refreshToken: user.refreshToken,
        expiration: user.expirationDate,
        nickname: user.nickname,
        avatarUrl: user.avatarUrl,
        email: user.email,
        id: user.id,
      );
      await GeneralService(user).init();
      return user;
    } else if (statusCodeOfResponse == 400) {
      if (responseData!.contains('Exists') && responseData.contains('nickname')) {
        throw Exception('400 - User with this nickname already exist');
      } else if (responseData.contains('Exists') && responseData.contains('email')) {
        throw Exception('400 - User with this email already exist');
      }
    } else {
      throw Exception('Failed to sign up');
    }
    return User(id: -12345678, email: email, nickname: nickname, avatarUrl: '', accessToken: '', refreshToken: '', expirationDate: DateTime.now());
  }
}