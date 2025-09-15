import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_az.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('az'),
    Locale('en'),
    Locale('ru'),
    Locale('tr')
  ];

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @roles.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get roles;

  /// No description provided for @friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friends;

  /// No description provided for @ratings.
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get ratings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @mafia.
  ///
  /// In en, this message translates to:
  /// **'Mafia'**
  String get mafia;

  /// No description provided for @terrorist.
  ///
  /// In en, this message translates to:
  /// **'Terrorist'**
  String get terrorist;

  /// No description provided for @barman.
  ///
  /// In en, this message translates to:
  /// **'Barman'**
  String get barman;

  /// No description provided for @informant.
  ///
  /// In en, this message translates to:
  /// **'Informant'**
  String get informant;

  /// No description provided for @citizen.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizen;

  /// No description provided for @doctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor'**
  String get doctor;

  /// No description provided for @sheriff.
  ///
  /// In en, this message translates to:
  /// **'Sheriff'**
  String get sheriff;

  /// No description provided for @mistress.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get mistress;

  /// No description provided for @journalist.
  ///
  /// In en, this message translates to:
  /// **'Journalist'**
  String get journalist;

  /// No description provided for @bodyguard.
  ///
  /// In en, this message translates to:
  /// **'Bodyguard'**
  String get bodyguard;

  /// No description provided for @spy.
  ///
  /// In en, this message translates to:
  /// **'Spy'**
  String get spy;

  /// No description provided for @rules.
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get rules;

  /// No description provided for @roleMafiaDescription.
  ///
  /// In en, this message translates to:
  /// **'The Mafia is a registered character in the game. Each team of Mafiosi knows the players from their country, unlike the citizens of the world, who do not know who is playing for whom. They wake up at night in order to kill one of the inhabitants of the world, also known like them. Doctor and Sheriff.'**
  String get roleMafiaDescription;

  /// No description provided for @roleTerroristDescription.
  ///
  /// In en, this message translates to:
  /// **'Terrorist - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the terrorist does not know the identity of the Mafia members. The Terrorist has one special ability. At any time during the day voting, the terrorist can blow up anyone player by killing both himself and the victim. The terrorist cannot be killed by the mafia at night. So the terrorist must help the mafia win using his life. Regardless of whether the terrorist is killed, he will receive experience points at the end of the game if. The mafia will win.'**
  String get roleTerroristDescription;

  /// No description provided for @roleBarmanDescription.
  ///
  /// In en, this message translates to:
  /// **'Barman - plays on the side of the mafia team. At night, he can make any player drunk. Thus, a drunk player will write illegible text in the chat, and will also not be able to vote during the day. The player will sober up only the next night.'**
  String get roleBarmanDescription;

  /// No description provided for @roleInformantDescription.
  ///
  /// In en, this message translates to:
  /// **'The informant is a player of the mafia team. The mafia does not know who the informant is. At night, the informant can check any player and reveal his role. He can also send messages to the mafia chat, and the spy will also see the informant\'s messages, but the mafioso and the spy will not see the nickname and photo of the informant. If all the mafiosi die, then the informant can vote for the player who will die at night.'**
  String get roleInformantDescription;

  /// No description provided for @roleCitizenDescription.
  ///
  /// In en, this message translates to:
  /// **'Civilians are tasked with identifying mafia players. They have no special abilities. All they can do is discuss and vote on who to kill in the day\'s vote.'**
  String get roleCitizenDescription;

  /// No description provided for @roleDoctorDescription.
  ///
  /// In en, this message translates to:
  /// **'The Doctor is a civilian. The Doctor can save one of the players from death at night if he is killed that night. When night comes, he chooses who he will treat.'**
  String get roleDoctorDescription;

  /// No description provided for @roleSheriffDescription.
  ///
  /// In en, this message translates to:
  /// **'The Sheriff is a civilian. He is one of the most important players in the Mafia game. Every night he can examine another player and find out who is a Mafioso in the game and who is a civilian.'**
  String get roleSheriffDescription;

  /// No description provided for @roleMistressDescription.
  ///
  /// In en, this message translates to:
  /// **'The Beauty is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Beauty came cannot use his ability at night, and also will not be able to vote the next day. The Beauty\'s love spell wears off only on next night.'**
  String get roleMistressDescription;

  /// No description provided for @roleJournalistDescription.
  ///
  /// In en, this message translates to:
  /// **'Journalist - plays on the side of the civilians. At night, he has the opportunity to conduct an investigation and check any two players, whether they play on the same team or on different ones. All players will see the result of the investigation in the news.'**
  String get roleJournalistDescription;

  /// No description provided for @roleBodyguardDescription.
  ///
  /// In en, this message translates to:
  /// **'Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a terrorist explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Terrorist or Mafioso will decide to kill at night. The Bodyguard\'s protection only applies once, either during the day or at night, if the terrorist did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia\'s shot.'**
  String get roleBodyguardDescription;

  /// No description provided for @roleSpyDescription.
  ///
  /// In en, this message translates to:
  /// **'A spy is a civilian. He sees what the mafia talks about at night, but does not see the personalities of the mafia.'**
  String get roleSpyDescription;

  /// No description provided for @rulesDescription.
  ///
  /// In en, this message translates to:
  /// **'The players are divided into two teams: civilians who do not know each other, and the Mafia team, which is in the minority but knows each other. \n\nIn a civilian team, players can have special statuses. For example, among civilians, as a rule, there is a Sheriff and a Doctor\n\nThe gameplay is divided into two phases - \"day\" and \"night\".\n\nAt night the mafia wakes up, \"consults\" and kills one from the surviving townspeople by voting. The resident who receives the most votes dies at night.\n\nIf the votes are divided equally, the victim is chosen at random.\n\nIf none of the Mafiosi voted, everyone remains alive.\n\nAt the same time, the Sheriff and the Doctor wake up. The sheriff chooses one of the residents whom he wants to “test” for involvement in the mafia. The doctor chooses who he will treat.\n\nIf the doctor cured the player who was voted for by the Mafiosi, the player remains alive. But if there is more than one mafioso in the game, they can vote for multiple players. Thus, if the doctor treated one of them, the next one with the most votes will die.\n\nWhen day comes, it is announced who was killed during the night. The killed player is eliminated from the game, having the right to a final farewell message.\n\nDuring the day, players discuss which of them may be “dishonest” - involved in the mafia. At the end of the discussion, all players vote who they want to kill in the daily vote.\n\nThe most suspicious resident with the most votes dies.\n\nIf the votes are evenly divided, the victim is chosen at random. If no one voted, everyone remains alive.\n\nThe killed player is eliminated from the game, having the right to the last, farewell message.\n\nVictory is awarded after the complete destruction of one of the teams.\n\nIf all civilians are killed, the Mafia wins.\n\nAccordingly, in the event of the death of all Mafiosi - civilians win.'**
  String get rulesDescription;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get experience;

  /// No description provided for @gamesPlayed.
  ///
  /// In en, this message translates to:
  /// **'Games Played'**
  String get gamesPlayed;

  /// No description provided for @gamesWon.
  ///
  /// In en, this message translates to:
  /// **'Games Won'**
  String get gamesWon;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @searchFriends.
  ///
  /// In en, this message translates to:
  /// **'Search friends'**
  String get searchFriends;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get online;

  /// No description provided for @sendRequest.
  ///
  /// In en, this message translates to:
  /// **'Send request'**
  String get sendRequest;

  /// No description provided for @requestAlredySent.
  ///
  /// In en, this message translates to:
  /// **'Request alredy sent'**
  String get requestAlredySent;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePassword;

  /// No description provided for @oldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @changeNickname.
  ///
  /// In en, this message translates to:
  /// **'Change nickname'**
  String get changeNickname;

  /// No description provided for @writeNewNickname.
  ///
  /// In en, this message translates to:
  /// **'Write new nickname'**
  String get writeNewNickname;

  /// No description provided for @changeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change avatar'**
  String get changeAvatar;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @deleteAccaunt.
  ///
  /// In en, this message translates to:
  /// **'Delete accaunt'**
  String get deleteAccaunt;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @dontHaveAccauntRegister.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an accaunt? Sign up'**
  String get dontHaveAccauntRegister;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccauntSigIn.
  ///
  /// In en, this message translates to:
  /// **'Alredy have an accaunt? Sign In'**
  String get alreadyHaveAccauntSigIn;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @gameStarted.
  ///
  /// In en, this message translates to:
  /// **'Game Started'**
  String get gameStarted;

  /// No description provided for @gatheringPlayers.
  ///
  /// In en, this message translates to:
  /// **'Gathering Players'**
  String get gatheringPlayers;

  /// No description provided for @alive.
  ///
  /// In en, this message translates to:
  /// **'Alive'**
  String get alive;

  /// No description provided for @dead.
  ///
  /// In en, this message translates to:
  /// **'Dead'**
  String get dead;

  /// No description provided for @createGame.
  ///
  /// In en, this message translates to:
  /// **'Create Game'**
  String get createGame;

  /// No description provided for @passwordOptional.
  ///
  /// In en, this message translates to:
  /// **'Password (Optional)'**
  String get passwordOptional;

  /// No description provided for @roomName.
  ///
  /// In en, this message translates to:
  /// **'Room Name'**
  String get roomName;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @friendInTheRoom.
  ///
  /// In en, this message translates to:
  /// **'Friends in the room'**
  String get friendInTheRoom;

  /// No description provided for @onlyRoomsWithAvailableSpace.
  ///
  /// In en, this message translates to:
  /// **'Only rooms with available space'**
  String get onlyRoomsWithAvailableSpace;

  /// No description provided for @roomsWithoutAPassword.
  ///
  /// In en, this message translates to:
  /// **'Rooms without a password'**
  String get roomsWithoutAPassword;

  /// No description provided for @roomsWithAPassword.
  ///
  /// In en, this message translates to:
  /// **'Rooms with a password'**
  String get roomsWithAPassword;

  /// No description provided for @additionalRoles.
  ///
  /// In en, this message translates to:
  /// **'Additional Roles'**
  String get additionalRoles;

  /// No description provided for @roomsWithourAdditionalRoles.
  ///
  /// In en, this message translates to:
  /// **'Rooms without additional roles'**
  String get roomsWithourAdditionalRoles;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @remainingTime.
  ///
  /// In en, this message translates to:
  /// **'Remaining time'**
  String get remainingTime;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @playersInRoom.
  ///
  /// In en, this message translates to:
  /// **'Players in the Room'**
  String get playersInRoom;

  /// No description provided for @enterMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter message'**
  String get enterMessage;

  /// No description provided for @alreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAnAccount;

  /// No description provided for @youMustWriteYourNickname.
  ///
  /// In en, this message translates to:
  /// **'You must write your nickname'**
  String get youMustWriteYourNickname;

  /// No description provided for @yourNicknameMustContainAtLeast3Characters.
  ///
  /// In en, this message translates to:
  /// **'Your nickname must contain at least 3 characters'**
  String get yourNicknameMustContainAtLeast3Characters;

  /// No description provided for @yourNicknameCanContainLettersNumbersAnd.
  ///
  /// In en, this message translates to:
  /// **'Your nickname can contain, letters, numbers and . _ -'**
  String get yourNicknameCanContainLettersNumbersAnd;

  /// No description provided for @youMustWriteYourEmail.
  ///
  /// In en, this message translates to:
  /// **'You must write your email'**
  String get youMustWriteYourEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter valid email'**
  String get enterValidEmail;

  /// No description provided for @youMustWriteYourPassword.
  ///
  /// In en, this message translates to:
  /// **'You must write your password'**
  String get youMustWriteYourPassword;

  /// No description provided for @yourPasswordMustContainAtLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'Your password must contain at least 6 characters'**
  String get yourPasswordMustContainAtLeast6Characters;

  /// No description provided for @youMustConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'You must confirm your password'**
  String get youMustConfirmYourPassword;

  /// No description provided for @passwordsAreNotMatching.
  ///
  /// In en, this message translates to:
  /// **'Passwords are not matching'**
  String get passwordsAreNotMatching;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @sorryConnectionWithServerTimeouted.
  ///
  /// In en, this message translates to:
  /// **'Sorry, connection with server timeouted...'**
  String get sorryConnectionWithServerTimeouted;

  /// No description provided for @playerWithThisEmailAlreadyExist.
  ///
  /// In en, this message translates to:
  /// **'Player with this email already exist'**
  String get playerWithThisEmailAlreadyExist;

  /// No description provided for @playerWithThisNicknameAlreadyExist.
  ///
  /// In en, this message translates to:
  /// **'Player with this nickname already exist'**
  String get playerWithThisNicknameAlreadyExist;

  /// No description provided for @sorrySomethingBadHappened.
  ///
  /// In en, this message translates to:
  /// **'Sorry, Something bad happened...'**
  String get sorrySomethingBadHappened;

  /// No description provided for @userWithThisEmailDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'User with this email does not exist'**
  String get userWithThisEmailDoesNotExist;

  /// No description provided for @emailOrPasswordIsInvalid.
  ///
  /// In en, this message translates to:
  /// **'Email or Password is invalid'**
  String get emailOrPasswordIsInvalid;

  /// No description provided for @dontHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAnAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPassword;

  /// No description provided for @playersInTheRoom.
  ///
  /// In en, this message translates to:
  /// **'Players in the room'**
  String get playersInTheRoom;

  /// No description provided for @civilian.
  ///
  /// In en, this message translates to:
  /// **'Civilian '**
  String get civilian;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @isYourDestiny.
  ///
  /// In en, this message translates to:
  /// **'is your destiny'**
  String get isYourDestiny;

  /// No description provided for @useSkill.
  ///
  /// In en, this message translates to:
  /// **'Use Skill'**
  String get useSkill;

  /// No description provided for @civiliansAreWithUs.
  ///
  /// In en, this message translates to:
  /// **'civilians are with us'**
  String get civiliansAreWithUs;

  /// No description provided for @bombard.
  ///
  /// In en, this message translates to:
  /// **'Bombard'**
  String get bombard;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @myMoveIsMade.
  ///
  /// In en, this message translates to:
  /// **'My move is made'**
  String get myMoveIsMade;

  /// No description provided for @iAcceptTheWeightOfMyChoice.
  ///
  /// In en, this message translates to:
  /// **'I accept the weight of my choice'**
  String get iAcceptTheWeightOfMyChoice;

  /// No description provided for @cure.
  ///
  /// In en, this message translates to:
  /// **'Cure'**
  String get cure;

  /// No description provided for @satisfy.
  ///
  /// In en, this message translates to:
  /// **'Satisfy'**
  String get satisfy;

  /// No description provided for @protect.
  ///
  /// In en, this message translates to:
  /// **'Protect'**
  String get protect;

  /// No description provided for @intoxicate.
  ///
  /// In en, this message translates to:
  /// **'Intoxicate'**
  String get intoxicate;

  /// No description provided for @reveale.
  ///
  /// In en, this message translates to:
  /// **'Reveale'**
  String get reveale;

  /// No description provided for @investigate.
  ///
  /// In en, this message translates to:
  /// **'Investigate'**
  String get investigate;

  /// No description provided for @interview.
  ///
  /// In en, this message translates to:
  /// **'Interview'**
  String get interview;

  /// No description provided for @mafias.
  ///
  /// In en, this message translates to:
  /// **'mafias'**
  String get mafias;

  /// No description provided for @civilians.
  ///
  /// In en, this message translates to:
  /// **'civilians'**
  String get civilians;

  /// No description provided for @pickYourTarget.
  ///
  /// In en, this message translates to:
  /// **'Pick your target'**
  String get pickYourTarget;

  /// No description provided for @iveChosenNoRegrets.
  ///
  /// In en, this message translates to:
  /// **'I\'ve chosen. No regrets'**
  String get iveChosenNoRegrets;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @enterTheMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the message...'**
  String get enterTheMessage;

  /// No description provided for @lobby.
  ///
  /// In en, this message translates to:
  /// **'Lobby'**
  String get lobby;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **' Search...'**
  String get search;

  /// No description provided for @filterOff.
  ///
  /// In en, this message translates to:
  /// **'Filter Off'**
  String get filterOff;

  /// No description provided for @noAvailableGames.
  ///
  /// In en, this message translates to:
  /// **'No available games..'**
  String get noAvailableGames;

  /// No description provided for @youArePlayingHere.
  ///
  /// In en, this message translates to:
  /// **'You Are Playing Here'**
  String get youArePlayingHere;

  /// No description provided for @youDiedHere.
  ///
  /// In en, this message translates to:
  /// **'You Died Here'**
  String get youDiedHere;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @allPlayers.
  ///
  /// In en, this message translates to:
  /// **'All Players'**
  String get allPlayers;

  /// No description provided for @areHere.
  ///
  /// In en, this message translates to:
  /// **'are here'**
  String get areHere;

  /// No description provided for @defeated.
  ///
  /// In en, this message translates to:
  /// **'Defeated'**
  String get defeated;

  /// No description provided for @stillHere.
  ///
  /// In en, this message translates to:
  /// **'Still here'**
  String get stillHere;

  /// No description provided for @enterTheName.
  ///
  /// In en, this message translates to:
  /// **' Enter the name'**
  String get enterTheName;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'on'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'off'**
  String get off;

  /// No description provided for @enterThePassword.
  ///
  /// In en, this message translates to:
  /// **' Enter the password'**
  String get enterThePassword;

  /// No description provided for @numberOfPlayers.
  ///
  /// In en, this message translates to:
  /// **'Number of players'**
  String get numberOfPlayers;

  /// No description provided for @extraRoles.
  ///
  /// In en, this message translates to:
  /// **'Extra Roles'**
  String get extraRoles;

  /// No description provided for @beauty.
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get beauty;

  /// No description provided for @bartender.
  ///
  /// In en, this message translates to:
  /// **'Bartender'**
  String get bartender;

  /// No description provided for @roomsWith.
  ///
  /// In en, this message translates to:
  /// **'Rooms with:'**
  String get roomsWith;

  /// No description provided for @availableSpots.
  ///
  /// In en, this message translates to:
  /// **'Available Spots'**
  String get availableSpots;

  /// No description provided for @friendsIn.
  ///
  /// In en, this message translates to:
  /// **'Friends In'**
  String get friendsIn;

  /// No description provided for @access.
  ///
  /// In en, this message translates to:
  /// **'Access'**
  String get access;

  /// No description provided for @mixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get mixed;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get private;

  /// No description provided for @includedRoles.
  ///
  /// In en, this message translates to:
  /// **'Included roles:'**
  String get includedRoles;

  /// No description provided for @lover.
  ///
  /// In en, this message translates to:
  /// **'Lover'**
  String get lover;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting:'**
  String get starting;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// No description provided for @trustedIndividuals.
  ///
  /// In en, this message translates to:
  /// **'TRUSTED INDIVIDUALS'**
  String get trustedIndividuals;

  /// No description provided for @justiceRidesWithUs.
  ///
  /// In en, this message translates to:
  /// **'Justice rides with us.'**
  String get justiceRidesWithUs;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @noFriendsFound.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get noFriendsFound;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @registry.
  ///
  /// In en, this message translates to:
  /// **'REGISTRY'**
  String get registry;

  /// No description provided for @ofChoosenOnes.
  ///
  /// In en, this message translates to:
  /// **'OF CHOOSEN ONES'**
  String get ofChoosenOnes;

  /// No description provided for @onlyTheTruestRideTogether.
  ///
  /// In en, this message translates to:
  /// **'Only the truest ride together.'**
  String get onlyTheTruestRideTogether;

  /// No description provided for @noPlayersFound.
  ///
  /// In en, this message translates to:
  /// **'No players found'**
  String get noPlayersFound;

  /// No description provided for @noRequestsFound.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequestsFound;

  /// No description provided for @wanted.
  ///
  /// In en, this message translates to:
  /// **'WANTED:'**
  String get wanted;

  /// No description provided for @goodCompany.
  ///
  /// In en, this message translates to:
  /// **'GOOD COMPANY'**
  String get goodCompany;

  /// No description provided for @ridingSoloAintTheWay.
  ///
  /// In en, this message translates to:
  /// **'Riding solo ain\'t the way.'**
  String get ridingSoloAintTheWay;

  /// No description provided for @requestPending.
  ///
  /// In en, this message translates to:
  /// **'Request Pending'**
  String get requestPending;

  /// No description provided for @approvePending.
  ///
  /// In en, this message translates to:
  /// **'Approve Pending'**
  String get approvePending;

  /// No description provided for @classic.
  ///
  /// In en, this message translates to:
  /// **'classic'**
  String get classic;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome,'**
  String get welcome;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @joinDate.
  ///
  /// In en, this message translates to:
  /// **'Join Date'**
  String get joinDate;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @addToFriends.
  ///
  /// In en, this message translates to:
  /// **'Add To Friends'**
  String get addToFriends;

  /// No description provided for @currentlyOffline.
  ///
  /// In en, this message translates to:
  /// **'Currently Offline'**
  String get currentlyOffline;

  /// No description provided for @currentlyAreNotPlaying.
  ///
  /// In en, this message translates to:
  /// **'Currently are not playing'**
  String get currentlyAreNotPlaying;

  /// No description provided for @currentlyArePlayingIn.
  ///
  /// In en, this message translates to:
  /// **'Currently are playing in:'**
  String get currentlyArePlayingIn;

  /// No description provided for @playersInTotal.
  ///
  /// In en, this message translates to:
  /// **'Players in total'**
  String get playersInTotal;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @wins.
  ///
  /// In en, this message translates to:
  /// **'Wins'**
  String get wins;

  /// No description provided for @loses.
  ///
  /// In en, this message translates to:
  /// **'Loses'**
  String get loses;

  /// No description provided for @mafiaWins.
  ///
  /// In en, this message translates to:
  /// **'Mafia Wins'**
  String get mafiaWins;

  /// No description provided for @civilianWins.
  ///
  /// In en, this message translates to:
  /// **'Civilian Wins'**
  String get civilianWins;

  /// No description provided for @playedRoles.
  ///
  /// In en, this message translates to:
  /// **'Played Roles'**
  String get playedRoles;

  /// No description provided for @avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @onOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get onOn;

  /// No description provided for @offOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offOff;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @currentAvatar.
  ///
  /// In en, this message translates to:
  /// **'Current Avatar'**
  String get currentAvatar;

  /// No description provided for @uploadNew.
  ///
  /// In en, this message translates to:
  /// **'Upload New'**
  String get uploadNew;

  /// No description provided for @uploadAnother.
  ///
  /// In en, this message translates to:
  /// **'Upload Another'**
  String get uploadAnother;

  /// No description provided for @currentNickname.
  ///
  /// In en, this message translates to:
  /// **'Current Nickname'**
  String get currentNickname;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @youMustWriteATitleOfTheReport.
  ///
  /// In en, this message translates to:
  /// **'You must write a title of the report'**
  String get youMustWriteATitleOfTheReport;

  /// No description provided for @typeHere.
  ///
  /// In en, this message translates to:
  /// **'Type here'**
  String get typeHere;

  /// No description provided for @inCaseOfAnyProblemPleaseNotifyUs.
  ///
  /// In en, this message translates to:
  /// **'In case of any problem, please notify us'**
  String get inCaseOfAnyProblemPleaseNotifyUs;

  /// No description provided for @recover.
  ///
  /// In en, this message translates to:
  /// **'Recover'**
  String get recover;

  /// No description provided for @writeDownTheEmailToGetACode.
  ///
  /// In en, this message translates to:
  /// **'Write down the email to get a code'**
  String get writeDownTheEmailToGetACode;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @youMustWriteTheSmsCode.
  ///
  /// In en, this message translates to:
  /// **'You must write the SMS code'**
  String get youMustWriteTheSmsCode;

  /// No description provided for @sms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get sms;

  /// No description provided for @codeMustBeNumeric.
  ///
  /// In en, this message translates to:
  /// **'Code must be numeric'**
  String get codeMustBeNumeric;

  /// No description provided for @codeMustBe6Charactes.
  ///
  /// In en, this message translates to:
  /// **'Code must be 6 charactes'**
  String get codeMustBe6Charactes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['az', 'en', 'ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'az':
      return AppLocalizationsAz();
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
