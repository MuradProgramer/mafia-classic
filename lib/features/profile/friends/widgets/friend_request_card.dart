import 'package:flutter/material.dart';
import 'package:mafia_classic/models/models.dart';

class FriendRequestCard extends StatelessWidget {
  final FriendRequest request;
  final Function(String, bool) onApprove;

  const FriendRequestCard({
    super.key,
    required this.request,
    required this.onApprove
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(//'someone'
          request.nickname
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                onApprove(request.nickname, true); // accept request
              },
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                onApprove(request.nickname, false); // decline request
              },
            ),
          ],
        ),
      ),
    );
  }
}