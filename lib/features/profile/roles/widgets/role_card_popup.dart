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
                        'You are the Sheriff, the town\'s investigator\ndedicated to rooting out the Mafia. Use\n your investigative skills wisely to expose\n the criminals before it\'s too late.',
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