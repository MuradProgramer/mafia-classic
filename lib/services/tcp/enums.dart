enum ServerEvent {
  pong(0),

  clientError(300),
  clientDuplicateLogin(301),
  clientAuthorizationSuccess(302),
  
  lobbyRooms(1100),
  lobbyRoomCreated(1101),
  lobbyPlayerEnteredRoom(1102),
  lobbyPlayerExitedRoom(1103),
  lobbyGameStarted(1104),
  lobbyPlayerEliminated(1105),
  lobbyGameOver(1106),
  lobbyRoomClosed(1107),

  roomStateData(1300),
  roomPlayerJoined(1301),
  roomPlayerLeft(1302),
  roomTimerUpdate(1303),
  roomNewMessage(1304),

  gameInitialStateData(1500),
  gameStateData(1501),
  gamePhaseChanged(1502),
  gameTimerUpdate(1503),
  gameNewMessage(1504),
  gameVoteRegistered(1505),
  gamePlayerEliminated(1506),
  gameTerroristExplosion(1507),
  gameJournalistInterview(1508),
  gameEffectApplied(1509),
  gameEffectRemoved(1510),
  gamePersonalFeedback(1511),
  gameNightActionPrompt(1512),
  gameOver(1513),

  friendshipFriends(2000), //
  friendshipFriendOnline(2001), //?
  friendshipFriendOffline(2002), //?
  friendshipRoomInvite(2003),
  friendshipFriendJoinedRoom(2004),
  friendshipFriendLeftRoom(2005),
  friendshipNewFriend(2006), //
  friendshipRequestFriendship(2007), //
  friendshipCancelRequest(2008),
  friendshipRequestDeclined(2009), //
  friendshipDeleteFriendship(2010), //
  friendshipFriendNewMessage(2011),
  friendshipFriendMessagesReaded(2012),
  friendshipFriendMessagesDelivered(2013),
  //friendInvitation(5000),

  errorEvent(-1);

  final int value;
  const ServerEvent(this.value);
}

enum ClientCommand {
  ping(0),

  authorize(300),

  getRooms(1100),
  createRoom(1101),
  joinRoom(1102),
  leaveRoom(1103),

  sendRoomMessage(1500),
  useGameAbility(1501),
  submitGameVote(1502),

  getFriends(2000),
  friendsUnreadMessages(2001),
  requestFriendship(2002),
  approveFriendship(2003),
  deleteFriendship(2004),
  getSuggestedFriends(2005),
  getFriendProfileDetails(2006),
  getPendingFriendshipRequests(2007),
  searchPlayers(2008),
  sendRoomInvite(2009),
  acceptRoomInvite(2010),
  getFriendMessages(2011),
  readFriendMessages(2012),
  sendMessageToFriend(2013),

  errorEvent(-1);

  final int value;
  const ClientCommand(this.value);
}

extension ServerEventExtension on ServerEvent {
  static ServerEvent? fromValue(int value) {
    return ServerEvent.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ServerEvent.errorEvent,
    );
  }
}

extension ClientCommandExtension on ClientCommand {
  static ClientCommand? fromValue(int value) {
    return ClientCommand.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClientCommand.errorEvent,
    );
  }
}