import 'dart:convert';

import 'package:mafia_classic/services/tcp/enums.dart';
import 'package:mafia_classic/services/tcp/event_bus.dart';

class ParserService {
  static final ParserService _instance = ParserService._internal();
  factory ParserService() => _instance;
  ParserService._internal();

  void parse(String rawData) {
    
  }

  ServerEvent? _parseEventType(String? type) {
    
  }
}
