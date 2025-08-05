// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
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
import 'package:mafia_classic/features/profile/roles/widgets/role_card.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/main.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:signalr_netcore/signalr_client.dart';

Map<String, BuildContext> popupContexts = {};

class GameScreen extends StatefulWidget {
  final String title;
  String role;
  int mafiaCount;
  int civilianCount;
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
    required this.civilianCount, 
    required this.allPlayers, 
    required this.cameBackFromAfk,
    required this.gameIsReadyWidget
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  String gamePhase = 'Night'; // +
  int dayNumber = 0;
  int mafiaAlive = 0; // +
  int civilianAlive = 0; // +
  ValueNotifier<List<InGamePlayer>> inGamePlayers = ValueNotifier<List<InGamePlayer>>([]); // +

  List<String> markNames = []; // + //!
  bool isAliveMyself = true; // +
  bool canISendMessage = true;
  int votesOnMe = 0; // +

  // DEF:    VOTE VARIABLES
  bool canIVote = false;
  bool iVoted = false;
  bool votesAreVisibleToMe = false;
  bool canNightVote = false; // NOTE: Informant

  // DEF:    SKILLS VARIABLES
  bool canIUseSkill = false;
  bool iUsedSkill = false;

  List<String> toWhomIUsedSkill = []; // +
  List<String> specialForJournalist = []; // +

  List<PlayerRole> namesOfRevealed = []; // +
  List<PlayerRole> namesOfDead = []; // +

  int index = 0;
  ValueNotifier<int> phaseTimeNotifier = ValueNotifier<int>(150);
  Timer? _intoxicationTimer;

  bool gameIsReady = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    //!!!!!!!!!!!!!!!!!!
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

    if (!inGamePlayers.value.firstWhere((el) => el.nickname == votedPlayerNickname).isAlive) return;

    if (markNames.any((el) => el == 'Satisfied')) return;

    if (widget.role == 'Terrorist') return;

