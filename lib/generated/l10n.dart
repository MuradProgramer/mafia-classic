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

  /// `Beauty`
  String get mistress {
    return Intl.message(
      'Beauty',
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

  /// `The Beauty is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Beauty came cannot use his ability at night, and also will not be able to vote the next day. The Beauty's love spell wears off only on next night.`
  String get roleMistressDescription {
    return Intl.message(
      'The Beauty is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Beauty came cannot use his ability at night, and also will not be able to vote the next day. The Beauty\'s love spell wears off only on next night.',
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

  /// `Players`
  String get players {
    return Intl.message(
      'Players',
      name: 'players',
      desc: '',
      args: [],
    );
  }

  /// `Min`
  String get min {
    return Intl.message(
      'Min',
      name: 'min',
      desc: '',
      args: [],
    );
  }

  /// `Max`
  String get max {
    return Intl.message(
      'Max',
      name: 'max',
      desc: '',
      args: [],
    );
  }

  /// `Join`
  String get join {
    return Intl.message(
      'Join',
      name: 'join',
      desc: '',
      args: [],
    );
  }

  /// `Game Started`
  String get gameStarted {
    return Intl.message(
      'Game Started',
      name: 'gameStarted',
      desc: '',
      args: [],
    );
  }

  /// `Gathering Players`
  String get gatheringPlayers {
    return Intl.message(
      'Gathering Players',
      name: 'gatheringPlayers',
      desc: '',
      args: [],
    );
  }

  /// `Alive`
  String get alive {
    return Intl.message(
      'Alive',
      name: 'alive',
      desc: '',
      args: [],
    );
  }

  /// `Dead`
  String get dead {
    return Intl.message(
      'Dead',
      name: 'dead',
      desc: '',
      args: [],
    );
  }

  /// `Create Game`
  String get createGame {
    return Intl.message(
      'Create Game',
      name: 'createGame',
      desc: '',
      args: [],
    );
  }

  /// `Password (Optional)`
  String get passwordOptional {
    return Intl.message(
      'Password (Optional)',
      name: 'passwordOptional',
      desc: '',
      args: [],
    );
  }

  /// `Room Name`
  String get roomName {
    return Intl.message(
      'Room Name',
      name: 'roomName',
      desc: '',
      args: [],
    );
  }

  /// `Reset`
  String get reset {
    return Intl.message(
      'Reset',
      name: 'reset',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: '',
      args: [],
    );
  }

  /// `Friends in the room`
  String get friendInTheRoom {
    return Intl.message(
      'Friends in the room',
      name: 'friendInTheRoom',
      desc: '',
      args: [],
    );
  }

  /// `Only rooms with available space`
  String get onlyRoomsWithAvailableSpace {
    return Intl.message(
      'Only rooms with available space',
      name: 'onlyRoomsWithAvailableSpace',
      desc: '',
      args: [],
    );
  }

  /// `Rooms without a password`
  String get roomsWithoutAPassword {
    return Intl.message(
      'Rooms without a password',
      name: 'roomsWithoutAPassword',
      desc: '',
      args: [],
    );
  }

  /// `Rooms with a password`
  String get roomsWithAPassword {
    return Intl.message(
      'Rooms with a password',
      name: 'roomsWithAPassword',
      desc: '',
      args: [],
    );
  }

  /// `Additional Roles`
  String get additionalRoles {
    return Intl.message(
      'Additional Roles',
      name: 'additionalRoles',
      desc: '',
      args: [],
    );
  }

  /// `Rooms without additional roles`
  String get roomsWithourAdditionalRoles {
    return Intl.message(
      'Rooms without additional roles',
      name: 'roomsWithourAdditionalRoles',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get apply {
    return Intl.message(
      'Apply',
      name: 'apply',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Remaining time`
  String get remainingTime {
    return Intl.message(
      'Remaining time',
      name: 'remainingTime',
      desc: '',
      args: [],
    );
  }

  /// `Seconds`
  String get seconds {
    return Intl.message(
      'Seconds',
      name: 'seconds',
      desc: '',
      args: [],
    );
  }

  /// `Players in the Room`
  String get playersInRoom {
    return Intl.message(
      'Players in the Room',
      name: 'playersInRoom',
      desc: '',
      args: [],
    );
  }

  /// `Enter message`
  String get enterMessage {
    return Intl.message(
      'Enter message',
      name: 'enterMessage',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAnAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `You must write your nickname`
  String get youMustWriteYourNickname {
    return Intl.message(
      'You must write your nickname',
      name: 'youMustWriteYourNickname',
      desc: '',
      args: [],
    );
  }

  /// `Your nickname must contain at least 3 characters`
  String get yourNicknameMustContainAtLeast3Characters {
    return Intl.message(
      'Your nickname must contain at least 3 characters',
      name: 'yourNicknameMustContainAtLeast3Characters',
      desc: '',
      args: [],
    );
  }

  /// `Your nickname can contain, letters, numbers and . _ -`
  String get yourNicknameCanContainLettersNumbersAnd {
    return Intl.message(
      'Your nickname can contain, letters, numbers and . _ -',
      name: 'yourNicknameCanContainLettersNumbersAnd',
      desc: '',
      args: [],
    );
  }

  /// `You must write your email`
  String get youMustWriteYourEmail {
    return Intl.message(
      'You must write your email',
      name: 'youMustWriteYourEmail',
      desc: '',
      args: [],
    );
  }

  /// `Enter valid email`
  String get enterValidEmail {
    return Intl.message(
      'Enter valid email',
      name: 'enterValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `You must write your password`
  String get youMustWriteYourPassword {
    return Intl.message(
      'You must write your password',
      name: 'youMustWriteYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Your password must contain at least 6 characters`
  String get yourPasswordMustContainAtLeast6Characters {
    return Intl.message(
      'Your password must contain at least 6 characters',
      name: 'yourPasswordMustContainAtLeast6Characters',
      desc: '',
      args: [],
    );
  }

  /// `You must confirm your password`
  String get youMustConfirmYourPassword {
    return Intl.message(
      'You must confirm your password',
      name: 'youMustConfirmYourPassword',
      desc: '',
      args: [],
    );
  }

  /// `Passwords are not matching`
  String get passwordsAreNotMatching {
    return Intl.message(
      'Passwords are not matching',
      name: 'passwordsAreNotMatching',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, connection with server timeouted...`
  String get sorryConnectionWithServerTimeouted {
    return Intl.message(
      'Sorry, connection with server timeouted...',
      name: 'sorryConnectionWithServerTimeouted',
      desc: '',
      args: [],
    );
  }

  /// `Player with this email already exist`
  String get playerWithThisEmailAlreadyExist {
    return Intl.message(
      'Player with this email already exist',
      name: 'playerWithThisEmailAlreadyExist',
      desc: '',
      args: [],
    );
  }

  /// `Player with this nickname already exist`
  String get playerWithThisNicknameAlreadyExist {
    return Intl.message(
      'Player with this nickname already exist',
      name: 'playerWithThisNicknameAlreadyExist',
      desc: '',
      args: [],
    );
  }

  /// `Sorry, Something bad happened...`
  String get sorrySomethingBadHappened {
    return Intl.message(
      'Sorry, Something bad happened...',
      name: 'sorrySomethingBadHappened',
      desc: '',
      args: [],
    );
  }

  /// `User with this email does not exist`
  String get userWithThisEmailDoesNotExist {
    return Intl.message(
      'User with this email does not exist',
      name: 'userWithThisEmailDoesNotExist',
      desc: '',
      args: [],
    );
  }

  /// `Email or Password is invalid`
  String get emailOrPasswordIsInvalid {
    return Intl.message(
      'Email or Password is invalid',
      name: 'emailOrPasswordIsInvalid',
      desc: '',
      args: [],
    );
  }

  /// `Don't have an account?`
  String get dontHaveAnAccount {
    return Intl.message(
      'Don\'t have an account?',
      name: 'dontHaveAnAccount',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password`
  String get forgotPassword {
    return Intl.message(
      'Forgot Password',
      name: 'forgotPassword',
      desc: '',
      args: [],
    );
  }

  /// `Players in the room`
  String get playersInTheRoom {
    return Intl.message(
      'Players in the room',
      name: 'playersInTheRoom',
      desc: '',
      args: [],
    );
  }

  /// `Civilian `
  String get civilian {
    return Intl.message(
      'Civilian ',
      name: 'civilian',
      desc: '',
      args: [],
    );
  }

  /// `Day`
  String get day {
    return Intl.message(
      'Day',
      name: 'day',
      desc: '',
      args: [],
    );
  }

  /// `is your destiny`
  String get isYourDestiny {
    return Intl.message(
      'is your destiny',
      name: 'isYourDestiny',
      desc: '',
      args: [],
    );
  }

  /// `Use Skill`
  String get useSkill {
    return Intl.message(
      'Use Skill',
      name: 'useSkill',
      desc: '',
      args: [],
    );
  }

  /// `civilians are with us`
  String get civiliansAreWithUs {
    return Intl.message(
      'civilians are with us',
      name: 'civiliansAreWithUs',
      desc: '',
      args: [],
    );
  }

  /// `Bombard`
  String get bombard {
    return Intl.message(
      'Bombard',
      name: 'bombard',
      desc: '',
      args: [],
    );
  }

  /// `Vote`
  String get vote {
    return Intl.message(
      'Vote',
      name: 'vote',
      desc: '',
      args: [],
    );
  }

  /// `My move is made`
  String get myMoveIsMade {
    return Intl.message(
      'My move is made',
      name: 'myMoveIsMade',
      desc: '',
      args: [],
    );
  }

  /// `I accept the weight of my choice`
  String get iAcceptTheWeightOfMyChoice {
    return Intl.message(
      'I accept the weight of my choice',
      name: 'iAcceptTheWeightOfMyChoice',
      desc: '',
      args: [],
    );
  }

  /// `Cure`
  String get cure {
    return Intl.message(
      'Cure',
      name: 'cure',
      desc: '',
      args: [],
    );
  }

  /// `Satisfy`
  String get satisfy {
    return Intl.message(
      'Satisfy',
      name: 'satisfy',
      desc: '',
      args: [],
    );
  }

  /// `Protect`
  String get protect {
    return Intl.message(
      'Protect',
      name: 'protect',
      desc: '',
      args: [],
    );
  }

  /// `Intoxicate`
  String get intoxicate {
    return Intl.message(
      'Intoxicate',
      name: 'intoxicate',
      desc: '',
      args: [],
    );
  }

  /// `Reveale`
  String get reveale {
    return Intl.message(
      'Reveale',
      name: 'reveale',
      desc: '',
      args: [],
    );
  }

  /// `Investigate`
  String get investigate {
    return Intl.message(
      'Investigate',
      name: 'investigate',
      desc: '',
      args: [],
    );
  }

  /// `Interview`
  String get interview {
    return Intl.message(
      'Interview',
      name: 'interview',
      desc: '',
      args: [],
    );
  }

  /// `mafias`
  String get mafias {
    return Intl.message(
      'mafias',
      name: 'mafias',
      desc: '',
      args: [],
    );
  }

  /// `civilians`
  String get civilians {
    return Intl.message(
      'civilians',
      name: 'civilians',
      desc: '',
      args: [],
    );
  }

  /// `Pick your target`
  String get pickYourTarget {
    return Intl.message(
      'Pick your target',
      name: 'pickYourTarget',
      desc: '',
      args: [],
    );
  }

  /// `I've chosen. No regrets`
  String get iveChosenNoRegrets {
    return Intl.message(
      'I\'ve chosen. No regrets',
      name: 'iveChosenNoRegrets',
      desc: '',
      args: [],
    );
  }

  /// `Choose`
  String get choose {
    return Intl.message(
      'Choose',
      name: 'choose',
      desc: '',
      args: [],
    );
  }

  /// `Enter the message...`
  String get enterTheMessage {
    return Intl.message(
      'Enter the message...',
      name: 'enterTheMessage',
      desc: '',
      args: [],
    );
  }

  /// `Lobby`
  String get lobby {
    return Intl.message(
      'Lobby',
      name: 'lobby',
      desc: '',
      args: [],
    );
  }

  /// ` Search...`
  String get search {
    return Intl.message(
      ' Search...',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Filter Off`
  String get filterOff {
    return Intl.message(
      'Filter Off',
      name: 'filterOff',
      desc: '',
      args: [],
    );
  }

  /// `No available games..`
  String get noAvailableGames {
    return Intl.message(
      'No available games..',
      name: 'noAvailableGames',
      desc: '',
      args: [],
    );
  }

  /// `You Are Playing Here`
  String get youArePlayingHere {
    return Intl.message(
      'You Are Playing Here',
      name: 'youArePlayingHere',
      desc: '',
      args: [],
    );
  }

  /// `You Died Here`
  String get youDiedHere {
    return Intl.message(
      'You Died Here',
      name: 'youDiedHere',
      desc: '',
      args: [],
    );
  }

  /// `Show`
  String get show {
    return Intl.message(
      'Show',
      name: 'show',
      desc: '',
      args: [],
    );
  }

  /// `All Players`
  String get allPlayers {
    return Intl.message(
      'All Players',
      name: 'allPlayers',
      desc: '',
      args: [],
    );
  }

  /// `are here`
  String get areHere {
    return Intl.message(
      'are here',
      name: 'areHere',
      desc: '',
      args: [],
    );
  }

  /// `Defeated`
  String get defeated {
    return Intl.message(
      'Defeated',
      name: 'defeated',
      desc: '',
      args: [],
    );
  }

  /// `Still here`
  String get stillHere {
    return Intl.message(
      'Still here',
      name: 'stillHere',
      desc: '',
      args: [],
    );
  }

  /// ` Enter the name`
  String get enterTheName {
    return Intl.message(
      ' Enter the name',
      name: 'enterTheName',
      desc: '',
      args: [],
    );
  }

  /// `on`
  String get on {
    return Intl.message(
      'on',
      name: 'on',
      desc: '',
      args: [],
    );
  }

  /// `off`
  String get off {
    return Intl.message(
      'off',
      name: 'off',
      desc: '',
      args: [],
    );
  }

  /// ` Enter the password`
  String get enterThePassword {
    return Intl.message(
      ' Enter the password',
      name: 'enterThePassword',
      desc: '',
      args: [],
    );
  }

  /// `Number of players`
  String get numberOfPlayers {
    return Intl.message(
      'Number of players',
      name: 'numberOfPlayers',
      desc: '',
      args: [],
    );
  }

  /// `Extra Roles`
  String get extraRoles {
    return Intl.message(
      'Extra Roles',
      name: 'extraRoles',
      desc: '',
      args: [],
    );
  }

  /// `Beauty`
  String get beauty {
    return Intl.message(
      'Beauty',
      name: 'beauty',
      desc: '',
      args: [],
    );
  }

  /// `Bartender`
  String get bartender {
    return Intl.message(
      'Bartender',
      name: 'bartender',
      desc: '',
      args: [],
    );
  }

  /// `Rooms with:`
  String get roomsWith {
    return Intl.message(
      'Rooms with:',
      name: 'roomsWith',
      desc: '',
      args: [],
    );
  }

  /// `Available Spots`
  String get availableSpots {
    return Intl.message(
      'Available Spots',
      name: 'availableSpots',
      desc: '',
      args: [],
    );
  }

  /// `Friends In`
  String get friendsIn {
    return Intl.message(
      'Friends In',
      name: 'friendsIn',
      desc: '',
      args: [],
    );
  }

  /// `Access`
  String get access {
    return Intl.message(
      'Access',
      name: 'access',
      desc: '',
      args: [],
    );
  }

  /// `Mixed`
  String get mixed {
    return Intl.message(
      'Mixed',
      name: 'mixed',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `Private`
  String get private {
    return Intl.message(
      'Private',
      name: 'private',
      desc: '',
      args: [],
    );
  }

  /// `Included roles:`
  String get includedRoles {
    return Intl.message(
      'Included roles:',
      name: 'includedRoles',
      desc: '',
      args: [],
    );
  }

  /// `Lover`
  String get lover {
    return Intl.message(
      'Lover',
      name: 'lover',
      desc: '',
      args: [],
    );
  }

  /// `Starting:`
  String get starting {
    return Intl.message(
      'Starting:',
      name: 'starting',
      desc: '',
      args: [],
    );
  }

  /// `Waiting...`
  String get waiting {
    return Intl.message(
      'Waiting...',
      name: 'waiting',
      desc: '',
      args: [],
    );
  }

  /// `TRUSTED INDIVIDUALS`
  String get trustedIndividuals {
    return Intl.message(
      'TRUSTED INDIVIDUALS',
      name: 'trustedIndividuals',
      desc: '',
      args: [],
    );
  }

  /// `Justice rides with us.`
  String get justiceRidesWithUs {
    return Intl.message(
      'Justice rides with us.',
      name: 'justiceRidesWithUs',
      desc: '',
      args: [],
    );
  }

  /// `No users found`
  String get noUsersFound {
    return Intl.message(
      'No users found',
      name: 'noUsersFound',
      desc: '',
      args: [],
    );
  }

  /// `No friends found`
  String get noFriendsFound {
    return Intl.message(
      'No friends found',
      name: 'noFriendsFound',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `REGISTRY`
  String get registry {
    return Intl.message(
      'REGISTRY',
      name: 'registry',
      desc: '',
      args: [],
    );
  }

  /// `OF CHOOSEN ONES`
  String get ofChoosenOnes {
    return Intl.message(
      'OF CHOOSEN ONES',
      name: 'ofChoosenOnes',
      desc: '',
      args: [],
    );
  }

  /// `Only the truest ride together.`
  String get onlyTheTruestRideTogether {
    return Intl.message(
      'Only the truest ride together.',
      name: 'onlyTheTruestRideTogether',
      desc: '',
      args: [],
    );
  }

  /// `No players found`
  String get noPlayersFound {
    return Intl.message(
      'No players found',
      name: 'noPlayersFound',
      desc: '',
      args: [],
    );
  }

  /// `No requests found`
  String get noRequestsFound {
    return Intl.message(
      'No requests found',
      name: 'noRequestsFound',
      desc: '',
      args: [],
    );
  }

  /// `WANTED:`
  String get wanted {
    return Intl.message(
      'WANTED:',
      name: 'wanted',
      desc: '',
      args: [],
    );
  }

  /// `GOOD COMPANY`
  String get goodCompany {
    return Intl.message(
      'GOOD COMPANY',
      name: 'goodCompany',
      desc: '',
      args: [],
    );
  }

  /// `Riding solo ain't the way.`
  String get ridingSoloAintTheWay {
    return Intl.message(
      'Riding solo ain\'t the way.',
      name: 'ridingSoloAintTheWay',
      desc: '',
      args: [],
    );
  }

  /// `Request Pending`
  String get requestPending {
    return Intl.message(
      'Request Pending',
      name: 'requestPending',
      desc: '',
      args: [],
    );
  }

  /// `Approve Pending`
  String get approvePending {
    return Intl.message(
      'Approve Pending',
      name: 'approvePending',
      desc: '',
      args: [],
    );
  }

  /// `classic`
  String get classic {
    return Intl.message(
      'classic',
      name: 'classic',
      desc: '',
      args: [],
    );
  }

  /// `Welcome,`
  String get welcome {
    return Intl.message(
      'Welcome,',
      name: 'welcome',
      desc: '',
      args: [],
    );
  }

  /// `Chat`
  String get chat {
    return Intl.message(
      'Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Offline`
  String get offline {
    return Intl.message(
      'Offline',
      name: 'offline',
      desc: '',
      args: [],
    );
  }

  /// `Join Date`
  String get joinDate {
    return Intl.message(
      'Join Date',
      name: 'joinDate',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get report {
    return Intl.message(
      'Report',
      name: 'report',
      desc: '',
      args: [],
    );
  }

  /// `Add To Friends`
  String get addToFriends {
    return Intl.message(
      'Add To Friends',
      name: 'addToFriends',
      desc: '',
      args: [],
    );
  }

  /// `Currently Offline`
  String get currentlyOffline {
    return Intl.message(
      'Currently Offline',
      name: 'currentlyOffline',
      desc: '',
      args: [],
    );
  }

  /// `Currently are not playing`
  String get currentlyAreNotPlaying {
    return Intl.message(
      'Currently are not playing',
      name: 'currentlyAreNotPlaying',
      desc: '',
      args: [],
    );
  }

  /// `Currently are playing in:`
  String get currentlyArePlayingIn {
    return Intl.message(
      'Currently are playing in:',
      name: 'currentlyArePlayingIn',
      desc: '',
      args: [],
    );
  }

  /// `Players in total`
  String get playersInTotal {
    return Intl.message(
      'Players in total',
      name: 'playersInTotal',
      desc: '',
      args: [],
    );
  }

  /// `Stats`
  String get stats {
    return Intl.message(
      'Stats',
      name: 'stats',
      desc: '',
      args: [],
    );
  }

  /// `Overall`
  String get overall {
    return Intl.message(
      'Overall',
      name: 'overall',
      desc: '',
      args: [],
    );
  }

  /// `Wins`
  String get wins {
    return Intl.message(
      'Wins',
      name: 'wins',
      desc: '',
      args: [],
    );
  }

  /// `Loses`
  String get loses {
    return Intl.message(
      'Loses',
      name: 'loses',
      desc: '',
      args: [],
    );
  }

  /// `Mafia Wins`
  String get mafiaWins {
    return Intl.message(
      'Mafia Wins',
      name: 'mafiaWins',
      desc: '',
      args: [],
    );
  }

  /// `Civilian Wins`
  String get civilianWins {
    return Intl.message(
      'Civilian Wins',
      name: 'civilianWins',
      desc: '',
      args: [],
    );
  }

  /// `Played Roles`
  String get playedRoles {
    return Intl.message(
      'Played Roles',
      name: 'playedRoles',
      desc: '',
      args: [],
    );
  }

  /// `Avatar`
  String get avatar {
    return Intl.message(
      'Avatar',
      name: 'avatar',
      desc: '',
      args: [],
    );
  }

  /// `Upload`
  String get upload {
    return Intl.message(
      'Upload',
      name: 'upload',
      desc: '',
      args: [],
    );
  }

  /// `Sound Effects`
  String get soundEffects {
    return Intl.message(
      'Sound Effects',
      name: 'soundEffects',
      desc: '',
      args: [],
    );
  }

  /// `On`
  String get onOn {
    return Intl.message(
      'On',
      name: 'onOn',
      desc: '',
      args: [],
    );
  }

  /// `Off`
  String get offOff {
    return Intl.message(
      'Off',
      name: 'offOff',
      desc: '',
      args: [],
    );
  }

  /// `Delete Account`
  String get deleteAccount {
    return Intl.message(
      'Delete Account',
      name: 'deleteAccount',
      desc: '',
      args: [],
    );
  }

  /// `Current Avatar`
  String get currentAvatar {
    return Intl.message(
      'Current Avatar',
      name: 'currentAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Upload New`
  String get uploadNew {
    return Intl.message(
      'Upload New',
      name: 'uploadNew',
      desc: '',
      args: [],
    );
  }

  /// `Upload Another`
  String get uploadAnother {
    return Intl.message(
      'Upload Another',
      name: 'uploadAnother',
      desc: '',
      args: [],
    );
  }

  /// `Current Nickname`
  String get currentNickname {
    return Intl.message(
      'Current Nickname',
      name: 'currentNickname',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get currentPassword {
    return Intl.message(
      'Current Password',
      name: 'currentPassword',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `You must write a title of the report`
  String get youMustWriteATitleOfTheReport {
    return Intl.message(
      'You must write a title of the report',
      name: 'youMustWriteATitleOfTheReport',
      desc: '',
      args: [],
    );
  }

  /// `Type here`
  String get typeHere {
    return Intl.message(
      'Type here',
      name: 'typeHere',
      desc: '',
      args: [],
    );
  }

  /// `In case of any problem, please notify us`
  String get inCaseOfAnyProblemPleaseNotifyUs {
    return Intl.message(
      'In case of any problem, please notify us',
      name: 'inCaseOfAnyProblemPleaseNotifyUs',
      desc: '',
      args: [],
    );
  }

  /// `Recover`
  String get recover {
    return Intl.message(
      'Recover',
      name: 'recover',
      desc: '',
      args: [],
    );
  }

  /// `Write down the email to get a code`
  String get writeDownTheEmailToGetACode {
    return Intl.message(
      'Write down the email to get a code',
      name: 'writeDownTheEmailToGetACode',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message(
      'Next',
      name: 'next',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message(
      'Back',
      name: 'back',
      desc: '',
      args: [],
    );
  }

  /// `You must write the SMS code`
  String get youMustWriteTheSmsCode {
    return Intl.message(
      'You must write the SMS code',
      name: 'youMustWriteTheSmsCode',
      desc: '',
      args: [],
    );
  }

  /// `SMS`
  String get sms {
    return Intl.message(
      'SMS',
      name: 'sms',
      desc: '',
      args: [],
    );
  }

  /// `Code must be numeric`
  String get codeMustBeNumeric {
    return Intl.message(
      'Code must be numeric',
      name: 'codeMustBeNumeric',
      desc: '',
      args: [],
    );
  }

  /// `Code must be 6 charactes`
  String get codeMustBe6Charactes {
    return Intl.message(
      'Code must be 6 charactes',
      name: 'codeMustBe6Charactes',
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
      Locale.fromSubtags(languageCode: 'az'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
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
