import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/view/view.dart';
import 'package:mafia_classic/generated/intl/messages_en.dart';
import 'package:mafia_classic/main.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/dio/dio_service.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';
 
import 'token_aware_service.dart';

class ApiService extends TokenAwareService {
  String _accessToken;
  DateTime _expiration;
  String _refreshToken;

  FutureOr<String>? get accessToken => _accessToken;

  late List<Game>? allGames;

  ///////// SIGNAL R ///////////
  late HubConnection mainHubConnection;
  bool mainHubIsConnected = false;

  late HubConnection gameHubConnection;
  bool gameHubIsConnected = false;

  // StreamController to handle the stream of games
  final StreamController<List<Game>> _gamesController = StreamController<List<Game>>.broadcast();
  final StreamController<List<GameLobbyChatPlayer>> _gameLobbyChatController = StreamController<List<GameLobbyChatPlayer>>.broadcast();
  
  // Getter for the games stream
  Stream<List<Game>> get gamesStream => _gamesController.stream;
  Stream<List<GameLobbyChatPlayer>> get gameLobbyChatStream => _gameLobbyChatController.stream;

  ApiService(this._accessToken, this._expiration, this._refreshToken) {
    allGames = <Game>[];

    mainHubConnection = HubConnectionBuilder().withUrl(
      'https://192.168.1.2:7141/mainlobby',
      options: HttpConnectionOptions(
        accessTokenFactory: () => Future.value("$_accessToken"),
        //skipNegotiation: true,
        //transport: HttpTransportType.WebSockets,
      ),
    )
    .build();
  }

  Future<void> connectMainHub() async {
    if (mainHubIsConnected) {
      print("HubConnection already established.");
      return; // Avoid reconnecting if already connected
    }

    // DONE
    mainHubConnection.on('GameLobbies', (List<Object?>? parameters) {
      //print('33: $parameters');
      final List<Game>? gamesList = decodeGamesParameters(parameters);

      allGames = gamesList;

      if (allGames != null) {
        _gamesController.add(allGames!); // Notify listeners
      }
    });

    // INCOMPLETE
    mainHubConnection.on('GameLobbyCreated', (List<Object?>? parameters) {
      final Game? game = decodeGameParameters(parameters);

      if (game != null) {
        allGames?.add(game);
        _gamesController.add(allGames!); // Notify listeners
      }
    });

    // INCOMPLETE
    mainHubConnection.on('GameLobbyClosed', (List<Object?>? parameters) {
      final String? title = parameters?.first as String;

      if (title != null && allGames != null) {
        if (allGames!.any((game) => game.title == title)) {
          allGames!.removeWhere((game) => game.title == title);
        }
        _gamesController.add(allGames!); // Notify listeners
      }
    });

    // INCOMPLETE
    mainHubConnection.on('PlayerJoined', (List<Object?>? parameters) {
      final PlayerJoinedGame? playerJoinedToGame = decodePlayerJoinedGameParameters(parameters);

      if (playerJoinedToGame != null && allGames != null) {
        if (!allGames!
          .firstWhere((game) => game.title == playerJoinedToGame.title)
          .players.any((player) => player.nickname == playerJoinedToGame.player.nickname)) {

          allGames!
          .firstWhere((game) => game.title == playerJoinedToGame.title)
          .players.add(playerJoinedToGame.player);
        }
        _gamesController.add(allGames!); // Notify listeners
      }
    });

    // INCOMPLETE
    mainHubConnection.on('PlayerLeft', (List<Object?>? parameters) {
      final PlayerLeftGame? playerLeftGame = decodePlayerLeftGameParameters(parameters);

      if (playerLeftGame != null && allGames != null) {
        if (allGames!
          .firstWhere((game) => game.title == playerLeftGame.title)
          .players.any((player) => player.nickname == playerLeftGame.nickname)) {

          allGames!
          .firstWhere((game) => game.title == playerLeftGame.title)
          .players.removeWhere((player) => player.nickname == playerLeftGame.nickname);
        }
        else {
          print('There is no player with this nickname');
        }
        _gamesController.add(allGames!); // Notify listeners
      }
    });

    // INCOMPLETE
    mainHubConnection.on('GameStarted', (List<Object?>? parameters) {
      final String? title = parameters?.first as String;

      if (title != null && allGames != null) {
        if (allGames!.any((game) => game.title == title)) {
          allGames!.firstWhere((game) => game.title == title).status = 'Game Started';
        }
        _gamesController.add(allGames!); // Notify listeners
      }
    });


    mainHubConnection.on('CloseConnection', (List<Object?>? parameters) async {
      await disconnectMainHub();
    });

    try {
      print("Starting HubConnection...");
      await mainHubConnection.start();
      mainHubIsConnected = true;
      print("HubConnection started.");
    } catch (e) {
      print("Failed to start HubConnection: $e");
    }
  }

