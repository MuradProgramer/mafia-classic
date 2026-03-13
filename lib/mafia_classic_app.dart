import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';
import 'package:mafia_classic/features/profile/friends/models/friendship.dart';
import 'package:mafia_classic/features/widgets/player_info_popup.dart';
import 'package:mafia_classic/features/widgets/validation_popup.dart';
import 'package:mafia_classic/global_data.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/l10n/l10n.dart';
import 'package:mafia_classic/services/cache/general_cache_service.dart';
import 'package:mafia_classic/services/locale/locale_service.dart';
import 'package:mafia_classic/services/shared_preferences/extensions/language_prefs.dart';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';
import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';
import 'package:mafia_classic/services/tcp/event_router_service.dart';
import 'package:mafia_classic/services/tcp/general_service.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';
import 'package:mafia_classic/streams/general_stream.dart';

import 'package:mafia_classic/theme/theme.dart';
import 'package:mafia_classic/router/router.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/features/features.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/repositories/repositories.dart';
import 'package:mafia_classic/utils/popup_utils.dart';
import 'package:mafia_classic/utils/snackbar.dart';

import 'blocs/sign_in/sign_in_bloc.dart';
import 'blocs/sign_up/sign_up_bloc.dart';

List<String> whoInvitedMe = [];
int isInFriendIdChatGlobal = -1;

void buildApiService(accessToken, refreshToken, expirationDate) {
  GetIt.I.registerSingleton(ApiService(accessToken, accessToken, accessToken));
}

final RouteObserver<PageRoute> appRouteObserver = RouteObserver<PageRoute>();

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MafiaClassicApp extends StatefulWidget {
  final LocaleService localeService;
  const MafiaClassicApp({super.key, required this.localeService});

  static final GlobalKey<_MafiaClassicAppState> globalKey =
      GlobalKey<_MafiaClassicAppState>();

  @override
  State<MafiaClassicApp> createState() => _MafiaClassicAppState();
}

class _MafiaClassicAppState extends State<MafiaClassicApp> with WidgetsBindingObserver {

  late final StreamSubscription _globalSub;

