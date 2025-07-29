import 'dart:developer';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mafia_classic/generated/l10n.dart';

//import 'package:mafia_classic/blocs/player_bloc.dart';
// import 'package:mafia_classic/blocs/player_event.dart';
// import 'package:mafia_classic/blocs/player_state.dart';

//import 'package:mafia_classic/repositories/player_repository.dart';

import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/features/profile/friends/widgets/widgets.dart';
import 'package:mafia_classic/features/profile/friends/view/screens/screens.dart';
import 'package:mafia_classic/theme/theme.dart';

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
          padding: EdgeInsets.only(top: 60.h, left: 10.w, right: 10.w, bottom: 10.h),
          child: Column(
            children: [
              //? BUTTON GO HOME
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
                              'Friends', // NOTE:    Translation L10
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
                              'Requests', // NOTE:    Translation L10
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
                              'Search', // NOTE:    Translation L10
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
                            borderRadius: BorderRadius.circular(100.0),
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
          title: Text(S.of(context).friends.toUpperCase(), style: theme.textTheme.bodyMedium),
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
  List<Friendship>? friends = [];
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
    super.initState();
    _loadFriends();
  }

  void _loadFriends() async {
    final updatedFriends = await GetIt.I<ApiService>().getFriends();

    if (!mounted) return;

    setState(() {
      friends = updatedFriends;
    });
  }

  void _deleteFriend(String nickname) async {
    bool isDeleted = await GetIt.I<ApiService>().deleteFriend(nickname);
    if (isDeleted) {
      _loadFriends();
    } else {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TEXT:    TRUSTED INDIVIDUALS
        Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: Text(
            'TRUSTED INDIVIDUALS',
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
            'Justice rides with us.',
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
                      cursorColor: const Color(0xFF3E3E3E),
                      cursorHeight: 20.h,
                      onTapOutside: (PointerDownEvent event) {
                        FocusScope.of(context).unfocus();
                      },
                      controller: searchController,
                      style: TextStyle(color: const Color(0xFF3E3E3E), fontSize: 16.sp),
                      decoration: const InputDecoration(
                        hintText: " Search...",
                        hintStyle: TextStyle(color: Color(0xFF3E3E3E)),
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: friends == null ? 0 : friends?.length,
              itemBuilder: (context, index) {
                if (friends == null) {
                  return Center(
                    child: Text(
                      'No friends found', //NOTE:   Translation L10
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                  );
                }
                final friend = friends![index];
                //final hasVotes = player["votes"] > 0;
                return Column(
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
                                    friend.isOnline ? 'Online' : DateFormat('yyyy.MM.dd HH:mm').format(friend.lastSeen), //! DYNAMIC
                                    style: TextStyle(
                                      fontSize: 15.sp, 
                                      color: Colors.black,
                                      fontFamily: 'CenturyGothic'
                                    )
                                  ),
                                ],
                              ),
                            ],
                          ),
                
                          //BUTTON:    DELETE
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
                                'Delete', // NOTE:    Translation L10 
                                //! DYNAMIC
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
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
  List<FriendRequest>? requests = [];
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

  @override
  void initState() {
    super.initState();
    _getRequests();
  }

  void _getRequests() async {
    requests = await GetIt.I<ApiService>().getRequests();
    if (!mounted) return;
    setState(() {});
  }

  void _approveFriend(String nickname, bool approve) async {
    bool isApproved = await GetIt.I<ApiService>().approveFriend(nickname, approve);
    if (isApproved) {
      _getRequests();
    } else {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TEXT:    REGISTRY
        Padding(
          padding: EdgeInsets.only(top: 30.h),
          child: Text(
            'REGISTRY',
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
          'OF CHOOSEN ONES',
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
            'Only the truest ride together.',
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: requests == null ? 0 : requests?.length,
              itemBuilder: (context, index) {
                if (requests == null) {
                  return Center(
                    child: Text(
                      'No requests found', //NOTE:   Translation L10
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 25.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                  );
                }

                final request = requests![index];

                return Column(
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
                                  _approveFriend(request.nickname, false);
                                },
                                child: Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                  size: 25.sp,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              GestureDetector(
                                onTap: () {
                                  _approveFriend(request.nickname, true);
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.green,
                                  size: 25.sp,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
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

  @override
  void initState() {
    super.initState();
    getPossibleFriends();
  }

  void getPossibleFriends() async {
    searchResults = await GetIt.I<ApiService>().possibleFriends();
    if (!mounted) return;
    setState(() {});
  }

  void _searchUsers() async {
    if (_searchController.text.isEmpty) {
      searchResults = await GetIt.I<ApiService>().possibleFriends();
    } else {
      searchResults = await GetIt.I<ApiService>().findFriend(_searchController.text);
    }
    if (!mounted) return;
    setState(() {});
  }

  void _sendRequest(String nickname) async {
    await GetIt.I<ApiService>().sendRequest(nickname);
    setState(() {});
  }

  void changeFriendshipStatus(String nickname) {
    setState(() {
      if (searchResults != null) {
        searchResults!.firstWhere((e) => e.nickname == nickname).friendshipStatus = '';
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
            'WANTED:',
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
          'GOOD COMPANY',
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
            'Riding solo ain\'t the way.',
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
                      decoration: const InputDecoration(
                        hintText: " Search...",
                        hintStyle: TextStyle(color: Color(0xFF3E3E3E)),
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
                'No users found',
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
                return Column(
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
                          ? Text(
                              "Request Pending", // NOTE:    Translation L10
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            )
                          : user.friendshipStatus == 'ApprovePending'
                          ? Text(
                              "Approve Pending", // NOTE:    Translation L10
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            )
                          : user.friendshipStatus == 'None'
                          ? SizedBox(
                            width: 110.w,
                            height: 35.h,
                            child: ElevatedButton(
                              onPressed: () {
                                //! CHECK
                                _sendRequest(user.nickname);
                                setState(() {

                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, //! DYNAMIC
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              
                              child: Text(
                                'Send Request', // NOTE:    Translation L10 
                                //! DYNAMIC
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          )
                          : const SizedBox()
                          
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  
  }
}
