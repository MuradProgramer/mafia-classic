import 'package:flutter/material.dart';
import 'package:mafia_classic/features/features.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/models/models.dart';

final routes = {
  '/': (context) => const SplashScreen(),
  '/profile': (context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return ProfileScreen(user: user);
  },
  '/profile/friends': (context) => const FriendsScreen(),
  '/profile/roles': (context) => const RolesScreen(),
  '/profile/ratings': (context) => const RatingsScreen(),
  '/games': (context) => const GamesPage(),
  '/create': (context) => const CreatePage(),
  '/settings': (context) => const SettingsScreen(),
};