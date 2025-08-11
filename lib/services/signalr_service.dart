import 'dart:developer';

import 'package:get_it/get_it.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';
import 'package:signalr_netcore/http_connection_options.dart';
import 'package:signalr_netcore/itransport.dart';

class SignalRService {
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;
  SignalRService._internal();

  HubConnection? _mainHubConnection;
  bool _isMainHubConnecting = false;

  HubConnection get mainHubConnection {
    _mainHubConnection ??= HubConnectionBuilder()
        .withAutomaticReconnect()
        .withUrl(
          'https://31.171.65.145/mainlobby',
          options: HttpConnectionOptions(
            transport: HttpTransportType.WebSockets,
            skipNegotiation: true,
            accessTokenFactory: () => Future.value(GetIt.I<ApiService>().accessToken)
          ),
        )
        .build();
    return _mainHubConnection!;
  }

  Future<void> startConnection() async {
    if (_isMainHubConnecting) {
      print('Connection attempt already in progress');
      return;
    }

    if (mainHubConnection.state == HubConnectionState.Disconnected) {
      try {
        _isMainHubConnecting = true;
        print('Starting connection...');
        await mainHubConnection.start();
        print('Connection started successfully');
      } catch (e) {
        print('Error starting connection: $e');
      } finally {
        _isMainHubConnecting = false;
      }
    } else {
      print('Cannot start: current state is ${mainHubConnection.state}');
    }
  }

  Future<void> stopConnection() async {
    if (_isMainHubConnecting) {
      print('Waiting for connection attempt to complete before stopping');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    if (_mainHubConnection?.state != HubConnectionState.Disconnected) {
      await _mainHubConnection?.stop();
      print('Connection stopped');
    } else {
      print('Connection already stopped');
    }
  }

  bool get isConnected => _mainHubConnection?.state == HubConnectionState.Connected;
}
