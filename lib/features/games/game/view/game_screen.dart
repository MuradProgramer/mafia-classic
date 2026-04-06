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
import 'package:just_audio/just_audio.dart';
import 'package:mafia_classic/features/features.dart';
import 'package:mafia_classic/features/games/game/models/in_game_player.dart';
import 'package:mafia_classic/features/games/games.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/widgets/widgets.dart';
import 'package:mafia_classic/features/games/popups/game_information_popup.dart';
import 'package:mafia_classic/features/games/popups/game_player_dead_popup.dart';
import 'package:mafia_classic/features/profile/roles/widgets/role_card.dart';
import 'package:mafia_classic/features/profile/roles/widgets/role_card_popup.dart';
import 'package:mafia_classic/features/widgets/player_info_popup.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/main.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:mafia_classic/utils/popup_utils.dart';
import 'package:mafia_classic/utils/snackbar.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../popups/game_over_popup.dart';

Map<String, BuildContext> popupContexts = {};

class GameScreen extends StatefulWidget {
  final String title;
  final String role;
  final int mafiaCount;
  final int civilianCount;
  final List<PlayerRole>? playersRole;
  final List<Player> allPlayers;
  final bool gameIsReadyWidget;
  final String phase;

  final bool cameBackFromAfk;

  const GameScreen({
    super.key, 
    required this.title, 
    required this.playersRole, 
    required this.role, 
    required this.mafiaCount, 
    required this.civilianCount, 
    required this.allPlayers, 
    required this.cameBackFromAfk,
    required this.gameIsReadyWidget,
    required this.phase
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String gamePhase = ""; // +
  int dayNumber = 0;
  int mafiaAlive = 0; // +
  int civilianAlive = 0; // +
  ValueNotifier<List<InGamePlayer>> inGamePlayers = ValueNotifier<List<InGamePlayer>>([]); // +

  String role = "";
  int mafiaCount = 0;
  int civilianCount = 0;
  String phase = "";

  List<String> markNames = []; // + //!
  bool isAliveMyself = true; // +
  bool canISendMessage = true; 
  int votesOnMe = 0; // +

  // DEF:    VOTE VARIABLES
  ValueNotifier<bool> canIVote = ValueNotifier<bool>(false);
  ValueNotifier<bool> iVoted = ValueNotifier<bool>(false);
  bool votesAreVisibleToMe = false;
  bool canNightVote = false; // NOTE: Informant

  // DEF:    SKILLS VARIABLES
  bool canIUseSkill = false;
  bool iUsedSkill = false;

  List<int> toWhomIUsedSkillId = []; // +
  List<int> specialForJournalistId = []; // +

  List<PlayerRole> namesOfRevealed = []; // +
  List<PlayerRole> namesOfDead = []; // +

  int index = 0;
  ValueNotifier<int> phaseTimeNotifier = ValueNotifier<int>(0);
  Timer? _intoxicationTimer;

  bool gameIsReady = false;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final FocusNode _messageFocusNode = FocusNode();

  int playerDeadSituation = -1;

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    //!!!!!!!!!!!!!!!!!!

    try {
      TcpClientService().sendMessage(ClientCommand.sendRoomMessage.value, json.encode({'message': _messageController.text.trim()}));
    } on Exception catch (e) {
      log('💥 ClientCommand.SendRoomMessage - $e - Client Command 💥');
    }
    /*
    await GetIt.I<ApiService>().gameHubConnection.invoke("SendMessage", args: <Object>[ 
      _messageController.text.trim()
    ]);
    */

    // setState(() {
    //   inGameMessages.add(InGameMessage(
    //     nickname: authorizedUser.nickname,
    //     content: _messageController.text.trim(),
    //     avatarUrl: authorizedUser.avatarUrl,
    //   ));
    // });

    _messageController.clear();
    _scrollToBottom();
  }

  List<InGameMessage> inGameMessages = [];

  void votePlayer(int votedPlayerId) async {
    if (!isAliveMyself) return;

    if (!inGamePlayers.value.firstWhere((el) => el.id == votedPlayerId).isAlive) return;

    if (markNames.any((el) => el == 'Satisfied')) return;

    if (role == 'Kamikaze') return;

    if (gamePhase == 'Day') {
      return;
    }
    else if (gamePhase == 'Night') {
      if ('Mafia' != role) {
        if ((role.toLowerCase() == 'informant') && canNightVote) {
          
        } else {
          return;
        }
      }
    }

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    try {

      TcpClientService().sendMessage(ClientCommand.submitGameVote.value, json.encode({'targetId': votedPlayerId}));
      /*
      await GetIt.I<ApiService>().gameHubConnection.invoke('Vote', args: <Object>[
        votedPlayerNickname
      ]).then((value) => log('vote playeer method suucesfully'));
      */
    } catch (e) {
      log('💥 ClientCommand.submitGameVote - $e - Client Command 💥');
    }
  }
  
  void useSkill(List<int> influencedBySkillPlayersId, bool state) async {
    if (!isAliveMyself) return;

    if (markNames.any((el) => el == 'Satisfied')) return;

    if (iUsedSkill) return;

    for (var element in influencedBySkillPlayersId) { //!
      if (!inGamePlayers.value.firstWhere((el) => el.id == element).isAlive) return; 
    }

    // NOTE:    CHECKING ROLES

    if (role == 'Mafia' || role == 'Civilian' || role == 'Spy') {
      return;
    }

    if (gamePhase == 'Day') {
      if (role != 'Bodyguard') return;
    }

    if (gamePhase == 'DayVoting') {
      if (role != 'Kamikaze') return;
    }

    if (gamePhase == 'Night') {
      if (!['Barman', 'Informant', 'Journalist', 'Beauty'].any((el) => el == role)) {
        return;
      }
    }

    if (gamePhase == 'NightVoting') {
      if (!['Doctor', 'Sheriff'].any((el) => el == role)) {
        return;
      }
    }
  
    if (['sheriff', 'informant'].any((e) => e == role.toLowerCase())) {
      for (var ids in influencedBySkillPlayersId) {
        toWhomIUsedSkillId.add(ids);
      }
    }

    if ('journalist' == role.toLowerCase() && influencedBySkillPlayersId.length >= 2) {
      for (var ids in influencedBySkillPlayersId) {
        toWhomIUsedSkillId.add(ids);
      }
    }

    setState(() {
      iUsedSkill = state;
    });
    

    //!!!!!!!!!!!!!!!
    if (state) {
      try {
        TcpClientService().sendMessage(ClientCommand.useGameAbility.value, json.encode({'targets': influencedBySkillPlayersId}));
      } catch (e) {
        log('💥 ClientCommand.useGameAbility - $e - Client Command 💥');
      }
      canIUseSkill = false;
    }
  }

  // NOTE:    TESTING
  void printInGamePlayers() {
    print('------------------------');
    for (var el in inGamePlayers.value) {
      print('Name: ${el.nickname}  |  Role: ${el.role}  |  IsAlive: ${el.isAlive}  |  IsRevealed: ${el.isRevealed}  |  AvatarUrl: ${el.avatarUrl?.substring(0, 10)}');
    }
  }

  late StreamSubscription<String> gameStateData;
  late StreamSubscription<String> gamePhaseChanged;
  late StreamSubscription<String> gameTimerUpdate;
  late StreamSubscription<String> gameNewMessage;
  late StreamSubscription<String> gameVoteRegistered;
  late StreamSubscription<String> gamePlayerEliminated;
  late StreamSubscription<String> gameKamikazeExplosion;
  late StreamSubscription<String> gameJournalistInterview;
  late StreamSubscription<String> gameEffectApplied;
  late StreamSubscription<String> gameEffectRemoved;
  late StreamSubscription<String> gamePersonalFeedback;
  late StreamSubscription<String> gameNightActionPrompt;
  late StreamSubscription<String> gameOver;

  void _handlePhaseChange(String newPhase) async {
    //print('Phase changed to: $newPhase');
    if (newPhase == "NightVoting") {
      await _audioPlayer.play();
      //print('🔊 Music started/resumed.');
    } else {
      await _audioPlayer.pause();
      //print('🔇 Music paused.');
    }
    if (mounted) setState(() {});
  }

  Iterable<InGamePlayer> filteredPlayers = [];

  @override
  void initState() {
    super.initState();
    //final authorizedPlayer = inGamePlayers.value.firstWhere((p) => p.id == authorizedUser.id);
    
    //inGamePlayers.value.removeWhere((p) => p.id == authorizedUser.id);
    //inGamePlayers.value.insert(0, authorizedPlayer);
    filteredPlayers = inGamePlayers.value.where((p) => p.id != authorizedUser.id);
    //filteredPlayers = inGamePlayers.value.where((p) => p.nickname != '${authorizedUser.nickname}ahgziiqedqw');
    // _audioPlayer.setAsset('assets/sounds/sawtrack.m4a');

    // _audioPlayer.playerStateStream.listen((state) {
    //   if (state.processingState == ProcessingState.completed && mounted) {
    //     setState(() {
    //       _audioPlayer.seek(Duration.zero);
    //     });
    //   }
    // });

    mafiaCount = widget.mafiaCount;
    civilianCount = widget.civilianCount;
    role = widget.role;

    mafiaAlive = widget.mafiaCount;
    civilianAlive = widget.civilianCount;
    gameIsReady = widget.gameIsReadyWidget;

    gamePhase = widget.phase;

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

    // INCOMPLETE
    gameStateData = EventRouterService()
        .subscribe(ServerEvent.gameStateData)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;

        var data = json.decode(payload);

        final role = data['role'];
        final phase = data['phase'];
        final isAlive = data['isAlive'] as bool;
        final mafiaCount = data['mafiaCount'] as int;
        final civilianCount = data['civilianCount'] as int;
        final aliveMafiaCount = data['aliveMafiaCount'] as int;
        final aliveCivilianCount = data['aliveCivilianCount'] as int;
        final canNightVoteData = data['canNightVote'] as bool;
        final day = data['day'] as int;
        final timer = data['timer'] as int;

        phaseTimeNotifier.value = timer;

        final players = (data['players'] as List<dynamic>?)
            ?.map((e) => PlayersFromAfk.fromJson(e))
            .toList() ?? [];

        final marksOfPlayer = (data['activeEffects'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [];

        final votes = (data['votes'] as List<dynamic>?)
            ?.map((e) => Vote.fromJson(e))
            .toList() ?? [];

        setState(() {
          gameIsReady = true;
          this.role = role;
          gamePhase = phase;
          isAliveMyself = isAlive;
          this.mafiaCount = mafiaCount;
          this.civilianCount = civilianCount;
          mafiaAlive = aliveMafiaCount;
          civilianAlive = aliveCivilianCount;
          dayNumber = day;
          canNightVote = canNightVoteData;

          checkIfEligibleToVote();
          checkIfEligibleToUseSkill();
          checkIfEligibleToSendMessage();
          intoxicationEffect();

          markNames = marksOfPlayer;

          // for (Vote vote in votes) {
          //   if (vote.target == authorizedUser.nickname) {
          //     votesOnMe += 1;
          //   }
          // } 

          inGamePlayers.value.add(
            InGamePlayer(
              id: authorizedUser.id,
              nickname: authorizedUser.nickname,
              isAlive: isAlive,
              avatarUrl: authorizedUser.avatarUrl,
              isRevealed: true,
              votesOfPlayer: [],
              role: role
            )
          );

          for (PlayersFromAfk el in players) {
            List<int> playerVotesTEMP = [];

            for (Vote vote in votes) {
              if (vote.targetId == el.id) {
                playerVotesTEMP.add(vote.fromId);
              }
            }

            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            //if (el.nickname == authorizedUser.nickname) continue;

            inGamePlayers.value.add(
              InGamePlayer(
                id: el.id,
                nickname: el.nickname,
                isAlive: el.isAlive,
                avatarUrl: el.avatarUrl,
                isRevealed: ((role == 'Sheriff' || role == 'Informant') && el.isMarked == true || !el.isAlive || (el.role == 'Mafia' && role == 'Mafia') || el.id == authorizedUser.id) ? true : false,
                votesOfPlayer: playerVotesTEMP,
                role: el.role
              )
            );

            if ((role == 'Sheriff' || role == 'Informant') && el.isMarked == true) {
              namesOfRevealed.add(PlayerRole(id: el.id, role: el.role!));
            }

            if (el.id == authorizedUser.id) {
              namesOfRevealed.add(PlayerRole(id: el.id, role: el.role!));
            }

            if (el.role == 'Mafia' && role == 'Mafia') {
              namesOfRevealed.add(PlayerRole(id: el.id, role: el.role!));
            }

            if (!el.isAlive) {
              namesOfDead.add(PlayerRole(id: el.id, role: el.role!));
            }

            if (el.isMarked == true) {
              toWhomIUsedSkillId.add(el.id);
              if (role == 'Journalist') {
                specialForJournalistId.add(el.id);
              }
            }
          }

          for (var element in inGamePlayers.value) {
            print('Name: ${element.nickname}  |  Role: ${element.role} \n');
          }

            // final authorizedPlayer = inGamePlayers.value.firstWhere((p) => p.nickname == authorizedUser.nickname);
            // inGamePlayers.value.removeWhere((p) => p.nickname == authorizedUser.nickname);
            // inGamePlayers.value.insert(0, authorizedPlayer);

          if ((gamePhase == 'NightVoting' && (role == 'Mafia' || canNightVote)) || gamePhase == 'DayVoting') {
            //!!!!!!!!!!!
            // inGamePlayers.value.insert(0, InGamePlayer(
            //   nickname: authorizedUser.nickname,
            //   isAlive: isAliveMyself,
            //   isRevealed: true,
            //   role: widget.role.toLowerCase(),
            //   avatarUrl: authorizedUser.avatarUrl,
            //   votesOfPlayer: []
            // ));
            
            PopupManager().show(
              context: context,
              id: 'votePopup',
              builder: (_) => VotePopup(
                role: role,
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
                  iVoted: iVoted,
              ),
            );
          }
        });
      } catch (e) {
        log('💥 Game State Data - Game Screen 💥');
      }
    });

    // DONE
    gamePhaseChanged = EventRouterService()
        .subscribe(ServerEvent.gamePhaseChanged)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        final String phase = json.decode(payload)['phase'];
        
        setState(() {
          //!!!!!!!!!!!!!!!!!!!!
          // if (inGamePlayers.value[0].nickname == authorizedUser.nickname) {
          //   inGamePlayers.value.removeAt(0);
          // }

          gamePhase = phase;
        
          if (role != 'Mafia' && gamePhase == 'NightVoting' || gamePhase == 'Day') {
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
          else if ((role != 'Mafia' && gamePhase == 'Night')) {
            votesAreVisibleToMe = false;
          }
          else {
            votesAreVisibleToMe = true;
          }
        
          for (var element in inGamePlayers.value) {
            element.votesOfPlayer = [];
          }
        
          iVoted.value = false;
          
          checkIfEligibleToVote();
        
          iUsedSkill = false;
          //toWhomIUsedSkill = [];
        
          checkIfEligibleToUseSkill();
          checkIfEligibleToSendMessage();

          Map<String, String> phaseMessages = {
            'Day': AppLocalizations.of(context)!.phaseMessagesDay,
            'DayVoting': AppLocalizations.of(context)!.phaseMessageDayVoting,
            'Night': AppLocalizations.of(context)!.phaseMessageNight,
            'NightVoting': AppLocalizations.of(context)!.phaseMessageNightVoting
          };
        
          inGameMessages.add(InGameMessage(
            playerId: authorizedUser.id,
            nickname: authorizedUser.nickname,
            content: phaseMessages[phase] ?? '',
            avatarUrl: authorizedUser.avatarUrl,
            type: 'System',
            colorHasOpacity: false
          ));

          if (gamePhase == 'Day') {
            dayNumber += 1;
          }

          if ((gamePhase == 'NightVoting' && (role == 'Mafia' || canNightVote)) || gamePhase == 'DayVoting') {
            //!!!!!!!!!!!!!!!!!!!!
            // inGamePlayers.value.insert(0, InGamePlayer(
            //   nickname: authorizedUser.nickname,
            //   isAlive: isAliveMyself,
            //   isRevealed: true,
            //   role: widget.role.toLowerCase(),
            //   avatarUrl: authorizedUser.avatarUrl,
            //   votesOfPlayer: []
            // ));
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
                role: role,
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
                  iVoted: iVoted,
              ),
            );
          } else {
            Future.delayed(const Duration(milliseconds: 0), () {
              if (!mounted) return;
              PopupManager().close('votePopup');
            });
          }
          //log('game phase: $gamePhase');
        });
        _handlePhaseChange(phase);
      } catch (e) {
        log('💥 Game Phase Changed Error - Game Screen 💥');
      }
    });

    // DONE
    gameTimerUpdate = EventRouterService()
        .subscribe(ServerEvent.gameTimerUpdate)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        
        if (mounted) {
          setState(() {
            phaseTimeNotifier.value = json.decode(payload)['timer'];
            //print(phaseTimeNotifier.value);
          });
        }
      } catch (e) {
        log('💥 Game Timer Update Error - Game Screen 💥');
      }
    });

    // DONE
    gameNewMessage = EventRouterService()
        .subscribe(ServerEvent.gameNewMessage)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        var data = json.decode(payload);

        bool colorHasOpacity = data['isAlive'] as bool ? false : true;
        
        // if (inGamePlayers.value.any((player) => player.nickname == data['nickname'])) {
        //   if (!inGamePlay ers.value.firstWhere((player) => player.nickname == data['nickname']).isAlive) {
        //     colorHasOpacity = true;
        //   }
        // } else {
        //   if (data['nickname'] == authorizedUser.nickname) {
        //     if (!isAliveMyself) {
        //       colorHasOpacity = true;
        //     }
        //   }
        // }
        
        setState(() {
          inGameMessages.add(InGameMessage(
            playerId: data['senderId'],
            nickname: data['nickname'], 
            content: data['content'], 
            avatarUrl: data['avatarUrl'],
            type: 'User',
            colorHasOpacity: colorHasOpacity
          ));
        });
      } catch (e) {
        log('💥 Game New Message Error - Game Screen 💥');
      }
    });

    // DONE
    gameVoteRegistered = EventRouterService()
        .subscribe(ServerEvent.gameVoteRegistered)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        var data = json.decode(payload);
        
        final int from = data['fromId'];
        final int target = data['targetId'];
        setState(() {
          inGamePlayers.value.firstWhere((el) => el.id == target).votesOfPlayer!.add(from);
          inGamePlayers.notifyListeners();
          //print('Voted: $from -> $target');
        });
      } catch (e) {
        log('💥 Game Vote Registered Error - Game Screen 💥');
      }
    });

    void playerDeadEvent(PlayerRole playerDead) {
      if (!mounted) return;
      
      try {
        setState(() {
          if (playerDead.id == authorizedUser.id) {
            youAreDead();
            if (['Mafia', 'Kamikaze', 'Beauty', 'Barman'].any((e) => e == playerDead.role)) {
              mafiaAlive -= 1;
            } else {
              civilianAlive -= 1;
            }
            isAliveMyself = false;
            checkIfEligibleToSendMessage();
            return;
          }
        
          inGamePlayers.value.firstWhere((inplayer) => inplayer.id == playerDead.id).isAlive = false;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.id == playerDead.id).role = playerDead.role;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.id == playerDead.id).isRevealed = true;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.id == playerDead.id).votesOfPlayer = [];
          inGamePlayers.notifyListeners();
          namesOfDead.add(PlayerRole(id: playerDead.id, role: playerDead.role));
        
          if (['Mafia', 'Kamikaze', 'Barman', 'Informant'].any((s) => s == playerDead.role)) {
            mafiaAlive -= 1;
          } else {
            civilianAlive -= 1;
          }
        });
      } catch (e) {
        log('💥 Player Dead EVENT Error - $e - Game Screen 💥');
      }
    }

    // DONE -
    gamePlayerEliminated = EventRouterService()
        .subscribe(ServerEvent.gamePlayerEliminated)
        .listen((payload) {
      try {
        if (payload.isEmpty) {
          return; 
        }
        
        var data = json.decode(payload);
        final String nickname = inGamePlayers.value.firstWhere((el) => el.id == data['id']).nickname;
        final String role = data['role'];
        final String phaseCheck = data['phase'];

        if (data['int'] as int == authorizedUser.id) {
          playerDeadSituation = phaseCheck == 'NightVoting' ? 1 : 2;
        }
        
        playerDeadEvent(PlayerRole(id: data['id'], role: role));

        setState(() {
          inGameMessages.add(InGameMessage(
            playerId: -1,
            nickname: '', 
            content: phaseCheck == 'NightVoting'
              ? AppLocalizations.of(context)!.nicknameDidNotSurviveTheNight(nickname)
              : AppLocalizations.of(context)!.nicknameWasEliminatedByTheTownsDecision(nickname),
            avatarUrl: '',
            type: 'System',
            colorHasOpacity: false,
            color: const Color(0xFFE62727)
          ));
        });
        
        //printInGamePlayers();
      } catch (e) {
        log('💥 Game Player Eliminated Error - Game Screen 💥');
      }
    });

    // INCOMPLETE
    gameKamikazeExplosion = EventRouterService()
        .subscribe(ServerEvent.gameKamikazeExplosion)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;

        var data = json.decode(payload);

        final int kamikazeId = data['kamikazeId'];
        PlayerRole targetPlayer = PlayerRole.fromJson(data['targetPlayer'] as Map<String, dynamic>);
        final bool isProtected = data['targetProtected'] as bool;
        
        String content = AppLocalizations.of(context)!.kamikazeTriedToBombTargetplayerButBodyguardSavedHimher(inGamePlayers.value.firstWhere((el) => el.id == targetPlayer.id).nickname);
        if (!isProtected) {
          content = AppLocalizations.of(context)!.kamikazeBombardedTargetplayer(inGamePlayers.value.firstWhere((el) => el.id == targetPlayer.id).nickname);
          playerDeadEvent(targetPlayer);
          if (targetPlayer.id == authorizedUser.id) {
            playerDeadSituation = 3;
          }
        }
        if (kamikazeId == authorizedUser.id) {
          playerDeadSituation = 4;
        }
        playerDeadEvent(PlayerRole(id: kamikazeId, role: 'Kamikaze'));

        TopSnackBarManager.show({"content": content}, 7);
        
        setState(() {
          inGameMessages.add(InGameMessage(
            playerId: -1,
            nickname: '', 
            content: content, 
            avatarUrl: '',
            type: 'System',
            colorHasOpacity: false,
            color: (isProtected) ? const Color(0xFF63A361): const Color(0xFFE62727)
          ));
        });
      } catch (e) {
        log('💥 Game Kamikaze Explosion Error - Game Screen 💥');
      }
    });

    // INCOMPLETE
    gameJournalistInterview = EventRouterService()
        .subscribe(ServerEvent.gameJournalistInterview)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;

        var data = json.decode(payload);

        final int firstPlayerId = data['firstPlayerId'];
        final int secondPlayerId = data['secondPlayerId'];
        final bool areSameTeam = data['areSameTeam'] as bool;

        final String firstPlayerNickname = inGamePlayers.value.firstWhere((el) => el.id == firstPlayerId).nickname;
        final String secondPlayerNickname = inGamePlayers.value.firstWhere((el) => el.id == secondPlayerId).nickname;

        String content = AppLocalizations.of(context)!.firstplayernicknameAndSecondplayernicknameAreOnDifferentTeams(firstPlayerNickname, secondPlayerNickname);
        if (areSameTeam) {
          content = AppLocalizations.of(context)!.firstplayernicknameAndSecondplayernicknameAreOnSameTeams(firstPlayerNickname, secondPlayerNickname);
        }
        
        setState(() {
          inGameMessages.add(InGameMessage(
            playerId: -1,
            nickname: '', 
            content: content, 
            avatarUrl: '',
            type: 'System',
            colorHasOpacity: false,
            color: const Color(0xFF00695C)
          ));
        });
      } catch (e) {
        log('💥 Game Journalist Interview Error - Game Screen 💥');
      }
    });
    
    // DONE 
    gameEffectApplied = EventRouterService()
        .subscribe(ServerEvent.gameEffectApplied)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        final String mark = json.decode(payload)['effectType'];

        setState(() {
          markNames.add(mark);
        });

        checkIfEligibleToUseSkill();

        PopupManager().show(
          context: context,
          id: 'informationPopup',
          builder: (_) => InformationPopup(effect: mark)
        );

        if (['intoxicated', 'satisfied'].any((e) => e == mark.toLowerCase())) {
          PopupManager().close('skillPopup');
        }
        if (mark.contains('LastMafia')) {
          canNightVote = true;
        }
      } catch (e) {
        log('💥 Game Effect Applied Error - Game Screen 💥');
      }
    });

    // DONE
    gameEffectRemoved = EventRouterService()
        .subscribe(ServerEvent.gameEffectRemoved)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        final String unmark = json.decode(payload)['effectType'];
        
        setState(() {
          markNames.remove(unmark);
          //markNames.remove('sheriff');
        });
      } catch (e) {
        log('💥 Game Effect Removed Error - Game Screen 💥');
      }
    });

    // DONE
    gamePersonalFeedback = EventRouterService()
        .subscribe(ServerEvent.gamePersonalFeedback)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        var data = json.decode(payload);
        var playerDto = data as Map<String, dynamic>;
        
        PlayerRole player = PlayerRole.fromJson(playerDto);

        TopSnackBarManager.show({"playerNickname": inGamePlayers.value.firstWhere((e) => e.id == player.id).nickname, "playerRole": player.role.toLowerCase()}, 6);
        
        setState(() {
          inGamePlayers.value.firstWhere((inplayer) => inplayer.id == player.id).isRevealed = true;
          inGamePlayers.value.firstWhere((inplayer) => inplayer.id == player.id).role = player.role.toLowerCase();
          namesOfRevealed.add(PlayerRole(id: player.id, role: player.role.toLowerCase()));
        });
      } catch (e) {
        log('💥 Game Personal Feedback Error - Game Screen 💥');
      }
    });

    // PARTIAL
    // gameNightActionPrompt = EventRouterService()
    //     .subscribe(ServerEvent.gameNightActionPrompt)
    //     .listen((payload) {
    //   try {
    //     setState(() {
    //       canNightVote = true;
    //       log('CAN NIGHT VOTE METHOD: ${DateTime.now().toIso8601String()}');
    //     });
    //   } on Exception catch (e) {
    //     log('EXCEPTION IN:     TIMER EVENT - GAME SCREEN: ${e.toString()}');
    //   }
    // });

    // PARTIAL
    gameOver = EventRouterService()
        .subscribe(ServerEvent.gameOver)
        .listen((payload) {
      try {
        if (payload.isEmpty) return;
        
        var data = json.decode(payload);
        
        final String winner = data['winner'];
        final int points = data['points'];

        PopupManager().show(
          context: context,
          id: 'gameOverPopup',
          builder: (_) => GameOverPopup(isMafiaWinner: winner.toLowerCase() == 'mafia', score: points)
        );

        log('WINNER: $winner    |    POINTS: $points');
      } on Exception catch (e) {
        log('💥 Game Over Error - Game Screen 💥');
      }
    });

  
    
    // !!!!!!!!!!!!!!!!!!!
    

    //!!!!!!!!!!!!!!
    //checkIfEligibleToUseSkill();
    
    
    //var apiService = GetIt.I<ApiService>();

    //
    //toWhomIUsedSkill.add('Player7');
    // for (var e in inGamePlayers) {
    //   e.isAlive = false;
    // }

    //!!!!!!!!!!!!
    /*
    if (!apiService.gameHubIsConnected) {
      print("187 games screen - creating connection");
      apiService.gameHubConnection = HubConnectionBuilder().withUrl(
        'https://31.171.65.145/gamelobby?title=${widget.title}',
        options: HttpConnectionOptions(
          accessTokenFactory: () => Future.value(GetIt.I<ApiService>().accessToken),
          // skipNegotiation: true,
          // transport: HttpTransportType.WebSockets,
        ),
      )
      .build();
    }
    */
    

    


    if (widget.cameBackFromAfk) {
      //!!!!!!!!!!!!

      log('----------- CAME BACK FROM AFK ----------');

      /*
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
          final canNightVoteData = data['canNightVote'] as bool;
          final day = data['day'] as int;

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
            dayNumber = day;
            canNightVote = canNightVoteData;
            
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

            // for (Vote vote in votes) {
            //   if (vote.target == authorizedUser.nickname) {
            //     votesOnMe += 1;
            //   }
            // } 

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
                  isRevealed: ((role == 'Sheriff' || role == 'Informant') && el.isMarked == true || !el.isAlive) ? true : false,
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

            if ((gamePhase == 'NightVoting' && (widget.role == 'Mafia' || canNightVote)) || gamePhase == 'DayVoting') {
              inGamePlayers.value.insert(0, InGamePlayer(
                nickname: authorizedUser.nickname,
                isAlive: isAliveMyself,
                isRevealed: true,
                role: widget.role.toLowerCase(),
                avatarUrl: authorizedUser.avatarUrl,
                votesOfPlayer: []
              ));
              
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
          });
        } on Exception catch (e) {
          log('EXCEPTION IN:     ReconnectGameData EVENT - GAME SCREEN: ${e.toString()}');
        }
      });
      */
    } else {
      Map<int, String> roleMap = {};
      if (widget.playersRole != null) {
        for (var element in widget.playersRole!) {
          roleMap[element.id] = element.role;
        }
      }

      final me = widget.allPlayers.firstWhere((player) => player.id == authorizedUser.id);

      inGamePlayers.value.add(InGamePlayer(
        id: me.id,
        nickname: me.nickname,
        isAlive: true,
        isRevealed: true,
        role: role,
        avatarUrl: me.avatarUrl,
        votesOfPlayer: []
      ));

      for (var item in widget.allPlayers) {
        //!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        if (item.id == authorizedUser.id) continue;
        inGamePlayers.value.add(InGamePlayer(
          id: item.id,
          nickname: item.nickname,
          isAlive: true,
          isRevealed: roleMap[item.id] == null ? false : true,
          role: roleMap[item.id] ?? 'undef',
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
 
    //!SIGNALR EVENTS
    /*
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
            if (['Mafia', 'Kamikaze', 'Beauty', 'Barman'].any((e) => e == playerDead.role)) {
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
        
          if (['Mafia', 'Kamikaze', 'Barman', 'Informant'].any((s) => s == playerDead.role)) {
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
    */
    
    //await GetIt.I<ApiService>().gameHubConnection.invoke("TriggerPhaseEvent", args: <Object>[]);
  }

  @override
  void dispose() async {
    _intoxicationTimer?.cancel();
    print("Disonnected to SignalR! 600 games screen");
    //!!!!!
    /*
    GetIt.I<ApiService>().disconnectGameHub();
    GetIt.I<ApiService>().gameHubIsConnected = false;
    */
    _controller.dispose();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    AudioPlayer.clearAssetCache();
    AudioPlayer().dispose();
    phaseTimeNotifier.dispose();

    gameStateData.cancel();
    gamePhaseChanged.cancel();
    gameTimerUpdate.cancel();
    gameNewMessage.cancel();
    gameVoteRegistered.cancel();
    gamePlayerEliminated.cancel();
    gameKamikazeExplosion.cancel();
    gameJournalistInterview.cancel();
    gameEffectApplied.cancel();
    gameEffectRemoved.cancel();
    gamePersonalFeedback.cancel();
    gameNightActionPrompt.cancel();
    gameOver.cancel();
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
      canIVote.value = newState;
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

    if (role == 'Kamikaze') {
      changeVoteState(false);
      return;
    }

    if (markNames.any((el) => el == 'Satisfied' || el == 'Intoxicated')) { //! ADD INTOXICATED
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
      if ('Mafia' != role) {
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

    if (role == 'Mafia' || role == 'Civilian' || role == 'Spy') {
      changeSkillState(false);
      return;
    }

    if (gamePhase == 'Day') {
      if (role != 'Bodyguard') {
        changeSkillState(false);
        return;
      }
    }

    if (gamePhase == 'DayVoting') {
      if (role != 'Kamikaze') {
        changeSkillState(false);
        return;
      }
    }

    if (gamePhase == 'Night') {
      if (!['Informant', 'Journalist', 'Barman', 'Beauty'].any((el) => el == role)) {
        changeSkillState(false);
        return;
      }
    }

    if (gamePhase == 'NightVoting') {
      if (!['Doctor', 'Sheriff'].any((el) => el == role)) {
        changeSkillState(false);
        return;
      }
    }

    changeSkillState(true);
  }

  bool checkSecondIfEligibleToUseSkill(InGamePlayer player) {
    if (role == 'Journalist') {
      if (specialForJournalistId.any((el) => el == player.id)) {
        return false;
      }
    } else {
      if(toWhomIUsedSkillId.contains(player.id)) {
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
      if (['Mafia', 'Informant'].any((e) => e == role)) {
        changeSendMessageState(true);
      } else {
        changeSendMessageState(false);
      }
    }
  }

  bool checkSecondIfEligibleToVote(InGamePlayer player) {
    if (['Mafia', 'Kamikaze'].any((el) => el == player.role) && role == 'Mafia' && gamePhase == 'NightVoting') {
      return false;
    }

    return true;
  }

  void youAreDead() {
    PopupManager().closeAll();
    
    PopupManager().show(
      context: context,
      id: 'playerDeadPopup',
      builder: (_) => GamePlayerDeadPopup(situationType: playerDeadSituation)
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

    if (player.id == authorizedUser.id) {
      return 'assets/images/${player.role!.toLowerCase()}.png';
    }

    if (player.isRevealed) {
      return 'assets/images/${player.role!.toLowerCase()}.png';
    }

    if (role == 'Mafia') {
      if (['Kamikaze', 'Mafia'].any((e) => e == player.role)) {
        return 'assets/images/${player.role!.toLowerCase()}.png';
      }
    }

    return "assets/images/default.png";
  }

  bool isOpened = false;
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    final double ornamentSize = 35.sp;
    final double ornamentMargin = 10.sp;

    final double height10 = deviceHeight * 0.01;
    final double width10 = deviceWidth * 0.023;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isOpened && !widget.cameBackFromAfk) {
        PopupManager().show(
          context: context,
          id: 'roleInformationPopup',
          builder: (_) => RoleCardPopup(roleName: role.toLowerCase(), closeType: 2,)
        );
        isOpened = true;
      }
    });

    return !gameIsReady ? const Center(child: CircularProgressIndicator()) : 
    PopScope(
      canPop: false,
      child: Stack(
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
      
          body: Stack(
            children: [
              LayoutBuilder(
                builder: (context, sizes) {
                  if (sizes.maxWidth < 360) {
                    return const Spacer();
                  } else if (sizes.maxWidth < 600) {
                    int playersCount = civilianCount + mafiaCount;
                    return SingleChildScrollView(
                      child: Align(
                        alignment: AlignmentGeometry.center,
                        child: Container(
                          width: deviceWidth * 0.95,
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              SizedBox(height: deviceHeight * 0.06),
                              
                              //? INFO PART
                              //!!!!!!!!!!!!!!!!
                              //DONE:    DYNAMIC
                              Container(
                                width: double.maxFinite,
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
                                                        
                                                        // TEXT    Players in the room
                                                        Text(
                                                          AppLocalizations.of(context)!.playersInTheRoom,
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
                                                        // TEXT    Mafia
                                                        Text(
                                                          "${AppLocalizations.of(context)!.mafia} ",
                                                          style: TextStyle(
                                                            height: 1,
                                                            color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                                            fontFamily: 'CenturyGothic',
                                                            fontSize: deviceWidth * 0.035
                                                          )
                                                        ),
                                                        Text(
                                                          '$mafiaAlive|$mafiaCount',
                                                          style: TextStyle(
                                                            height: 1,
                                                            color: const Color(0xFFFFB000),
                                                            fontFamily: 'CenturyGothic',
                                                            fontSize: deviceWidth * 0.035
                                                          ),
                                                        ),
                                                        SizedBox(width: width10),
                        
                                                        // TEXT    Civilian
                                                        Text(
                                                          "${AppLocalizations.of(context)!.civilians} ",
                                                          style: TextStyle(
                                                            height: 1,
                                                            color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                                            fontFamily: 'CenturyGothic',
                                                            fontSize: deviceWidth * 0.035
                                                          )
                                                        ),
                                                        Text(
                                                          '$civilianAlive|$civilianCount',
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
                              
                              //? DAY AND NIGHT PART ++++++
                              //DONE:    DYNAMIC
                              Container(
                                width: double.maxFinite,
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
                                        (dayNumber == 0) ? AppLocalizations.of(context)!.day : '${AppLocalizations.of(context)!.day} $dayNumber',
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
                                        // //? DAY
                                        // GestureDetector(
                                        //   //NOTE: FONT SIZE
                                        //   child: Icon(
                                        //     Icons.sunny,
                                        //     color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFB000) : Colors.black,
                                        //     size: 25.sp,
                                        //   ),
                                        // ),

                                        SizedBox(
                                          width: 23.w,
                                          height: 23.h,
                                          child: Image.asset(
                                            "assets/images/icon-day.png",
                                            fit: BoxFit.contain,
                                            color: gamePhase == 'Day' ? const Color(0xFFFFB000) : gamePhase == 'DayVoting' || gamePhase == 'Day' ?  Colors.black : Colors.white,
                                          ),
                                        ),
                        
                                        SizedBox(width: 13.w),

                                        SizedBox(
                                          width: 23.w,
                                          height: 23.h,
                                          child: Image.asset(
                                            "assets/images/icon-day-voting.png",
                                            fit: BoxFit.contain,
                                            color: gamePhase == 'DayVoting' ? const Color(0xFFFFB000) : gamePhase == 'DayVoting' || gamePhase == 'Day' ?  Colors.black : Colors.white,
                                          ),
                                        ),

                                        SizedBox(width: 13.w),

                                        SizedBox(
                                          width: 14.w,
                                          height: 14.h,
                                          child: Image.asset(
                                            "assets/images/icon-night.png",
                                            fit: BoxFit.contain,
                                            color: gamePhase == 'Night' ? const Color(0xFFFFB000) : gamePhase == 'DayVoting' || gamePhase == 'Day' ?  Colors.black : Colors.white,
                                          ),
                                        ),

                                        SizedBox(width: 13.w),

                                        SizedBox(
                                          width: 23.w,
                                          height: 23.h,
                                          child: Image.asset(
                                            "assets/images/icon-night-voting.png",
                                            fit: BoxFit.contain,
                                            color: gamePhase == 'NightVoting' ? const Color(0xFFFFB000) : gamePhase == 'DayVoting' || gamePhase == 'Day' ?  Colors.black : Colors.white,
                                          ),
                                        ),

                                        SizedBox(width: 25.w),
                        
                                        // //? NIGHT
                                        // GestureDetector(
                                        //   //NOTE: FONT SIZE
                                        //   child: Icon(
                                        //     Icons.nights_stay,
                                        //     color: !['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFB000) : Colors.black,
                                        //     size: 20.sp,
                                        //   ),
                                        // ),
                                    
                                        //SizedBox(width: 8.w),
                                    
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
                              SizedBox(
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    //? PLAYERS +
                                    Container(
                                      width: deviceWidth * 0.67,
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
                                        itemCount: filteredPlayers.length,
                                        itemBuilder: (context, index) {
                                          final player = filteredPlayers.elementAt(index);
                                          return Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        width: (!player.isAlive) ? 1.5.w : 0.w,
                                                        color: (!player.isAlive) ? const Color(0xFF831611) : Colors.transparent
                                                      ),
                                                      borderRadius: BorderRadius.circular(4.r)
                                                    ),
                                                    child: RoleTooltipCard(
                                                      roleName: player.role!,
                                                      isAlive: player.isAlive,
                                                      isRevealed: player.isRevealed,
                                                    ),
                                                  ),
      
                                                  if (!player.isAlive)
                                                    IgnorePointer(
                                                      child: Image.asset(
                                                        'assets/images/blood-effect.png',
                                                        width: 62.w,
                                                        height: 78.h,
                                                        fit: BoxFit.fill,
                                                        alignment: Alignment.topLeft,
                                                      ),
                                                    )
                                                
                                                ],
                                              ),
                                              
                                              Container(
                                                margin: EdgeInsets.only(top: 2.h),
                                                width: 75.w,
                                                height: 40.h,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showBouncingPopupFromLeft(
                                                      context, 
                                                      PlayerInfoPopup(
                                                        id: player.id,
                                                        height: 727.h, 
                                                        width: 405.w, 
                                                        nickname: player.nickname,
                                                      )
                                                    ).then((_) {
                                                      
                                                    });
                                                  },
                                                  child: Text(
                                                    player.nickname,
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
                                            role,
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 19.sp,
                                              color: const Color(0xFFFFB000),
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          
                                          // TEXT:    is your destiny
                                          Text(
                                            AppLocalizations.of(context)!.isYourDestiny,
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
                                          Stack(
                                            children: [
                                              Container(
                                                width: deviceWidth * 0.174, 
                                                height: deviceHeight * 0.106,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: !isAliveMyself ? const Color(0xFF831611) : ['mafia', 'informant', 'kamikaze', 'barman'].contains(role.toLowerCase()) ? const Color(0xFF000000) : const Color(0xFFFFD77E),
                                                      blurRadius: 12.0.r, 
                                                      spreadRadius: -2.r, 
                                                      offset: Offset.zero, 
                                                    ),
                                                  ],
                                                  border: Border.all(
                                                    width: (!isAliveMyself) ? 1.5.w : 0.w,
                                                    color: (!isAliveMyself) ? const Color(0xFF831611) : Colors.transparent
                                                  ),
                                                  borderRadius: BorderRadius.circular(6.r)
                                                ),
                                                child: RoleCard(
                                                  roleName: role.toLowerCase(), 
                                                  width: deviceWidth * 0.174, 
                                                  height: deviceHeight * 0.106,
                                                  isMini: false,
                                                ),
                                              ),
                                            
                                              if (!isAliveMyself)
                                                IgnorePointer(
                                                  child: Image.asset(
                                                    'assets/images/blood-effect.png',
                                                    width: deviceWidth * 0.174, 
                                                    height: deviceHeight * 0.106,
                                                    fit: BoxFit.fill,
                                                    alignment: Alignment.topLeft,
                                                  ),
                                                )
                                            ],
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
                                                borderRadius: BorderRadius.circular(34.r),
                                              ),
                                              child: SizedBox(
                                                width: deviceWidth * 0.255,
                                                height: deviceHeight * 0.04,
                                                child: ElevatedButton(
                                                  
                                                  onPressed: () {
                                                    // !!!!!!!!!!!!
                                                      
                                                    
                                                    //checkSecondIfEligibleToVote(inGamePlayers.value.firstWhere((inplayer) => inplayer.nickname == authorizedUser.nickname));
      
                                                    if (canIVote.value) {
                                                      //!!!!!!!!!!!!!!!!!!!!
                                                      // inGamePlayers.value.insert(0, InGamePlayer(
                                                      //   nickname: authorizedUser.nickname,
                                                      //   isAlive: isAliveMyself,
                                                      //   isRevealed: true,
                                                      //   role: widget.role.toLowerCase(),
                                                      //   avatarUrl: authorizedUser.avatarUrl,
                                                      //   votesOfPlayer: []
                                                      // ));
      
                                                      PopupManager().show(
                                                        context: context, 
                                                        id: 'votePopup', 
                                                        builder: (_) => VotePopup(
                                                          role: role,
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
                                                            iVoted: iVoted,
                                                        ),
                                                      );
                                                      return;
                                                    }
      
                                                    if (canIUseSkill == false) {
                                                      return;
                                                    }
      
                                                    PopupManager().show(
                                                      context: context,
                                                      id: 'skillPopup',
                                                      builder: (_) => SkillPopup(
                                                        role: role,
                                                        useSkill: useSkill,
                                                        title: widget.title,
                                                        gamePhase: gamePhase,
                                                        iUsedSkill: iUsedSkill,
                                                        canIUseSkill: canIUseSkill,
                                                        aliveMafiaCount: mafiaAlive,
                                                        inGamePlayers: inGamePlayers,
                                                        mafiaCount: mafiaCount,
                                                        aliveCivilianCount: civilianAlive,
                                                        timerNotifier: phaseTimeNotifier,
                                                        civilianCount: civilianCount,
                                                        toWhomIUsedSkillId: toWhomIUsedSkillId,
                                                      )
                                                    );
                                                    
                                                    // showGeneralDialog(
                                                    //   context: context,
                                                    //   barrierDismissible: true,
                                                    //   barrierLabel: "Dismiss",
                                                    //   barrierColor: Colors.black.withOpacity(0.7),
                                                    //   transitionDuration: const Duration(milliseconds: 800),
                                                    //   pageBuilder: (context, animation, secondaryAnimation) {
                                                    //     return SkillPopup(
                                                    //       role: widget.role,
                                                    //       useSkill: useSkill,
                                                    //       title: widget.title,
                                                    //       gamePhase: gamePhase,
                                                    //       iUsedSkill: iUsedSkill,
                                                    //       canIUseSkill: canIUseSkill,
                                                    //       aliveMafiaCount: mafiaAlive,
                                                    //       inGamePlayers: inGamePlayers,
                                                    //       mafiaCount: widget.mafiaCount,
                                                    //       aliveCivilianCount: civilianAlive,
                                                    //       timerNotifier: phaseTimeNotifier,
                                                    //       civilianCount: widget.civilianCount,
                                                    //       toWhomIUsedSkill: toWhomIUsedSkill,
                                                    //     );
                                                    //   },
                                                    //   transitionBuilder: (context, animation, secondaryAnimation, child) {
                                                    //     final curvedAnimation = CurvedAnimation(
                                                    //       parent: animation,
                                                    //       curve: Curves.elasticOut,
                                                    //       reverseCurve: Curves.easeInBack,
                                                    //     );
                                      
                                                    //     return SlideTransition(
                                                    //       position: Tween<Offset>(
                                                    //         begin: const Offset(-1.0, 0.0),
                                                    //         end: Offset.zero,
                                                    //       ).animate(curvedAnimation),
                                                    //       child: child,
                                                    //     );
                                                    //   },
                                                    // );
                                                    
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: canIUseSkill || canIVote.value ? const Color(0xFFFFB000) : const Color(0xFF9A9A9A),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(34.0),
                                                      side: const BorderSide(
                                                        color: Colors.white,
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                  ),
                                                      
                                                  child: Text(
                                                    canIVote.value ? AppLocalizations.of(context)!.vote : AppLocalizations.of(context)!.useSkill,
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
                              ),
                            
                              SizedBox(height: height10),
                        
                              //? MESSAGES PART
                              Container(
                                width: double.maxFinite,
                                height: deviceHeight * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(12.sp),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5.h),
                                    decoration: BoxDecoration(
                                      color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? const Color(0xFFFFECC5) : const Color(0xFF1E1E1E),
                                      border: Border.all(
                                        color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black : Colors.white,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: InGameChatBox(
                                      messages: inGameMessages, 
                                      scrollController: _scrollController, 
                                      messageController: _messageController, 
                                      scrollToBottom: _scrollToBottom, 
                                      isAlive: isAliveMyself, 
                                      gamePhase: gamePhase,
                                      players: widget.allPlayers,
                                    )
                                  ),
                                ),
                              ),
                        
                              SizedBox(height: height10),
                        
                              //? INPUT PART
                              Container(
                                width: double.maxFinite,
                                height: deviceHeight * 0.067,
                                decoration: BoxDecoration(
                                  color: ['Day', 'DayVoting'].any((e) => e == gamePhase) ? Colors.black.withOpacity(0.4) : const Color(0xFF2B2B2B),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(left: 4.w, right: 4.w),
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Image.asset(
                                          'assets/images/icon-disabled-micro.png',
                                          width: 35.h,
                                          height: 35.h,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: deviceWidth * 0.83,
                                      height: deviceHeight * 0.06,
                                      child: EnterMessage(messageController: _messageController, sendMessage: _sendMessage, canISendMessage: canISendMessage, gamePhase: gamePhase, focusNode: _messageFocusNode,)
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        
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
                          //   inGamePlayers.firstWhere((inplayer) => inplayer.nickname == 'Player1').role = 'Kamikaze';
                          //   namesOfDead.add(PlayerRole(nickname: 'Player1', role: 'Kamikaze'));
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
                                            
                                            if (['Mafia', 'Kamikaze'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') {
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
                                                ? ['Mafia', 'Kamikaze'].any((el) => el == player.role)
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
                                          
                                          if (['Mafia', 'Kamikaze'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') {
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
                                              ? (['Mafia', 'Kamikaze'].any((el) => el == player.role) && widget.role == 'Mafia' && gamePhase == 'NightVoting') 
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
      
      ]),
    );
  }
}


class VotePopup extends StatefulWidget {
  final String role;
  final ValueNotifier<bool> canIVote;
  final bool votesAreVisibleToMe;
  final void Function(bool newState) changeVoteState;
  final bool Function(InGamePlayer player) checkSecondIfEligibleToVote;

  //! ESSENTIAL VARIABLES
  final ValueNotifier<bool> iVoted;
  final int dayCount;
  final String title;
  final int aliveCount;
  final String gamePhase;
  final bool canNightVote;
  final bool isAliveMyself;
  final List<String> markNames;
  final ValueNotifier<int> timerNotifier;
  final ValueNotifier<List<InGamePlayer>> inGamePlayers;
  final void Function(int votedPlayerNickname) votePlayer;
  final void Function(List<int> toWhomIUsedSkill, bool state) useSkill;

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
    required this.iVoted,
  });
  
  @override
  State<VotePopup> createState() => _VotePopupState();
}

class _VotePopupState extends State<VotePopup> {
  bool iVotedCompletely = false;
  bool iVotedPartially = false;
  int toWhomIVotedId = -1;

  bool isPopupClosed = false;

  //ModalRoute? voteRoute;

  // void votePlayer(String votedPlayerNickname) async {
  //   if (!widget.isAliveMyself) return;

  //   if (!widget.inGamePlayers.value.firstWhere((el) => el.nickname == votedPlayerNickname).isAlive) return;

  //   if (widget.markNames.any((el) => el == 'Satisfied')) return;

  //   if (widget.role == 'Kamikaze') return;

  //   await GetIt.I<ApiService>().gameHubConnection.invoke('Vote', args: <Object>[
  //     votedPlayerNickname
  //   ]).then((value) => log('vote playeer method suucesfully'));
  // }

  bool checkIfItIsMafiaAndNight(String playerRole, String myRole, String gamePhase) {
    if (gamePhase == 'NightVoting' && myRole.toLowerCase() == 'mafia') {
      if (playerRole == 'Mafia' || playerRole == 'Kamikaze') {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  bool canIVotePopup(InGamePlayer player) {
    if (!widget.isAliveMyself) return false;

    if (widget.inGamePlayers.value[0].id == player.id) return false;

    if (!player.isAlive) return false;

    if (widget.markNames.contains('Satisfied') || widget.markNames.contains('Intoxicated')) return false;

    if (iVotedCompletely) return false;
    
    if (widget.role.toLowerCase() == 'informant' && widget.canNightVote) return true; 

    if (widget.gamePhase == 'Night' && (player.role == 'Kamikaze' || player.role == 'Mafia') && widget.role == 'Mafia') return false;

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

    if (widget.iVoted.value) {
      setState(() {
        iVotedCompletely = true;
        iVotedPartially = false;
      });
    }
    
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

        // Future.delayed(const Duration(milliseconds: 700), () {
        //     if (!mounted) return;
        //     PopupManager().close('votePopup');
        //   });




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
    //widget.timerNotifier.removeListener();
    super.dispose();
  }

  bool get isDay => ['Day', 'DayVoting'].any((e) => e == widget.gamePhase);


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
            borderRadius: BorderRadius.circular(16.r),
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
                borderRadius: BorderRadius.circular(16.r),
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
                          padding: EdgeInsets.only(left: 10.w, top: 5.h),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.day} ${widget.dayCount == 0 ? '' : widget.dayCount}', 
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
                        // Padding(
                        //   padding: EdgeInsets.only(top: 3.h, right: 40.w),
                        //   child: Column(
                        //     children: [
                        //       SizedBox(height: 5.h),
                        //       Text(
                        //         '${widget.aliveCount} | ${widget.inGamePlayers.value.length}',
                        //         style: TextStyle(
                        //           height: 0,
                        //           fontSize: 15.sp,
                        //           fontFamily: 'CenturyGothic',
                        //           color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                        //             ? Colors.black 
                        //             : Colors.white
                        //         )
                        //       ),
                        //       Text(
                        //         S.of(context).civiliansAreWithUs,
                        //         style: TextStyle(
                        //           height: 0,
                        //           fontSize: 15.sp,
                        //           fontFamily: 'CenturyGothic',
                        //           color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                        //             ? Colors.black 
                        //             : Colors.white
                        //         )
                        //       ),
                        //     ],
                        //   ),
                        // ),
        
                        // //BUTTON:    X
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.h, right: 5.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (widget.timerNotifier.value > 1) {
                                    //!!!!!!!!!!!!!!!!!!!!!!!!
                                    //widget.inGamePlayers.value.removeWhere((player) => player.nickname == authorizedUser.nickname);
                                    PopupManager().close('votePopup');
                                  }
                                },
                                child: Image.asset(
                                  !isDay
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
                          width: 2.w,
                        ),
                        borderRadius: BorderRadius.circular(13.r),
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
                          Column(
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
                                        '${['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? AppLocalizations.of(context)!.whoIsNext : AppLocalizations.of(context)!.pickYourTarget} $minutes:${seconds.toString().padLeft(2, '0')}',
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
                                child: Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 17.w),
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
                                            child: NoIconExpansionTile(
                                              canExpand: canExpand,
                                              //controlAffinity: ListTileControlAffinity.leading,
                                              //enabled: canExpand,
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
                                  
                                                            Stack(
                                                              children: [
                                                                RoleCard(
                                                                  roleName: player.isRevealed ? player.role!.toLowerCase() : 'noname',
                                                                  width: 30.w,
                                                                  height: 30.h,
                                                                  isMini: true,
                                                                  enabled: false,
                                                                ),

                                                                if (!player.isAlive)
                                                                  Positioned(
                                                                    top: 1,
                                                                    left: 4,
                                                                    child: IgnorePointer(
                                                                      child: Image.asset(
                                                                        'assets/images/blood-effect.png',
                                                                        width: 20.w,
                                                                        height: 26.h,
                                                                        fit: BoxFit.fill,
                                                                        alignment: Alignment.topRight,
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
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
                                                                fontFamily: 'CenturyGothic',
                                                                fontWeight: player.id == authorizedUser.id ? FontWeight.w700 : FontWeight.w400
                                                              )
                                                            ),
                                                          ],
                                                        ),
                                              
                                                        //BUTTON:    VOTE'
                                                        Row(
                                                          children: [
                                                            Padding(
                                                              padding: EdgeInsets.only(right: 5.w),
                                                              child: Text(
                                                                player.votesOfPlayer == null || player.votesOfPlayer!.isEmpty ? '' : 'x${player.votesOfPlayer!.length}', //! DYNAMIC
                                                                style: TextStyle(
                                                                  fontSize: 15.sp, 
                                                                  // color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                                                  //   ? Colors.black 
                                                                  //   : Colors.white,
                                                                  color: Colors.redAccent,
                                                                  fontFamily: 'CenturyGothic',
                                                                  fontWeight: FontWeight.w700
                                                                )
                                                              ), 
                                                            ),
                                                            
                                                            SizedBox(
                                                              width: (player.id != authorizedUser.id) ? 90.w : 70.w,
                                                              height: (player.id != authorizedUser.id) ? 37.h : 20.h,
                                                              child: (player.id != authorizedUser.id) 
                                                              ? ElevatedButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    if (canIVotePopup(player)) {
                                                                      iVotedPartially = true;
                                                                      toWhomIVotedId = player.id;
                                                                    }
                                                                  });
                                                                  //!
                                                                },
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor: canIVotePopup(player) 
                                                                    ? iVotedPartially && !iVotedCompletely && toWhomIVotedId == player.id
                                                                      ? const Color(0xFFFFB000)
                                                                      : Colors.transparent
                                                                    : toWhomIVotedId == player.id 
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
                                                                  AppLocalizations.of(context)!.choose,
                                                                  //! DYNAMIC
                                                                  style: TextStyle(
                                                                    fontSize: 15.sp,
                                                                    fontFamily: 'CenturyGothic',
                                                                    color: canIVotePopup(player) 
                                                                      ? (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white)
                                                                      : (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4)),
                                                                  ),
                                                                ),
                                                              )
                                                              : Text(
                                                                AppLocalizations.of(context)!.itIsYou,
                                                                style: TextStyle(
                                                                  fontSize: 15.sp,
                                                                  fontFamily: 'CenturyGothic',
                                                                  color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white)
                                                                ),
                                                              )
                                                            ),

                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  //if (index < players.length - 1)
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
                                                if (player.votesOfPlayer != null && player.votesOfPlayer!.isNotEmpty)
                                                  GridView.builder(
                                                    padding: EdgeInsets.only(left: 20.w, top: 5.h, right: player.id == authorizedUser.id ? 10.w : 0.w),
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    shrinkWrap: true,
                                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 5.h,
                                                      mainAxisExtent: 40.h,
                                                    ),
                                                    itemCount: player.votesOfPlayer!.length,
                                                    itemBuilder: (context, index) {
                                                      final voter = player.votesOfPlayer![index];
                                                  
                                                      final playerData = widget.inGamePlayers.value.firstWhere(
                                                        (e) => e.id == voter,
                                                      );
                                                  
                                                      return Row(
                                                        children: [
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              border: Border.all(
                                                                color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white),
                                                                width: 1.sp,
                                                              ),
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: CircleAvatar(
                                                              radius: 15.r,
                                                              backgroundImage: NetworkImage(playerData.avatarUrl!),
                                                            ),
                                                          ),
                                                          SizedBox(width: 8.w),
                                                          SizedBox(
                                                            width: 80.w,
                                                            child: Text(
                                                              widget.inGamePlayers.value.firstWhere((e) => e.id == voter).nickname,
                                                              textAlign: TextAlign.center,
                                                              softWrap: true,
                                                              maxLines: 2,
                                                              style: TextStyle(
                                                                height: 0,
                                                                fontSize: 15.sp,
                                                                fontFamily: 'CenturyGothic',
                                                                color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  )
                                                else
                                                  const SizedBox(),
                                                // Row(
                                                //   children: [
                                                //     CircleAvatar(
                                                //       backgroundImage: NetworkImage(widget.inGamePlayers.value.firstWhere((e) => e.nickname == player.votesOfPlayer?[0]).avatarUrl!),
                                                //       //backgroundImage: NetworkImage("https://www.w3schools.com/w3images/avatar6.png"),
                                                //       radius: 15,
                                                //     ),
                                                //     SizedBox(width: 5.w),
                                                //     Text(
                                                //       player.votesOfPlayer![0], 
                                                //       style: TextStyle(
                                                //         fontSize: 15.sp,
                                                //         fontFamily: 'CenturyGothic',
                                                //         color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white),
                                                //       ),
                                                //     ),
                                                //   ],
                                                // )
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
                                            widget.iVoted.value = true;
                                          });
                                  
                                          if (widget.role.toLowerCase() == 'kamikaze') {
                                            widget.useSkill([toWhomIVotedId], true);
                                            return;
                                          }
                                          widget.votePlayer(toWhomIVotedId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(34.r),
                                            side: BorderSide(
                                              color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                                                ? Colors.black 
                                                : Colors.white,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        
                                        child: Text(
                                          widget.role.toLowerCase() == 'kamikaze' ? AppLocalizations.of(context)!.bombard : AppLocalizations.of(context)!.myMoveIsMade ,
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
                                   "I accept the weight of my choice",
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
  final List<int> toWhomIUsedSkillId;
  
  final ValueNotifier<int> timerNotifier;
  final ValueNotifier<List<InGamePlayer>> inGamePlayers;

  final void Function(List<int> influencedBySkillPlayersId, bool state) useSkill;

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
    required this.toWhomIUsedSkillId,
    required this.aliveCivilianCount
  });

  @override
  State<SkillPopup> createState() => _SkillPopupState();
}

class _SkillPopupState extends State<SkillPopup> {
  List<int> toWhomIVotedNow = [];
  bool tempStateIUsedSkill = false;

  Iterable<InGamePlayer> filteredPlayers = [];

  bool isPopupClosed = false;

  void sleep(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  bool isSkillButtonEnabled() {
    return widget.role == 'Journalist'
    ? toWhomIVotedNow.length < 2
    : toWhomIVotedNow.isEmpty;
  }

  void closePopup() {
    Navigator.pop(context);
  }

  bool delayStarted = false;

  @override
  void initState() {
    super.initState();
    widget.timerNotifier.addListener(handleTimerChange);
    filteredPlayers = widget.inGamePlayers.value.where((p) => p.id != authorizedUser.id);
  }

  void handleTimerChange() {
    final time = widget.timerNotifier.value;

    if (time == 0 && !isPopupClosed) {
      isPopupClosed = true;

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    widget.timerNotifier.removeListener(handleTimerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Map<String, String> rolesSkills = {
      'doctor': AppLocalizations.of(context)!.cure,
      'beauty': AppLocalizations.of(context)!.satisfy,
      'bodyguard': AppLocalizations.of(context)!.protect,
      'barman': AppLocalizations.of(context)!.intoxicate,
      'informant': AppLocalizations.of(context)!.reveale,
      'sheriff': AppLocalizations.of(context)!.investigate,
      'journalist': AppLocalizations.of(context)!.interview,
    };

    Map<String, String> skillsDescriptions = {
      'doctor': AppLocalizations.of(context)!.skillsDescriptionsDoctor,
      'beauty': AppLocalizations.of(context)!.skillsDescriptionsBeauty,
      'bodyguard': AppLocalizations.of(context)!.skillsDescriptionsBodyguard,
      'barman': AppLocalizations.of(context)!.skillsDescriptionsBarman,
      'informant': AppLocalizations.of(context)!.skillsDescriptionsInformant,
      'sheriff': AppLocalizations.of(context)!.skillsDescriptionsSheriff,
      'journalist': AppLocalizations.of(context)!.skillsDescriptionsJournalist,
    };

    String skillDescription = skillsDescriptions[widget.role.toLowerCase()] ?? AppLocalizations.of(context)!.choose;

    bool fromMafiaTeam = ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.role.toLowerCase());

    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          height: MediaQuery.of(context).size.height * 0.73,
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
                height: skillDescription.length > 75 ? 200.h : 190.h,
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
                          SizedBox(width: 15.w),

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

                          // //BUTTON:    X
                          Padding(
                            padding: EdgeInsets.only(top: 5.h, right: 5.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (widget.timerNotifier.value > 1) {
                                      PopupManager().close('skillPopup');
                                    }
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
                        height: skillDescription.length > 75 ? 88.h : 68.h,
                        width: double.maxFinite,
                        color: const Color(0xFFFFAB00),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center, 
                          children: [
                            // TEXT:    Descrription of the Skill
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: skillDescription.length > 67 ? 5.w : 40.w),
                              child: Text(
                                skillDescription,
                                textAlign: TextAlign.center,
                                
                                style: TextStyle(
                                  height: 0,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: const Color(0xFF000000),
                                ),
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
                                    Future.delayed(const Duration(milliseconds: 0), () {
                                      if (!mounted) return;
                                      if (Navigator.of(context).canPop()) {
                                        PopupManager().close('skillPopup');
                                      }
                                    });
                                  });
                                }

                                return Text(
                                  '$minutes:${seconds.toString().padLeft(2, '0')}',
                                  style: TextStyle(
                                    height: 0,
                                    fontSize: 15.sp,
                                    fontFamily: 'CenturyGothic',
                                    color: const Color(0xFF000000)
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
                        "I've Choosen. No Regrets",
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
                      itemCount: value.length - 1,
                      itemBuilder: (context, index) {
                        final player = value[index + 1];

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
                                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 25.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        // Container(
                                        //   decoration: BoxDecoration(
                                        //     borderRadius: BorderRadius.circular(50.r),
                                        //     border: Border.all(
                                        //       width: 1.w,
                                        //       color: const Color(0xFFFFFFFF)
                                        //     )
                                        //   ),
                                        //   child: CircleAvatar(
                                        //     backgroundImage: NetworkImage(player.avatarUrl!), //!!!!!!!!!!!
                                        //     radius: 15.sp,
                                        //   ),
                                        // ),
                                        //? Role Card
                                        Stack(
                                          children: [
                                            RoleCard(
                                              roleName: player.isRevealed ? player.role!.toLowerCase() : 'noname',
                                              width: 30.w,
                                              height: 30.h,
                                              isMini: true,
                                              enabled: false,
                                            ),

                                            if (!player.isAlive)
                                              Positioned(
                                                top: 1,
                                                left: 4,
                                                child: IgnorePointer(
                                                  child: Image.asset(
                                                    'assets/images/blood-effect.png',
                                                    width: 20.w,
                                                    height: 26.h,
                                                    fit: BoxFit.fill,
                                                    alignment: Alignment.topRight,
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                  
                                        SizedBox(width: 5.w),

                                        // TEXT:    Player Nickname
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
                                    (player.id == authorizedUser.id)
                                    ? Text(
                                      AppLocalizations.of(context)!.itIsYou,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'CenturyGothic',
                                        color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white)
                                      ),
                                    )
                                    : Row(
                                      children: [         
                                        SizedBox(
                                          width: 100.w,
                                          height: 37.h,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if (!widget.canIUseSkill) {
                                                return;
                                              }
                                              if (tempStateIUsedSkill || widget.iUsedSkill) {
                                                return;
                                              }
                                              if (toWhomIVotedNow.contains(player.id)) {
                                                return;
                                              }
                                              if (widget.toWhomIUsedSkillId.contains(player.id)) {
                                                return;
                                              }
                                              if (!player.isAlive) {
                                                return;
                                              }
                                              
                                              // for (var nick in widget.toWhomIUsedSkill) {
                                              //   log('toWhomIUsedSkill: $nick');
                                              // }
                                              // print('iUsedSkill: ${widget.iUsedSkill}');
                                              toWhomIVotedNow.add(player.id);

                                              if (widget.role != 'Journalist') {
                                                tempStateIUsedSkill = true;
                                                setState(() {
                                                  widget.useSkill(toWhomIVotedNow, true);
                                                });
                                                Future.delayed(const Duration(milliseconds: 200), () {
                                                  if (Navigator.of(context).canPop()) {
                                                    PopupManager().close('skillPopup');
                                                  }
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
                                                  Future.delayed(const Duration(milliseconds: 200), () {
                                                    if (Navigator.of(context).canPop()) {
                                                      PopupManager().close('skillPopup');
                                                    }
                                                  });
                                                }
                                              }
                                              
                                              //Navigator.of(context).pop();

                                              // print('---------------------------');
                                              // for (var nick in toWhomIVotedNow) {
                                              //   print('toWhomIUsedSkill: $nick');
                                              // }
                                              // print('+++++++++++++++++++++++++++');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: toWhomIVotedNow.contains(player.id) && player.isAlive ? const Color(0xFFFFB000) : Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(34.r),
                                                side: BorderSide(
                                                  color: (!tempStateIUsedSkill && !widget.iUsedSkill) && !widget.toWhomIUsedSkillId.contains(player.id) && player.isAlive
                                                    ? (!fromMafiaTeam ? Colors.black : Colors.white)
                                                    : (!fromMafiaTeam ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4)),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            
                                            child: Text(
                                              rolesSkills[widget.role.toLowerCase()] ?? AppLocalizations.of(context)!.choose,
                                              //! DYNAMIC
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily: 'CenturyGothic',
                                                color: (!tempStateIUsedSkill && !widget.iUsedSkill) && !widget.toWhomIUsedSkillId.contains(player.id) && player.isAlive
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
  final int id;
  final String nickname;
  bool isAlive;
  String? role;
  String? avatarUrl;
  bool? isMarked;

  PlayersFromAfk({
    required this.id,
    required this.nickname, 
    required this.isAlive, 
    required this.role,
    required this.avatarUrl,
    required this.isMarked
  });

  factory PlayersFromAfk.fromJson(Map<String, dynamic> json) {

    return PlayersFromAfk(
      id: json['id'],
      nickname: json['nickname'],
      isAlive: json['isAlive'],    
      role: json['role'],    
      avatarUrl: json['avatarUrl'], 
      isMarked: json['effectApplied'],
    );
  }
}

class Vote {
  final int fromId;
  final int targetId;

  Vote({required this.fromId, required this.targetId});

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      fromId: json['fromId'] ?? 0,
      targetId: json['targetId'] ?? 0,
    );
  }
}


class RoleTooltipCard extends StatefulWidget {
  final String roleName;
  final bool isAlive;
  final bool isRevealed;

  const RoleTooltipCard({
    required this.roleName,
    required this.isAlive,
    required this.isRevealed,
    super.key,
  });

  @override
  State<RoleTooltipCard> createState() => _RoleTooltipCardState();
}

class _RoleTooltipCardState extends State<RoleTooltipCard> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  Map<String, String> get rolesLocalizaitons => {
    'mafia': AppLocalizations.of(context)!.mafia,
    'civilian': AppLocalizations.of(context)!.civilian,
    'spy': AppLocalizations.of(context)!.spy,
    'doctor': AppLocalizations.of(context)!.doctor,
    'beauty': AppLocalizations.of(context)!.beauty,
    'bodyguard': AppLocalizations.of(context)!.bodyguard,
    'barman': AppLocalizations.of(context)!.barman,
    'informant': AppLocalizations.of(context)!.informant,
    'sheriff': AppLocalizations.of(context)!.sheriff,
    'journalist': AppLocalizations.of(context)!.journalist,
    'kamikaze': AppLocalizations.of(context)!.kamikaze,
    'undef': AppLocalizations.of(context)!.uknown
  };

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx + renderBox.size.width / 2 - 40,
          top: offset.dy - 40,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      widget.isRevealed || !widget.isAlive ? rolesLocalizaitons[widget.roleName.toLowerCase()]! : AppLocalizations.of(context)!.uknown,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    _controller.forward();

    // Auto hide
    Future.delayed(const Duration(seconds: 1), () => _hideTooltip());
  }

  void _hideTooltip() async {
    if (_overlayEntry == null) return;
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_overlayEntry != null) {
          _hideTooltip();
        } else {
          _showTooltip();
        }
      },
      child: Opacity(
        opacity: widget.isAlive ? 1.0 : 0.5,
        child: Image.asset(
          widget.isRevealed || !widget.isAlive
              ? 'assets/images/role-card-${widget.roleName.toLowerCase()}.png'
              : 'assets/images/role-card-noname.png',
          width: 60.w,
          height: 78.h,
        ),
      ),
    );
  }
}


class NoIconExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;
  final bool canExpand;

  const NoIconExpansionTile({
    Key? key,
    required this.title,
    required this.children, 
    required this.canExpand,
  }) : super(key: key);

  @override
  State<NoIconExpansionTile> createState() => _NoIconExpansionTileState();
}

class _NoIconExpansionTileState extends State<NoIconExpansionTile>
    with SingleTickerProviderStateMixin {

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,  // <— важный момент!
          onTap: () => {
            if (widget.canExpand) setState(() => _expanded = !_expanded)
          },
          child: widget.title,  // полностью твой layout, без ListTile
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: _expanded
              ? Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: widget.children,
                  ),
              )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}


class PopupManager {
  // Singleton pattern
  static final PopupManager _instance = PopupManager._internal();
  factory PopupManager() => _instance;
  PopupManager._internal();

  final Map<String, _PopupData> _popupMap = {};

  Future<T?> show<T>({
    required BuildContext context,
    required String id,
    required WidgetBuilder builder,
    bool dismissOnTapOutside = true,
    Duration duration = const Duration(milliseconds: 800),
    Offset slideBegin = const Offset(-1.0, 0),
    Curve curve = Curves.elasticOut,
    Curve reverseCurve = Curves.easeInBack,
  }) {
     if (_popupMap.containsKey(id)) {
      return (_popupMap[id] as _PopupData<T>).completer.future;
    }

    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return Future.value(null);

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

    final completer = Completer<T?>();

    final entry = OverlayEntry(
      builder: (_) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: dismissOnTapOutside ? () => close(id) : null,
        child: Material(
          color: Colors.black.withOpacity(0.7),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (dismissOnTapOutside) close(id);
            },
            child: SlideTransition(
              position: slideAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: () {}, // Prevent closing on inner tap
                  child: builder(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    controller.forward();

    _popupMap[id] = _PopupData<T>(entry, controller, completer);

    return completer.future;
  }

  void closeWithResult<T>(String id, T result) {
    try {
      final popup = _popupMap[id] as _PopupData<T>?;
      if (popup == null) return;
      
      popup.completer.complete(result);
      
      popup.controller.reverse().then((_) {
        popup.entry.remove();
        popup.controller.dispose();
        _popupMap.remove(id);
      });
    } catch (e) {
      log('💥 Close With Result Error - $e - Popup Manager 💥');
    }
  }


  void close(String id) {
    try {
      final popup = _popupMap[id];
      if (popup == null) return;
      
      popup.completer.complete(null);
      
      popup.controller.reverse().then((_) {
        popup.entry.remove();
        popup.controller.dispose();
        _popupMap.remove(id);
      });
    } catch (e) {
      log('💥 Close Error - $e - Popup Manager 💥');
    }
  }

  void closeAll() {
    try {
      for (final id in _popupMap.keys.toList()) {
        close(id);
      }
    } catch (e) {
      log('💥 Close All Error - $e - Popup Manager 💥');
    }
  }
}

class _PopupData<T> {
  final OverlayEntry entry;
  final AnimationController controller;
  final Completer<T?> completer;

  _PopupData(this.entry, this.controller, this.completer);
}