  void setLocale() async {
    
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    String languageCode =
      SharedPrefsService().getSavedLanguageCode() ??
      PlatformDispatcher.instance.locale.languageCode;

    const supported = ['en', 'ru', 'az', 'tr'];

    if (!supported.contains(languageCode)) {
      languageCode = 'en';
    }

    final locale = L10n.locals.firstWhere(
      (l) => l.languageCode == languageCode,
    );

    GeneralStreams.languageStream.add(const Locale('ru'));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLifecycle.instance.markReady();
    });

    _globalSub = EventRouterService().globalStream.listen((entry) async {
      final event = entry.key;
      final payload = entry.value;

      //? Friendship Invite
      if (event == ServerEvent.friendshipRoomInvite) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final nav = rootNavigatorKey.currentState;
        if (nav == null) return;

        if (whoInvitedMe.any((key) => key == data['roomId'])) {
          return;
        }

        whoInvitedMe.add(data['roomId']);

        showBouncingPopupFromLeft<bool>(
          nav.overlay!.context, 
          AcceptRoomInvitePopup(
            friendNickname: data['nickname'] ?? "",
            gameTitle: data['roomTitle'] ?? "",
          )
        ).then((status) async {
          if (status == null) return;

          if (status) {
            await GetIt.I<ApiService>().acceptInviteToRoom(data['roomId']);
          }

          whoInvitedMe.remove(data['roomId']);
        });
      }

      if (event == ServerEvent.friendshipNewFriend) {
        try {
          final Map<String, dynamic> jsonData = json.decode(payload)['friend'];

          final newFriend = Friendship.fromJson(jsonData);

          List<Friendship>? currentFriends = GeneralCacheService().loadList<Friendship>(
            "all_friends_list",
            (json) => Friendship.fromJson(json as Map<String, dynamic>),
          );

          currentFriends ??= [];
          currentFriends.add(newFriend);

          await GeneralCacheService().save<List<Friendship>?>(
            "all_friends_list",
            currentFriends,
          );

          EventBus().fire(NewFriendAddedEvent(newFriend));

          TopSnackBarManager.show(
            {
              "nickname": newFriend.nickname,
              "avatarUrl": newFriend.avatarUrl,
            }, 4);
        } on Exception catch (e) {
          log('EXCEPTION IN:     friendshipNewFriend: ${e.toString()}');
        }
      }

      if (event == ServerEvent.friendshipRequestFriendship) {
        Map<String, dynamic> data = json.decode(payload);
        EventBus().fire(FriendRequestReceivedEvent(data));
        TopSnackBarManager.show({
            "nickname": data['nickname'],
            "avatarUrl": data['avatarUrl'],
          }, 3
        );
      }

      if (event == ServerEvent.friendshipCancelRequest) {
        final int friendId = json.decode(payload)['playerId'] as int;
        EventBus().fire(CancelFriendRequest(friendId));
      }

      if (event == ServerEvent.friendshipFriendNewMessage) {
        try {
          final Map<String, dynamic> decodedPayload = json.decode(payload);
          final newMessage = Message.fromJson(decodedPayload['message']);
          final int friendId = json.decode(payload)['id'] as int;
          final String friendNickname = json.decode(payload)['nickname'];
          final String avatarUrl = json.decode(payload)['avatarUrl'];

          if (isInFriendIdChatGlobal != friendId) {
            TopSnackBarManager.show({
              "content": newMessage.text,
              "nickname": friendNickname, 
              "avatarUrl": avatarUrl
            }, 2);
          }
          
          EventBus().fire(FriendNewMessageEvent(newMessage, friendId));
          
        } on Exception catch (e) {
          log('EXCEPTION IN:     friendshipFriendNewMessage: ${e.toString()}');
        }
      }

      if (event == ServerEvent.clientError) {
        //print("EVENT TYPE: CLIENT ERROR PAYLOAD: $payload");
        switch (json.decode(payload)['errorType'] as int) {
          case 1007:
            showExceptionPopup("Password is incorrect, try another one!");
            break;
          case 403:
            showExceptionPopup("You don't have permission to perform this action.");
            break;
          case 404:
            showExceptionPopup("Requested resource was not found.");
            break;
          case 500:
            showExceptionPopup("Server error occurred. Please, try again later.");
            break;
          default:
            showExceptionPopup("An unexpected error occurred. Please, try again.");
            break;
        }
        //showExceptionPopup("Password is incorrect, try another one!");
      }
    });

    super.initState();
  }

  void showExceptionPopup(String content) {
    showBouncingPopupFromTop(
      ValidationPopup(
        height: 170.h, 
        width: 270.w, 
        popupType: 2, 
        statusCode: 111, 
        content: content
      )
    );
  }


  // void _showInviteDialog(String? sender, String? room) {
  //   final nav = rootNavigatorKey.currentState;
  //   if (nav == null) return;
  //   showDialog(
  //     context: nav.overlay!.context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('🎉 Invitation'),
  //       content: Text('${sender ?? "Friend"} invited you to "${room ?? "room"}"'),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Decline')),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //             // Навигация в комнату, отправка join-команды и т.п.
  //           },
  //           child: const Text('Join'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void dispose() {
    GeneralStreams.languageStream.close();
    WidgetsBinding.instance.removeObserver(this);
    _globalSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);


    if (state == AppLifecycleState.paused) {
      print("App is paused or going to the background.");
      
    } else if (state == AppLifecycleState.detached) {
      print("App engine detached. Clearing all cache...");
      TcpClientService().disconnect();
      //GeneralCacheService().clearCacheExceptLanguage();
    } else if (state == AppLifecycleState.hidden) {
      print("App is hidden.");
    } else if (state == AppLifecycleState.resumed) {
        _handleAppResumed();
    }
  }

  void initGeneralServiceForAuthorizedUser(User authorized) async {
    await GeneralService(authorized).init();
  }

  Future<void> _reconnect() async {
    User alreadyUser = User(
      id: SharedPrefsService.getUserId() ?? -1, 
      email: SharedPrefsService.getUserEmail() ?? '', 
      nickname: SharedPrefsService.getUserNickname() ?? '', 
      avatarUrl: SharedPrefsService.getUserAvatarUrl() ?? '', 
      accessToken: SharedPrefsService.getAccessToken() ?? '', 
      refreshToken: SharedPrefsService.getRefreshToken() ?? '', 
      expirationDate: SharedPrefsService.getAccessTokenExpiryUtc()!
    );
    setup(alreadyUser);
    initGeneralServiceForAuthorizedUser(alreadyUser);
    await TcpClientService().connect(serverIP, serverPort, alreadyUser);
  }

  void _handleAppResumed() {
    // Check if the service still has an active socket
    if (!TcpClientService().isConnected) {
      log('🔄 Socket was lost in background. Reconnecting...');
      _reconnect();
    } else {
      // Sometimes the socket is 'dead' but hasn't realized it yet.
      // Sending a ping forces the OS to realize the pipe is broken.
      TcpClientService().sendMessage(ClientCommand.ping.value, "wakeup");
    }
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
      child: AnimatedBuilder(
        animation: widget.localeService,
        builder: (context, snapshot) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: MaterialApp(
              navigatorKey: rootNavigatorKey,
              navigatorObservers: [appRouteObserver],
              key: MafiaClassicApp.globalKey,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
              ],
              locale: widget.localeService.locale,
              supportedLocales: L10n.locals,
              //title: 'Flutter Demo',
              theme: theme,
              routes: routes,
            ),
          );
        }
      )
    );
  }
}

