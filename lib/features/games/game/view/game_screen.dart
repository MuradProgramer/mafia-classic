// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/game/models/in_game_player.dart';
import 'package:mafia_classic/features/games/games.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/widgets/widgets.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/services/api_service.dart';

class GameScreen extends StatefulWidget {
  final String title;
  final String role;
  final int mafiaCount;
  final int citizenCount;
  final List<PlayerRole>? playersRole;
  final List<Player> allPlayers;

  const GameScreen(
    {
    super.key, 
    required this.title, 
    required this.playersRole, 
    required this.role, 
    required this.mafiaCount, 
    required this.citizenCount, 
    required this.allPlayers
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String gamePhase = '';
  int mafiaAlive = 0;
  int citizenAlive = 0;
  List<String> markNames = [];
  List<InGamePlayer> inGamePlayers = [];

  bool isAliveMyself = true;
  bool canIVote = true;
  bool iVoted = false;
  bool votesAreVisibleToMe = false;

  // DEF:    SKILLS VARIABLES
  bool canIUseSkill = false;
  bool iUsedSkill = false;
  List<String> toWhomIUsedSkill = [];
  List<String> specialForJournalist = [];


  int index = 0;

  List<PlayerRole> namesOfRevealed = [];
  List<PlayerRole> namesOfDead = [];

  late Timer? _timer;
  int phaseTime = 31;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    await GetIt.I<ApiService>().gameHubConnection.invoke("SendMessage", args: <Object>[ 
      _messageController.text.trim()
    ]);

    setState(() {
      inGameMessages.add(InGameMessage(
        nickname: authorizedUser.nickname,
        content: _messageController.text.trim(),
        avatarUrl: authorizedUser.avatarUrl,
      ));
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void startTimer(int seconds) {
    _timer?.cancel();

    setState(() {
      phaseTime = seconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (phaseTime > 0) {
        setState(() {
          phaseTime--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  List<InGameMessage> inGameMessages = [
    //InGameMessage(nickname: 'Player 1', content: 'hello world', avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png')
  ];

  void votePlayer(String votedPlayerNickname) async {
    if (!isAliveMyself) return;

    if (!inGamePlayers.firstWhere((el) => el.nickname == votedPlayerNickname).isAlive) return;

    if (markNames.any((el) => el == 'Satisfied')) return;

    if (widget.role == 'Terrorist') return;

    if (gamePhase == 'Day') {
      return;
    }
    else if (gamePhase == 'Night') {
      if ('Mafia' != widget.role) {
        return;
      }
    }

    await GetIt.I<ApiService>().gameHubConnection.invoke('Vote', args: <Object>[
      votedPlayerNickname
    ]);
  }
  
  void useSkill(List<String> influencedBySkillPlayersNickname) async {
    if (!isAliveMyself) return;

    if (markNames.any((el) => el == 'Satisfied')) return;

    for (var element in influencedBySkillPlayersNickname) { //!
      if (!inGamePlayers.firstWhere((el) => el.nickname == element).isAlive) return; 
    }

    // NOTE:    CHECKING ROLES

    if (widget.role == 'Mafia' || widget.role == 'Citizen' || widget.role == 'Spy') {
      return;
    }

    if (gamePhase == 'Day') {
      if (widget.role != 'Bodyguard') return;
    }

    if (gamePhase == 'DayVoting') {
      if (widget.role != 'Terrorist') return;
    }

    if (gamePhase == 'Night') {
      if (!['Barman', 'Informant', 'Journalist', 'Doctor', 'Mistress', 'Sheriff'].any((el) => el == widget.role)) {
        return;
      }
    }

    await GetIt.I<ApiService>().gameHubConnection.invoke('Skill', args: 
      influencedBySkillPlayersNickname
    );
  }

  // NOTE:    TESTING
  void printInGamePlayers() {
    print('------------------------');
    for (var el in inGamePlayers) {
      print('Name: ${el.nickname}  |  Role: ${el.role}  |  IsAlive: ${el.isAlive}  |  IsRevealed: ${el.isRevealed}  |  AvatarUrl: ${el.avatarUrl?.substring(0, 10)}');
    }
  }

  @override
  void initState() {
    super.initState();

    mafiaAlive = widget.mafiaCount;
    citizenAlive = widget.citizenCount;

    var apiService = GetIt.I<ApiService>();

    Map<String, String> roleMap = {};
    if (widget.playersRole != null) {
      for (var element in widget.playersRole!) {
        roleMap[element.nickname] = element.role;
      }
    }

    for (var item in widget.allPlayers) {
      if (item.nickname == authorizedUser.nickname) continue;
      inGamePlayers.add(InGamePlayer(
        nickname: item.nickname,
        isAlive: true,
        isRevealed: false,
        role: roleMap[item.nickname] ?? 'undef',
        avatarUrl: item.avatarUrl,
        votesOfPlayer: []
      ));
    }

    //printInGamePlayers();
    checkIfEligibleToVote();
    checkIfEligibleToUseSkill();
    
    // !:    REALIZATION OF PHASE
    apiService.gameHubConnection.on('Phase', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return; 

      var data = json.decode(parameters.first as String);

      final String phase = data['phase'];

      setState(() {
        gamePhase = phase;

        if (widget.role != 'Mafia' && gamePhase == 'NightVoting' || gamePhase == 'Day') {
          votesAreVisibleToMe = false;
        }
        else if (gamePhase == 'DayVoting') {
          votesAreVisibleToMe = true;
        }
        else if ((widget.role != 'Mafia' && gamePhase == 'Night')) {
          votesAreVisibleToMe = false;
        }
        else {
          votesAreVisibleToMe = true;
        }

        for (var element in inGamePlayers) {
          element.votesOfPlayer = [];
        }

        iVoted = false;
        
        checkIfEligibleToVote();

        iUsedSkill = false;
        toWhomIUsedSkill = [];

        checkIfEligibleToUseSkill();

        inGameMessages.add(InGameMessage(
          nickname: authorizedUser.nickname,
          content: 'Phase: $gamePhase',
          avatarUrl: authorizedUser.avatarUrl,
          isSystemMessage: true
        ));
        log('game phase: $gamePhase');
      });

      // DONE:   EVENT TIMER
      String eventTime = data['eventTime'] ?? '';

      if (eventTime.isNotEmpty) {
        final DateTime parsedDate = DateTime.parse(eventTime);
        //startTimer(parsedDate.difference(DateTime.now()).inSeconds);

        setState(() {
          phaseTime = parsedDate.difference(DateTime.now()).inSeconds;
        });

        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (phaseTime > 0) {
            setState(() {
              phaseTime--;
            });
          } else {
            timer.cancel();
          }
        });
      }
    });

    // DONE
    apiService.gameHubConnection.on('Mark', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String mark = parameters.first as String;

      setState(() {
        markNames.add(mark);
      });
    });

    // DONE
    apiService.gameHubConnection.on('Unmark', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      final String unmark = parameters.first as String;

      setState(() {
        markNames.remove(unmark);
      });
    });

    // DONE
    apiService.gameHubConnection.on('Mystery', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);
      var playerDto = data as Map<String, dynamic>;

      PlayerRole player = PlayerRole.fromJson(playerDto);

      setState(() {
        inGamePlayers.firstWhere((inplayer) => inplayer.nickname == player.nickname).isRevealed = true;
        inGamePlayers.firstWhere((inplayer) => inplayer.nickname == player.nickname).role = player.role;
        namesOfRevealed.add(PlayerRole(nickname: player.nickname, role: player.role));
      });
    });

    // DONE
    apiService.gameHubConnection.on('Interviewed', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);
      var interviewedPlayerDto = data as Map<String, dynamic>;

      InterviewedPlayer playersInterviewed = InterviewedPlayer.fromJson(interviewedPlayerDto);

      setState(() {
      inGameMessages.add(InGameMessage(
        nickname: "SYSTEM",
        content: 'Player ${playersInterviewed.firstPlayer} and ${playersInterviewed.secondPlayer} ${playersInterviewed.message}',
        avatarUrl: "https://www.w3schools.com/w3images/avatar6.png",
        isSystemMessage: true
      ));
    });

    _scrollToBottom();
    });

    // DONE
    apiService.gameHubConnection.on('PlayerDead', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) { 
        return; 
      }

      var data = json.decode(parameters.first as String);
      var playerDto = data as Map<String, dynamic>;

      PlayerRole playerDead = PlayerRole.fromJson(playerDto);

      setState(() {
        inGamePlayers.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).isAlive = false;
        inGamePlayers.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).role = playerDead.role;
        namesOfDead.add(PlayerRole(nickname: playerDead.nickname, role: playerDead.role));

        if (['Mafia', 'Terrorist', 'Barman', 'Mistress'].any((s) => s == playerDead.role)) {
          mafiaAlive -= 1;
        } else {
          citizenAlive -= 1;
        }

        if (playerDead.nickname == authorizedUser.nickname) {
          youAreDead();
          isAliveMyself = false;
        }
      });

