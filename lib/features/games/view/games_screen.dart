import 'dart:developer';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/services/api_service.dart';

List<Game> games = [];

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late ApiService apiService;

  @override
  void initState() {
    super.initState();
    GetIt.I<ApiService>().connectHub();
    //_loadGames();
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
                  return GameCard(game: games[index]);
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
  final String name;
  //final int currentPlayers; // massive size
  final int minPlayers;
  final int maxPlayers;
  final String status;
  final bool hasPassword;
  //final List<String> characters;
  final List<Player> players;

  Game({
    required this.name,
    //required this.currentPlayers,
    required this.minPlayers,
    required this.maxPlayers,
    required this.status,
    //required this.characters,
    required this.hasPassword,
    required this.players,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final playersFrom = json['Players'].isEmpty ? null : json['Players'].map((item) {
      return Player.fromJson(item as Map<String, dynamic>);
    }).toList();

    return Game(
      name: json['Title'],
      //currentPlayers: json['currentPlayers'],
      //currentPlayers: json['currentPlayers'],
      minPlayers: json['MinCapacity'],    
      maxPlayers: json['MaxCapacity'],    
      hasPassword: json['HasPassword'], 
      status: json['Status'],    
      players: playersFrom
      //characters: json['characters'] as List<String>,    
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
                    game.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  //////////////////////////////////////////////////////////
                  //Text('${S.of(context).players}: ${game.currentPlayers}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                      SizedBox(
                        width: 90,
                        child: Container(
                          margin: const EdgeInsets.only(left: 15),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GameLobbyScreen(
                                  roomName:  game.name, 
                                  //currentPlayers: game.currentPlayers, 
                                  currentPlayers: 10, 
                                  maxPlayers: 15, 
                                  activeRoles: const ['Mafia', 'Doctor', 'Sheriff'] //game.characters
                                )),
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
  final String status;

  Player({
    required this.nickname, 
    required this.avatarUrl, 
    required this.status
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      nickname: json['Nickname'],
      avatarUrl: json['AvatarUrl'],
      status: json['IsAlive']
    );
  }
}

List<Player> players = [
  Player(
    nickname: 'Player1', 
    avatarUrl: 'https://example.com/avatar1.png', 
    status: 'Alive'
  ),
  Player(
    nickname: 'Player2', 
    avatarUrl: 'https://example.com/avatar2.png', 
    status: 'Dead'
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
                    players[index].status == 'Alive' ? S.of(context).alive : S.of(context).dead,
                    style: TextStyle(
                      fontSize: 12,
                      color: players[index].status == 'Alive'
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

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

//// LOGIC ////
class _CreateGameScreenState extends State<CreateGameScreen> {
  String roomName = '';
  double minPlayers = 5;
  double maxPlayers = 7;
  
  String password = '';
  
  late Map<String, bool> roles;

  @override
  void initState() {
    super.initState();
    // Initialize an empty map or placeholder here
    roles = {};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize roles using S.of(context) here
    roles = {
      S.of(context).doctor: false,
      S.of(context).mistress: false,
      S.of(context).journalist: false,
      S.of(context).bodyguard: false,
      S.of(context).spy: false,
      S.of(context).terrorist: false,
      S.of(context).barman: false,
      S.of(context).informant: false,
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
                  values: RangeValues(minPlayers, maxPlayers),
                  min: 5,
                  max: 20,
                  divisions: 15,
                  onChanged: (RangeValues values) {
                    setState(() {
                      minPlayers = values.start;
                      maxPlayers = values.end;
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
                  children: roles.keys.map((role) {
                    return ListTile(
                      leading: const Icon(Icons.person, color: Colors.white), // Замените на иконку роли
                      title: Text(role, style: const TextStyle(color: Colors.white)),
                      trailing: Switch(
                        value: roles[role]!,
                        onChanged: (value) {
                          setState(() {
                            final a = roles[role];
                            //print('$a');
                            print('Before: $roles');
                            roles[role] = value;
                            //print('$role updated to $value');
                            print('After: $roles');
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
      S.of(context).doctor: false,
      S.of(context).sheriff: false,
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
  final String roomName;
  final int currentPlayers;
  final int maxPlayers;
  final List<String> activeRoles;

  const GameLobbyScreen({
    super.key, 
    required this.roomName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.activeRoles,
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
          nickname: 'Nickname',
          avatarUrl: 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg',
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
          title: Text(widget.roomName),
          actions: [
            Row(
              children: widget.activeRoles.map((role) => const Icon(Icons.person)).toList(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(30.0),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('${S.of(context).playersInRoom} [${widget.currentPlayers}/${widget.maxPlayers}]'),
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
                      MaterialPageRoute(builder: (context) => const GameScreen(title: 'game name')),
                    );
                    },
                    child: Text(S.of(context).join),
                  ),
                ),
              ],
            ),
      
            // Player list
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: const PlayerTableWidget(),
              ),
            ),
      
            // Chat
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                ),
                child: ChatWidget(messages: messages),
              ),
            ),
      
            // Message enter
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
  const PlayerTableWidget({super.key});

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
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        return ListTile(
          leading: const CircleAvatar(
            //////////////////////////////////////////////////////////
            // backgroundImage: NetworkImage(player.avatarUrl),
            backgroundImage: NetworkImage('https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg'),
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