late User authorizedUser;

class HomeScreen extends StatefulWidget {

  final User user;
  
  const HomeScreen({super.key, required this.user});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;
  final ValueNotifier<int> tabIndexNotifier = ValueNotifier(2);
  //late List<Widget> _widgetOptions;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
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
        return MyProfileScreen(
          id: widget.user.id,
          height: 700.h, 
          width: 390.w, 
          nickname: widget.user.nickname,
          tabIndexNotifier: tabIndexNotifier, tabIndex: 0
        );
      case 1:
        //TcpClientService().sendMessage(2, "");
        return GamesScreen(user: widget.user, tabIndexNotifier: tabIndexNotifier, tabIndex: 1);
      case 2:
        return ProfileScreen(user: widget.user);
      case 3:
        return CreateGameScreen(tabIndexNotifier: tabIndexNotifier, tabIndex: 3);
      case 4:
        return const FriendsScreen();
      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();

    authorizedUser = widget.user;

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
      tabIndexNotifier.value = index;
    });
    if (_navigatorKeys[index].currentState == null) return;
      _navigatorKeys[index].currentState!.popUntil((route) => route.isFirst);
  }

  Widget _buildNavItem(String assetPath, int index, String text) {
    final isSelected = _selectedIndex == index;
    return Opacity(
      opacity: isSelected ? 1 : 0.55,
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(5.sp),
                //   border: Border.all(color: isSelected ?  const Color(0xFFFFB000) : Colors.transparent, width: 1.5.sp)
                // ),
                height: 45.h,
                width: 45.w,
                child: Image.asset(
                  assetPath,
                ),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,

      body: Stack(
        children: List.generate(
          5,
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
              _buildNavItem('assets/images/icon-home.png', 2, "Home"),
              _buildNavItem('assets/images/icon-create.png', 3, S.of(context).create),
              _buildNavItem('assets/images/icon-friends.png', 4, S.of(context).friends),
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

class AppLifecycle {
  static final AppLifecycle instance = AppLifecycle._();
  AppLifecycle._();

  final Completer<void> _readyCompleter = Completer<void>();

  Future<void> get ready => _readyCompleter.future;

  void markReady() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
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