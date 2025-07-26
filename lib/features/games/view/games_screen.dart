import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/game/game.dart';
import 'package:mafia_classic/features/profile/roles/widgets/widgets.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/models/player.dart';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

int stateToJoin = 1;

/*
List<Game> games = [
  /*
  Game(
    title: 'Mafia Game 1',
    //currentPlayers: 6,
    minPlayers: 10,
    maxPlayers: 20,
    status: 'Gathering players',
    hasPassword: false,
    players: players,
    extraRoles: ['Mafia', 'Doctor', 'Sheriff'],
  ),
  Game(
    title: 'Mafia Game 2',
    //currentPlayers: 7,
    minPlayers: 4,
    maxPlayers: 10,
    status: 'Game Started',
    hasPassword: true,
    players: playersWithMe,
    extraRoles: ['Mafia', 'Doctor', 'Sheriff'],
  ),
  Game(
    title: 'Mafia Game 3',
    //currentPlayers: 10,
    minPlayers: 5,
    maxPlayers: 15,
    status: 'Gathering players',
    hasPassword: false,
    players: players,
    extraRoles: ['Mafia', 'Doctor', 'Sheriff'],
  )
  */
];
*/

//!!!!!!!!!!!!!!!!!!!!!!!
late User authorizedUser;
//User authorizedUser = User(email: "asdasd", nickname: "musayev", avatarUrl: "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg", accessToken: "accessToken", refreshToken: "refreshToken", expirationDate: DateTime.now());

class GamesScreen extends StatefulWidget {
  final User user;

  const GamesScreen({
    super.key, 
    required this.user
  });

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String text = '';

  List<Game>? allGames = [];
  List<Game>? searchedGames = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    authorizedUser = widget.user;

    // NOTE:    MAIN HUB CONNECTION AND SOCKETS

    var apiService = GetIt.I<ApiService>();
    
    //! BUILD
    apiService.mainHubConnection = HubConnectionBuilder().withUrl(
      'https://31.171.65.145/mainlobby',
      options: HttpConnectionOptions(
        accessTokenFactory: () => Future.value(GetIt.I<ApiService>().accessToken),
        skipNegotiation: true,
        transport: HttpTransportType.WebSockets,
      ),
    )
    .build();

    //! METHODS

    // DONE
    apiService.mainHubConnection.on('GameLobbies', (List<Object?>? parameters) {
      print('33: $parameters');
      final List<Game>? gamesList = apiService.decodeGamesParameters(parameters);

      if (gamesList != null) {
        setState(() {
          allGames = gamesList;
          searchedGames = allGames;
        });
      }
    });

    // INCOMPLETE
    apiService.mainHubConnection.on('GameLobbyCreated', (List<Object?>? parameters) {
      final Game? game = apiService.decodeGameParameters(parameters);

      if (game != null) {
        setState(() {
          allGames?.add(game);
          searchedGames = allGames;
        });
      }
    });

    // INCOMPLETE
    apiService.mainHubConnection.on('GameLobbyClosed', (List<Object?>? parameters) {
      final String? title = parameters?.first as String;

      if (title != null && allGames != null) {
        if (allGames!.any((game) => game.title == title)) {
          setState(() {
            allGames!.removeWhere((game) => game.title == title);
            searchedGames = allGames;
          });
        }
      }
    });

    // INCOMPLETE
    apiService.mainHubConnection.on('PlayerJoined', (List<Object?>? parameters) {
      final PlayerJoinedGame? playerJoinedToGame = apiService.decodePlayerJoinedGameParameters(parameters);

      if (playerJoinedToGame != null && allGames != null) {
        if (!allGames!
          .firstWhere((game) => game.title == playerJoinedToGame.title)
          .players.any((player) => player.nickname == playerJoinedToGame.player.nickname)) {

          setState(() {
            allGames!
            .firstWhere((game) => game.title == playerJoinedToGame.title)
            .players.add(playerJoinedToGame.player);
            searchedGames = allGames;
          });
        }
      }
    });

    // INCOMPLETE
    apiService.mainHubConnection.on('PlayerLeft', (List<Object?>? parameters) {
      final PlayerLeftGame? playerLeftGame = apiService.decodePlayerLeftGameParameters(parameters);

      if (playerLeftGame != null && allGames != null) {
        if (allGames!
          .firstWhere((game) => game.title == playerLeftGame.title)
          .players.any((player) => player.nickname == playerLeftGame.nickname)) {

          setState(() {
            allGames!
            .firstWhere((game) => game.title == playerLeftGame.title)
            .players.removeWhere((player) => player.nickname == playerLeftGame.nickname);
            searchedGames = allGames;
          });
        }
        else {
          print('There is no player with this nickname');
        }
      }
    });

    // INCOMPLETE
    apiService.mainHubConnection.on('GameStarted', (List<Object?>? parameters) {
      final String? title = parameters?.first as String;

      if (title != null && allGames != null) {
        if (allGames!.any((game) => game.title == title)) {
          setState(() {
            allGames!.firstWhere((game) => game.title == title).status = 'Game Started';
            searchedGames = allGames;
          });
        }
      }
    });

    apiService.mainHubConnection.on('CloseConnection', (List<Object?>? parameters) async {
      await apiService.disconnectMainHub();
    });

    //! CONNECTION
    if (!apiService.mainHubIsConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        apiService.mainHubConnection.start()?.then((_) {
          apiService.mainHubIsConnected = true;
          print("Connected to SignalR!");
        }).catchError((e) {
          print("Connection error: $e");
        });
      });
    }

    bool temp = false;
    //!!!!!!!!!!!!!!!!!
    for (var game in allGames!) {
      for (var player in game.players) {
        if (player.nickname == authorizedUser.nickname) {
          log('message: ${player.nickname} is in the game ${game.title}');
          stateToJoin = (player.isAlive) ? 2 : 3;
          temp = true;
          break;
        }
      }
      if (temp) break;
    }

    //allGames = games;
    searchedGames = allGames;
  }

  @override
  void dispose() {
    // Dispose of the hub connection when the screen is closed
    GetIt.I<ApiService>().disconnectMainHub();
    super.dispose();
  }

  void _loadGames() async {
    final fetchedGames = await GetIt.I<ApiService>().getGames();
    setState(() {
      //games = fetchedGames;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 45.sp;
    final double ornamentMargin = 12.sp;
    const String ornament = "assets/images/game-ornament-night.png";

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/game-phase-night.png"), fit: BoxFit.cover, opacity: 0.8),
      ),
      child: Scaffold(

        /*
        appBar: AppBar(
          title: Text(S.of(context).games),
          automaticallyImplyLeading: false,
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.add, color: Colors.white),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const CreateGameScreen()),
            //     );
            //   },
            // ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FilterizationScreen()),
                );
              },
            ),
          ],
        ),
        */

        //! STREAM
        // body: 
        // StreamBuilder<List<Game>>(
        //   stream: GetIt.I<ApiService>().gamesStream,
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Center(child: CircularProgressIndicator());
        //     } else if (snapshot.hasError) {
        //       return Center(child: Text('Error: ${snapshot.error}'));
        //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //       return const Center(child: Text('No games available.'));
        //     } else {
        //       final gamesSnap = snapshot.data!;
        //       return ListView.builder(
        //         itemCount: gamesSnap.length, 
        //         itemBuilder: (context, index) {
        //           return GameCard(game: gamesSnap[index]);
        //         },
        //       );
        //     }
        //   },
        // ),
        
        body: Padding(
          padding: EdgeInsets.only(top: 50.h, right: 20.w, left: 20.w),
          child: Column(
            children: [

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BUTTON:    HOME
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/images/home-icon.png",
                      scale: 2.8,
                    ),
                  ),

                  // BUTTON:    FILTER
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FilterizationScreen(),
                        )
                      );
                    },
                    child: Image.asset(
                      "assets/images/filter-icon.png",
                      scale: 3,
                    ),
                  ),
                ],
              ),
            
              //? INFO PART
              Container(
                margin: EdgeInsets.only(top: 25.h),
                width: double.maxFinite,
                height: 200.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  children: [
        
                    //? ORNAMENTS
                    Stack(
                      children: [
                        // Top-left ornament
                        Positioned(
                          top: ornamentMargin,
                          left: ornamentMargin,
                          child: Image.asset(
                            ornament,
                            width: ornamentSize,
                            height: ornamentSize,
                          ),
                        ),
                        // Top-right ornament (rotated 90 degrees)
                        Positioned(
                          top: ornamentMargin,
                          right: ornamentMargin,
                          child: Transform.rotate(
                            angle: 90 * 3.14159 / 180, // 90 degrees in radians
                            child: Image.asset(
                              ornament,
                              width: ornamentSize,
                              height: ornamentSize,
                            ),
                          ),
                        ),
                        // Bottom-left ornament (rotated 270 degrees)
                        Positioned(
                          bottom: ornamentMargin,
                          left: ornamentMargin,
                          child: Transform.rotate(
                            angle: 270 * 3.14159 / 180, // 270 degrees in radians
                            child: Image.asset(
                              ornament,
                              width: ornamentSize,
                              height: ornamentSize,
                            ),
                          ),
                        ),
                        // Bottom-right ornament (rotated 180 degrees)
                        Positioned(
                          bottom: ornamentMargin,
                          right: ornamentMargin,
                          child: Transform.rotate(
                            angle: 180 * 3.14159 / 180, // 180 degrees in radians
                            child: Image.asset(
                              ornament,
                              width: ornamentSize,
                              height: ornamentSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(),

                        Column(
                          children: [

                            //? TITLE
                            Padding(
                              padding: EdgeInsets.only(top: 15.h),
                              child: Text(
                                'Lobby',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 42.sp,
                                  color: const Color(0xFFFFB000)
                                ),
                              ),
                            ),

                            //? SEARCH
                            Padding(
                              padding: EdgeInsets.only(top: 15.h, left: 25.w, right: 20.w),
                              child: Container(
                                height: 40.h,
                                width: 290.w,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 1.5),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
                                        child: TextField(
                                          cursorColor: Colors.white,
                                          cursorHeight: 20.h,
                                          onTapOutside: (PointerDownEvent event) {
                                            FocusScope.of(context).unfocus();
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              if (value.isEmpty) {
                                                searchedGames = allGames;
                                              }
                                              else {
                                                searchedGames = allGames?.where((game) => game.title.toLowerCase().contains(value.toLowerCase())).toList() ?? [];
                                              }
                                            });
                                          },
                                          controller: _searchController,
                                          style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'CenturyGothic'),
                                          decoration: const InputDecoration(
                                            hintText: " Search...",
                                            hintStyle: TextStyle(color: Color.fromARGB(255, 166, 166, 166), fontFamily: 'CenturyGothic'),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 10.w),
                                      child: GestureDetector(
                                        onTap: () {
                                      
                                        },
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 25.sp,
                                        ),
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              ),
                            ),
                          
                            //? FILTER OFF
                            Padding(
                              padding: EdgeInsets.only(top: 15.h, left: 25.w, right: 20.w),
                              child: Text(
                                'Filter Off',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontFamily: 'CenturyGothic',
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox()
                      ],
                    )
                  ],
                ),
              ),


              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 10.h),
                  height: 500.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: searchedGames!.length,
                    itemBuilder: (context, index) {
                      return GameCard(game: searchedGames![index]);
                    },
                  ),
                ),
              ),
            ],
          ),
        )

        // ListView.builder(
        //   //! AllGames
        //   itemCount: (allGames == null || allGames!.isNotEmpty) ? allGames!.length : 0, 
        //   itemBuilder: (context, index) {
        //     if (allGames == null || allGames!.isNotEmpty)
        //     {
        //       return GameCard(game: allGames![index]);
        //     }
        //   },
        // ),
      ),
    );
  }
}


