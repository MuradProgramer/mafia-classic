import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/auth/auth.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/features/widgets/widgets.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

List<PlayerRole> players = [
  PlayerRole(
    id: -1,
    role: 'Doctor'
  ),
  PlayerRole(
    id: -2,
    role: 'Citizen'
  ),
  PlayerRole(
    id: -3,
    role: 'Mafia'
  ),
  PlayerRole(
    id: -4,
    role: 'Citizen'
  ),
  PlayerRole(
    id: -5,
    role: 'Citizen'
  ),
  PlayerRole(
    id: -6,
    role: 'Terrorist'
  ),
  PlayerRole(
    id: -7,
    role: 'Barman'
  ),
];

List<Player> allPlayers = [
  Player(
    id: -1,
    nickname: 'Player1001',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -2,
    nickname: 'Player2',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -3,
    nickname: 'Player3aaaa',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -4,
    nickname: 'Player4',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -5,
    nickname: 'Pl5',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -6,
    nickname: 'Player6',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -7,
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
          fullscreenDialog: true,
          builder: (context) => const SignInScreen()   // TRUEEE
          
          // builder: (context) => FriendChat(friend: 
          //   Friendship(
          //     gameTitle: 'Avengers999',
          //     nickname: 'Leonardo Di Caprio', 
          //     avatarUrl: 'https://mediaproxy.tvtropes.org/width/1200/https://static.tvtropes.org/pmwiki/pub/images/tony_stark.png',
          //     isOnline: true,
          //     lastSeen: DateTime.now()
          //   ),
          // )
          
          //builder: (context) => const SignUpScreen()
          //builder: (context) => const SettingsScreen(),
          //builder: (context) => const ForgotPasswordScreen(),
          //builder: (context) => const RatingsScreen(),
          //builder: (context) => GameScreen(title: 'Avengers999', playersRole: players, mafiaCount: 2, citizenCount: 5, role: 'Journalist', allPlayers: allPlayers, cameBackFromAfk: false, gameIsReadyWidget: true,)
          //builder: (context) => GamesScreen(user: authorizedUser)
          //builder: (context) => const CreateGameScreen(),
          //builder: (context) => HomeScreen(user: authorizedUser),
          //builder: (context) => const CreateGameScreen(),
          //builder: (context) => const FilterizationScreen(),
          //builder: (context) => const RolesScreen() // FALSEEE
          //builder: (context) => const FriendsScreen() // FALSEEE
          //builder: (context) => GameLobbyScreen(game: Game(extraRoles: ['Bodyguard', 'Beauty', 'Spy', 'Journalist'], hasPassword: false, maxPlayers: 11, minPlayers: 6, players: allPlayers, status: 'Gathering Players', title: 'Avengers999'), password: ''),
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
              
              child: Align(
                alignment: Alignment.topCenter,
                child: TextButton(
                  onPressed: () {
                    showBouncingPopupFromLeft(
                      context, 
                      PlayerInfoPopup(
                        id: 123,
                        height: 727.h, 
                        width: 405.w,
                        nickname: 'Admin',
                        /*
                        playerInfo: PlayerInfo(
                          nickname: 'Tony Stark', 
                          avatarUrl: 'assets/avatar.jpg', 
                          isOnline: false, 
                          lastSeen: DateTime(2025, 8, 15, 17, 36),
                          joinDate: DateTime.now(), 
                          friendshipStatus: 'None',
                          inGameLobby: false, 
                          
                          overall: 2429 + 1230, 
                          wins: 2429, 
                          loses: 1230, 
                          mafiaWins: 1120, 
                          civilianWins: 1309,
                          playedRoles: {
                            "Civilian": 177,
                            "Mafia": 54,
                            "Doctor": 682,
                            "Sheriff": 254,
                            "Bodyguard": 365,
                            "Beauty": 45,
                            "Journalist": 24,
                            "Spy": 76,
                            "Terrorist": 245,
                            "Informant": 343,
                            "Barman": 543
                          }, 
                          gameLobbyTitle: null, 
                          gameLobbyStatus: null, 
                          gameLobbyPlayerCount: null
                        ),
                        */
                      )
                    );
                  }, 
                  child: Text(
                    'MAFIA CLASSIC',
                    style: TextStyle(
                      fontSize: 40.sp, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w700,
                    )
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