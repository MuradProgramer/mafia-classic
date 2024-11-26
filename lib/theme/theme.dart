import 'package:flutter/material.dart';

final view = WidgetsBinding.instance.platformDispatcher.views.first;
final size = view.physicalSize;
final pixelRatio = view.devicePixelRatio;

// Size in physical pixels:
final width = size.width / pixelRatio;
final height = size.height;

final theme = ThemeData(
  //colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 6, 0, 63)),
  //colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),


  primaryColor: const Color(0xff6200ee),
  primaryColorDark: const Color(0xff3700B3),
  cardColor: const Color(0xff03DAC5),



  iconTheme: const IconThemeData(color: Colors.white),
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor:  Color(0xff3700B3),
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 25
    )
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
      fontSize: 20
    ),
    labelSmall: TextStyle(
      color: Colors.white, 
      fontSize: 16, 
      fontWeight: FontWeight.w500,
    )
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      padding: EdgeInsets.zero, 
      textStyle: const TextStyle(fontSize: 18), 
      minimumSize: Size(width * 0.8, 50),
      backgroundColor: const Color(0xff3700B3),          
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15)))   
    )
  )
);