import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mafia_classic/features/games/view/view.dart';
import 'package:mafia_classic/features/profile/friends/models/models.dart';
import 'package:mafia_classic/features/widgets/player_info_popup.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/mafia_classic_app.dart';

//import 'package:mafia_classic/blocs/player_bloc.dart';
// import 'package:mafia_classic/blocs/player_event.dart';
// import 'package:mafia_classic/blocs/player_state.dart';

//import 'package:mafia_classic/repositories/player_repository.dart';

import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/features/profile/friends/widgets/widgets.dart';
import 'package:mafia_classic/features/profile/friends/view/screens/screens.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  int selectedTabIndex = 0;

  // final _playerBloc = PlayerBloc(
  //   playerRepository: GetIt.I<PlayerRepository>(),
  // );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final double buttonHeight = 35.h;
    final double buttonWidth = 93.w;

    final double ornamentSize = 55.sp;
    final double ornamentMargin = 2.sp;

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/friends-background.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,

        body: Container(
          padding: EdgeInsets.only(top: 40.h, left: 10.w, right: 10.w, bottom: 10.h),
          child: Column(
            children: [
              //? BUTTON GO HOME
              /*
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // BUTTON:    HOME
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Image.asset(
                      "assets/images/home-icon.png",
                      scale: 2.8,
                    ),
                  ),

                  const SizedBox()
                ],
              ),
              */

              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BUTTON:    Friends 
                    Container(
                      decoration: BoxDecoration(
                        color: selectedTabIndex == 0 ? const Color(0xFFC4B4A3) : Colors.transparent,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: 5.h, left: 7.w, right: 7.w, bottom: 10.h), 
                        padding: EdgeInsets.all(3.sp),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: selectedTabIndex == 0 ? const Color(0xFF2A2723) : Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectedTabIndex = 0);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTabIndex == 0 ? const Color(0xFFFFE8D4) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: selectedTabIndex == 0 ? const Color(0xFF2A2723) : Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            
                            // TEXT:    Friends
                            child: Text(
                              AppLocalizations.of(context)!.friends,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: selectedTabIndex == 0 ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          ),
                        ),
                    ),
                
                    // BUTTON:    Friend Requests
                    Container(
                      decoration: BoxDecoration(
                        color: selectedTabIndex == 1 ? const Color(0xFFC4B4A3) : Colors.transparent,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: 5.h, left: 7.w, right: 7.w, bottom: 10.h), 
                        padding: EdgeInsets.all(3.sp),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: selectedTabIndex == 1 ? const Color(0xFF2A2723) : Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectedTabIndex = 1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTabIndex == 1 ? const Color(0xFFFFE8D4) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: selectedTabIndex == 1 ? const Color(0xFF2A2723) : Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            
                            // TEXT:    Reuqests
                            child: Text(
                              AppLocalizations.of(context)!.requests,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: selectedTabIndex == 1 ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          ),
                        ),
                    ),
                
                    // BUTTON:    Search Friends
                    Container(
                      decoration: BoxDecoration(
                        color: selectedTabIndex == 2 ? const Color(0xFFC4B4A3) : Colors.transparent,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                      ),
                      child: Container(
                        margin: EdgeInsets.only(top: 5.h, left: 7.w, right: 7.w, bottom: 10.h), 
                        padding: EdgeInsets.all(3.sp),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: selectedTabIndex == 2 ? const Color(0xFF2A2723) : Colors.white,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SizedBox(
                          width: buttonWidth,
                          height: buttonHeight,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => selectedTabIndex = 2);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTabIndex == 2 ? const Color(0xFFFFE8D4) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: BorderSide(
                                  color: selectedTabIndex == 2 ? const Color(0xFF2A2723) : Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            
                            // TEXT:    Search
                            child: Text(
                              AppLocalizations.of(context)!.search,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: selectedTabIndex == 2 ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                
                  ]
                ),
              ),

              const Divider(
                color: Color(0xFFC4B4A3),
                thickness: 4,
                height: 0,
              ),

              //? TABS LOGIC
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE2D2BF),
                        Color(0xFF9E8468),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(3.sp),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: const Color(0xFF2A2723),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
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
                          width: double.infinity,
                          margin: EdgeInsets.all(5.sp),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color(0xFF2A2723),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(100.sp),
                          ),

                          child: (selectedTabIndex == 0) 
                            ? const FriendsTab() 
                            : (selectedTabIndex == 1) 
                              ? const RequestsTab() 
                              : const SearchTab()
                        )
                      ],
                    ),
                  )
                
                ),
              )
            ]
          ),
        ),
      )

      /*
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white
          ),
          title: Text(AppLocalizations.of(context)!.friends.toUpperCase(), style: theme.textTheme.bodyMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendSearchScreen(
      
                    )),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendRequestScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    //!_loadFriends();
                  }
                });
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: friends == null ? 0 : friends?.length,
          itemBuilder: (context, index) {
            if (friends == null) {
              return const SizedBox();
            }
            final friend = friends![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(friend: friends![index]),
                  ),
                );
              },
              child: FriendCard(
                friend: friend, 
                onDelete: _deleteFriend,
              )
            );
          }
        )
       */
        
        // BlocBuilder(
        //   bloc: _playerBloc,
        //   builder: (context, state) {
        //     if(state is PlayerFriendsLoadSuccess) {
        //       return ListView.builder(
        //         itemCount: state.friends.length,
        //         itemBuilder: (context, index) {
        //           return GestureDetector(
        //             onTap: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (context) => ChatScreen(friend: state.friends[index]),
        //                 ),
        //               );
        //             },
        //             child: FriendCard(friend: state.friends[index])
        //           );
        //         }
        //       );
        //     }
        //     if(state is PlayerFriendsLoadFailure) {
        //       return const Center(
        //         child: Text(
        //           'something went wrong...', 
        //           style: TextStyle(
        //             fontSize: 18,
        //             color: Colors.white
        //           )
        //         ),
        //       );
        //     }
        //     return const Center(child: CircularProgressIndicator());
        //   }        
        // )
      
    );
  }
}



