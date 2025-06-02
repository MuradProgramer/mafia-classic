// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

//NOTE:      53, 90, 4

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/game/models/in_game_player.dart';
import 'package:mafia_classic/features/games/games.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/widgets/widgets.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/main.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:signalr_netcore/signalr_client.dart';

class GameScreen extends StatefulWidget {
  final String title;
  String role;
  int mafiaCount;
  int citizenCount;
  final List<PlayerRole>? playersRole;
  final List<Player> allPlayers;
  final bool gameIsReadyWidget;

  final bool cameBackFromAfk;

  GameScreen({
    super.key, 
    required this.title, 
    required this.playersRole, 
    required this.role, 
    required this.mafiaCount, 
    required this.citizenCount, 
    required this.allPlayers, 
    required this.cameBackFromAfk,
    required this.gameIsReadyWidget
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String gamePhase = 'Day'; // +
  int mafiaAlive = 0; // +
  int citizenAlive = 0; // +
  List<InGamePlayer> inGamePlayers = []; // +

  List<String> markNames = []; // +
  bool isAliveMyself = true; // +
  bool canISendMessage = true;
  int votesOnMe = 0; // +

  // DEF:    VOTE VARIABLES
  bool canIVote = false;
  bool iVoted = false;
  bool votesAreVisibleToMe = false;

  // DEF:    SKILLS VARIABLES
  bool canIUseSkill = false;
  bool iUsedSkill = false;

  List<String> toWhomIUsedSkill = []; // +
  List<String> specialForJournalist = []; // +

  List<PlayerRole> namesOfRevealed = []; // +
  List<PlayerRole> namesOfDead = []; // +

  int index = 0;
  int phaseTime = 0;
  Timer? _intoxicationTimer;

  bool gameIsReady = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    //!!!!!!!!!!!!!!!!!!
    // await GetIt.I<ApiService>().gameHubConnection.invoke("SendMessage", args: <Object>[ 
    //   _messageController.text.trim()
    // ]);

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

  List<InGameMessage> inGameMessages = [];

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
    ]).then((value) => log('vote playeer method suucesfully'));
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
      if (!['Barman', 'Informant', 'Journalist', 'Doctor', 'Beauty', 'Sheriff'].any((el) => el == widget.role)) {
        return;
      }
    }

    await GetIt.I<ApiService>().gameHubConnection.invoke('Skill', args:
      [influencedBySkillPlayersNickname]
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
    gameIsReady = widget.gameIsReadyWidget;
    printInGamePlayers();
    // !!!!!!!!!!!!!!!!!!!
    /*

    //!!!!!!!!!!!!!!
    var apiService = GetIt.I<ApiService>();

    //
    //toWhomIUsedSkill.add('Player7');
    // for (var e in inGamePlayers) {
    //   e.isAlive = false;
    // }

    //!!!!!!!!!!!!
    if (!apiService.gameHubIsConnected) {
      print("187 games screen - creating connection");
      apiService.gameHubConnection = HubConnectionBuilder().withUrl(
        'https://46.32.173.182/gamelobby?title=${widget.title}',
        options: HttpConnectionOptions(
          accessTokenFactory: () => Future.value(GetIt.I<ApiService>().accessToken),
          // skipNegotiation: true,
          // transport: HttpTransportType.WebSockets,
        ),
      )
      .build();
    }
    
    if (widget.cameBackFromAfk) {
      //!!!!!!!!!!!!
      
      apiService.gameHubConnection.on('ReconnectGameData', (List<Object?>? parameters) {
        try {
          if (parameters == null || parameters.isEmpty) return;
          var data = json.decode(parameters.first as String);


          final role = data['role'];
          log('01');
          final phase = data['gamePhase'];
          log('02');
          final isAlive = data['isAlive'] as bool;
          log('03');
          final mafiaCount = data['mafiaCount'] as int;
          log('04');
          final citizenCount = data['citizenCount'] as int;
          log('05');
          final aliveMafiaCount = data['aliveMafiaCount'] as int;
          log('06');
          final aliveCitizenCount = data['aliveCitizenCount'] as int;
          log('07');

          //log((data['messages'] as List<dynamic>)[0]['nickname'].toString());
          final players = (data['players'] as List<dynamic>?)
              ?.map((e) => PlayersFromAfk.fromJson(e))
              .toList() ?? [];
              
          final messages = (data['messages'] as List<dynamic>?)
              ?.map((e) => InGameMessage.fromJson(e))
              .toList() ?? [];
          
          log('8');

          final marksOfPlayer = (data['playerMarks'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [];
          
          log('9');
          //log((data['votes'] as List<dynamic>?).toString());
          final votes = (data['votes'] as List<dynamic>?)
              ?.map((e) => Vote.fromJson(e))
              .toList() ?? [];

          log('10');
          // final players = (data['players'] as List<dynamic>?)
          //     ?.map((e) => PlayersFromAfk.fromJson(e))
          //     .toList() ?? [];

          log('11');
          // final players = data['players'].map((playerJson) {
          //   return PlayersFromAfk.fromJson(playerJson as Map<String, dynamic>);
          // }).toList();

          setState(() {
            gameIsReady = true;
            widget.role = role;
            gamePhase = phase;
            isAliveMyself = isAlive;
            widget.mafiaCount = mafiaCount;
            widget.citizenCount = citizenCount;
            mafiaAlive = aliveMafiaCount;
            citizenAlive = aliveCitizenCount;
            
            for (InGameMessage message in messages) {
              
              if (message.type == 'Default') {
                if (players.any((el) => el.nickname == message.nickname)) {
                  message.avatarUrl = players.firstWhere((el) => el.nickname == message.nickname).avatarUrl;
                } else {
                  message.avatarUrl = authorizedUser.avatarUrl;
                }
              }
              inGameMessages.add(message);
            }

            checkIfEligibleToVote();
            checkIfEligibleToUseSkill();
            checkIfEligibleToSendMessage();
            intoxicationEffect();

            inGameMessages = messages;

            markNames = marksOfPlayer;

            for (Vote vote in votes) {
              if (vote.target == authorizedUser.nickname) {
                votesOnMe += 1;
              }
            } 

            for (PlayersFromAfk el in players) {
              List<String> playerVotesTEMP = [];

              for (Vote vote in votes) {
                if (vote.target == el.nickname) {
                  playerVotesTEMP.add(vote.from);
                }
              }

              if (el.nickname == authorizedUser.nickname) continue;

              inGamePlayers.add(
                InGamePlayer(
                  nickname: el.nickname,
                  isAlive: el.isAlive,
                  avatarUrl: el.avatarUrl,
                  isRevealed: ((role == 'Sheriff' || role == 'Informant') && el.isMarked == true) ? true : false,
                  votesOfPlayer: playerVotesTEMP,
                  role: el.role
                )
              );

              if ((role == 'Sheriff' || role == 'Informant') && el.isMarked == true) {
                namesOfRevealed.add(PlayerRole(nickname: el.nickname, role: el.role!));
              }

              if (!el.isAlive) {
                namesOfDead.add(PlayerRole(nickname: el.nickname, role: el.role!));
              }

              if (el.isMarked == true) {
                toWhomIUsedSkill.add(el.nickname);
                if (role == 'Journalist') {
                  specialForJournalist.add(el.nickname);
                }
              }
            }


          });
        } on Exception catch (e) {
          log('EXCEPTION IN:     ReconnectGameData EVENT - GAME SCREEN: ${e.toString()}');
        }
      });
      
    } else {
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
    }

    checkIfEligibleToVote();
    checkIfEligibleToUseSkill();
    checkIfEligibleToSendMessage();
    intoxicationEffect();

    
    // DONE
    apiService.gameHubConnection.on('Phase', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return; 
        
        log(parameters.first as String);
        final String phase = parameters.first as String;
        
        setState(() {
          gamePhase = phase;
        
          if (widget.role != 'Mafia' && gamePhase == 'NightVoting' || gamePhase == 'Day') {
            votesAreVisibleToMe = false;
          }
          else if (gamePhase == 'DayVoting') {
            if (markNames.any((e) => e == 'Intoxicated')) {
                  votesAreVisibleToMe = false;
                }
                else {
                  votesAreVisibleToMe = true;
                }
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
          checkIfEligibleToSendMessage();
        
          inGameMessages.add(InGameMessage(
            nickname: authorizedUser.nickname,
            content: 'Phase: $gamePhase',
            avatarUrl: authorizedUser.avatarUrl,
            type: 'System'
          ));
          log('game phase: $gamePhase');
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     PHASE EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE
    apiService.gameHubConnection.on('Mark', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        final String mark = parameters.first as String;
        
        setState(() {
          markNames.add(mark);
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     MARK EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE
    apiService.gameHubConnection.on('Unmark', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        final String unmark = parameters.first as String;
        
        setState(() {
          markNames.remove(unmark);
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     UNMARK EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE
    apiService.gameHubConnection.on('Mystery', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        var data = json.decode(parameters.first as String);
        var playerDto = data as Map<String, dynamic>;
        
        PlayerRole player = PlayerRole.fromJson(playerDto);
        
        setState(() {
          inGamePlayers.firstWhere((inplayer) => inplayer.nickname == player.nickname).isRevealed = true;
          inGamePlayers.firstWhere((inplayer) => inplayer.nickname == player.nickname).role = player.role;
          namesOfRevealed.add(PlayerRole(nickname: player.nickname, role: player.role));
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     MYSTERY EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE
    apiService.gameHubConnection.on('PlayerDead', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) {
          return; 
        }
        
        var data = json.decode(parameters.first as String);
        var playerDto = data as Map<String, dynamic>;
        
        PlayerRole playerDead = PlayerRole.fromJson(playerDto);
        
        setState(() {
        
          if (playerDead.nickname == authorizedUser.nickname) {
            youAreDead();
            if (['Mafia', 'Terrorist', 'Beauty', 'Barman'].any((e) => e == playerDead.role)) {
              mafiaAlive -= 1;
            } else {
              citizenAlive -= 1;
            }
            isAliveMyself = false;
            checkIfEligibleToSendMessage();
            return;
          }
        
          inGamePlayers.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).isAlive = false;
          inGamePlayers.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).role = playerDead.role;
          namesOfDead.add(PlayerRole(nickname: playerDead.nickname, role: playerDead.role));
        
          if (['Mafia', 'Terrorist', 'Barman', 'Informant'].any((s) => s == playerDead.role)) {
            mafiaAlive -= 1;
          } else {
            citizenAlive -= 1;
          }
          
        });
        
        printInGamePlayers();
      } on Exception catch (e) {
        log('EXCEPTION IN:     PLAYER DEAD EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE:    REALIZATION OF WINNING AND POINTS
    apiService.gameHubConnection.on('GameOver', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        var data = json.decode(parameters.first as String);
        
        final String winner = data['winner'];
        final int points = data['points'];
        
        log('WINNER: $winner    |    POINTS: $points');
      } on Exception catch (e) {
        log('EXCEPTION IN:     GAME OVER EVENT - GAME SCREEN: ${e.toString()}');
      }
    });
  
    apiService.gameHubConnection.off('ReceiveMessage');
    
    // DONE 
    apiService.gameHubConnection.on('ReceiveMessage', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        print(parameters.first);
        var data = json.decode(parameters.first as String);
        
        final String nickname = data['nickname'];
        final String type = data['type'];
        final String content = data['content'];
        String avatarUrl = "https://i.pinimg.com/736x/97/53/2c/97532cc6bf6af4ef60ef08fb5ebc5abc.jpg";
        if (type != 'System' && nickname != 'Informant') {
          inGamePlayers.firstWhere((pl) => pl.nickname == nickname).avatarUrl;
        }
        
        setState(() {
          inGameMessages.add(InGameMessage(
            nickname: nickname, 
            content: content, 
            avatarUrl: avatarUrl,
            type: type
          ));
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     RECIEVE MESSAGE EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE
    apiService.gameHubConnection.on('Voted', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;

        var data = json.decode(parameters.first.toString());
        
        final String from = data['from'];
        final String target = data['target'];
        
        setState(() {
          if (target == authorizedUser.nickname) {
            votesOnMe += 1;
            return;
          }
          inGamePlayers.firstWhere((el) => el.nickname == target).votesOfPlayer!.add(from);
        });
      } catch (e) {
        log('EXCEPTION IN:     VOTED EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // DONE
    apiService.gameHubConnection.on('CloseConnection', (List<Object?>? parameters) {
      try {
        GetIt.I<ApiService>().disconnectGameHub();
      } on Exception catch (e) {
        log('EXCEPTION IN:     CLOSE CONNECTION EVENT - GAME SCREEN: ${e.toString()}');
      }
    });
    
    // DONE
    apiService.gameHubConnection.on('Timer', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        setState(() {
          phaseTime = parameters.first as int;
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     TIMER EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // NOTE:    TESTING
    apiService.gameHubConnection.on('Ping', (List<Object?>? parameters) {
      log('PING');
    });

    apiService.gameHubConnection.onclose(({Exception? error}) {
      print("OnClose: $error");
    });

    apiService.gameHubConnection.onreconnecting(({Exception? error}) {
      print("OnReconnecting: $error");
    });

    apiService.gameHubConnection.onreconnected(({String? connectionId}) {
      print("OnReconnected: $connectionId");
    });
    
    if (!apiService.gameHubIsConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        apiService.gameHubConnection.start()?.then((_) {
          apiService.gameHubIsConnected = true;
          gameIsReady = true;
          print("Connected to SignalR!");
        }).catchError((e) {
          print("Connection error: $e");
        });
      });
    }

    */

    //await GetIt.I<ApiService>().gameHubConnection.invoke("TriggerPhaseEvent", args: <Object>[]);
    
  }

  @override
  void dispose() {
    _intoxicationTimer?.cancel();
    print("Disonnected to SignalR! 600 games screen");
    GetIt.I<ApiService>().disconnectGameHub();
    GetIt.I<ApiService>().gameHubIsConnected = false;
    super.dispose();
  }

  String giveRandomStr(int count) {
    List<String> symbols = ['!', '@', '#', '%', '^', '&', '*'];
    return List.generate(count, (index) => symbols[math.Random().nextInt(symbols.length)]).join();
  }
  
  void intoxicationEffect() {
    if (markNames.any((e) => e == 'Intoxicated')) {
      _intoxicationTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        setState(() {});
      });
    } else {
      _intoxicationTimer?.cancel();
    }
  }

  void changeVoteState(bool newState) {
    setState(() {
      canIVote = newState;
    });
  }

  void changeSkillState(bool newState) {
    setState(() {
      canIUseSkill = newState;
    });
  }

  void changeSendMessageState(bool newState) {
    setState(() {
      canISendMessage = newState;
    });
  }
 
  void checkIfEligibleToVote() {
    if (!['Day', 'DayVoting', 'Night', 'NightVoting'].any((el) => el == gamePhase)) {
      changeVoteState(false);
      return;
    }

    if (!isAliveMyself) {
      changeVoteState(false);
      return;
    }

    if (widget.role == 'Terrorist') {
      changeVoteState(false);
      return;
    }

    if (markNames.any((el) => el == 'Satisfied')) {
      changeVoteState(false);
      return;
    }

    if (gamePhase == 'Day') {
      changeVoteState(false);
      return;
    } else if (gamePhase == 'DayVoting') {
      if (markNames.any((e) => e == 'Intoxicated')) {
        changeVoteState(false);
      }
      else {
        changeVoteState(true);
      }
      return;
    } else if (gamePhase == 'NightVoting') {
      if ('Mafia' != widget.role) {
        changeVoteState(false);
        return;
      }
      else {
        changeVoteState(true);
        return;
      }
    } else if (gamePhase == 'Night') {
      changeVoteState(false);
      return;
    }

    changeVoteState(true);
    return;
  }

  void checkIfEligibleToUseSkill() {
    if (!['Day', 'DayVoting', 'Night', 'NightVoting'].any((el) => el == gamePhase)) {
      changeSkillState(false);
      return;
    }
    if (!isAliveMyself) {
      changeSkillState(false);
      return;
    }

    if (markNames.any((el) => el == 'Satisfied' || el == 'Intoxicated')) {
      changeSkillState(false);
      return;
    }

    if (widget.role == 'Mafia' || widget.role == 'Citizen' || widget.role == 'Spy') {
      changeSkillState(false);
      return;
    }

    if (gamePhase == 'Day') {
      if (widget.role != 'Bodyguard') {
        changeSkillState(false);
        return;
      }
    }

    if (gamePhase == 'DayVoting') {
      if (widget.role != 'Terrorist') {
        changeSkillState(false);
        return;
      }
    }

    if (gamePhase == 'Night') {
      if (!['Informant', 'Journalist', 'Doctor', 'Beauty', 'Sheriff'].any((el) => el == widget.role)) {
        changeSkillState(false);
        return;
      }
    }

    if (gamePhase == 'NightVoting') {
      if ('Barman' != widget.role) {
        changeSkillState(false);
        return;
      }
    }

    changeSkillState(true);
  }

  bool checkSecondIfEligibleToUseSkill(InGamePlayer player) {
    if (widget.role == 'Journalist') {
      if (specialForJournalist.any((el) => el == player.nickname)) {
        return false;
      }
    } else {
      if(toWhomIUsedSkill.contains(player.nickname)) {
        return false;
      }
    }

    if (player.isRevealed) {
      return false;
    }
    return true;
  }

  void checkIfEligibleToSendMessage() {
    if (!isAliveMyself) {
      changeSendMessageState(true);
      return;
    }

    if (gamePhase == 'DayVoting' || gamePhase == 'NightVoting') {
      changeSendMessageState(false);
      return;
    }
    else if (gamePhase == 'Day') {
      changeSendMessageState(true);
    }
    else if (gamePhase == 'Night') {
      if (['Mafia', 'Informant'].any((e) => e == widget.role)) {
        changeSendMessageState(true);
      } else {
        changeSendMessageState(false);
      }
    }
  }

  bool checkSecondIfEligibleToVote(InGamePlayer player) {
    if (['Mafia', 'Terrorist'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') {
      return false;
    }

    return true;
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


  String getCardImage(InGamePlayer player) {
    if (player.role == '') {
      return "assets/images/default.png";
    }

    if (!player.isAlive) {
      return 'assets/images/${player.role!.toLowerCase()}-dead.png';
    }

    if (player.nickname == authorizedUser.nickname) {
      return 'assets/images/${player.role!.toLowerCase()}.png';
    }

    if (player.isRevealed) {
      return 'assets/images/${player.role!.toLowerCase()}.png';
    }

    if (widget.role == 'Mafia') {
      if (['Terrorist', 'Mafia'].any((e) => e == player.role)) {
        return 'assets/images/${player.role!.toLowerCase()}.png';
      }
    }

    return "assets/images/default.png";
  }

  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    final double ornamentSize = 35.sp;
    final double ornamentMargin = 10.sp;

    final double height10 = deviceHeight * 0.01;
    final double width10 = deviceWidth * 0.023;

    return !gameIsReady ? const Center(child: CircularProgressIndicator()) :  Stack(
      children: [
      Positioned.fill(
        child: Image.asset(
          ['Day', 'DayVoting'].any((e) => e == gamePhase) ? "assets/images/game-phase-day.png" : "assets/images/game-phase-night.png",
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        /*
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: TextButton(
            onPressed: () {
              setState(() {
                final phases = ['NightVoting', 'Day', 'DayVoting', 'Night'];
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
                  if (markNames.any((e) => e == 'Intoxicated')) {
                    votesAreVisibleToMe = false;
                  }
                  else {
                    votesAreVisibleToMe = true;
                  }
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
                checkIfEligibleToSendMessage();

                inGameMessages.add(InGameMessage(
                  nickname: authorizedUser.nickname,
                  content: 'Phase: $gamePhase',
                  avatarUrl: authorizedUser.avatarUrl,
                  type: 'System'
                ));
              });
            },
            child: Text(widget.title, style: const TextStyle(fontSize: 30, color: Colors.white)))
        ),
        */

        body: LayoutBuilder(
          builder: (context, sizes) {
            if (sizes.maxWidth < 360) {
              return const Spacer();
            } else if (sizes.maxWidth < 600) {
              return Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    SizedBox(height: deviceHeight * 0.07),
                    
                    //? INFO PART
                    Container(
                      width: deviceWidth * 0.88,
                      height: deviceHeight * 0.13,
                      decoration: BoxDecoration(
                        color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFECC5) : const Color(0xFF2C2C2C),
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
                                  "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == gamePhase) ? "day" : "night"}.png",
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
                                    "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == gamePhase) ? "day" : "night"}.png",
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
                                    "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == gamePhase) ? "day" : "night"}.png",
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
                                    "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == gamePhase) ? "day" : "night"}.png",
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
                                children: [
              
                                  //? TITLE
                                  Text(
                                    'Avengers999',
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 24.sp,
                                      color: const Color(0xFFFFB000),
                                      fontWeight: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? FontWeight.w700 : FontWeight.w400,
                                    ),
                                  ),
              
                                  SizedBox(height: deviceHeight * 0.0072),
              
                                  //? PLAYERS INFORMATION
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(width: deviceWidth * 0.03),
                                      //? PLAYERS COUNT INFORMATION
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            children: [
                                              //NOTE: FONT SIZE
                                              Text(
                                                '${inGamePlayers.length} ',
                                                style: TextStyle(
                                                  height: 1,
                                                  color: const Color(0xFFFFB000),
                                                  fontFamily: 'CenturyGothic',
                                                  fontSize: deviceWidth * 0.035
                                                ),
                                              ),
                                              Text(
                                                'Players in the room',
                                                style: TextStyle(
                                                  height: 1,
                                                  color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                                  fontFamily: 'CenturyGothic',
                                                  fontSize: deviceWidth * 0.035
                                                )
                                              ),
                                            ],
                                          ),
              
                                          SizedBox(height: height10 / 2),
              
                                          SizedBox(
                                            width: deviceWidth * 0.416,
                                            height: 5,
                                            child: Divider(
                                              color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                              thickness: 1,
                                            ),
                                          ),
              
                                          SizedBox(height: height10 / 2),
              
                                          Row(
                                            children: [
                                              Text(
                                                'Mafia ',
                                                style: TextStyle(
                                                  height: 1,
                                                  color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                                  fontFamily: 'CenturyGothic',
                                                  fontSize: deviceWidth * 0.035
                                                )
                                              ),
                                              Text(
                                                '$mafiaAlive|${widget.mafiaCount}',
                                                style: TextStyle(
                                                  height: 1,
                                                  color: const Color(0xFFFFB000),
                                                  fontFamily: 'CenturyGothic',
                                                  fontSize: deviceWidth * 0.035
                                                ),
                                              ),
                                              SizedBox(width: width10),
                                              Text(
                                                'Civilian ',
                                                style: TextStyle(
                                                  height: 1,
                                                  color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                                  fontFamily: 'CenturyGothic',
                                                  fontSize: deviceWidth * 0.035
                                                )
                                              ),
                                              Text(
                                                '$citizenAlive|${widget.citizenCount}',
                                                style: TextStyle(
                                                  height: 1,
                                                  color: const Color(0xFFFFB000),
                                                  fontFamily: 'CenturyGothic',
                                                  fontSize: deviceWidth * 0.035
                                                ),
                                              ),
                                            ],
                                          ),
              
                                        ],
                                      ),
                                    
                                      SizedBox(width: deviceWidth * 0.08),
              
                                      //? AFFECTED BY 
                                      SizedBox(
                                        width: deviceWidth * 0.25,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              'assets/images/roles-sheriff-icon-small.png',
                                              fit: BoxFit.scaleDown,
                                              width: deviceWidth * 0.05,
                                              height: deviceHeight * 0.03,
                                            ),
                                            SizedBox(width: deviceWidth * 0.007),
                                            Image.asset(
                                              'assets/images/roles-sheriff-icon-small.png',
                                              fit: BoxFit.scaleDown,
                                              width: deviceWidth * 0.05,
                                              height: deviceHeight * 0.03,
                                            ),
                                            SizedBox(width: deviceWidth * 0.007),
                                            Image.asset(
                                              'assets/images/roles-sheriff-icon-small.png',
                                              fit: BoxFit.scaleDown,
                                              width: deviceWidth * 0.05,
                                              height: deviceHeight * 0.03,
                                            ),
                                          ],
                                        ),
                                      ),
              
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
              
                    SizedBox(height: 10.w),
                    
                    //? DAY AND NIGHT PART
                    Container(
                      width: deviceWidth * 0.88,
                      height: deviceHeight * 0.037,
                      decoration: BoxDecoration(
                        color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFECC5) : const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          
                          //? DAY COUNT
                          Container(
                            margin: EdgeInsets.only(left: 15.w),
                            child: Text(
                              'Day 1',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                fontFamily: 'CenturyGothic',
                              ),
                            ),
                          ),
              
                          //? ICONS +
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    gamePhase = 'Day';
                                  });
                                },
                                //NOTE: FONT SIZE
                                child: Icon(
                                  Icons.sunny,
                                  color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFB000) : Colors.black,
                                  size: 25.sp,
                                ),
                              ),
              
                              SizedBox(width: width10),
              
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    gamePhase = 'Night';
                                  });
                                },
                                //NOTE: FONT SIZE
                                child: Icon(
                                  Icons.nights_stay,
                                  color: !['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFB000) : Colors.black,
                                  size: 20.sp,
                                ),
                              )
                            ],
                          ),
              
                          //? TIMER
                          Container(
                            margin: EdgeInsets.only(right: 15.w),
                            //NOTE: FONT SIZE
                            child: Text(
                              '1:56',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                fontFamily: 'CenturyGothic',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
              
                    SizedBox(height: height10),
              
                    //? PLAYERS PART AND ROLE CARD +
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //? PLAYERS +
                        Container(
                          width: deviceWidth * 0.59,
                          height: deviceHeight * 0.23,
                          padding: const EdgeInsets.only(top: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 cards per row
                              childAspectRatio: 0.8, // Adjust aspect ratio to fit card height
                              crossAxisSpacing: 0, // Spacing between columns
                              mainAxisSpacing: 0, // Spacing between rows
                            ),
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/roles-noname-icon.png',
                                    width: 54.w,
                                    height: 72.h,
                                  ),
                                  Text(
                                    players[index].nickname,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: 'CenturyGothic',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        SizedBox(width: 10.w),
              
                        //? ROLE CARD +
                        Container(
                          width: deviceWidth * 0.25,
                          height: deviceHeight * 0.23,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.role,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 19.sp,
                                  color: const Color(0xFFFFB000),
                                  fontWeight: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                              Text(
                                'is your destiny', // NOTE:    Translation L10
                                style: TextStyle(
                                  height: 1,
                                  fontSize: 14.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400
                                ),
                              ),
              
                              SizedBox(height: 10.h),
              
                              Image.asset(
                                // getCardImage(InGamePlayer(
                                //   nickname: authorizedUser.nickname,
                                //   isAlive: isAliveMyself,
                                //   isRevealed: false,
                                //   role: widget.role,
                                //   avatarUrl: authorizedUser.avatarUrl
                                // )),
                                'assets/images/resident-icon.png',
                                fit: BoxFit.scaleDown,
                                width: deviceWidth * 0.174,
                                height: deviceHeight * 0.106,
                              ),
              
                              SizedBox(height: 10.h),
              
                              // BUTTON:    Use Skill or Vote
                              Center(
                                child: Container(
                                  padding: EdgeInsets.all(3.sp),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(34.0),
                                  ),
                                  child: SizedBox(
                                    width: deviceWidth * 0.255,
                                    height: deviceHeight * 0.04,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // !!!!!!!!!!!!
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: VotePopup(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFFFB000),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(34.0),
                                          side: const BorderSide(
                                            color: Colors.white,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
              
                                      child: Text(
                                        'Use Skill', // NOTE:    Translation L10
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.white,
                                        ),
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
                  
                    SizedBox(height: height10),
              
                    //? MESSAGES PART
                    Container(
                      width: deviceWidth * 0.87,
                      height: deviceHeight * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFECC5) : const Color(0xFF1E1E1E),
                            border: Border.all(
                              color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: InGameChatBox(messages: inGameMessages, scrollController: _scrollController, messageController: _messageController, scrollToBottom: _scrollToBottom, isAlive: isAliveMyself, gamePhase: gamePhase,)
                        ),
                      ),
                    ),
              
                    SizedBox(height: height10),
              
                    //? INPUT PART
                    Container(
                      width: deviceWidth * 0.87,
                      height: deviceHeight * 0.067,
                      decoration: BoxDecoration(
                        color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black.withOpacity(0.4) : const Color(0xFF2B2B2B),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Row(
                        children: [
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
                          SizedBox(
                            width: deviceWidth * 0.75,
                            height: deviceHeight * 0.06,
                            child: EnterMessage(messageController: _messageController, sendMessage: _sendMessage, canISendMessage: canISendMessage, gamePhase: gamePhase,)
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              
              );
            } else {
              return const Spacer();
            }
          }
        ),
        
        /*
        body: Container(
          margin: EdgeInsets.only(bottom: deviceHeight * 0.005),
          color: Colors.transparent,
          child: Column(
            children: [
      
              //NOTE:    FOR TESTING
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, left: 5),
                    width: 100,
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
                        // setState(() {
                        //   inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player1').isAlive = false;
                        //   inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player1').role = 'Terrorist';
                        //   namesOfDead.add(PlayerRole(nickname: 'Player1', role: 'Terrorist'));
                        //   printInGamePlayers();
                        // });
      
                        // setState(() {
                        //   votesOnMe += 1;
                        // });
      
                        if (!markNames.any((e) => e == 'Intoxicated')) {
                          setState(() {
                            markNames.add('Intoxicated');
                            //!!!!!!!!!!!!!!
                            //intoxicationEffect();
                          });
                        }
                      },
                      child: const Text('ACTION'),
                    ),
                  ),
      
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (markNames.any((e) => e == 'Intoxicated')) {
                          setState(() {
                            //!!!!!!!!!!!!!!
                            markNames.remove('Intoxicated');
                            //intoxicationEffect();
                          });
                        }
                      }, 
                      child: const Text('DEL')
                    ),
                  ),
      
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 5),
                    width: 100,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        // NOTE:    Event: Phase
                        setState(() {
                          final phases = ['NightVoting', 'Day', 'DayVoting', 'Night'];
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
                            if (markNames.any((e) => e == 'Intoxicated')) {
                              votesAreVisibleToMe = false;
                            }
                            else {
                              votesAreVisibleToMe = true;
                            }
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
                          checkIfEligibleToSendMessage();
      
                          inGameMessages.add(InGameMessage(
                            nickname: authorizedUser.nickname,
                            content: 'Phase: $gamePhase',
                            avatarUrl: authorizedUser.avatarUrl,
                            isSystemMessage: true
                          ));
                        });
                      },
                      child: const Text('PHASE'),
                    ),
                  ),
                ],
              ),
              */
              
              Container(
                height: deviceHeight * 0.75,
                width: deviceWidth,
                margin: const EdgeInsets.all(4.0),
                
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //?    INFO PART
                    Container(
                      width: deviceWidth * 0.979,
                      height: deviceHeight * 0.14,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
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
                              // votesOnMe != 0 
                              //   ? Text('$votesOnMe', style: const TextStyle(fontSize: 14, color: Colors.red)) 
                              //   : const SizedBox(height: 0.1, width: 0.1),
                              
                              
                              //? ROLE
                              Container(
                                margin: const EdgeInsets.only(left: 5),
                                child: Row(
                                  children: [
                                    
                                    //? ROLE
                                    Column(
                                      children: [
                                
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                                                    
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Stack(
                                                children: [
                                                  Image.asset(
                                                    getCardImage(InGamePlayer(
                                                      nickname: authorizedUser.nickname,
                                                      isAlive: isAliveMyself,
                                                      isRevealed: false,
                                                      role: widget.role,
                                                    )),
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                  ),
                                                  Container(
                                                    height: 80,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.3),
                                                          blurRadius: 5,
                                                          offset: const Offset(0, 3),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                                                    
                                            if (votesOnMe > 0)
                                              Positioned(
                                                top: 10,
                                                right: 10,
                                                child: Container(
                                                  padding: const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    "$votesOnMe",
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            
                                          ],
                                        ),
                                
                                        Text(widget.role, style: const TextStyle(fontSize: 18)),
                                      ],
                                    ),
                                
                                    Column(
                                      children: [
                                        SizedBox(
                                          width: 150,
                                          child: Text(
                                            //? MARKED ROLES
                                            markNames.isNotEmpty ? markNames.join(", ") : '', 
                                            style: const TextStyle(fontSize: 14, color: Colors.amber),
                                          )
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              )

                              


                              // SizedBox(
                              //   width: 150,
                              //   child: Text(
                              //     //? MARKED ROLES
                              //     markNames.isNotEmpty ? markNames.join(", ") : '', 
                              //     style: const TextStyle(fontSize: 14, color: Colors.amber),
                              //   )
                              // )
                            ],
                          ),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 7, right: 10),
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
            
                    //? PLAYERS AND CHAT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        //?    CHAT PART
                        Container(
                          width: deviceWidth * 0.663,
                          height: deviceHeight * 0.6025,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: InGameChatBox(messages: inGameMessages, scrollController: _scrollController, messageController: _messageController, scrollToBottom: _scrollToBottom, isAlive: isAliveMyself,),
                        ),

                        //?    PLAYERS PART
                        Container(
                          width: deviceWidth * 0.3,
                          height: deviceHeight * 0.6025,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              // crossAxisCount: 2,
                              // crossAxisSpacing: 7,
                              // mainAxisSpacing: 10,
                              // childAspectRatio: 0.45,
                              crossAxisCount: 2,
                              crossAxisSpacing: 7,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.45,
                            ),
                            itemCount: inGamePlayers.length,
                            itemBuilder: (context, index) {
                              final player = inGamePlayers[index];
                        
                              return Column(
                                children: [
                                  
                                  Expanded(
                                    flex: 3,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (!canIVote || iVoted) {
                                          if (!canIUseSkill || iUsedSkill) {
                                            return;
                                          }
                                        } else {
                                          if (!inGamePlayers.firstWhere((el) => el.nickname == player.nickname).isAlive) {
                                            return;
                                          }
                                          
                                          if (['Mafia', 'Terrorist'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') {
                                            return;
                                          }
                                            
                                          setState(() {
                                            iVoted = true;
                                            //!!!!!!!!!!!!!!
                                            //inGamePlayers.firstWhere((el) => el.nickname == player.nickname).votesOfPlayer!.add(authorizedUser.nickname);
                                            votePlayer(player.nickname);
                                            log('Voted to: ${player.nickname}');
                                          });
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
                                            if (player.isRevealed) {
                                              return;
                                            }
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
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                        
                                          Container(
                                            height: 100,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage(getCardImage(player)),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                          ),
                        
                                          if (player.votesOfPlayer!.isNotEmpty)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  "${player.votesOfPlayer!.length}",
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            
                                          if (canIVote && !iVoted && player.isAlive && checkSecondIfEligibleToVote(player))
                                            const Positioned(
                                              bottom: 10,
                                              left: 10,
                                              child: AnimatedImageButton(
                                                imagePath: 'assets/images/target.png',
                                              ),
                                            ),
                                            
                                          if (canIUseSkill 
                                            && !iUsedSkill 
                                            && player.isAlive
                                            && checkSecondIfEligibleToUseSkill(player)
                                            )
                                            const Positioned(
                                              bottom: 10,
                                              left: 10,
                                              child: AnimatedIconButton(
                                                icon: Icons.star,
                                                color: Colors.blue,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      player.nickname,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: player.isAlive ? Colors.white : Colors.grey,
                                      ),
                                    ),
                                  )
                                ],
                              );
                        
                              /*
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // DEF:    Player Card
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        // NOTE:    IF THE ROLE IS MAFIA IT WILL SHOW OTHER MAFIAS
                                        //DONE
                                        color: 
                                          player.isAlive
                                            ? widget.role == 'Mafia'
                                              ? ['Mafia', 'Terrorist'].any((el) => el == player.role)
                                                ? Colors.purple
                                                : player.isRevealed
                                                  ? Colors.amber
                                                  : Colors.black
                                            : player.isRevealed
                                              ? Colors.amber
                                              : Colors.black
                                          : Colors.red
                                        , borderRadius: BorderRadius.circular(5),
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
                                            ? (widget.role == 'Journalist') 
                                              ? (!specialForJournalist.any((el) => el == player.nickname))
                                                ? Container(
                                                  height: 20,
                                                  width: 40,
                                                  color: Colors.cyan[900],
                                                  child: const Center(child: Text('Use', style: TextStyle(fontSize: 12))),
                                                )
                                                : const SizedBox()
                                              : !inGamePlayers.firstWhere((e) => e.nickname == player.nickname).isRevealed 
                                                ? Container(
                                                    height: 20,
                                                    width: 40,
                                                    color: Colors.cyan[900],
                                                    child: const Center(child: Text('Use', style: TextStyle(fontSize: 12))),
                                                  ) 
                                                : const SizedBox()
                                            : const SizedBox(),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // DEF:    Voting
                                  Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (iVoted) return;
                                          
                                        if (!canIVote) return;
                                          
                                        if (!inGamePlayers.firstWhere((el) => el.nickname == player.nickname).isAlive) {
                                          //changeState1(false);
                                          return;
                                        }
                                        
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
                                  ),
                                ],
                              );
                              */
                            },
                          ),
                        ),
                      ],
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
                    color: Colors.white,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: EnterMessage(messageController: _messageController, sendMessage: _sendMessage, canISendMessage: canISendMessage,)
              )
            ],
          ),
        )
        */
      
      ),
    
    ]);
  }
}


class VotePopup extends StatefulWidget {
  final int timerSeconds;

  const VotePopup({
    super.key, required this.timerSeconds
  });
  
  @override
  State<VotePopup> createState() => _VotePopupState();
}

class _VotePopupState extends State<VotePopup> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}




class AnimatedIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;

  const AnimatedIconButton({super.key, required this.icon, required this.color});

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.3).animate(_controller),
      child: Icon(widget.icon, color: widget.color, size: 30),
    );
  }
}

class AnimatedImageButton extends StatefulWidget {
  final String imagePath;

  const AnimatedImageButton({super.key, required this.imagePath});

  @override
  State<AnimatedImageButton> createState() => _AnimatedImageButtonState();
}

class _AnimatedImageButtonState extends State<AnimatedImageButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.3).animate(_controller),
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.imagePath),
            fit: BoxFit.cover,
          ),
        ),
      )
    );
  }
}

class PlayersFromAfk {
  final String nickname;
  bool isAlive;
  String? role;
  String? avatarUrl;
  bool? isMarked;

  PlayersFromAfk({
    required this.nickname, 
    required this.isAlive, 
    required this.role,
    required this.avatarUrl,
    required this.isMarked
  });

  factory PlayersFromAfk.fromJson(Map<String, dynamic> json) {

    return PlayersFromAfk(
      nickname: json['nickname'],
      isAlive: json['isAlive'],    
      role: json['role'],    
      avatarUrl: json['avatarUrl'], 
      isMarked: json['isMarked'],
    );
  }
}

class Vote {
  final String from;
  final String target;

  Vote({required this.from, required this.target});

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      from: json['from'] ?? '',
      target: json['target'] ?? '',
    );
  }
}