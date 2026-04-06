//? Information Popup
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';

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
      case 'lastmafia':
        return 'mafia';
    }
    return '';
  }

  String get content {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return AppLocalizations.of(context)!.gameInformationPopupCured;
      case 'interviewed':
        return AppLocalizations.of(context)!.gameInformationPopupInterviewed;
      case 'intoxicated':
        return AppLocalizations.of(context)!.gameInformationPopupIntoxicated;
      case 'investigated':
        return AppLocalizations.of(context)!.gameInformationPopupInvestigated;
      case 'revealed':
        return AppLocalizations.of(context)!.gameInformationPopupRevealed;
      case 'protected':
        return AppLocalizations.of(context)!.gameInformationPopupProtected;
      case 'satisfied':
        return AppLocalizations.of(context)!.gameInformationPopupSatisfied;
      case 'lastmafia':
        return AppLocalizations.of(context)!.gameInformationPopupLastMafia;
    }
    return '';
  }

  String get title {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return AppLocalizations.of(context)!.gameInformationPopupTitleCured;
      case 'interviewed':
        return AppLocalizations.of(context)!.gameInformationPopupTitleInterviewed;
      case 'intoxicated':
        return AppLocalizations.of(context)!.gameInformationPopupTitleIntoxicated;
      case 'investigated':
        return AppLocalizations.of(context)!.gameInformationPopupTitleInvestigated;
      case 'revealed':
        return AppLocalizations.of(context)!.gameInformationPopupTitleRevealed;
      case 'protected':
        return AppLocalizations.of(context)!.gameInformationPopupTitleProtected;
      case 'satisfied':
        return AppLocalizations.of(context)!.gameInformationPopupTitleSatisfied;
      case 'lastmafia':
        return AppLocalizations.of(context)!.gameInformationPopupTitleLastMafia;
    }
    return '';
  }

  String get expiration {
    switch (widget.effect.toLowerCase()) {
      case 'cured':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationCured;
      case 'interviewed':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationInterviewed;
      case 'intoxicated':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationIntoxicated;
      case 'investigated':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationInvestigated;
      case 'revealed':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationRevealed;
      case 'protected':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationProtected;
      case 'satisfied':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationSatisfied;
      case 'lastmafia':
        return AppLocalizations.of(context)!.gameInformationPopupExpirationLastMafia;
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
                      'kamikaze',
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
                                    'kamikaze',
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
                    style: GoogleFonts.playfairDisplay(
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
                      fontFamily: 'CenturyGothic',
                      color:
                          [
                            'mafia',
                            'kamikaze',
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
                    style: GoogleFonts.playfairDisplay(
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
