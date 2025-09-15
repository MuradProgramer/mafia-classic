import 'dart:async';
import 'package:flutter/material.dart';

class GeneralStreams {
  const GeneralStreams._();

  static final StreamController<Locale> languageStream = StreamController.broadcast();
}