class FriendsTab extends StatefulWidget {
  const FriendsTab({
    super.key,
  });

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final TextEditingController searchController = TextEditingController();
  StreamSubscription? _eventSubscriptionLoadFriends;
  StreamSubscription? _eventSubscriptionNewFriend;
  StreamSubscription? _eventSubscriptionNewFriendMessage;
  StreamSubscription? _eventSubscriptionDeleteFriend;
  StreamSubscription? _eventSubscriptionFriendOnline;
  StreamSubscription? _eventSubscriptionFriendOffline;
  StreamSubscription? _eventSubscriptionFriendMessagesReaded;
  List<Friendship> friends = [];
  List<Friendship> filteredFriends = [];
  // List<Friendship>? friends = [
  //   Friendship(
  //     nickname: 'Player1', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     isOnline: true, 
  //     lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
  //   ),
  //   Friendship(
  //     nickname: 'Player2', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     isOnline: false, 
  //     lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
  //   ),
  //   Friendship(
  //     nickname: 'Player3', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     isOnline: true, 
  //     lastSeen: DateTime.now().subtract(const Duration(minutes: 2)),
  //   ),
  //   Friendship(
  //     nickname: 'Player4', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     isOnline: false, 
  //     lastSeen: DateTime.now().subtract(const Duration(hours: 3)),
  //   ),
  // ];