////////// GAME CLASSES ////////

//////////////////////////////////////////////////////////
class Game {
  final String title;
  //final int currentPlayers; // massive size
  final int minPlayers;
  final int maxPlayers;
  String status;
  final bool hasPassword;
  final List<String> extraRoles;
  final List<Player> players;

  Game({
    required this.title,
    //required this.currentPlayers,
    required this.minPlayers,
    required this.maxPlayers,
    required this.status,
    required this.extraRoles,
    required this.hasPassword,
    required this.players,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    // final playersFrom = json['Players'].isEmpty ? null : json['Players'].map((item) {
    //   return Player.fromJson(item as Map<String, dynamic>);
    // }).toList();

    return Game(
      title: json['title'],
      //currentPlayers: json['currentPlayers'],
      //currentPlayers: json['currentPlayers'],
      minPlayers: json['minCapacity'],    
      maxPlayers: json['maxCapacity'],    
      hasPassword: json['hasPassword'], 
      status: json['status'],
      players: json['players'].isEmpty ? <Player>[] : (json['players'] as List)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      extraRoles: json['extraRoles'].isEmpty ? <String>[] : json['extraRoles'].cast<String>(),    
    );
  }
}

//////////////////////////////////////////////////////////

// [
//   Game(
//     name: 'Mafia Game 1',
//     //currentPlayers: 6,
//     minPlayers: 10,
//     maxPlayers: 20,
//     status: 'Gathering players',
//     hasPassword: false,
//     players: players
//     //characters: ['Mafia', 'Doctor', 'Sheriff'],
//   ),
//   Game(
//     name: 'Mafia Game 2',
//     //currentPlayers: 7,
//     minPlayers: 4,
//     maxPlayers: 10,
//     status: 'Game Started',
//     hasPassword: false,
//     players: players
//     //characters: ['Mafia', 'Doctor', 'Sheriff'],
//   ),
//   Game(
//     name: 'Mafia Game 3',
//     //currentPlayers: 10,
//     minPlayers: 5,
//     maxPlayers: 15,
//     status: 'Gathering players',
//     hasPassword: false,
//     players: players
//     //characters: ['Mafia', 'Doctor', 'Sheriff'],
//   )
// ];


////////// GAMECARD ///////////

class GameCard extends StatefulWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  String text = '';
  bool isCardExpanded = false;

  @override
  void initState() {
    if (widget.game.players.any((e) => e.nickname == authorizedUser.nickname)) {
      if (widget.game.players.firstWhere((e) => e.nickname == authorizedUser.nickname).isAlive) {
        text = 'You Are Playing Here';
      } else {
        text = 'You Died Here';
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5.h, right: 5.h, left: 5.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12.sp)
      ),
      clipBehavior: Clip.hardEdge,
      width: double.maxFinite,
      child: ExpansionTile(
        // shape: RoundedRectangleBorder(
        //   side: BorderSide(width: 0, color: Colors.transparent),
        //   borderRadius: BorderRadius.circular(12.0),
        // ),
        backgroundColor: Colors.transparent,
        textColor: Colors.transparent,
        clipBehavior: Clip.hardEdge,
        tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
        showTrailingIcon: false,
        onExpansionChanged: (value) => {
          setState(() {
            isCardExpanded = value;
          })
        },
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //? TITLE
            Expanded(
              child: Text(
                widget.game.title,
                overflow: (isCardExpanded) ? TextOverflow.fade : TextOverflow.ellipsis,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 23.sp, 
                  color: const Color(0xFFFFB000)
                )
              ),
            ),
                          
            // BUTTON:    JOIN 
            //!
            widget.game.status == 'Game Started'
            ? Text(
              'Game Started',
              style: TextStyle(
                fontSize: 15.sp,
                color: Colors.white,
                fontFamily: 'CenturyGothic'
              ),
            )
            : Row(
              children: [
                widget.game.hasPassword 
                ? Image.asset(
                  "assets/images/locker.png",
                  scale: 3.5,
                )
                : const SizedBox(),
        
                SizedBox(width: 40.w),
        
                GestureDetector(
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(builder: (context) => 
                        (text == 'You Are Playing Here' || text == 'You Died Here')
                        ? GameScreen(title: widget.game.title, playersRole: [], role: '', mafiaCount: 0, citizenCount: 0, allPlayers: widget.game.players, cameBackFromAfk: true, gameIsReadyWidget: false,)
                        : GameLobbyScreen(
                          game: widget.game,
                          //! ------------------- CHANGE -------------------
                          password: widget.game.hasPassword ? 'password' : '',
                        )
                      ),
                    );
                  },
                  child: Container(
                    width: 100.w,
                    height: 35.h,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Center(
                      child: Text(
                        'Join', // NOTE:    Translation L10
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontFamily: 'CenturyGothic',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
                      
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                                      
                  Column(
                    children: [
                                      
                      //? MIN AND MAX
                      Row(
                        children: [
                                    
                          //? MIN COUNT
                          Column(
                            children: [
                              Text(
                                "${widget.game.minPlayers}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  height: 0
                                ),
                              ),
                                    
                              Text(
                                "min",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  height: 0
                                ),
                              )
                            ],
                          ),

                          //? ACTUAL COUNT
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Column(
                              children: [
                                Text(
                                  "${widget.game.players.length}",
                                  style: GoogleFonts.playfairDisplay(
                                    color: const Color(0xFFFFB000),
                                    fontSize: 32.sp,
                                  ),
                                ),
                                SizedBox(height: 15.h,)
                              ],
                            ),
                          ),

                          //? MAX COUNT
                          Column(
                            children: [
                              Text(
                                "${widget.game.maxPlayers}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  height: 0
                                ),
                              ),
                                    
                              Text(
                                "max",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  height: 0
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ],
                  ),

                  // TEXT:    players in the room            
                  Text(
                    'players in the room',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontFamily: 'CenturyGothic'
                    ),
                  ),
                                      
                  const SizedBox()
                ],
              ),

              //? DIVIDER      
              SizedBox(
                width: 320.w,
                child: const Divider(
                  color: Colors.white,
                  thickness: 1,
                ),
              ),
            
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [

                      //? EXTRA ROLES
                      Container(
                        width: 140.w,
                        height: 95.h,
                        margin: EdgeInsets.only(left: 15.w, top: 5.h),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.game.extraRoles == null ? 0 : widget.game.extraRoles.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                log('Tapped on card $index');
                              },
                              child: Container(
                                width: 60.w,
                                height: 100.h,
                                margin: EdgeInsets.all(5.sp),
                                child: Stack(
                                  children: [
                                    RoleCard(roleName: widget.game.extraRoles[index].toLowerCase(), width: 70.w, height: 93.h)
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),

                      // TEXT:    are here
                      RotatedBox(
                        quarterTurns: 3, // Rotates the text 90 degrees clockwise
                        child: Text(
                          'are here', // Replace with your text
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'CenturyGothic',
                          ),
                        ),
                      ),
                    
                    ],
                  ),
                
                  // BUTTON:    SHOW ALL PLAYERS
                  Container(
                    margin: EdgeInsets.only(right: 25.w, bottom: 5.h),
                    child: GestureDetector(
                      onTap: () {
                        //DONE:    DIALOG
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Dismiss",
                          barrierColor: Colors.black.withOpacity(0.7),
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return PlayersPopup(playersInGame: widget.game.players, gameTitle: widget.game.title,);
                          },
                          transitionBuilder: (context, animation, secondaryAnimation, child) {
                            final curvedAnimation = CurvedAnimation(
                              parent: animation,
                              curve: Curves.elasticOut,
                              reverseCurve: Curves.easeInBack,
                            );

                            return SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(-1.0, 0.0),
                                end: Offset.zero,
                              ).animate(curvedAnimation),
                              child: child,
                            );
                          },
                        );            
                      },
                      child: Column(
                        children: [
                          Text(
                            'Show',
                            style: GoogleFonts.playfairDisplay(
                              height: 0,
                              color: const Color(0xFFFFB000),
                              fontSize: 20.sp
                            )
                          ),
                      
                          Text(
                            'All Players',
                            style: GoogleFonts.playfairDisplay(
                              height: 0,
                              color: const Color(0xFFFFB000),
                              fontSize: 20.sp
                            )
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            
              //? DIVIDER
              Container(
                margin: EdgeInsets.only(bottom: 10.h),
                width: 320.w,
                child: const Divider(
                  color: Colors.white,
                  thickness: 1,
                ),
              ),

              // TEXT:    USER STATE
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontFamily: 'CenturyGothic',
                    color: const Color(0xFF515151)
                  ),
                ),
              )
            ],
          )
        ],              
      ),
    );
  }
}