    if (gamePhase == 'Day') {
      return;
    }
    else if (gamePhase == 'Night') {
      if ('Mafia' != widget.role) {
        if ((widget.role.toLowerCase() == 'informant') && canNightVote) {
          
        } else {
          return;
        }
      }
    }

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    try {
      await GetIt.I<ApiService>().gameHubConnection.invoke('Vote', args: <Object>[
        votedPlayerNickname
      ]).then((value) => log('vote playeer method suucesfully'));
    } on Exception catch (e) {
      log('Vote Player: $e');
    }
  }
  
  void useSkill(List<String> influencedBySkillPlayersNickname, bool state) async {
    if (!isAliveMyself) return;

    if (markNames.any((el) => el == 'Satisfied')) return;

    if (iUsedSkill) return;

    for (var element in influencedBySkillPlayersNickname) { //!
      if (!inGamePlayers.value.firstWhere((el) => el.nickname == element).isAlive) return; 
    }

    // NOTE:    CHECKING ROLES

    if (widget.role == 'Mafia' || widget.role == 'Civilian' || widget.role == 'Spy') {
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
  
    for (var nickname in influencedBySkillPlayersNickname) {
      if (['journalist', 'sheriff', 'informant'].any((e) => e == widget.role.toLowerCase())) {
        toWhomIUsedSkill.add(nickname);
      }
    }

    setState(() {
      iUsedSkill = state;
    });
    

    //!!!!!!!!!!!!!!!
    await GetIt.I<ApiService>().gameHubConnection.invoke('Skill', args:
      [influencedBySkillPlayersNickname]
    );
  }

  // NOTE:    TESTING
  void printInGamePlayers() {
    print('------------------------');
    for (var el in inGamePlayers.value) {
      print('Name: ${el.nickname}  |  Role: ${el.role}  |  IsAlive: ${el.isAlive}  |  IsRevealed: ${el.isRevealed}  |  AvatarUrl: ${el.avatarUrl?.substring(0, 10)}');
    }
  }

  @override
  void initState() {
    super.initState();

    mafiaAlive = widget.mafiaCount;
    civilianAlive = widget.civilianCount;
    gameIsReady = widget.gameIsReadyWidget;

    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Map<String, String> roleMap = {};
    // if (widget.playersRole != null) {
    //   for (var element in widget.playersRole!) {
    //   roleMap[element.nickname] = element.role;
    //   }
    // }

    // for (var player in widget.allPlayers) {
    //   if (player.nickname == authorizedUser.nickname) continue;
    //   inGamePlayers.value.add(InGamePlayer(
    //   nickname: player.nickname,
    //   isAlive: true,
    //   isRevealed: false,
    //   role: roleMap[player.nickname] ?? 'undef',
    //   avatarUrl: player.avatarUrl,
    //   votesOfPlayer: [],
    //   ));
    // }

    //inGamePlayers.value.firstWhere((el) => el.nickname == 'Player2' || el.nickname == 'Player4').isAlive = false;

    
    // !!!!!!!!!!!!!!!!!!!
    

    //!!!!!!!!!!!!!!
    //checkIfEligibleToUseSkill();
    
    
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
          final civilianCount = data['civilianCount'] as int;
          log('05');
          final aliveMafiaCount = data['aliveMafiaCount'] as int;
          log('06');
          final aliveCivilianCount = data['aliveCivilianCount'] as int;
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
            widget.civilianCount = civilianCount;
            mafiaAlive = aliveMafiaCount;
            civilianAlive = aliveCivilianCount;
            
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

              inGamePlayers.value.add(
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
        inGamePlayers.value.add(InGamePlayer(
          nickname: item.nickname,
          isAlive: true,
          isRevealed: roleMap[item.nickname] == null ? false : true,
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

    //printInGamePlayers();
 
    
    // DONE
    apiService.gameHubConnection.on('Phase', (List<Object?>? parameters) {
      //log('-------------------- PHASE EVENT --------------------: ${DateTime.now().toIso8601String()}');
      try {
        //print('-------------------- PHASE EVENT: TRY CATCH --------------------: ${DateTime.now().toIso8601String()}');
        if (parameters == null || parameters.isEmpty) return; 
        
        //log(parameters.first as String);
        final String phase = parameters.first as String;
        
        setState(() {
          if (inGamePlayers.value[0].nickname == authorizedUser.nickname) {
            inGamePlayers.value.removeAt(0);
          }

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
        
          for (var element in inGamePlayers.value) {
            element.votesOfPlayer = [];
          }
        
          iVoted = false;
          
          checkIfEligibleToVote();
        
          iUsedSkill = false;
          //toWhomIUsedSkill = [];
        
          checkIfEligibleToUseSkill();
          checkIfEligibleToSendMessage();

          Map<String, String> phaseMessages = {
            'Day': 'The silence of night is over. Now speak.',
            'DayVoting': 'Choose the imposter of the day',
            'Night': 'The night begins. All must rest in silence',
            'NightVoting': 'The Mafia cast their deadly vote.'
          };
        
          inGameMessages.add(InGameMessage(
            nickname: authorizedUser.nickname,
            content: phaseMessages[phase] ?? '',
            avatarUrl: authorizedUser.avatarUrl,
            type: 'System'
          ));

          if (gamePhase == 'Day') {
            dayNumber += 1;
          }

          if ((gamePhase == 'NightVoting' && (widget.role == 'Mafia' || canNightVote)) || gamePhase == 'DayVoting') {
            inGamePlayers.value.insert(0, InGamePlayer(
              nickname: authorizedUser.nickname,
              isAlive: isAliveMyself,
              isRevealed: true,
              role: widget.role.toLowerCase(),
              avatarUrl: authorizedUser.avatarUrl,
              votesOfPlayer: []
            ));
            /*
            showGeneralDialog(
              context: context,
              barrierDismissible: false,
              barrierLabel: "Dismiss",
              barrierColor: Colors.black.withOpacity(0.7),
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) {
                return Builder(
                  builder: (innerContext) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      popupContexts['votePopupId'] = innerContext;
                    });
                    return VotePopup(
                      role: widget.role,
                      canIVote: canIVote,
                      useSkill: useSkill,
                      dayCount: dayNumber,
                      title: widget.title,
                      gamePhase: gamePhase,
                      markNames: markNames,
                      votePlayer: votePlayer,
                      canNightVote: canNightVote,
                      isAliveMyself: isAliveMyself,
                      inGamePlayers: inGamePlayers,
                      changeVoteState: changeVoteState,
                      timerNotifier: phaseTimeNotifier,
                      aliveCount: mafiaAlive + civilianAlive,
                      votesAreVisibleToMe: votesAreVisibleToMe,
                      checkSecondIfEligibleToVote: checkSecondIfEligibleToVote,
                    );
                  }
                );
              },
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                  reverseCurve: Curves.easeInBack,
                );

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              },
            ).then((value) {
              popupContexts.remove('votePopupId');
            });
            */
            
            PopupManager().show(
              context: context,
              id: 'votePopup',
              builder: (_) => VotePopup(
                role: widget.role,
                  canIVote: canIVote,
                  useSkill: useSkill,
                  dayCount: dayNumber,
                  title: widget.title,
                  gamePhase: gamePhase,
                  markNames: markNames,
                  votePlayer: votePlayer,
                  canNightVote: canNightVote,
                  isAliveMyself: isAliveMyself,
                  inGamePlayers: inGamePlayers,
                  changeVoteState: changeVoteState,
                  timerNotifier: phaseTimeNotifier,
                  aliveCount: mafiaAlive + civilianAlive,
                  votesAreVisibleToMe: votesAreVisibleToMe,
                  checkSecondIfEligibleToVote: checkSecondIfEligibleToVote,
              ),
            );
          }
          //log('game phase: $gamePhase');
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     PHASE EVENT - GAME SCREEN: ${e.toString()}');
      }
      //log('---------------------------------------');
    });

    // DONE
    apiService.gameHubConnection.on('Mark', (List<Object?>? parameters) {
      try {
        if (parameters == null || parameters.isEmpty) return;
        
        final String mark = parameters.first as String;
        
        //!!!!!!!!!!
        setState(() {
          markNames.add(mark);
          //markNames.add('sheriff');
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
          //markNames.remove('sheriff');
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
          inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == player.nickname).isRevealed = true;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == player.nickname).role = player.role.toLowerCase();
          namesOfRevealed.add(PlayerRole(nickname: player.nickname, role: player.role.toLowerCase()));
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
              civilianAlive -= 1;
            }
            isAliveMyself = false;
            checkIfEligibleToSendMessage();
            return;
          }
        
          inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).isAlive = false;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).role = playerDead.role;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).isRevealed = true;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == playerDead.nickname).votesOfPlayer = [];
          inGamePlayers.notifyListeners();
          namesOfDead.add(PlayerRole(nickname: playerDead.nickname, role: playerDead.role));
        
          if (['Mafia', 'Terrorist', 'Barman', 'Informant'].any((s) => s == playerDead.role)) {
            mafiaAlive -= 1;
          } else {
            civilianAlive -= 1;
          }
          
        });
        
        //printInGamePlayers();
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
        
        //print(parameters.first);
        var data = json.decode(parameters.first as String);
        
        final String nickname = data['nickname'];
        final String type = data['type'];
        final String content = data['content'];
        String avatarUrl = "https://i.pinimg.com/736x/97/53/2c/97532cc6bf6af4ef60ef08fb5ebc5abc.jpg";
        if (type != 'System' && nickname != 'Informant') {
          inGamePlayers.value.firstWhere((pl) => pl.nickname == nickname).avatarUrl;
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
          inGamePlayers.value.firstWhere((el) => el.nickname == target).votesOfPlayer!.add(from);
          inGamePlayers.notifyListeners();
          //print('Voted: $from -> $target');
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
          phaseTimeNotifier.value = parameters.first as int;
          //print(phaseTimeNotifier.value);
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     TIMER EVENT - GAME SCREEN: ${e.toString()}');
      }
    });

    // INCOMPLETE
    apiService.gameHubConnection.on('CanNightVote', (List<Object?>? parameters) {
      try {
        setState(() {
          canNightVote = true;
          log('CAN NIGHT VOTE METHOD: ${DateTime.now().toIso8601String()}');
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
    
    //await GetIt.I<ApiService>().gameHubConnection.invoke("TriggerPhaseEvent", args: <Object>[]);
  }

  @override
  void dispose() {
    _intoxicationTimer?.cancel();
    print("Disonnected to SignalR! 600 games screen");
    GetIt.I<ApiService>().disconnectGameHub();
    GetIt.I<ApiService>().gameHubIsConnected = false;
    _controller.dispose();
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

    if (widget.role == 'Mafia' || widget.role == 'Civilian' || widget.role == 'Spy') {
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
    
    PopupManager().show(
      context: context,
      id: 'deadPopup',
      builder: (_) =>
        AlertDialog(
          title: const Text("You Died!"),
          content: const Text("You have been eliminated from the game."),
          actions: [
            TextButton(
              onPressed: () {
                PopupManager().close('deadPopup');
              },
              child: const Text("Close"),
            ),
          ],
        )
    );
    
    /*
    showGeneralDialog(
      context: context,
      pageBuilder: (context, anim1, anim2) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          popupContexts['deadPopup'] = context;
        });
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
    ).then((value) {
      popupContexts.remove('deadPopup');
    });
    */
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

    return !gameIsReady ? const Center(child: CircularProgressIndicator()) : Stack(
      children: [
      Positioned.fill(
        child: Image.asset(
          ['Day', 'DayVoting'].any((e) => e == gamePhase) ? "assets/images/game-phase-day.png" : "assets/images/game-phase-night.png",
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        resizeToAvoidBottomInset: true,
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

        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, sizes) {
                if (sizes.maxWidth < 360) {
                  return const Spacer();
                } else if (sizes.maxWidth < 600) {
                  int playersCount = widget.civilianCount + widget.mafiaCount;
                  return SingleChildScrollView(
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          SizedBox(height: deviceHeight * 0.06),
                          
                          //? INFO PART
                          //!!!!!!!!!!!!!!!!
                          //DONE:    DYNAMIC
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
                                          widget.title,
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
                                                      '$playersCount ',
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
                                                      '$civilianAlive|${widget.civilianCount}',
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
                                          
                                            SizedBox(width: deviceWidth * 0.05),
                    
                                            //? AFFECTED BY 
                                            //!!!!!!!!!!!!!!
                                            FadeTransition(
                                              opacity: _fadeAnimation,
                                              child: Container(
                                                width: deviceWidth * 0.23,
                                                height: deviceHeight * 0.05,
                                                margin: EdgeInsets.only(right: 20.w),
                                                child: ListView.builder(
                                                  itemCount: markNames.isEmpty ? 0 : markNames.length,
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (context, index) {
                                                    return Row(
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.only(right: 2.w),
                                                          child: RoleCard(
                                                            roleName: markNames[index], 
                                                            width: deviceWidth * 0.05, 
                                                            height: deviceHeight * 0.03, 
                                                            isMini: true
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  }
                                                ),
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
                          //DONE:    DYNAMIC
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
                                    (dayNumber == 0) ? 'Day' : 'Day $dayNumber',
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
                                    //? DAY
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
                    
                                    SizedBox(width: 8.w),
                    
                                    //? NIGHT
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
                                    ),
                                
                                    SizedBox(width: 8.w),
                                
                                    //! CHANGE
                                    
                                    /*
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          markNames.add('Intoxicated');
                                          markNames.add('Satisfied');
                                          markNames.add('Cured');
                                          markNames.add('Protected');
                                          markNames.add('Investigated');
                                          markNames.add('Revealed');
                                          markNames.add('Interviewed');
                                          //'Intoxicated', 'Satisfied', 'Cured', 'Protected', 'Investigated', 'Revealed', 'Interviewed'
                                          /*
                                          final phases = ['NightVoting', 'Day', 'DayVoting', 'Night'];
                                          gamePhase = phases[index];
                                          index += 1;
                                          if (index > 3) {
                                            index = 0;
                                          }
                                          if (gamePhase == 'Day') {
                                            dayNumber += 1;
                                          }
                                          print('phase: $gamePhase');
                    
                                          iUsedSkill = false;
                                          checkIfEligibleToUseSkill();
                                          //inGamePlayers.value[2].isAlive = false;
                                          inGamePlayers.value[2].votesOfPlayer!.add('Player5');
                                
                                          if ((gamePhase == 'NightVoting' && widget.role == 'Mafia') || gamePhase == 'DayVoting') {
                                            showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: "Dismiss",
                                              barrierColor: Colors.black.withOpacity(0.7),
                                              transitionDuration: const Duration(milliseconds: 800),
                                              pageBuilder: (context, animation, secondaryAnimation) {
                                                return VotePopup(
                                                  title: widget.title,
                                                  timerNotifier: phaseTimeNotifier,
                                                  canIVote: canIVote,
                                                  inGamePlayers: inGamePlayers,
                                                  votesAreVisibleToMe: votesAreVisibleToMe,
                                                  changeVoteState: changeVoteState,
                                                  checkSecondIfEligibleToVote: checkSecondIfEligibleToVote,
                                                  gamePhase: gamePhase,
                                                  aliveCount: mafiaAlive + citizenAlive,
                                                  isAliveMyself: isAliveMyself,
                                                  markNames: markNames,
                                                  role: widget.role,
                                                  votePlayer: votePlayer,
                                                  dayCount: dayNumber,
                                                );
                                              },
                                              transitionBuilder: (context, animation, secondaryAnimation, child) {
                                                final curvedAnimation = CurvedAnimation(
                                                  parent: animation,
                                                  curve: Curves.elasticOut,
                                                  reverseCurve: Curves.easeInBack,
                                                );
                                
                                                return SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin: const Offset(-1.0, 0.0),
                                                    end: Offset.zero,
                                                  ).animate(curvedAnimation),
                                                  child: child,
                                                );
                                              },
                                            );
                                          }
                                          */
                                        });
                                      },
                                      
                                      child: Icon(
                                        Icons.warning,
                                        color: Colors.green,
                                        size: 20.sp,
                                      ),
                                    ),
                                    */
                                  ],
                                ),
                    
                                //? TIMER
                                Container(
                                  margin: EdgeInsets.only(right: 15.w),
                                  //NOTE: FONT SIZE
                                  child: Text(
                                    '${phaseTimeNotifier.value ~/ 60}:${(phaseTimeNotifier.value - phaseTimeNotifier.value ~/ 60 * 60).toString().padLeft(2, '0')}',
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
                                    crossAxisCount: 3,
                                    childAspectRatio: 0.67,
                                    crossAxisSpacing: 0,
                                    mainAxisSpacing: 0,
                                  ),
                                  itemCount: inGamePlayers.value.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Opacity(
                                          opacity: inGamePlayers.value[index].isAlive ? 1.0 : 0.5,
                                          child: Image.asset(
                                            inGamePlayers.value[index].isRevealed || !inGamePlayers.value[index].isAlive ? 'assets/images/role-card-${inGamePlayers.value[index].role!.toLowerCase()}.png' : 'assets/images/role-card-noname.png',
                                            width: 54.w,
                                            height: 72.h,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: 2.h),
                                          width: 70.w,
                                          height: 40.h,
                                          child: Text(
                                            inGamePlayers.value[index].nickname,
                                            textAlign: TextAlign.center,
                                            softWrap: true,
                                            maxLines: 2,
                                            style: TextStyle(
                                              height: 0,
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                            ),
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
                                    //? ROLE
                                    Text(
                                      widget.role,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 19.sp,
                                        color: const Color(0xFFFFB000),
                                        fontWeight: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? FontWeight.w700 : FontWeight.w400,
                                      ),
                                    ),
                                    
                                    //? TEXT:    is your destiny
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
                    
                                    //? ROLE CARD IMAGE
                                    RoleCard(
                                      roleName: widget.role.toLowerCase(), 
                                      width: deviceWidth * 0.174, 
                                      height: deviceHeight * 0.106,
                                      isMini: false
                                    ),
                    
                                    SizedBox(height: 10.h),
                    
                                    // BUTTON:    USE SKILL
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.all(3.sp),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: canIUseSkill ? 1.5 : 0,
                                          ),
                                          borderRadius: BorderRadius.circular(34.0),
                                        ),
                                        child: SizedBox(
                                          width: deviceWidth * 0.255,
                                          height: deviceHeight * 0.04,
                                          child: ElevatedButton(
                                            
                                            onPressed: () {
                                              // !!!!!!!!!!!!
                    
                                              
                                              //checkSecondIfEligibleToVote(inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == authorizedUser.nickname));
                                              
                                              if (canIUseSkill == false) {
                                                return;
                                              }
                                              
                                              showGeneralDialog(
                                                context: context,
                                                barrierDismissible: true,
                                                barrierLabel: "Dismiss",
                                                barrierColor: Colors.black.withOpacity(0.7),
                                                transitionDuration: const Duration(milliseconds: 800),
                                                pageBuilder: (context, animation, secondaryAnimation) {
                                                  return SkillPopup(
                                                    role: widget.role,
                                                    useSkill: useSkill,
                                                    title: widget.title,
                                                    gamePhase: gamePhase,
                                                    iUsedSkill: iUsedSkill,
                                                    canIUseSkill: canIUseSkill,
                                                    aliveMafiaCount: mafiaAlive,
                                                    inGamePlayers: inGamePlayers,
                                                    mafiaCount: widget.mafiaCount,
                                                    aliveCivilianCount: civilianAlive,
                                                    timerNotifier: phaseTimeNotifier,
                                                    civilianCount: widget.civilianCount,
                                                    toWhomIUsedSkill: toWhomIUsedSkill,
                                                  );
                                                },
                                                transitionBuilder: (context, animation, secondaryAnimation, child) {
                                                  final curvedAnimation = CurvedAnimation(
                                                    parent: animation,
                                                    curve: Curves.elasticOut,
                                                    reverseCurve: Curves.easeInBack,
                                                  );
                                
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: const Offset(-1.0, 0.0),
                                                      end: Offset.zero,
                                                    ).animate(curvedAnimation),
                                                    child: child,
                                                  );
                                                },
                                              );
                                              
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: canIUseSkill ? const Color(0xFFFFB000) : const Color(0xFF9A9A9A),
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
                    
                    ),
                  );
                } else {
                  return const Spacer();
                }
              }
            ),

            ['Night', 'NightVoting'].any((e) => e == gamePhase) 
            ?
              IgnorePointer(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Colors.transparent
                      ],
                      stops: [0.7, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    "assets/images/night-light.png",
                    fit: BoxFit.cover,
                    height: 300.h,
                    width: deviceWidth + 30.w,
                  ),
                ),
              )
            : 
              const SizedBox()
          ],
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
                                        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
  final String role;
  final bool canIVote;
  final bool votesAreVisibleToMe;
  final void Function(bool newState) changeVoteState;
  final bool Function(InGamePlayer player) checkSecondIfEligibleToVote;

  //! ESSENTIAL VARIABLES
  final int dayCount;
  final String title;
  final int aliveCount;
  final String gamePhase;
  final bool canNightVote;
  final bool isAliveMyself;
  final List<String> markNames;
  final ValueNotifier<int> timerNotifier;
  final ValueNotifier<List<InGamePlayer>> inGamePlayers;
  final void Function(String votedPlayerNickname) votePlayer;
  final void Function(List<String> toWhomIUsedSkill, bool state) useSkill;

  const VotePopup({
    super.key, 
    required this.role, 
    required this.title,
    required this.dayCount, 
    required this.canIVote, 
    required this.useSkill, 
    required this.markNames, 
    required this.gamePhase, 
    required this.aliveCount, 
    required this.votePlayer, 
    required this.timerNotifier, 
    required this.inGamePlayers, 
    required this.isAliveMyself, 
    required this.changeVoteState, 
    required this.votesAreVisibleToMe, 
    required this.checkSecondIfEligibleToVote, 
    required this.canNightVote, 
  });
  
  @override
  State<VotePopup> createState() => _VotePopupState();
}

class _VotePopupState extends State<VotePopup> {
  bool iVotedCompletely = false;
  bool iVotedPartially = false;
  String toWhomIVoted = '';

  bool isPopupClosed = false;

  //ModalRoute? voteRoute;

  // void votePlayer(String votedPlayerNickname) async {
  //   if (!widget.isAliveMyself) return;

  //   if (!widget.inGamePlayers.value.firstWhere((el) => el.nickname == votedPlayerNickname).isAlive) return;

  //   if (widget.markNames.any((el) => el == 'Satisfied')) return;

  //   if (widget.role == 'Terrorist') return;

  //   await GetIt.I<ApiService>().gameHubConnection.invoke('Vote', args: <Object>[
  //     votedPlayerNickname
  //   ]).then((value) => log('vote playeer method suucesfully'));
  // }

  bool checkIfItIsMafiaAndNight(String playerRole, String myRole, String gamePhase) {
    if (gamePhase == 'NightVoting' && myRole.toLowerCase() == 'mafia') {
      if (playerRole == 'Mafia' || playerRole == 'Terrorist') {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool canIVotePopup(InGamePlayer player) {
    if (!widget.isAliveMyself) return false;

    if (widget.inGamePlayers.value[0].nickname == player.nickname) return false;

    if (!player.isAlive) return false;

    if (widget.markNames.contains('Satisfied') || widget.markNames.contains('Intoxicated')) return false;

    if (iVotedCompletely) return false;
    
    if (widget.role.toLowerCase() == 'informant' && widget.canNightVote) return true; 

    if (widget.gamePhase == 'Night' && (player.role == 'Terrorist' || player.role == 'Mafia') && widget.role == 'Mafia') return false;

    if (checkIfItIsMafiaAndNight(player.role!, widget.role, widget.gamePhase)) {
      return false;
    }

    return true;
  }

  bool delayStarted = false;
  
  late BuildContext votePopupContext;

  @override
  void initState() {
    super.initState();
    
    //widget.timerNotifier.addListener(handleTimerChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    //voteRoute ??= ModalRoute.of(context);

    widget.timerNotifier.addListener(() {
      if (!mounted) return;

      if (widget.timerNotifier.value == 1 && !delayStarted) {
        delayStarted = true;

        Future.delayed(const Duration(milliseconds: 700), () {
            if (!mounted) return;
            PopupManager().close('votePopup');
          });

        // Future.delayed(const Duration(milliseconds: 700), () {
        //   if (!mounted) return;

        //   final voteContext = popupContexts['votePopupId'];
        //   if (voteContext != null) {
        //     Navigator.of(voteContext).pop();
        //     popupContexts.remove('votePopupId');
        //   }
        //   if (Navigator.of(context).canPop()) {
        //     Navigator.of(context).pop();
        //   }

        // });

        // Future.delayed(const Duration(milliseconds: 700), () {
        //   if (!mounted) return;
        //   if (Navigator.of(context).canPop()) {
        //     Navigator.of(context).pop();
        //   }
        //   //Navigator.of(context).removeRoute(voteRoute!);
        // });

        // Future.delayed(const Duration(milliseconds: 700), () {
        //   if (votePopupNavigatorKey.currentState?.canPop() ?? false) {
        //     votePopupNavigatorKey.currentState?.pop();
        //   }
        // });
      }
    });
  }

  // void handleTimerChange() {
  //   final time = widget.timerNotifier.value;

  //   if (time == 1 && !isPopupClosed) {
  //     isPopupClosed = true;

  //     if (Navigator.of(context).canPop()) {
  //       Navigator.of(context).pop();
  //     }
  //   }
  // }

  @override
  void dispose() {
    //widget.timerNotifier.removeListener(handleTimerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 50.sp;
    final double ornamentMargin = 5.sp;

    return Builder(
      builder: (context) {
        votePopupContext = context;
        return Align(
          alignment: Alignment.center,
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.91,
              height: MediaQuery.of(context).size.height * 0.75,
              padding: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                    ? [const Color(0xFFFFFBF2), const Color(0xFFF6E0B2)] 
                    : [const Color(0xFF363636), const Color(0xFF000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  //? HEADER
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
        
                        //? DAY COUNT
                        Padding(
                          padding: EdgeInsets.only(left: 5.w, top: 5.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'Day ${widget.dayCount}', 
                                style: GoogleFonts.playfairDisplay(
                                  height: 0,
                                  fontSize: 30.sp, 
                                  color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                    ? Colors.black 
                                    : Colors.white
                                )
                              ),
                            ],
                          ),
                        ),
        
                        //? MAFIAS OR CITIZENS COUNT
                        Padding(
                          padding: EdgeInsets.only(top: 3.h, right: 40.w),
                          child: Column(
                            children: [
                              SizedBox(height: 5.h),
                              Text(
                                '${widget.aliveCount} of ${widget.inGamePlayers.value.length}',
                                style: TextStyle(
                                  height: 0,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                    ? Colors.black 
                                    : Colors.white
                                )
                              ),
                              Text(
                                'civilians are with us', //! DO DYNAMICALLY
                                style: TextStyle(
                                  height: 0,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                    ? Colors.black 
                                    : Colors.white
                                )
                              ),
                            ],
                          ),
                        ),
        
                        //BUTTON:    X
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.h, right: 5.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(
                                  Icons.close, 
                                  color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                    ? Colors.black 
                                    : Colors.white,
                                  size: 35.sp
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                  ),
                  
                  //SizedBox(height: 16.h),
                  
                  //? VOTE LIST
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                            ? const Color(0xFF000000)
                            : const Color(0xFFFFFFFF),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(13.0),
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
                                  "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? "day" : "night"}.png",
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
                                    "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? "day" : "night"}.png",
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
                                    "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? "day" : "night"}.png",
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
                                    "assets/images/game-ornament-${['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? "day" : "night"}.png",
                                    width: ornamentSize,
                                    height: ornamentSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                           
                          //? VOTE LIST VIEW
                          Center(
                            child: Column(
                              children: [
                                SizedBox(height: 10.h),
        
                                //? TITLE
                                Text(
                                  widget.title,
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 32.sp,
                                    color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                      ? Colors.black
                                      : const Color(0xFFFFB000),
                                  ),
                                ),
                                
                                //? TIMER
                                ValueListenableBuilder(
                                  valueListenable: widget.inGamePlayers,
                                  builder: (context, value, child) {
                                    return ValueListenableBuilder(
                                      valueListenable: widget.timerNotifier,
                                      builder: (context, value, child) {
                                        final minutes = value ~/ 60;
                                        final seconds = value % 60;
                                    
                                        // if (value == 1 && !delayStarted) {
                                        //   delayStarted = true;
                                    
                                        //   WidgetsBinding.instance.addPostFrameCallback((_) {
                                        //     Future.delayed(const Duration(milliseconds: 700), () {
                                        //       if (!mounted) return;
                                        //       if (Navigator.of(context).canPop()) {
                                        //         widget.inGamePlayers.value.removeAt(0);
                                        //         Navigator.of(context).pop();
                                        //       }
                                        //     });
                                        //   });
                                        // }
                                    
                                        return Text(
                                          '${['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? 'Time for decision - ' : 'Pick your target - '}$minutes:${seconds.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontFamily: 'CenturyGothic',
                                            color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                              ? const Color(0xFF494239)
                                              : Colors.white
                                          ),
                                        );
                                      }
                                    );
                                  }
                                ),
                                
                                //? VOTE LIST
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 25.w, top: 10.h, bottom: 10.h),
                                    child: ValueListenableBuilder(
                                      valueListenable: widget.inGamePlayers,
                                      builder: (context, value, child) {
                                        return ListView.builder(
                                          padding: EdgeInsets.zero,
                                          itemCount: value.length,
                                          itemBuilder: (context, index) {
                                            final player = value[index];
                                        
                                            bool canExpand = false;
                                            if (player.votesOfPlayer != null && player.votesOfPlayer!.isNotEmpty) {
                                              canExpand = true;
                                            }
                                            //final hasVotes = player["votes"] > 0;
                                            return SizedBox(
                                              width: double.maxFinite,
                                              child: ExpansionTile(
                                                trailing: const SizedBox.shrink(),
                                                enabled: canExpand,
                                                title: Column(
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              // CircleAvatar(
                                                              //   backgroundImage: NetworkImage(player.avatarUrl!), //!!!!!!!!!!!
                                                              //   radius: 15,
                                                              // ),
        
                                                              RoleCard(
                                                                roleName: player.isRevealed ? player.role!.toLowerCase() : 'noname',
                                                                width: 30.w, 
                                                                height: 30.h, 
                                                                isMini: false
                                                              ),
        
                                                              SizedBox(width: 5.w),
        
                                                              // TEXT:    PLAYER NICKNAME
                                                              Text(
                                                                player.nickname, 
                                                                style: TextStyle(
                                                                  fontSize: 15.sp, 
                                                                  color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                                                  ? Colors.black 
                                                                  : Colors.white,
                                                                  fontFamily: 'CenturyGothic'
                                                                )
                                                              ),
                                                            ],
                                                          ),
                                                
                                                          //BUTTON:    VOTE
                                                          Row(
                                                            children: [
                                                              Padding(
                                                                padding: EdgeInsets.only(right: 5.w),
                                                                child: Text(
                                                                  player.votesOfPlayer == null || player.votesOfPlayer!.isEmpty ? '' : 'x${player.votesOfPlayer!.length}', //! DYNAMIC
                                                                  style: TextStyle(
                                                                    fontSize: 15.sp, 
                                                                    color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                                                      ? Colors.black 
                                                                      : Colors.white,
                                                                    fontFamily: 'CenturyGothic'
                                                                  )
                                                                ), 
                                                              ),
                                            
                                                              SizedBox(
                                                                width: 90.w,
                                                                height: 37.h,
                                                                child: ElevatedButton(
                                                                  onPressed: () {
                                                                    setState(() {
                                                                      if (canIVotePopup(player)) {
                                                                        iVotedPartially = true;
                                                                        toWhomIVoted = player.nickname;
                                                                      }
                                                                    });
                                                                    //!
                                                                  },
                                                                  style: ElevatedButton.styleFrom(
                                                                    backgroundColor: canIVotePopup(player) 
                                                                      ? iVotedPartially && !iVotedCompletely && toWhomIVoted == player.nickname
                                                                        ? const Color(0xFFFFB000)
                                                                        : Colors.transparent
                                                                      : toWhomIVoted == player.nickname 
                                                                        ? const Color(0xFFFFB000) 
                                                                        : Colors.transparent, //! DYNAMIC
                                                                    shadowColor: Colors.transparent,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(34.0),
                                                                      side: BorderSide(
                                                                        color: canIVotePopup(player)
                                                                        ? (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white)
                                                                        : (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4)),
                                                                        width: 1,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  
                                                                  child: Text(
                                                                    widget.role.toLowerCase() == 'terrorist' ? 'Bombard' : 'Vote', // NOTE:    Translation L10 
                                                                    //! DYNAMIC
                                                                    style: TextStyle(
                                                                      fontSize: 15.sp,
                                                                      fontFamily: 'CenturyGothic',
                                                                      color: canIVotePopup(player) 
                                                                        ? (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white)
                                                                        : (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4)),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    if (index < players.length - 1)
                                                      Divider(
                                                        height: 1, 
                                                        thickness: 1, 
                                                        color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                                          ? Colors.black 
                                                          : Colors.white,
                                                      ),
                                                  ],
                                                ),
                                                                          
                                                children: [
                                                  player.votesOfPlayer!.isNotEmpty && (player.votesOfPlayer != null)
                                                  ?
                                                  Row(
                                                    children: [
                                                      CircleAvatar(
                                                        //backgroundImage: NetworkImage(widget.inGamePlayers.value.firstWhere((e) => e.nickname == player.votesOfPlayer?[0]).avatarUrl!),
                                                        backgroundImage: NetworkImage("https://www.w3schools.com/w3images/avatar6.png"),
                                                        radius: 15,
                                                      ),
                                                      SizedBox(width: 5.w),
                                                      Text(
                                                        player.votesOfPlayer![0], 
                                                        style: TextStyle(
                                                          fontSize: 15.sp,
                                                          fontFamily: 'CenturyGothic',
                                                          color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  :
                                                  const SizedBox()
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    ),
                                  
                                  ),
                                ),
        
                                //BUTTON:    CONFIRMATION BUTTON
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                          ? Colors.black 
                                          : Colors.white,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(34.0),
                                    ),
                                    child: SizedBox(
                                      width: 230.w,
                                      height: 40.h,
                                      child: Opacity(
                                        opacity: !iVotedPartially ? 0.5 : 1.0,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (!iVotedPartially) return;
                                        
                                            setState(() {
                                              iVotedCompletely = true;
                                              iVotedPartially = false;
                                            });
        
                                            if (widget.role.toLowerCase() == 'terrorist') {
                                              widget.useSkill([toWhomIVoted], true);
                                              return;
                                            }
                                            widget.votePlayer(toWhomIVoted);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(34.0),
                                              side: BorderSide(
                                                color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                                  ? Colors.black 
                                                  : Colors.white,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          
                                          child: Text(
                                            'My move is made', // NOTE:    Translation L10
                                            //! DYNAMIC
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
        
                                // TEXT:    "I accept the weight of my choice"
                                Padding(
                                  padding: EdgeInsets.only(bottom: 30.h),
                                  child: Text(
                                    'I accept the weight of my choice', // NOTE:    Translation L10
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'CommercialScriptBT',
                                      color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                        ? Colors.black 
                                        : const Color(0xFFB8B8B8)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }
    );
  }

}


class SkillPopup extends StatefulWidget {
  final int mafiaCount;
  final int civilianCount;
  final int aliveMafiaCount;
  final int aliveCivilianCount;

  final String title;
  final String gamePhase;

  final String role;

  final bool iUsedSkill;
  final bool canIUseSkill;
  final List<String> toWhomIUsedSkill;
  
  final ValueNotifier<int> timerNotifier;
  final ValueNotifier<List<InGamePlayer>> inGamePlayers;

  final void Function(List<String> influencedBySkillPlayersNickname, bool state) useSkill;

  const SkillPopup({
    super.key, 
    required this.role,
    required this.title,
    required this.useSkill,
    required this.gamePhase,
    required this.iUsedSkill,
    required this.mafiaCount,
    required this.canIUseSkill,
    required this.civilianCount,
    required this.timerNotifier,
    required this.inGamePlayers,
    required this.aliveMafiaCount,
    required this.toWhomIUsedSkill,
    required this.aliveCivilianCount
  });

  @override
  State<SkillPopup> createState() => _SkillPopupState();
}

class _SkillPopupState extends State<SkillPopup> {
  List<String> toWhomIVotedNow = [];
  bool tempStateIUsedSkill = false;

  Map<String, String> rolesSkills = {
    'doctor': 'Cure',
    'beauty': 'Satisfy',
    'bodyguard': 'Protect',
    'barman': 'Intoxicate',
    'informant': 'Reveale',
    'sheriff': 'Investigate',
    'journalist': 'Interview',
  };

  bool isPopupClosed = false;

  void sleep(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  void closePopup() {
    Navigator.pop(context);
  }

  bool delayStarted = false;

  @override
  void initState() {
    super.initState();
    //widget.timerNotifier.addListener(handleTimerChange);
  }

  // void handleTimerChange() {
  //   final time = widget.timerNotifier.value;

  //   if (time == 0 && !isPopupClosed) {
  //     isPopupClosed = true;

  //     if (Navigator.of(context).canPop()) {
  //       Navigator.of(context).pop();
  //     }
  //   }
  // }

  @override
  void dispose() {
    //widget.timerNotifier.removeListener(handleTimerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool fromMafiaTeam = ['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.role.toLowerCase());

    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          height: MediaQuery.of(context).size.height * 0.78,
          color: Colors.transparent,
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     colors: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
          //       ? [const Color(0xFFFFFBF2), const Color(0xFFF6E0B2)] 
          //       : [const Color(0xFF363636), const Color(0xFF000000)],
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //   ),
          //   borderRadius: BorderRadius.circular(16),
          // ),
          child: Column(
            children: [
              //? HEADER
              Container(
                height: 190.h,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: fromMafiaTeam
                      ? [const Color(0xFF4F4F4F), const Color(0xFF000000)]
                      : [const Color(0xFFFFF8EA), const Color(0xFFF6E0B2)], 
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(13.sp),
                    border: Border.all(
                      color: fromMafiaTeam
                        ? const Color(0xFFFFFFFF)
                        : const Color(0xFF494739),
                      width: 2.sp,
                    ),
                  ),
                  child: Column(
                    children: [
                      //? TITLE AND CLOSE BUTTON
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(),

                          //? TITLE
                          Text(
                            widget.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32.sp,
                              color: fromMafiaTeam
                                ? Colors.white
                                : Colors.black, 
                            ),
                          ),

                          //BUTTON:    X
                          Padding(
                            padding: EdgeInsets.only(top: 5.h, right: 5.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Image.asset(
                                    fromMafiaTeam
                                      ? 'assets/images/close-white-icon.png'
                                      : 'assets/images/icon-close-grey.png',
                                    height: 30.h,
                                    width: 23.w,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    
                      //? PLAYERS COUNT INFORMATION
                      Container(
                        margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
                        height: 68.h,
                        width: double.maxFinite,
                        color: const Color(0xFFFFAB00),
                        child: Column(
                          children: [
                            // TEXT:    Mafia Alive
                            Text(
                              '${widget.aliveMafiaCount} of ${widget.mafiaCount} mafias',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic',
                                color: const Color(0xFF000000),
                              ),
                            ),

                            // TEXT:    Citizens Alive
                            Text(
                              '${widget.aliveCivilianCount} of ${widget.civilianCount} civilians',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic',
                                color: const Color(0xFF000000),
                              ),
                            ),

                            //? TIMER
                            ValueListenableBuilder(
                              valueListenable: widget.timerNotifier,
                              builder: (context, value, child) {
                                final minutes = value ~/ 60;
                                final seconds = value % 60;

                                if (value == 1 && !delayStarted) {
                                  delayStarted = true;

                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    Future.delayed(const Duration(milliseconds: 700), () {
                                      if (!mounted) return;
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  });
                                }

                                return Text(
                                  'Pick your target - $minutes:${seconds.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily: 'CenturyGothic',
                                    color: !fromMafiaTeam
                                      ? const Color(0xFF000000)
                                      : Colors.white
                                  ),
                                );
                              }
                            ),
                            

                            // TEXT:    Whose fate will you change?
                            // Text(
                            //   'Whose fate will you change?',
                            //   style: TextStyle(
                            //     fontSize: 15.sp,
                            //     fontFamily: 'CenturyGothic',
                            //     color: const Color(0xFF000000),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    
                      //? TEXT
                      Text(
                        'I\'ve chosen. No regrets',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontFamily: 'CommercialScriptBT',
                          color: fromMafiaTeam ? const Color(0xFFFFFFFF) : const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
              //? SKILLS LIST
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: widget.inGamePlayers,
                  builder: (context, value, child) {
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        final player = value[index];

                        //final hasVotes = player["votes"] > 0;
                        return Container(
                          height: 65.h,
                          width: double.maxFinite,
                          margin: EdgeInsets.only(top: 10.h),
                          decoration: BoxDecoration(
                             gradient: LinearGradient(
                              colors: fromMafiaTeam
                                ? [const Color(0xFF323232), const Color(0xFF212121)]
                                : [const Color(0xFFFFF8EA), const Color(0xFFF6E0B2)], 
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 30.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage: NetworkImage(player.avatarUrl!), //!!!!!!!!!!!
                                          radius: 15,
                                        ),
                                        SizedBox(width: 5.w),
                                        Row(
                                          children: [
                                            Text(
                                              player.nickname, 
                                              style: TextStyle(
                                                fontSize: 15.sp, 
                                                color: fromMafiaTeam
                                                ? Colors.white 
                                                : Colors.black,
                                                fontFamily: 'CenturyGothic'
                                              )
                                            ),
                                            //if (hasVotes)
                                              
                                          ],
                                        ),
                                      ],
                                    ),
                          
                                    //BUTTON:    CHOOSE
                                    Row(
                                      children: [         
                                        SizedBox(
                                          width: 90.w,
                                          height: 37.h,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (!widget.canIUseSkill) {
                                                return;
                                              }
                                              if (tempStateIUsedSkill || widget.iUsedSkill) {
                                                return;
                                              }
                                              if (toWhomIVotedNow.contains(player.nickname)) {
                                                return;
                                              }
                                              if (widget.toWhomIUsedSkill.contains(player.nickname)) {
                                                return;
                                              }
                                              if (!player.isAlive) {
                                                return;
                                              }
                                              
                                              // for (var nick in widget.toWhomIUsedSkill) {
                                              //   log('toWhomIUsedSkill: $nick');
                                              // }
                                              // print('iUsedSkill: ${widget.iUsedSkill}');
                                              toWhomIVotedNow.add(player.nickname);

                                              if (widget.role != 'Journalist') {
                                                tempStateIUsedSkill = true;
                                                setState(() {
                                                  widget.useSkill(toWhomIVotedNow, true);
                                                });
                                              } else {
                                                setState(() {
                                                  widget.useSkill(toWhomIVotedNow, false);
                                                });
                                                if (toWhomIVotedNow.length == 2) {
                                                  tempStateIUsedSkill = true;
                                                  setState(() {
                                                    widget.useSkill(toWhomIVotedNow, true);
                                                  });
                                                }
                                              }
                                              
                                              Navigator.of(context).pop();

                                              // print('---------------------------');
                                              // for (var nick in toWhomIVotedNow) {
                                              //   print('toWhomIUsedSkill: $nick');
                                              // }
                                              // print('+++++++++++++++++++++++++++');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: toWhomIVotedNow.contains(player.nickname) && player.isAlive ? const Color(0xFFFFB000) : Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(34.0),
                                                side: BorderSide(
                                                  color: (!tempStateIUsedSkill && !widget.iUsedSkill) && !widget.toWhomIUsedSkill.contains(player.nickname) && player.isAlive
                                                    ? (!fromMafiaTeam ? Colors.black : Colors.white)
                                                    : (!fromMafiaTeam ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4)),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            
                                            child: Text(
                                              rolesSkills[widget.role.toLowerCase()] ?? 'Choose', // NOTE:    Translation L10 
                                              //! DYNAMIC
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily: 'CenturyGothic',
                                                color: (!tempStateIUsedSkill && !widget.iUsedSkill) && !widget.toWhomIUsedSkill.contains(player.nickname) && player.isAlive
                                                  ? (!fromMafiaTeam ? Colors.black : Colors.white)
                                                  : (!fromMafiaTeam ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4)),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                ),
              ),

            ],
          ),
        ),
      ),
    );
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







class PopupManager {
  // Singleton pattern
  static final PopupManager _instance = PopupManager._internal();
  factory PopupManager() => _instance;
  PopupManager._internal();

  final Map<String, _PopupData> _popupMap = {};

  void show({
    required BuildContext context,
    required String id,
    required WidgetBuilder builder,
    Duration duration = const Duration(milliseconds: 800),
    Offset slideBegin = const Offset(-1.0, 0),
    Curve curve = Curves.elasticOut,
    Curve reverseCurve = Curves.easeInBack,
  }) {
    if (_popupMap.containsKey(id)) return;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final navigator = Navigator.of(context);
    if (navigator is! TickerProvider) {
      throw Exception(
          "Context must provide TickerProvider (e.g. from State<T> with TickerProviderStateMixin).");
    }

    final controller = AnimationController(
      duration: duration,
      vsync: navigator,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    final slideAnimation = Tween<Offset>(
      begin: slideBegin,
      end: Offset.zero,
    ).animate(animation);

    final entry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.black.withOpacity(0.7),
        child: SlideTransition(
          position: slideAnimation,
          child: Center(child: builder(context)),
        ),
      ),
    );

    overlay.insert(entry);
    controller.forward();

    _popupMap[id] = _PopupData(entry, controller);
  }

  void close(String id) {
    final popup = _popupMap[id];
    if (popup == null) return;

    popup.controller.reverse().then((_) {
      popup.entry.remove();
      popup.controller.dispose();
      _popupMap.remove(id);
    });
  }

  void closeAll() {
    for (final id in _popupMap.keys.toList()) {
      close(id);
    }
  }
}

class _PopupData {
  final OverlayEntry entry;
  final AnimationController controller;

  _PopupData(this.entry, this.controller);
}