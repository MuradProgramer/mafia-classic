import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/services/dio/dio_service.dart';
import 'package:mafia_classic/repositories/repositories.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  GetIt.I.registerSingleton(PlayerRepository());
  GetIt.I.registerSingleton(AuthRepository());
  GetIt.I.registerSingleton(DioService());
  runApp(const MafiaClassicApp());
}