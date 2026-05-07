import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/l10n/app_localizations_az.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
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
  StreamSubscription? _eventSubscriptionCancelRequest;

  @override
  void initState() {
    super.initState();

    _loadPlayerInfo();
    
    _eventSubscriptionFriendOnline = EventBus().on<FriendOnlineEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        playerInfo!.isOnline = true;
      });
    });

    _eventSubscriptionFriendOffline = EventBus().on<FriendOfflineEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        playerInfo!.isOnline = false;
        playerInfo!.lastSeen = DateTime.now().toLocal();
      });
    });

    _eventSubscriptionDeleteFriend = EventBus().on<DeleteFriendEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        playerInfo!.friendshipStatus = 'None';
      });
    });

    _eventSubscriptionDeleteFriend = EventBus().on<CancelFriendRequest>().listen((event) {
      if (!mounted) return;
      setState(() {
        playerInfo!.friendshipStatus = 'None';
      });
    });

    _eventSubscriptionNewFriendMessage = EventBus().on<FriendNewMessageEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        playerInfo!.unreadMessagesCount++;
      });
    });

    _eventSubscriptionFriendMessagesReaded = EventBus().on<FriendMessagesReadedEvent>().listen((event) {
      if (!mounted) return;
      setState(() {
        playerInfo!.unreadMessagesCount = 0;
      });
    });

    _eventSubscriptionNewFriendAdded = EventBus().on<NewFriendAddedEvent>().listen((event) {
      if (!mounted) return;
      if (event.requestData.id != playerInfo!.id) return;
      setState(() {
        playerInfo!.friendshipStatus = 'Accepted';
      });
    });

    _eventSubscriptionFriendRequestRecieved = EventBus().on<FriendRequestReceivedEvent>().listen((event) {
      if (!mounted) return;
      if (event.requestData['friendId'] != playerInfo!.id) return;
      setState(() {
        playerInfo!.friendshipStatus = 'ApprovePending';
      });
    });

    _eventSubscriptionFriendRequestDeclined = EventBus().on<FriendRequestDeclinedEvent>().listen((event) {
      if (!mounted) return;
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
    _eventSubscriptionCancelRequest?.cancel();
    super.dispose();
  }

  String formatLastSeen(DateTime lastSeen, BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 59) {
      return AppLocalizations.of(context)!.lessThanAMinute;
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} ${AppLocalizations.of(context)!.minsAgo}";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} ${AppLocalizations.of(context)!.hoursAgo}";
    } else if (difference.inDays < 31) {
      return "${difference.inDays} ${AppLocalizations.of(context)!.daysAgo}";
    } else {
      return DateFormat('dd.MM.yyyy').format(lastSeen.toLocal());
    }
  }

  void _loadPlayerInfo() async {
    final playerInfoData = await GetIt.I<ApiService>().getPlayerInfo(widget.id);
    print(playerInfoData.toString());
    if (!mounted) return;
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
                      borderRadius: BorderRadius.circular(85.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // TEXT:    Profile
                        Text(
                          AppLocalizations.of(context)!.playerProfile,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32.sp,
                            color: const Color(0xFF000000)
                          )
                        ),

                        SizedBox(height: 20.h,),
                    
                        //? OLINE STATUS  |  AVATAR  |  JOIN DATE
                        /*
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
                                        playerInfo!.isOnline ? AppLocalizations.of(context)!.online : AppLocalizations.of(context)!.offline,
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
                                  border: Border.all(color: Colors.white, width: 1.w),
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
                                    AppLocalizations.of(context)!.joinDate,
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
                        */
                        
                        //? AVATAR  |  NICKNAME  |  STATUS
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              
                              //? ONLINE STATUS  |  AVATAR 
                              Row(
                                children: [
                                  //? AVATAR
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context, 
                                        builder: (context) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          child: Container(
                                            width: 300.w,
                                            height: 300.h,
                                            decoration: BoxDecoration(
                                              //borderRadius: BorderRadius.circular(12.sp),
                                              border: Border.all(color: Colors.white, width: 2.w),
                                              shape: BoxShape.circle
                                            ),
                                            child: ClipRRect(
                                              //borderRadius: BorderRadius.circular(300.sp),
                                              child: Image.network(
                                                playerInfo!.avatarUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        )
                                      );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(35.sp),
                                        border: Border.all(color: Colors.white, width: 1.w),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          playerInfo!.avatarUrl
                                        ),
                                        radius: 35.sp,
                                      )
                                    ),
                                  ),

                                  SizedBox(width: 15.w),

                                  //? JOIN DATE AND NICKNAME TEXTS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TEXT:    NICKNAME
                                      Text(
                                        "${AppLocalizations.of(context)!.nickname}:  ",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                      
                                      // TEXT:    JOIN DATE
                                      Text(
                                        playerInfo!.isOnline ? "${AppLocalizations.of(context)!.status}:  " : "${AppLocalizations.of(context)!.lastSeen}:  ",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black,
                                          height: 0
                                        )
                                      ),
                                    ],
                                  ),
                            
                                ],
                              ),

                              SizedBox(width: 5.w),
                          
                              //? JOIN DATE AND NICKNAME TEXTS
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // TEXT:    NICKNAME
                                  Text(
                                    playerInfo!.nickname,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: 'CenturyGothic',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black
                                    ),
                                  ),
                                  
                                  // TEXT:    JOIN DATE
                                  Text(
                                    playerInfo!.isOnline ? AppLocalizations.of(context)!.online : formatLastSeen(playerInfo!.lastSeen!, context),
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontFamily: 'CenturyGothic',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                      height: 0
                                    )
                                  ),
                                ],
                              )
                            
                            ],
                          ),
                        ),

                        SizedBox(height: 10.h),

                        //? NICKNAME
                        /*
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
                        */
                    
                        //? REPORT  |  ADD FRIENDS  |  CHAT
                        Padding(
                          padding: EdgeInsets.only(left: 15.w, right: 10.w, top: 10.h, bottom: 5.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // BUTTON:    REPORT
                              /*
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
                                      AppLocalizations.of(context)!.report,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'CenturyGothic',
                                        color: Colors.black
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              */

                              //? FRIENDSHIP STATUS
                              playerInfo!.friendshipStatus == 'None'
                              ? GestureDetector(
                                onTap: () async {
                                  await GetIt.I<ApiService>().sendRequest(playerInfo!.id);
                                  _loadPlayerInfo();
                                },
                                child: Container(
                                  height: 35.h,
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFB000),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.w
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp)
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                                      child: Text(
                                        AppLocalizations.of(context)!.addToFriends,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black,
                                          //fontWeight: FontWeight.w800
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
                                  width: 140.w,
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
                                        AppLocalizations.of(context)!.deleteFriend,
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
                              : playerInfo!.friendshipStatus == 'ApprovePending'
                              ?
                                //? BUTTONS:     REJECT AND ACCEPT
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          playerInfo!.friendshipStatus = 'Accepted';
                                        });
                                        await GetIt.I<ApiService>().approveFriend(playerInfo!.id, true);
                                      },
                                      child: Container(
                                        height: 35.h,
                                        width: 150.w,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFB000),
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.w
                                          ),
                                          borderRadius: BorderRadius.circular(12.sp)
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                                            child: Text(
                                              AppLocalizations.of(context)!.acceptRequest,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily: 'CenturyGothic',
                                                color: Colors.black,
                                                //fontWeight: FontWeight.w800
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 27.w),
                                    GestureDetector(
                                      onTap: () async {
                                        setState(() {
                                          playerInfo!.friendshipStatus = 'None';
                                        });
                                        await GetIt.I<ApiService>().approveFriend(playerInfo!.id, false);
                                      },
                                      child: Container(
                                        height: 35.h,
                                        width: 150.w,
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          border: Border.all(
                                            color: Colors.black,
                                            width: 1.w
                                          ),
                                          borderRadius: BorderRadius.circular(12.sp)
                                        ),
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 8.w),
                                            child: Text(
                                              AppLocalizations.of(context)!.rejectRequest,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontFamily: 'CenturyGothic',
                                                color: Colors.black,
                                                //fontWeight: FontWeight.w800
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              
                              :
                              // BUTTON:    Cancel request
                              GestureDetector(
                                onTap: () async {
                                  await GetIt.I<ApiService>().cancelFriendRequest(playerInfo!.id);
                                  _loadPlayerInfo();
                                },
                                child: Container(
                                  height: 35.h,
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1.w
                                    ),
                                    borderRadius: BorderRadius.circular(12.sp)
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                                      child: Text(
                                        AppLocalizations.of(context)!.cancelRequest,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black,
                                          //fontWeight: FontWeight.w800
                                        ),
                                      ),
                                    ),
                                  ),
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
                                            chatId: playerInfo!.chatId,
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
                                        width: 140.h,
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
                                            AppLocalizations.of(context)!.chat,
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
                    
                        SizedBox(height: 10.h),

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
                            playerInfo!.isOnline ? "Currently is not in a room" : AppLocalizations.of(context)!.currentlyOffline,
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
                                AppLocalizations.of(context)!.currentlyArePlayingIn,
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
                                          AppLocalizations.of(context)!.playersInTotal,
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
                          AppLocalizations.of(context)!.stats,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20.sp,
                            color: Colors.black
                          ),
                        ),
                        
                        //? OVERALL STATS
                        /*
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
                                AppLocalizations.of(context)!.overall,
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
                        */

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
                                        AppLocalizations.of(context)!.wins,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      // TEXT:    WINS
                                      Text(
                                        AppLocalizations.of(context)!.loses,
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
                                        AppLocalizations.of(context)!.mafiaWins,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      // TEXT:    CIVILIAN WINS
                                      Text(
                                        AppLocalizations.of(context)!.civilianWins,
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
                          AppLocalizations.of(context)!.playedRoles,
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
                            WinRole(role: 'Kamikaze', winCount: playerInfo!.kamikazeRolePlayedGames),
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
  final int id; //
  final int chatId;
  final String nickname; //
  final String avatarUrl; //
  bool isOnline;
  DateTime? lastSeen;
  final DateTime joinDate; //
  String friendshipStatus;
  final String? gameLobbyTitle; 
  final String? gameLobbyStatus;
  final int? gameLobbyPlayerCount;
  final bool inGameLobby;
  final int overall; //
  final int wins; //
  final int loses; //
  final int mafiaWins; //
  final int civilianWins; //
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
  final int kamikazeRolePlayedGames;

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
    required this.kamikazeRolePlayedGames,

    required this.id,
    required this.chatId,
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
      chatId: json['chatId'] ?? -1,
      nickname: json['nickname'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeen: parsedLastSeen ?? DateTime.now(),
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
      kamikazeRolePlayedGames: json['stats']['kamikazeRolePlayedGames'] ?? 0,
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
      chatId = other.chatId,
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
      kamikazeRolePlayedGames = other.kamikazeRolePlayedGames;

      
}

class WinRole extends StatefulWidget  {
  final String role;
  final int winCount;

  const WinRole({super.key, required this.role, required this.winCount});

  @override
  State<WinRole> createState() => _WinRoleState();
}

class _WinRoleState extends State<WinRole> with SingleTickerProviderStateMixin {
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
                      rolesLocalizaitons[widget.role.toLowerCase()]!,
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

  String getAssetByRole() {
    switch (widget.role) {
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

      case "Kamikaze":
        return 'assets/images/role-card-mark-kamikaze.png';

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
        GestureDetector(
          onTap: () {
            if (_overlayEntry != null) {
              _hideTooltip();
            } else {
              _showTooltip();
            }
          },
          child: Image.asset(
            getAssetByRole(),
            height: 36.h,
            width: 27.w,
          ),
        ),
        
        SizedBox(height: 5.h),

        //? WIN COUNT
        Text(
          widget.winCount.toString(),
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



class MyProfileScreen extends StatefulWidget {
  final int id;
  final String nickname;
  final double height;
  final double width;
  final ValueNotifier<int> tabIndexNotifier;
  final int tabIndex;

  const MyProfileScreen({
    super.key, 
    required this.id, 
    required this.nickname, 
    required this.height, 
    required this.width, 
    required this.tabIndexNotifier,
    required this.tabIndex
  });

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> with RouteAware {
  bool _routeVisible = false;
  bool _tabVisible = false;

  bool get _isActive => _routeVisible && _tabVisible;
  PlayerInfo? playerInfo;
  final double ornamentSize = 50.sp;
  final double ornamentMargin = 5.sp;

  final double cardsMargin = 20.w;

  @override
  void initState() {
    //_loadPlayerInfo();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
    
    widget.tabIndexNotifier.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final visible = widget.tabIndexNotifier.value == widget.tabIndex;

    if (visible != _tabVisible) {
      _tabVisible = visible;
      _evaluateState();
    }
  }

  /// FIRST TIME tab becomes visible
  @override
  void didPush() {
    _routeVisible = true;
    _evaluateState();
  }

  /// coming back to this tab
  @override
  void didPopNext() {
    _routeVisible = true;
    _evaluateState();
  }

  /// leaving this tab (switch tab or push)
  @override
  void didPushNext() {
    _routeVisible = false;
    _evaluateState();
  }

  void _evaluateState() {
    if (_isActive) {
      _onActive();
    } else {
      _onInactive();
    }
  }

  void _onActive() {
    print('My Profile Screen ACTIVE');
    _loadPlayerInfo();
  }

  void _onInactive() {
    print('My Profile Screen INACTIVE');
  }
  
  void _loadPlayerInfo() async {
    final playerInfoData = await GetIt.I<ApiService>().getMyInfo();
    print(playerInfoData.toString());
    setState(() {
      playerInfo = PlayerInfo.from(playerInfoData);
    });
    print('-----------------');
    print(playerInfo.toString());
  }

  @override
  void dispose() {
    super.dispose();
    appRouteObserver.unsubscribe(this);
    widget.tabIndexNotifier.removeListener(_onTabChanged);
  }

  @override
  Widget build(BuildContext context) {
    if (playerInfo == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            "assets/images/background_my_profile.png",
            fit: BoxFit.cover,
          ),
        ),
        
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(top: 10.h),
            height: widget.height,
            width: widget.width,
            child: Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  //color: Colors.transparent,
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
                            /*
                            Text(
                              AppLocalizations.of(context)!.profile,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 32.sp,
                                color: const Color(0xFF000000)
                              )
                            ),
                            */
        
                            SizedBox(height: 20.h),
        
                            //? AVATAR
                            SizedBox(
                              height: 130.h,
                              width: 140.w,
                              child: Stack(
                                children: [
                                  //? AVATAR GLOW
                                  Positioned(
                                    right: 10.w,
                                    top: 0.h,
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: 20.h),
                                      child: GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context, 
                                            builder: (context) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                width: 300.w,
                                                height: 300.h,
                                                decoration: BoxDecoration(
                                                  //borderRadius: BorderRadius.circular(12.sp),
                                                  border: Border.all(color: Colors.white, width: 2.w),
                                                  shape: BoxShape.circle
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(300.sp),
                                                  child: Image.network(
                                                    playerInfo!.avatarUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            )
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            //borderRadius: BorderRadius.circular(35.sp),
                                            border: Border.all(color: Colors.white, width: 1.w),
                                            shape: BoxShape.circle
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                              playerInfo!.avatarUrl
                                            ),
                                            radius: 60.sp,
                                          )
                                        ),
                                      ),
                                    ),
                                  ),
                                
                                  //? ONLINE STATUS BADGE
                                  Positioned(
                                    right: 15.w,
                                    top: 2.h,
                                    child: Container(
                                      padding: EdgeInsets.all(4.w),
                                      constraints: BoxConstraints(
                                        minWidth: 20.w,
                                        minHeight: 20.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 1.5.w),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "",
                                          style: TextStyle(
                                            color: Colors.white ,
                                            fontSize: 16.sp,
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
                        
                            //? OLINE STATUS  |  AVATAR  |  JOIN DATE
                            /*
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
                                              color:  const Color(0xFF896A44),
                                              border: Border.all(
                                                color: const Color(0xFFB98744),
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
                                            AppLocalizations.of(context)!.online,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontFamily: 'CenturyGothic',
                                              color: Colors.black
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
        
                                  //? AVATAR
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(35.sp),
                                      border: Border.all(color: Colors.white, width: 1.w),
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
                                        AppLocalizations.of(context)!.joinDate,
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
                            */
        
        
        
                            //? AVATAR  |  NICKNAME  |  JOIN DATE
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 30.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  //SizedBox(width: 3.w),
                                  //? JOIN DATE AND NICKNAME TEXTS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // TEXT:    NICKNAME
                                      Text(
                                        "${AppLocalizations.of(context)!.nickname}:",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                      
                                      // TEXT:    JOIN DATE
                                      Text(
                                        "${AppLocalizations.of(context)!.joinDate}:  ",
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black,
                                          height: 0
                                        )
                                      ),
                                    ],
                                  ),
                                
                                  //? JOIN DATE AND NICKNAME TEXTS
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // TEXT:    NICKNAME
                                      Text(
                                        playerInfo!.nickname,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black
                                        ),
                                      ),
                                      
                                      // TEXT:    JOIN DATE
                                      Text(
                                        DateFormat('dd.MM.yyyy').format(playerInfo!.joinDate),
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontFamily: 'CenturyGothic',
                                          fontWeight: FontWeight.w700,
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
                            /*
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
                            */
        
                            SizedBox(height: 15.h),
        
                            //? DIVIDER
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.w),
                              child: Divider(
                                thickness: 2.h,
                                color: const Color(0xFF494239),
                              ),
                            ),
        
                            SizedBox(height: 7.h),
                          
                            ////? STATS
                            // TEXT:    STATS
                            Text(
                              AppLocalizations.of(context)!.stats,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20.sp,
                                color: Colors.black
                              ),
                            ),
                            
                            //? OVERALL STATS
                            /*
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
                                    AppLocalizations.of(context)!.overall,
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
                            */
        
                            //? SPECIFIC STATS
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
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
                                            AppLocalizations.of(context)!.wins,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontFamily: 'CenturyGothic',
                                              color: Colors.black
                                            ),
                                          ),
                                                            
                                          SizedBox(height: 10.h),
                                                            
                                          // TEXT:    WINS
                                          Text(
                                            AppLocalizations.of(context)!.loses,
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
                                            AppLocalizations.of(context)!.mafiaWins,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontFamily: 'CenturyGothic',
                                              color: Colors.black
                                            ),
                                          ),
                                                            
                                          SizedBox(height: 10.h),
                                                            
                                          // TEXT:    CIVILIAN WINS
                                          Text(
                                            AppLocalizations.of(context)!.civilianWins,
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
        
                            SizedBox(height: 15.h),
                          
                            // TEXT:    PLAYED ROLES
                            Text(
                              AppLocalizations.of(context)!.playedRoles,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 20.sp,
                                color: Colors.black
                              )
                            ),
        
                            SizedBox(height: 25.h),
                            
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
                                WinRole(role: 'Kamikaze', winCount: playerInfo!.kamikazeRolePlayedGames),
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
        ),
      ],
    );
  }

}


class RoleMiniCardTooltip extends StatefulWidget {
  const RoleMiniCardTooltip({super.key});

  @override
  State<RoleMiniCardTooltip> createState() => _RoleMiniCardTooltipState();
}

class _RoleMiniCardTooltipState extends State<RoleMiniCardTooltip> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class ShowAvatarPopup extends StatelessWidget {
  final String avatarUrl;
  const ShowAvatarPopup({super.key, required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Align(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: Center(
          child: Container(
            height: 300.h,
            width: 300.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white, width: 2.w)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.network(
                avatarUrl,
                fit: BoxFit.cover,
              ),
            ),
          )
        ),
      ),
    );
  }
}
