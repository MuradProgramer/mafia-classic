import 'package:mafia_classic/models/models.dart';

abstract class AbstractPlayerRepository {  
  List<PlayerFull> getPlayers();

  List<Friend> getFriendList(int playerId);

  List<PlayerFull> getRequestsList(int playerId);
  
  void addPlayer(PlayerFull player);

  void sendRequest(int playerIdFrom, int playerIdTo);

  void acceptRequst(int playerId, int acceptedFriendId);

  void deleteFriend(int playerId, deleteFriendId);
}