  @override
  void initState() {
    log("*********** INIT STATE OF FRIEND TAB ***********");
    _loadFriends();

    filteredFriends = friends;

    _eventSubscriptionLoadFriends = EventBus().on<LoadFriendsEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        log("****** LOAD FRIEND ******");
        _loadFriends();
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });
  
    _eventSubscriptionNewFriend = EventBus().on<NewFriendAddedEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        log("****** NEW FRIEND ******");
        friends.insert(0, event.requestData); 
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });

    _eventSubscriptionNewFriendMessage = EventBus().on<FriendNewMessageEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        friends.firstWhere((friend) => friend.id == event.friendId).unreadMessagesCount++;
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });
    
    _eventSubscriptionDeleteFriend = EventBus().on<DeleteFriendEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        friends.removeWhere((friend) => friend.id == event.friendId); 
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });
    
    _eventSubscriptionFriendOnline = EventBus().on<FriendOnlineEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        friends.firstWhere((friend) => friend.id == event.friendId).isOnline = true;
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });

    _eventSubscriptionFriendOffline = EventBus().on<FriendOfflineEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        Friendship friend = friends.firstWhere((friend) => friend.id == event.friendId);
        friend.isOnline = false;
        friend.lastSeen = DateTime.now();
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });

    _eventSubscriptionFriendMessagesReaded = EventBus().on<FriendMessagesReadedEvent>().listen((event) {
      setState(() {
        if (!mounted) return;
        friends.firstWhere((friend) => friend.id == event.friendId).unreadMessagesCount = 0;
        filteredFriends = _filterFriends(searchController.text.trim());
      });
    });
    
    super.initState();
  }

  List<Friendship> _filterFriends(String query) {
    if (query.isEmpty) {
      return friends;
    } else {
      return friends
          .where((friend) => friend.nickname.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  // @override
  // void didUpdateWidget(covariant FriendsTab oldWidget) {
  //   super.didUpdateWidget(oldWidget);
  //   _loadFriends();
  // }

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



  @override
  void didChangeDependencies() {
    _loadFriends();
    super.didChangeDependencies();
  }

  void _loadFriends() {
    if (!mounted) return;
    List<Friendship>? updated;
    try {
      updated = GeneralCacheService().loadList<Friendship>(
        "all_friends_list",
        (json) { 
          // if ((json as Map<String, dynamic>)['id'] == null) {
          //   return null;
          // }
          return Friendship.fromJson(json);
        },
      );
    } on Exception catch (e) {
      log("Error _loadFriends() | friends_tab | from cache: ${e.toString()}");
    }
    
    setState(() {
      // if (updated == null) {
      //   friends = [];
      // } else {
      //   friends = updated.whereType<Friendship>().toList();
      // }
      friends = updated ?? [];
      //print('FRIENDS LOADED FROM CACHE: ${friends.length}');
    });
  }

  void _deleteFriend(String nickname) async {
    if (!mounted) return;
    TcpClientService().sendMessage(ClientCommand.deleteFriendship.value, json.encode({'nickname': nickname}));
    friends.removeWhere((friend) => friend.nickname == nickname);
    await GeneralCacheService().save('all_friends_list', friends);
    setState(() {});
  }

  @override
  void dispose() {
    if (!mounted) return;
    _eventSubscriptionLoadFriends?.cancel();
    _eventSubscriptionNewFriend?.cancel();
    _eventSubscriptionNewFriendMessage?.cancel();
    _eventSubscriptionDeleteFriend?.cancel();
    _eventSubscriptionFriendOnline?.cancel();
    _eventSubscriptionFriendOffline?.cancel();
    _eventSubscriptionFriendMessagesReaded?.cancel();
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //_loadFriends();

    return Column(
      children: [
        // TEXT:    TRUSTED INDIVIDUALS
        Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: Text(
            AppLocalizations.of(context)!.trustedIndividuals,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2723),
            ),
          ),
        ),

        // TEXT:    Justice rides with us.
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Text(
            AppLocalizations.of(context)!.justiceRidesWithUs,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14.sp,
              color: const Color(0xFF2A2723),
            ),
          ),
        ),

        //? IMAGE DIVIDER
        Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: Image.asset(
            "assets/images/roles-line.png",
            width: 130.w,
          ),
        ),

        //? SEARCH FROM FRIENDS
        Padding(
          padding: EdgeInsets.only(top: 15.h, left: 25.w, right: 20.w),
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3E3E3E), width: 1.5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                // TEXTFIELD:    Search...
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
                    child: TextField(
                      onChanged: (value) => setState(() {
                        filteredFriends = _filterFriends(value);
                      }),
                      cursorColor: const Color(0xFF3E3E3E),
                      cursorHeight: 20.h,
                      onTapOutside: (PointerDownEvent event) {
                        FocusScope.of(context).unfocus();
                      },
                      controller: searchController,
                      style: TextStyle(color: const Color(0xFF3E3E3E), fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: ' ${AppLocalizations.of(context)!.search}...',
                        hintStyle: const TextStyle(color: Color(0xFF3E3E3E)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                
                //? SEARCH ICON
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () {
                      
                    },
                    child: Image.asset(
                      "assets/images/friends-search-icon.png",
                      width: 25.w,
                      height: 25.h,
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),

        //? FRIENDS LIST
        (filteredFriends.isEmpty)
        ? 
        Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              AppLocalizations.of(context)!.noFriendsFound,
              style: GoogleFonts.playfairDisplay(
                color: Colors.black,
                fontSize: 18
              ),
            )
          ),
        )
        : Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = filteredFriends[index];
                return GestureDetector(
                  onTap: () {
                    showBouncingPopupFromLeft(
                      context, 
                      PlayerInfoPopup(
                        id: friend.id,
                        height: 727.h, 
                        width: 405.w, 
                        nickname: friend.nickname,
                      )
                    ).then((_) {
                      _loadFriends();
                    });
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                //? PROFILE PHOTO
                                CircleAvatar(
                                  backgroundImage: NetworkImage(friend.avatarUrl),
                                  radius: 21.sp,
                                ),
                  
                                SizedBox(width: 12.w),
                  
                                //? NICKNAME AND STATUS
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TEXT:    NICKNAME
                                    Text(
                                      friend.nickname,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18.sp, 
                                        color: Colors.black 
                                      )
                                    ),
                  
                                    // TEXT:    STATUS
                                    Text(
                                      //friend.isOnline ? AppLocalizations.of(context)!.online : DateFormat('dd.MM.yyyy HH:mm').format(friend.lastSeen.toLocal()), //! DYNAMIC
                                      friend.isOnline ? AppLocalizations.of(context)!.online : formatLastSeen(friend.lastSeen.toLocal()), //! DYNAMIC
                                      style: TextStyle(
                                        fontSize: 15.sp, 
                                        fontStyle: FontStyle.italic,
                                        color: Colors.black,
                                        fontFamily: 'CenturyGothic'
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  
                            //? CHAT
                            SizedBox(
                              width: 50.w,
                              height: 50.h,
                              child: GestureDetector(
                                onTap: () {
                                  //_deleteFriend(friend.nickname);
                                  friend.unreadMessagesCount = 0;
                                  setState(() {});
                                  Navigator.of(context, rootNavigator: true).push(
                                    MaterialPageRoute(
                                      builder: (context) => FriendChat(friend: friends[index]),
                                    ),
                                  ).then((_) {
                                    friend.unreadMessagesCount = 0;
                                    setState(() {});
                                  });
                                },
                                child: Stack(
                                  children: [
                                    //? CHAT 
                                    Positioned(
                                      right: 7.w,
                                      top: 10.w,
                                      child: Icon(
                                        Icons.chat,
                                        color: Colors.black,
                                        size: 30.sp,
                                      ),
                                    ),
                              
                                    //? UNREAD MESSAGES COUNT
                                    if (friend.unreadMessagesCount > 0)
                                      Positioned(
                                        right: 0.w,
                                        top: -4.h,
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
                                )
                              ),
                            ),
                              
                            /*
                            SizedBox(
                              width: 85.w,
                              height: 35.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  _deleteFriend(friend.nickname);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                  //! DYNAMIC
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontFamily: 'CenturyGothic',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            )
                            */
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}



class RequestsTab extends StatefulWidget {
  const RequestsTab({super.key});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  StreamSubscription? _eventSubscription;
  List<FriendRequest> requests = [];
  // List<FriendRequest>? requests = [
  //   FriendRequest(
  //     nickname: 'Player1', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  //   ),
  //   FriendRequest(
  //     nickname: 'Player2', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  //   ),
  //   FriendRequest(
  //     nickname: 'Player3', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  //   ),

  // ];

  //late StreamSubscription<String> friendshipPendingFriendshipRequests;

  @override
  void initState() {
    super.initState();

    /*
    friendshipPendingFriendshipRequests = EventRouterService()
        .subscribe(ServerEvent.friendshipPendingFriendshipRequests)
        .listen((payload) async {
      try {
        final List<dynamic> jsonData = json.decode(payload)['pendingFriends'];

        requests = jsonData.isEmpty ? [] : jsonData.map((item) {
          return FriendRequest.fromJson(item as Map<String, dynamic>);
        }).toList();

        if (!mounted) return;
        setState(() {});
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipPendingFriendshipRequests Event - Friend Request Screen: ${e.toString()}');
      }
    });
    */

    _eventSubscription = EventBus().on<FriendRequestReceivedEvent>().listen((event) {
      setState(() {
        // DIRECT UPDATE: Add the new request to the TOP of the list
        requests.insert(0, FriendRequest(id: event.requestData["friendId"], nickname: event.requestData["nickname"], avatarUrl: event.requestData["avatarUrl"])); 
      });
    });

    
    _getRequests();
  }

  @override
  void dispose() {
    //friendshipPendingFriendshipRequests.cancel();
    _eventSubscription?.cancel();
    super.dispose();
  }

  void _getRequests() async {
    //TcpClientService().sendMessage(ClientCommand.getPendingFriendshipRequests.value, "");
    requests = await GetIt.I<ApiService>().getRequests() ?? [];
    if (!mounted) return;
    setState(() {});
  }

  void _approveFriend(int id, bool approve) async {
    //TcpClientService().sendMessage(ClientCommand.approveFriendship.value, json.encode({'nickname': nickname, 'approve': approve}));
    await GetIt.I<ApiService>().approveFriend(id, approve);
    requests.removeWhere((request) => request.id == id);
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TEXT:    REGISTRY
        Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: Text(
            AppLocalizations.of(context)!.registry,
            style: GoogleFonts.playfairDisplay(
              height: 1,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2723),
            ),
          ),
        ),

        // TEXT:    OF CHOOSEN ONES
        Text(
          AppLocalizations.of(context)!.ofChoosenOnes,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2723),
          ),
        ),

        // TEXT:    Only the truest ride together.
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Text(
            AppLocalizations.of(context)!.onlyTheTruestRideTogether,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14.sp,
              color: const Color(0xFF2A2723),
            ),
          ),
        ),
        
        //? IMAGE DIVIDER
        Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: Image.asset(
            "assets/images/roles-line.png",
            width: 130.w,
          ),
        ),
      
        //? REQUESTS
        (requests.isEmpty)
        ?
        Padding(
          padding: EdgeInsets.only(top: 20.h),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              AppLocalizations.of(context)!.noPlayersFound,
              style: GoogleFonts.playfairDisplay(
                color: Colors.black,
                fontSize: 18
              ),
            )
          ),
        )
        : 
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];

                return GestureDetector(
                  onTap: () {
                    showBouncingPopupFromLeft(
                      context, 
                      PlayerInfoPopup(
                        id: request.id,
                        height: 727.h, 
                        width: 405.w, 
                        nickname: request.nickname,
                      )
                    );
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                //? PROFILE PHOTO
                                CircleAvatar(
                                  backgroundImage: NetworkImage(request.avatarUrl), //!!!!!!!!!!!
                                  radius: 21.sp,
                                ),
                  
                                SizedBox(width: 12.w),
                  
                                //? REQUEST NICKNAME
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.nickname, //!!!!!!!!!!!
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18.sp, 
                                        color: Colors.black 
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  
                            //? BUTTONS:     REJECT AND ACCEPT
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _approveFriend(request.id, true);
                                    //EventBus().fire(FriendApprovedEvent(request.id, true));
                                  },
                                  child: Icon(
                                    Icons.handshake_outlined,
                                    color: const Color(0xFF302B25),
                                    size: 30.sp,
                                  )
                                ),
                                SizedBox(width: 5.w),
                                GestureDetector(
                                  onTap: () {
                                    _approveFriend(request.id, false);
                                    //EventBus().fire(FriendApprovedEvent(request.id, false));
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
                          
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}



class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  int count = 1;
  final TextEditingController _searchController = TextEditingController();
  //bool requestSent = false;
  List<FindFriend>? searchResults = [];
  // List<FindFriend>? searchResults = [
  //   FindFriend(
  //     nickname: 'Player1', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     friendshipStatus: 'None',
  //     createdDateTime: DateTime.now().subtract(const Duration(days: 1))
  //   ),
  //   FindFriend(
  //     nickname: 'Player2', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     friendshipStatus: '',
  //     createdDateTime: DateTime.now().subtract(const Duration(days: 2))
  //   ),
  //   FindFriend(
  //     nickname: 'Player3', 
  //     avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png', 
  //     friendshipStatus: 'Pending',
  //     createdDateTime: DateTime.now().subtract(const Duration(days: 3))
  //   ),
  // ];

  //late StreamSubscription<String> friendshipSearchedPlayers;
  //late StreamSubscription<String> friendshipSuggestedFriends;

  @override
  void initState() {
    super.initState();

    /*
    friendshipSearchedPlayers = EventRouterService()
        .subscribe(ServerEvent.friendshipSearchedPlayers)
        .listen((payload) async {
      try {
        final List<dynamic> jsonData = json.decode(payload)['players'];
        print("BBBBBBBBBBBBBB2222222: $jsonData");
        
        setState(() {
          searchResults = jsonData.isEmpty ? null : jsonData.map((item) {
            return FindFriend.fromJson(item as Map<String, dynamic>);
          }).toList();

          print("AAAAAAAAAAAAAA ${searchResults?.first.friendshipStatus}");
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipSearchedPlayers Event - Friend Search Screen: ${e.toString()}');
      }
    });

    friendshipSuggestedFriends = EventRouterService()
        .subscribe(ServerEvent.friendshipSuggestedFriends)
        .listen((payload) async {
      try {
        final List<dynamic> jsonData = json.decode(payload)['suggestedFriends'];
        print("BBBBBBBBBBBBBB2222222: $jsonData");
      
        setState(() {
          searchResults = jsonData.isEmpty ? null : jsonData.map((item) {
            return FindFriend.fromJson(item as Map<String, dynamic>);
          }).toList();
        });
      } on Exception catch (e) {
        log('EXCEPTION IN:     TIMER EVENT - GAME SCREEN: ${e.toString()}');
      }
    });
    */

    getPossibleFriends();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    //friendshipSearchedPlayers.cancel();
    //friendshipSuggestedFriends.cancel();
  }

  // DONE
  void getPossibleFriends() async {

    //TcpClientService().sendMessage(ClientCommand.getSuggestedFriends.value, "");

    searchResults = await GetIt.I<ApiService>().suggestedFriends();
    if (!mounted) return;
    setState(() {});
  }

  // DONE
  void _searchUsers() async {
    // if (_searchController.text.trim().isEmpty) {
    //   TcpClientService().sendMessage(ClientCommand.getSuggestedFriends.value, "");
    // } else {
    //   TcpClientService().sendMessage(ClientCommand.searchPlayers.value, json.encode({'pattern': _searchController.text.trim()}));
    // }

    if (_searchController.text.trim().isEmpty) {
      searchResults = await GetIt.I<ApiService>().suggestedFriends();
    } else {
      searchResults = await GetIt.I<ApiService>().findFriend(_searchController.text.trim());
    }
    if (!mounted) return;
    setState(() {});
  }

  void _sendRequest(int id) async {
    //TcpClientService().sendMessage(ClientCommand.requestFriendship.value, json.encode({'nickname': nickname}));
    await GetIt.I<ApiService>().sendRequest(id);
    setState(() {});
  }

  void changeFriendshipStatus(String nickname, String status) {
    setState(() {
      if (searchResults != null) {
        searchResults!.firstWhere((e) => e.nickname == nickname).friendshipStatus = status;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TEXT:    WANTED:
        Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: Text(
            AppLocalizations.of(context)!.wanted,
            style: GoogleFonts.playfairDisplay(
              height: 1,
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2A2723),
            ),
          ),
        ),

        // TEXT:    GOOD COMPANY
        Text(
          AppLocalizations.of(context)!.goodCompany,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2A2723),
          ),
        ),

        // TEXT:    Riding solo ain’t the way.
        Padding(
          padding: EdgeInsets.only(top: 3.h),
          child: Text(
            AppLocalizations.of(context)!.ridingSoloAintTheWay,
            style: GoogleFonts.playfairDisplay(
              fontSize: 14.sp,
              color: const Color(0xFF2A2723),
            ),
          ),
        ),

        //? IMAGE DIVIDER
        Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: Image.asset(
            "assets/images/roles-line.png",
            width: 130.w,
          ),
        ),

        //? SEARCHED PLAYERS
        Padding(
          padding: EdgeInsets.only(top: 15.h, left: 25.w, right: 20.w),
          child: Container(
            height: 40.h,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3E3E3E), width: 1.5),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Row(
              children: [
                // INPUT:    Search...
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 1.h),
                    child: TextField(
                      cursorColor: const Color(0xFF3E3E3E),
                      cursorHeight: 20.h,
                      
                      onTapOutside: (PointerDownEvent event) {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (value) => {
                        _searchUsers()
                      },
                      controller: _searchController,
                      style: TextStyle(color: const Color(0xFF3E3E3E), fontSize: 16.sp),
                      decoration: InputDecoration(
                        hintText: " ${AppLocalizations.of(context)!.search}...",
                        hintStyle: const TextStyle(color: Color(0xFF3E3E3E)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // BUTTON:    SEARCH
                Padding(
                  padding: EdgeInsets.only(right: 10.w),
                  child: GestureDetector(
                    onTap: () {
                      _searchUsers(); //! CHECK
                    },
                    child: Image.asset(
                      "assets/images/friends-search-icon.png",
                      width: 25.w,
                      height: 25.h,
                    ),
                  ),
                ),
                
              ],
            ),
          ),
        ),
      
        //? RESULTS
        Expanded(
          child: searchResults == null
          ? 
          Padding(
            padding: EdgeInsets.only(top: 20.h),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                AppLocalizations.of(context)!.noPlayersFound,
                style: GoogleFonts.playfairDisplay(
                  color: Colors.black,
                  fontSize: 18
                ),
              )
            ),
          )
          :
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: searchResults!.length,
              itemBuilder: (context, index) {
                FindFriend user = searchResults![index];
                //final hasVotes = player["votes"] > 0;
                //? SEARCHED AND FOUND ONES
                return GestureDetector(
                  onTap: () {
                    showBouncingPopupFromLeft(
                      context, 
                      PlayerInfoPopup(
                        id: user.id,
                        height: 727.h, 
                        width: 405.w,
                        nickname: user.nickname,
                      )
                    );
                  },
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                //? PROFILE PHOTO
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.avatarUrl),
                                  radius: 21.sp,
                                ),
                  
                                SizedBox(width: 12.w),
                  
                                // TEXT:    NICKNAME
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.nickname, //!!!!!!!!!!!
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18.sp, 
                                        color: Colors.black 
                                      )
                                    ),
                                  ],
                                ),
                              ],
                            ),
                  
                            //BUTTON:    DELETE
                            user.friendshipStatus == 'RequestPending'
                            ? 
                              Container(
                                margin: EdgeInsets.only(right: 5.w),
                                child: Icon(
                                  size: 30.sp,
                                  Icons.pending_actions,
                                  color: const Color(0xFF00695C),
                                ),
                              )
                              // Text(
                              //   AppLocalizations.of(context)!.requestPending,
                              //   style: TextStyle(
                              //     color: Colors.green,
                              //     fontSize: 15.sp,
                              //     fontFamily: 'CenturyGothic'
                              //   ),
                              // )
                            : user.friendshipStatus == 'ApprovePending'
                            ? 
                              Text(
                                AppLocalizations.of(context)!.approvePending,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              )
                            : user.friendshipStatus == 'None'
                            ? SizedBox(
                              width: 40.w,
                              height: 35.h,
                              child: GestureDetector(
                                onTap: () {
                                  //! CHECK
                                  _sendRequest(user.id);
                                  changeFriendshipStatus(user.nickname, 'RequestPending');
                                },
                                
                                child: Icon(
                                  Icons.handshake_outlined,
                                  color: const Color(0xFF302B25),
                                  size: 30.sp,
                                )
                              ),
                            )
                            : user.friendshipStatus == 'Accepted' 
                            ? Container(
                                margin: EdgeInsets.only(right: 5.w),
                                child: Icon(
                                  size: 30.sp,
                                  Icons.people_alt,
                                  color: const Color(0xFF302B25),
                                ),
                              )
                            : const SizedBox()
                            
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  
  }
}



