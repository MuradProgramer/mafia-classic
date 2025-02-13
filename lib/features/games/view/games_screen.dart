import 'dart:convert';
import 'dart:developer';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/api_service.dart';

List<Game> games = [];

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

  @override
  void initState() {
    super.initState();
    authorizedUser = widget.user;
    GetIt.I<ApiService>().connectHub();
    //_loadGames();
  }

  @override
  void dispose() {
    // Dispose of the hub connection when the screen is closed
    GetIt.I<ApiService>().disconnectHub();
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
        body: 
        StreamBuilder<List<Game>>(
          stream: GetIt.I<ApiService>().gamesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No games available.'));
            } else {
              final gamesSnap = snapshot.data!;
              return ListView.builder(
                itemCount: gamesSnap.length, 
                itemBuilder: (context, index) {
                  return GameCard(game: gamesSnap[index]);
                },
              );
            }
          },
        ),
        
        // ListView.builder(
        //   itemCount: games.length, 
        //   itemBuilder: (context, index) {
        //     return GameCard(game: games[index]);
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
      title: json['Title'],
      //currentPlayers: json['currentPlayers'],
      //currentPlayers: json['currentPlayers'],
      minPlayers: json['MinCapacity'],    
      maxPlayers: json['MaxCapacity'],    
      hasPassword: json['HasPassword'], 
      status: json['Status'],
      players: json['Players'].isEmpty ? <Player>[] : (json['Players'] as List)
          .map((playerJson) => Player.fromJson(playerJson))
          .toList(),
      extraRoles: json['ExtraRoles'].isEmpty ? <String>[] : json['ExtraRoles'].cast<String>(),    
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

class GameCard extends StatelessWidget {
  final Game game;

  const GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Card(
        //color: Theme.of(context).cardColor,
        color: Colors.transparent,
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  //////////////////////////////////////////////////////////
                  /////Text('${S.of(context).players}: ${game.currentPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${S.of(context).players}: ${game.players.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${S.of(context).min}: ${game.minPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${S.of(context).max}: ${game.maxPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    game.status == 'Game Started' ? S.of(context).gameStarted : S.of(context).gatheringPlayers,
                    style: TextStyle(
                      fontSize: 12,
                      color: game.status ==  'Game Started'
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
                      SizedBox(
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
                      SizedBox(
                        width: 90,
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),

                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => 
                                  GameLobbyScreen(
                                    game: game,
                                    //roomName:  game.title, 
                                    //currentPlayers: game.currentPlayers, 
                                    // currentPlayers: 10, 
                                    // maxPlayers: 15, 
                                    // activeRoles: const ['Mafia', 'Doctor', 'Sheriff'] //game.characters
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
      nickname: json['Nickname'],
      avatarUrl: json['AvatarUrl'],
      isAlive: json['IsAlive'] as bool
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
      'name': title,
      'minPlayers': minPlayers,
      'maxPlayers': maxPlayers,
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
                    onPressed: () {
                      mainRoles.forEach((mainRole, state) {
                        print(mainRole);
                        print(state);
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
                      GetIt.I<ApiService>().createGame(jsonEncode(finalGame.toJson()));
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
  final List<ChatMessage> messages = [];
  late Timer _timer;
  int remainingTime = 60;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
          // Logic start after time ends
          startGame();
        }
      });
    });
  }

  void startGame() {
    log('Игра началась!');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void sendMessage(String text) {
    if (text.isNotEmpty) {
      setState(() {
        messages.add(ChatMessage(
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
              child: Text('${S.of(context).playersInRoom} [${widget.game.players.length}/${widget.game.maxPlayers}]'),
            ),
          ),
        ),
        body: Column(
          children: [
            // Тimer: before the game starts
      
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    '${S.of(context).remainingTime}: $remainingTime ${S.of(context).seconds}',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 50,
                  child: ElevatedButton(    
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen(title: 'game name'))
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
                child: PlayerTableWidget(playersInRoom: widget.game.players),
              ),
            ),
      
            // DEF:     Chat
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: ChatWidget(messages: messages),
              ),
            ),
      
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

  final List<Player> playersInRoom;

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


///////////// GAME /////////

class GameScreen extends StatefulWidget {
  final String title;

  const GameScreen({super.key, required this.title});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle())
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: deviceHeight * 0.005),
        color: Colors.white,
        child: Column(
          children: [

            Container( //   TO ONE WIDGET
              width: deviceWidth,
              height: deviceHeight * 0.017,
              margin: const EdgeInsets.all(2.0),
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black, 
              //     width: 1.0, 
              //   ),
              //   borderRadius: BorderRadius.circular(4.0),
              // ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: deviceHeight * 0.03,
                    width: deviceWidth * 0.663,
                    child: const Center(
                      child: Text(
                        "Game Started",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                        )
                      ),
                    )
                  ),
                  Container(
                    height: deviceHeight * 0.03,
                    width: deviceWidth * 0.3,
                    child: const Center(
                      child: Text(
                        "Players",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black
                        )
                      ), 
                    )
                  ),
                ],
              ),
            ),

            Container( // SECOND
              height: deviceHeight * 0.7,
              width: deviceWidth,
              margin: const EdgeInsets.all(4.0),
              // decoration: BoxDecoration(
              //   border: Border.all(
              //     color: Colors.black,
              //     width: 1.0,
              //   ),
              //   borderRadius: BorderRadius.circular(4.0),
              // ),
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: deviceWidth * 0.663,
                    height: deviceHeight * 0.7,
                    // decoration: BoxDecoration(
                    //   border: Border.all(
                    //     color: Colors.black,
                    //     width: 1.0,
                    //   ),
                    //   borderRadius: BorderRadius.circular(4.0),
                    // ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Container(
                          width: deviceWidth * 0.663,
                          height: deviceHeight * 0.2,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: const Text(
                            "Box",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        Container(
                          width: deviceWidth * 0.663,
                          height: deviceHeight * 0.49,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: const Text(
                            "Box",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    )
                  ),

                  Container(
                    width: deviceWidth * 0.3,
                    height: deviceHeight * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      "Box",
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              )
            ),

            Container(
              width: deviceWidth,
              height: deviceHeight * 0.055,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: const Text(
                "Box",
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      )
    
    );
  }
}


// Container(
//                 width: deviceWidth,
//                 height: deviceHeight * 0.7,
//                 margin: const EdgeInsets.all(4.0),
//                 decoration: BoxDecoration(
//                   border: Border.all(
//                     color: Colors.black,
//                     width: 1.0,
//                   ),
//                   borderRadius: BorderRadius.circular(4.0),
//                 ),
//                 child: const Text(
//                   "Box",
//                   textAlign: TextAlign.center,
//                 ),
//               ),