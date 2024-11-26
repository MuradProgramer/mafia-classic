import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/generated/l10n.dart';

class FriendCard extends StatelessWidget {
  final Friendship friend;
  final Function(String) onDelete;

  const FriendCard({super.key, required this.friend, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 8, right: 8, top: 8),
      color: const Color.fromARGB(255, 6, 0, 63),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              //backgroundImage: AssetImage(friend.avatarUrl),
              backgroundImage: NetworkImage(friend.avatarUrl),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: CircleAvatar(
                radius: 5,
                backgroundColor: friend.isOnline ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
        title: Text(
          friend.nickname,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500
          )
        ),
        subtitle: Text(
          friend.isOnline ? S.of(context).online : DateFormat('yyyy.MM.dd HH:mm').format(friend.lastSeen),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300
          )
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.white,),
          onPressed: () => onDelete(friend.nickname)  // DELETE FRIEND
        ),
      ),
    );
  }
}