  Future<void> connectGameHub() async {
    if (gameHubIsConnected) {
      print("Game HubConnection already established.");
      return; // Avoid reconnecting if already connected
    }

    // INCOMPLETE
    gameHubConnection.on('GameLobbyData', (List<Object?>? parameters) {
      // NOTE:    parameters as Map<String, dynamic> to variable
      final List<GameLobbyChatPlayer>? messages = decodeGameLobbyChatPlayersParameters(parameters);

      final String eventTime = (parameters as Map<String, dynamic>)['eventTime'];
      if (eventTime.isNotEmpty) {
        final DateTime parsedDate = DateTime.parse(eventTime);
      }
    });
    
    // INCOMPLETE
    gameHubConnection.on('GameStarted', (List<Object?>? parameters) {
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

      var data = parameters.first as Map<String, dynamic>;

      String role = data['role'] ?? '';
      int citizenCount = data['citizenCount'] ?? 0;
      int mafiaCount = data['mafiaCount'] ?? 0;

      List<dynamic> playerRolesJson = data['playerRoles'] ?? [];
      List<PlayerRole> playerRoles = playerRolesJson.map((json) => PlayerRole.fromJson(json)).toList();

    });

    // INCOMPLETE
    gameHubConnection.on('PlayerJoined', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = parameters.first as Map<String, dynamic>;
      var playerDto = data['player'] as Map<String, dynamic>;

      LobbyPlayer player = LobbyPlayer.fromJson(playerDto);

      String eventTime = data['eventTime'] ?? '';
      if (eventTime.isNotEmpty) {
        final DateTime parsedDate = DateTime.parse(eventTime);
      }

    });

    // INCOMPLETE
    gameHubConnection.on('PlayerLeft', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String nickname = parameters.first as String;
 
    });

    // INCOMPLETE
    gameHubConnection.on('StopEventTimer', (List<Object?>? parameters) {
      // NOTE:    STOP TIMER IF THE TIMER TICKING

    });

    // INCOMPLETE
    gameHubConnection.on('ReceiveMessage', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = parameters.first as Map<String, dynamic>;

      // NOTE:    CHANGE CLASS NAME
      GameLobbyChatPlayer message = GameLobbyChatPlayer.fromJson(data);

      final nickname = message.nickname;
      final content = message.content; 

    });

    // DONE
    gameHubConnection.on('CloseConnection', (List<Object?>? parameters) async {
      await disconnectGameHub();
    });

    try {
      print("Starting HubConnection...");
      await gameHubConnection.start();
      gameHubIsConnected = true;
      print("HubConnection started.");
    } catch (e) {
      print("Failed to start HubConnection: $e");
    }
  }

