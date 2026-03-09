import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/blocs/player_event.dart';
import 'package:mafia_classic/features/games/game/game.dart';
import 'package:mafia_classic/features/games/popups/games_popups.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/roles/widgets/widgets.dart';
import 'package:mafia_classic/features/widgets/validation_popup.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/models/player.dart';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/signalr_service.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:mafia_classic/utils/popup_utils.dart';
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
//late User authorizedUser;
//User authorizedUser = User(id: 1123123123, email: "asdasd", nickname: "musayev", avatarUrl: "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg", accessToken: "accessToken", refreshToken: "refreshToken", expirationDate: DateTime.now());

class GamesScreen extends StatefulWidget {
  final User user;
  final ValueNotifier<int> tabIndexNotifier;
  final int tabIndex;

  const GamesScreen({
    super.key, 
    required this.user,
    required this.tabIndexNotifier,
    required this.tabIndex
  });

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> with RouteAware {
  bool _routeVisible = false;
  bool _tabVisible = false;

  bool get _isActive => _routeVisible && _tabVisible;

  String text = '';

  List<Game>? allGames = [];
  List<Game>? searchedGames = [];

  GameFilters currentFilters = GameFilters(
    accessState: 0,

    minPlayers: 4,
    maxPlayers: 21,

    hasSpy: false,
    hasLover: false,
    hasBodyguard: false,
    hasJournalist: false,
    hasTerrorist: false,
    hasBartender: false,
    hasInformant: false,

    roomsWithSpace: false,
  );

  void applyFilters(GameFilters filters) {
    setState(() {
      currentFilters = filters;
      if (allGames != null) {
        searchedGames = allGames!.where((game) {
          if (game.players.length < filters.minPlayers || game.players.length > filters.maxPlayers) return false;
          if (game.players.length == filters.maxPlayers) return false; // || OR GAME IS STARTED
          if (filters.accessState == 1 && game.hasPassword) return false;
          if (filters.accessState == 2 && !game.hasPassword) return false;

          List<String> requiredRoles = [];
          if (filters.hasBodyguard) requiredRoles.add('Bodyguard');
          if (filters.hasLover) requiredRoles.add('Beauty');
          if (filters.hasTerrorist) requiredRoles.add('Journalist');
          if (filters.hasTerrorist) requiredRoles.add('Spy');

          if (filters.hasTerrorist) requiredRoles.add('Terrorist');
          if (filters.hasTerrorist) requiredRoles.add('Informant');
          if (filters.hasTerrorist) requiredRoles.add('Barman');

          if (requiredRoles.isNotEmpty) {
            for (final role in requiredRoles) {
              if (!game.extraRoles.contains(role)) return false;
            }
          }

          return true;
        }).toList();
      }
    });
  }

  Future<void> openFilterizationScreen() async {
    final filters = await Navigator.push<GameFilters>(
      context,
      MaterialPageRoute(builder: (_) => FilterizationScreen(filters: currentFilters)),
    );

    if (filters != null) {
      applyFilters(filters);
    }
  }

  final TextEditingController _searchController = TextEditingController();

  //? STREAMS
  StreamSubscription<String>? lobbyRooms;
  StreamSubscription<String>? lobbyRoomCreated;
  StreamSubscription<String>? lobbyPlayerEnteredRoom;
  StreamSubscription<String>? lobbyPlayerExitedRoom;
  StreamSubscription<String>? lobbyPlayerGameStarted;
  StreamSubscription<String>? lobbyPlayerEliminated;
  StreamSubscription<String>? lobbyGameOver;
  StreamSubscription<String>? lobbyRoomClosed;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }

