import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/game/game.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/models/player.dart';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/itransport.dart';

int stateToJoin = 1;

List<Game> games = [
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
    hasPassword: false,
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
];


//late User authorizedUser;
User authorizedUser = User(email: "asdasd", nickname: "musayev", avatarUrl: "https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg", accessToken: "accessToken", refreshToken: "refreshToken", expirationDate: DateTime.now());

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

  List<Game>? allGames = [];

  @override
  void initState() {
    super.initState();
    authorizedUser = widget.user;

    // NOTE:    MAIN HUB CONNECTION AND SOCKETS

    var apiService = GetIt.I<ApiService>();
    
    //! BUILD
    apiService.mainHubConnection = HubConnectionBuilder().withUrl(
      'https://46.32.173.182/mainlobby',
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
      //print('33: $parameters');
      final List<Game>? gamesList = apiService.decodeGamesParameters(parameters);

      if (gamesList != null) {
        setState(() {
          allGames = gamesList;
        });
      }
    });

    // INCOMPLETE
    apiService.mainHubConnection.on('GameLobbyCreated', (List<Object?>? parameters) {
      final Game? game = apiService.decodeGameParameters(parameters);

      if (game != null) {
        setState(() {
          allGames?.add(game);
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
    for (var game in games) {
      for (var player in game.players) {
        if (player.nickname == authorizedUser.nickname) {
          stateToJoin = (player.isAlive) ? 2 : 3;
          temp = true;
          break;
        }
      }
      if (temp) break;
    }}

  @override
  void dispose() {
    // Dispose of the hub connection when the screen is closed
    GetIt.I<ApiService>().disconnectMainHub();
    super.dispose();
  }

  void _loadGames() async {
    final fetchedGames = await GetIt.I<ApiService>().getGames();
    setState(() {
      games = fetchedGames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-2.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
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
        
        body: ListView.builder(
          //! AllGames
          itemCount: (allGames == null || allGames!.isNotEmpty) ? allGames!.length : 0, 
          itemBuilder: (context, index) {
            if (allGames == null || allGames!.isNotEmpty)
            {
              return GameCard(game: allGames![index]);
            }
          },
        ),
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
    return Card(
        //color: Theme.of(context).cardColor,
        color: Colors.transparent,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      //////////////////////////////////////////////////////////
                      /////Text('${S.of(context).players}: ${game.currentPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('${S.of(context).players}: ${widget.game.players.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('${S.of(context).min}: ${widget.game.minPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('${S.of(context).max}: ${widget.game.maxPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.game.status == 'Started' ? S.of(context).gameStarted : S.of(context).gatheringPlayers,
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.game.status ==  'Started'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        //////////////////////////////////////////////////////////
                        children: ['Mafia', 'Doctor', 'Sheriff'] //game.characters
                            .map((character) => const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.0),
                                  child: Icon(
                                    Icons.person, 
                                    size: 24,
                                  ),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
              
                          // BUTTON:      Players Popup
                          if ((stateToJoin == 2 && text == 'You Are Playing Here') || (stateToJoin != 2)) SizedBox(
                            width: 90,
                            child: ElevatedButton(     
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const PlayersPopup(),
                                );
                              },
                              child: Text(S.of(context).players),
                            ),
                          ),
              
                          // BUTTON:      Game Lobby
                          if ((stateToJoin == 2 && text == 'You Are Playing Here') || (stateToJoin != 2)) SizedBox(
                            width: 90,
                            child: Container(
                              margin: const EdgeInsets.only(left: 15),
              
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => 
                                      (text == 'You Are Playing Here' || text == 'You Died Here')
                                      //!!!!!!!!!!!!!!!! 
                                      ? GameScreen(title: widget.game.title, playersRole: [], role: '', mafiaCount: 0, citizenCount: 0, allPlayers: widget.game.players, cameBackFromAfk: true)
                                      : GameLobbyScreen(
                                        game: widget.game,
                                      )
                                    ),
                                  );
                                },
                                child: Text(S.of(context).join),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                    ],
                  ),
                ],
              ),
              Text(text, style: const TextStyle(fontSize: 20),)
            ],
          ),
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
    nickname: 'Player5', 
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

