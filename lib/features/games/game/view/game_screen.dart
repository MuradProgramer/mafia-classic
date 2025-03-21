import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/game/models/in_game_player.dart';
import 'package:mafia_classic/features/games/games.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/widgets/widgets.dart';
import 'package:mafia_classic/services/api_service.dart';

class GameScreen extends StatefulWidget {
  final String title;
  final String role;
  final int mafiaCount;
  final int citizenCount;
  final List<PlayerRole> playersRole;
  List<InGamePlayer> inGamePlayers;

  GameScreen(
    {
    super.key, 
    required this.title, 
    required this.playersRole, 
    required this.role, 
    required this.mafiaCount, 
    required this.citizenCount,
    this.inGamePlayers = const []
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String gamePhase = 'Morning';
  int mafiaAlive = 0;
  int citizenAlive = 0;
  List<String> markNames = ['Sheriff', 'Informant', 'Doctor'];

  List<PlayerRole> namesOfRevealed = [];
  List<PlayerRole> namesOfDead = [];

  late Timer? _timer;
  int phaseTime = 40;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _inGameMessages.add(InGameMessage(
        nickname: "You",
        content: _messageController.text.trim(),
        avatarUrl: "https://www.w3schools.com/w3images/avatar6.png",
      ));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  final List<InGameMessage> _inGameMessages = [
    InGameMessage(nickname: 'Player 1', content: 'hello world', avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png')
  ];

  @override
  void initState() {
    super.initState();

    mafiaAlive = widget.mafiaCount;
    citizenAlive = widget.citizenCount;

    var apiService = GetIt.I<ApiService>();

    for (var playerRole in widget.playersRole) {
      widget.inGamePlayers.add(InGamePlayer(
        nickname: playerRole.nickname, 
        role: playerRole.role, 
        isAlive: true, 
        isRevealed: false
      ));
    }

    // NOTE: TESTING
    apiService.gameHubConnection.on('Mark', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String mark = parameters.first as String;

      setState(() {
        markNames.add(mark);
      });
    });

    // NOTE: TESTING
    apiService.gameHubConnection.on('Unmark', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String unmark = parameters.first as String;

      setState(() {
        markNames.remove(unmark);
      });
    });

    // NOTE: TESTING
    apiService.gameHubConnection.on('Mystery', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);
      var playerDto = data as Map<String, dynamic>;

      PlayerRole player = PlayerRole.fromJson(playerDto);

      setState(() {
        widget.inGamePlayers.firstWhere((inplayer) => inplayer.nickname == player.nickname).isRevealed = true;
        namesOfRevealed.add(PlayerRole(nickname: player.nickname, role: player.role));
      });
    });

    // NOTE: TESTING
    apiService.gameHubConnection.on('Interviewed', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);
      var interviewedPlayerDto = data as Map<String, dynamic>;

      InterviewedPlayer playersInterviewed = InterviewedPlayer.fromJson(interviewedPlayerDto);

      setState(() {
      _inGameMessages.add(InGameMessage(
        nickname: "SYSTEM",
        content: 'Player ${playersInterviewed.firstPlayer} and ${playersInterviewed.secondPlayer} {players.message}',
        avatarUrl: "https://www.w3schools.com/w3images/avatar6.png",
        isSystemMessage: true
      ));
    });

