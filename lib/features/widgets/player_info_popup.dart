import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';

// ignore: must_be_immutable
class PlayerInfoPopup extends StatefulWidget {
  final int id;
  final String nickname;
  final double height;
  final double width;
  //PlayerInfo playerInfo;

  const PlayerInfoPopup({
    super.key, 
    required this.height, 
    required this.width, 
    required this.nickname, 
    required this.id,
    //required this.playerInfo,
  });

  @override
  State<PlayerInfoPopup> createState() => _PlayerInfoPopupState();
}

class _PlayerInfoPopupState extends State<PlayerInfoPopup> {
  PlayerInfo? playerInfo;
  final double ornamentSize = 50.sp;
  final double ornamentMargin = 5.sp;

  final double cardsMargin = 20.w;

  StreamSubscription? _eventSubscriptionFriendOnline;
  StreamSubscription? _eventSubscriptionFriendOffline;
  StreamSubscription? _eventSubscriptionNewFriendMessage;
  StreamSubscription? _eventSubscriptionDeleteFriend;
  StreamSubscription? _eventSubscriptionFriendMessagesReaded;
  StreamSubscription? _eventSubscriptionFriendRequestRecieved;
  StreamSubscription? _eventSubscriptionFriendRequestDeclined;
  StreamSubscription? _eventSubscriptionNewFriendAdded;

  @override
  void initState() {
    super.initState();

    _loadPlayerInfo();
    
    _eventSubscriptionFriendOnline = EventBus().on<FriendOnlineEvent>().listen((event) {
      setState(() {
        playerInfo!.isOnline = true;
      });
    });

    _eventSubscriptionFriendOffline = EventBus().on<FriendOfflineEvent>().listen((event) {
      setState(() {
        playerInfo!.isOnline = false;
        playerInfo!.lastSeen = DateTime.now().toLocal();
      });
    });

    _eventSubscriptionDeleteFriend = EventBus().on<DeleteFriendEvent>().listen((event) {
      setState(() {
        playerInfo!.friendshipStatus = 'None';
      });
    });

    _eventSubscriptionNewFriendMessage = EventBus().on<FriendNewMessageEvent>().listen((event) {
      setState(() {
        playerInfo!.unreadMessagesCount++;
      });
    });

    _eventSubscriptionFriendMessagesReaded = EventBus().on<FriendMessagesReadedEvent>().listen((event) {
      setState(() {
        playerInfo!.unreadMessagesCount = 0;
      });
    });

    _eventSubscriptionNewFriendAdded = EventBus().on<NewFriendAddedEvent>().listen((event) {
      if (event.requestData.id != playerInfo!.id) return;
      setState(() {
        playerInfo!.friendshipStatus = 'Accepted';
      });
    });

    _eventSubscriptionFriendRequestRecieved = EventBus().on<FriendRequestReceivedEvent>().listen((event) {
      if (event.requestData['friendId'] != playerInfo!.id) return;
      setState(() {
        playerInfo!.friendshipStatus = 'ApprovePending';
      });
    });

    _eventSubscriptionFriendRequestDeclined = EventBus().on<FriendRequestDeclinedEvent>().listen((event) {
      if (event.playerId != playerInfo!.id) return;
      setState(() {
        playerInfo!.friendshipStatus = 'None';
      });
    });
  }

