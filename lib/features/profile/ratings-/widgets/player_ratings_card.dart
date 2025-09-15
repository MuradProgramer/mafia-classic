import 'package:flutter/material.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/models/models.dart';

class UserRatingCard extends StatefulWidget {
  final Player player;
  final int playerIndex;
  final String sortBy;

  const UserRatingCard({
    super.key, 
    required this.player, 
    required this.playerIndex, 
    required this.sortBy
  });

  @override
  State<UserRatingCard> createState() => _UserRatingCardState();
}

class _UserRatingCardState extends State<UserRatingCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Theme.of(context).primaryColorDark,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/avatar.jpg'),
        ),
        title: Text(
          widget.player.username, 
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500
          ),
        ),
        subtitle: Text(
          widget.sortBy == 'Experience'
              ? '${S.of(context).experience}: ${widget.player.experience}'
              : widget.sortBy == 'Games Played'
                  ? '${S.of(context).gamesPlayed}: ${widget.player.gamesPlayed}'
                  : '${S.of(context).gamesWon}: ${widget.player.gamesWon}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300
          )
        ),
        trailing: Text('#${widget.playerIndex + 1}', style: const TextStyle(color: Colors.white),),
      ),
    );
  }
}