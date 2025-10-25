import 'package:mafia_classic/global_data.dart';
import 'package:mafia_classic/models/user.dart';

import 'tcp_client_service.dart';

class GeneralService {
  final TcpClientService _tcp = TcpClientService();

  final User user;

  GeneralService(this.user);

  Future<void> init() async {
    await _tcp.connect(serverIP, serverPort, user);
    // _tcp.messages.listen((raw) {
    //   final event = ParserService.parse(raw);
    //   if (event != null) {
    //     _bus.emit(event);
    //   }
    // });
  }
}
