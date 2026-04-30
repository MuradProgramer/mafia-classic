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

  /// No description provided for @kamikaze.
  ///
  /// In en, this message translates to:
  /// **'Kamikaze'**
  String get kamikaze;

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

  /// No description provided for @roleKamikazeDescription.
  ///
  /// In en, this message translates to:
  /// **'Kamikaze - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the kamikaze does not know the identity of the Mafia members. The Kamikaze has one special ability. At any time during the day voting, the kamikaze can blow up anyone player by killing both himself and the victim. The kamikaze cannot be killed by the mafia at night. So the kamikaze must help the mafia win using his life. Regardless of whether the kamikaze is killed, he will receive experience points at the end of the game if. The mafia will win.'**
  String get roleKamikazeDescription;

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
  /// **'Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a kamikaze explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Kamikaze or Mafioso will decide to kill at night. The Bodyguard\'s protection only applies once, either during the day or at night, if the kamikaze did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia\'s shot.'**
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
  /// **'Type here'**
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
  /// **'Skill'**
  String get useSkill;

  /// No description provided for @civiliansAreWithUs.
  ///
  /// In en, this message translates to:
  /// **'civilians are with us'**
  String get civiliansAreWithUs;

  /// No description provided for @bombard.
  ///
  /// In en, this message translates to:
  /// **'Explode'**
  String get bombard;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get vote;

  /// No description provided for @myMoveIsMade.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get myMoveIsMade;

  /// No description provided for @iAcceptTheWeightOfMyChoice.
  ///
  /// In en, this message translates to:
  /// **'I accept the weight of my choice'**
  String get iAcceptTheWeightOfMyChoice;

  /// No description provided for @cure.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get cure;

  /// No description provided for @satisfy.
  ///
  /// In en, this message translates to:
  /// **'Charm'**
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
  /// **'Reveal'**
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
  /// **'Mafias'**
  String get mafias;

  /// No description provided for @civilians.
  ///
  /// In en, this message translates to:
  /// **'Civilians'**
  String get civilians;

  /// No description provided for @pickYourTarget.
  ///
  /// In en, this message translates to:
  /// **'Choose a Victim'**
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
  /// **' Search'**
  String get search;

  /// No description provided for @filterOff.
  ///
  /// In en, this message translates to:
  /// **'Filter Off'**
  String get filterOff;

  /// No description provided for @noAvailableGames.
  ///
  /// In en, this message translates to:
  /// **'No active games yet… Create one and invite your friends!'**
  String get noAvailableGames;

  /// No description provided for @youArePlayingHere.
  ///
  /// In en, this message translates to:
  /// **'You are playing in this room'**
  String get youArePlayingHere;

  /// No description provided for @youDiedHere.
  ///
  /// In en, this message translates to:
  /// **'You died in this room'**
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
  /// **'roles'**
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
  /// **'Extra Roles:'**
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
  /// **'Waiting For Players'**
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
  /// **'Forward only together'**
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
  /// **'Welcome'**
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
  /// **'Statistics'**
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
  /// **'Losses'**
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

  /// No description provided for @gameKamikazeExplosion.
  ///
  /// In en, this message translates to:
  /// **'Kamikaze tried to bomb [{playerNickname}], but bodyguard saved him/her'**
  String gameKamikazeExplosion(String playerNickname);

  /// No description provided for @timeForDecision.
  ///
  /// In en, this message translates to:
  /// **'Town\'s decision - '**
  String get timeForDecision;

  /// No description provided for @skillsDescriptionsBeauty.
  ///
  /// In en, this message translates to:
  /// **'Choose a player to charm. They will be unable to vote or use their ability'**
  String get skillsDescriptionsBeauty;

  /// No description provided for @skillsDescriptionsBodyguard.
  ///
  /// In en, this message translates to:
  /// **'Choose a player to protect from the Mafia and the Kamikaze'**
  String get skillsDescriptionsBodyguard;

  /// No description provided for @skillsDescriptionsBarman.
  ///
  /// In en, this message translates to:
  /// **'Choose a player to intoxicate. They will be unable to vote, speak, or use their ability'**
  String get skillsDescriptionsBarman;

  /// No description provided for @skillsDescriptionsDoctor.
  ///
  /// In en, this message translates to:
  /// **'Choose a player to save from a Mafia attack'**
  String get skillsDescriptionsDoctor;

  /// No description provided for @skillsDescriptionsInformant.
  ///
  /// In en, this message translates to:
  /// **'Choose a player to reveal their role'**
  String get skillsDescriptionsInformant;

  /// No description provided for @skillsDescriptionsSheriff.
  ///
  /// In en, this message translates to:
  /// **'Choose a player to investigate and learn their role'**
  String get skillsDescriptionsSheriff;

  /// No description provided for @skillsDescriptionsJournalist.
  ///
  /// In en, this message translates to:
  /// **'Choose two players to find out if they are on the same team'**
  String get skillsDescriptionsJournalist;

  /// No description provided for @hasJoined.
  ///
  /// In en, this message translates to:
  /// **'has joined'**
  String get hasJoined;

  /// No description provided for @hasLeft.
  ///
  /// In en, this message translates to:
  /// **'has left'**
  String get hasLeft;

  /// No description provided for @rolesGeneralDescriptionMafia.
  ///
  /// In en, this message translates to:
  /// **'You are Mafia and play for the mafia team. Your task is to eliminate civilians through deception during day voting and night kills together with your team'**
  String get rolesGeneralDescriptionMafia;

  /// No description provided for @rolesGeneralDescriptionCivilian.
  ///
  /// In en, this message translates to:
  /// **'You are a Civilian and play for the civilian team. Your task is to identify all mafia members and vote against them, helping the civilians achieve victory'**
  String get rolesGeneralDescriptionCivilian;

  /// No description provided for @rolesGeneralDescriptionSpy.
  ///
  /// In en, this message translates to:
  /// **'You are a Spy and play for the civilian team. Eavesdrop on mafia conversations and share useful information with the civilians to expose the mafia'**
  String get rolesGeneralDescriptionSpy;

  /// No description provided for @rolesGeneralDescriptionDoctor.
  ///
  /// In en, this message translates to:
  /// **'You are a Doctor and play for the civilian team. Use your medical skills to save civilians from night mafia attacks'**
  String get rolesGeneralDescriptionDoctor;

  /// No description provided for @rolesGeneralDescriptionBeauty.
  ///
  /// In en, this message translates to:
  /// **'You are the Beauty and play for the civilian team. Use your charm to distract the mafia, preventing them from using abilities and participating in voting'**
  String get rolesGeneralDescriptionBeauty;

  /// No description provided for @rolesGeneralDescriptionBodyguard.
  ///
  /// In en, this message translates to:
  /// **'You are a Bodyguard and play for the civilian team. Use your skills to protect civilians from kamikaze or mafia attacks'**
  String get rolesGeneralDescriptionBodyguard;

  /// No description provided for @rolesGeneralDescriptionInformant.
  ///
  /// In en, this message translates to:
  /// **'You are the Informant and play for the mafia team. You don\'t know the mafia, and they don\'t know you. Reveal civilian roles and communicate anonymously with the mafia, passing on vital information'**
  String get rolesGeneralDescriptionInformant;

  /// No description provided for @rolesGeneralDescriptionSheriff.
  ///
  /// In en, this message translates to:
  /// **'You are the Sheriff and play for the civilian team. Your task is to investigate players and identify mafia members'**
  String get rolesGeneralDescriptionSheriff;

  /// No description provided for @rolesGeneralDescriptionJournalist.
  ///
  /// In en, this message translates to:
  /// **'You are a Journalist and play for the civilian team. Every night, conduct interviews with two players so everyone finds out if they are on the same team or different ones'**
  String get rolesGeneralDescriptionJournalist;

  /// No description provided for @rolesGeneralDescriptionKamikaze.
  ///
  /// In en, this message translates to:
  /// **'You are the Kamikaze and play for the mafia team. You don\'t know the mafia, but the mafia knows you. During the day voting, you can blow up a civilian, dying along with them'**
  String get rolesGeneralDescriptionKamikaze;

  /// No description provided for @rolesGeneralDescriptionBarman.
  ///
  /// In en, this message translates to:
  /// **'You are the Barman and play for the mafia team. You don\'t know the mafia, and they don\'t know you. Use your bartending skills to intoxicate civilians'**
  String get rolesGeneralDescriptionBarman;

  /// No description provided for @rolesObjectiveMafia.
  ///
  /// In en, this message translates to:
  /// **'Eliminate all civilians'**
  String get rolesObjectiveMafia;

  /// No description provided for @rolesObjectiveVicilian.
  ///
  /// In en, this message translates to:
  /// **'Eliminate all mafia members'**
  String get rolesObjectiveVicilian;

  /// No description provided for @rolesObjectiveSpy.
  ///
  /// In en, this message translates to:
  /// **'Help the civilians eliminate all mafia members by eavesdropping on their nightly conversations'**
  String get rolesObjectiveSpy;

  /// No description provided for @rolesObjectiveDoctor.
  ///
  /// In en, this message translates to:
  /// **'Help the civilians eliminate all mafia members by saving them from mafia attacks'**
  String get rolesObjectiveDoctor;

  /// No description provided for @rolesObjectiveBeauty.
  ///
  /// In en, this message translates to:
  /// **'Help the civilians eliminate all mafia members by distracting mafia members'**
  String get rolesObjectiveBeauty;

  /// No description provided for @rolesObjectiveBodyguard.
  ///
  /// In en, this message translates to:
  /// **'Help the civilians eliminate all mafia members by protecting civilians from kamikaze and mafia members'**
  String get rolesObjectiveBodyguard;

  /// No description provided for @rolesObjectiveBarman.
  ///
  /// In en, this message translates to:
  /// **'Help the mafia members eliminate civilians by getting them drunk'**
  String get rolesObjectiveBarman;

  /// No description provided for @rolesObjectiveInformant.
  ///
  /// In en, this message translates to:
  /// **'Help the mafia members eliminate civilians by passing important information to them'**
  String get rolesObjectiveInformant;

  /// No description provided for @rolesObjectiveSheriff.
  ///
  /// In en, this message translates to:
  /// **'Help the civilians eliminate all mafia members by identifying mafia members'**
  String get rolesObjectiveSheriff;

  /// No description provided for @rolesObjectiveJournalist.
  ///
  /// In en, this message translates to:
  /// **'Help the civilians eliminate all mafia members by conducting daily reports'**
  String get rolesObjectiveJournalist;

  /// No description provided for @rolesObjectiveKamikaze.
  ///
  /// In en, this message translates to:
  /// **'Help the mafia members eliminate civilians by detonating an important civilian'**
  String get rolesObjectiveKamikaze;

  /// No description provided for @rolesDayPhaseMafia.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, steer the conversation in the mafia\'s favour'**
  String get rolesDayPhaseMafia;

  /// No description provided for @rolesDayPhaseCivilian.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, guide the conversation and support the civilians'**
  String get rolesDayPhaseCivilian;

  /// No description provided for @rolesDayPhaseSpy.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, guide the conversation and support the civilians'**
  String get rolesDayPhaseSpy;

  /// No description provided for @rolesDayPhaseDoctor.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, guide the conversation and support the civilians'**
  String get rolesDayPhaseDoctor;

  /// No description provided for @rolesDayPhaseBeauty.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, guide the conversation and support the civilians'**
  String get rolesDayPhaseBeauty;

  /// No description provided for @rolesDayPhaseBodyguard.
  ///
  /// In en, this message translates to:
  /// **'Each day you can choose a player to protect from a Kamikaze or Mafia attack'**
  String get rolesDayPhaseBodyguard;

  /// No description provided for @rolesDayPhaseBarman.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, steer the conversation in the mafia\'s favour'**
  String get rolesDayPhaseBarman;

  /// No description provided for @rolesDayPhaseInformant.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, steer the conversation in the mafia\'s favour'**
  String get rolesDayPhaseInformant;

  /// No description provided for @rolesDayPhaseSheriff.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, take the initiative and lead the civilians to victory'**
  String get rolesDayPhaseSheriff;

  /// No description provided for @rolesDayPhaseJournalist.
  ///
  /// In en, this message translates to:
  /// **'Participate in discussions and voting, guide the conversation and support the civilians'**
  String get rolesDayPhaseJournalist;

  /// No description provided for @rolesDayPhaseKamikaze.
  ///
  /// In en, this message translates to:
  /// **'You can participate in discussions but are not allowed to vote. During the day voting, you can blow up a player, however, if a Bodyguard protects them, you will die taking only the Bodyguard with you'**
  String get rolesDayPhaseKamikaze;

  /// No description provided for @skill.
  ///
  /// In en, this message translates to:
  /// **'Skill'**
  String get skill;

  /// No description provided for @rolesThirdDescriptionMafia.
  ///
  /// In en, this message translates to:
  /// **'Every night the Mafia gathers, discusses and chooses one player to eliminate. Spy can see your night conversations, but does not know who exactly is sending them'**
  String get rolesThirdDescriptionMafia;

  /// No description provided for @rolesThirdDescriptionCivilian.
  ///
  /// In en, this message translates to:
  /// **'There is nothing for you to do at night, just rest'**
  String get rolesThirdDescriptionCivilian;

  /// No description provided for @rolesThirdDescriptionSpy.
  ///
  /// In en, this message translates to:
  /// **'At night you can eavesdrop on the conversations of Mafia and Informant, but their identities remain unknown'**
  String get rolesThirdDescriptionSpy;

  /// No description provided for @rolesThirdDescriptionDoctor.
  ///
  /// In en, this message translates to:
  /// **'Every night you can save one player chosen by the Mafia for attack. If you choose the right player, their life will be spared'**
  String get rolesThirdDescriptionDoctor;

  /// No description provided for @rolesThirdDescriptionBodyguard.
  ///
  /// In en, this message translates to:
  /// **'The player you chose during the day remains under your protection throughout the night against Mafia attacks'**
  String get rolesThirdDescriptionBodyguard;

  /// No description provided for @rolesThirdDescriptionBarman.
  ///
  /// In en, this message translates to:
  /// **'Every night you can intoxicate one player. The intoxicated player will be unable to vote, use abilities or speak clearly until the next night'**
  String get rolesThirdDescriptionBarman;

  /// No description provided for @rolesThirdDescriptionInformant.
  ///
  /// In en, this message translates to:
  /// **'Every night you can reveal the role of one player and communicate with the Mafia. Mafia and Spy can see your messages, but your identity remains hidden'**
  String get rolesThirdDescriptionInformant;

  /// No description provided for @rolesThirdDescriptionSheriff.
  ///
  /// In en, this message translates to:
  /// **'Every night you can investigate one player to find out their role'**
  String get rolesThirdDescriptionSheriff;

  /// No description provided for @rolesThirdDescriptionJournalist.
  ///
  /// In en, this message translates to:
  /// **'Every night you can interview two players to find out if they are on the same team. The results are visible to everyone in the chat'**
  String get rolesThirdDescriptionJournalist;

  /// No description provided for @rolesThirdDescriptionKamikaze.
  ///
  /// In en, this message translates to:
  /// **'There is nothing for you to do at night, just rest'**
  String get rolesThirdDescriptionKamikaze;

  /// No description provided for @rolesThirdDescriptionBeauty.
  ///
  /// In en, this message translates to:
  /// **'Every night you can charm one player. The distracted player will be unable to vote or use their abilities until the next night'**
  String get rolesThirdDescriptionBeauty;

  /// No description provided for @rolesWinningConditionMafia.
  ///
  /// In en, this message translates to:
  /// **'You win when no civilians are left alive'**
  String get rolesWinningConditionMafia;

  /// No description provided for @rolesWinningConditionsCivilian.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsCivilian;

  /// No description provided for @rolesWinningConditionsSpy.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsSpy;

  /// No description provided for @rolesWinningConditionsDoctor.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsDoctor;

  /// No description provided for @rolesWinningConditionsBeauty.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsBeauty;

  /// No description provided for @rolesWinningConditionsBodyguard.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsBodyguard;

  /// No description provided for @rolesWinningConditionsBarman.
  ///
  /// In en, this message translates to:
  /// **'You win when no civilians are left alive'**
  String get rolesWinningConditionsBarman;

  /// No description provided for @rolesWinningConditionsInformant.
  ///
  /// In en, this message translates to:
  /// **'You win when no civilians are left alive'**
  String get rolesWinningConditionsInformant;

  /// No description provided for @rolesWinningConditionsSheriff.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsSheriff;

  /// No description provided for @rolesWinningConditionsJournalist.
  ///
  /// In en, this message translates to:
  /// **'You win when no Mafia members are left alive'**
  String get rolesWinningConditionsJournalist;

  /// No description provided for @rolesWinningConditionsKamikaze.
  ///
  /// In en, this message translates to:
  /// **'You win when no civilians are left alive'**
  String get rolesWinningConditionsKamikaze;

  /// No description provided for @gameplayRules.
  ///
  /// In en, this message translates to:
  /// **'Gameplay Rules:'**
  String get gameplayRules;

  /// No description provided for @objective.
  ///
  /// In en, this message translates to:
  /// **'Objective'**
  String get objective;

  /// No description provided for @dayPhase.
  ///
  /// In en, this message translates to:
  /// **'Day Phase'**
  String get dayPhase;

  /// No description provided for @nightPhase.
  ///
  /// In en, this message translates to:
  /// **'Night Phase'**
  String get nightPhase;

  /// No description provided for @winningConditions.
  ///
  /// In en, this message translates to:
  /// **'Winning Conditions'**
  String get winningConditions;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @itIsYou.
  ///
  /// In en, this message translates to:
  /// **'it is you'**
  String get itIsYou;

  /// No description provided for @uknown.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get uknown;

  /// No description provided for @underTheEffectYouCannotVoteUseAbilitiesAndYour.
  ///
  /// In en, this message translates to:
  /// **'Under the effect: you cannot vote, use abilities, and your messages appear distorted'**
  String get underTheEffectYouCannotVoteUseAbilitiesAndYour;

  /// No description provided for @gameInformationPopupCured.
  ///
  /// In en, this message translates to:
  /// **'You\'re in «safe» hands, the Mafia won\'t be able to harm you tonight'**
  String get gameInformationPopupCured;

  /// No description provided for @gameInformationPopupInterviewed.
  ///
  /// In en, this message translates to:
  /// **'Congratulations — you\'re now the star of the report. Everyone is already debating whether you and the other interviewee are on the same side or not'**
  String get gameInformationPopupInterviewed;

  /// No description provided for @gameInformationPopupIntoxicated.
  ///
  /// In en, this message translates to:
  /// **'Under the effect: you cannot vote or use skills, and your messages appear distorted'**
  String get gameInformationPopupIntoxicated;

  /// No description provided for @gameInformationPopupInvestigated.
  ///
  /// In en, this message translates to:
  /// **'The sheriff entered your details into the system and now they know who you are'**
  String get gameInformationPopupInvestigated;

  /// No description provided for @gameInformationPopupRevealed.
  ///
  /// In en, this message translates to:
  /// **'Now your life depends on how important your role is'**
  String get gameInformationPopupRevealed;

  /// No description provided for @gameInformationPopupProtected.
  ///
  /// In en, this message translates to:
  /// **'While the protection is active, you\'re safe'**
  String get gameInformationPopupProtected;

  /// No description provided for @gameInformationPopupSatisfied.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been enchanted — you cannot vote or use abilities'**
  String get gameInformationPopupSatisfied;

  /// No description provided for @gameInformationPopupTitleCured.
  ///
  /// In en, this message translates to:
  /// **'The Doctor has saved you'**
  String get gameInformationPopupTitleCured;

  /// No description provided for @gameInformationPopupTitleInterviewed.
  ///
  /// In en, this message translates to:
  /// **'The Journalist interviewed you'**
  String get gameInformationPopupTitleInterviewed;

  /// No description provided for @gameInformationPopupTitleIntoxicated.
  ///
  /// In en, this message translates to:
  /// **'The Barman got you drunk'**
  String get gameInformationPopupTitleIntoxicated;

  /// No description provided for @gameInformationPopupTitleInvestigated.
  ///
  /// In en, this message translates to:
  /// **'The Sheriff investigated you'**
  String get gameInformationPopupTitleInvestigated;

  /// No description provided for @gameInformationPopupTitleRevealed.
  ///
  /// In en, this message translates to:
  /// **'The Informant revealed your role'**
  String get gameInformationPopupTitleRevealed;

  /// No description provided for @gameInformationPopupTitleProtected.
  ///
  /// In en, this message translates to:
  /// **'The Bodyguard has protected you'**
  String get gameInformationPopupTitleProtected;

  /// No description provided for @gameInformationPopupTitleSatisfied.
  ///
  /// In en, this message translates to:
  /// **'The Beauty has charm you'**
  String get gameInformationPopupTitleSatisfied;

  /// No description provided for @gameInformationPopupExpirationCured.
  ///
  /// In en, this message translates to:
  /// **'The effect will wear off in one day'**
  String get gameInformationPopupExpirationCured;

  /// No description provided for @gameInformationPopupExpirationInterviewed.
  ///
  /// In en, this message translates to:
  /// **'The effect lasts until the end of the game'**
  String get gameInformationPopupExpirationInterviewed;

  /// No description provided for @gameInformationPopupExpirationIntoxicated.
  ///
  /// In en, this message translates to:
  /// **'The effect will wear off in one day'**
  String get gameInformationPopupExpirationIntoxicated;

  /// No description provided for @gameInformationPopupExpirationInvestigated.
  ///
  /// In en, this message translates to:
  /// **'The effect lasts until the end of the game'**
  String get gameInformationPopupExpirationInvestigated;

  /// No description provided for @gameInformationPopupExpirationRevealed.
  ///
  /// In en, this message translates to:
  /// **'The effect lasts until the end of the game'**
  String get gameInformationPopupExpirationRevealed;

  /// No description provided for @gameInformationPopupExpirationProtected.
  ///
  /// In en, this message translates to:
  /// **'The effect will wear off in one day'**
  String get gameInformationPopupExpirationProtected;

  /// No description provided for @gameInformationPopupExpirationSatisfied.
  ///
  /// In en, this message translates to:
  /// **'The effect will wear off in one day'**
  String get gameInformationPopupExpirationSatisfied;

  /// No description provided for @youMustWriteYourReport.
  ///
  /// In en, this message translates to:
  /// **'You must write your report'**
  String get youMustWriteYourReport;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite Friend'**
  String get inviteFriend;

  /// No description provided for @phaseMessagesDay.
  ///
  /// In en, this message translates to:
  /// **'A new day begins. Talk, question and suspect. The mafia walks among you'**
  String get phaseMessagesDay;

  /// No description provided for @phaseMessageDayVoting.
  ///
  /// In en, this message translates to:
  /// **'Time to decide. Who do you trust least? Cast your vote'**
  String get phaseMessageDayVoting;

  /// No description provided for @phaseMessageNight.
  ///
  /// In en, this message translates to:
  /// **'Night falls over the town. In the darkness, the mafia whispers'**
  String get phaseMessageNight;

  /// No description provided for @phaseMessageNightVoting.
  ///
  /// In en, this message translates to:
  /// **'The mafia never sleeps.. someone\'s fate is being decided right now'**
  String get phaseMessageNightVoting;

  /// ...
  ///
  /// In en, this message translates to:
  /// **'[{nickname}] did not survive the night..'**
  String nicknameDidNotSurviveTheNight(String nickname);

  /// ...
  ///
  /// In en, this message translates to:
  /// **'[{nickname}] was eliminated by the town\'s decision'**
  String nicknameWasEliminatedByTheTownsDecision(String nickname);

  /// ...
  ///
  /// In en, this message translates to:
  /// **'Kamikaze tried to bomb [{targetPlayer}], but Bodyguard saved him/her'**
  String kamikazeTriedToBombTargetplayerButBodyguardSavedHimher(
      String targetPlayer);

  /// ...
  ///
  /// In en, this message translates to:
  /// **'Kamikaze bombarded [{targetPlayer}]'**
  String kamikazeBombardedTargetplayer(String targetPlayer);

  /// ...
  ///
  /// In en, this message translates to:
  /// **'Journalist conducted an interview with [{firstPlayerNickname}] and [{secondPlayerNickname}] — they play on opposite teams'**
  String firstplayernicknameAndSecondplayernicknameAreOnDifferentTeams(
      String firstPlayerNickname, String secondPlayerNickname);

  /// ...
  ///
  /// In en, this message translates to:
  /// **'Journalist conducted an interview with [{firstPlayerNickname}] and [{secondPlayerNickname}] — they play on the same team'**
  String firstplayernicknameAndSecondplayernicknameAreOnSameTeams(
      String firstPlayerNickname, String secondPlayerNickname);

  /// ...
  ///
  /// In en, this message translates to:
  /// **'After your investigation, it seems that [{playerNickname}] is [{playerRole}]'**
  String personalFeedBackToInformantAndSheriff(
      String playerNickname, String playerRole);

  /// No description provided for @inGame.
  ///
  /// In en, this message translates to:
  /// **'in room'**
  String get inGame;

  /// No description provided for @enterTheTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the title'**
  String get enterTheTitle;

  /// No description provided for @gameRoles.
  ///
  /// In en, this message translates to:
  /// **'Game Roles'**
  String get gameRoles;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// No description provided for @filterOn.
  ///
  /// In en, this message translates to:
  /// **'Filter On'**
  String get filterOn;

  /// No description provided for @gameIsFull.
  ///
  /// In en, this message translates to:
  /// **'Game is Full'**
  String get gameIsFull;

  /// No description provided for @enterRoomName.
  ///
  /// In en, this message translates to:
  /// **' Enter room name'**
  String get enterRoomName;

  /// No description provided for @noFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'No friend requests'**
  String get noFriendRequests;

  /// No description provided for @noFriendsToSuggest.
  ///
  /// In en, this message translates to:
  /// **'No friends to suggest'**
  String get noFriendsToSuggest;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'mins ago'**
  String get minsAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'hours ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'days ago'**
  String get daysAgo;

  /// No description provided for @lessThanAMinute.
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get lessThanAMinute;

  /// No description provided for @playerProfile.
  ///
  /// In en, this message translates to:
  /// **'Player Profile'**
  String get playerProfile;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @deleteFriend.
  ///
  /// In en, this message translates to:
  /// **'Delete friend'**
  String get deleteFriend;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get acceptRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get rejectRequest;

  /// No description provided for @cancelRequest.
  ///
  /// In en, this message translates to:
  /// **'Cancel request'**
  String get cancelRequest;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @sentFriendRequest.
  ///
  /// In en, this message translates to:
  /// **' sent friend request'**
  String get sentFriendRequest;

  /// No description provided for @acceptedYourRequest.
  ///
  /// In en, this message translates to:
  /// **' accepted your request'**
  String get acceptedYourRequest;

  /// No description provided for @whoIsNext.
  ///
  /// In en, this message translates to:
  /// **'Who is Next?'**
  String get whoIsNext;

  /// No description provided for @invititationToGame.
  ///
  /// In en, this message translates to:
  /// **'Invititation To Room'**
  String get invititationToGame;

  /// No description provided for @invitedYouToTheGame.
  ///
  /// In en, this message translates to:
  /// **' invited you to the room - '**
  String get invitedYouToTheGame;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @gameInformationPopupLastMafia.
  ///
  /// In en, this message translates to:
  /// **'All Mafia members are dead. As the Informant, you can now participate in the Mafia\'s night voting'**
  String get gameInformationPopupLastMafia;

  /// No description provided for @gameInformationPopupTitleLastMafia.
  ///
  /// In en, this message translates to:
  /// **'Last Mafia'**
  String get gameInformationPopupTitleLastMafia;

  /// No description provided for @gameInformationPopupExpirationLastMafia.
  ///
  /// In en, this message translates to:
  /// **'The effect lasts until the end of the game'**
  String get gameInformationPopupExpirationLastMafia;

  /// No description provided for @youAreNotElligibleToSendMessageRightNow.
  ///
  /// In en, this message translates to:
  /// **'You are not elligible to send message right now'**
  String get youAreNotElligibleToSendMessageRightNow;

  /// No description provided for @theShadowsHaveConsumedYourLight.
  ///
  /// In en, this message translates to:
  /// **'The shadows have consumed your light.'**
  String get theShadowsHaveConsumedYourLight;

  /// No description provided for @youAreDead.
  ///
  /// In en, this message translates to:
  /// **'You are dead'**
  String get youAreDead;

  /// No description provided for @iDeadSituationOneText.
  ///
  /// In en, this message translates to:
  /// **'The mafia chose you as their victim tonight. You did not live to see the morning'**
  String get iDeadSituationOneText;

  /// No description provided for @iDeadSituationTwoText.
  ///
  /// In en, this message translates to:
  /// **'The town voted and pointed at you. You were eliminated by the town\'s decision'**
  String get iDeadSituationTwoText;

  /// No description provided for @iDeadSituationThreeText.
  ///
  /// In en, this message translates to:
  /// **'The kamikaze chose you as their target. The explosion cut your life short'**
  String get iDeadSituationThreeText;

  /// No description provided for @iDeadSituationFourText.
  ///
  /// In en, this message translates to:
  /// **'You blew yourself up along with your target. Your mission ended here'**
  String get iDeadSituationFourText;

  /// No description provided for @nightVotingCanNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'While everyone sleeps, the mafia chooses their victim'**
  String get nightVotingCanNotSendMessage;

  /// No description provided for @nightCanNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Only the mafia can speak during the night'**
  String get nightCanNotSendMessage;

  /// No description provided for @dayVotingCanNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'No one can speak during the day voting'**
  String get dayVotingCanNotSendMessage;

  /// No description provided for @unsupportedFileFormat.
  ///
  /// In en, this message translates to:
  /// **'This file format is not supported for avatars'**
  String get unsupportedFileFormat;

  /// No description provided for @fileIsTooLargeItMustBe200kb.
  ///
  /// In en, this message translates to:
  /// **'The file is too large. Please upload an avatar smaller than 200 KB'**
  String get fileIsTooLargeItMustBe200kb;
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
