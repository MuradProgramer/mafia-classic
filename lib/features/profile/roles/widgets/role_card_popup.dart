import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';

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

  Map<String, String> get rolesGeneralDescription => {
    'mafia': AppLocalizations.of(context)!.rolesGeneralDescriptionMafia,
    'civilian': AppLocalizations.of(context)!.rolesGeneralDescriptionCivilian,
    'spy': AppLocalizations.of(context)!.rolesGeneralDescriptionSpy,
    'doctor': AppLocalizations.of(context)!.rolesGeneralDescriptionDoctor,
    'beauty': AppLocalizations.of(context)!.rolesGeneralDescriptionBeauty,
    'bodyguard': AppLocalizations.of(context)!.rolesGeneralDescriptionBodyguard,
    'barman': AppLocalizations.of(context)!.rolesGeneralDescriptionBarman,
    'informant': AppLocalizations.of(context)!.rolesGeneralDescriptionInformant,
    'sheriff': AppLocalizations.of(context)!.rolesGeneralDescriptionSheriff,
    'journalist': AppLocalizations.of(context)!.rolesGeneralDescriptionJournalist,
    'kamikaze': AppLocalizations.of(context)!.rolesGeneralDescriptionKamikaze,
  };

  Map<String, String> get rolesObjective => {
    'mafia': AppLocalizations.of(context)!.rolesObjectiveMafia,
    'civilian': AppLocalizations.of(context)!.rolesObjectiveVicilian,
    'spy': AppLocalizations.of(context)!.rolesObjectiveSpy,
    'doctor': AppLocalizations.of(context)!.rolesObjectiveDoctor,
    'beauty': AppLocalizations.of(context)!.rolesObjectiveBeauty,
    'bodyguard': AppLocalizations.of(context)!.rolesObjectiveBodyguard,
    'barman': AppLocalizations.of(context)!.rolesObjectiveBarman,
    'informant': AppLocalizations.of(context)!.rolesObjectiveInformant,
    'sheriff': AppLocalizations.of(context)!.rolesObjectiveSheriff,
    'journalist': AppLocalizations.of(context)!.rolesObjectiveJournalist,
    'kamikaze': AppLocalizations.of(context)!.rolesObjectiveKamikaze,
  };

  Map<String, String> get rolesDayPhase => {
    'mafia': AppLocalizations.of(context)!.rolesDayPhaseMafia,
    'civilian': AppLocalizations.of(context)!.rolesDayPhaseCivilian,
    'spy': AppLocalizations.of(context)!.rolesDayPhaseSpy,
    'doctor': AppLocalizations.of(context)!.rolesDayPhaseDoctor,
    'beauty': AppLocalizations.of(context)!.rolesDayPhaseBeauty,
    'bodyguard': AppLocalizations.of(context)!.rolesDayPhaseBodyguard,
    'barman': AppLocalizations.of(context)!.rolesDayPhaseBarman,
    'informant': AppLocalizations.of(context)!.rolesDayPhaseInformant,
    'sheriff': AppLocalizations.of(context)!.rolesDayPhaseSheriff,
    'journalist': AppLocalizations.of(context)!.rolesDayPhaseJournalist,
    'kamikaze': AppLocalizations.of(context)!.rolesDayPhaseKamikaze,
  };

  List<String> exceptionRolesForSecondTitle = ['bodyguard', 'kamikaze'];

  List<String> exceptionRolesForThirdTitle = ['doctor', 'beauty', 'barman', 'informant', 'sheriff', 'journalist'];

  Map<String, String> get rolesThirdDescription => {
    'mafia': AppLocalizations.of(context)!.rolesThirdDescriptionMafia,
    'civilian': AppLocalizations.of(context)!.rolesThirdDescriptionCivilian,
    'spy': AppLocalizations.of(context)!.rolesThirdDescriptionSpy,
    'doctor': AppLocalizations.of(context)!.rolesThirdDescriptionDoctor,
    'beauty': AppLocalizations.of(context)!.rolesThirdDescriptionBeauty,
    'bodyguard': AppLocalizations.of(context)!.rolesThirdDescriptionBodyguard,
    'barman': AppLocalizations.of(context)!.rolesThirdDescriptionBarman,
    'informant': AppLocalizations.of(context)!.rolesThirdDescriptionInformant,
    'sheriff': AppLocalizations.of(context)!.rolesThirdDescriptionSheriff,
    'journalist': AppLocalizations.of(context)!.rolesThirdDescriptionJournalist,
    'kamikaze': AppLocalizations.of(context)!.rolesThirdDescriptionKamikaze,
  };

  Map<String, String> get rolesWinningConditions => {
    'mafia': AppLocalizations.of(context)!.rolesWinningConditionMafia,
    'civilian': AppLocalizations.of(context)!.rolesWinningConditionsCivilian,
    'spy': AppLocalizations.of(context)!.rolesWinningConditionsSpy,
    'doctor': AppLocalizations.of(context)!.rolesWinningConditionsDoctor,
    'beauty': AppLocalizations.of(context)!.rolesWinningConditionsBeauty,
    'bodyguard': AppLocalizations.of(context)!.rolesWinningConditionsBodyguard,
    'barman': AppLocalizations.of(context)!.rolesWinningConditionsBarman,
    'informant': AppLocalizations.of(context)!.rolesWinningConditionsInformant,
    'sheriff': AppLocalizations.of(context)!.rolesWinningConditionsSheriff,
    'journalist': AppLocalizations.of(context)!.rolesWinningConditionsJournalist,
    'kamikaze': AppLocalizations.of(context)!.rolesWinningConditionsKamikaze,
  };

  bool get fromMafiaTeam => ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName);

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
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Container(
            margin: EdgeInsets.all(5.sp),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) 
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
                              ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) 
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
                      padding: EdgeInsets.only(bottom: 5.h, left: 2.w, right: 2.w),
                      child: Text(
                        rolesGeneralDescription[widget.roleName]!,
                        style: GoogleFonts.playfairDisplay(
                          fontStyle: FontStyle.italic,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w300,
                          color: fromMafiaTeam 
                            ? const Color(0xFF917A4D)
                            : const Color(0xFF807B75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
      
                    // //? PATTERN
                    // Padding(
                    //   padding: EdgeInsets.symmetric(vertical: 8.h),
                    //   child: Image.asset(
                    //     ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) 
                    //       ? 'assets/images/pattern-2.png'
                    //       : 'assets/images/pattern-1.png',
                    //     height: 20.h,
                    //     width: 92.w,
                    //   ),
                    // ),

                    //? MORE DETAILS
                    Container(
                      height: 370.h,
                      width: double.maxFinite,
                      margin: EdgeInsets.all(10.sp),
                      decoration: BoxDecoration(
                        gradient: ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName)? const RadialGradient(
                          center: Alignment.center,
                          radius: 0.8,
                          colors: [
                            Color(0xFF323232),
                            Color(0xFF000000),
                          ],
                          stops: [0.0, 1.0],
                        ) : null,
                        color: ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName)  ? null : const Color(0xFFFFF0D2),
                        border: Border.all(
                          color: ['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) 
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
                                  "assets/images/game-ornament-${['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
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
                                    "assets/images/game-ornament-${['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
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
                                    "assets/images/game-ornament-${['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
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
                                    "assets/images/game-ornament-${['mafia', 'kamikaze', 'barman', 'informant'].any((e) => e == widget.roleName) ? "night" : "day"}.png",
                                    width: ornamentSize,
                                    height: ornamentSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // TEXT: GamePlay Rules
                              Container(
                                margin: EdgeInsets.only(top: 15.h, bottom: 5.h),
                                child: Text(
                                  AppLocalizations.of(context)!.gameplayRules,
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
                                margin: EdgeInsets.only(left: 20.w, right: 20.w),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                          
                                    //? Objective
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          // TEXT:    Objective
                                          TextSpan(
                                            text: "${AppLocalizations.of(context)!.objective}: ",
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
                                              color: !fromMafiaTeam ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
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
                                            text: "${AppLocalizations.of(context)!.day}${exceptionRolesForSecondTitle.any((role) => role.toLowerCase() == widget.roleName) ? ' / ${AppLocalizations.of(context)!.skill}: ' : ': '}",
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
                                              color: !fromMafiaTeam ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                                              fontWeight: FontWeight.w400
                                            ),
                                          ),
                                        ]
                                      )
                                    ),
                                  
                                    SizedBox(height: 10.h),
                          
                                    //? Night Phase
                                    RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          // TEXT:    Night Phase
                                          TextSpan(
                                            text: "${AppLocalizations.of(context)!.night}${exceptionRolesForThirdTitle.any((role) => role.toLowerCase() == widget.roleName) ? ' / ${AppLocalizations.of(context)!.skill}: ' : ': '}",
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
                                              color: !fromMafiaTeam ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
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
                                            text: "${AppLocalizations.of(context)!.winningConditions}: ",
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
                                              color: !fromMafiaTeam ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
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