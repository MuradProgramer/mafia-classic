// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Games`
  String get games {
    return Intl.message(
      'Games',
      name: 'games',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Roles`
  String get roles {
    return Intl.message(
      'Roles',
      name: 'roles',
      desc: '',
      args: [],
    );
  }

  /// `Friends`
  String get friends {
    return Intl.message(
      'Friends',
      name: 'friends',
      desc: '',
      args: [],
    );
  }

  /// `Ratings`
  String get ratings {
    return Intl.message(
      'Ratings',
      name: 'ratings',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get share {
    return Intl.message(
      'Share',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `Mafia`
  String get mafia {
    return Intl.message(
      'Mafia',
      name: 'mafia',
      desc: '',
      args: [],
    );
  }

  /// `Terrorist`
  String get terrorist {
    return Intl.message(
      'Terrorist',
      name: 'terrorist',
      desc: '',
      args: [],
    );
  }

  /// `Barman`
  String get barman {
    return Intl.message(
      'Barman',
      name: 'barman',
      desc: '',
      args: [],
    );
  }

  /// `Informant`
  String get informant {
    return Intl.message(
      'Informant',
      name: 'informant',
      desc: '',
      args: [],
    );
  }

  /// `Citizen`
  String get citizen {
    return Intl.message(
      'Citizen',
      name: 'citizen',
      desc: '',
      args: [],
    );
  }

  /// `Doctor`
  String get doctor {
    return Intl.message(
      'Doctor',
      name: 'doctor',
      desc: '',
      args: [],
    );
  }

  /// `Sheriff`
  String get sheriff {
    return Intl.message(
      'Sheriff',
      name: 'sheriff',
      desc: '',
      args: [],
    );
  }

  /// `Mistress`
  String get mistress {
    return Intl.message(
      'Mistress',
      name: 'mistress',
      desc: '',
      args: [],
    );
  }

  /// `Journalist`
  String get journalist {
    return Intl.message(
      'Journalist',
      name: 'journalist',
      desc: '',
      args: [],
    );
  }

  /// `Bodyguard`
  String get bodyguard {
    return Intl.message(
      'Bodyguard',
      name: 'bodyguard',
      desc: '',
      args: [],
    );
  }

  /// `Spy`
  String get spy {
    return Intl.message(
      'Spy',
      name: 'spy',
      desc: '',
      args: [],
    );
  }

  /// `Rules`
  String get rules {
    return Intl.message(
      'Rules',
      name: 'rules',
      desc: '',
      args: [],
    );
  }

  /// `The Mafia is a registered character in the game. Each team of Mafiosi knows the players from their country, unlike the citizens of the world, who do not know who is playing for whom. They wake up at night in order to kill one of the inhabitants of the world, also known like them. Doctor and Sheriff.`
  String get roleMafiaDescription {
    return Intl.message(
      'The Mafia is a registered character in the game. Each team of Mafiosi knows the players from their country, unlike the citizens of the world, who do not know who is playing for whom. They wake up at night in order to kill one of the inhabitants of the world, also known like them. Doctor and Sheriff.',
      name: 'roleMafiaDescription',
      desc: '',
      args: [],
    );
  }

  /// `Terrorist - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the terrorist does not know the identity of the Mafia members. The Terrorist has one special ability. At any time during the day voting, the terrorist can blow up anyone player by killing both himself and the victim. The terrorist cannot be killed by the mafia at night. So the terrorist must help the mafia win using his life. Regardless of whether the terrorist is killed, he will receive experience points at the end of the game if. The mafia will win.`
  String get roleTerroristDescription {
    return Intl.message(
      'Terrorist - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the terrorist does not know the identity of the Mafia members. The Terrorist has one special ability. At any time during the day voting, the terrorist can blow up anyone player by killing both himself and the victim. The terrorist cannot be killed by the mafia at night. So the terrorist must help the mafia win using his life. Regardless of whether the terrorist is killed, he will receive experience points at the end of the game if. The mafia will win.',
      name: 'roleTerroristDescription',
      desc: '',
      args: [],
    );
  }

  /// `Barman - plays on the side of the mafia team. At night, he can make any player drunk. Thus, a drunk player will write illegible text in the chat, and will also not be able to vote during the day. The player will sober up only the next night.`
  String get roleBarmanDescription {
    return Intl.message(
      'Barman - plays on the side of the mafia team. At night, he can make any player drunk. Thus, a drunk player will write illegible text in the chat, and will also not be able to vote during the day. The player will sober up only the next night.',
      name: 'roleBarmanDescription',
      desc: '',
      args: [],
    );
  }

  /// `The informant is a player of the mafia team. The mafia does not know who the informant is. At night, the informant can check any player and reveal his role. He can also send messages to the mafia chat, and the spy will also see the informant's messages, but the mafioso and the spy will not see the nickname and photo of the informant. If all the mafiosi die, then the informant can vote for the player who will die at night.`
  String get roleInformantDescription {
    return Intl.message(
      'The informant is a player of the mafia team. The mafia does not know who the informant is. At night, the informant can check any player and reveal his role. He can also send messages to the mafia chat, and the spy will also see the informant\'s messages, but the mafioso and the spy will not see the nickname and photo of the informant. If all the mafiosi die, then the informant can vote for the player who will die at night.',
      name: 'roleInformantDescription',
      desc: '',
      args: [],
    );
  }

  /// `Civilians are tasked with identifying mafia players. They have no special abilities. All they can do is discuss and vote on who to kill in the day's vote.`
  String get roleCitizenDescription {
    return Intl.message(
      'Civilians are tasked with identifying mafia players. They have no special abilities. All they can do is discuss and vote on who to kill in the day\'s vote.',
      name: 'roleCitizenDescription',
      desc: '',
      args: [],
    );
  }

  /// `The Doctor is a civilian. The Doctor can save one of the players from death at night if he is killed that night. When night comes, he chooses who he will treat.`
  String get roleDoctorDescription {
    return Intl.message(
      'The Doctor is a civilian. The Doctor can save one of the players from death at night if he is killed that night. When night comes, he chooses who he will treat.',
      name: 'roleDoctorDescription',
      desc: '',
      args: [],
    );
  }

  /// `The Sheriff is a civilian. He is one of the most important players in the Mafia game. Every night he can examine another player and find out who is a Mafioso in the game and who is a civilian.`
  String get roleSheriffDescription {
    return Intl.message(
      'The Sheriff is a civilian. He is one of the most important players in the Mafia game. Every night he can examine another player and find out who is a Mafioso in the game and who is a civilian.',
      name: 'roleSheriffDescription',
      desc: '',
      args: [],
    );
  }

  /// `The Mistress is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Mistress came cannot use his ability at night, and also will not be able to vote the next day. The Mistress's love spell wears off only on next night.`
  String get roleMistressDescription {
    return Intl.message(
      'The Mistress is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Mistress came cannot use his ability at night, and also will not be able to vote the next day. The Mistress\'s love spell wears off only on next night.',
      name: 'roleMistressDescription',
      desc: '',
      args: [],
    );
  }

  /// `Journalist - plays on the side of the civilians. At night, he has the opportunity to conduct an investigation and check any two players, whether they play on the same team or on different ones. All players will see the result of the investigation in the news.`
  String get roleJournalistDescription {
    return Intl.message(
      'Journalist - plays on the side of the civilians. At night, he has the opportunity to conduct an investigation and check any two players, whether they play on the same team or on different ones. All players will see the result of the investigation in the news.',
      name: 'roleJournalistDescription',
      desc: '',
      args: [],
    );
  }

  /// `Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a terrorist explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Terrorist or Mafioso will decide to kill at night. The Bodyguard's protection only applies once, either during the day or at night, if the terrorist did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia's shot.`
  String get roleBodyguardDescription {
    return Intl.message(
      'Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a terrorist explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Terrorist or Mafioso will decide to kill at night. The Bodyguard\'s protection only applies once, either during the day or at night, if the terrorist did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia\'s shot.',
      name: 'roleBodyguardDescription',
      desc: '',
      args: [],
    );
  }

  /// `A spy is a civilian. He sees what the mafia talks about at night, but does not see the personalities of the mafia.`
  String get roleSpyDescription {
    return Intl.message(
      'A spy is a civilian. He sees what the mafia talks about at night, but does not see the personalities of the mafia.',
      name: 'roleSpyDescription',
      desc: '',
      args: [],
    );
  }

  /// `The players are divided into two teams: civilians who do not know each other, and the Mafia team, which is in the minority but knows each other. \n\nIn a civilian team, players can have special statuses. For example, among civilians, as a rule, there is a Sheriff and a Doctor\n\nThe gameplay is divided into two phases - "day" and "night".\n\nAt night the mafia wakes up, "consults" and kills one from the surviving townspeople by voting. The resident who receives the most votes dies at night.\n\nIf the votes are divided equally, the victim is chosen at random.\n\nIf none of the Mafiosi voted, everyone remains alive.\n\nAt the same time, the Sheriff and the Doctor wake up. The sheriff chooses one of the residents whom he wants to “test” for involvement in the mafia. The doctor chooses who he will treat.\n\nIf the doctor cured the player who was voted for by the Mafiosi, the player remains alive. But if there is more than one mafioso in the game, they can vote for multiple players. Thus, if the doctor treated one of them, the next one with the most votes will die.\n\nWhen day comes, it is announced who was killed during the night. The killed player is eliminated from the game, having the right to a final farewell message.\n\nDuring the day, players discuss which of them may be “dishonest” - involved in the mafia. At the end of the discussion, all players vote who they want to kill in the daily vote.\n\nThe most suspicious resident with the most votes dies.\n\nIf the votes are evenly divided, the victim is chosen at random. If no one voted, everyone remains alive.\n\nThe killed player is eliminated from the game, having the right to the last, farewell message.\n\nVictory is awarded after the complete destruction of one of the teams.\n\nIf all civilians are killed, the Mafia wins.\n\nAccordingly, in the event of the death of all Mafiosi - civilians win.`
  String get rulesDescription {
    return Intl.message(
      'The players are divided into two teams: civilians who do not know each other, and the Mafia team, which is in the minority but knows each other. \n\nIn a civilian team, players can have special statuses. For example, among civilians, as a rule, there is a Sheriff and a Doctor\n\nThe gameplay is divided into two phases - "day" and "night".\n\nAt night the mafia wakes up, "consults" and kills one from the surviving townspeople by voting. The resident who receives the most votes dies at night.\n\nIf the votes are divided equally, the victim is chosen at random.\n\nIf none of the Mafiosi voted, everyone remains alive.\n\nAt the same time, the Sheriff and the Doctor wake up. The sheriff chooses one of the residents whom he wants to “test” for involvement in the mafia. The doctor chooses who he will treat.\n\nIf the doctor cured the player who was voted for by the Mafiosi, the player remains alive. But if there is more than one mafioso in the game, they can vote for multiple players. Thus, if the doctor treated one of them, the next one with the most votes will die.\n\nWhen day comes, it is announced who was killed during the night. The killed player is eliminated from the game, having the right to a final farewell message.\n\nDuring the day, players discuss which of them may be “dishonest” - involved in the mafia. At the end of the discussion, all players vote who they want to kill in the daily vote.\n\nThe most suspicious resident with the most votes dies.\n\nIf the votes are evenly divided, the victim is chosen at random. If no one voted, everyone remains alive.\n\nThe killed player is eliminated from the game, having the right to the last, farewell message.\n\nVictory is awarded after the complete destruction of one of the teams.\n\nIf all civilians are killed, the Mafia wins.\n\nAccordingly, in the event of the death of all Mafiosi - civilians win.',
      name: 'rulesDescription',
      desc: '',
      args: [],
    );
  }

  /// `Experience`
  String get experience {
    return Intl.message(
      'Experience',
      name: 'experience',
      desc: '',
      args: [],
    );
  }

  /// `Games Played`
  String get gamesPlayed {
    return Intl.message(
      'Games Played',
      name: 'gamesPlayed',
      desc: '',
      args: [],
    );
  }

  /// `Games Won`
  String get gamesWon {
    return Intl.message(
      'Games Won',
      name: 'gamesWon',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get today {
    return Intl.message(
      'Today',
      name: 'today',
      desc: '',
      args: [],
    );
  }

  /// `All Time`
  String get allTime {
    return Intl.message(
      'All Time',
      name: 'allTime',
      desc: '',
      args: [],
    );
  }

  /// `Search friends`
  String get searchFriends {
    return Intl.message(
      'Search friends',
      name: 'searchFriends',
      desc: '',
      args: [],
    );
  }

  /// `Enter username`
  String get enterUsername {
    return Intl.message(
      'Enter username',
      name: 'enterUsername',
      desc: '',
      args: [],
    );
  }

  /// `online`
  String get online {
    return Intl.message(
      'online',
      name: 'online',
      desc: '',
      args: [],
    );
  }

  /// `Send request`
  String get sendRequest {
    return Intl.message(
      'Send request',
      name: 'sendRequest',
      desc: '',
      args: [],
    );
  }

  /// `Request alredy sent`
  String get requestAlredySent {
    return Intl.message(
      'Request alredy sent',
      name: 'requestAlredySent',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get requests {
    return Intl.message(
      'Requests',
      name: 'requests',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Change password`
  String get changePassword {
    return Intl.message(
      'Change password',
      name: 'changePassword',
      desc: '',
      args: [],
    );
  }

  /// `Old password`
  String get oldPassword {
    return Intl.message(
      'Old password',
      name: 'oldPassword',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get newPassword {
    return Intl.message(
      'New password',
      name: 'newPassword',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get change {
    return Intl.message(
      'Change',
      name: 'change',
      desc: '',
      args: [],
    );
  }

  /// `Nickname`
  String get nickname {
    return Intl.message(
      'Nickname',
      name: 'nickname',
      desc: '',
      args: [],
    );
  }

  /// `Change nickname`
  String get changeNickname {
    return Intl.message(
      'Change nickname',
      name: 'changeNickname',
      desc: '',
      args: [],
    );
  }

  /// `Write new nickname`
  String get writeNewNickname {
    return Intl.message(
      'Write new nickname',
      name: 'writeNewNickname',
      desc: '',
      args: [],
    );
  }

  /// `Change avatar`
  String get changeAvatar {
    return Intl.message(
      'Change avatar',
      name: 'changeAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Log out`
  String get logOut {
    return Intl.message(
      'Log out',
      name: 'logOut',
      desc: '',
      args: [],
    );
  }

  /// `Delete accaunt`
  String get deleteAccaunt {
    return Intl.message(
      'Delete accaunt',
      name: 'deleteAccaunt',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Sign In`
  String get signIn {
    return Intl.message(
      'Sign In',
      name: 'signIn',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an accaunt? Sign up`
  String get dontHaveAccauntRegister {
    return Intl.message(
      'Don\'t have an accaunt? Sign up',
      name: 'dontHaveAccauntRegister',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get confirmPassword {
    return Intl.message(
      'Confirm Password',
      name: 'confirmPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match',
      name: 'passwordsDoNotMatch',
      desc: '',
      args: [],
    );
  }

  /// `Sign Up`
  String get signUp {
    return Intl.message(
      'Sign Up',
      name: 'signUp',
      desc: '',
      args: [],
    );
  }

  /// `Alredy have an accaunt? Sign In`
  String get alreadyHaveAccauntSigIn {
    return Intl.message(
      'Alredy have an accaunt? Sign In',
      name: 'alreadyHaveAccauntSigIn',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
