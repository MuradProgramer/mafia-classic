import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mafia_classic/generated/l10n.dart';

//import 'package:mafia_classic/blocs/player_bloc.dart';
// import 'package:mafia_classic/blocs/player_event.dart';
// import 'package:mafia_classic/blocs/player_state.dart';

//import 'package:mafia_classic/repositories/player_repository.dart';

import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/features/profile/friends/widgets/widgets.dart';
import 'package:mafia_classic/features/profile/friends/view/screens/screens.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  //int playerId = 3;

  List<Friendship>? friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  void _loadFriends() async {
    final updatedFriends = await GetIt.I<ApiService>().getFriends();
    setState(() {
      friends = updatedFriends;
    });
  }

  void _deleteFriend(String nickname) async {
    bool isDeleted = await GetIt.I<ApiService>().deleteFriend(nickname);
    if (isDeleted) {
      _loadFriends();
    } else {
      // error
    }
  }

  // final _playerBloc = PlayerBloc(
  //   playerRepository: GetIt.I<PlayerRepository>(),
  // );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-2.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white
          ),
          title: Text(S.of(context).friends.toUpperCase(), style: theme.textTheme.bodyMedium),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendSearchScreen(
      
                    )),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FriendRequestScreen(),
                  ),
                ).then((result) {
                  if (result == true) {
                    _loadFriends();
                  }
                });
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: friends == null ? 0 : friends?.length,
          itemBuilder: (context, index) {
            if (friends == null) {
              return const SizedBox();
            }
            final friend = friends![index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(friend: friends![index]),
                  ),
                );
              },
              child: FriendCard(
                friend: friend, 
                onDelete: _deleteFriend,
              )
            );
          }
        )
        
        
        // BlocBuilder(
        //   bloc: _playerBloc,
        //   builder: (context, state) {
        //     if(state is PlayerFriendsLoadSuccess) {
        //       return ListView.builder(
        //         itemCount: state.friends.length,
        //         itemBuilder: (context, index) {
        //           return GestureDetector(
        //             onTap: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(
        //                   builder: (context) => ChatScreen(friend: state.friends[index]),
        //                 ),
        //               );
        //             },
        //             child: FriendCard(friend: state.friends[index])
        //           );
        //         }
        //       );
        //     }
        //     if(state is PlayerFriendsLoadFailure) {
        //       return const Center(
        //         child: Text(
        //           'something went wrong...', 
        //           style: TextStyle(
        //             fontSize: 18,
        //             color: Colors.white
        //           )
        //         ),
        //       );
        //     }
        //     return const Center(child: CircularProgressIndicator());
        //   }        
        // )
      
      ),
    );
  }
}
