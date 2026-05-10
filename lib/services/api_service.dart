import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mafia_classic/features/auth/signin/view/sign_in_screen.dart';
import 'package:mafia_classic/features/profile/friends/models/models.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/features/widgets/widgets.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/dio/dio_service.dart';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';

import 'token_aware_service.dart';
import 'package:intl/intl.dart';

DateTime? parseDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateFormat("M/d/yyyy h:mm:ss a").parse(dateStr);
  } catch (_) {
    try {
      return DateFormat("M/d/yyyy").parse(dateStr);
    } catch (_) {
      return null;
    }
  }
}

class ApiService extends TokenAwareService {
  String _accessToken;
  DateTime _expiration;
  String _refreshToken;

  FutureOr<String>? get accessToken => _accessToken;

  /*
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

    //!!!!!!!!!!!
    // mainHubConnection = HubConnectionBuilder().withUrl(
    //   'https://31.171.65.145/mainlobby',
    //   options: HttpConnectionOptions(
    //     accessTokenFactory: () => Future.value(_accessToken),
    //     skipNegotiation: true,
    //     transport: HttpTransportType.WebSockets,
    //   ),
    // )
    // .build();
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


    // METHODS FOR 

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
      final Map<String, dynamic> jsonData = json.decode(parameters.first as String);

      return Game.fromJson(jsonData);
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
      final List<dynamic> jsonData = json.decode(parameters.first as String)['messages'] ?? [];

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
      log('Main Hub connection stopped');
    }).catchError((error) {
      log('Error stopping MAIN hub connection: $error');
    });
  }

  Future<void> disconnectGameHub() async {
    gameHubConnection.stop().then((_) {
      gameHubIsConnected = false;
      log('Game Hub connection stopped');
    }).catchError((error) {
      log('Error stopping hub connection: $error');
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

  Future<bool> createGame(CreateGame game) async {
    bool status = false;

    await executeWithTokenCheck((accessToken) async {

      final dataJson = jsonEncode(game);
      print(dataJson);

      final response = await GetIt.I<DioService>().dio.post(
        'GameLobby/CreateLobby',
        data: dataJson,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      if (response.statusCode == 201) {
        status = true;
      } else if (response.statusCode == 409) {
        // 
      } else if (response.statusCode == 404) {
        // 
      }
    });
    
    return status;
  }

  */

  //? constructor
  ApiService(this._accessToken, this._expiration, this._refreshToken);

  @override
  Future<String> getAccessToken() async {
    return _accessToken;
  }

  @override
  bool isTokenExpired() {
    return DateTime.now().toUtc().isAfter(_expiration);
  }

