// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/game/models/in_game_player.dart';
import 'package:mafia_classic/features/games/games.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/widgets/widgets.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:signalr_netcore/signalr_client.dart';

class GameScreen extends StatefulWidget {
  final String title;
  String role;
  int mafiaCount;
  int citizenCount;
  final List<PlayerRole>? playersRole;
  final List<Player> allPlayers;

  final bool cameBackFromAfk;

  GameScreen({
    super.key, 
    required this.title, 
    required this.playersRole, 
    required this.role, 
    required this.mafiaCount, 
    required this.citizenCount, 
    required this.allPlayers, 
    required this.cameBackFromAfk
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String gamePhase = 'Night'; // +
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

    //!!!!!!!!!!!!!!
    var apiService = GetIt.I<ApiService>();

    //printInGamePlayers();
    //toWhomIUsedSkill.add('Player7');
    // for (var e in inGamePlayers) {
    //   e.isAlive = false;
    // }

    //!!!!!!!!!!!!
    if (!apiService.gameHubIsConnected) {
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
            log('pox mashini 2');


            inGameMessages = messages;
            log('pox mashini 3');

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
            log('PLAYER DEAD:    playerDead.nickname == authorizedUser.nickname: ${playerDead.nickname == authorizedUser.nickname}');
            youAreDead();
            isAliveMyself = false;
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
          print("Connected to SignalR!");
        }).catchError((e) {
          print("Connection error: $e");
        });
      });
    }

    //await GetIt.I<ApiService>().gameHubConnection.invoke("TriggerPhaseEvent", args: <Object>[]);
    
  }

  @override
  void dispose() {
    _intoxicationTimer?.cancel();
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

    return Stack(
      children: [
      Positioned.fill(
        child: Image.asset(
          ['Day', 'DayVoting'].any((e) => e == gamePhase) ? "assets/images/day-phase.png" : "assets/images/night-phase.png",
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
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
                          child: InGameChatBox(messages: inGameMessages, scrollController: _scrollController, messageController: _messageController, scrollToBottom: _scrollToBottom,),
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
      
      ),
    
    ]);
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