    widget.tabIndexNotifier.addListener(_onTabChanged);
  }

  void loadStreamsAndData() {
    TcpClientService().sendMessage(ClientCommand.getRooms.value, ""); //? lobbyRooms
    log('*************SEND MESSAGE IS SUCCEFULL*************');

    // DONE +
    lobbyRooms = EventRouterService()
        .subscribe(ServerEvent.lobbyRooms)
        .listen((payload) {
      final List<dynamic> jsonData = json.decode(payload)['rooms'];
      setState(() {
        final games = jsonData.map((gameJson) {
          return Game.fromJson(gameJson as Map<String, dynamic>);
        }).toList();

        final List<Game>? gamesList = games;

        if (gamesList != null) {
          setState(() {
            allGames = gamesList;
            searchedGames = allGames;
          });
        }
      });
    });

    // DONE +a
    lobbyRoomCreated = EventRouterService()
        .subscribe(ServerEvent.lobbyRoomCreated)
        .listen((payload) {
      try {
        final Map<String, dynamic> jsonData = json.decode(payload);

        final Game? game = Game.fromJson(jsonData);
        if (game != null) {
        setState(() {
          allGames?.add(game);
          searchedGames = allGames;
        });
      }
      } catch (e) {
        log("Event Router Service Error: GAMES SCREEN | LOBBY ROOM CREATE\n$e");
        return;
      }
    });

    // DONE +a
    lobbyPlayerEnteredRoom = EventRouterService()
        .subscribe(ServerEvent.lobbyPlayerEnteredRoom)
        .listen((payload) {
      if (payload.isEmpty) {
        log("Event Router Service Error: GAMES SCREEN | LOBBY ROOM CREATE\nNo data received.");
        return;
      }

      try {
        final dynamic jsonData = json.decode(payload);

        final PlayerJoinedGame? playerJoinedToGame = PlayerJoinedGame.fromJson(jsonData as Map<String, dynamic>);

        if (playerJoinedToGame != null && allGames != null) {
          if (!allGames!
            .firstWhere((game) => game.id == playerJoinedToGame.roomId)
            .players.any((player) => player.id == playerJoinedToGame.player.id)) {
            setState(() {
              allGames!
              .firstWhere((game) => game.id == playerJoinedToGame.roomId)
              .players.add(playerJoinedToGame.player);
              searchedGames = allGames;
            });
          }
        }
      } catch (e) {
        log("Event Router Service Error: GAMES SCREEN | LOBBY ROOM CREATE\n$e");
        return;
      }
    });

    // DONE +a
    lobbyPlayerExitedRoom = EventRouterService()
        .subscribe(ServerEvent.lobbyPlayerExitedRoom)
        .listen((payload) {
      if (payload.isEmpty) {
        log("Event Router Service Error: GAMES SCREEN | LOBBY PLAYER EXITED ROOM\nNo data received.");
        return;
      }

      try {
        final dynamic jsonData = json.decode(payload);

        final PlayerLeftGame? playerLeftGame = PlayerLeftGame.fromJson(jsonData as Map<String, dynamic>);

        if (playerLeftGame != null && allGames != null) {
          if (allGames!
            .firstWhere((game) => game.id == playerLeftGame.roomId)
            .players.any((player) => player.id == playerLeftGame.playerId)) {

            setState(() {
              allGames!
              .firstWhere((game) => game.id == playerLeftGame.roomId)
              .players.removeWhere((player) => player.id == playerLeftGame.playerId);
              searchedGames = allGames;
            });
          }
          else {
            log('Event Router Service Info: GAMES SCREEN | LOBBY PLAYER EXITED ROOM -> There is no player with this nickname');
          }
        }
      } catch (e) {
        log("Event Router Service Error: GAMES SCREEN | LOBBY PLAYER EXITED ROOM\n$e");
        return;
      }
    });
    
    // DONE +a
    lobbyPlayerGameStarted = EventRouterService()
        .subscribe(ServerEvent.lobbyGameStarted)
        .listen((payload) {
      final String? roomId = json.decode(payload)['roomId'];

      if (roomId != null && allGames != null) {
        if (allGames!.any((game) => game.id == roomId)) {
          setState(() {
            allGames!.firstWhere((game) => game.id == roomId).status = 'Started';
            searchedGames = allGames;
          });
        }
      }
    });

    // PARTIALLY DONE +
    lobbyPlayerEliminated = EventRouterService()
        .subscribe(ServerEvent.lobbyPlayerEliminated)
        .listen((payload) {
      try {
        if (payload.isEmpty) {
          log("Event Router Service Error: GAMES SCREEN | LOBBY PLAYER ELIMINATED\nNo data received.");
          return;
        }
        
        var data = json.decode(payload);
        
        final int playerId = data['playerId'];
        final String roomId = data['roomId'];
        
        setState(() {
          allGames!
            .firstWhere((e) => e.id == roomId).players
            .firstWhere((e) => e.id == playerId).isAlive = false;
          searchedGames = allGames;
        });
      } on Exception catch (e) {
        log('Event Router Service Error: GAMES SCREEN | LOBBY PLAYER ELIMINATED\n${e.toString()}');
      }
    });

    // DONE +a
    lobbyGameOver = EventRouterService()
        .subscribe(ServerEvent.lobbyGameOver)
        .listen((payload) {
      final String? roomId = json.decode(payload)['roomId'];

      if (roomId != null && allGames != null) {
        if (allGames!.any((game) => game.id == roomId)) {
          setState(() {
            allGames!.firstWhere((game) => game.id == roomId).status = 'Wating';
            searchedGames = allGames;
          });
        }
      }
    });

    // DONE +a
    lobbyRoomClosed = EventRouterService()
        .subscribe(ServerEvent.lobbyRoomClosed)
        .listen((payload) {
      final String? roomId = json.decode(payload)['roomId'];

      if (roomId != null && allGames != null) {
        if (allGames!.any((game) => game.id == roomId)) {
          setState(() {
            allGames!.removeWhere((game) => game.id == roomId);
            searchedGames = allGames;
          });
        }
      }
    });

    authorizedUser = widget.user;
    //allGames = games;
    searchedGames = allGames;
  }

  @override
  void initState() {
    super.initState(); 
    //loadStreamsAndData();    
  }

  /// FIRST TIME tab becomes visible
  @override
  void didPush() {
    _routeVisible = true;
    _evaluateState();
  }

  /// coming back to this tab
  @override
  void didPopNext() {
    _routeVisible = true;
    _evaluateState();
  }

  /// leaving this tab (switch tab or push)
  @override
  void didPushNext() {
    _routeVisible = false;
    _evaluateState();
  }

  void _onTabChanged() {
    final visible = widget.tabIndexNotifier.value == widget.tabIndex;

    if (visible != _tabVisible) {
      _tabVisible = visible;
      _evaluateState();
    }
  }

  void _evaluateState() {
    if (_isActive) {
      _onActive();
    } else {
      _onInactive();
    }
  }

  @override
  void dispose() {
    widget.tabIndexNotifier.removeListener(_onTabChanged);
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  void _onActive() {
    // if (_active) return;
    // _active = true;

    loadStreamsAndData();

    print('GamesScreen ACTIVE');
    // TcpClientService().connect(widget.user.id);
  }

  void _onInactive() {
    // if (!_active) return;
    // _active = false;

    lobbyRooms?.cancel();
    lobbyRoomCreated?.cancel();
    lobbyPlayerEnteredRoom?.cancel();
    lobbyPlayerExitedRoom?.cancel();
    lobbyPlayerGameStarted?.cancel();
    lobbyPlayerEliminated?.cancel();
    lobbyGameOver?.cancel();
    lobbyRoomClosed?.cancel();

    print('GamesScreen INACTIVE');
    // TcpClientService().disconnect();
  }

  void _loadGames() async {
    // final fetchedGames = await GetIt.I<ApiService>().getGames();
    // setState(() {
    //   //games = fetchedGames;
    // });
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 45.sp;
    final double ornamentMargin = 12.sp;
    const String ornament = "assets/images/game-ornament-night.png";

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/background-games&filter.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: EdgeInsets.only(top: 50.h, right: 20.w, left: 20.w),
          child: Column(
            children: [

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BUTTON:    HOME
                  const SizedBox(),
                  /*
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/images/home-icon.png",
                      scale: 2.8,
                    ),
                  ),
                  */

                  // BUTTON:    FILTER
                  GestureDetector(
                    onTap: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (_) => FilterizationScreen(filters: currentFilters),
                      //   )
                      // );
                      openFilterizationScreen();
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
                                AppLocalizations.of(context)!.lobby,
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
                                    // INPUT:    SEARCH
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
                                          decoration: InputDecoration(
                                            hintText: ' ${AppLocalizations.of(context)!.search}',
                                            hintStyle: const TextStyle(color: Color.fromARGB(255, 166, 166, 166), fontFamily: 'CenturyGothic'),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // BUTTON:    SEARCH
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
                                AppLocalizations.of(context)!.filterOff,
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

              //? GAMES
              Expanded(
                child: 
                Container(
                  margin: EdgeInsets.only(top: 10.h),
                  height: 500.h,
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.sp),
                  ),
                  child: (searchedGames!.isEmpty)
                  ? Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          AppLocalizations.of(context)!.noAvailableGames,
                          style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 22
                          ),
                        )
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: searchedGames!.length,
                      itemBuilder: (context, index) {
                        return GameCard(game: searchedGames![index], loadStreamsAndData: loadStreamsAndData,);
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
  final String id;
  final String title;
  //final int currentPlayers; // massive size
  final int minPlayers;
  final int maxPlayers;
  String status;
  final bool hasPassword;
  final List<String> extraRoles;
  final List<Player> players;

  Game({
    required this.id,
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
      id: json['roomId'],
      title: json['title'],
      //currentPlayers: json['currentPlayers'],
      //currentPlayers: json['currentPlayers'],
      minPlayers: json['minCapacity'],    
      maxPlayers: json['maxCapacity'],    
      hasPassword: json['hasPassword'],
      status: json['state'],
      players: json['players'].isEmpty ? <Player>[] : (json['players'] as List)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      extraRoles: json['extraGameRoles'].isEmpty ? <String>[] : json['extraGameRoles'].cast<String>(),    
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
  final void Function() loadStreamsAndData;

  const GameCard({super.key, required this.game, required this.loadStreamsAndData});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  String text = '';
  String password = '';
  bool isCardExpanded = false;

  late StreamSubscription<String> passwordIsWrong;
  bool canBeNavigated = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }
  
  @override
  void initState() {
    passwordIsWrong = EventRouterService()
        .subscribe(ServerEvent.clientError)
        .listen((payload) {
      try {
        setState(() {
          canBeNavigated = false;
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     : ${e.toString()}');
      }
    });


    if (widget.game.players.any((e) => e.id == authorizedUser.id)) {
      if (widget.game.players.firstWhere((e) => e.id == authorizedUser.id).isAlive) {
        text = 'You Are Playing Here';
      } else {
        text = 'You Died Here';
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    passwordIsWrong.cancel();
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
            widget.game.status == 'Started' && text == ''
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
                  onTap: () async {
                    
                    if (widget.game.hasPassword) {
                      final result = await showGeneralDialog<String>(
                        context: context,
                        useRootNavigator: true,              // <— важно
                        barrierDismissible: false, 
                        //barrierDismissible: true,
                        barrierLabel: "Dismiss",
                        barrierColor: Colors.black.withOpacity(0.7),
                        transitionDuration: const Duration(milliseconds: 800),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          //return const InformationPopup(effect: 'satisfied');
                          return const GameJoinPasswordPopup();
                          //return GameOverPopup(isMafiaWinner: true, score: 250);
                        },
                        transitionBuilder:
                            (context, animation, secondaryAnimation, child) {
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

                      log("RESULT: $result");

                      if (result == null) {
                        log("RESULT IS NOT SUCCESFULL");
                        return;
                      } else {
                        password = result;
                      }
                    }

                    //! PROVERKA

                    
                    final jsonString = jsonEncode({
                      'roomId': widget.game.id,
                      'password': password,
                    });

                    TcpClientService().sendMessage(ClientCommand.joinRoom.value, jsonString);

                    if (text == 'You Are Playing Here' || text == 'You Died Here') {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return GameScreen(title: widget.game.title, playersRole: [] , role: '', mafiaCount: 0, civilianCount: 0, allPlayers: widget.game.players, cameBackFromAfk: true, gameIsReadyWidget: false, phase: "",);
                          }
                        )
                      ).then((result) {
                        widget.loadStreamsAndData();
                      });
                    }
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
                        AppLocalizations.of(context)!.join,
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
                                AppLocalizations.of(context)!.min,
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
                                AppLocalizations.of(context)!.max,
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
                    AppLocalizations.of(context)!.playersInTheRoom,
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
                                    RoleCard(roleName: widget.game.extraRoles[index].toLowerCase(), width: 70.w, height: 93.h, isMini: false)
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
                          AppLocalizations.of(context)!.areHere, // Replace with your text
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
                        final playersNotifier = ValueNotifier<List<Player>>(widget.game.players);
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: "Dismiss",
                          barrierColor: Colors.black.withOpacity(0.7),
                          transitionDuration: const Duration(milliseconds: 800),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return PlayersPopup(playersNotifier: playersNotifier, gameTitle: widget.game.title,);
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
                            AppLocalizations.of(context)!.show,
                            style: GoogleFonts.playfairDisplay(
                              height: 0,
                              color: const Color(0xFFFFB000),
                              fontSize: 20.sp
                            )
                          ),
                      
                          Text(
                            AppLocalizations.of(context)!.allPlayers,
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
            
              if (text.isNotEmpty)
                //? DIVIDER
                Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  width: 320.w,
                  child: const Divider(
                    color: Colors.white,
                    thickness: 1,
                  ),
                ),
              
              if (text.isEmpty)
                SizedBox(height: 10.h),

              // TEXT:    USER STATE
              if (text.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Text(
                    text == 'You Are Playing Here'
                    ? AppLocalizations.of(context)!.youArePlayingHere
                    : text == 'You Died Here'
                    ? AppLocalizations.of(context)!.youDiedHere
                    : '',
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
  final int id;
  final String nickname;
  final String avatarUrl;
  bool isAlive;

  Player({
    required this.id,
    required this.nickname, 
    required this.avatarUrl, 
    required this.isAlive
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
      isAlive: json['isAlive'] as bool
    );
  }
}

List<Player> players = [
  Player(
    id: -11,
    nickname: 'Player1', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    id: -12,
    nickname: 'Player2', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: false
  ),
  Player(
    id: -13,
    nickname: 'Player3', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    id: -14,
    nickname: 'Player4', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    id: -15,
    nickname: 'Player5', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
  Player(
    id: -16,
    nickname: 'Player6', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: false
  ),
  Player(
    id: -17,
    nickname: 'Player7', 
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
    isAlive: true
  ),
];

List<Player> playersWithMe = [
  Player(
    id: -1,
    nickname: 'Player1', 
    avatarUrl: 'https://example.com/avatar1.png', 
    isAlive: true
  ),
  Player(
    id: -2,
    nickname: 'Player2', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: false
  ),
  Player(
    id: -3,
    nickname: 'Player3', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
  Player(
    id: -4,
    nickname: 'Player4', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
  Player(
    id: -5,
    nickname: 'musayev', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
  Player(
    id: -6,
    nickname: 'Player6', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: false
  ),
  Player(
    id: -7,
    nickname: 'Player7', 
    avatarUrl: 'https://example.com/avatar2.png', 
    isAlive: true
  ),
];

////////// PLAYER ///////

class PlayersPopup extends StatefulWidget {
  final ValueNotifier<List<Player>> playersNotifier;
  final String gameTitle;
  
  const PlayersPopup({
    super.key, 
    required this.playersNotifier, 
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
      child: ValueListenableBuilder(
        valueListenable: widget.playersNotifier,
        builder: (context, value, child) {
          return Container(
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
                      itemCount: value.length,
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
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 0.7.sp,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: CircleAvatar(
                                          radius: 15,
                                          backgroundImage: NetworkImage(value[index].avatarUrl),
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        value[index].nickname, 
                                        style: TextStyle(
                                          fontSize: 15.sp, 
                                          fontFamily: 'CenturyGothic',
                                          color: value[index].isAlive == true ? const Color(0xFFFFB000) : const Color(0xFF515151)
                                        )
                                      ),
                                    ],
                                  ),
                                              
                                  // TEXT:    DEFEATED OR STILL HERE
                                  Text(
                                    value[index].isAlive == true ? AppLocalizations.of(context)!.stillHere : AppLocalizations.of(context)!.defeated,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: 'CenturyGothic',
                                      color: widget.playersNotifier.value[index].isAlive == true ? const Color(0xFFFFB000) : const Color(0xFF515151),
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
          );
        }
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
  final String roomId;
  final Player player;

  PlayerJoinedGame({
    required this.roomId,
    required this.player
  });
  
  factory PlayerJoinedGame.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedGame(
      roomId: json['roomId'],
      player: Player.fromJson(json['player'])
    );
  }
}

class PlayerLeftGame {
  final String roomId;
  final int playerId;

  PlayerLeftGame({
    required this.roomId,
    required this.playerId
  });
  
  factory PlayerLeftGame.fromJson(Map<String, dynamic> json) {
    return PlayerLeftGame(
      roomId: json['roomId'],
      playerId: json['playerId']
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
  final int id;
  final String role;

  PlayerRole({required this.id, required this.role});

  factory PlayerRole.fromJson(Map<String, dynamic> json) {
    return PlayerRole(
      id: json['id'] ?? 0,
      role: json['role'] ?? '',
    );
  }
}

class CreateGameScreen extends StatefulWidget {
  final ValueNotifier<int> tabIndexNotifier;
  final int tabIndex;

  const CreateGameScreen({
    super.key,
    required this.tabIndexNotifier,
    required this.tabIndex
  });

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

//// LOGIC ////
class _CreateGameScreenState extends State<CreateGameScreen> with RouteAware{
  bool _routeVisible = false;
  bool _tabVisible = false;

  bool get _isActive => _routeVisible && _tabVisible;
  
  String roomName = '';
  int minPlayers = 7;
  int maxPlayers = 14;

  int showedMinPlayers = 7;
  int showedMaxPlayers = 14;
  
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

  //StreamSubscription<String>? roomStateData;

  @override
  void initState() {
    super.initState();
    rolesL10 = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }

    widget.tabIndexNotifier.addListener(_onTabChanged);
    
    rolesL10 = {
      AppLocalizations.of(context)!.mistress: false,
      AppLocalizations.of(context)!.journalist: false,
      AppLocalizations.of(context)!.bodyguard: false,
      AppLocalizations.of(context)!.spy: false,
      AppLocalizations.of(context)!.terrorist: false,
      AppLocalizations.of(context)!.barman: false,
      AppLocalizations.of(context)!.informant: false,
    };

    mainRoles = {
      "Mistress": false,
      "Journalist": false,
      "Bodyguard": false,
      "Spy": false,
      "Terrorist": false,
      "Barman": false,
      "Informant": false,
    };
  }

  void createGameLobby() async {
    final roleFlags = {
      'Spy': hasSpy,
      'Barman': hasBartender,
      'Bodyguard': hasBodyguard,
      'Doctor': hasDoctor,
      'Informant': hasInformant,
      'Journalist': hasJournalist,
      'Beauty': hasLover,
      'Terrorist': hasTerrorist,
    };

    final extras = roleFlags.entries
      .where((entry) => entry.value)
      .map((entry) => entry.key)
      .toList();


    final jsonString = jsonEncode({
      'Title': roomName,
      'MinCapacity': minPlayers,
      'MaxCapacity': maxPlayers,
      'Password': password,
      'ExtraGameRoles': extras,
    });

    TcpClientService().sendMessage(ClientCommand.createRoom.value, jsonString);

    // bool status = await GetIt.I<ApiService>().createGame(
    //   CreateGame(
    //     title: roomName, 
    //     minPlayers: minPlayers, 
    //     maxPlayers: maxPlayers, 
    //     password: password, 
    //     extraRoles: extras
    //   )
    // );
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    widget.tabIndexNotifier.removeListener(_onTabChanged);
    super.dispose();

    //roomStateData.cancel();
  }

  void _onTabChanged() {
    final visible = widget.tabIndexNotifier.value == widget.tabIndex;

    if (visible != _tabVisible) {
      _tabVisible = visible;
      _evaluateState();
    }
  }

  void _evaluateState() {
    if (_isActive) {
      _onActive();
    } else {
      _onInactive();
    }
  }

  /// FIRST TIME tab becomes visible
  @override
  void didPush() {
    _routeVisible = true;
    _evaluateState();
  }

  /// coming back to this tab
  @override
  void didPopNext() {
    _routeVisible = true;
    _evaluateState();
  }

  /// leaving this tab (switch tab or push)
  @override
  void didPushNext() {
    _routeVisible = false;
    _evaluateState();
  }

  void _onActive() {
    // if (_active) return;
    // _active = true;

    /*
    roomStateData = EventRouterService()
        .subscribe(ServerEvent.roomStateData)
        .listen((payload) {
      print('----- LOBBY ROOMS DATA:  CreateGameScreen -----');
      
      //print(payload);
      final roleFlags = {
        'Spy': hasSpy,
        'Barman': hasBartender,
        'Bodyguard': hasBodyguard,
        'Doctor': hasDoctor,
        'Informant': hasInformant,
        'Journalist': hasJournalist,
        'Beauty': hasLover,
        'Terrorist': hasTerrorist,
      };

      final extras = roleFlags.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => GameLobbyScreen(
            game: Game(
              id: '',
              title: roomName, 
              minPlayers: minPlayers,
              maxPlayers: maxPlayers,
              status: 'Waiting',
              extraRoles: extras, 
              hasPassword: false, 
              players: [
                Player(
                  id: authorizedUser.id,
                  nickname: authorizedUser.nickname, 
                  avatarUrl: authorizedUser.avatarUrl, 
                  isAlive: true
                )
              ]
            ),
            //!!!!!!!!! CHANGE
            password: '',
          )
        ),
      );
    
    });
    */
    print('Create GamesScreen ACTIVE');
    // TcpClientService().connect(widget.user.id);
  }

  void _onInactive() {
    // if (!_active) return;
    // _active = false;

    //roomStateData?.cancel();

    print('Create GamesScreen INACTIVE');
    // TcpClientService().disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/temp-create-game-background.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        body: Padding(
          padding: EdgeInsets.only(top: 50.h),
          child: Column(
            children: [
            
              // BUTTON:   HOME
              /*
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
              */

              // TEXT:    Create Game
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.createGame,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 38.sp,
                      color: Colors.white
                    ),
                  )
                ],
              ),

              SizedBox(height: 27.h),
            
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
                
                    // INPUT:    TITLE
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
                            roomName = value;
                          });
                        },
                        controller: _titleController,
                        style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: 'CenturyGothic'),
                        decoration: InputDecoration(
                          hintText: ' ${AppLocalizations.of(context)!.enterTheTitle}',
                          hintStyle: TextStyle(color: const Color(0xFF515151), fontFamily: 'CenturyGothic', fontSize: 14.sp),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        maxLength: 14,
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
                                '${AppLocalizations.of(context)!.password} ${isPasswordVisible ? AppLocalizations.of(context)!.on : AppLocalizations.of(context)!.off}',
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
                                    ? Image.asset('assets/images/locker-closed-icon.png', scale: 3.2.sp)
                                    : Image.asset('assets/images/locker-opened-icon.png', scale: 3.2.sp) 
                                ),
                              )
                            
                            ],
                          ),
                        ),
                      ],
                    ),
                  
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            child: child,
                          ),
                        );
                      },
                    child:
                      isPasswordVisible
                      ?
                      // INPUT:    PASSWORD
                      Padding(
                        padding: EdgeInsets.only(top: 15.h, bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
                                    password = value;
                                  });
                                },
                                controller: _passwordController,
                                style: TextStyle(color: Colors.white, fontSize: 14.sp, fontFamily: 'CenturyGothic'),
                                decoration: InputDecoration(
                                  hintText: ' ${AppLocalizations.of(context)!.enterThePassword}',
                                  hintStyle: TextStyle(color: const Color(0xFF515151), fontFamily: 'CenturyGothic', fontSize: 14.sp),
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                maxLength: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                      :
                      const SizedBox.shrink(key: ValueKey('empty')),
                    )
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
                      AppLocalizations.of(context)!.numberOfPlayers,
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
                            min: 4,
                            max: 21,
                            divisions: 17,
                            
                            
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
                        AppLocalizations.of(context)!.extraRoles,
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
                              padding: EdgeInsets.only(top: 25.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDDB98B),
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              child: Column(
                                children: [
                                  //? BODYGUARD
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          AppLocalizations.of(context)!.bodyguard,
                                          style: TextStyle(
                                            color: const Color(0xFFFFFFFF),
                                            fontSize: 18.sp,
                                            fontFamily: 'CenturyGothic',
                                          ),
                                          softWrap: true,
                                          maxLines: 2,
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
                                          AppLocalizations.of(context)!.spy,
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
                                          AppLocalizations.of(context)!.journalist,
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
        
                                  //? BEAUTY
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // TEXT:
                                      Padding(
                                        padding: EdgeInsets.only(left: 8.w, top: 8.h),
                                        child: Text(
                                          AppLocalizations.of(context)!.beauty,
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
                              padding: EdgeInsets.only(top: 40.h),
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
                                          AppLocalizations.of(context)!.terrorist,
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
                                          AppLocalizations.of(context)!.bartender,
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
                                          AppLocalizations.of(context)!.informant,
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
                        createGameLobby();
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
                            AppLocalizations.of(context)!.create,
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
                  labelText: AppLocalizations.of(context)!.roomName,
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
              Text('${AppLocalizations.of(context)!.players}: $minPlayers - $maxPlayers'),
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
                AppLocalizations.of(context)!.roles,
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
                  labelText: AppLocalizations.of(context)!.passwordOptional,
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
                  child: Text(AppLocalizations.of(context)!.createGame),
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
  final GameFilters filters;

  const FilterizationScreen({super.key, required this.filters});

  @override
  State<FilterizationScreen> createState() => _FilterizationScreenState();
}

//// LOGIC ////
class _FilterizationScreenState extends State<FilterizationScreen> {
  int minPlayers = 4;
  int maxPlayers = 21;

  bool friendsInRoom = false;
  bool roomsWithSpace = false;
  // bool roomsWithoutPassword = false;
  // bool roomsWithPassword = false;
  int accessState = 0;
  //bool noAdditionalRoles = false;

  bool hasBodyguard = false;
  bool hasLover = false;
  bool hasSpy = false;
  bool hasJournalist = false;

  bool hasTerrorist = false;
  bool hasBartender = false;
  bool hasInformant = false;

  bool isReseted = false;
  
  @override
  void initState() {
    super.initState();
    minPlayers = widget.filters.minPlayers;
    maxPlayers = widget.filters.maxPlayers;
    friendsInRoom = widget.filters.friendsInRoom;
    roomsWithSpace = widget.filters.roomsWithSpace;
    accessState = widget.filters.accessState;

    hasBodyguard = widget.filters.hasBodyguard;
    hasLover = widget.filters.hasLover;
    hasSpy = widget.filters.hasSpy;
    hasJournalist = widget.filters.hasJournalist; 
    hasTerrorist = widget.filters.hasTerrorist;
    hasBartender = widget.filters.hasBartender;
    hasInformant = widget.filters.hasInformant;
  }

  void confirmFilters() {
    Navigator.pop(
      context,
      GameFilters(
        accessState: accessState, 
        minPlayers: minPlayers, 
        maxPlayers: maxPlayers, 
        roomsWithSpace: roomsWithSpace, 
        hasBodyguard: hasBodyguard, 
        hasLover: hasLover, 
        hasSpy: hasSpy, 
        hasJournalist: hasJournalist, 
        hasTerrorist: hasTerrorist, 
        hasBartender: hasBartender, 
        hasInformant: hasInformant
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 45.sp;
    final double ornamentMargin = 10.sp;
    const String ornament = "assets/images/game-ornament-night.png";

    Map<String, bool> additionalRoles = {
      //AppLocalizations.of(context)!.doctor: false,
      //AppLocalizations.of(context)!.sheriff: false,
      AppLocalizations.of(context)!.mistress: false,
      AppLocalizations.of(context)!.journalist: false,
      AppLocalizations.of(context)!.bodyguard: false,
      AppLocalizations.of(context)!.spy: false,
      AppLocalizations.of(context)!.terrorist: false,
      AppLocalizations.of(context)!.barman: false,
      AppLocalizations.of(context)!.informant: false,
    };

    void resetFilters() {
      setState(() {
        isReseted = true;
        minPlayers = 4;
        maxPlayers = 21;
        friendsInRoom = false;
        roomsWithSpace = false;
        // roomsWithoutPassword = false;
        // roomsWithPassword = false;
        accessState = 0;
        //noAdditionalRoles = false;

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
        image: DecorationImage(image: AssetImage("assets/images/background-filter.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        body: Padding(
          padding: EdgeInsetsGeometry.only(top: 50.h, left: 15.w, right: 15.w),
          child: Column(
            children: [
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
                              AppLocalizations.of(context)!.filter,
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
                                  //resetFilters();
                                  //confirmFilters();
                                  !isReseted ? Navigator.of(context).pop() : confirmFilters();
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
                                      AppLocalizations.of(context)!.close,
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
                      AppLocalizations.of(context)!.numberOfPlayers,
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
                            min: 4,
                            max: 21,
                            divisions: 17,
                            
                            activeColor: const Color(0xFFFFB000),
                            inactiveColor: Colors.white,
                            onChanged: (RangeValues values) {
                              setState(() {
                                minPlayers = values.start.toInt();
                                maxPlayers = values.end.toInt();
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
                                '$minPlayers',
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
                                '$maxPlayers',
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
                      AppLocalizations.of(context)!.roomsWith,
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
                                  AppLocalizations.of(context)!.availableSpots,
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
                                AppLocalizations.of(context)!.friendsIn,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
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
                                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5.sp),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    // setState(() {
                                    //   friendsInRoom = !friendsInRoom;
                                    // });
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
                        AppLocalizations.of(context)!.access,
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
                                AppLocalizations.of(context)!.mixed,
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
                          width: 90.w,
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
                                AppLocalizations.of(context)!.open,
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
                                AppLocalizations.of(context)!.private,
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
                height: 150.h,
                width: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // TEXT:    Included Roles
                    Text(
                      AppLocalizations.of(context)!.includedRoles,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),

                    Container(
                      height: 100.h,
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
                                      margin: EdgeInsets.only(left: 30.w),
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
                                        AppLocalizations.of(context)!.bodyguard,
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
                                      AppLocalizations.of(context)!.terrorist,
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
                                      margin: EdgeInsets.only(right: 30.w, left: 10.w),
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
                                        margin: EdgeInsets.only(left: 30.w),
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
                                          AppLocalizations.of(context)!.journalist,
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
                                        AppLocalizations.of(context)!.bartender,
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
                                        margin: EdgeInsets.only(left: 10.w, right: 30.w),
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
                                        margin: EdgeInsets.only(left: 30.w),
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
                                          AppLocalizations.of(context)!.beauty,
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
                                        AppLocalizations.of(context)!.informant,
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
                                        margin: EdgeInsets.only(left: 10.w, right: 30.w),
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
                                      AppLocalizations.of(context)!.spy,
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
                            AppLocalizations.of(context)!.reset,
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
                        confirmFilters();
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
                            AppLocalizations.of(context)!.apply,
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


class GameFilters {
  int accessState;
  int minPlayers;
  int maxPlayers;

  bool friendsInRoom;
  bool roomsWithSpace;

  bool hasBodyguard;
  bool hasLover;
  bool hasSpy;
  bool hasJournalist;

  bool hasTerrorist;
  bool hasBartender;
  bool hasInformant;

  GameFilters({
    required this.accessState,
    required this.minPlayers,
    required this.maxPlayers,
    required this.roomsWithSpace,
    required this.hasBodyguard,
    required this.hasLover,
    required this.hasSpy,
    required this.hasJournalist,
    required this.hasTerrorist,
    required this.hasBartender,
    required this.hasInformant,

    this.friendsInRoom = false
  });
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

  late StreamSubscription<String> roomStateData;
  late StreamSubscription<String> roomPlayerJoined;
  late StreamSubscription<String> roomPlayerLeft;
  late StreamSubscription<String> roomTimerUpdate;
  late StreamSubscription<String> roomNewMessage;
  late StreamSubscription<String> gameInitialState;

  @override
  void initState() {
    super.initState();

    for (var player in widget.game.players) {
      log('nickname: ${player.nickname} | avatar url: ${player.avatarUrl} | isAlive: ${player.isAlive}');
      gameLobbyPlayers.add(LobbyPlayer(
        id: player.id,
        nickname: player.nickname, 
        avatarUrl: player.avatarUrl, 
        isAlive: player.isAlive
      ));
    }

    // DONE+
    roomStateData = EventRouterService()
        .subscribe(ServerEvent.roomStateData)
        .listen((payload) {
      print('\n\n----- LOBBY ROOMS DATA: GAME LOBBY SCREEN -----\n\n');
      print(payload);
    });

    // DONE+
    roomPlayerJoined = EventRouterService()
        .subscribe(ServerEvent.roomPlayerJoined)
        .listen((payload) {
      if (payload.isEmpty) {
        return;
      }

      var data = json.decode(payload);

      LobbyPlayer player = LobbyPlayer.fromJson(data);

      setState(() {
        gameLobbyPlayers.add(player);
        widget.game.players.add(Player(
          id: player.id,
          avatarUrl: player.avatarUrl, 
          nickname: player.nickname, 
          isAlive: true
        ));
        gameLobbyChatMessages.add(
          ChatMessage(
            isSystemMessage: true, 
            nickname: player.nickname, 
            avatarUrl: player.avatarUrl,
            text: '[${player.nickname}] ${AppLocalizations.of(context)!.hasJoined}'
          )
        );
      });
    });

    // DONE+
    roomPlayerLeft = EventRouterService()
        .subscribe(ServerEvent.roomPlayerLeft)
        .listen((payload) {
      if (payload.isEmpty) return;

      final int id = json.decode(payload)['id'];

      setState(() {
        gameLobbyChatMessages.add(
          ChatMessage(
            isSystemMessage: true, 
            nickname: gameLobbyPlayers.firstWhere((player) => player.id == id).nickname, 
            avatarUrl: gameLobbyPlayers[0].avatarUrl,
            text: '[${gameLobbyPlayers.firstWhere((player) => player.id == id).nickname}] ${AppLocalizations.of(context)!.hasLeft}'
          )
        );
        gameLobbyPlayers.removeWhere((player) => player.id == id);
        widget.game.players.removeWhere((player) => player.id == id);
        if (gameLobbyPlayers.length < widget.game.minPlayers) {
          remainingTime = -1;
        }
      });
    });

    // DONE+
    roomTimerUpdate = EventRouterService()
        .subscribe(ServerEvent.roomTimerUpdate)
        .listen((payload) {
      if (payload.isEmpty) return;

      final int time = json.decode(payload)['timer'];

      setState(() {
        remainingTime = time;
      });
    });

    // DONE+
    roomNewMessage = EventRouterService()
        .subscribe(ServerEvent.roomNewMessage)
        .listen((payload) {
      if (payload.isEmpty) return;

      var data = json.decode(payload);

      setState(() {
        gameLobbyChatMessages.add(
          ChatMessage(
            isSystemMessage: false, 
            nickname: data['nickname'], 
            avatarUrl: data['avatarUrl'], 
            text: data['content']
          )
        );
      });
    });
  
    // DONE
    gameInitialState = EventRouterService()
        .subscribe(ServerEvent.gameInitialStateData)
        .listen((payload) {
      if (payload.isEmpty) return;

      var data = json.decode(payload);

      String role = data['role'] ?? '';
      String phase = data['phase'] ?? '';
      int civilianCount = data['civilianCount'] as int;
      int mafiaCount = data['mafiaCount'] as int;

      List<dynamic> playerRolesJson = data['playerRoles'] ?? [];
      List<PlayerRole> playerRoles = playerRolesJson.map((json) => PlayerRole.fromJson(json)).toList();

      PopupManager().close('inviteFriendPopup');

      startGame(widget.game.title, role, civilianCount, mafiaCount, playerRoles, phase);
    });
  
  }

  
  

  void startGame(String title, String role, int civilianCount, int mafiaCount, List<PlayerRole> playerRoles, String phase) {
    //widget.game.players.removeWhere((e) => e.nickname == authorizedUser.nickname);
    Navigator.pushReplacement(
      context,
      // NOTE:  MATERIAL PAGE ROUTE ---- ANDROID: HER YERDE shupheli
      MaterialPageRoute(builder: (context) => 
        GameScreen(
          phase: phase,
          title: title,
          role: role,
          civilianCount: civilianCount,
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
    roomStateData.cancel();
    roomPlayerJoined.cancel();
    roomPlayerLeft.cancel();
    roomTimerUpdate.cancel();
    roomNewMessage.cancel();
    gameInitialState.cancel();
    super.dispose();
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    TcpClientService().sendMessage(ClientCommand.sendRoomMessage.value, json.encode({'message': text.trim()}));

    // setState(() {
    //   gameLobbyChatMessages.add(ChatMessage(
    //     isSystemMessage: false,
    //     nickname: authorizedUser.nickname,
    //     avatarUrl: authorizedUser.avatarUrl,
    //     text: text,
    //   ));
    // });
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 35.sp;
    final double ornamentMargin = 10.sp;
    const String ornament = "assets/images/game-ornament-night.png";

    return PopScope(
      canPop: false,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/background-waiting-lobby.png"), fit: BoxFit.cover),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
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
                child: Text('${AppLocalizations.of(context)!.playersInRoom} [${gameLobbyPlayers.length}/${widget.game.maxPlayers}]'),
              ),
            ),
          ),
         */
      
          body: SingleChildScrollView(
            child: Stack(
              children: [
                
            
                Padding(
                  padding: EdgeInsets.only(top: 50.h, right: 7.w, left: 7.w),
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const SizedBox(),
                
                                Column(
                                  children: [
                
                                    //? TITLE
                                    Text(
                                      widget.game.title, 
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 32.sp,
                                        color: const Color(0xFFFFB000)
                                      ),
                                    ),
      
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
                                              "Min",
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
                                                "${gameLobbyPlayers.length}",
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
                                              "Max",
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
      
                                    // BUTTON:    INVITE FRIEND
                                    GestureDetector(
                                      onTap: () {
                                        PopupManager().show(
                                          context: context,
                                          id: 'inviteFriendPopup',
                                          builder: (_) { 
                                            List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
                                              "all_friends_list",
                                              (json) => Friendship.fromJson(json as Map<String, dynamic>),
                                            );
      
                                            currentFriends ??= [];
      
                                            return InviteFriendPopup(
                                              friendsList: currentFriends,
                                              inGamePlayers: widget.game.players,
                                            );
                                          }
                                        );
                                      },
                                      child: Container(
                                        width: AppLocalizations.of(context)!.inviteFriend.length <= 13 ? 120.w : 155.w,
                                        height: 35.h,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(71.sp),
                                          border: Border.all(color: const Color(0xFFFFFFFF), width: 1.5)
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.inviteFriend,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              color: const Color(0xFFFFFFFF),
                                              fontFamily: 'CenturyGothic'
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  
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
                                      height: 80.h, 
                                      isMini: false
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
                        height: 452.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2B2B),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //? PLAYERS
                                SizedBox(
                                  width: 230.w,
                                  height: 130.h,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    //   crossAxisCount: 2,
                                    //   childAspectRatio: 2.5,
                                    //   crossAxisSpacing: 5,
                                    //   mainAxisSpacing: 5,
                                    // ),
                                    itemCount: gameLobbyPlayers.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsetsGeometry.only(bottom: 10.h),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(width: 7.5.w),
                                                  
                                            //? AVATAR
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(50.r),
                                                border: Border.all(
                                                  width: 0.7.w,
                                                  color: const Color(0xFFFFFFFF)
                                                )
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                  gameLobbyPlayers[index].avatarUrl
                                                ),
                                                radius: 18.sp,
                                              )
                                            ),
                                            SizedBox(width: 4.w),
                                                  
                                            //? NICKNAME
                                            Container(
                                              child: Text(
                                                gameLobbyPlayers[index].nickname,
                                                softWrap: true,
                                                overflow: TextOverflow.fade,
                                                style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontFamily: 'CenturyGothic',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                
                                //? TIMER
                                Container(
                                  margin: EdgeInsets.only(top: 10.h, right: 10.w),
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
                                        AppLocalizations.of(context)!.starting,
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
                                          textAlign: TextAlign.center,
                                          remainingTime != -1 ? '$remainingTime\n${AppLocalizations.of(context)!.seconds}' : AppLocalizations.of(context)!.waiting.replaceAll(' ', '\n'),
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
                              margin: EdgeInsets.all(10.sp),
                              width: double.maxFinite,
                              height: 290.h,
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
                        margin: EdgeInsets.only(top: 715.h),
                        width: double.maxFinite,
                        height: 55.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2B2B2B),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            //? MICROFON
                            Container(
                              margin: EdgeInsets.only(left: 4.w, right: 4.w),
                              child: GestureDetector(
                                onTap: () {},
                                child: Image.asset(
                                  'assets/images/icon-disabled-micro.png',
                                  width: 35.h,
                                  height: 35.h,
                                ),
                              ),
                            ),
                            
                            //? INPUT
                            SizedBox(
                              width: 330.w,
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
                                
                      GestureDetector(
                        onTap: () {
                          TcpClientService().sendMessage(ClientCommand.leaveRoom.value, "");
                          widget.game.players.removeWhere((e) => e.id == authorizedUser.id);
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
                ),
              ],
            ),
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
                      remainingTime != -1 ? '${AppLocalizations.of(context)!.remainingTime}: $remainingTime ${AppLocalizations.of(context)!.seconds}' : "Waiting",
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
                  //     child: Text(AppLocalizations.of(context)!.join),
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
    
        if (message.isSystemMessage) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: Text(
                message.text,
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFFFFB000), fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }

        return ListTile(
          leading: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 0.7.sp,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(message.avatarUrl),
            ),
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
  final bool isSystemMessage;
  final String text;

  ChatMessage({required this.nickname, required this.avatarUrl, required this.text, required this.isSystemMessage});
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
                cursorColor: const Color(0xFFFFFFFF),
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '${AppLocalizations.of(context)!.enterMessage}...',
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


class InviteFriendPopup extends StatefulWidget {
  final List<Friendship> friendsList;
  final List<Player> inGamePlayers;

  const InviteFriendPopup({
    super.key, 
    required this.friendsList,
    required this.inGamePlayers
  });

  @override
  State<InviteFriendPopup> createState() => _InviteFriendPopupState();
}

class _InviteFriendPopupState extends State<InviteFriendPopup> {

  List<Friendship> possibleFriendsForInvitation = [];
  List<int> sendedInvitationList = [];

  StreamSubscription? _eventSubscriptionFriendOnline;
  StreamSubscription? _eventSubscriptionFriendOffline;
  StreamSubscription? _eventSubscriptionFriendJoinedRoom;
  StreamSubscription? _eventSubscriptionFriendLeftRoom;

  @override
  void initState() {
    super.initState();

    for (var friend in widget.friendsList) {
      if (friend.isOnline) {
        possibleFriendsForInvitation.add(friend);
      }
    }

    for (var player in widget.inGamePlayers) {
      if (possibleFriendsForInvitation.any((friend) => friend.id == player.id)) {
        possibleFriendsForInvitation.removeWhere((friend) => friend.id == player.id);
      }
    }

    _eventSubscriptionFriendOnline = EventBus().on<FriendOnlineEvent>().listen((event) {
      setState(() {
        possibleFriendsForInvitation.add(widget.friendsList.firstWhere((friend) => friend.id == event.friendId));
      });
    });

    _eventSubscriptionFriendOffline = EventBus().on<FriendOfflineEvent>().listen((event) {
      setState(() {
        if (possibleFriendsForInvitation.any((friend) => friend.id == event.friendId)) {
          possibleFriendsForInvitation.removeWhere((friend) => friend.id == event.friendId);
        }
      });
    });

    _eventSubscriptionFriendJoinedRoom = EventBus().on<FriendJoinedRoomEvent>().listen((event) {
      setState(() {
        possibleFriendsForInvitation.firstWhere((friend) => friend.id == event.friendId).gameTitle = event.gameTitle;
      });
    });

    _eventSubscriptionFriendLeftRoom = EventBus().on<FriendLeftRoomEvent>().listen((event) {
      setState(() {
        possibleFriendsForInvitation.firstWhere((friend) => friend.id == event.friendId).gameTitle = "";
      });
    });
  }

  @override
  void dispose() {
    _eventSubscriptionFriendOnline?.cancel();
    _eventSubscriptionFriendOffline?.cancel();
    _eventSubscriptionFriendJoinedRoom?.cancel();
    _eventSubscriptionFriendLeftRoom?.cancel();

    super.dispose();
  }

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
                      "Friends",
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
                        PopupManager().close('inviteFriendPopup');
                      },
                      child: Image.asset(
                        "assets/images/close-white-icon.png",
                        scale: 2.5,
                      ),
                    ),
                  )
                ],
              ),

              (possibleFriendsForInvitation.isEmpty)
              ? Container(
                margin: EdgeInsets.only(top: 90.h),
                child: Text(
                  AppLocalizations.of(context)!.noFriendsFound,
                  softWrap: true,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontFamily: 'CenturyGothic',
                    color: const Color(0xFFFFFFFF)
                  ),
                ),
              )
              : Container(
                margin: EdgeInsets.only(top: 10.h),
                height: 250.h,
                child: ListView.builder(
                  padding: EdgeInsets.only(left: 20.w, right: 20.w),
                  shrinkWrap: true,
                  itemCount: possibleFriendsForInvitation.length,
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
                                  //? AVATAR
                                  CircleAvatar(
                                    radius: 20.r,
                                    backgroundImage: NetworkImage(possibleFriendsForInvitation[index].avatarUrl),
                                  ),

                                  SizedBox(width: 10.w),

                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TEXT:    NICKNAME
                                      Text(
                                        possibleFriendsForInvitation[index].nickname, 
                                        style: TextStyle(
                                          height: 0.h,
                                          fontSize: 16.sp, 
                                          fontFamily: 'CenturyGothic',
                                          color: const Color(0xFFFFFFFF)
                                        )
                                      ),

                                      // TEXT:    IS IN GAME OR LOBBY
                                      Row(
                                        children: [
                                          if (possibleFriendsForInvitation[index].gameTitle.isNotEmpty)
                                            Text(
                                              "${AppLocalizations.of(context)!.inGame} ",
                                              style: TextStyle(
                                                height: 0.h,
                                                fontSize: 14.sp,
                                                fontFamily: 'CenturyGothic',
                                                color: const Color(0xFFFFFFFF)
                                              )
                                            ),
                                          
                                          Text(
                                            possibleFriendsForInvitation[index].gameTitle.isNotEmpty ? possibleFriendsForInvitation[index].gameTitle : AppLocalizations.of(context)!.lobby,
                                            style: TextStyle(
                                              height: 0.h,
                                              fontSize: 14.sp,
                                              fontFamily: 'CenturyGothic',
                                              fontStyle: FontStyle.italic,
                                              color: const Color(0xFFFFB000)
                                            )
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                                          
                              // BUTTON:    Invite or Invited
                              (sendedInvitationList.any((id) => id == possibleFriendsForInvitation[index].id))
                              ? Text(
                                  "Sent",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontFamily: 'CenturyGothic',
                                    color: const Color(0xFFFFB000),
                                  )
                                )
                              : possibleFriendsForInvitation[index].gameTitle.isNotEmpty
                              ? const SizedBox()
                              : GestureDetector(
                                onTap: () {
                                  //if (!widget.friendsList[index].isOnline) return;
                                  // TcpClientService().sendMessage(ClientCommand.sendRoomMessage.value, jsonEncode({
                                  //   'type': 'friendInvitation',
                                  //   'toNickname': value[index].nickname
                                  // }));
                                  // Navigator.of(context).pop();
                                  if (possibleFriendsForInvitation[index].gameTitle.isNotEmpty) return;
                                  GetIt.I<ApiService>().sendInviteToRoom(possibleFriendsForInvitation[index].id);
                                  sendedInvitationList.add(possibleFriendsForInvitation[index].id);
                                  setState(() {});
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 37.h,
                                  width: 105.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(34.sp),
                                    border: Border.all(
                                      color: possibleFriendsForInvitation[index].isOnline ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF).withOpacity(0.6), 
                                      width: 1
                                    )
                                  ),
                                  child: Text(
                                    "Invite",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: 'CenturyGothic',
                                      color:possibleFriendsForInvitation[index].isOnline ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF).withOpacity(0.6),
                                    )
                                  ),
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
      )
    );
  }
}

class AcceptRoomInvitePopup extends StatefulWidget {
  final String gameTitle;
  final String friendNickname;

  const AcceptRoomInvitePopup({
    super.key,
    required this.gameTitle,
    required this.friendNickname
  });

  @override
  State<AcceptRoomInvitePopup> createState() => _AcceptRoomInvitePopupState();
}

class _AcceptRoomInvitePopupState extends State<AcceptRoomInvitePopup> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 21.w),
        width: double.maxFinite,
        height: 200.h,
        child: Material(
          borderRadius: BorderRadius.circular(12.sp),
          color: const Color(0xFF111111),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //? TITLE
              Text(
                "Invititation To Game",
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 24.sp,
                  color: const Color(0xFFFFB000),
                  fontFamily: 'CenturyGothic'
                ),
              ),

              //? Invitation
              ((widget.friendNickname.length + widget.gameTitle.length) < 18)
              ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.friendNickname,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFB000),
                      fontFamily: 'CenturyGothic'
                    ),
                  ),

                  Text(
                    " invited you to the game ",
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFFFFF),
                      fontFamily: 'CenturyGothic'
                    ),
                  ),

                  Text(
                    widget.gameTitle,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFB000),
                      fontFamily: 'CenturyGothic'
                    ),
                  ),
                ],
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.friendNickname,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFB000),
                      fontFamily: 'CenturyGothic'
                    ),
                  ),

                  Text(
                    " invited you to the game ",
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFFFFF),
                      fontFamily: 'CenturyGothic'
                    ),
                  ),

                  Text(
                    widget.gameTitle,
                    softWrap: true,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFB000),
                      fontFamily: 'CenturyGothic'
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // BUTTON:    DECLINE
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      height: 45.h,
                      width: 100.h,
                      margin: EdgeInsets.all(5.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.sp),
                        color: const Color(0xFFFFFFFF)
                      ),
                      child: Center(
                        child: Text(
                          "Decline",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: const Color(0xFF000000),
                            fontFamily: 'CenturyGothic'
                          ),
                        ),
                      )
                    ),
                  ),

                  // BUTTON:    ACCEPT
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      height: 45.h,
                      width: 100.h,
                      margin: EdgeInsets.all(5.sp),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.sp),
                        color: const Color(0xFFFFB000)
                      ),
                      child: Center(
                        child: Text(
                          "Accept",
                          style: TextStyle(
                            fontSize: 18.sp,
                            color: const Color(0xFFFFFFFF),
                            fontFamily: 'CenturyGothic'
                          ),
                        ),
                      )
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}