    _scrollToBottom();
    });

    // NOTE: TESTING
    apiService.gameHubConnection.on('PlayerDead', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);
      var playerDto = data as Map<String, dynamic>;

      PlayerRole playerDead = PlayerRole.fromJson(playerDto);

      setState(() {
        widget.inGamePlayers.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).isAlive = false;
        namesOfDead.add(PlayerRole(nickname: playerDead.nickname, role: playerDead.role));
      });
    });

    // NOTE:    REALIZATION OF PHASE
    apiService.gameHubConnection.on('Phase', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      final String phase = data['phase'];

      setState(() {
        gamePhase = phase;
        log('game phase: $gamePhase');
      });

      // DONE:   EVENT TIMER
      String eventTime = data['eventTime'] ?? '';
      if (eventTime.isNotEmpty) {
        final DateTime parsedDate = DateTime.parse(eventTime);

        setState(() {
          phaseTime = parsedDate.difference(DateTime.now()).inSeconds;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (phaseTime > 0) {
              phaseTime--;
            } else {
              timer.cancel();
            }
          });
        });
      }
    });

    // NOTE:    REALIZATION OF WINNING AND POINTS
    apiService.gameHubConnection.on('GameOver', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      final String winner = data['winner'];
      final String points = data['points'];

      log('WINNER: $winner    |    POINTS: $points');
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade800,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle())
      ),
      body: Container(
        margin: EdgeInsets.only(bottom: deviceHeight * 0.005),
        color: Colors.grey.shade800,
        child: Column(
          children: [

            Container( //   TO ONE WIDGET
              width: deviceWidth,
              height: deviceHeight * 0.017,
              margin: const EdgeInsets.all(2.0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
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
                  SizedBox(
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

            Container(
              height: deviceHeight * 0.7,
              width: deviceWidth,
              margin: const EdgeInsets.all(4.0),
              
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: deviceWidth * 0.663,
                    height: deviceHeight * 0.7,

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        //?    INFO PART
                        Container(
                          width: deviceWidth * 0.663,
                          height: deviceHeight * 0.14,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.amber,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //? ROLE
                                  Text(widget.role, style: const TextStyle(fontSize: 20)),
                                  SizedBox(
                                    width: 150,
                                    child: Text(
                                      markNames.isNotEmpty ? markNames.join(", ") : '', 
                                      style: const TextStyle(fontSize: 14, color: Colors.amber),
                                    )
                                  )
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 2.5, right: 6),
                                    child: Column(
                                      children: [
                                        Text(
                                          //? MAFIA COUNT
                                          "  Mafia: ${widget.mafiaCount} | $mafiaAlive", 
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.red
                                          ),
                                        ),
                                        //? CITIZEN COUNT
                                        Text(
                                          "Citizen: ${widget.citizenCount} | $citizenAlive", 
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.green
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer()
                                ],
                              )
                            ],
                          )
                        ),
                        
                        //?    CHAT PART
                        Container(
                          width: deviceWidth * 0.663,
                          height: deviceHeight * 0.5525,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.green,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: InGameChatBox(messages: _inGameMessages, scrollController: _scrollController, messageController: _messageController, scrollToBottom: _scrollToBottom,),
                        ),
                      ],
                    )
                  ),

                  //?    PLAYERS PART
                  Container(
                    width: deviceWidth * 0.3,
                    height: deviceHeight * 0.7,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.6,
                      ),
                      itemCount: widget.inGamePlayers.length,
                      itemBuilder: (context, index) {
                        final player = widget.inGamePlayers[index];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  // NOTE:    IF THE ROLE IS MAFIA IT WILL SHOW OTHER MAFIAS
                                  color: widget.role == 'Mafia' //! IF
                                    ? player.role == 'Mafia' //! IF
                                      ? Colors.purple 
                                      : player.isRevealed //! IF
                                        ? Colors.amber 
                                        : player.isAlive //! IF
                                          ? Colors.black 
                                          : Colors.red 
                                    : player.isRevealed //! IF
                                      ? Colors.amber 
                                      : player.isAlive //! IF
                                        ? Colors.black 
                                        : Colors.red,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  !player.isAlive 
                                    ? namesOfDead.firstWhere((playerDead) => playerDead.nickname == player.nickname).role 
                                    : player.isRevealed
                                      ? namesOfRevealed.firstWhere((playerRevealed) => playerRevealed.nickname == player.nickname).role 
                                      : '',
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              player.nickname,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        );
                      },
                    ),
                  )
                ],
              )
            ),

            //?    INPUT PART
            Container(
              width: deviceWidth,
              height: deviceHeight * 0.055,
              margin: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: EnterMessage(messageController: _messageController, sendMessage: _sendMessage)
            )
          ],
        ),
      )
    
    );
  }
}