      printInGamePlayers();
    });

    // DONE:    REALIZATION OF WINNING AND POINTS
    apiService.gameHubConnection.on('GameOver', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      final String winner = data['winner'];
      final int points = data['points'];

      log('WINNER: $winner    |    POINTS: $points');
    });
  
    // NOTE: 
    apiService.gameHubConnection.on('ReceiveMessage', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      final String nickname = data['nickname'];
      final String content = data['content'];
      final String avatarUrl = inGamePlayers.firstWhere((pl) => pl.nickname == nickname).avatarUrl ?? '';

      setState(() {
        inGameMessages.add(InGameMessage(
          nickname: nickname, 
          content: content, 
          avatarUrl: avatarUrl
        ));
      });
    });

    // DONE
    apiService.gameHubConnection.on('Voted', (List<Object?>? parameters) {
      if (parameters == null || parameters.isEmpty) return;

      var data = json.decode(parameters.first as String);

      final String from = data['from'];
      final String target = data['target'];

      setState(() {
        inGamePlayers.firstWhere((el) => el.nickname == target).votesOfPlayer!.add(from);
      });
    });

    // DONE
    apiService.gameHubConnection.on('CloseConnection', (List<Object?>? parameters) {
      GetIt.I<ApiService>().disconnectGameHub();
    });
    //await GetIt.I<ApiService>().gameHubConnection.invoke("TriggerPhaseEvent", args: <Object>[]);
  }


  void changeState1(bool newState) {
    setState(() {
      canIVote = newState;
    });
  }

  void changeState2(bool newState) {
    setState(() {
      canIUseSkill = newState;
    });
  }

  void checkIfEligibleToVote() {
    if (!['Day', 'DayVoting', 'Night', 'NightVoting'].any((el) => el == gamePhase)) {
      changeState1(false);
      return;
    }

    if (!isAliveMyself) {
      changeState1(false);
      return;
    }

    if (widget.role == 'Terrorist') {
      changeState1(false);
      return;
    }

    if (markNames.any((el) => el == 'Satisfied')) {
      changeState1(false);
      return;
    }

    if (gamePhase == 'Day') {
      changeState1(false);
      return;
    } else if (gamePhase == 'DayVoting') {
      changeState1(true);
      return;
    } else if (gamePhase == 'NightVoting') {
      if ('Mafia' != widget.role) {
        changeState1(false);
        return;
      }
      else {
        changeState1(true);
        return;
      }
    } else if (gamePhase == 'Night') {
      changeState1(false);
      return;
    }

    changeState1(true);
    return;
  }

  void checkIfEligibleToUseSkill() {
    if (!['Day', 'DayVoting', 'Night', 'NightVoting'].any((el) => el == gamePhase)) {
      changeState2(false);
      return;
    }
    if (!isAliveMyself) {
      changeState2(false);
      return;
    }

    if (markNames.any((el) => el == 'Satisfied')) {
      changeState2(false);
      return;
    }

    if (widget.role == 'Mafia' || widget.role == 'Citizen' || widget.role == 'Spy') {
      changeState2(false);
      return;
    }

    if (gamePhase == 'Day') {
      if (widget.role != 'Bodyguard') {
        changeState2(false);
        return;
      }
    }

    if (gamePhase == 'DayVoting') {
      if (widget.role != 'Terrorist') {
        changeState2(false);
        return;
      }
    }

    if (gamePhase == 'Night') {
      if (!['Informant', 'Journalist', 'Doctor', 'Mistress', 'Sheriff'].any((el) => el == widget.role)) {
        changeState2(false);
        return;
      }
    }

    if (gamePhase == 'NightVoting') {
      if ('Barman' != widget.role) {
        changeState2(false);
        return;
      }
    }

    changeState2(true);
  }

  void youAreDead() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("You Died!"),
          content: const Text("You have been eliminated from the game."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
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


            //NOTE:    FOR TESTING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, left: 5),
                  width: 150,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // NOTE:    Event: Interviewed
                      // setState(() {
                      //   inGameMessages.add(InGameMessage(
                      //     nickname: "SYSTEM",
                      //     content: 'Player PLAYER2 and PLAYER4 ARE IN THE SAME GROUP',
                      //     avatarUrl: "https://www.w3schools.com/w3images/avatar6.png",
                      //     isSystemMessage: true
                      //   ));
                      // });

                      // NOTE:    Event: Mystery
                      // setState(() {
                      //   inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player4').isRevealed = true;
                      //   inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player4').role = 'Barman';
                      //   namesOfRevealed.add(PlayerRole(nickname: 'Player4', role: 'Barman'));
                      //   printInGamePlayers();
                      // });

                      // NOTE:    Event: PlayerDead
                      setState(() {
                        inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player1').isAlive = false;
                        inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player1').role = 'Terrorist';
                        namesOfDead.add(PlayerRole(nickname: 'Player1', role: 'Terrorist'));
                        printInGamePlayers();
                      });
                    },
                    child: const Text('ACTION'),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 5, right: 5),
                  width: 200,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      // NOTE:    Event: Phase
                      setState(() {
                        final phases = ['Day', 'DayVoting', 'Night', 'NightVoting'];
                        gamePhase = phases[index];
                        index += 1;
                        if (index > 3) {
                          index = 0;
                        }

                        // NOTE:   VOTE
                        if (widget.role != 'Mafia' && gamePhase == 'NightVoting' || gamePhase == 'Day') {
                          votesAreVisibleToMe = false;
                        }
                        else if (gamePhase == 'DayVoting') {
                          votesAreVisibleToMe = true;
                        }
                        else if ((widget.role != 'Mafia' && gamePhase == 'Night')) {
                          votesAreVisibleToMe = false;
                        }
                        else {
                          votesAreVisibleToMe = true;
                        }

                        for (var element in inGamePlayers) {
                          element.votesOfPlayer = [];
                        }

                        iVoted = false;
                        
                        checkIfEligibleToVote();

                        // NOTE:    SKILL
                        //!!!!!!!!!!!!!!

                        iUsedSkill = false;
                        toWhomIUsedSkill = [];

                        checkIfEligibleToUseSkill();

                        inGameMessages.add(InGameMessage(
                          nickname: authorizedUser.nickname,
                          content: 'Phase: $gamePhase',
                          avatarUrl: authorizedUser.avatarUrl,
                          isSystemMessage: true
                        ));
                      });
                    },
                    child: const Text('CHANGE PHASE'),
                  ),
                ),
              ],
            ),
            
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
                                      //? MARKED ROLES
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
                                  //? TIMER
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Text(
                                      phaseTime != 0 ? '$phaseTime' : "",
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
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
                          child: InGameChatBox(messages: inGameMessages, scrollController: _scrollController, messageController: _messageController, scrollToBottom: _scrollToBottom,),
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
                      itemCount: inGamePlayers.length,
                      itemBuilder: (context, index) {
                        final player = inGamePlayers[index];

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Expanded(
                              child: Container(
                                height: 100,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  // NOTE:    IF THE ROLE IS MAFIA IT WILL SHOW OTHER MAFIAS
                                  color: 
                                    player.isAlive
                                      ? widget.role == 'Mafia'
                                        ? ['Mafia', 'Terrorist'].any((el) => el == player.role)
                                          ? Colors.purple
                                          : player.isRevealed
                                            ? Colors.amber
                                            : Colors.black
                                      : Colors.black
                                    : player.isRevealed
                                      ? Colors.amber
                                      : Colors.red
                                  
                                  // widget.role == 'Mafia' //! IF
                                  //   ? ['Mafia', 'Terrorist'].any((el) => el == player.role)  //! IF
                                  //     ? Colors.purple 
                                  //     : player.isRevealed //! IF
                                  //       ? Colors.amber 
                                  //       : player.isAlive //! IF
                                  //         ? Colors.black 
                                  //         : Colors.red 
                                  //   : player.isRevealed //! IF
                                  //     ? Colors.amber 
                                  //     : player.isAlive //! IF
                                  //       ? Colors.black 
                                  //       : Colors.red,
                                  ,borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      !player.isAlive 
                                        ? namesOfDead.firstWhere((playerDead) => playerDead.nickname == player.nickname).role 
                                        : player.isRevealed
                                          ? namesOfRevealed.firstWhere((playerRevealed) => playerRevealed.nickname == player.nickname).role 
                                          : '',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    Text(
                                      (player.isAlive && votesAreVisibleToMe) 
                                        ? player.votesOfPlayer!.isNotEmpty 
                                          ?'${player.votesOfPlayer!.length}'
                                          : ''
                                        : '',
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                    // DEF:    SKILLS BUTTON
                                    GestureDetector(
                                      onTap: () {
                                        if (iUsedSkill) {
                                          return;
                                        }

                                        if (!canIUseSkill) {
                                          return;
                                        }

                                        if (!inGamePlayers.firstWhere((el) => el.nickname == player.nickname).isAlive) {
                                          return;
                                        }

                                        if (toWhomIUsedSkill.any((el) => el == player.nickname)) {
                                          return;
                                        }
                                        
                                        setState(() {
                                          if (widget.role == 'Journalist') {
                                            if (specialForJournalist.any((el) => el == player.nickname)) {
                                              return;
                                            }

                                            toWhomIUsedSkill.add(player.nickname);
                                            specialForJournalist.add(player.nickname);

                                            log('added: ${player.nickname}');

                                            if (toWhomIUsedSkill.length == 2) {
                                              iUsedSkill = true;
                                              //!!!!!!!!!!!!!!
                                              useSkill(toWhomIUsedSkill);
                                              return;
                                            }
                                          }
                                          else {
                                            iUsedSkill = true;
                                            for (var e in toWhomIUsedSkill) {
                                              log(e);
                                            }
                                            toWhomIUsedSkill.add(player.nickname);
                                            //!!!!!!!!!!!!!!
                                            useSkill(toWhomIUsedSkill);
                                          }
                                          log('used skill on: ${player.nickname}');
                                        });
                                      },
                                      child: (!iUsedSkill && canIUseSkill && player.isAlive) 
                                      ? (widget.role == 'Journalist' && !specialForJournalist.any((el) => el == player.nickname)) 
                                        ? Container(
                                          height: 20,
                                          width: 40,
                                          color: Colors.cyan[900],
                                          child: const Center(child: Text('Use', style: TextStyle(fontSize: 12))),
                                        )
                                        : 
                                          Container(
                                              height: 20,
                                              width: 40,
                                              color: Colors.cyan[900],
                                              child: const Center(child: Text('Use', style: TextStyle(fontSize: 12))),
                                            )
                                      : const SizedBox(),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            // DEF:    Voting
                            GestureDetector(
                              onTap: () {
                                if (iVoted) return;

                                if (!canIVote) return;

                                if (!inGamePlayers.firstWhere((el) => el.nickname == player.nickname).isAlive) {
                                  //changeState1(false);
                                  return;
                                }
                                //!
                                if (['Mafia', 'Terrorist'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') {
                                  return;
                                }

                                setState(() {
                                  iVoted = true;
                                  //!!!!!!!!!!!!!!
                                  //inGamePlayers.firstWhere((el) => el.nickname == player.nickname).votesOfPlayer!.add(authorizedUser.nickname);
                                  votePlayer(player.nickname);
                                  log('taped: ${player.nickname}');
                                });
                              },
                              child: Text(
                                player.nickname,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: //(!iVoted && canIVote) ? Colors.green : Colors.white, 
                                  (!iVoted && canIVote && player.isAlive) 
                                  //!
                                    ? (['Mafia', 'Terrorist'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') 
                                      ? Colors.white 
                                      : Colors.green 
                                    : Colors.white, 
                                  fontSize: 12
                                ),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                
                              ),
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