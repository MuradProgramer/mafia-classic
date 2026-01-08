import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/features/profile/ratings-/view/ratings_screen.dart';
//import 'package:mafia_classic/features/profile/ratings/view/ratings_screen.dart';
import 'package:mafia_classic/features/profile/roles/view/roles_screen.dart';
import 'package:mafia_classic/features/settings/view/settings_screen.dart';
import 'package:mafia_classic/features/widgets/player_info_popup.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/models/models.dart' hide Message;
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  final String title = 'MAFIA CLASSIC';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late StreamSubscription<String> friendshipFriends;
  late StreamSubscription<String> friendshipNewFriend;
  late StreamSubscription<String> friendshipRequestFriendship;
  late StreamSubscription<String> friendshipDeleteFriendship;
  late StreamSubscription<String> friendshipFriendOnline;
  late StreamSubscription<String> friendshipFriendOffline;
  late StreamSubscription<String> friendshipFriendJoinedRoom;
  late StreamSubscription<String> friendshipFriendLeftRoom;
  late StreamSubscription<String> friendshipFriendNewMessage; 

  @override
  void initState() {

    friendshipFriends = EventRouterService()
        .subscribe(ServerEvent.friendshipFriends)
        .listen((payload) async {
      try {
        final List<dynamic> jsonData = json.decode(payload)['friends'];
        List<Friendship> allFriends = [];
        for (var item in jsonData) {
          try {
            if (item is Map<String, dynamic>) {
              allFriends.add(Friendship.fromJson(item));
            } else {
              log('Skipping malformed friend data: $item');
            }
          } catch (e) {
            log('Error parsing single friend item $item: ${e.toString()}');
          }
        }

        await GeneralCacheService().save('all_friends_list', allFriends);
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriends: ${e.toString()}');
      }
    });

    friendshipNewFriend = EventRouterService()
        .subscribe(ServerEvent.friendshipNewFriend)
        .listen((payload) async {
      try {
        final Map<String, dynamic> jsonData = json.decode(payload)['friend'];

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
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipNewFriend: ${e.toString()}');
      }
    });

    friendshipRequestFriendship = EventRouterService()
        .subscribe(ServerEvent.friendshipRequestFriendship)
        .listen((payload) async {
      print("SNACKBAR: REQUEST FRIENDSHIP RECEIVED");
      EventBus().fire(FriendRequestReceivedEvent(json.decode(payload)));
    });

    friendshipDeleteFriendship = EventRouterService()
        .subscribe(ServerEvent.friendshipDeleteFriendship)
        .listen((payload) async {
      try {
        final String nicknameToDelete = json.decode(payload)['nickname'];

        List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
          "all_friends_list",
          (json) => Friendship.fromJson(json as Map<String, dynamic>),
        );

        currentFriends ??= [];
        currentFriends.removeWhere((friend) => friend.nickname == nicknameToDelete);
        EventBus().fire(DeleteFriendEvent(nicknameToDelete));
        await GeneralCacheService().save<List<Friendship>?>("all_friends_list", currentFriends);
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipDeleteFriendship: ${e.toString()}');
      }
    });

    friendshipFriendOnline = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendOnline)
        .listen((payload) async {
      try {
        final String nicknameOnline = json.decode(payload)['nickname'];

        List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
          "all_friends_list",
          (json) => Friendship.fromJson(json as Map<String, dynamic>),
        );

        currentFriends ??= [];
        currentFriends.firstWhere((friend) => friend.nickname == nicknameOnline).isOnline = true;
        EventBus().fire(FriendOnlineEvent(nicknameOnline));
        await GeneralCacheService().save<List<Friendship>?>("all_friends_list", currentFriends);
        
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriendOnline: ${e.toString()}');
      }
    });

    friendshipFriendOffline = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendOffline)
        .listen((payload) async {
      try {
        final String nicknameOffline = json.decode(payload)['nickname'];

        List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
          "all_friends_list",
          (json) => Friendship.fromJson(json as Map<String, dynamic>),
        );

        currentFriends ??= [];
        currentFriends.firstWhere((friend) => friend.nickname == nicknameOffline).isOnline = false;
        EventBus().fire(FriendOfflineEvent(nicknameOffline));
        await GeneralCacheService().save<List<Friendship>?>("all_friends_list", currentFriends);
        
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriendOffline: ${e.toString()}');
      }
    });

    friendshipFriendJoinedRoom = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendJoinedRoom)
        .listen((payload) async {
      try {
        final String nicknameJoined = json.decode(payload)['nickname'];
        final String roomTitle = json.decode(payload)['roomTitle'];

        List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
          "all_friends_list",
          (json) => Friendship.fromJson(json as Map<String, dynamic>),
        );

        currentFriends ??= [];
        currentFriends.firstWhere((friend) => friend.nickname == nicknameJoined).gameTitle = roomTitle;

        //EventBus().fire(FriendOnlineEvent(nicknameJoined));

        await GeneralCacheService().save<List<Friendship>?>("all_friends_list", currentFriends);
        
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriendJoinedRoom: ${e.toString()}');
      } catch (e) {
        log('EXCEPTION IN:     friendshipFriendJoinedRoom: ${e.toString()}');
      }
    });

    friendshipFriendLeftRoom = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendLeftRoom)
        .listen((payload) async {
      try {
        final String nicknameLeft = json.decode(payload)['nickname'];

        List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
          "all_friends_list",
          (json) => Friendship.fromJson(json as Map<String, dynamic>),
        );

        currentFriends ??= [];
        currentFriends.firstWhere((friend) => friend.nickname == nicknameLeft).gameTitle = "";

        EventBus().fire(FriendOnlineEvent(nicknameLeft));

        await GeneralCacheService().save<List<Friendship>?>("all_friends_list", currentFriends);
        
      } catch (e) {
        log('EXCEPTION IN:     friendshipFriendLeftRoom: ${e.toString()}');
      }
    });

    friendshipFriendNewMessage = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendNewMessage)
        .listen((payload) async {
      try {
        final Map<String, dynamic> jsonData = json.decode(payload);

        final newMessage = Message.fromJson(jsonData);

        //? SNACKBAR HERE

        EventBus().fire(FriendNewMessageEvent(newMessage));
        
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriendNewMessage: ${e.toString()}');
      }
    });

    //TcpClientService().sendMessage(ClientCommand.getFriends.value, "");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final double ornamentSize = 50.sp;
    final double ornamentMargin = 30.sp;
    final double marginButtons = 23.sp;
    const String ornament = "assets/images/game-ornament-night.png";
    final theme = Theme.of(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back navigation
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/temp-home-background.png"), fit: BoxFit.fill, opacity: 1),
        ),
        child: Scaffold(
          /*
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            title: Text(widget.title, style: theme.appBarTheme.titleTextStyle),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          */
          
          body: Container(
            margin: EdgeInsets.only(top: 50.h),
            child: Column(
              children: [
                //? MAFIA CLASSIC TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 125.h,
                      width: 300.w,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Stack(
                        children: [
                          // TEXT:    MAFIA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.mafia,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 55.sp,
                                  height: 0,
                                  color: const Color(0xFFFFB000),
                                ),
                              ),
                            ],
                          ),
                    
                          // TEXT:    CLASSIC
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 70.h),
                                child: Text(
                                  AppLocalizations.of(context)!.classic,
                                  style: TextStyle(
                                    fontSize: 26.sp,
                                    height: 0,
                                    fontFamily: 'CenturyGothic',
                                    fontWeight: FontWeight.w200,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              
                //? WELCOME TEXT
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 285.h),
                      height: 110.h,
                      width: 310.w,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12.0),
                        //border: Border.all(color: Colors.white, width: 1)
                      ),
                      child: Stack(
                        children: [

                          //? ORNAMENTS
                          Stack(
                            children: [
                              Positioned(
                                bottom: ornamentMargin,
                                left: ornamentMargin / 2 + 5,
                                child: Transform.rotate(
                                  angle: -45 * 3.14159 / 180,
                                  child: Image.asset(
                                    ornament,
                                    width: ornamentSize,
                                    height: ornamentSize,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: ornamentMargin,
                                right: ornamentMargin / 2 + 5,
                                child: Transform.rotate(
                                  angle: -225 * 3.14159 / 180,
                                  child: Image.asset(
                                    ornament,
                                    width: ornamentSize,
                                    height: ornamentSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  
                          //? WELCOME
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${AppLocalizations.of(context)!.welcome},",
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 32.sp,
                                      height: 0,
                                      color: const Color(0xFFFFB000),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.user.nickname,
                                    style: GoogleFonts.playfairDisplay(
                                      fontSize: 32.sp,
                                      height: 0,
                                      color: const Color(0xFFFFB000),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )

                        ],
                      ),
                    )
                  ],
                ),
              
                //? BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20.h),
                      height: 150.h,
                      width: 310.w,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12.sp),
                        //border: Border.all(color: Colors.white, width: 1)
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              // BUTTON:    RATING
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RatingsScreen(),
                                    )
                                  );
                                },
                                child: Container(
                                  width: 110.w,
                                  height: 40.h,
                                  margin: EdgeInsets.only(top: marginButtons, left: 30.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(71.sp),
                                    border: Border.all(color: Colors.white, width: 1.5)
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.ratings,
                                      style: TextStyle(
                                        fontSize: 23.sp,
                                        color: Colors.white,
                                        fontFamily: 'CenturyGothic'
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // BUTTON:    SETTINGS
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SettingsScreen(),
                                    )
                                  );
                                },
                                child: Container(
                                  width: 110.w,
                                  height: 40.h,
                                  margin: EdgeInsets.only(top: marginButtons, left: 30.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(71.sp),
                                    border: Border.all(color: Colors.white, width: 1.5)
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.settings,
                                      style: TextStyle(
                                        fontSize: 23.sp,
                                        color: Colors.white,
                                        fontFamily: 'CenturyGothic'
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              // BUTTON:    ROLES
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const RolesScreen(),
                                    )
                                  );
                                },
                                child: Container(
                                  width: 110.w,
                                  height: 40.h,
                                  margin: EdgeInsets.only(top: marginButtons, left: 30.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(71.sp),
                                    border: Border.all(color: Colors.white, width: 1.5)
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.roles,
                                      style: TextStyle(
                                        fontSize: 23.sp,
                                        color: Colors.white,
                                        fontFamily: 'CenturyGothic'
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // BUTTON:    CHAT
                              //!!!!!!!!!!!!!!!!
                              GestureDetector(
                                onTap: () {
                                  showBouncingPopupFromLeft(
                                    context, 
                                    PlayerInfoPopup(
                                      height: 727.h, 
                                      width: 405.w, 
                                      nickname: "Admin",
                                      /*
                                      playerInfo: PlayerInfo(
                                        nickname: 'Tony Stark', 
                                        avatarUrl: 'https://img.freepik.com/premium-vector/mafia-logo_74829-29.jpg', 
                                        isOnline: false, 
                                        lastSeen: DateTime(2025, 8, 15, 17, 36),
                                        joinDate: DateTime.now(), 
                                        friendshipStatus: 'None',
                                        inGameLobby: false, 
                                        
                                        overall: 2429 + 1230, 
                                        wins: 2429, 
                                        loses: 1230, 
                                        mafiaWins: 1120, 
                                        civilianWins: 1309,
                                        playedRoles: {
                                          "Civilian": 177,
                                          "Mafia": 54,
                                          "Doctor": 682,
                                          "Sheriff": 254,
                                          "Bodyguard": 365,
                                          "Beauty": 45,
                                          "Journalist": 24,
                                          "Spy": 76,
                                          "Terrorist": 245,
                                          "Informant": 343,
                                          "Barman": 543
                                        }, 
                                        gameLobbyTitle: null, 
                                        gameLobbyStatus: null, 
                                        gameLobbyPlayerCount: null
                                      ),
                                      */
                                    )
                                  );
                                },
                                child: Container(
                                  width: 110.w,
                                  height: 40.h,
                                  margin: EdgeInsets.only(top: marginButtons, left: 30.w),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(71.sp),
                                    border: Border.all(color: Colors.white, width: 1.5)
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.chat,
                                      style: TextStyle(
                                        fontSize: 23.sp,
                                        color: Colors.white,
                                        fontFamily: 'CenturyGothic'
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    )
                  ],
                )
              ],
            ),
          )
        ),
      ),
    );
  }
}