class PlayersPopup extends StatelessWidget {
  const PlayersPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).players),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: players.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        //////////////////////////////////////////
                        //child: Text(players[index].avatarUrl[0]),
                        child: Image.network('https://example.com/avatar1.png'),
                      ),
                      const SizedBox(width: 8),
                      Text(players[index].nickname, style: const TextStyle(fontSize: 12, color: Colors.black)),
                    ],
                  ),
                  Text(
                    players[index].isAlive == true ? S.of(context).alive : S.of(context).dead,
                    style: TextStyle(
                      fontSize: 12,
                      color: players[index].isAlive == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  )
                ],
              )
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).close),
        ),
      ],
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
  
  String password = '';
  
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
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).createGame),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
          ),
      
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
  bool friendsInRoom = false;
  bool roomsWithSpace = false;
  bool roomsWithoutPassword = false;
  bool roomsWithPassword = false;
  bool noAdditionalRoles = false;

  @override
  Widget build(BuildContext context) {
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
        roomsWithoutPassword = false;
        roomsWithPassword = false;
        noAdditionalRoles = false;

        additionalRoles.updateAll((key, value) => false);
      });
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).filter),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // reset
                ElevatedButton(
                  onPressed: resetFilters,
                  child: Text(S.of(context).reset, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 20),
                // friends in games
                ListTile(
                  leading: const Icon(Icons.people, color: Colors.green),
                  title: Text(
                    S.of(context).friendInTheRoom, 
                    style: const TextStyle(color: Colors.white, fontSize: 15)
                  ),
                  trailing: Switch(
                    value: friendsInRoom,
                    onChanged: (value) {
                      setState(() {
                        friendsInRoom = value;
                      });
                    },
                  ),
                ),
                // only where places
                ListTile(
                  title: Text(
                    S.of(context).onlyRoomsWithAvailableSpace, 
                    style: const TextStyle(color: Colors.white, fontSize: 15)
                  ),
                  trailing: Switch(
                    value: roomsWithSpace,
                    onChanged: (value) {
                      setState(() {
                        roomsWithSpace = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // without password
                ListTile(
                  title: Text(
                    S.of(context).roomsWithoutAPassword, 
                    style: const TextStyle(color: Colors.white, fontSize: 15)
                  ),
                  trailing: Switch(
                    value: roomsWithoutPassword,
                    onChanged: (value) {
                      setState(() {
                        roomsWithoutPassword = value;
                      });
                    },
                  ),
                ),
                // with password
                ListTile(
                  title: Text(
                    S.of(context).roomsWithAPassword, 
                    style: const TextStyle(color: Colors.white, fontSize: 15)
                  ),
                  trailing: Switch(
                    value: roomsWithPassword,
                    onChanged: (value) {
                      setState(() {
                        roomsWithPassword = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // roles
                Text(
                  S.of(context).additionalRoles,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: additionalRoles.keys.map((role) {
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.white),
                      title: Text(role, style: const TextStyle(color: Colors.white, fontSize: 15)),
                      trailing: Switch(
                        value: additionalRoles[role]!,
                        onChanged: (value) {
                          setState(() {
                            additionalRoles[role] = value;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                // without additional roles
                ListTile(
                  title: Text(
                    S.of(context).roomsWithourAdditionalRoles, 
                    style: const TextStyle(color: Colors.white, fontSize: 15)
                  ),
                  trailing: Switch(
                    value: noAdditionalRoles,
                    onChanged: (value) {
                      setState(() {
                        noAdditionalRoles = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // LOGIC
                    },
                    child: Text(
                      S.of(context).apply,
                      style: const TextStyle(color: Colors.white)
                    ),
                  ),
                ),
              ],
            ),
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

  const GameLobbyScreen({
    super.key, 
    // required this.roomName,
    // required this.currentPlayers,
    // required this.maxPlayers,
    // required this.activeRoles,
    required this.game
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

    var connectionUri = (widget.game.hasPassword)
      ? "https://46.32.173.182/gamelobby?title=${widget.game.title}&password=${password}" // passwordu tapammiram
      : "https://46.32.173.182/gamelobby?title=${widget.game.title}";

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
          print("Connected to SignalR!");
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
      GetIt.I<ApiService>().disconnectGameHub();
    }
    super.dispose();
  }

  void sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        gameLobbyChatMessages.add(ChatMessage(
          nickname: authorizedUser.nickname,
          avatarUrl: authorizedUser.avatarUrl,
          text: text,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
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
        body: Column(
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
                SizedBox(
                  width: 60,
                  height: 50,
                  child: ElevatedButton(    
                    onPressed: () {
                      List<PlayerRole> playerRoles = [
                        PlayerRole(
                          nickname: 'Player1',
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
                          role: 'Mafia'
                        ),
                        PlayerRole(
                          nickname: 'Player7',
                          role: 'Barman'
                        ),
                      ];

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen(title: 'game name', playersRole: playerRoles, mafiaCount: 5, citizenCount: 7, role: 'Mafia', allPlayers: widget.game.players, cameBackFromAfk: false))
                      );
                    },
                    child: Text(S.of(context).join),
                  ),
                ),
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
      controller: _scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(message.avatarUrl),
          ),
          title: Text(message.nickname, style: TextStyle(color: Colors.lightBlue[300])),
          subtitle: Text(message.text, style: const TextStyle(color: Colors.white)),
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
          child: TextField(
            style: const TextStyle(color: Colors.white),
            controller: _controller,
            decoration: InputDecoration(
              hintText: '${S.of(context).enterMessage}...',
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
