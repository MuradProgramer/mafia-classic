import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/profile/friends/view/friends_screen.dart';
import 'package:mafia_classic/features/profile/ratings/view/ratings_screen.dart';
import 'package:mafia_classic/features/profile/roles/view/roles_screen.dart';
import 'package:mafia_classic/features/settings/view/settings_screen.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/models/models.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  final String title = 'MAFIA CLASSIC';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

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
                                'Mafia',
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
                                  'classic',
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
                                    'Welcome,',
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
                                      'Rating',
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
                                      'Settings',
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
                                      'Roles',
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
                              //!
                              GestureDetector(
                                onTap: () {
                                  //Navigator.of(context).pushNamed('/profile/share');
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
                                      'Chat',
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