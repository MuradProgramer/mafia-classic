import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/l10n/l10n.dart';
import 'package:mafia_classic/streams/general_stream.dart';

import 'package:mafia_classic/theme/theme.dart';
import 'package:mafia_classic/router/router.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/features/features.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/repositories/repositories.dart';

import 'blocs/sign_in/sign_in_bloc.dart';
import 'blocs/sign_up/sign_up_bloc.dart';

void buildApiService(accessToken, refreshToken, expirationDate) {
  GetIt.I.registerSingleton(ApiService(accessToken, accessToken, accessToken));
}

class MafiaClassicApp extends StatefulWidget {
  const MafiaClassicApp({super.key});

  static final GlobalKey<_MafiaClassicAppState> globalKey =
      GlobalKey<_MafiaClassicAppState>();

  @override
  State<MafiaClassicApp> createState() => _MafiaClassicAppState();
}

class _MafiaClassicAppState extends State<MafiaClassicApp> {

  @override
  void initState() {
    GeneralStreams.languageStream.add(const Locale("en"));
    super.initState();
  }

  @override
  void dispose() {
    GeneralStreams.languageStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignInBloc>(
          create: (context) => SignInBloc(authRepository: GetIt.I<AuthRepository>()),
        ),
        BlocProvider<SignUpBloc>(
          create: (context) => SignUpBloc(authRepository: GetIt.I<AuthRepository>()),
        ),
      ],
      child: StreamBuilder<Locale>(
        stream: GeneralStreams.languageStream.stream,
        builder: (context, snapshot) {
          return MaterialApp(
            key: MafiaClassicApp.globalKey,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
            locale: snapshot.data,
            supportedLocales: L10n.locals,
            //title: 'Flutter Demo',
            theme: theme,
            routes: routes,
          );
        }
      )
    );
  }
}

class HomeScreen extends StatefulWidget {

  final User user;
  
  const HomeScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  //late List<Widget> _widgetOptions;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (_) => _getInitialPageForIndex(index),
          );
        },
      ),
    );
  }

  Widget _getInitialPageForIndex(int index) {
    switch (index) {
      case 0:
        return ProfileScreen(user: widget.user);
      case 1:
        return GamesScreen(user: widget.user);
      case 2:
        return const CreateGameScreen();
      case 3:
        return const FriendsScreen();
      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();

    //////////////////////////
    //setup(widget.user);

    // _widgetOptions = <Widget>[
    //   ProfileScreen(user: widget.user),
    //   GamesScreen(user: widget.user),
    //   const CreateGameScreen(),
    //   const SettingsScreen(),
    // ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem(String assetPath, int index, String text) {
    //final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              scale: 2.8
            ),
            Text(
              text,
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 16.sp
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,

      body: Stack(
        children: List.generate(
          4,
          (index) => _buildOffstageNavigator(index),
        ),
      ),

      bottomNavigationBar: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: BottomAppBar(
          height: 100.h,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('assets/images/icon-profile.png', 0, S.of(context).profile),
              _buildNavItem('assets/images/icon-games.png', 1, S.of(context).games),
              _buildNavItem('assets/images/icon-create.png', 2, S.of(context).create),
              _buildNavItem('assets/images/icon-friends.png', 3, S.of(context).friends),
            ],
          ),
        ),
      ),

      
      // bottomNavigationBar: SizedBox(
      //   height: 90.h,
      //   child: BottomNavigationBar(
      //     items: <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: Image.asset(
      //           'assets/images/temp-profile-icon.png',
      //           scale: 3,
      //         ),
      //         label: ''
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Image.asset(
      //           'assets/images/temp-games-icon.png',
      //           scale: 3,
      //         ),
      //         label: ''
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Image.asset(
      //           'assets/images/temp-create-icon.png',
      //           scale: 3,
      //         ),
      //         label: ''
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Image.asset(
      //           'assets/images/temp-settings-icon.png',
      //           scale: 3,
      //         ),
      //         label: ''
      //       ),
      //     ],
      //     currentIndex: _selectedIndex,
      //     onTap: _onItemTapped,
      //     backgroundColor: Colors.black,
      //     selectedItemColor: Colors.white,
      //     unselectedItemColor: Colors.grey,
      //     type: BottomNavigationBarType.fixed,
      //   ),
      // ),
      
    
    );
  }
}



class CreatePage extends StatelessWidget {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-2.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: const Center(
        child: Text('Create Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Games Page', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    );
  }
}