// NOTE:    MAIN LOBBY SOCKET PARSERS
  Game? decodeGameParameters(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty || parameters.first == null) {
      print("No data received.");
      return null;
    }

    try {
      final List<dynamic> jsonData = json.decode(parameters.first as String);

      return Game.fromJson(jsonData as Map<String, dynamic>);
    } catch (e) {
      print("Error decoding parameters: $e");
      return null;
    }
  }

  List<Game>? decodeGamesParameters(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty || parameters.first == null) {
      print("No data received.");
      return null;
    }

    try {
      final List<dynamic> jsonData = json.decode(parameters.first as String);

      final games = jsonData.map((gameJson) {
        return Game.fromJson(gameJson as Map<String, dynamic>);
      }).toList();

      return games;
    } catch (e) {
      print("Error decoding parameters: $e");
      return null;
    }
  }

  PlayerJoinedGame? decodePlayerJoinedGameParameters(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty || parameters.first == null) {
      print("No data received.");
      return null;
    }

    try {
      final dynamic jsonData = json.decode(parameters.first as String);

      return PlayerJoinedGame.fromJson(jsonData as Map<String, dynamic>);
    } catch (e) {
      print("Error decoding parameters: $e");
      return null;
    }
  }

  PlayerLeftGame? decodePlayerLeftGameParameters(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty || parameters.first == null) {
      print("No data received.");
      return null;
    }

    try {
      final dynamic jsonData = json.decode(parameters.first as String);

      return PlayerLeftGame.fromJson(jsonData as Map<String, dynamic>);
    } catch (e) {
      print("Error decoding parameters: $e");
      return null;
    }
  }


  // NOTE:    GAME LOBBY SOCKET PARSERS
  List<GameLobbyChatPlayer>? decodeGameLobbyChatPlayersParameters(List<Object?>? parameters) {
    if (parameters == null || parameters.isEmpty || parameters.first == null) {
      print("No data received.");
      return null;
    }

    try {
      final List<dynamic> jsonData = json.decode((parameters as Map<String, dynamic>)['messages'] as String) ?? [];

      final gameLobbyChatPlayers = jsonData.map((gameJson) {
        return GameLobbyChatPlayer.fromJson(gameJson as Map<String, dynamic>);
      }).toList();

      return gameLobbyChatPlayers;
    } catch (e) {
      print("Error decoding parameters: $e");
      return null;
    }
  }


  Future<void> disconnectMainHub() async {
    mainHubConnection.stop().then((_) {
      mainHubIsConnected = false;
      print('Hub connection stopped');
    }).catchError((error) {
      print('Error stopping hub connection: $error');
    });
  }

  Future<void> disconnectGameHub() async {
    gameHubConnection.stop().then((_) {
      gameHubIsConnected = false;
      print('Hub connection stopped');
    }).catchError((error) {
      print('Error stopping hub connection: $error');
    });
  }
  
  Future<List<Game>> getGames() async {
    //List<Game> gamesA;
    //await connectHub();
    // return getGamesList();
    return games;
  }

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
      players: players,
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

  void dispose() {
    _gamesController.close();
  }

  Future<bool> createGame(String game) async {
    bool status = false;

    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'Game': game});

      print(formDataObject);

      final response = await GetIt.I<DioService>().dio.post(
        'GameLobby/CreateLobby',
        data: formDataObject,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        status = true;
      } else if (response.statusCode == 409) {
        // 
      } else if (response.statusCode == 404) {
        // 
      }
    });
    
    return status;
  }

  @override
  Future<String> getAccessToken() async {
    return _accessToken;
  }

  @override
  bool isTokenExpired() {
    return DateTime.now().isAfter(_expiration);
  }

  @override
  Future<void> refreshToken() async {
    final response = await GetIt.I<DioService>().dio.post(
      'Account/UpdateSession',
      options: Options(
        headers: {
          'Authorization': 'Bearer $_refreshToken'
        }
      )
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.data);
      _accessToken = data['accessToken'];
      _expiration = DateTime.parse(data['expiration']);
      _refreshToken = data['refreshToken'];
    } else if(response.statusCode == 401) {
      // go to sign in page
    } else {
      throw Exception('Failed to refresh token');
    }
  }

  // ++++++
  Future<List<Friendship>?> getFriends() async {
    List<Friendship>? friendList = [];
    await executeWithTokenCheck((accessToken) async {
      final response = await GetIt.I<DioService>().dio.get(
        'Friend/All',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken'
          }
        )
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data as List<dynamic>;
    
        friendList = jsonData.isEmpty ? null : jsonData.map((item) {
          return Friendship.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception('Failed to load friends');
      }
    });
    return friendList;
  }

  // ++++++
  Future<bool> deleteFriend(String nickname) async {
    bool status = false;
    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'nickname': nickname});

      final response = await GetIt.I<DioService>().dio.delete(
        'Friend/Delete',
        data: formDataObject,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        status = true;
      } else if (response.statusCode == 404) {
        throw Exception('No user found');
      } else {
        throw Exception('Failed to send POST request');
      }
    });
    return status;
  }

  // ++++++
  
  Future<List<FindFriend>?> findFriend(String pattern) async {
    List<FindFriend>? userList = [];
    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'pattern': pattern});

      final response = await GetIt.I<DioService>().dio.get(
        'Friend/Find',
        data: formDataObject,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data as List<dynamic>;
        
        userList = jsonData.isEmpty ? null : jsonData.map((item) {
          return FindFriend.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else if (response.statusCode == 404) {
        throw Exception('No user found');
      } else {
        throw Exception('Failed to send POST request');
      }
    });
    return userList;
  }

  // +++++++
  Future<bool> sendRequest(String nickname) async {
    bool status = false;
    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'nickname': nickname});

      final response = await GetIt.I<DioService>().dio.post(
        'Friend/RequestFriendship',
        data: formDataObject,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        status = true;
      } else if (response.statusCode == 409) {
        // request to alredy friend
      } else if (response.statusCode == 404) {
        // not find
      }
    });
    return status;
  }

  // ++++++
  Future<List<FriendRequest>?> getRequests() async {
    List<FriendRequest>? requestsList = [];
    await executeWithTokenCheck((accessToken) async {
      final response = await GetIt.I<DioService>().dio.get(
        'Friend/Addressee',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data as List<dynamic>;
        requestsList = jsonData.isEmpty ? null : jsonData.map((item) {
          return FriendRequest.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception('Failed to load requests');
      }
    });
    return requestsList;
  }

  // ++++++
  Future<bool> approveFriend(String nickname, bool approve) async {
    bool status = false;
    bool res = approve;
    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'nickname': nickname, 'approve': res});

      final response = await GetIt.I<DioService>().dio.post(
        'Friend/ApproveFriendship',
        data: formDataObject,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        status = true;
      } else if (response.statusCode == 409) {
        // request to alredy friend
      } 
    });
    return status;
  }


  // CHAAAAAAAAAAAAAAAAAAATTT

  // token, nickname         token nickname - chati   -   GET CHAT
  // text, date, from(nickname)

  Future<List<Message>?> getMessages(nickname) async {
    List<Message>? messages = [];
    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'nickname': nickname});

      final response = await GetIt.I<DioService>().dio.get(
        'Friend/Addressee',
        data: formDataObject,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = response.data as List<dynamic>;
        messages = jsonData.isEmpty ? null : jsonData.map((item) {
          return Message.fromJson(item as Map<String, dynamic>);
        }).toList();
      } else {
        throw Exception('Failed to load messages');
      }
    });
    return messages;
  }


  // sendMessage (token, nickname, date, )


  ///////// SIGNAL R ///////////
  
}

void setup(User user) {
  GetIt.I.registerSingleton<ApiService>(
    ApiService(
      user.accessToken,
      user.expirationDate,
      user.refreshToken,
    ),
  );
}