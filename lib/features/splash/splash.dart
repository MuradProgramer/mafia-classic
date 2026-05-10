import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/auth/auth.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/features/widgets/widgets.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/models/user.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/shared_preferences/auth/auth_cache_service.dart';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';
import 'package:mafia_classic/services/tcp/general_service.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';
import 'package:mafia_classic/utils/popup_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<PlayerRole> players = [
  PlayerRole(
    id: -1,
    role: 'Doctor'
  ),
  PlayerRole(
    id: -2,
    role: 'Citizen'
  ),
  PlayerRole(
    id: -3,
    role: 'Mafia'
  ),
  PlayerRole(
    id: -4,
    role: 'Citizen'
  ),
  PlayerRole(
    id: -5,
    role: 'Citizen'
  ),
  PlayerRole(
    id: -6,
    role: 'Kamikaze'
  ),
  PlayerRole(
    id: -7,
    role: 'Barman'
  ),
];

List<Player> allPlayers = [
  Player(
    id: -1,
    nickname: 'Player1001',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -2,
    nickname: 'Player2',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -3,
    nickname: 'Player3aaaa',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -4,
    nickname: 'Player4',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -5,
    nickname: 'Pl5',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -6,
    nickname: 'Player6',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
  Player(
    id: -7,
    nickname: 'Player7',
    isAlive: true,
    avatarUrl: 'https://www.w3schools.com/w3images/avatar6.png'
  ),
];


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final int myTargetMilliseconds = 500;
  final ValueNotifier<int> myProgress = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    //final width = MediaQuery.of(context).size.width;

    void initGeneralServiceForAuthorizedUser(User authorized) async {
      await GeneralService(authorized).init();
    }

    Timer(Duration(milliseconds: myTargetMilliseconds + 100), () async {
      final authorized = await AuthService.hasValidSession(context);

      if (!mounted) return;
      Navigator.push(context, 
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) { 
            if (authorized) {
              User alreadyUser = User(
                id: SharedPrefsService.getUserId()!, 
                email: SharedPrefsService.getUserEmail()!, 
                nickname: SharedPrefsService.getUserNickname()!, 
                avatarUrl: SharedPrefsService.getUserAvatarUrl()!, 
                accessToken: SharedPrefsService.getAccessToken()!, 
                refreshToken: SharedPrefsService.getRefreshToken()!, 
                expirationDate: SharedPrefsService.getAccessTokenExpiryUtc()!
              );
              setup(alreadyUser);
              initGeneralServiceForAuthorizedUser(alreadyUser);
              print("\n\n------------------------------");
              print('Already authorized id: ${alreadyUser.id}');
              print('Already authorized nickname: ${alreadyUser.nickname}');
              print('Already authorized access token: ${alreadyUser.accessToken}');
              print('Already authorized refresh token: ${alreadyUser.refreshToken}');
              print('Already authorized expiration date: ${alreadyUser.expirationDate.toLocal().toIso8601String()}');
              print("------------------------------\n\n");
              return HomeScreen(user: alreadyUser);
            }
            else {
              return const SignInScreen();
            }
          }
          
          // builder: (context) => FriendChat(friend: 
          //   Friendship(
          //     gameTitle: 'Avengers999',
          //     nickname: 'Leonardo Di Caprio', 
          //     avatarUrl: 'https://mediaproxy.tvtropes.org/width/1200/https://static.tvtropes.org/pmwiki/pub/images/tony_stark.png',
          //     isOnline: true,
          //     lastSeen: DateTime.now()
          //   ),
          // )
          
          //builder: (context) => const SignUpScreen()
          //builder: (context) => const SettingsScreen(),
          //builder: (context) => const ForgotPasswordScreen(),
          //builder: (context) => const RatingsScreen(),
          //builder: (context) => GameScreen(title: 'Avengers999', playersRole: players, mafiaCount: 2, citizenCount: 5, role: 'Journalist', allPlayers: allPlayers, cameBackFromAfk: false, gameIsReadyWidget: true,)
          //builder: (context) => GamesScreen(user: authorizedUser)
          //builder: (context) => const CreateGameScreen(),
          //builder: (context) => HomeScreen(user: authorizedUser),
          //builder: (context) => const CreateGameScreen(),
          //builder: (context) => const FilterizationScreen(),
          //builder: (context) => const RolesScreen() // FALSEEE
          //builder: (context) => const FriendsScreen() // FALSEEE
          //builder: (context) => GameLobbyScreen(game: Game(extraRoles: ['Bodyguard', 'Beauty', 'Spy', 'Journalist'], hasPassword: false, maxPlayers: 11, minPlayers: 6, players: allPlayers, status: 'Gathering Players', title: 'Avengers999'), password: ''),
        ) 
      );
    });

    return Padding(
      padding: EdgeInsetsGeometry.only(top: 50.h),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/background-splash.png"), fit: BoxFit.cover, opacity: 0.9),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /*
              Container(
                margin: EdgeInsets.symmetric(vertical: height * 0.2),
                
                child: Align(
                  alignment: Alignment.topCenter,
                  child: TextButton(
                    onPressed: () {
                      showBouncingPopupFromLeft(
                        context, 
                        PlayerInfoPopup(
                          id: 123,
                          height: 727.h, 
                          width: 405.w,
                          nickname: 'Admin',
                          /*
                          playerInfo: PlayerInfo(
                            nickname: 'Tony Stark', 
                            avatarUrl: 'assets/avatar.jpg', 
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
                              "Kamikaze": 245,
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
                    child: Text(
                      'MAFIA CLASSIC',
                      style: TextStyle(
                        fontSize: 40.sp, 
                        color: Colors.white, 
                        fontWeight: FontWeight.w700,
                      )
                    )
                  )
                )
              ),
              */
              //? MAFIA CLASSIC TEXT
              Padding(
                padding: EdgeInsets.only(top: 0.h),
                child: Row(
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
                                  "classic edition",
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
              ),
              
              //SizedBox(height: 130.h),
              
              //? PROGRESS BAR
              Column(
                children: [
                  //? PROGRESS BAR PERCEENTAGE
                  // ValueListenableBuilder<int>(
                  //   valueListenable: myProgress,
                  //   builder: (context, value, child) {
                  //     return Text(
                  //       "$value %", 
                  //       style: TextStyle(
                  //         fontSize: 40.sp, 
                  //         color: Colors.white, 
                  //         fontWeight: FontWeight.bold,
                  //         fontFamily: 'CenturyGothic',
                  //       )
                  //     );
                  //   },
                  // ),
      
                  
      
                  //? PROGRESS BAR
                  DynamicProgressBar(
                    durationInMilliseconds: myTargetMilliseconds, 
                    progressNotifier: myProgress, 
                    onComplete: () {
                      
                    },
                  ),

                  SizedBox(height: 25.h),

                  // Text(
                  //   "Loading Game", 
                  //   style: TextStyle(
                  //     fontSize: 30.sp, 
                  //     color: Colors.white, 
                  //     fontFamily: 'CenturyGothic',
                  //   )
                  // )
                ],
              ),
                  
              // Text(
              //   'Powered by CORPORAZ', 
              //   style: TextStyle(
              //     color: Colors.white.withOpacity(0.8), 
              //     fontWeight: FontWeight.w700,
              //   ),
              // ),
      
              //const SizedBox()
            ],
          )        
        ),
      ),
    );
    
  }
}

class DynamicProgressBar extends StatefulWidget {
  final int durationInMilliseconds; // Dynamic seconds
  final ValueNotifier<int> progressNotifier; // To show percentage elsewhere
  final VoidCallback? onComplete;

  const DynamicProgressBar({
    super.key, 
    required this.durationInMilliseconds, 
    required this.progressNotifier, 
    this.onComplete
  });

  @override
  State<DynamicProgressBar> createState() => _DynamicProgressBarState();
}

class _DynamicProgressBarState extends State<DynamicProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // 1. Use the dynamic variable for duration
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationInMilliseconds),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear), // Linear for steady progress
    )..addListener(() {
        // 2. Update the shared notifier so other widgets can see the %
        int currentPercent = (_animation.value * 100).toInt();
        if (widget.progressNotifier.value != currentPercent) {
          widget.progressNotifier.value = currentPercent;
        }
        setState(() {}); 
      });

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320.w,
      height: 14.h, // Slightly taller for better shadow visibility
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3), // Dark background for the "track"
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          // Subtle outer shadow to lift the whole widget
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          // Inner shadow effect (darker edge)
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            //inset: true, // If using a package like flutter_inset_box_shadow
            blurRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: CustomPaint(
          painter: SimpleGradientPainter(progress: _animation.value),
        ),
      ),
    );
  }
}