class FriendChat extends StatefulWidget {
  final Friendship friend;
  const FriendChat({super.key, required this.friend});

  @override
  State<FriendChat> createState() => _FriendChatState();
}

class _FriendChatState extends State<FriendChat> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // List<Message> messages = [
  //   Message(text: "abrakadabra", isMe: false, time: DateTime.now(), id: 1),
  //   Message(text: "abrakadabra", isMe: true, time: DateTime.now(), id: 2, status: "DeLiVerEd"),
  //   Message(text: "abrakadabra", isMe: false, time: DateTime.now(), id: 3),
  //   Message(text: "abrakadabra", isMe: true, time: DateTime.now(), id: 4, status: "sENt"),
  // ];

  List<Message> messages = [];

  StreamSubscription? eventSubscriptionNewMessage;
  StreamSubscription? _eventSubscriptionFriendOnline;
  StreamSubscription? _eventSubscriptionFriendOffline;

  //late StreamSubscription<String> friendshipFriendMessages;
  late StreamSubscription<String> friendshipFriendMessagesReaded;
  late StreamSubscription<String> friendshipFriendMessagesDelivered;

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  bool _isUserAtBottom() {
    if (!_scrollController.hasClients) return false;
    const threshold = 50.0; 
    return _scrollController.position.maxScrollExtent -
          _scrollController.position.pixels < threshold;
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


  bool _autoScroll = true;
  bool _userDragging = false;

  @override
  void initState() {
    super.initState();
    isInFriendIdChatGlobal = widget.friend.id;

    eventSubscriptionNewMessage = EventBus().on<FriendNewMessageEvent>().listen((event) {
      setState(() {
        if (widget.friend.id == event.friendId) {
          messages.add(event.message);
          GetIt.I<ApiService>().readFriendMessages(widget.friend.id);
        }
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });

    _eventSubscriptionFriendOnline = EventBus().on<FriendOnlineEvent>().listen((event) {
      setState(() {
        if (event.friendId == widget.friend.id) {
          widget.friend.isOnline = true;
        }
      });
    });

    _eventSubscriptionFriendOffline = EventBus().on<FriendOfflineEvent>().listen((event) {
      setState(() {
        if (event.friendId == widget.friend.id) {
          widget.friend.isOnline = false;
          widget.friend.lastSeen = DateTime.now();
        }
      });
    });

    loadMessages();
    //!

    friendshipFriendMessagesReaded = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendMessagesReaded)
        .listen((payload) async {
      try {
        
        if (mounted) {
          setState(() {
            for (var msg in messages) {
              msg.status = "Read";
            }
          });

          EventBus().fire(FriendMessagesReadedEvent(friendId: widget.friend.id));

          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   scrollToBottom();
          // });
        }
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriendMessagesReaded Event - Friend Chat Screen: ${e.toString()}');
      }
    });

    friendshipFriendMessagesDelivered = EventRouterService()
        .subscribe(ServerEvent.friendshipFriendMessagesDelivered)
        .listen((payload) async {
      try {
        final int friendId = json.decode(payload)['friendId'] as int;
        if (mounted) {
          setState(() {
            if (friendId != widget.friend.id) return;
            for (var msg in messages) {
              if (msg.status != "Read") msg.status = "Delivered";
            }
          });

          // WidgetsBinding.instance.addPostFrameCallback((_) {
          //   scrollToBottom();
          // });
        }
      } on Exception catch (e) {
        log('EXCEPTION IN:     friendshipFriendMessagesReaded Event - Friend Chat Screen: ${e.toString()}');
      }
    });

    // friendshipFriendMessages = EventRouterService()
    //     .subscribe(ServerEvent.friendshipFriendMessages)
    //     .listen((payload) async {
    //   try {
    //     final List<dynamic> jsonList = json.decode(payload);

    //     List<Message> historyMessages = jsonList
    //         .map((jsonItem) => Message.fromJson(jsonItem))
    //         .toList();

    //     if (mounted) {
    //       setState(() {
    //         messages = historyMessages; 
    //       });

    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         scrollToBottom();
    //       });
    //     }
    //   } on Exception catch (e) {
    //     log('EXCEPTION IN:     friendshipFriendMessages Event - Friend Chat Screen: ${e.toString()}');
    //   }
    // });

    _scrollController.addListener(() {
      if (_scrollController.position.isScrollingNotifier.value) {
        _userDragging = true;
        _autoScroll = false;
      }

      if (_isUserAtBottom()) {
        _userDragging = false;
        _autoScroll = true;
      }
    });

    scrollToBottom();
  }

  @override
  void dispose() {
    super.dispose();
    isInFriendIdChatGlobal = -1;
    eventSubscriptionNewMessage?.cancel();
    _eventSubscriptionFriendOnline?.cancel();
    _eventSubscriptionFriendOffline?.cancel();
    friendshipFriendMessagesReaded.cancel();
    _scrollController.dispose();
    _messageController.dispose();
  }

  void scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      Future.microtask(() {
        if (_scrollController.hasClients && _autoScroll) {
          _scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void loadMessages() async {
    //await GetIt.I<ApiService>().readFriendMessages(widget.friend.nickname);
    var allMessages = await GetIt.I<ApiService>().getAllMessagesInFriendChat(widget.friend.id);

    if (mounted) {
      setState(() {
        messages = allMessages ?? [];
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    }

    await GetIt.I<ApiService>().readFriendMessages(widget.friend.id);
  }

  @override
  void didUpdateWidget(covariant FriendChat oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScroll) {
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/background-friend-chat.png"), fit: BoxFit.fill),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: SingleChildScrollView(
          child: Stack(
            children: [
              // BUTTON:    GoBack
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h, right: 10.w),
                      child: Image.asset(
                        "assets/images/close-white-icon.png",
                        width: 30.w,
                        height: 30.h,
                      ),
                    ),
                  ),
                ],
              ),
          
              Column(
                children: [
                  //? HEADER
                  Align(
                    alignment: Alignment.center,
                    //? NICKNAME AND IS ONLINE
                    child: Container(
                      width: 160.w,
                      height: 250.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D0D0D),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //? PROFILE PHOTO
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
                                      borderRadius: BorderRadius.circular(300.sp),
                                      child: Image.network(
                                        widget.friend.avatarUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                )
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.w),
                                borderRadius: BorderRadius.circular(55.r)
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(widget.friend.avatarUrl),
                                radius: 50.r,
                              ),
                            ),
                          ),
            
                          SizedBox(height: 10.h),
            
                          // TEXT:    NICKNAME
                          Text(
                            widget.friend.nickname,
                            softWrap: true,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(
                              height: 0,
                              fontSize: 24.sp, 
                              color: Colors.white 
                            )
                          ),
            
                          SizedBox(height: 5.h),

                          // TEXT:    IS ONLINE
                          Text(
                            widget.friend.isOnline ? AppLocalizations.of(context)!.online : formatLastSeen(widget.friend.lastSeen),
                            style: TextStyle(
                              fontSize: 16.sp, 
                              color: Colors.white,
                              fontFamily: 'CenturyGothic'
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                
                  //? CHAT
                  Container(
                    height: 520.h,
                    margin: EdgeInsets.only(top: 10.h, left: 10.w, right: 10.w),
                    padding: EdgeInsets.all(10.h),
                    decoration: BoxDecoration(
                      //color: const Color(0xFF2A2723).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        return ChatBubble(message: messages[index]);
                      },
                    ),
                  ),
                
                  //? INPUT PART
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // INPUT
                      Container(
                        width: 325.w,
                        height: 45.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3C278),
                          borderRadius: BorderRadius.circular(12.r)
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(left: 10.w, bottom: 6.h, right: 10.w),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(color: Colors.white, fontSize: 15.sp),
                            cursorColor: const Color(0xFFFFFFFF),
                            decoration: InputDecoration(
                              hintText: '${AppLocalizations.of(context)!.enterMessage}...',
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
          
                      SizedBox(width: 5.w),

                      // BUTTON:    Send
                      GestureDetector(
                        child: Container(
                          width: 46.w,
                          height: 45.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3C278),
                            borderRadius: BorderRadius.circular(12.r)
                          ),
                          child: Padding(
                            padding: EdgeInsetsGeometry.only(left: 2.w),
                            child: IconButton(
                              icon: Icon(Icons.send, color: Colors.white, size: 25.sp),
                              onPressed: () async {
                                if (_messageController.text.trim().isEmpty) return;
                                //messages.add(Message(text: _messageController.text, isMe: true, time: DateTime.now(), id: 001));
                                // TcpClientService().sendMessage(ClientCommand.sendMessageToFriend.value, json.encode({
                                //   'nickname': widget.friend.nickname,
                                //   'content': _messageController.text.trim(),
                                // }));
                                Map<String, dynamic>? response = await GetIt.I<ApiService>().sendNewMessageToFriend(
                                  widget.friend.id, 
                                  _messageController.text.trim()
                                );
                                _scrollToBottom();
                                if (!mounted) return;
                                print("RESPONSE MESSAGE ID: ${response?['messageId'].toString()}");
                                setState(() {
                                  messages.add(Message(text: _messageController.text, isMe: true, time: DateTime.now(), id: response?['messageId'], status: response?['status']));
                                  _messageController.clear();
                                });
                              },
                            ),
                          ) 
                        ),
                        
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ChatBubble extends StatelessWidget {
  final Message message;

  const ChatBubble({super.key, required this.message});

  bool isSameDay(DateTime a, DateTime b) {
    DateTime utcA = a.toUtc();
    DateTime utcB = b.toUtc();

    return utcA.year == utcB.year && 
      utcA.month == utcB.month && 
      utcA.day == utcB.day;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = message.isMe ? const Color(0xFF9C978E) : const Color(0xFFB0A07B);
    final align = message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final radius = message.isMe
        ? const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          );

    return Container(
      alignment: align,
      margin: EdgeInsets.symmetric(vertical: 6.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 280.w,
          minWidth: 100.w
        ),
        child: Container(
          padding: EdgeInsets.all(14.sp),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: radius,
          ),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 17.sp, 
                    color: Colors.black,
                    fontFamily: 'CenturyGothic'
                  ),
                ),
            
                SizedBox(height: 6.sp),
            
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // TEXT:     Time
                      Text(
                        isSameDay(message.time, DateTime.now())
                        ? DateFormat('HH:mm').format(message.time)
                        : DateFormat('dd.MM.yy, HH:mm').format(message.time),
                        style: TextStyle(
                          fontSize: 13.sp, 
                          color: Colors.black,
                          fontFamily: 'CenturyGothic'
                        ),
                      ),

                      //SizedBox(width: 5.w),

                      //? DELIVERED ICON
                      message.isMe
                      ? Container(
                        margin: EdgeInsets.only(left: 2.w),
                        child: 
                        message.status.toLowerCase() == "sent"
                          ? Icon(
                            Icons.check,
                            size: 18.sp,
                            color: Colors.black,
                          )
                          :
                          Icon(
                            Icons.done_all,
                            size: 18.sp,
                            color: message.status.toLowerCase() == "read" ? const Color(0xFFE3C278) : Colors.black,
                          ),
                      )
                      : const SizedBox(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Message {
  final int id;
  final String text;
  final bool isMe;
  final DateTime time;
  String status;

  static final DateFormat _customFormat = DateFormat('dd.MM.yyyy HH:mm');

  Message({required this.text, required this.isMe, required this.time, required this.id, this.status = "sent"});

  factory Message.fromJson(Map<String, dynamic> json) {
    final String dateTimeString = json['dateTime'] as String? ?? '';
    
    DateTime parsedDateTime = DateTime.now();
    
    if (dateTimeString.isNotEmpty) {
      DateTime? isoDate = DateTime.tryParse(dateTimeString);
      
      if (isoDate != null) {
        parsedDateTime = isoDate.toLocal();
      } else {
        try {
          parsedDateTime = _customFormat.parse(dateTimeString, true).toLocal();
        } catch (e) {
          print('Error parsing date CHAT "$dateTimeString": $e');
        }
      }
    }

    return Message(
      id: json['messageId'] as int,
      text: json['content'] as String,
      isMe: json['senderId'] == authorizedUser.id ? true : false,
      status: json['status'] ?? "sent",
      time: parsedDateTime,
    );
  }
}