import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'internet_state.dart';

class InternetCubit extends Cubit<InternetState> {
  late StreamSubscription _subscription;

  InternetCubit() : super(InternetInitial()) {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((_) => checkInternet());
    checkInternet();
  }

  Future<void> checkInternet() async {
    emit(InternetChecking());

    final hasInternet =
        await InternetConnectionChecker().hasConnection;

    if (hasInternet) {
      emit(InternetConnected());
    } else {
      emit(InternetDisconnected());
    }
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