class Player {
  final String nickname;
  final String avatarUrl;
  final bool isAlive;

  Player({
    required this.nickname, 
    required this.avatarUrl, 
    required this.isAlive
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      isAlive: json['isAlive'] as bool
    );
  }
}

List<Player> players = [
  Player(
    nickname: 'Player1', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player2', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: false
  ),
  Player(
    nickname: 'Player3', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player4', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player5', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player6', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: false
  ),
  Player(
    nickname: 'Player7', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
];

List<Player> playersWithMe = [
  Player(
    nickname: 'Player1', 
    avatarUrl: 'https://example.com/avatar1.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player2', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: false
  ),
  Player(
    nickname: 'Player3', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player4', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
  Player(
    nickname: 'musayev', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
  Player(
    nickname: 'Player6', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: false
  ),
  Player(
    nickname: 'Player7', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
];

////////// PLAYER ///////

class PlayersPopup extends StatefulWidget {
  final List<Player> playersInGame;
  final String gameTitle;
  
  const PlayersPopup({
    super.key, 
    required this.playersInGame, 
    required this.gameTitle
  });

  @override
  State<PlayersPopup> createState() => _PlayersPopupState();
}

class _PlayersPopupState extends State<PlayersPopup> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 21.w),
        width: double.maxFinite,
        height: 350.h,
        child: Material(
          borderRadius: BorderRadius.circular(12.sp),
          color: const Color(0xFF111111),
          child: Column(
            children: [
              //? TITLE AND CLOSE BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 25.w),
        
                  Padding(
                    padding: EdgeInsets.all(8.sp),
                    child: Text(
                      widget.gameTitle,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32.sp,
                        color: const Color(0xFFFFB000)
                      ),
                    ),
                  ),
        
                  // BUTTON:    CLOSE BUTTON
                  Padding(
                    padding: EdgeInsets.only(right: 25.w),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Image.asset(
                        "assets/images/close-white-icon.png",
                        scale: 2.5,
                      ),
                    ),
                  )
                ],
              ),
        
              Container(
                margin: EdgeInsets.only(top: 10.h),
                height: 250.h,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  shrinkWrap: true,
                  itemCount: widget.playersInGame.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 5.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //? CIRCLE AVATAR AND NICKNAME
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(widget.playersInGame[index].avatarUrl),
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    widget.playersInGame[index].nickname, 
                                    style: TextStyle(
                                      fontSize: 15.sp, 
                                      fontFamily: 'CenturyGothic',
                                      color: widget.playersInGame[index].isAlive == true ? const Color(0xFFFFB000) : const Color(0xFF515151)
                                    )
                                  ),
                                ],
                              ),
                                          
                              // TEXT:    DEFEATED OR STILL HERE
                              Text(
                                widget.playersInGame[index].isAlive == true ? 'Still here' : 'Defeated',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: widget.playersInGame[index].isAlive == true ? const Color(0xFFFFB000) : const Color(0xFF515151),
                                ),
                              )
                            ],
                          ),
                        
                          //? DIVIDER      
                          Padding(
                            padding: EdgeInsets.only(top: 5.h),
                            child: SizedBox(
                              width: 310.w,
                              child: const Divider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                          ),
            
                        ],
                      )
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//////// CREATE GAME /////////

class CreateGame {
  final String title;
  final int minPlayers;
  final int maxPlayers;
  final String? password;
  final List<String> extraRoles;

  CreateGame({
    required this.title, 
    required this.minPlayers, 
    required this.maxPlayers, 
    required this.password, 
    required this.extraRoles
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'minCapacity': minPlayers,
      'maxCapacity': maxPlayers,
      'password': password,
      'extraRoles': extraRoles,
    };
  }
}

class PlayerJoinedGame {
  final String title;
  final Player player;

  PlayerJoinedGame({
    required this.title, 
    required this.player
  });
  
  factory PlayerJoinedGame.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedGame(
      title: json['title'],
      player: Player.fromJson(json['player'])
    );
  }
}

class PlayerLeftGame {
  final String title;
  final String nickname;

  PlayerLeftGame({
    required this.title, 
    required this.nickname
  });
  
  factory PlayerLeftGame.fromJson(Map<String, dynamic> json) {
    return PlayerLeftGame(
      title: json['title'],
      nickname: json['nickname']
    );
  }
}

class GameLobbyChatPlayer {
  final String nickname;
  final String content;

  GameLobbyChatPlayer({
    required this.nickname, 
    required this.content
  });
  
  factory GameLobbyChatPlayer.fromJson(Map<String, dynamic> json) {
    return GameLobbyChatPlayer(
      nickname: json['nickname'],
      content: json['content']
    );
  }
}

class PlayerRole {
  final String nickname;
  final String role;

  PlayerRole({required this.nickname, required this.role});

  factory PlayerRole.fromJson(Map<String, dynamic> json) {
    return PlayerRole(
      nickname: json['nickname'] ?? '',
      role: json['role'] ?? '',
    );
  }
}

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

//// LOGIC ////
class _CreateGameScreenState extends State<CreateGameScreen> {
  String roomName = '';
  int minPlayers = 5;
  int maxPlayers = 7;

  int showedMinPlayers = 5;
  int showedMaxPlayers = 7;
  
  String password = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isPasswordVisible = false;

  bool hasDoctor = false;
  bool hasBodyguard = false;
  bool hasSpy = false;
  bool hasJournalist = false;
  bool hasLover = false;

  bool hasTerrorist = false;
  bool hasBartender = false;
  bool hasInformant = false;
  
  late Map<String, bool> rolesL10;
  late Map<String, bool> mainRoles;
  List<String> roles = <String>[];

