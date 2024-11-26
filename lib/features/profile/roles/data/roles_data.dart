import 'package:flutter/material.dart';
import 'package:mafia_classic/features/profile/roles/models/models.dart';
import 'package:mafia_classic/generated/l10n.dart';

List<Role> getRoles(BuildContext context) {
  return [
    Role(S.of(context).mafia,     S.of(context).roleMafiaDescription,      "assets/avatar.jpg"),
    Role(S.of(context).terrorist, S.of(context).roleTerroristDescription,  "assets/avatar.jpg"),
    Role(S.of(context).barman,    S.of(context).roleBarmanDescription,     "assets/avatar.jpg"),
    Role(S.of(context).informant, S.of(context).roleInformantDescription,  "assets/avatar.jpg"),

    Role(S.of(context).citizen,   S.of(context).roleCitizenDescription,    "assets/avatar.jpg"),
    Role(S.of(context).doctor,    S.of(context).roleDoctorDescription,     "assets/avatar.jpg"),
    Role(S.of(context).sheriff,   S.of(context).roleSheriffDescription,    "assets/avatar.jpg"),
    Role(S.of(context).mistress,  S.of(context).roleMistressDescription,   "assets/avatar.jpg"),
    Role(S.of(context).journalist,S.of(context).roleJournalistDescription, "assets/avatar.jpg"),
    Role(S.of(context).bodyguard, S.of(context).roleBodyguardDescription,  "assets/avatar.jpg"),
    Role(S.of(context).spy,       S.of(context).roleSpyDescription,        "assets/avatar.jpg"),

    Role(S.of(context).rules,     S.of(context).rulesDescription,          "assets/avatar.jpg")
  ];
}