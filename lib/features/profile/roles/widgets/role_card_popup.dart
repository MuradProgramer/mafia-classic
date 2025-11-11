import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';

class RoleCardPopup extends StatefulWidget {
  final String roleName;
  final int closeType;

  const RoleCardPopup({super.key, required this.roleName, required this.closeType});

  @override
  State<RoleCardPopup> createState() => _RoleCardPopupState();
}

class _RoleCardPopupState extends State<RoleCardPopup> {
  final double ornamentSize = 50.sp;
  final double ornamentMargin = 5.sp;

  Map<String, String> rolesGeneralDescription = {
    'mafia': "",
    'civilian': "",
    'spy': "",
    'doctor': "",
    'beauty': "",
    'bodyguard': "",
    'barman': "",
    'informant': "",
    'sheriff': "You are the Sheriff — the town’s investigator, dedicated to uncovering the Mafia. Use your sharp instincts and investigative skills to expose the criminals before it’s too late.",
    'journalist': "",
    'terrorist': "",
  };

  Map<String, String> rolesObjective = {
    'mafia': "",
    'civilian': "",
    'spy': "",
    'doctor': "",
    'beauty': "",
    'bodyguard': "",
    'barman': "",
    'informant': "",
    'sheriff': "Eliminate all members of the Mafia.",
    'journalist': "",
    'terrorist': "",
  };

  Map<String, String> rolesDayPhase = {
    'mafia': "",
    'civilian': "",
    'spy': "",
    'doctor': "",
    'beauty': "",
    'bodyguard': "",
    'barman': "",
    'informant': "",
    'sheriff': "Participate in daytime discussions, help the townspeople identify the Mafia, and vote to exile suspects.",
    'journalist': "",
    'terrorist': "",
  };

  Map<String, String> rolesThirdTitle = {
    'mafia': "",
    'civilian': "",
    'spy': "",
    'doctor': "",
    'beauty': "",
    'bodyguard': "",
    'barman': "",
    'informant': "",
    'sheriff': "Night Phase / Skill",
    'journalist': "",
    'terrorist': "",
  };

  Map<String, String> rolesThirdDescription = {
    'mafia': "",
    'civilian': "",
    'spy': "",
    'doctor': "",
    'beauty': "",
    'bodyguard': "",
    'barman': "",
    'informant': "",
    'sheriff': "Each night, use your Sheriff’s ability to investigate one player and learn their true role or alignment.",
    'journalist': "",
    'terrorist': "",
  };

  Map<String, String> rolesWinningConditions = {
    'mafia': "",
    'civilian': "",
    'spy': "",
    'doctor': "",
    'beauty': "",
    'bodyguard': "",
    'barman': "",
    'informant': "",
    'sheriff': "The Town wins when all Mafia members have been eliminated.",
    'journalist': "",
    'terrorist': "",
  };

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.86,
          padding: EdgeInsets.all(5.sp),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/role-card-background-${widget.roleName}.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(6.sp),
          ),
          child: Container(
            margin: EdgeInsets.all(5.sp),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(
                color: ['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) 
                  ? Colors.white 
                  : const Color(0xFF494239),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //? BUTTON:    X
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
      
                    //BUTTON:    X
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, right: 10.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (widget.closeType == 1) {
                                Navigator.of(context).pop();
                              } else {
                                PopupManager().close('roleInformationPopup');
                              }
                              
                            },
                            child: Image.asset(
                              ['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) 
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
      
                //? DESCRIPTION
                Column(
                  children: [
                    //? GENERAL DESCRIPTION
                    Padding(
                      padding: EdgeInsets.only(top: 120.sp),
                      child: Text(
                        rolesGeneralDescription[widget.roleName]!,
                        style: GoogleFonts.playfairDisplay(
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: ['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) 
                            ? const Color(0xFF917A4D)
                            : const Color(0xFF807B75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
      
                    //? PATTERN
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Image.asset(
                        ['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) 
                          ? 'assets/images/pattern-2.png'
                          : 'assets/images/pattern-1.png',
                        height: 20.h,
                        width: 92.w,
                      ),
                    ),

                    //? MORE DETAILS
                    Container(
                      height: 330.h,
                      width: double.maxFinite,
                      margin: EdgeInsets.all(10.sp),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) 
                            ? const Color(0xFFFFFFFF)
                            : const Color(0xFF494239),
                          width: 2.0,
                        ),
                        borderRadius: BorderRadius.circular(3.sp),
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
                                  "assets/images/game-ornament-${['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
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
                                    "assets/images/game-ornament-${['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
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
                                    "assets/images/game-ornament-${['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
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
                                    "assets/images/game-ornament-${['mafia', 'terrorist', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
                                    width: ornamentSize,
                                    height: ornamentSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // TEXT: GamePlay Rules
                              Container(
                                margin: EdgeInsets.only(top: 15.h),
                                child: Text(
                                  "Gameplay Rules:",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    height: 0,
                                    fontFamily: 'CenturyGothic',
                                    color: const Color(0xFFFFB000),
                                    fontWeight: FontWeight.w800
                                  ),
                                ),
                              ),
                          
                              SizedBox(height: 10.h),
                          
                              //? Rules
                              Container(
                                margin: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 50.h),
                                child: Column(
                                  children: [
                          
                                    //? Objective
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          // TEXT:    Objective
                                          TextSpan(
                                            text: "Objective: ",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFFFFB000),
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                      
                                          // TEXT
                                          TextSpan(
                                            text: rolesObjective[widget.roleName],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFF000000),
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                                        ]
                                      )
                                    ),
                                  
                                    SizedBox(height: 10.h),
                          
                                    //? Day Phase
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          // TEXT:    Day Phase
                                          TextSpan(
                                            text: "Day Phase: ",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFFFFB000),
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                      
                                          // TEXT
                                          TextSpan(
                                            text: rolesDayPhase[widget.roleName],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFF000000),
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                                        ]
                                      )
                                    ),
                                  
                                    SizedBox(height: 10.h),
                          
                                    //? Third Description
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          // TEXT:    Third Desc Title
                                          TextSpan(
                                            text: "${rolesThirdTitle[widget.roleName]}: ",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFFFFB000),
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                      
                                          // TEXT:    Third Description
                                          TextSpan(
                                            text: rolesThirdDescription[widget.roleName],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFF000000),
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                                        ]
                                      )
                                    ),
                                  
                                    SizedBox(height: 10.h),
                          
                                    //? Winning Conditions
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          // TEXT:    Winning Conditions
                                          TextSpan(
                                            text: "Winning Conditions: ",
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontStyle: FontStyle.italic,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFFFFB000),
                                              fontWeight: FontWeight.w800
                                            ),
                                          ),
                                      
                                          // TEXT
                                          TextSpan(
                                            text: rolesWinningConditions[widget.roleName],
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              height: 0,
                                              fontFamily: 'CenturyGothic',
                                              color: const Color(0xFF000000),
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                                        ]
                                      )
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}