  @override
  void initState() {
    super.initState();
    // Initialize an empty map or placeholder here
    rolesL10 = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    rolesL10 = {
      S.of(context).mistress: false,
      S.of(context).journalist: false,
      S.of(context).bodyguard: false,
      S.of(context).spy: false,
      S.of(context).terrorist: false,
      S.of(context).barman: false,
      S.of(context).informant: false,
    };

    mainRoles = {
      "mistress": false,
      "journalist": false,
      "bodyguard": false,
      "spy": false,
      "terrorist": false,
      "barman": false,
      "informant": false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/temp-create-game-background.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(

        /*
        appBar: AppBar(
          title: Text(S.of(context).createGame),
          automaticallyImplyLeading: false,
        ),
        */

        body: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Column(
            children: [
              
              // BUTTON:   HOME
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15.w),
                    child: GestureDetector(
                      onTap: () {
                    
                      },
                      child: Image.asset(
                        'assets/images/home-icon.png',
                        scale: 2.9,
                      ),
                    ),
                  ),
                  const SizedBox()
                ],
              ),
            
              // TEXT:    Create Game
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create Game',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 38.sp,
                      color: Colors.white
                    ),
                  )
                ],
              ),
            
              //? TITLE AND PASSWORD
              Container(
                height: 160.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  //border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                
                    // TEXTFIELD:    TITLE
                    Container(
                      height: 37.h,
                      width: 230.w,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1C3A6),
                        border: Border.all(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: TextField(
                        cursorColor: Colors.white,
                        cursorHeight: 20.h,
                        textAlign: TextAlign.center,
                        onTapOutside: (PointerDownEvent event) {
                          FocusScope.of(context).unfocus();
                        },
                        onChanged: (value) {
                          setState(() {
                            
                          });
                        },
                        controller: _titleController,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: 'CenturyGothic'),
                        decoration: InputDecoration(
                          hintText: " Enter the name",
                          hintStyle: TextStyle(color: const Color(0xFF515151), fontFamily: 'CenturyGothic', fontSize: 14.sp),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLength: 12,
                      ),
                    ),
        
                    // TEXT:    Password
                    //? Toggle Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 15.h),
                          child: Row(
                            children: [
                              Text(
                                'Password ${isPasswordVisible ? 'on' : 'off'}',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: const Color(0xFF494239),
                                  fontFamily: 'CenturyGothic',
                                ),
                              ),
                        
                              Container(
                                width: 65.w,
                                height: 27.h,
                                margin: EdgeInsets.only(left: 15.w),
                                child: AnimatedToggleSwitch.dual(
                                  current: isPasswordVisible, 
                                  first: false, 
                                  second: true,
                                  spacing: 10.w,
                                  height: 30.h,
                                  onChanged: (value) {
                                    setState(() {
                                      isPasswordVisible = value;
                                    });
                                  },
                                  style: const ToggleStyle(
                                    backgroundColor: Colors.transparent,
                                    borderColor: Colors.transparent,
                                  ),
                                  styleBuilder: (value) => ToggleStyle(
                                    backgroundColor: value ? const Color(0xFFEBBD57) : const Color(0xFF585755),
                                    indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF585755),
                                  ),
                                  iconBuilder: (value) => value 
                                    ? Image.asset('assets/images/locker-opened-icon.png', scale: 3.2.sp) 
                                    : Image.asset('assets/images/locker-closed-icon.png', scale: 3.2.sp),
                                ),
                              )
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                    isPasswordVisible
                    ?
                    // TEXTFIELD:    PASSWORD
                    Padding(
                      padding: EdgeInsets.only(top: 15.h),
                      child: Container(
                        height: 37.h,
                        width: 230.w,
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1C3A6),
                          border: Border.all(color: Colors.white, width: 1.5),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: TextField(
                          cursorColor: Colors.white,
                          cursorHeight: 20.h,
                          textAlign: TextAlign.center,
                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              
                            });
                          },
                          controller: _passwordController,
                          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: 'CenturyGothic'),
                          decoration: InputDecoration(
                            hintText: " Enter the password",
                            hintStyle: TextStyle(color: const Color(0xFF515151), fontFamily: 'CenturyGothic', fontSize: 14.sp),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          maxLength: 12,
                        ),
                      ),
                    )
                    :
                    const SizedBox(),
                  ],
                ),
              ),
        
              //? NUMBER OF PLAYERS
              Container(
                height: 100.h,
                width: 280.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  //border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TEXT:    Number of players
                    Text(
                      'Number of players',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 23.sp,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                    Stack(
                      children: [
                        //? SLIDER
                        SliderTheme(
                          data: const SliderThemeData(
                            rangeThumbShape: RoundRangeSliderThumbShape(
                              enabledThumbRadius: 5
                            ),
                          ),
                          child: RangeSlider(
                            values: RangeValues(minPlayers.toDouble(), maxPlayers.toDouble()),
                            min: 5,
                            max: 20,
                            divisions: 15,
                            
                            activeColor: const Color(0xFFFFB000),
                            inactiveColor: Colors.white,
                            onChanged: (RangeValues values) {
                              setState(() {
                                minPlayers = values.start.toInt();
                                maxPlayers = values.end.toInt();
                                showedMinPlayers = values.start.toInt();
                                showedMaxPlayers = values.end.toInt();
                              });
                            },
                          ),
                        ),
                        
                        //? TEXT:    MIN AND MAX PLAYERS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //? MIN COUNT
                            Padding(
                              padding: EdgeInsets.only(top: 30.h, left: 10.h),
                              child: Text(
                                '$showedMinPlayers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
        
                            //? MAX COUNT
                            Padding(
                              padding: EdgeInsets.only(top: 30.h, right: 10.w),
                              child: Text(
                                '$showedMaxPlayers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
        
              //? EXTRA ROLES
              Container(
                height: 280.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  //border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Column(
                  children: [
                    // TEXT:    EXTRA ROLES
                    Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: Text(
                        'Extra Roles',
                        style: GoogleFonts.playfairDisplay(
                          color: const Color(0xFF494239),
                          fontSize: 23.sp,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                    ),
        
                    //? ROLES
                    Padding(
                      padding: EdgeInsets.only(top: 5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //? CITIZEN ROLES
                          Padding(
                            padding: EdgeInsets.only(right: 5.w),
                            child: Container(
                              height: 200.h,
                              width: 190.w,
                              padding: EdgeInsets.only(top: 10.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDB98B),
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              child: Column(
                                children: [
                                  //? Doctor
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Doctor',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 19.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasDoctor, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasDoctor = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                        ),
                                      )
                                    
                                    ],
                                  ),
        
                                  //? BODYGUARD
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Bodyguard',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 18.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasBodyguard, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasBodyguard = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                          
                                        ),
                                      )
                                    ],
                                  ),
        
                                  //? SPY
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Spy',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 19.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasSpy, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasSpy = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                          
                                        ),
                                      )
                                    ],
                                  ),
        
                                  //? JOURNALIST
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Journalist',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 19.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasJournalist, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasJournalist = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                          
                                        ),
                                      )
                                    ],
                                  ),
        
                                  //? LOVER
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Lover',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 19.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasLover, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasLover = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                          
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            
                            ),
                          ),
                      
                          //? MAFIA ROLES
                          Padding(
                            padding: EdgeInsets.only(left: 5.w),
                            child: Container(
                              height: 200.h,
                              width: 190.w,
                              padding: EdgeInsets.only(top: 45.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000000),
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              child: Column(
                                children: [
                                  //? TERRORIST
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Terrorist',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 19.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasTerrorist, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasTerrorist = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                        ),
                                      )
                                    
                                    ],
                                  ),
        
                                  //? BARTENDER
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Bartender',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 18.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasBartender, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasBartender = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                          
                                        ),
                                      )
                                    ],
                                  ),
        
                                  //? INFORMANT
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          'Informant',
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 19.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
        
                                      //? TOGGLE:
                                      Container(
                                        width: 62.w,
                                        height: 27.h,
                                        margin: EdgeInsets.only(left: 8.w, top: 8.h, right: 8.w),
                                        child: AnimatedToggleSwitch.dual(
                                          current: hasInformant, 
                                          first: false, 
                                          second: true,
                                          spacing: 10.w,
                                          height: 30.h,
                                          onChanged: (value) {
                                            setState(() {
                                              hasInformant = value;
                                            });
                                          },
                                          style: const ToggleStyle(
                                            backgroundColor: Colors.transparent,
                                            borderColor: Colors.transparent,
                                          ),
                                          styleBuilder: (value) => ToggleStyle(
                                            backgroundColor: value ? const Color(0xFFFFFFFF) : const Color(0xFF4F4F4F),
                                            indicatorColor: value ? const Color(0xFFEBBD57) : const Color(0xFF000000),
                                            indicatorBorderRadius: BorderRadius.circular(50.sp),
                                            borderRadius: BorderRadius.circular(10.sp),
                                            
                                          ),
                                          indicatorSize: Size(20.sp, 20.sp),
                                          padding: EdgeInsets.only(left: 5.w, right: 5.w),
                                          
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
        
              // BUTTON:    CONFIRM
              Padding(
                padding: EdgeInsets.only(top: 15.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                    
                      },
                      child: Container(
                        width: 140.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB000),
                          borderRadius: BorderRadius.circular(34.sp),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )         
            ],
          ),
          
          /*
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: S.of(context).roomName,
                  hintStyle: const TextStyle(color: Colors.white30)
                ),
                onChanged: (value) {
                  setState(() {
                    roomName = value;
                  });
                },
                style: const TextStyle(color: Colors.white)
              ),
              const SizedBox(height: 20),
              Text('${S.of(context).players}: $minPlayers - $maxPlayers'),
              RangeSlider(
                values: RangeValues(minPlayers.toDouble(), maxPlayers.toDouble()),
                min: 5,
                max: 20,
                divisions: 15,
                onChanged: (RangeValues values) {
                  setState(() {
                    minPlayers = values.start.toInt();
                    maxPlayers = values.end.toInt();
                  });
                },
              ),
              const SizedBox(height: 20),
              Text(
                S.of(context).roles,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: rolesL10.keys.map((role) {
                  return ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: Text(role, style: const TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: rolesL10[role]!,
                      onChanged: (value) {
                        setState(() {
                          rolesL10[role] = value;
                          for (var i = 0; i < rolesL10.length; i++) {
                            if (rolesL10.keys.elementAt(i) == role) {
                              mainRoles[mainRoles.keys.elementAt(i)] = true;
                            }
                          }
                          //print('roles l10: $rolesL10');
                          //print('main roles: $mainRoles');
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  labelText: S.of(context).passwordOptional,
                  hintStyle: const TextStyle(color: Colors.white30)
                ),
                obscureText: true,
                onChanged: (value) {
                  setState(() {
                    password = value;
                  });
                },
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    mainRoles.forEach((mainRole, state) {
                      if (state) {
                        roles.add(mainRole);
                      }
                    });
                    CreateGame finalGame = CreateGame(
                      title: roomName, 
                      minPlayers: minPlayers, 
                      maxPlayers: maxPlayers, 
                      password: (password.isEmpty) ? "" : password, 
                      extraRoles: roles
                    );
                    //print(jsonEncode(finalGame.toJson()));
                   //bool status = await GetIt.I<ApiService>().createGame(jsonEncode(finalGame.toJson()));
                   bool status = await GetIt.I<ApiService>().createGame(finalGame);
        
                    if (status) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => 
                          GameLobbyScreen(
                            game: Game(
                              title: roomName, 
                              minPlayers: minPlayers, 
                              maxPlayers: maxPlayers, 
                              status: 'Gathering Players', 
                              extraRoles: roles, 
                              hasPassword: (password.isEmpty) ? false : true, 
                              players: []
                            ),
                            password: (password.isEmpty) ? "" : password,
                          )
                        ),
                      );
                    }
                  },
                  child: Text(S.of(context).createGame),
                ),
              ),
            ],
          ),
          */
        
        )
      ),
    );
  }
}


////// FILTERIZATION /////////

class FilterizationScreen extends StatefulWidget {

  const FilterizationScreen({super.key});

  @override
  State<FilterizationScreen> createState() => _FilterizationScreenState();
}

//// LOGIC ////
class _FilterizationScreenState extends State<FilterizationScreen> {
  int minPlayers = 5;
  int maxPlayers = 7;

  int showedMinPlayers = 5;
  int showedMaxPlayers = 7;

  bool friendsInRoom = false;
  bool roomsWithSpace = false;
  // bool roomsWithoutPassword = false;
  // bool roomsWithPassword = false;
  int accessState = 0;
  bool noAdditionalRoles = false;

  bool hasBodyguard = false;
  bool hasLover = false;
  bool hasSpy = false;
  bool hasJournalist = false;

