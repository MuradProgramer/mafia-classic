import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mafia_classic/services/api_service.dart';

// ignore: must_be_immutable
class PlayerInfoPopup extends StatefulWidget {
  final double height;
  final double width;
  PlayerInfo playerInfo;

  PlayerInfoPopup({
    super.key, 
    required this.height, 
    required this.width, 
    required this.playerInfo,
  });

  @override
  State<PlayerInfoPopup> createState() => _PlayerInfoPopupState();
}

class _PlayerInfoPopupState extends State<PlayerInfoPopup> {
  final double ornamentSize = 50.sp;
  final double ornamentMargin = 5.sp;

  final double cardsMargin = 20.w;

  @override
  void initState() {
    super.initState();
    _loadPlayerInfo();
  }

  String formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds} secs ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} mins ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return DateFormat('dd.MM.yyyy').format(lastSeen);
    }
  }

  void _loadPlayerInfo() async {
    final playerInfoData = await GetIt.I<ApiService>().getPlayerInfo('musayev');
    print(playerInfoData.toString());
    setState(() {
      widget.playerInfo = PlayerInfo.from(playerInfoData);
    });
    print('-----------------');
    print(widget.playerInfo.toString());
  }

  @override
  Widget build(BuildContext context) {
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
                          'Profile',
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
                                          color: widget.playerInfo.isOnline ? const Color(0xFF896A44) : const Color(0xFF9D9D9D),
                                          border: Border.all(
                                            color: widget.playerInfo.isOnline ? const Color(0xFFB98744) : const Color(0xFFD6D6D6),
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
                                        widget.playerInfo.isOnline ? 'Online' : 'Offline',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      )
                                    ],
                                  ),
                                
                                  //? LAST SEEN
                                  widget.playerInfo.isOnline
                                  ? const SizedBox()
                                  : Text(
                                    formatLastSeen(widget.playerInfo.lastSeen!),
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
                                    widget.playerInfo.avatarUrl
                                  ),
                                  radius: 35.sp,
                                )
                              ),
                          
                              //? JOIN DATE
                              Column(
                                children: [
                                  // TEXT:    JOIN DATE
                                  Text(
                                    'Join Date',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'CenturyGothic',
                                      color: Colors.black,
                                      height: 0
                                    )
                                  ),
                                  
                                  //? JOIN DATE
                                  Text(
                                    DateFormat('dd.MM.yyyy').format(widget.playerInfo.joinDate),
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
                            widget.playerInfo.nickname,
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
                                      'Report',
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
                              widget.playerInfo.friendshipStatus == 'None'
                              ? GestureDetector(
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
                                        'Add To Friends',
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
                              : Text(
                                widget.playerInfo.friendshipStatus,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black
                                ),
                              ),
                    
                              // BUTTON:    CHAT
                              GestureDetector(
                                child: Container(
                                  width: 70.h,
                                  height: 35.h,
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
                                      'Chat',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontFamily: 'CenturyGothic',
                                        color: Colors.black
                                      ),
                                    ),
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
                        !widget.playerInfo.inGameLobby
                        ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            widget.playerInfo.isOnline ? 'Currently are not playing' : 'Currently Offline',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 20.sp,
                              color: const Color(0xFF4F4F4F)
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                'Currently are playing in:',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 20.sp,
                                  color: const Color(0xFF4F4F4F)
                                ),
                              ),
                            ),

                            Padding(
                              padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 10.h, bottom: 5.h),
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
                                            widget.playerInfo.gameLobbyTitle!,
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
                                            widget.playerInfo.gameLobbyStatus!,
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
                                          widget.playerInfo.gameLobbyPlayerCount!.toString(),
                                          style: GoogleFonts.playfairDisplay(
                                            fontSize: 20.sp,
                                            color: Colors.black
                                          )
                                        ),
                                    
                                        // TEXT:    Players in total
                                        Text(
                                          'Players in total',
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
                          'Stats',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20.sp,
                            color: Colors.black
                          ),
                        ),
                        
                        //? OVERALL STATS
                        Container(
                          height: 27.h,
                          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFAF977E),
                            borderRadius: BorderRadius.circular(12.sp)
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // TEXT:    OVERALL
                              Text(
                                'Overall',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'CenturyGothic',
                                  color: Colors.black
                                ),
                              ),

                              SizedBox(width: 50.w,),

                              //? OVERALL STATS
                              Text(
                                widget.playerInfo.overall.toString(),
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
                                        'Wins',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      // TEXT:    WINS
                                      Text(
                                        'Loses',
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
                                        widget.playerInfo.wins.toString(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      //? LOSES
                                      Text(
                                        widget.playerInfo.loses.toString(),
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
                                        'Mafia Wins',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      // TEXT:    CIVILIAN WINS
                                      Text(
                                        'Civilian Wins',
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
                                        widget.playerInfo.mafiaWins.toString(),
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontFamily: 'CenturyGothic',
                                          color: Colors.black
                                        ),
                                      ),
                                                        
                                      SizedBox(height: 10.h),
                                                        
                                      //? CIVILIAN WINS
                                      Text(
                                        widget.playerInfo.civilianWins.toString(),
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
                          'Played Roles',
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
                            WinRole(role: 'Civilian', winCount: widget.playerInfo.playedRoles[('Civillian')]!),
                            SizedBox(width: cardsMargin),

                            //? DOCTOR
                            WinRole(role: 'Doctor', winCount: widget.playerInfo.playedRoles[('Doctor')]!),
                            SizedBox(width: cardsMargin),

                            //? SHERIFF
                            WinRole(role: 'Sheriff', winCount: widget.playerInfo.playedRoles[('Sheriff')]!),
                            SizedBox(width: cardsMargin),

                            //? BODYGUARD
                            WinRole(role: 'Bodyguard', winCount: widget.playerInfo.playedRoles[('Bodyguard')]!),
                            SizedBox(width: cardsMargin),

                            //? BEAUTY
                            WinRole(role: 'Beauty', winCount: widget.playerInfo.playedRoles[('Beauty')]!),
                            SizedBox(width: cardsMargin),

                            //? JOURNALIST
                            WinRole(role: 'Journalist', winCount: widget.playerInfo.playedRoles[('Journalist')]!),
                            SizedBox(width: cardsMargin),

                            //? SPY
                            WinRole(role: 'Spy', winCount: widget.playerInfo.playedRoles[('Spy')]!),
                          ],
                        ),
                      
                        SizedBox(height: 10.h),

                        //? PLAYED ROLES - MAFIA TEAM
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //? MAFIA
                            WinRole(role: 'Mafia', winCount: widget.playerInfo.playedRoles[('Mafia')]!),
                            SizedBox(width: cardsMargin),

                            //? TERRORIST
                            WinRole(role: 'Terrorist', winCount: widget.playerInfo.playedRoles[('Terrorist')]!),
                            SizedBox(width: cardsMargin),

                            //? INFORMANT
                            WinRole(role: 'Informant', winCount: widget.playerInfo.playedRoles[('Informant')]!),
                            SizedBox(width: cardsMargin),

                            //? BARMAN
                            WinRole(role: 'Barman', winCount: widget.playerInfo.playedRoles[('Barman')]!)
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
  final String nickname;
  final String avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime joinDate;
  final String friendshipStatus;
  final String? gameLobbyTitle;
  final String? gameLobbyStatus;
  final int? gameLobbyPlayerCount;
  final bool inGameLobby;
  final int overall;
  final int wins;
  final int loses;
  final int mafiaWins;
  final int civilianWins;
  final Map<String, int> playedRoles;

  PlayerInfo({
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
    required this.playedRoles,
    required this.gameLobbyTitle, 
    required this.gameLobbyStatus, 
    required this.gameLobbyPlayerCount,
  });

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
  playedRoles: $playedRoles
)
''';
  }

  PlayerInfo.from(PlayerInfo other)
    : nickname = other.nickname,
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
      playedRoles = Map.from(other.playedRoles),
      gameLobbyTitle = other.gameLobbyTitle,
      gameLobbyStatus = other.gameLobbyStatus,
      gameLobbyPlayerCount = other.gameLobbyPlayerCount;
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