enum ServerEvent {
  pong(0),

  clientError(1),
  clientDuplicateLogin(2),
  clientAuthorizationSuccess(3),
  
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

  friendInvitation(5000),

  errorEvent(-1);

  final int value;
  const ServerEvent(this.value);
}

enum ClientCommand {
  ping(0),

  authorize(1),

  getRooms(1100),
  createRoom(1101),
  joinRoom(1102),
  leaveRoom(1103),

  sendRoomMessage(1500),
  useGameAbility(1501),
  submitGameVote(1502),

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