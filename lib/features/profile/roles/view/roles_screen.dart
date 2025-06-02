import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mafia_classic/features/profile/roles/data/data.dart';
import 'package:mafia_classic/features/profile/roles/widgets/widgets.dart';
import 'package:mafia_classic/generated/l10n.dart';

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

    return Stack(
      children: [
          
          Positioned.fill(
            child: Image.asset(
              "assets/images/roles-${selectedTabIndex == 0 ? "civilians" : "mafias"}-background.png",
              fit: BoxFit.cover,
            ),
          ),

          Scaffold(
            resizeToAvoidBottomInset: false,

            // appBar: AppBar(
            //   iconTheme: const IconThemeData(
            //     color: Colors.white
            //   ),
            //   backgroundColor: Colors.transparent,
            //   //title: Text(S.of(context).roles.toUpperCase(), style: theme.textTheme.bodyMedium)
            // ),
            // body: ListView.builder(
            //   itemCount: roles.length,
            //   itemBuilder: (context, index) {
            //     return RoleCard(role: roles[index]);
            //   }
            // )

            body: Column(
              children: [
                SizedBox(height: deviceHeight * 0.075),

                Row(
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
                              'Civilians', // NOTE:    Translation L10
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

                    const SizedBox(width: 5),

                    Image.asset(
                      'assets/images/roles-line.png',
                      width: deviceWidth * 0.32,
                      height: deviceHeight * 0.018,
                    ),

                    const SizedBox(width: 5),

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
                              'Mafias', // NOTE:    Translation L10
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
                const SizedBox(height: 20),

                // Tab content
                Expanded(
                  child: selectedTabIndex == 0 ? const CiviliansTab() : const MafiasTab(),
                ),
                SizedBox(height: deviceHeight * 0.15),
              ],
            ),
          ),
      ]
    );
  }

  Widget _buildFirstTab() {
    return const Center(
      child: Text('This is Tab 1', style: TextStyle(fontSize: 24))
    );
  }

  Widget _buildSecondTab() {
    return const Center(
      child: Text('This is Tab 2', style: TextStyle(fontSize: 24))
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
    return const Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
              SizedBox(height: 10),
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
            ],
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
              SizedBox(height: 10),
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
              SizedBox(height: 10),
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
            ],
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
              SizedBox(height: 10),
              RoleCard(roleImagePath: 'assets/images/resident-icon.png'),
            ],
          ),
        ],
      ),
    );
  }
}

class RoleCard extends StatefulWidget {
  final String roleImagePath;

  const RoleCard({super.key, required this.roleImagePath});

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  @override
  Widget build(BuildContext context) {

    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      
      child: Image.asset(
        width: deviceWidth * 0.276,
        height: deviceHeight * 0.167,
        widget.roleImagePath,
        fit: BoxFit.scaleDown,
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
    return const Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleImagePath: 'assets/images/roles-mafia-icon.png'),
              SizedBox(height: 10),
              RoleCard(roleImagePath: 'assets/images/roles-mafia-icon.png'),
            ],
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RoleCard(roleImagePath: 'assets/images/roles-mafia-icon.png'),
              SizedBox(height: 10),
              RoleCard(roleImagePath: 'assets/images/roles-mafia-icon.png'),
            ],
          ),
        ],
      ),
    );
  }
}