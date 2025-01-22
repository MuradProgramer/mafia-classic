import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/view/view.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/dio/dio_service.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';

import 'token_aware_service.dart';

class ApiService extends TokenAwareService {
  String _accessToken;
  DateTime _expiration;
  String _refreshToken;

  ///////// SIGNAL R ///////////
  late HubConnection hubConnection;
  bool hubIsConnected = false;

  // StreamController to handle the stream of games
  final StreamController<List<Game>> _gamesController = StreamController<List<Game>>.broadcast();
  
  // Getter for the games stream
  Stream<List<Game>> get gamesStream => _gamesController.stream;

  ApiService(this._accessToken, this._expiration, this._refreshToken) {
    hubConnection = HubConnectionBuilder().withUrl(
      'https://192.168.0.1:5163/mainlobby',
      options: HttpConnectionOptions(
        headers: MessageHeaders()..setHeaderValue('Authorization', 'Bearer $_accessToken'),
      ),
    )
    .build();
  }

  Future<void> connectHub() async {
    if (hubIsConnected) {
      print("HubConnection already established.");
      return; // Avoid reconnecting if already connected
    }

    hubConnection.on('GameLobbies', (List<Object?>? parameters) {
      //print('33: $parameters');
      final List<Game>? gamesList = decodeGameParameters(parameters);

      if (gamesList != null) {
        _gamesController.add(gamesList); // Notify listeners
      }
    });

    try {
      print("Starting HubConnection...");
      await hubConnection.start();
      hubIsConnected = true;
      print("HubConnection started.");
    } catch (e) {
      print("Failed to start HubConnection: $e");
    }
    // hubConnection.on('GameLobbyCreated', _handleReceivedMessage);
    // hubConnection.on('GameLobbyClosed',  _handleReceivedMessage);
    // hubConnection.on('PlayerJoined',     _handleReceivedMessage);
    // hubConnection.on('PlayerLeft',       _handleReceivedMessage);
  }

  List<Game>? decodeGameParameters(List<Object?>? parameters) {
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

  Future<void> disconnectHub() async {
    hubConnection.stop().then((_) {
      hubIsConnected = false;
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
      name: 'Mafia Game 1',
      //currentPlayers: 6,
      minPlayers: 10,
      maxPlayers: 20,
      status: 'Gathering players',
      hasPassword: false,
      players: players
      //characters: ['Mafia', 'Doctor', 'Sheriff'],
    ),
    Game(
      name: 'Mafia Game 2',
      //currentPlayers: 7,
      minPlayers: 4,
      maxPlayers: 10,
      status: 'Game Started',
      hasPassword: false,
      players: players
      //characters: ['Mafia', 'Doctor', 'Sheriff'],
    ),
    Game(
      name: 'Mafia Game 3',
      //currentPlayers: 10,
      minPlayers: 5,
      maxPlayers: 15,
      status: 'Gathering players',
      hasPassword: false,
      players: players
      //characters: ['Mafia', 'Doctor', 'Sheriff'],
    )
  ];

  void dispose() {
    _gamesController.close();
  }

  Future<bool> createGame(Game game) async {
    bool status = false;
    await executeWithTokenCheck((accessToken) async {
      final formDataObject = FormData.fromMap({'Game': game});

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