//? Player Dead
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';

class GamePlayerDeadPopup extends StatefulWidget {
  const GamePlayerDeadPopup({super.key});

  @override
  State<GamePlayerDeadPopup> createState() => _GamePlayerDeadPopupState();
}

class _GamePlayerDeadPopupState extends State<GamePlayerDeadPopup> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.55,
          padding: EdgeInsets.all(5.sp),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage(
                'assets/images/background_youaredead_popup.png',
              ),
              fit: BoxFit.cover,
              alignment: Alignment(0, -0.6),
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1.5.w
              ),
              borderRadius: BorderRadius.circular(16.r)
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
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
                                  PopupManager().close('playerDeadPopup');
                                },
                                child: Image.asset(
                                  'assets/images/close-white-icon.png',
                                  height: 30.h,
                                  width: 23.w,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                
                    // TEXT:    The shadows have consumed your light.
                    Padding(
                      padding: EdgeInsets.only(top: 25.h, bottom: 10.h, left: 20.w, right: 20.w),
                      child: Text(
                        textAlign: TextAlign.center,
                        'The shadows have consumed your light.',
                        style: TextStyle(
                          height: 0,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF652123),
                        ),
                      ),
                    ),
            
                  ],
                ),
            
                //? TEXT:    Enter the password
                Padding(
                  padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
                  child: Text(
                    'You are dead',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFFFFFFFF),
                      fontFamily: 'CenturyGothic',
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
