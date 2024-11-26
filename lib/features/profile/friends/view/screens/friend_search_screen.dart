import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';

import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/services/api_service.dart';

class FriendSearchScreen extends StatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool requestSent = false;
  List<FindFriend>? searchResults = [];

  @override
  void initState() {
    super.initState();
  }

  void _searchUsers() async {
    searchResults = await GetIt.I<ApiService>().findFriend(_searchController.text);
    setState(() {});
  }

  void _sendRequest(String nickname) async {
    await GetIt.I<ApiService>().sendRequest(nickname);
    setState(() {});
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white
          ),
          title: Text(S.of(context).searchFriends.toUpperCase(), style: theme.textTheme.bodyMedium),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Введите имя...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchUsers,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
            Expanded(
              child: searchResults == null 
              ? 
              const Center(
                child: Text(
                  'No users found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15
                  ),
                )
              )
              :
              ListView.builder(
                itemCount: searchResults!.length,
                itemBuilder: (context, index) {
                  FindFriend user = searchResults![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(user.avatarUrl[0]),
                      ),
                      title: Text(user.nickname),
                      trailing: user.friendshipStatus == 'Pending'
                          ? const Text(
                              "Запрос отправлен",
                              style: TextStyle(color: Colors.green),
                            )
                          : user.friendshipStatus == 'None'
                          ? IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () {
                                _sendRequest(user.nickname);
                                _searchUsers();
                              },
                              color: Colors.blueAccent,
                            )
                          : const SizedBox()
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // body: Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Column(
        //     children: [
        //       TextField(
        //         controller: _searchController,
        //         decoration: InputDecoration(
        //           hintText: S.of(context).enterUsername,
        //           suffixIcon: IconButton(
        //             icon: const Icon(Icons.search, color: Colors.white),
        //             onPressed: _searchFriend,
        //           ),
        //           hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        //         ),
        //         style: const TextStyle(color: Colors.white)
        //       ),
        //       const SizedBox(height: 20),
        //       if (searchResult.isNotEmpty) ...[
        //         Text(searchResult),
        //         const SizedBox(height: 10),
        //         if (!requestSent)
        //           ElevatedButton(
        //             onPressed: () {
        //               setState(() {
        //                 requestSent = true;
        //                 // send request logic
        //               });
        //             },
        //             child: Text(S.of(context).sendRequest),
        //           )
        //         else
        //           Text(S.of(context).requestAlredySent),
        //       ]
        //     ],
        //   ),
        // ),
      ),
    );
  }  
}