  @override
  Future<void> refreshToken() async {
    Response<dynamic>? response;
    try {
      response = await GetIt.I<DioService>().dio.post(
        'Account/RefreshToken',
        options: Options(
          headers: {
            'Authorization': 
            'Bearer $_refreshToken'
          }
        )
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;

        _accessToken = data['accessToken'];
        _expiration = DateTime.parse(data['expiration']).toUtc();
        _refreshToken = data['refreshToken'];

        log("🔥🔥🔥🔥🔥🔥 refreshToken 🔥🔥🔥🔥🔥🔥🔥🔥");
        log("ACCESS TOKEN: $_accessToken");
        log("EXPIRATION DATE: $_expiration");
        log("EXPIRATOPN DATE NOW: ${_expiration.toLocal()}");
        log("REFRESH TOKEN: $_refreshToken");
        log("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥");

        await SharedPrefsService.saveTokens(
          accessToken: _accessToken,
          refreshToken: _refreshToken,
          expiration: _expiration,
          nickname: SharedPrefsService.getUserNickname()!,
          avatarUrl: SharedPrefsService.getUserAvatarUrl()!,
          email: SharedPrefsService.getUserEmail()!,
          id: SharedPrefsService.getUserId()!,
        );
      } else if (response.statusCode == 401) {
        print('Failed to refresh token ERROR CODE 401');
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      log('💥 Refresh Token Error - $e - API Service 💥');
    }
  }

 @override
  Future<bool> refreshTokenBoolean() async {
    Response<dynamic>? response;
    try {
      response = await GetIt.I<DioService>().dio.post(
        'Account/RefreshToken',
        options: Options(
          headers: {
            'Authorization': 
            'Bearer $_refreshToken'
          }
        )
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;

        _accessToken = data['accessToken'];
        _expiration = DateTime.parse(data['expiration']).toUtc();
        _refreshToken = data['refreshToken'];
        log("🔥🔥🔥🔥🔥🔥 refreshTokenBoolean 🔥🔥🔥🔥🔥🔥🔥🔥");
        log("ACCESS TOKEN: $_accessToken");
        log("EXPIRATION DATE: $_expiration");
        log("EXPIRATOPN DATE NOW: ${_expiration.toLocal()}");
        log("REFRESH TOKEN: $_refreshToken");
        log("🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥🔥");

        await SharedPrefsService.saveTokens(
          accessToken: _accessToken,
          refreshToken: _refreshToken,
          expiration: _expiration,
          nickname: SharedPrefsService.getUserNickname()!,
          avatarUrl: SharedPrefsService.getUserAvatarUrl()!,
          email: SharedPrefsService.getUserEmail()!,
          id: SharedPrefsService.getUserId()!,
        );
        return true;
      } else if (response.statusCode == 401) {
        //print('9`823549`82638`623848`:     Failed to refresh token ERROR CODE 401');
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      //if (response?.statusCode == 401) {
      return false;
      //}
      //log('💥 Refresh Token WITH CONTEXT Error - $e - API Service\n\t\tSTATUS CODE: ${response?.statusCode} 💥');
    }
    return false;
  }

  // DONE
  Future<List<Friendship>?> getFriends() async {
    List<Friendship>? friendList = [];

    try {
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

          friendList = jsonData.isEmpty
            ? null
            : jsonData.map((item) {
                return Friendship.fromJson(item as Map<String, dynamic>);
              }).toList();
        } else {
          throw Exception('Failed to load friends');
        }
      });
    } catch (e) {
      log('💥 Get Friends Error - API Service 💥');
    }
    return friendList;
  }

  // DONE partially
  Future<Map<String, dynamic>?> sendNewMessageToFriend(int chatId, String content) async {
    Map<String, dynamic>? result;

    try {
      await executeWithTokenCheck((accessToken) async {
        final body = jsonEncode({'content': content});

        final response = await GetIt.I<DioService>().dio.post(
          'chat/$chatId/messages',
          data: body,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {
          Map<String, dynamic> jsonData = response.data;
          result = {
            //'messageId': jsonData['messageId'] as int,
            'status': jsonData['state'],
          };
        } else {
          throw Exception('Failed to load new message');
        }
      });
    } catch (e) {
      log('💥 Send New Message To Friend - API Service 💥');
    }
    return result;
  }

  // DONE partially
  Future<List<Message>?> getAllMessagesInFriendChat(int chatId) async {
    List<Message>? result;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.get(
          'chat/$chatId/messages',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = response.data['messages'];

          result = jsonList.map((jsonItem) => Message.fromJson(jsonItem)).toList();
        } else {
          throw Exception('Failed to load new message');
        }
      });
    } catch (e) {
      log('💥 Get All Messages in Friend Chat - API Service 💥');
    }
    return result;
  }

  // DONE partially
  Future<List<Message>?> readFriendMessages(int chatId) async {
    List<Message>? result;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.patch(
          'chat/$chatId/messages/read',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {

        } else {
          throw Exception('Failed to load new message');
        }
      });
    } catch (e) {
      log('💥 Read Friend Messages - API Service 💥');
    }
    return result;
  }

  // DONE partially
  Future<PlayerInfo> getPlayerInfo(int id) async {
    PlayerInfo playerInfo = PlayerInfo(
      chatId: -1,
      civilianRolePlayedGames: 0, 
      sheriffRolePlayedGames: 0, 
      doctorRolePlayedGames: 0, 
      beautyRolePlayedGames: 0, 
      bodyguardRolePlayedGames: 0, 
      spyRolePlayedGames: 0, 
      journalistRolePlayedGames: 0, 
      mafiaRolePlayedGames: 0, 
      informantRolePlayedGames: 0, 
      barmanRolePlayedGames: 0, 
      kamikazeRolePlayedGames: 0, 
      id: 0, 
      nickname: '', 
      avatarUrl: 'https://i.pinimg.com/736x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg', 
      isOnline: false, 
      lastSeen: DateTime.now(), 
      joinDate: DateTime.now(), 
      friendshipStatus: '', 
      inGameLobby: false, 
      overall: 0, 
      wins: 0, 
      loses: 0,
      mafiaWins: 0, 
      civilianWins: 0, 
      gameLobbyTitle: '', 
      gameLobbyStatus: '', 
      gameLobbyPlayerCount: 0, 
      unreadMessagesCount: 0
    );

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.get(
          'profile/$id',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;

          playerInfo = PlayerInfo.fromJson(data);
        } else {
          throw Exception('Failed to load friends');
        }
      });
    } catch (e) {
      log('💥 Get Player Info - $e - API Service 💥');
    }

    return playerInfo;
  }

  // DONE
  Future<PlayerInfo> getMyInfo() async {
    PlayerInfo playerInfo = PlayerInfo(
      chatId: -1,
      civilianRolePlayedGames: 0,
      sheriffRolePlayedGames: 0,
      doctorRolePlayedGames: 0,
      beautyRolePlayedGames: 0,
      bodyguardRolePlayedGames: 0,
      spyRolePlayedGames: 0,
      journalistRolePlayedGames: 0,
      mafiaRolePlayedGames: 0,
      informantRolePlayedGames: 0,
      barmanRolePlayedGames: 0,
      kamikazeRolePlayedGames: 0,
      id: 0,
      nickname: '',
      avatarUrl: 'https://i.pinimg.com/736x/9e/83/75/9e837528f01cf3f42119c5aeeed1b336.jpg',
      isOnline: true,
      lastSeen: DateTime.now(),
      joinDate: DateTime.now(),
      friendshipStatus: '',
      inGameLobby: false,
      overall: 0,
      wins: 0,
      loses: 0,
      mafiaWins: 0,
      civilianWins: 0,
      gameLobbyTitle: '',
      gameLobbyStatus: '',
      gameLobbyPlayerCount: 0,
      unreadMessagesCount: 0
    );

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.get(
          'profile/me',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          playerInfo = PlayerInfo.fromJson(data);
        } else {
          throw Exception('Failed to load my info');
        }
      });
    } catch (e) {
      log('💥 Get My Info - $e - API Service 💥');
    }

    return playerInfo;
  }

  // INCOMPLETE
  Future<void> report(String title, String description) async {
    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.post(
          'report',
          data: {
            "title": title, 
            "description": description
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {

        } else {
          throw Exception('Failed to report');
        }
      });
    } catch (e) {
      log('💥 Report - API Service 💥');
    }
  }

  // DONE
  Future<void> logOut() async {
    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.post(
          'Account/Logout',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken'
            }
          )
        );

        if (response.statusCode == 200) {
          await SharedPrefsService().clear();
        } else {
          throw Exception('Failed to log out');
        }
      });
    } catch (e) {
      log('💥 Log Out - API Service 💥');
    }
  }

  // DONE partially
  Future<bool> deleteFriend(int id) async {
    bool status = false;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.delete(
          'Friend/$id',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          status = true;
          List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
            "all_friends_list",
            (json) => Friendship.fromJson(json as Map<String, dynamic>),
          );

          currentFriends ??= [];

          currentFriends.removeWhere((f) => f.id == id);

          await GeneralCacheService().save<List<Friendship>?>(
            "all_friends_list",
            currentFriends,
          );

          EventBus().fire(DeleteFriendEvent(id));
        } else if (response.statusCode == 404) {
          throw Exception('No user found');
        } else {
          throw Exception('Failed to send POST request');
        }
      });
    } catch (e) {
      log('💥 Delete Friend - API Service 💥');
    }
    return status;
  }

  // DONE partially
  Future<bool> cancelFriendRequest(int id) async {
    bool status = false;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.delete(
          'Friend/$id/Cancel',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          status = true;
          EventBus().fire(DeleteFriendEvent(id));
        } else if (response.statusCode == 404) {
          throw Exception('No user found');
        } else {
          throw Exception('Failed to send POST request');
        }
      });
    } catch (e) {
      log('💥 Cancel Friend Request - $e - API Service 💥');
    }
    return status;
  }

  // DONE partially
  Future<List<FindFriend>?> findFriend(String? pattern) async {
    List<FindFriend>? userList = [];

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.get(
          'Friend/Search',
          queryParameters: {
            'pattern': pattern,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonData = response.data['players'] as List<dynamic>;

          userList = jsonData.isEmpty
            ? null
            : jsonData.map((item) {
                return FindFriend.fromJson(item as Map<String, dynamic>);
              }).toList();
        } else if (response.statusCode == 404) {
          throw Exception('No user found');
        } else {
          throw Exception('Failed to send POST request');
        }
      });
    } catch (e) {
      log('💥 Find Friend - API Service 💥');
    }
    return userList;
  }

  // DONE partially
  Future<List<FindFriend>?> suggestedFriends() async {
    List<FindFriend>? userList = [];

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.get(
          'Friend/Suggested',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonData = response.data['suggestedFriends'];

          userList = jsonData.isEmpty
            ? null
            : jsonData.map((item) {
                return FindFriend.fromJson(item as Map<String, dynamic>);
              }).toList();
        } else if (response.statusCode == 404) {
          throw Exception('No user found');
        } else {
          throw Exception('Failed to send POST request');
        }
      });
    } catch (e) {
      log('💥 Suggested Friends - API Service 💥');
    }
    return userList;
  }

  // DONE partially
  Future<bool> sendRequest(int id) async {
    bool status = false;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.post(
          'Friend/$id/request',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          status = true;
          EventBus().fire(FriendRequestSentEvent(id));
        } else if (response.statusCode == 409) {
          // request to alredy friend
        } else if (response.statusCode == 404) {
          // not find
        }
      });
    } catch (e) {
      log('💥 Send Request - API Service 💥');
    }
    return status;
  }

  // DONE partially
  Future<List<FriendRequest>?> getRequests() async {
    List<FriendRequest>? requestsList = [];

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.get(
          'friend/requests',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          List<dynamic> jsonData = response.data['pendingFriends'];
          requestsList = jsonData.isEmpty
            ? null
            : jsonData.map((item) {
                return FriendRequest.fromJson(item as Map<String, dynamic>);
              }).toList();
        } else {
          throw Exception('Failed to load requests');
        }
      });
    } catch (e) {
      log('💥 Get Requests - API Service - $e 💥');
    }
    return requestsList;
  }

  // DONE partially
  Future<bool> approveFriend(int id, bool approve) async {
    bool status = false;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.post(
          'Friend/$id/approve',
          queryParameters: {
            'approve': approve,
          },
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          status = true;
          if (approve) {
            final Map<String, dynamic> jsonData = response.data['friend'];

            final newFriend = Friendship.fromJson(jsonData);

            List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
              "all_friends_list",
              (json) => Friendship.fromJson(json as Map<String, dynamic>),
            );

            currentFriends ??= [];
            currentFriends.add(newFriend);

            await GeneralCacheService().save<List<Friendship>?>(
              "all_friends_list",
              currentFriends,
            );

            EventBus().fire(NewFriendAddedEvent(newFriend));
          }
        } else if (response.statusCode == 409) {
          // request to alredy friend
        }
      });
    } catch (e) {
      log('💥 Approve Friend - API Service 💥');
    }
    return status;
  }

  // DONE partially
  Future<bool> acceptInviteToRoom(String roomId) async {
    bool status = false;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.post(
          'room/$roomId/accept',
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
        }
      });
    } catch (e) {
      log('💥 Accept Invite To Room - API Service 💥');
    }
    return status;
  }

  // DONE partially
  Future<bool> sendInviteToRoom(int friendId) async {
    bool status = false;

    try {
      await executeWithTokenCheck((accessToken) async {
        final response = await GetIt.I<DioService>().dio.post(
          'room/invite/$friendId',
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          status = true;
        } else if (response.statusCode == 400) {
          //
        }
      });
    } catch (e) {
      log('💥 Send Invite To Room - API Service 💥');
    }
    return status;
  }

  // DONE
  Future<List<Message>?> getMessages(nickname) async {
    List<Message>? messages = [];

    try {
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
          messages = jsonData.isEmpty
            ? null
            : jsonData.map((item) {
                return Message.fromJson(item as Map<String, dynamic>);
              }).toList();
        } else {
          throw Exception('Failed to load messages');
        }
      });
    } catch (e) {
      log('💥 Get Messages - API Service 💥');
    }
    return messages;
  }

  // DONE
  Future<String> uploadAvatar(XFile imageFile) async {
    String avatar = "";

    try {
      await executeWithTokenCheck((accessToken) async {
        final file = File(imageFile.path);

        final formData = FormData.fromMap({
          'avatarFile': await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        });

        final response = await GetIt.I<DioService>().dio.post(
          'Account/ChangeAvatar',
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'multipart/form-data',
            },
          ),
        );

        if (response.statusCode == 200) {
          avatar = response.toString();
        } else {
          throw Exception('Failed to load avatar');
        }
      });
    } catch (e) {
      log('💥 Upload Avatar - API Service 💥');
    }
    return avatar;
  }

  // DONE
  Future<String> changeNickname(String nickname) async {
    String nickname = "";

    try {
      await executeWithTokenCheck((accessToken) async {
        final formDataObject = FormData.fromMap({'nickname': nickname});

        final response = await GetIt.I<DioService>().dio.get(
          'Account/',
          data: formDataObject,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
            },
          ),
        );

        if (response.statusCode == 200) {
          nickname = response.toString();
        } else {
          throw Exception('Failed to load messages');
        }
      });
    } catch (e) {
      log('💥 Change Nickname - API Service 💥');
    }
    return nickname;
  }
}

void setup(User user) {
  if (GetIt.I.isRegistered<ApiService>()) {
    GetIt.I.unregister<ApiService>();
  }
  GetIt.I.registerSingleton<ApiService>(
    ApiService(
      user.accessToken,
      user.expirationDate,
      user.refreshToken,
    ),
  );
}
