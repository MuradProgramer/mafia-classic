import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/profile/roles/data/data.dart';
import 'package:mafia_classic/features/profile/roles/widgets/widgets.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';

class RolesScreen extends StatefulWidget {
  const RolesScreen({super.key});

  @override
  State<RolesScreen> createState() => _RolesScreenState();
}

class _RolesScreenState extends State<RolesScreen> {
  int selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = getRoles(context);

    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    final buttonHeight = deviceHeight * 0.045;
    final buttonWidth = deviceWidth * 0.27;
    final buttonTextFontSize = deviceWidth * 0.057;

    //"assets/images/roles-${selectedTabIndex == 0 ? "civilians" : "mafias"}-background.png"

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/roles-${selectedTabIndex == 0 ? "civilians" : "mafias"}-background.png"), fit: BoxFit.cover),
      ),
      child: Scaffold(
      
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
                      width: 30.w,
                      height: 30.h,
                    ),
                  ),
                
                  const SizedBox()
                ],
              ),
              
              //? TABS CHANGER
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // BUTTON:    Civilians
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: Colors.white,
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
                              backgroundColor: selectedTabIndex == 0 ? const Color(0xFFFFB000) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            
                            child: Text(
                              AppLocalizations.of(context)!.civilians,
                              style: TextStyle(
                                fontSize: buttonTextFontSize,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                
                    SizedBox(width: 5.w),
                
                    Image.asset(
                      'assets/images/roles-line.png',
                      width: deviceWidth * 0.32,
                      height: deviceHeight * 0.018,
                    ),
                
                    SizedBox(width: 5.w),
                
                    // BUTTON:    Mafias
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: Colors.white,
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
                              backgroundColor: selectedTabIndex == 1 ? const Color(0xFFFFB000) : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                side: const BorderSide(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                            ),
                            
                            child: Text(
                              AppLocalizations.of(context)!.mafias,
                              style: TextStyle(
                                fontSize: buttonTextFontSize,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 20.h),
              
              // Tab content
              Expanded(
                child: selectedTabIndex == 0 ? const CiviliansTab() : const MafiasTab(),
              ),
              SizedBox(height: deviceHeight * 0.15),
            ],
          ),
        ),
      ),
    );
  }
}

// NOTE: Civilians Widget
class CiviliansTab extends StatefulWidget {
  const CiviliansTab({super.key});

  @override
  State<CiviliansTab> createState() => _CiviliansTabState();
}

class _CiviliansTabState extends State<CiviliansTab> {
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double cardHeight = deviceHeight * 0.167; // Adjusted height for the cards
    final double cardWidth = deviceWidth * 0.276; // Adjusted width for the cards
    
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleName: 'beauty', width: cardWidth, height: cardHeight, isMini: false),
              SizedBox(height: 10.h),
              RoleCard(roleName: 'journalist', width: cardWidth, height: cardHeight, isMini: false),
            ],
          ),
          SizedBox(width: 10.h),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleName: 'civilian', width: cardWidth, height: cardHeight, isMini: false),
              SizedBox(height: 10.h),
              RoleCard(roleName: 'sheriff', width: cardWidth, height: cardHeight, isMini: false),
              SizedBox(height: 10.h),
              RoleCard(roleName: 'spy', width: cardWidth, height: cardHeight, isMini: false),
            ],
          ),
          SizedBox(width: 10.h),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleName: 'doctor', width: cardWidth, height: cardHeight, isMini: false),
              SizedBox(height: 10.h),
              RoleCard(roleName: 'bodyguard', width: cardWidth, height: cardHeight, isMini: false),
            ],
          ),
        ],
      ),
    );
  }
}


// NOTE: Mafias Widget
class MafiasTab extends StatefulWidget {
  const MafiasTab({super.key});

  @override
  State<MafiasTab> createState() => _MafiasTabState();
}

class _MafiasTabState extends State<MafiasTab> {
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double cardHeight = deviceHeight * 0.167; // Adjusted height for the cards
    final double cardWidth = deviceWidth * 0.276; // Adjusted width for the cards

    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleName: 'terrorist', width: cardWidth, height: cardHeight, isMini: false),
              SizedBox(height: 10.h),
              RoleCard(roleName: 'barman', width: cardWidth, height: cardHeight, isMini: false),
            ],
          ),
          SizedBox(width: 10.h),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleName: 'mafia', width: cardWidth, height: cardHeight, isMini: false),
              SizedBox(height: 10.h),
              RoleCard(roleName: 'informant', width: cardWidth, height: cardHeight, isMini: false),
            ],
          ),
        ],
      ),
    );
  }
}