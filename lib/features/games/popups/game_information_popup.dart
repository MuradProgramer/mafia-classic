//? Information Popup
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';

class InformationPopup extends StatefulWidget {
  final String effect;

  const InformationPopup({super.key, required this.effect});

  @override
  State<InformationPopup> createState() => _InformationPopupState();
}

class _InformationPopupState extends State<InformationPopup> {
  String get roleName {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return 'doctor';
      case 'interviewed':
        return 'journalist';
      case 'intoxicated':
        return 'barman';
      case 'investigated':
        return 'sheriff';
      case 'revealed':
        return 'informant';
      case 'protected':
        return 'bodyguard';
      case 'satisfied':
        return 'beauty';
    }
    return '';
  }

  String get content {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return 'You’re in “safe” hands, the mafia can’t touch you now';
      case 'interviewed':
        return 'Congrats — you’re now part of their “big investigation,” whether you like it or not. And, as always, everyone’s already gossiping about whether you’re on the same side as the other interviewee';
      case 'intoxicated':
        return 'Under the effect: you cannot vote, use abilities, and your messages appear distorted';
      case 'investigated':
        return 'The sheriff entered your details into the system — now they know who you are';
      case 'revealed':
        return 'Now your life depends on how important your role is';
      case 'protected':
        return 'While the protection is active, you’re safe from harm.';
      case 'satisfied':
        return 'You’ve succumbed to the temptation and cannot vote or use abilities.';
    }
    return '';
  }

  String get title {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return 'The doctor has cured you';
      case 'interviewed':
        return 'The journalist interviewed you';
      case 'intoxicated':
        return 'The bartender got you drunk';
      case 'investigated':
        return 'The sheriff investigated you.';
      case 'revealed':
        return 'The informant revealed your role.';
      case 'protected':
        return 'The bodyguard has protected you.';
      case 'satisfied':
        return 'The beauty has enchanted you.';
    }
    return '';
  }

  String get expiration {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return 'The effect will wear off in one day';
      case 'interviewed':
        return 'The effect lasts until the end of the game';
      case 'intoxicated':
        return 'The effect will wear off in one day';
      case 'investigated':
        return 'The effect lasts until the end of the game';
      case 'revealed':
        return 'The effect lasts until the end of the game';
      case 'protected':
        return 'The effect will wear off in one day';
      case 'satisfied':
        return 'The effect will wear off in one day';
    }
    return '';
  }

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
            image: DecorationImage(
              image: AssetImage(
                'assets/images/role-card-background-$roleName.png',
              ),
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.6),
            ),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Container(
            margin: EdgeInsets.all(5.sp),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color:
                    [
                      'mafia',
                      'terrorist',
                      'barman',
                      'informant',
                    ].any((e) => e == roleName)
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
                              PopupManager().close('informationPopup');
                            },
                            child: Image.asset(
                              [
                                    'mafia',
                                    'terrorist',
                                    'barman',
                                    'informant',
                                  ].any((e) => e == roleName)
                                  ? 'assets/images/close-white-icon.png'
                                  : 'assets/images/icon-close-grey.png',
                              height: 30.h,
                              width: 23.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(),

                //? TITLE
                Padding(
                  padding: EdgeInsets.only(top: 80.h),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 23.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB000),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                //? DESCRIPTION
                Padding(
                  padding: EdgeInsets.only(right: 5.w, left: 5.w),
                  child: Text(
                    content,
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w300,
                      color:
                          [
                            'mafia',
                            'terrorist',
                            'barman',
                            'informant',
                          ].any((e) => e == roleName)
                          ? const Color(0xFF917A4D)
                          : const Color(0xFF807B75),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                //? EXPIRATION
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h, left: 5.w, right: 5.w),
                  child: Text(
                    expiration,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: const Color(0xFFFFB000),
                    ),
                    textAlign: TextAlign.center,
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
