import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:mafia_classic/features/games/view/games_screen.dart';
//import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/features/auth/auth.dart';
import 'package:mafia_classic/features/games/game/game.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';
import 'package:mafia_classic/features/profile/roles/view/roles_screen.dart';
//import 'package:mafia_classic/features/games/view/games_screen.dart';
//import 'package:mafia_classic/models/models.dart';
//import 'package:mafia_classic/features/profile/profile.dart';

List<PlayerRole> players = [
  PlayerRole(
    nickname: 'Player1111111',
    role: 'Doctor'
  ),
  PlayerRole(
    nickname: 'Player2',
    role: 'Citizen'
  ),
  PlayerRole(
    nickname: 'Player3',
    role: 'Mafia'
  ),
  PlayerRole(
    nickname: 'Player4', 
    role: 'Citizen'
  ),
  PlayerRole(
    nickname: 'Player5',
    role: 'Citizen'
  ),
  PlayerRole(
    nickname: 'Player6',
    role: 'Terrorist'
  ),
  PlayerRole(
    nickname: 'Player7',
    role: 'Barman'
  ),
];

List<Player> allPlayers = [
  Player(
    nickname: 'Player1111111',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    nickname: 'Player2',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    nickname: 'Player3',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    nickname: 'Player4',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    nickname: 'Player5',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    nickname: 'Player6',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    nickname: 'Player7',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
];


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    //final width = MediaQuery.of(context).size.width;

    Timer(const Duration(seconds: 1), () {
      Navigator.push(context, 
        MaterialPageRoute(
          //builder: (context) => const SignInScreen()   // TRUEEE
          builder: (context) => GameScreen(title: 'Room Main', playersRole: players, mafiaCount: 5, citizenCount: 7, role: 'Sheriff', allPlayers: allPlayers, cameBackFromAfk: false, gameIsReadyWidget: true,)
          //builder: (context) => GamesScreen(user: authorizedUser)
          //builder: (context) => const CreateGameScreen(),
          //builder: (context) => const RolesScreen() // FALSEEE
        ) 
      );
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/2-moons-night-buildings.png"), fit: BoxFit.cover, opacity: 0.5),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.2),
              
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'MAFIA CLASSIC', 
                  style: TextStyle(
                    fontSize: 40, 
                    color: Colors.white, 
                    fontWeight: FontWeight.w700,
                  )
                )
              )
            ),
            Text(
              'Powered by CORPORAZ', 
              style: TextStyle(
                color: Colors.white.withOpacity(0.8), 
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )        
      ),
    );
    
  }
}