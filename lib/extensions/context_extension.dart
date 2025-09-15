import 'package:flutter/material.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
//import 'package:flutter_gen';

extension BuildContextExtension on BuildContext {
  AppLocalizations get localizations => AppLocalizations.of(this)!;
}