// Minimal Painter for the Amazing Look
class SimpleGradientPainter extends CustomPainter {
  final double progress;
  SimpleGradientPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final double currentWidth = size.width * progress;
    final RRect progressRect = RRect.fromLTRBR(
      0, 0, currentWidth, size.height, Radius.circular(20.r)
    );

    // 1. THE GLOW SHADOW (Inner/Outer Glow)
    // We create a separate paint for the shadow to make it look like a neon light
    final Paint shadowPaint = Paint()
      ..color = const Color(0xFF000000).withOpacity(0.5) // Shadow color
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8); // This creates the glow

    // Draw the glow slightly offset or centered behind the bar
    canvas.drawRRect(progressRect, shadowPaint);

    // 2. THE MAIN GRADIENT FILL
    final Paint fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFB000), Color(0xFFFF7000)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(progressRect.outerRect)
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(progressRect, fillPaint);

    // 3. OPTIONAL: WHITE OVERLAY (For a 3D Glass look)
    // final Paint highlightPaint = Paint()
    //   ..color = Colors.white.withOpacity(0.2)
    //   ..style = PaintingStyle.fill;
    
    // final RRect highlightRect = RRect.fromLTRBR(
    //   2.w, 2.h, currentWidth - 2.w, size.height / 2.5, Radius.circular(20.r)
    // );
    
    // canvas.drawRRect(highlightRect, highlightPaint);
  }

  @override
  bool shouldRepaint(SimpleGradientPainter oldDelegate) => oldDelegate.progress != progress;
}