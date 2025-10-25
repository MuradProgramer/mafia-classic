import 'dart:convert';

import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/tcp_client_service.dart';

class GameService {
  final TcpClientService _tcp = TcpClientService();

  void votePlayer(String gameTitle, String from, String to) async {
    final request = {
      'action': 'vote',
      'gameTitle': gameTitle,
      'from': from,
      'to': to,
    };

  }
}
