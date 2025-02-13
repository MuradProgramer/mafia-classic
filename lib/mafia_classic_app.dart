import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:get_it/get_it.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';

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

class MafiaClassicApp extends StatelessWidget {
  
  const MafiaClassicApp({super.key});

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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        //locale: const Locale("ru"),
        supportedLocales: S.delegate.supportedLocales,
        title: 'Flutter Demo',
        theme: theme,
        routes: routes,
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

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    //////////////////////////
    //setup(widget.user);

    _widgetOptions = <Widget>[
      GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/profile', arguments: widget.user);
        },
        child: ProfileScreen(user: widget.user),
      ),
      GamesScreen(user: widget.user),
      const CreateGameScreen(),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),

      bottomNavigationBar: BottomNavigationBar(
        
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: S.of(context).profile,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.games),
            label: S.of(context).games,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add),
            label: S.of(context).create,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: S.of(context).settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Theme.of(context).primaryColorDark,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        
      ),
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