  bool hasTerrorist = false;
  bool hasBartender = false;
  bool hasInformant = false;

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 45.sp;
    final double ornamentMargin = 10.sp;
    const String ornament = "assets/images/game-ornament-night.png";

    Map<String, bool> additionalRoles = {
      //S.of(context).doctor: false,
      //S.of(context).sheriff: false,
      S.of(context).mistress: false,
      S.of(context).journalist: false,
      S.of(context).bodyguard: false,
      S.of(context).spy: false,
      S.of(context).terrorist: false,
      S.of(context).barman: false,
      S.of(context).informant: false,
    };

    void resetFilters() {
      setState(() {
        friendsInRoom = false;
        roomsWithSpace = false;
        // roomsWithoutPassword = false;
        // roomsWithPassword = false;
        accessState = 0;
        noAdditionalRoles = false;

        hasBodyguard = false;
        hasLover = false;
        hasSpy = false;
        hasJournalist = false; 
        hasTerrorist = false;
        hasBartender = false;
        hasInformant = false;

        additionalRoles.updateAll((key, value) => false);
      });
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/game-phase-night.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 50.h, left: 15.w, right: 15.w),
          child: Column(
            children: [
              //? GO BACK BUTTON
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
        
                  // BUTTON:    GO BACK
                  GestureDetector(
                    onTap: () {
                      resetFilters();
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 33.w,
                      height: 33.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB000).withOpacity(0.4),
                        borderRadius: BorderRadius.circular(8.sp),
                      ),
                      child: Icon(
                        Icons.keyboard_double_arrow_left,
                        color: Colors.white,
                        size: 33.sp,
                      ),
                    ),
                  )
                ],
              ),
        
              //? INFO PART
              Container(
                margin: EdgeInsets.only(top: 20.h),
                width: double.maxFinite,
                height: 180.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Stack(
                  children: [
        
                    //? ORNAMENTS
                    Stack(
                      children: [
                        // Top-left ornament
                        Positioned(
                          top: ornamentMargin,
                          left: ornamentMargin,
                          child: Image.asset(
                            ornament,
                            width: ornamentSize,
                            height: ornamentSize,
                          ),
                        ),
                        // Top-right ornament (rotated 90 degrees)
                        Positioned(
                          top: ornamentMargin,
                          right: ornamentMargin,
                          child: Transform.rotate(
                            angle: 90 * 3.14159 / 180, // 90 degrees in radians
                            child: Image.asset(
                              ornament,
                              width: ornamentSize,
                              height: ornamentSize,
                            ),
                          ),
                        ),
                        // Bottom-left ornament (rotated 270 degrees)
                        Positioned(
                          bottom: ornamentMargin,
                          left: ornamentMargin,
                          child: Transform.rotate(
                            angle: 270 * 3.14159 / 180, // 270 degrees in radians
                            child: Image.asset(
                              ornament,
                              width: ornamentSize,
                              height: ornamentSize,
                            ),
                          ),
                        ),
                        // Bottom-right ornament (rotated 180 degrees)
                        Positioned(
                          bottom: ornamentMargin,
                          right: ornamentMargin,
                          child: Transform.rotate(
                            angle: 180 * 3.14159 / 180, // 180 degrees in radians
                            child: Image.asset(
                              ornament,
                              width: ornamentSize,
                              height: ornamentSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // TEXT:    FILTER
                            Text(
                              'Filter',
                              style: GoogleFonts.playfairDisplay(
                                color: const Color(0xFFFFB000),
                                fontSize: 42.sp
                              ),
                            ),
        
                            // BUTTON:    CLOSE
                            Padding(
                              padding: EdgeInsets.only(top: 15.h),
                              child: GestureDetector(
                                onTap: () {
                                  resetFilters();
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  width: 100.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.sp),
                                    border: BoxBorder.all(
                                      color: const Color(0xFFFFFFFF),
                                      width: 1.5.sp,
                                    )
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        color: const Color(0xFFFFFFFF),
                                        fontSize: 16.sp,
                                        fontFamily: 'CenturyGothic',
                                      )
                                    )
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    )
                  
                  ],
                ),
              ),
            
              //? NUMBER OF PLAYERS
              Container(
                height: 80.h,
                width: 280.w,
                margin: EdgeInsets.only(top: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  //border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TEXT:    Number of players
                    Text(
                      'Number of players',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                    Stack(
                      children: [
                        //? SLIDER
                        SliderTheme(
                          data: const SliderThemeData(
                            rangeThumbShape: RoundRangeSliderThumbShape(
                              enabledThumbRadius: 5
                            ),
                          ),
                          child: RangeSlider(
                            values: RangeValues(minPlayers.toDouble(), maxPlayers.toDouble()),
                            min: 5,
                            max: 20,
                            divisions: 15,
                            
                            activeColor: const Color(0xFFFFB000),
                            inactiveColor: Colors.white,
                            onChanged: (RangeValues values) {
                              setState(() {
                                minPlayers = values.start.toInt();
                                maxPlayers = values.end.toInt();
                                showedMinPlayers = values.start.toInt();
                                showedMaxPlayers = values.end.toInt();
                              });
                            },
                          ),
                        ),
                        
                        //? TEXT:    MIN AND MAX PLAYERS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //? MIN COUNT
                            Padding(
                              padding: EdgeInsets.only(top: 30.h, left: 10.h),
                              child: Text(
                                '$showedMinPlayers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
        
                            //? MAX COUNT
                            Padding(
                              padding: EdgeInsets.only(top: 30.h, right: 10.w),
                              child: Text(
                                '$showedMaxPlayers',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
                
              //? ROOMS WITH
              SizedBox(
                height: 80.h,
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TEXT:    ROOMS WITH
                    Text(
                      'Rooms with:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                    
                    Padding(
                      padding: EdgeInsets.only(top: 15.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //? WITH AVAILABLE SPOTS
                          Row(
                            children: [
                              //? CHECKBOX
                              Container(
                                width: 25.w,
                                height: 25.h,
                                decoration: BoxDecoration(
                                  color: roomsWithSpace ? const Color(0xFFFFB000) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.sp),
                                  border: Border.all(color: Colors.white, width: 1.5.sp),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      roomsWithSpace = !roomsWithSpace;
                                    });
                                  },
                                ),
                              ),
        
                              // TEXT:    Available spots
                              Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Text(
                                  'Available Spots',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16.sp,
                                    fontFamily: 'CenturyGothic'
                                  ),
                                ),
                              ),
                            ],
                          ),
        
                          SizedBox(width: 40.w),
                      
                          //? WITH FRIENDS IN
                          Row(
                            children: [
                              // TEXT:    Friends In
                              Text(
                                'Friends In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                              
                              //? CHECKBOX
                              Container(
                                width: 25.w,
                                height: 25.h,
                                margin: EdgeInsets.only(left: 10.w),
                                decoration: BoxDecoration(
                                  color: friendsInRoom ? const Color(0xFFFFB000) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.sp),
                                  border: Border.all(color: Colors.white, width: 1.5.sp),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      friendsInRoom = !friendsInRoom;
                                    });
                                  },
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
                
              //? ROOMS' ACCESS
              Container(
                height: 80.h,
                width: double.maxFinite,
                margin: EdgeInsets.only(top: 20.h),
                child: Column(
                  children: [
                    // TEXT:    Access
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Text(
                        'Access',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'CenturyGothic'
                        ),
                      ),
                    ),
        
                    //? ACCESS TYPE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //? MIXED ROOMS
                        Container(
                          height: 34.h,
                          width: 67.w,
                          margin: EdgeInsets.only(left: 10.w),
                          decoration: BoxDecoration(
                            color: accessState == 0 ? const Color(0xFF4D4D4D) : Colors.transparent,
                            borderRadius: BorderRadius.circular(47.sp),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                accessState = 0;
                              });
                            },
                            child: Center(
                              child: Text(
                                'Mixed',
                                style: TextStyle(
                                  color: accessState == 0 ? Colors.white : const Color(0xFFBFBFBF),
                                  fontSize: 16.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ),
                        ),
                    
                        //? OPEN ROOMS
                        Container(
                          height: 34.h,
                          width: 67.w,
                          decoration: BoxDecoration(
                            color: accessState == 1 ? const Color(0xFF4D4D4D) : Colors.transparent,
                            borderRadius: BorderRadius.circular(47.sp),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                accessState = 1;
                              });
                            },
                            child: Center(
                              child: Text(
                                'Open',
                                style: TextStyle(
                                  color: accessState == 1 ? Colors.white : const Color(0xFFBFBFBF),
                                  fontSize: 16.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ),
                        ),
                    
                        //? PRIVATE ROOMS
                        Container(
                          height: 34.h,
                          width: 67.w,
                          margin: EdgeInsets.only(right: 10.w),
                          decoration: BoxDecoration(
                            color: accessState == 2 ? const Color(0xFF4D4D4D) : Colors.transparent,
                            borderRadius: BorderRadius.circular(47.sp),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                accessState = 2;
                              });
                            },
                            child: Center(
                              child: Text(
                                'Private',
                                style: TextStyle(
                                  color: accessState == 2 ? Colors.white : const Color(0xFFBFBFBF),
                                  fontSize: 16.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
              //? INCLUDED ROLES
              SizedBox(
                height: 130.h,
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TEXT:    Included Roles
                    Text(
                      'Included roles:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),

                    Container(
                      height: 85.h,
                      margin: EdgeInsets.only(top: 15.h),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            //? BODYGUARD AND TERRORIST
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //? HAS BODYGUARD
                                Row(
                                  children: [
                                    //? CHECKBOX:    Bodyguard
                                    Container(
                                      width: 25.w,
                                      height: 25.h,
                                      margin: EdgeInsets.only(left: 50.w),
                                      decoration: BoxDecoration(
                                        color: hasBodyguard ? const Color(0xFFFFB000) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.sp),
                                        border: Border.all(color: Colors.white, width: 1.5.sp),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            hasBodyguard = !hasBodyguard;
                                          });
                                        },
                                      ),
                                    ),
                              
                                    // TEXT:    Bodyguard
                                    Padding(
                                      padding: EdgeInsets.only(left: 10.w),
                                      child: Text(
                                        'Bodyguard',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontFamily: 'CenturyGothic'
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            
                                //? HAS TERRORIST
                                Row(
                                  children: [
                                    // TEXT:    Terrorist
                                    Text(
                                      'Terrorist',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontFamily: 'CenturyGothic'
                                      ),
                                    ),
                                    
                                    //? CHECKBOX
                                    Container(
                                      width: 25.w,
                                      height: 25.h,
                                      margin: EdgeInsets.only(right: 50.w, left: 10.w),
                                      decoration: BoxDecoration(
                                        color: hasTerrorist ? const Color(0xFFFFB000) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6.sp),
                                        border: Border.all(color: Colors.white, width: 1.5.sp),
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            hasTerrorist = !hasTerrorist;
                                          });
                                        },
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ),
                        
                            //? JOURNALIST AND BARTENDER
                            Padding(
                              padding: EdgeInsets.only(top: 15.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //? HAS JOURNALIST
                                  Row(
                                    children: [
                                      //? CHECKBOX:    Journalist
                                      Container(
                                        width: 25.w,
                                        height: 25.h,
                                        margin: EdgeInsets.only(left: 50.w),
                                        decoration: BoxDecoration(
                                          color: hasJournalist ? const Color(0xFFFFB000) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.sp),
                                          border: Border.all(color: Colors.white, width: 1.5.sp),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              hasJournalist = !hasJournalist;
                                            });
                                          },
                                        ),
                                      ),
                                
                                      // TEXT:    Journalist
                                      Padding(
                                        padding: EdgeInsets.only(left: 10.w),
                                        child: Text(
                                          'Journalist',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontFamily: 'CenturyGothic'
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              
                                  //? HAS BARTENDER
                                  Row(
                                    children: [
                                      // TEXT:    Bartender
                                      Text(
                                        'Bartender',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontFamily: 'CenturyGothic'
                                        ),
                                      ),
                                      
                                      //? CHECKBOX
                                      Container(
                                        width: 25.w,
                                        height: 25.h,
                                        margin: EdgeInsets.only(left: 10.w, right: 50.w),
                                        decoration: BoxDecoration(
                                          color: hasBartender ? const Color(0xFFFFB000) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.sp),
                                          border: Border.all(color: Colors.white, width: 1.5.sp),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              hasBartender = !hasBartender;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),

                            //? LOVER AND INFORMANT
                            Padding(
                              padding: EdgeInsets.only(top: 15.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //? HAS LOVER
                                  Row(
                                    children: [
                                      //? CHECKBOX:    Lover
                                      Container(
                                        width: 25.w,
                                        height: 25.h,
                                        margin: EdgeInsets.only(left: 50.w),
                                        decoration: BoxDecoration(
                                          color: hasLover ? const Color(0xFFFFB000) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.sp),
                                          border: Border.all(color: Colors.white, width: 1.5.sp),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              hasLover = !hasLover;
                                            });
                                          },
                                        ),
                                      ),
                                
                                      // TEXT:    Lover
                                      Padding(
                                        padding: EdgeInsets.only(left: 10.w),
                                        child: Text(
                                          'Lover',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                            fontFamily: 'CenturyGothic'
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              
                                  //? HAS INFORMANT
                                  Row(
                                    children: [
                                      // TEXT:    Informant
                                      Text(
                                        'Informant',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontFamily: 'CenturyGothic'
                                        ),
                                      ),
                                      
                                      //? CHECKBOX
                                      Container(
                                        width: 25.w,
                                        height: 25.h,
                                        margin: EdgeInsets.only(left: 10.w, right: 50.w),
                                        decoration: BoxDecoration(
                                          color: hasInformant ? const Color(0xFFFFB000) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.sp),
                                          border: Border.all(color: Colors.white, width: 1.5.sp),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              hasInformant = !hasInformant;
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),

                            //? SPY 
                            Padding(
                              padding: EdgeInsets.only(top: 15.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //? CHECKBOX:    SPY
                                  Container(
                                    width: 25.w,
                                    height: 25.h,
                                    decoration: BoxDecoration(
                                      color: hasSpy ? const Color(0xFFFFB000) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6.sp),
                                      border: Border.all(color: Colors.white, width: 1.5.sp),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          hasSpy = !hasSpy;
                                        });
                                      },
                                    ),
                                  ),
                                                                  
                                  // TEXT:    Spy
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: Text(
                                      'Spy',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontFamily: 'CenturyGothic'
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
               
              //? BUTTONS:   APPLY AND RESET
              Padding(
                padding: EdgeInsets.only(top: 25.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // BUTTON:    RESET
                    GestureDetector(
                      onTap: () {
                        resetFilters();
                      },
                      child: Container(
                        width: 110.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(71.sp),
                          border: Border.all(color: Colors.white, width: 1.5)
                        ),
                        child: Center(
                          child: Text(
                            'Reset',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),
                      ),
                    ),
                
                    // BUTTON:    APPLY
                    GestureDetector(
                      onTap: () {
                        
                      },
                      child: Container(
                        width: 110.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(71.sp),
                          border: Border.all(color: const Color(0xFFFFB000), width: 1.5)
                        ),
                        child: Center(
                          child: Text(
                            'Apply',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: const Color(0xFFFFB000),
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


///////////// GAMESSSS LOBBY SCRENNN ////////////////
/// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



// lobby screen
class GameLobbyScreen extends StatefulWidget {
  // final String roomName;
  // final int currentPlayers;
  // final int maxPlayers;
  // final List<String> activeRoles;
  final Game game;
  final String password;

  const GameLobbyScreen({
    super.key, 
    // required this.roomName,
    // required this.currentPlayers,
    // required this.maxPlayers,
    // required this.activeRoles,
    required this.game,
    required this.password
  });

  @override
  State<GameLobbyScreen> createState() => _GameLobbyScreenState();
}

class _GameLobbyScreenState extends State<GameLobbyScreen> {
  List<ChatMessage> gameLobbyChatMessages = [];
  List<LobbyPlayer> gameLobbyPlayers = [];
  //final List<ChatMessage> messages = [];
  //Timer? _timer = null;
  bool timerIsStarted = false;
  int remainingTime = -1;


  bool shouldDisconnect = true;

  @override
  void initState() {
    super.initState();

    for (var player in widget.game.players) {
      gameLobbyPlayers.add(LobbyPlayer(
        nickname: player.nickname, 
        avatarUrl: player.avatarUrl, 
        isAlive: player.isAlive
      ));
    }

    // reference lazimdi her defe container nedi istifade elirsen
    
    var apiService = GetIt.I<ApiService>();

    // NOTE:    UNCOMMENT THIS SECTION

    
    //! ------------------- CHANGE ------------------- IIIIPPPP
    var connectionUri = (widget.game.hasPassword)
      ? "https://31.171.65.145/gamelobby?title=${widget.game.title}&password=${widget.password}" // passwordu tapammiram
      : "https://31.171.65.145/gamelobby?title=${widget.game.title}";

    //!   GAME LOBBY HUB
    apiService.gameHubConnection = HubConnectionBuilder().withUrl(
      connectionUri, // MURAD PASSWORD LAZIMDI BURA
      options: HttpConnectionOptions(
        accessTokenFactory: () => Future.value(GetIt.I<ApiService>().accessToken),
        // skipNegotiation: true,
        // transport: HttpTransportType.WebSockets,
      ),
    )
    .build();

    // DONE - TIMER HERE
    apiService.gameHubConnection.on('GameLobbyData', (List<Object?>? parameters) {
      // NOTE:    parameters as Map<String, dynamic> to variable
      log('1');
      final List<GameLobbyChatPlayer>? messages = GetIt.I<ApiService>().decodeGameLobbyChatPlayersParameters(parameters);
      log('2');
      // DONE:    MESSAGES IN VIEW

      setState(() {
        log('3');
        if (!(messages == null || messages.isEmpty)) {
          log('4');
          for (var message in messages) {
            gameLobbyChatMessages.add(ChatMessage(
              nickname: message.nickname, 
              avatarUrl: widget.game.players.firstWhere((player) => player.nickname == message.nickname).avatarUrl, 
              text: message.content
            ));
          }
        }
        log('5');
      });

      // DONE:    TIMER
      // final String eventTime = json.decode(parameters!.first as String)['eventTime'];
      // if (eventTime.isNotEmpty && !timerIsStarted) {
      //   final DateTime parsedDate = DateTime.parse(eventTime);

      //   setState(() {
      //     remainingTime = parsedDate.difference(DateTime.now()).inSeconds;
      //   });

      //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //     setState(() {
      //       if (remainingTime > 0) {
      //         remainingTime--;
      //       } else {
      //         timer.cancel();
      //       }
      //     });
      //   });

      //   timerIsStarted = !timerIsStarted;
      // }
    });
    
    // DONE
    apiService.gameHubConnection.on('GameStarted', (List<Object?>? parameters) {
      // {
      //   "role": "Mafia",
      //   "citizenCount": 5,
      //   "mafiaCount": 2,
      //   "playerRoles": [
      //     {
      //         "nickname": "Player1",
      //         "role": "Mafia"
      //     },
      //     {
      //         "nickname": "Player2",
      //         "role": "Citizen"
      //     },
      //     {
      //         "nickname": "Player3",
      //         "role": "Doctor"
      //     }
      //   ]
      // }

      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      String role = data['role'] ?? '';
      int citizenCount = data['citizenCount'] ?? 0;
      int mafiaCount = data['mafiaCount'] ?? 0;

      List<dynamic> playerRolesJson = data['playerRoles'] ?? [];
      List<PlayerRole> playerRoles = playerRolesJson.map((json) => PlayerRole.fromJson(json)).toList();

      startGame(widget.game.title, role, citizenCount, mafiaCount, playerRoles);
    });

    // DONE - TIMER HERE
    apiService.gameHubConnection.on('PlayerJoined', (List<Object?>? parameters) {
      log('1');
      if (parameters == null || parameters.isEmpty) {
        log('2');
        return;
      }

      // DONE:   PLAYER
      log(parameters.first as String);
      var data = json.decode(parameters.first as String);
      //var playerDto = data['player'] as Map<String, dynamic>;

      LobbyPlayer player = LobbyPlayer.fromJson(data);

      setState(() {
        gameLobbyPlayers.add(player);
      });

      // DONE:    EVENT TIME
      // String eventTime = data['eventTime'] ?? '';
      // if (eventTime.isNotEmpty && !timerIsStarted) {
      //   final DateTime parsedDate = DateTime.parse(eventTime);

      //   setState(() {
      //     remainingTime = parsedDate.difference(DateTime.now()).inSeconds;
      //   });

      //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      //     setState(() {
      //       if (remainingTime > 0) {
      //         remainingTime--;
      //       } else {
      //         timer.cancel();
      //       }
      //     });
      //   });

      //   timerIsStarted = !timerIsStarted;
      // }
    });

    // DONE
    apiService.gameHubConnection.on('PlayerLeft', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String nickname = parameters.first as String;

      setState(() {
        gameLobbyPlayers.removeWhere((player) => player.nickname == nickname);
        if (gameLobbyPlayers.length < widget.game.minPlayers) {
          remainingTime = -1;
        }
      });
    });

    // DONE
    // apiService.gameHubConnection.on('StopEventTimer', (List<Object?>? parameters) {
    //   // NOTE:    STOP TIMER IF THE TIMER TICKING
    //   setState(() {
    //     _timer!.cancel();
    //     remainingTime = 0;
    //   });
    // });

    // DONE
    apiService.gameHubConnection.on('ReceiveMessage', (List<Object?>? parameters) {
      log('PERVIN');
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      // NOTE:    CHANGE CLASS NAME
      GameLobbyChatPlayer message = GameLobbyChatPlayer.fromJson(data);

      final nickname = message.nickname;
      final content = message.content; 

      setState(() {
        gameLobbyChatMessages.add(ChatMessage(
          nickname: nickname, 
          avatarUrl: widget.game.players.firstWhere((player) => player.nickname == message.nickname).avatarUrl, 
          text: content
        ));
      });
    });

    // DONE
    apiService.gameHubConnection.on('CloseConnection', (List<Object?>? parameters) {
      print("Disonnected to SignalR! 1400 games screen");
      GetIt.I<ApiService>().disconnectGameHub();
    });

    // INCOMPLETE
    apiService.gameHubConnection.on('Timer', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      setState(() {
        remainingTime = parameters.first as int;
      });
    });
    
    // GetIt.I<ApiService>().gameHubConnection.onclose((error) {
    //     print('Connection closed by client. Error: ${error?.toString() ?? "No error"}');
    // });

    if (!apiService.gameHubIsConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        apiService.gameHubConnection.start()?.then((_) {
          apiService.gameHubIsConnected = true;
          print("Connected to SignalR! 1400 games screen");
        }).catchError((e) {
          print("Connection error: $e");
        });
      });
    }
    

    // _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    //   setState(() {
    //     if (remainingTime > 0) {
    //       remainingTime--;
    //     } else {
    //       timer.cancel();
    //       // Logic start after time ends
    //       startGame();
    //     }
    //   });
    // });
    
    //!!!!!!!!!!!!!!!
  }
  

  void startGame(String title, String role, int citizenCount, int mafiaCount, List<PlayerRole> playerRoles) {
    Navigator.push(
      context,
      // NOTE:  MATERIAL PAGE ROUTE ---- ANDROID: HER YERDE shupheli
      MaterialPageRoute(builder: (context) => 
        GameScreen(
          title: title,
          role: role,
          citizenCount: citizenCount,
          mafiaCount: mafiaCount,
          playersRole: playerRoles,
          allPlayers: widget.game.players,
          cameBackFromAfk: false,
          gameIsReadyWidget: true,
        )
      ),
    );
    log('Игра началась!');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    shouldDisconnect = ModalRoute.of(context)?.settings.name != "GameScreen";
  }

  @override
  void dispose() {
    //_timer?.cancel();
    // DONE
    if (shouldDisconnect) {
      print("Disonnected to SignalR! 1400 games screen");
      GetIt.I<ApiService>().disconnectGameHub();
    }
    print("1400 games screen Dispose");
    super.dispose();
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    //!!!!!!!!!!!!!!!!!!
    await GetIt.I<ApiService>().gameHubConnection.invoke("SendMessage", args: <Object>[ 
      text.trim()
    ]);

    setState(() {
      gameLobbyChatMessages.add(ChatMessage(
        nickname: authorizedUser.nickname,
        avatarUrl: authorizedUser.avatarUrl,
        text: text,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 35.sp;
    final double ornamentMargin = 10.sp;
    const String ornament = "assets/images/game-ornament-night.png";

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/background-waiting-lobby.png"), fit: BoxFit.cover),
      ),
      child: Scaffold(
        /*
        appBar: AppBar(
          title: Text(widget.game.title),
          actions: [
            Row(
              children: widget.game.extraRoles.map((role) => const Icon(Icons.person)).toList(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('${S.of(context).playersInRoom} [${gameLobbyPlayers.length}/${widget.game.maxPlayers}]'),
            ),
          ),
        ),
       */

        body: Stack(
          children: [
            

            Padding(
              padding: EdgeInsets.only(top: 50.h, right: 15.w, left: 15.w),
              child: Stack(
                children: [
                  
            
                  //? INFO PART
                  Container(
                    margin: EdgeInsets.only(top: 50.h),
                    width: double.maxFinite,
                    height: 150.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Stack(
                      children: [
            
                        //? ORNAMENTS
                        Stack(
                          children: [
                            // Top-left ornament
                            Positioned(
                              top: ornamentMargin,
                              left: ornamentMargin,
                              child: Image.asset(
                                ornament,
                                width: ornamentSize,
                                height: ornamentSize,
                              ),
                            ),
                            // Top-right ornament (rotated 90 degrees)
                            Positioned(
                              top: ornamentMargin,
                              right: ornamentMargin,
                              child: Transform.rotate(
                                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                                child: Image.asset(
                                  ornament,
                                  width: ornamentSize,
                                  height: ornamentSize,
                                ),
                              ),
                            ),
                            // Bottom-left ornament (rotated 270 degrees)
                            Positioned(
                              bottom: ornamentMargin,
                              left: ornamentMargin,
                              child: Transform.rotate(
                                angle: 270 * 3.14159 / 180, // 270 degrees in radians
                                child: Image.asset(
                                  ornament,
                                  width: ornamentSize,
                                  height: ornamentSize,
                                ),
                              ),
                            ),
                            // Bottom-right ornament (rotated 180 degrees)
                            Positioned(
                              bottom: ornamentMargin,
                              right: ornamentMargin,
                              child: Transform.rotate(
                                angle: 180 * 3.14159 / 180, // 180 degrees in radians
                                child: Image.asset(
                                  ornament,
                                  width: ornamentSize,
                                  height: ornamentSize,
                                ),
                              ),
                            ),
                          ],
                        ),
                      
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(),
            
                            Column(
                              children: [
            
                                //? TITLE
                                Padding(
                                  padding: EdgeInsets.only(top: 15.h),
                                  child: Text(
                                    widget.game.title, 
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 32.sp,
                                      color: const Color(0xFFFFB000)
                                    ),
                                  ),
                                ),
            
                                //? MIN AND MAX
                                Container(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: Row(
                                    children: [
            
                                      //? MIN COUNT
                                      Column(
                                        children: [
                                          Text(
                                            "${widget.game.minPlayers}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                              height: 0
                                            ),
                                          ),
            
                                          Text(
                                            "min",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                              height: 0
                                            ),
                                          )
                                        ],
                                      ),
            
                                      //? ACTUAL COUNT
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        child: Column(
                                          children: [
                                            Text(
                                              "${widget.game.players.length}",
                                              style: GoogleFonts.playfairDisplay(
                                                color: const Color(0xFFFFB000),
                                                fontSize: 32.sp,
                                              ),
                                            ),
                                            SizedBox(height: 15.h,)
                                          ],
                                        ),
                                      ),
            
                                      //? MAX COUNT
                                      Column(
                                        children: [
                                          Text(
                                            "${widget.game.maxPlayers}",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                              height: 0
                                            ),
                                          ),
            
                                          Text(
                                            "max",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                              height: 0
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              
                              ],
                            ),
            
                            const SizedBox()
                          ],
                        )
                      
                      ],
                    ),
                  ),
                
                  //? CARDS PART
                  Container(
                    margin: EdgeInsets.only(top: 215.h),
                    height: 80,
                    alignment: Alignment.center,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final int count = widget.game.extraRoles.length;
                        final double cardWidth = 60.w;
                        const double overlap = 20.0;

                        final double totalWidth = count > 0
                          ? cardWidth + (count - 1) * (cardWidth - overlap)
                          : 0;

                        return SizedBox(
                          height: 80.h,
                          width: totalWidth,
                          child: Stack(
                            children: List.generate(count, (i) {
                              int index = i; // инверсия: 4, 3, 2, 1, 0
                              
                              final leftOffset = index * (cardWidth - overlap);
                                      
                              return Positioned(
                                left: leftOffset,
                                child: RoleCard(
                                  roleName: widget.game.extraRoles[index].toLowerCase(), 
                                  width: cardWidth, 
                                  height: 80.h
                                )
                              );
                            }),
                          ),
                        );
                      }
                    ),
                  ),
            
                  //? CHAT, PLAYERS, TIMER
                  Container(
                    margin: EdgeInsets.only(top: 260.h),
                    width: double.maxFinite,
                    height: 450.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            //? PLAYERS
                            SizedBox(
                              width: 210.w,
                              height: 130.h,
                              child: GridView.builder(
                                padding: EdgeInsets.zero,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 2.5,
                                  crossAxisSpacing: 5,
                                  mainAxisSpacing: 5,
                                ),
                                itemCount: widget.game.players.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 10.w),

                                      //? AVATAR
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(50.sp),
                                        ),
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            widget.game.players[index].avatarUrl
                                          ),
                                          radius: 11.sp,
                                        )
                                      ),
                                      SizedBox(width: 4.w),

                                      //? NICKNAME
                                      Container(
                                        width: 60.w,
                                        child: Text(
                                          widget.game.players[index].nickname,
                                          softWrap: true,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
            
                            //? TIMER
                            Container(
                              margin: EdgeInsets.only(top: 10.h, right: 15.w),
                              width: 130.w,
                              height: 130.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5.w
                                )
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  remainingTime != -1
                                  ? Text(
                                    "Starting:",
                                    style: GoogleFonts.playfairDisplay(
                                      color: const Color(0xFFFFB000),
                                      fontSize: 22.sp,
                                      height: 0
                                    ),
                                  )
                                  : const SizedBox(),
                                  
            
                                  Padding(
                                    padding: remainingTime == -1 ? EdgeInsets.only(bottom: 5.h) : EdgeInsets.only(bottom: 0.h),
                                    child: Text(
                                      remainingTime != -1 ? '$remainingTime ${S.of(context).seconds}' : "Waiting...",
                                      style: GoogleFonts.playfairDisplay(
                                        color: const Color(0xFFFFB000),
                                        fontSize: 22.sp,
                                        height: 0
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        //? CHAT
                        Container(
                          margin: EdgeInsets.all(15.sp),
                          width: double.maxFinite,
                          height: 280.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5.w
                            )
                          ),
                          child: ChatWidget(messages: gameLobbyChatMessages),
                        )
                      ],
                    ),
                  ),
                
                  //? INPUT FIELD
                  Container(
                    margin: EdgeInsets.only(top: 725.h),
                    width: double.maxFinite,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B2B),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Row(
                      children: [
                        //? SMILES
                        Container(
                          margin: const EdgeInsets.only(left: 7, right: 7),
                          child: GestureDetector(
                            onTap: () {},
                            child: Image.asset(
                              'assets/images/game-stickers-icon.png',
                              width: 30.h,
                              height: 30.h,
                            ),
                          ),
                        ),
            
                        //? INPUT
                        SizedBox(
                          width: 310.w,
                          height: 55.h,
                          child: MessageInputField(onSend: sendMessage),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
            IgnorePointer(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.transparent
                    ],
                    stops: [0.7, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  "assets/images/light-waiting-lobby.png",
                  fit: BoxFit.cover,
                  height: 300.h,
                  width: double.maxFinite,
                ),
              ),
            ),
          
            // BUTTON:    GO BACK
            Padding(
              padding: EdgeInsets.only(top: 50.h, right: 15.w, left: 15.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                            
                  Container(
                    width: 33.w,
                    height: 33.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB000).withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8.sp),
                    ),
                    child: Icon(
                      Icons.keyboard_double_arrow_left,
                      color: Colors.white,
                      size: 33.sp,
                    ),
                  )
                ],
              ),
            ),
          ],
        )
        
        /*
        Column(
          children: [
            // Тimer: before the game starts
      
            // DEF:     TIMER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    remainingTime != -1 ? '${S.of(context).remainingTime}: $remainingTime ${S.of(context).seconds}' : "Waiting",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                // SizedBox(
                //   width: 60,
                //   height: 50,
                //   child: ElevatedButton(    
                //     onPressed: () {
                //       List<PlayerRole> playerRoles = [
                //         PlayerRole(
                //           nickname: 'Player1',
                //           role: 'Doctor'
                //         ),
                //         PlayerRole(
                //           nickname: 'Player2',
                //           role: 'Citizen'
                //         ),
                //         PlayerRole(
                //           nickname: 'Player3',
                //           role: 'Mafia'
                //         ),
                //         PlayerRole(
                //           nickname: 'Player4', 
                //           role: 'Citizen'
                //         ),
                //         PlayerRole(
                //           nickname: 'Player5',
                //           role: 'Citizen'
                //         ),
                //         PlayerRole(
                //           nickname: 'Player6',
                //           role: 'Mafia'
                //         ),
                //         PlayerRole(
                //           nickname: 'Player7',
                //           role: 'Barman'
                //         ),
                //       ];

                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => GameScreen(title: 'game name', playersRole: playerRoles, mafiaCount: 5, citizenCount: 7, role: 'Mafia', allPlayers: widget.game.players, cameBackFromAfk: false))
                //       );
                //     },
                //     child: Text(S.of(context).join),
                //   ),
                // ),
              
              ],
            ),
      
            // DEF:     Players Table
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: PlayerTableWidget(playersInRoom: gameLobbyPlayers),
              ),
            ),
      
            // DEF:     Chat
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: ChatWidget(messages: gameLobbyChatMessages),
              ),
            ),

            // Expanded(
            //   child: Container(
            //     decoration: BoxDecoration(
            //       border: Border.all(),
            //     ),
            //     child: StreamBuilder<List<Game>>(
            //       stream: GetIt.I<ApiService>().gamesStream,
            //       builder: (context, snapshot) {
            //         if (snapshot.connectionState == ConnectionState.waiting) {
            //           return const Center(child: CircularProgressIndicator());
            //         } else if (snapshot.hasError) {
            //           return Center(child: Text('Error: ${snapshot.error}'));
            //         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //           return const Center(child: Text('No games available.'));
            //         } else {
            //           final gamesSnap = snapshot.data!;
            //           return ListView.builder(
            //             itemCount: gamesSnap.length, 
            //             itemBuilder: (context, index) {
            //               return GameCard(game: gamesSnap[index]);
            //             },
            //           );
            //         }
            //       },
            //     ),
            //   ),
            // ),

            //! STREAM
            // body: 
            // StreamBuilder<List<Game>>(
            //   stream: GetIt.I<ApiService>().gamesStream,
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.waiting) {
            //       return const Center(child: CircularProgressIndicator());
            //     } else if (snapshot.hasError) {
            //       return Center(child: Text('Error: ${snapshot.error}'));
            //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //       return const Center(child: Text('No games available.'));
            //     } else {
            //       final gamesSnap = snapshot.data!;
            //       return ListView.builder(
            //         itemCount: gamesSnap.length, 
            //         itemBuilder: (context, index) {
            //           return GameCard(game: gamesSnap[index]);
            //         },
            //       );
            //     }
            //   },
            // ),
      
            // INPUT:     Enter the message
            Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: MessageInputField(onSend: sendMessage),
            ),
          ],
        ),
        */
      ),
    );
  }
}

class RoleIcon {
  final IconData icon;
  RoleIcon(this.icon);
}


// Player List
class PlayerTableWidget extends StatefulWidget {

  final List<LobbyPlayer> playersInRoom;

  const PlayerTableWidget({
    super.key, required this.playersInRoom
  });

  @override
  State<PlayerTableWidget> createState() => _PlayerTableWidgetState();
}

class _PlayerTableWidgetState extends State<PlayerTableWidget> {
  //////////////////////////////////////////////////////////
  // final List<Player> players = [
  //   Player(nickname: 'Murad', avatarUrl: 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg', status: 'alive'),
  //   Player(nickname: 'Pervin', avatarUrl: 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg', status: 'alive'),
  // ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.playersInRoom.length,
      itemBuilder: (context, index) {
        final player = widget.playersInRoom[index];
        return ListTile(
          leading: CircleAvatar(
            //////////////////////////////////////////////////////////
            // backgroundImage: NetworkImage(player.avatarUrl),
            backgroundImage: NetworkImage(player.avatarUrl), 
          ),
          title: Text(player.nickname, style: const TextStyle(color: Colors.white)),
        );
      },
    );
  }
}


// chat 
class ChatWidget extends StatefulWidget {
  final List<ChatMessage> messages;

  const ChatWidget({super.key, required this.messages});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant ChatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      controller: _scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(message.avatarUrl),
          ),
          title: Text(
            message.nickname, 
            style: TextStyle(
              color: const Color(0xFFFFB000),
              fontFamily: 'CenturyGothic',
              fontSize: 16.sp
            )
          ),
          subtitle: Text(
            message.text, 
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp
            )
          ),
        );
      },
    );
  }
}


class ChatMessage {
  final String nickname;
  final String avatarUrl;
  final String text;

  ChatMessage({required this.nickname, required this.avatarUrl, required this.text});
}


class MessageInputField extends StatefulWidget {
  final Function(String) onSend;

  const MessageInputField({super.key, required this.onSend});

  @override
  State<MessageInputField> createState() => _MessageInputFieldState();
}

class _MessageInputFieldState extends State<MessageInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 7.w, bottom: 6.h),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '${S.of(context).enterMessage}...',
                  border: InputBorder.none
                ),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onSend(_controller.text);
              _controller.clear();
            }
          },
        ),
      ],
    );
  }
}