  @override
  void dispose() {
    _eventSubscriptionFriendOnline?.cancel();
    _eventSubscriptionFriendOffline?.cancel();
    _eventSubscriptionNewFriendMessage?.cancel();
    _eventSubscriptionDeleteFriend?.cancel();
    _eventSubscriptionFriendMessagesReaded?.cancel();
    _eventSubscriptionNewFriendAdded?.cancel();
    _eventSubscriptionFriendRequestRecieved?.cancel();
    _eventSubscriptionFriendRequestDeclined?.cancel();
    super.dispose();
  }

  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 59) {
      return "less than a minute";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else if (difference.inDays < 31) {
      return "${difference.inDays} days ago";
    } else {
      return DateFormat('dd.MM.yyyy').format(lastSeen.toLocal());
    }
  }

  void _loadPlayerInfo() async {
    final playerInfoData = await GetIt.I<ApiService>().getPlayerInfo(widget.id);
    print(playerInfoData.toString());
    setState(() {
      playerInfo = PlayerInfo.from(playerInfoData);
    });
    print('-----------------');
    print(playerInfo.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (playerInfo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Align(
      alignment: Alignment.center,
      child: Container(
        margin: EdgeInsets.only(top: 10.h),
        height: widget.height,
        width: widget.width,
        child: Material(
          color: Colors.transparent,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              image: DecorationImage(image: AssetImage('assets/images/background_player_info_popup.png'), fit: BoxFit.fill)
            ),
            child: Container(
              margin: EdgeInsets.only(top: 5.h, bottom: 15.h, left: 5.w, right: 5.w),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: const Color(0xFF2A2723),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
            
                  //? ORNAMENTS
                  Stack(
                    children: [
                      // Top-left ornament
                      Positioned(
                        top: ornamentMargin,
                        left: ornamentMargin,
                        child: Image.asset(
                          "assets/images/game-ornament-day.png",
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
                            "assets/images/game-ornament-day.png",
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
                            "assets/images/game-ornament-day.png",
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
                            "assets/images/game-ornament-day.png",
                            width: ornamentSize,
                            height: ornamentSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  //? CONTENT
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF2A2723),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(85.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TEXT:    Profile
                        Text(
                          S.of(context).profile,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.sp,
                            color: const Color(0xFF000000)
                          )
                        ),
                    
                        //? OLINE STATUS  |  AVATAR  |  JOIN DATE
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //? ONLINE STATUS
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      //? BADGE
                                      Container(
                                        height: 20.h,
                                        width: 20.w,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: playerInfo!.isOnline ? const Color(0xFF896A44) : const Color(0xFF9D9D9D),
                                          border: Border.all(
                                            color: playerInfo!.isOnline ? const Color(0xFFB98744) : const Color(0xFFD6D6D6),
                                            width: 2.sp
                                          )
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.star,
                                            size: 13.sp,
                                            color: Colors.white
                                          ),
                                        ),
                                      ),
                                  
                                      SizedBox(width: 4.w),
                                  
                                      // TEXT:    IS ONLINE
                                      Text(
                                        playerInfo!.isOnline ? S.of(context).online : S.of(context).offline,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                
                                  //? LAST SEEN
                                  playerInfo!.isOnline
                                  ? const SizedBox()
                                  : Text(
                                    formatLastSeen(playerInfo!.lastSeen!),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'CenturyGothic',
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black
                                    ),
                                  )
                                ],
                              ),

                              //? AVATAR
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(35.sp),
                                ),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    playerInfo!.avatarUrl
                                  ),
                                  radius: 35.sp,
                                )
                              ),
                          
                              //? JOIN DATE
                              Column(
                                children: [
                                  // TEXT:    JOIN DATE
                                  Text(
                                    S.of(context).joinDate,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'CenturyGothic',
                                      color: Colors.black,
                                      height: 0
                                    )
                                  ),
                                  
                                  //? JOIN DATE
                                  Text(
                                    DateFormat('dd.MM.yyyy').format(playerInfo!.joinDate),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'CenturyGothic',
                                      color: Colors.black,
                                      height: 0
                                    )
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      
                        //? NICKNAME
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            playerInfo!.nickname,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20.sp,
                              color: Colors.black
                            ),
                          ),
                        ),
                    
                        //? REPORT  |  ADD FRIENDS  |  CHAT
                        Padding(
                          padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.h, bottom: 5.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // BUTTON:    REPORT
                              GestureDetector(
                                child: Container(
                                  width: 70.h,
                                  height: 35.h,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp)
                                  ),
                                  child: Center(
                                    child: Text(
                                      S.of(context).report,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'CenturyGothic',
                                        color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          
                              //? FRIENDSHIP STATUS
                              playerInfo!.friendshipStatus == 'None'
                              ? GestureDetector(
                                onTap: () async {
                                  await GetIt.I<ApiService>().sendRequest(playerInfo!.id);
                                  _loadPlayerInfo();
                                },
                                child: Container(
                                  height: 35.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp)
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                                      child: Text(
                                        S.of(context).addToFriends,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : playerInfo!.friendshipStatus == 'Accepted' 
                              ? 
                              // BUTTON:   DELETE FRIEND
                              GestureDetector(
                                onTap: () async {
                                  await GetIt.I<ApiService>().deleteFriend(playerInfo!.id);
                                  _loadPlayerInfo();
                                },
                                child: Container(
                                  height: 35.h,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp)
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                                      child: Text(
                                        "Delete friend",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              : playerInfo!.friendshipStatus == 'ApprovePending'
                              ?
                                //? BUTTONS:     REJECT AND ACCEPT
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          playerInfo!.friendshipStatus = 'Accepted';
                                        });
                                        await GetIt.I<ApiService>().approveFriend(playerInfo!.id, true);
                                      },
                                      child: Icon(
                                        Icons.handshake_outlined,
                                        color: const Color(0xFF302B25),
                                        size: 30.sp,
                                      )
                                    ),
                                    SizedBox(width: 5.w),
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          playerInfo!.friendshipStatus = 'None';
                                        });
                                        await GetIt.I<ApiService>().approveFriend(playerInfo!.id, false);
                                      },
                                      child: Container(
                                        width: 30.w,
                                        height: 30.h,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF302B25),
                                          borderRadius: BorderRadius.circular(5.sp),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        child: Center(
                                          child: Container(
                                            height: 5.h,
                                            width: 20.w,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0D0BC),
                                              borderRadius: BorderRadius.circular(5.sp),
                                            ),
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                )
                              
                              :
                              Text(
                                playerInfo!.friendshipStatus,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black
                                ),
                              ),
                    
                              // BUTTON:    CHAT
                              if (playerInfo!.friendshipStatus == 'Accepted')
                              SizedBox(
                                height: 45.h,
                                child: GestureDetector(
                                  onTap: () {
                                    //if (playerInfo!.friendshipStatus != 'Accepted') return;
                                    playerInfo!.unreadMessagesCount = 0;
                                    setState(() {});
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FriendChat(
                                          friend: Friendship(
                                            id: playerInfo!.id,
                                            nickname: playerInfo!.nickname, 
                                            avatarUrl: playerInfo!.avatarUrl,
                                            isOnline: playerInfo!.isOnline,
                                            gameTitle: playerInfo!.gameLobbyTitle ?? '',
                                            lastSeen: playerInfo!.lastSeen ?? DateTime.now()
                                          )
                                        ),
                                      ),
                                    ).then((_) async {
                                      List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
                                        "all_friends_list",
                                        (json) => Friendship.fromJson(json as Map<String, dynamic>),
                                      );

                                      currentFriends ??= [];
                                      currentFriends.firstWhere((friend) => friend.id == playerInfo!.id).unreadMessagesCount = 0;

                                      await GeneralCacheService().save<List<Friendship>?>(
                                        "all_friends_list",
                                        currentFriends,
                                      );

                                      playerInfo!.unreadMessagesCount = 0;
                                      setState(() {});
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      // BUTTON:    CHAT
                                      Container(
                                        width: 70.h,
                                        height: 35.h,
                                        margin: EdgeInsets.only(top: 5.h, right: 5.w),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB000),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1
                                          ),
                                          borderRadius: BorderRadius.circular(12.sp)
                                        ),
                                        child: Center(
                                          child: Text(
                                            S.of(context).chat,
                                            style: TextStyle(
                                              fontSize: 15.sp,
                                              fontFamily: 'CenturyGothic',
                                              color: Colors.black
                                            ),
                                          ),
                                        ),
                                      ),
                                
                                      //? UNREAD MESSAGES COUNT
                                      if (playerInfo!.unreadMessagesCount > 0)
                                        Positioned(
                                          right: 0.w,
                                          top: -5.h,
                                          child: Container(
                                            padding: EdgeInsets.all(4.w),
                                            constraints: BoxConstraints(
                                              minWidth: 16.w,
                                              minHeight: 16.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1.5.w),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "",
                                                style: TextStyle(
                                                  color: Colors.white ,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'CenturyGothic',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ),
                        ),
                    
                        //? DIVIDER
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Divider(
                            thickness: 2.h,
                            color: const Color(0xFF494239),
                          ),
                        ),
                      
                        //? CURRENT GAME
                        !playerInfo!.inGameLobby
                        ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            playerInfo!.isOnline ? "Currently is not in a room" : S.of(context).currentlyOffline,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20.sp,
                              color: const Color(0xFF4F4F4F)
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                S.of(context).currentlyArePlayingIn,
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20.sp,
                                  color: const Color(0xFF4F4F4F)
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 5.h, bottom: 5.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //? GAME TITLE AND GAME STATUS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //? GAME TITLE
                                      Container(
                                        height: 27.h,
                                        width: 160.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFAF977E),
                                          borderRadius: BorderRadius.circular(12.sp)
                                        ),
                                        child: Align(
                                          alignment: Alignment.topCenter,
                                          child: Text(
                                            playerInfo!.gameLobbyTitle!,
                                            style: GoogleFonts.playfairDisplay(
                                              fontSize: 20.sp,
                                              color: Colors.black
                                            )
                                          ),
                                        ),
                                      ),
                              
                                      SizedBox(height: 5.h),
                              
                                      //? GAME STATUS
                                      Container(
                                        height: 22.h,
                                        width: 112.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(12.sp)
                                        ),
                                        child: Center(
                                          child: Text(
                                            playerInfo!.gameLobbyStatus!,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFFFFB000)
                                            )
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: Column(
                                      children: [
                                        //? PLAYER COUNT
                                        Text(
                                          playerInfo!.gameLobbyPlayerCount!.toString(),
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 20.sp,
                                            color: Colors.black
                                          )
                                        ),
                                    
                                        // TEXT:    Players in total
                                        Text(
                                          S.of(context).playersInTotal,
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontFamily: 'CenturyGothic',
                                            color: Colors.black
                                          )
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )

                          ],
                        ),
                      
                        //? DIVIDER
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Divider(
                            thickness: 2.h,
                            color: const Color(0xFF494239),
                          ),
                        ),
                      
                        ////? STATS
                        // TEXT:    STATS
                        Text(
                          S.of(context).stats,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20.sp,
                            color: Colors.black
                          ),
                        ),
                        
                        //? OVERALL STATS
                        Container(
                          height: 27.h,
                          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAF977E),
                            borderRadius: BorderRadius.circular(12.sp)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // TEXT:    OVERALL
                              Text(
                                S.of(context).overall,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black
                                ),
                              ),

                              SizedBox(width: 50.w,),

                              //? OVERALL STATS
                              Text(
                                playerInfo!.overall.toString(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                        //? SPECIFIC STATS
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //? WINS AND LOSES
                              Row(
                                children: [
                                  //? TEXTS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TEXT:    WINS
                                      Text(
                                        S.of(context).wins,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      // TEXT:    WINS
                                      Text(
                                        S.of(context).loses,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                                        
                                  SizedBox(width: 12.w),
                                
                                  //? DIVIDER
                                  Container(
                                    width: 2.w,
                                    height: 45.h,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: const Color(0xFF494239),
                                          width: 2.w
                                        )
                                      )
                                    ),
                                  ),
                                                        
                                  SizedBox(width: 12.w),
                                                        
                                  //? STATS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //? WINS
                                      Text(
                                        playerInfo!.wins.toString(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      //? LOSES
                                      Text(
                                        playerInfo!.loses.toString(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),

                              //? TEAM WINS
                              Row(
                                children: [
                                  //? TEXTS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TEXT:    MAFIA WINS
                                      Text(
                                        S.of(context).mafiaWins,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      // TEXT:    CIVILIAN WINS
                                      Text(
                                        S.of(context).civilianWins,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                                        
                                  SizedBox(width: 12.w),
                                
                                  //? DIVIDER
                                  Container(
                                    width: 2.w,
                                    height: 45.h,
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: const Color(0xFF494239),
                                          width: 2.w
                                        )
                                      )
                                    ),
                                  ),
                                                        
                                  SizedBox(width: 12.w),
                                                        
                                  //? STATS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //? MAFIA WINS
                                      Text(
                                        playerInfo!.mafiaWins.toString(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      //? CIVILIAN WINS
                                      Text(
                                        playerInfo!.civilianWins.toString(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        //? DIVIDER
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Divider(
                            thickness: 2.h,
                            color: const Color(0xFF494239),
                          ),
                        ),
                      
                        // TEXT:    PLAYED ROLES
                        Text(
                          S.of(context).playedRoles,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20.sp,
                            color: Colors.black
                          )
                        ),

                        SizedBox(height: 10.h),
                        
                        //? PLAYED ROLES - CIVILIAN TEAM
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //? CIVILIAN
                            WinRole(role: 'Civilian', winCount: playerInfo!.civilianRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? DOCTOR
                            WinRole(role: 'Doctor', winCount: playerInfo!.doctorRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? SHERIFF
                            WinRole(role: 'Sheriff', winCount: playerInfo!.sheriffRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? BODYGUARD
                            WinRole(role: 'Bodyguard', winCount: playerInfo!.bodyguardRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? BEAUTY
                            WinRole(role: 'Beauty', winCount: playerInfo!.beautyRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? JOURNALIST
                            WinRole(role: 'Journalist', winCount: playerInfo!.journalistRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? SPY
                            WinRole(role: 'Spy', winCount: playerInfo!.spyRolePlayedGames),
                          ],
                        ),
                      
                        SizedBox(height: 10.h),

                        //? PLAYED ROLES - MAFIA TEAM
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //? MAFIA
                            WinRole(role: 'Mafia', winCount: playerInfo!.mafiaRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? TERRORIST
                            WinRole(role: 'Terrorist', winCount: playerInfo!.terroristRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? INFORMANT
                            WinRole(role: 'Informant', winCount: playerInfo!.informantRolePlayedGames),
                            SizedBox(width: cardsMargin),

                            //? BARMAN
                            WinRole(role: 'Barman', winCount: playerInfo!.barmanRolePlayedGames)
                          ],
                        )
                      
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerInfo {
  final int id;
  final String nickname;
  final String avatarUrl;
  bool isOnline;
  DateTime? lastSeen;
  final DateTime joinDate;
  String friendshipStatus;
  final String? gameLobbyTitle;
  final String? gameLobbyStatus;
  final int? gameLobbyPlayerCount;
  final bool inGameLobby;
  final int overall;
  final int wins;
  final int loses;
  final int mafiaWins;
  final int civilianWins;
  int unreadMessagesCount;
  
  final int civilianRolePlayedGames;
  final int sheriffRolePlayedGames;
  final int doctorRolePlayedGames;
  final int beautyRolePlayedGames;
  final int bodyguardRolePlayedGames;
  final int spyRolePlayedGames;
  final int journalistRolePlayedGames;
  final int mafiaRolePlayedGames;
  final int informantRolePlayedGames;
  final int barmanRolePlayedGames;
  final int terroristRolePlayedGames;

  PlayerInfo({
    required this.civilianRolePlayedGames, 
    required this.sheriffRolePlayedGames, 
    required this.doctorRolePlayedGames, 
    required this.beautyRolePlayedGames, 
    required this.bodyguardRolePlayedGames,
    required this.spyRolePlayedGames, 
    required this.journalistRolePlayedGames, 
    required this.mafiaRolePlayedGames, 
    required this.informantRolePlayedGames, 
    required this.barmanRolePlayedGames, 
    required this.terroristRolePlayedGames,

    required this.id,
    required this.nickname, 
    required this.avatarUrl, 
    required this.isOnline, 
    required this.lastSeen, 
    required this.joinDate, 
    required this.friendshipStatus, 
    required this.inGameLobby, 
    required this.overall, 
    required this.wins, 
    required this.loses, 
    required this.mafiaWins, 
    required this.civilianWins, 
    required this.gameLobbyTitle, 
    required this.gameLobbyStatus, 
    required this.gameLobbyPlayerCount,
    required this.unreadMessagesCount,
  });

  static final DateFormat _customFormat = DateFormat('dd.MM.yyyy HH:mm');

  factory PlayerInfo.fromJson(Map<String, dynamic> json) {
    final String lastSeenString = json['lastSeen'] as String? ?? '';
    final String joindDateString = json['joinDate'] as String? ?? '';
    
    DateTime? parsedLastSeen;
    DateTime parsedJoinDate = DateTime.now();
    
    if (lastSeenString.isNotEmpty) {
      DateTime? isoDate = DateTime.tryParse(lastSeenString);
      
      if (isoDate != null) {
        parsedLastSeen = isoDate.toLocal();
      } else {
        try {
          parsedLastSeen = _customFormat.parse(lastSeenString, true).toLocal();
        } catch (e) {
          print('Error parsing date "$lastSeenString": $e');
        }
      }
    }

    if (joindDateString.isNotEmpty) {
      DateTime? isoDate = DateTime.tryParse(joindDateString);
      
      if (isoDate != null) {
        parsedJoinDate = isoDate.toLocal();
      } else {
        try {
          parsedJoinDate = _customFormat.parse(joindDateString, true).toLocal();
        } catch (e) {
          print('Error parsing date "$joindDateString": $e');
        }
      }
    }

    return PlayerInfo(
      id: json['playerId'],
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: parsedLastSeen,
      joinDate: parsedJoinDate,
      friendshipStatus: json['friendshipStatus'] ?? '',
      inGameLobby: json['inRoom'] ?? false,
      overall: json['stats']['overall'] ?? 0,
      wins: json['stats']['wins'] ?? 0,
      loses: json['stats']['loses'] ?? 0,
      mafiaWins: json['stats']['mafiaWins'] ?? 0,
      civilianWins: json['stats']['civilianWins'] ?? 0,
      unreadMessagesCount: json['unreadMessagesCount'] ?? 0,

      bodyguardRolePlayedGames: json['stats']['bodyguardRolePlayedGames'] ?? 0,
      doctorRolePlayedGames: json['stats']['doctorRolePlayedGames'] ?? 0,
      sheriffRolePlayedGames: json['stats']['sheriffRolePlayedGames'] ?? 0,
      beautyRolePlayedGames: json['stats']['beautyRolePlayedGames'] ?? 0,
      journalistRolePlayedGames: json['stats']['journalistRolePlayedGames'] ?? 0,
      spyRolePlayedGames: json['stats']['spyRolePlayedGames'] ?? 0,
      civilianRolePlayedGames: json['stats']['civilianRolePlayedGames'] ?? 0,
      mafiaRolePlayedGames: json['stats']['mafiaRolePlayedGames'] ?? 0,
      terroristRolePlayedGames: json['stats']['terroristRolePlayedGames'] ?? 0,
      informantRolePlayedGames: json['stats']['informantRolePlayedGames'] ?? 0,
      barmanRolePlayedGames: json['stats']['barmanRolePlayedGames'] ?? 0,

      gameLobbyTitle: json['room'] == null ? '' : json['room']['title'] ?? '',
      gameLobbyStatus: json['room'] == null ? '' : json['room']['state'] ?? '',
      gameLobbyPlayerCount: json['room'] == null ? -1 : json['room']['playersCount'] ?? -1,
    );
  }

  @override
  String toString() {
    return '''
PlayerInfo(
  nickname: $nickname,
  avatarUrl: $avatarUrl,
  isOnline: $isOnline,
  lastSeen: ${lastSeen?.toIso8601String()},
  joinDate: ${joinDate.toIso8601String()},
  friendshipStatus: $friendshipStatus,
  gameLobbyTitle: $gameLobbyTitle,
  gameLobbyStatus: $gameLobbyStatus,
  gameLobbyPlayerCount: $gameLobbyPlayerCount,
  inGameLobby: $inGameLobby,
  overall: $overall,
  wins: $wins,
  loses: $loses,
  mafiaWins: $mafiaWins,
  civilianWins: $civilianWins,
)
''';
  }

  PlayerInfo.from(PlayerInfo other)
    : id = other.id,
      nickname = other.nickname,
      avatarUrl = other.avatarUrl,
      isOnline = other.isOnline,
      lastSeen = other.lastSeen,
      joinDate = other.joinDate,
      friendshipStatus = other.friendshipStatus,
      inGameLobby = other.inGameLobby,
      overall = other.overall,
      wins = other.wins,
      loses = other.loses,
      mafiaWins = other.mafiaWins,
      civilianWins = other.civilianWins,
      gameLobbyTitle = other.gameLobbyTitle,
      gameLobbyStatus = other.gameLobbyStatus,
      gameLobbyPlayerCount = other.gameLobbyPlayerCount,
      unreadMessagesCount = other.unreadMessagesCount,

      civilianRolePlayedGames = other.civilianRolePlayedGames,
      sheriffRolePlayedGames = other.sheriffRolePlayedGames,
      doctorRolePlayedGames = other.doctorRolePlayedGames,
      beautyRolePlayedGames = other.beautyRolePlayedGames,
      bodyguardRolePlayedGames = other.bodyguardRolePlayedGames,
      spyRolePlayedGames = other.spyRolePlayedGames,
      journalistRolePlayedGames = other.journalistRolePlayedGames,
      mafiaRolePlayedGames = other.mafiaRolePlayedGames,
      informantRolePlayedGames = other.informantRolePlayedGames,
      barmanRolePlayedGames = other.barmanRolePlayedGames,
      terroristRolePlayedGames = other.terroristRolePlayedGames;

      
}

class WinRole extends StatelessWidget {
  final String role;
  final int winCount;

  const WinRole({super.key, required this.role, required this.winCount});

  String getAssetByRole() {
    switch (role) {
      case "Mafia":
        return 'assets/images/role-card-mark-mafia.png';

      case "Civilian":
        return 'assets/images/role-card-mark-civilian.png';

      case "Bodyguard":
        return 'assets/images/role-card-mark-protected.png';

      case "Journalist":
        return 'assets/images/role-card-mark-interviewed.png';

      case "Beauty":
        return 'assets/images/role-card-mark-satisfied.png';

      case "Doctor":
        return 'assets/images/role-card-mark-cured.png';
        
      case "Sheriff":
        return 'assets/images/role-card-mark-investigated.png';

      case "Spy":
        return 'assets/images/role-card-mark-spy.png';

      case "Terrorist":
        return 'assets/images/role-card-mark-terrorist.png';

      case "Informant":
        return 'assets/images/role-card-mark-revealed.png';

      case "Barman":
        return 'assets/images/role-card-mark-intoxicated.png';

      default:
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //? MINI ROLE CARD
        Image.asset(
          getAssetByRole(),
          height: 36.h,
          width: 27.w,
        ),
        
        SizedBox(height: 5.h),

        //? WIN COUNT
        Text(
          winCount.toString(),
          style: TextStyle(
            fontSize: 13.sp,
            fontFamily: 'CenturyGothic',
            color: Colors.black
          ),
        )
      ],
    );
  }
}