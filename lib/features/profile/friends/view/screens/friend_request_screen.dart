import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/generated/l10n.dart';
//import 'package:mafia_classic/blocs/player_bloc.dart';
//import 'package:mafia_classic/blocs/player_state.dart';
import 'package:mafia_classic/features/profile/friends/widgets/widgets.dart';
import 'package:mafia_classic/services/api_service.dart';

class FriendRequestScreen extends StatefulWidget {

  //final PlayerBloc bloc;

  const FriendRequestScreen({
    super.key,
    //required this.bloc
  });

  @override
  State<FriendRequestScreen> createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends State<FriendRequestScreen> {

  List<FriendRequest>? requests = [];

  @override
  void initState() {
    super.initState();
    _getRequests();
  }

  void _getRequests() async {
    requests = await GetIt.I<ApiService>().getRequests();
    setState(() {});
  }

  void _approveFriend(String nickname, bool approve) async {
    bool isApproved = await GetIt.I<ApiService>().approveFriend(nickname, approve);
    if (isApproved) {
      _getRequests();
    } else {
      // error
    }
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {
            final navigator = Navigator.of(context);
            navigator.pop();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).requests),
          ),
          body: ListView.builder(
            itemCount: requests == null ? 0 : requests?.length,
            itemBuilder: (context, index) {
              if (requests == null) return const SizedBox();
      
              return FriendRequestCard(
                request: requests![index],
                onApprove: _approveFriend
              );
            },
          )
        )
      ),
    );
  }
}
