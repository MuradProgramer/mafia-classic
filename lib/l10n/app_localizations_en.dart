// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get profile => 'Profile';

  @override
  String get games => 'Games';

  @override
  String get create => 'Create';

  @override
  String get settings => 'Settings';

  @override
  String get roles => 'Roles';

  @override
  String get friends => 'Friends';

  @override
  String get ratings => 'Ratings';

  @override
  String get share => 'Share';

  @override
  String get mafia => 'Mafia';

  @override
  String get terrorist => 'Terrorist';

  @override
  String get barman => 'Barman';

  @override
  String get informant => 'Informant';

  @override
  String get citizen => 'Citizen';

  @override
  String get doctor => 'Doctor';

  @override
  String get sheriff => 'Sheriff';

  @override
  String get mistress => 'Beauty';

  @override
  String get journalist => 'Journalist';

  @override
  String get bodyguard => 'Bodyguard';

  @override
  String get spy => 'Spy';

  @override
  String get rules => 'Rules';

  @override
  String get roleMafiaDescription =>
      'The Mafia is a registered character in the game. Each team of Mafiosi knows the players from their country, unlike the citizens of the world, who do not know who is playing for whom. They wake up at night in order to kill one of the inhabitants of the world, also known like them. Doctor and Sheriff.';

  @override
  String get roleTerroristDescription =>
      'Terrorist - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the terrorist does not know the identity of the Mafia members. The Terrorist has one special ability. At any time during the day voting, the terrorist can blow up anyone player by killing both himself and the victim. The terrorist cannot be killed by the mafia at night. So the terrorist must help the mafia win using his life. Regardless of whether the terrorist is killed, he will receive experience points at the end of the game if. The mafia will win.';

  @override
  String get roleBarmanDescription =>
      'Barman - plays on the side of the mafia team. At night, he can make any player drunk. Thus, a drunk player will write illegible text in the chat, and will also not be able to vote during the day. The player will sober up only the next night.';

  @override
  String get roleInformantDescription =>
      'The informant is a player of the mafia team. The mafia does not know who the informant is. At night, the informant can check any player and reveal his role. He can also send messages to the mafia chat, and the spy will also see the informant\'s messages, but the mafioso and the spy will not see the nickname and photo of the informant. If all the mafiosi die, then the informant can vote for the player who will die at night.';

  @override
  String get roleCitizenDescription =>
      'Civilians are tasked with identifying mafia players. They have no special abilities. All they can do is discuss and vote on who to kill in the day\'s vote.';

  @override
  String get roleDoctorDescription =>
      'The Doctor is a civilian. The Doctor can save one of the players from death at night if he is killed that night. When night comes, he chooses who he will treat.';

  @override
  String get roleSheriffDescription =>
      'The Sheriff is a civilian. He is one of the most important players in the Mafia game. Every night he can examine another player and find out who is a Mafioso in the game and who is a civilian.';

  @override
  String get roleMistressDescription =>
      'The Beauty is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Beauty came cannot use his ability at night, and also will not be able to vote the next day. The Beauty\'s love spell wears off only on next night.';

  @override
  String get roleJournalistDescription =>
      'Journalist - plays on the side of the civilians. At night, he has the opportunity to conduct an investigation and check any two players, whether they play on the same team or on different ones. All players will see the result of the investigation in the news.';

  @override
  String get roleBodyguardDescription =>
      'Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a terrorist explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Terrorist or Mafioso will decide to kill at night. The Bodyguard\'s protection only applies once, either during the day or at night, if the terrorist did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia\'s shot.';

  @override
  String get roleSpyDescription =>
      'A spy is a civilian. He sees what the mafia talks about at night, but does not see the personalities of the mafia.';

  @override
  String get rulesDescription =>
      'The players are divided into two teams: civilians who do not know each other, and the Mafia team, which is in the minority but knows each other. \n\nIn a civilian team, players can have special statuses. For example, among civilians, as a rule, there is a Sheriff and a Doctor\n\nThe gameplay is divided into two phases - \"day\" and \"night\".\n\nAt night the mafia wakes up, \"consults\" and kills one from the surviving townspeople by voting. The resident who receives the most votes dies at night.\n\nIf the votes are divided equally, the victim is chosen at random.\n\nIf none of the Mafiosi voted, everyone remains alive.\n\nAt the same time, the Sheriff and the Doctor wake up. The sheriff chooses one of the residents whom he wants to “test” for involvement in the mafia. The doctor chooses who he will treat.\n\nIf the doctor cured the player who was voted for by the Mafiosi, the player remains alive. But if there is more than one mafioso in the game, they can vote for multiple players. Thus, if the doctor treated one of them, the next one with the most votes will die.\n\nWhen day comes, it is announced who was killed during the night. The killed player is eliminated from the game, having the right to a final farewell message.\n\nDuring the day, players discuss which of them may be “dishonest” - involved in the mafia. At the end of the discussion, all players vote who they want to kill in the daily vote.\n\nThe most suspicious resident with the most votes dies.\n\nIf the votes are evenly divided, the victim is chosen at random. If no one voted, everyone remains alive.\n\nThe killed player is eliminated from the game, having the right to the last, farewell message.\n\nVictory is awarded after the complete destruction of one of the teams.\n\nIf all civilians are killed, the Mafia wins.\n\nAccordingly, in the event of the death of all Mafiosi - civilians win.';

  @override
  String get experience => 'Experience';

  @override
  String get gamesPlayed => 'Games Played';

  @override
  String get gamesWon => 'Games Won';

  @override
  String get today => 'Today';

  @override
  String get allTime => 'All Time';

  @override
  String get searchFriends => 'Search friends';

  @override
  String get enterUsername => 'Enter username';

  @override
  String get online => 'online';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestAlredySent => 'Request alredy sent';

  @override
  String get requests => 'Requests';

  @override
  String get language => 'Language';

  @override
  String get password => 'Password';

  @override
  String get changePassword => 'Change password';

  @override
  String get oldPassword => 'Old password';

  @override
  String get newPassword => 'New password';

  @override
  String get change => 'Change';

  @override
  String get nickname => 'Nickname';

  @override
  String get changeNickname => 'Change nickname';

  @override
  String get writeNewNickname => 'Write new nickname';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get logOut => 'Log out';

  @override
  String get deleteAccaunt => 'Delete accaunt';

  @override
  String get email => 'Email';

  @override
  String get signIn => 'Sign In';

  @override
  String get dontHaveAccauntRegister => 'Don\'t have an accaunt? Sign up';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccauntSigIn => 'Alredy have an accaunt? Sign In';

  @override
  String get players => 'Players';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get join => 'Join';

  @override
  String get gameStarted => 'Game Started';

  @override
  String get gatheringPlayers => 'Gathering Players';

  @override
  String get alive => 'Alive';

  @override
  String get dead => 'Dead';

  @override
  String get createGame => 'Create Game';

  @override
  String get passwordOptional => 'Password (Optional)';

  @override
  String get roomName => 'Room Name';

  @override
  String get reset => 'Reset';

  @override
  String get filter => 'Filter';

  @override
  String get friendInTheRoom => 'Friends in the room';

  @override
  String get onlyRoomsWithAvailableSpace => 'Only rooms with available space';

  @override
  String get roomsWithoutAPassword => 'Rooms without a password';

  @override
  String get roomsWithAPassword => 'Rooms with a password';

  @override
  String get additionalRoles => 'Additional Roles';

  @override
  String get roomsWithourAdditionalRoles => 'Rooms without additional roles';

  @override
  String get apply => 'Apply';

  @override
  String get close => 'Close';

  @override
  String get remainingTime => 'Remaining time';

  @override
  String get seconds => 'Seconds';

  @override
  String get playersInRoom => 'Players in the Room';

  @override
  String get enterMessage => 'Enter message';

  @override
  String get alreadyHaveAnAccount => 'Already have an account?';

  @override
  String get youMustWriteYourNickname => 'You must write your nickname';

  @override
  String get yourNicknameMustContainAtLeast3Characters =>
      'Your nickname must contain at least 3 characters';

  @override
  String get yourNicknameCanContainLettersNumbersAnd =>
      'Your nickname can contain, letters, numbers and . _ -';

  @override
  String get youMustWriteYourEmail => 'You must write your email';

  @override
  String get enterValidEmail => 'Enter valid email';

  @override
  String get youMustWriteYourPassword => 'You must write your password';

  @override
  String get yourPasswordMustContainAtLeast6Characters =>
      'Your password must contain at least 6 characters';

  @override
  String get youMustConfirmYourPassword => 'You must confirm your password';

  @override
  String get passwordsAreNotMatching => 'Passwords are not matching';

  @override
  String get confirm => 'Confirm';

  @override
  String get sorryConnectionWithServerTimeouted =>
      'Sorry, connection with server timeouted...';

  @override
  String get playerWithThisEmailAlreadyExist =>
      'Player with this email already exist';

  @override
  String get playerWithThisNicknameAlreadyExist =>
      'Player with this nickname already exist';

  @override
  String get sorrySomethingBadHappened => 'Sorry, Something bad happened...';

  @override
  String get userWithThisEmailDoesNotExist =>
      'User with this email does not exist';

  @override
  String get emailOrPasswordIsInvalid => 'Email or Password is invalid';

  @override
  String get dontHaveAnAccount => 'Don\'t have an account?';

  @override
  String get forgotPassword => 'Forgot Password';

  @override
  String get playersInTheRoom => 'Players in the room';

  @override
  String get civilian => 'Civilian ';

  @override
  String get day => 'Day';

  @override
  String get isYourDestiny => 'is your destiny';

  @override
  String get useSkill => 'Skill';

  @override
  String get civiliansAreWithUs => 'civilians are with us';

  @override
  String get bombard => 'Explode';

  @override
  String get vote => 'Choose';

  @override
  String get myMoveIsMade => 'Vote';

  @override
  String get iAcceptTheWeightOfMyChoice => 'I accept the weight of my choice';

  @override
  String get cure => 'Cure';

  @override
  String get satisfy => 'Satisfy';

  @override
  String get protect => 'Protect';

  @override
  String get intoxicate => 'Intoxicate';

  @override
  String get reveale => 'Reveale';

  @override
  String get investigate => 'Investigate';

  @override
  String get interview => 'Interview';

  @override
  String get mafias => 'mafias';

  @override
  String get civilians => 'civilians';

  @override
  String get pickYourTarget => 'Mafias pick target - ';

  @override
  String get iveChosenNoRegrets => 'I\'ve chosen. No regrets';

  @override
  String get choose => 'Choose';

  @override
  String get enterTheMessage => 'Enter the message...';

  @override
  String get lobby => 'Lobby';

  @override
  String get search => ' Search...';

  @override
  String get filterOff => 'Filter Off';

  @override
  String get noAvailableGames => 'No available games..';

  @override
  String get youArePlayingHere => 'You Are Playing Here';

  @override
  String get youDiedHere => 'You Died Here';

  @override
  String get show => 'Show';

  @override
  String get allPlayers => 'All Players';

  @override
  String get areHere => 'are here';

  @override
  String get defeated => 'Defeated';

  @override
  String get stillHere => 'Still here';

  @override
  String get enterTheName => ' Enter the name';

  @override
  String get on => 'on';

  @override
  String get off => 'off';

  @override
  String get enterThePassword => ' Enter the password';

  @override
  String get numberOfPlayers => 'Number of players';

  @override
  String get extraRoles => 'Extra Roles';

  @override
  String get beauty => 'Beauty';

  @override
  String get bartender => 'Bartender';

  @override
  String get roomsWith => 'Rooms with:';

  @override
  String get availableSpots => 'Available Spots';

  @override
  String get friendsIn => 'Friends In';

  @override
  String get access => 'Access';

  @override
  String get mixed => 'Mixed';

  @override
  String get open => 'Open';

  @override
  String get private => 'Private';

  @override
  String get includedRoles => 'Included roles:';

  @override
  String get lover => 'Lover';

  @override
  String get starting => 'Starting:';

  @override
  String get waiting => 'Waiting For Players';

  @override
  String get trustedIndividuals => 'TRUSTED INDIVIDUALS';

  @override
  String get justiceRidesWithUs => 'Justice rides with us.';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get noFriendsFound => 'No friends found';

  @override
  String get delete => 'Delete';

  @override
  String get registry => 'REGISTRY';

  @override
  String get ofChoosenOnes => 'OF CHOOSEN ONES';

  @override
  String get onlyTheTruestRideTogether => 'Only the truest ride together.';

  @override
  String get noPlayersFound => 'No players found';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get wanted => 'WANTED:';

  @override
  String get goodCompany => 'GOOD COMPANY';

  @override
  String get ridingSoloAintTheWay => 'Riding solo ain\'t the way.';

  @override
  String get requestPending => 'Request Pending';

  @override
  String get approvePending => 'Approve Pending';

  @override
  String get classic => 'classic';

  @override
  String get welcome => 'Welcome';

  @override
  String get chat => 'Chat';

  @override
  String get offline => 'Offline';

  @override
  String get joinDate => 'Join Date';

  @override
  String get report => 'Report';

  @override
  String get addToFriends => 'Add To Friends';

  @override
  String get currentlyOffline => 'Currently Offline';

  @override
  String get currentlyAreNotPlaying => 'Currently are not playing';

  @override
  String get currentlyArePlayingIn => 'Currently are playing in:';

  @override
  String get playersInTotal => 'Players in total';

  @override
  String get stats => 'Stats';

  @override
  String get overall => 'Overall';

  @override
  String get wins => 'Wins';

  @override
  String get loses => 'Loses';

  @override
  String get mafiaWins => 'Mafia Wins';

  @override
  String get civilianWins => 'Civilian Wins';

  @override
  String get playedRoles => 'Played Roles';

  @override
  String get avatar => 'Avatar';

  @override
  String get upload => 'Upload';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get onOn => 'On';

  @override
  String get offOff => 'Off';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get currentAvatar => 'Current Avatar';

  @override
  String get uploadNew => 'Upload New';

  @override
  String get uploadAnother => 'Upload Another';

  @override
  String get currentNickname => 'Current Nickname';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get title => 'Title';

  @override
  String get youMustWriteATitleOfTheReport =>
      'You must write a title of the report';

  @override
  String get typeHere => 'Type here';

  @override
  String get inCaseOfAnyProblemPleaseNotifyUs =>
      'In case of any problem, please notify us';

  @override
  String get recover => 'Recover';

  @override
  String get writeDownTheEmailToGetACode =>
      'Write down the email to get a code';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get youMustWriteTheSmsCode => 'You must write the SMS code';

  @override
  String get sms => 'SMS';

  @override
  String get codeMustBeNumeric => 'Code must be numeric';

  @override
  String get codeMustBe6Charactes => 'Code must be 6 charactes';

  @override
  String gameTerroristExplosion(String playerNickname) {
    return 'Terrorist tried to bomb [$playerNickname], but bodyguard saved him/her';
  }

  @override
  String get timeForDecision => 'Town\'s decision - ';

  @override
  String get skillsDescriptionsBeauty =>
      'Select a player to satisfy. They won\'t be able to vote or use abilities';

  @override
  String get skillsDescriptionsBodyguard =>
      'Select a player to protect from the mafia and the terrorist';

  @override
  String get skillsDescriptionsBarman =>
      'Select a player to intoxicate. They won\'t be able to vote, speak, or use abilities';

  @override
  String get skillsDescriptionsDoctor =>
      'Select a player to heal from a mafia attack';

  @override
  String get skillsDescriptionsInformant =>
      'Select a player whose role you want to reveal';

  @override
  String get skillsDescriptionsSheriff =>
      'Select a player to investigate and find out their role';

  @override
  String get skillsDescriptionsJournalist =>
      'Select two players to find out if they are on the same team';

  @override
  String get hasJoined => 'has joined';

  @override
  String get hasLeft => 'has left';

  @override
  String get rolesGeneralDescriptionMafia =>
      'You are mafia and you play for the mafia team. Your task is to eliminate the civilians through deception during day voting and nightly murders together with your team';

  @override
  String get rolesGeneralDescriptionCivilian =>
      'You are a simple civilian of the city. Your task is to identify all the members of the Mafia and vote against them, helping the civilians achieve victory';

  @override
  String get rolesGeneralDescriptionSpy =>
      'You are a spy for the civilians. Eavesdrop on the mafia\'s conversations and share useful information with the civilians to expose the mafia';

  @override
  String get rolesGeneralDescriptionDoctor =>
      'You are the doctor for the civilians. Your goal is to use your medical skills to save the civilian team members from the mafia\'s attacks in the night';

  @override
  String get rolesGeneralDescriptionBeauty =>
      'You are the beauty, a player for the civilians. Use your charm to distract the mafia, preventing them from using their abilities and participating in the voting';

  @override
  String get rolesGeneralDescriptionBodyguard =>
      'You are the bodyguard for the civilians. Use your skills to carefully protect the civilians from attacks by the terrorist or the mafia during the day';

  @override
  String get rolesGeneralDescriptionBarman =>
      'You are the barman, playing for the mafia team. You do not know the mafia, and they do not know you. Use your barman skills to intoxicate the civilians';

  @override
  String get rolesGeneralDescriptionInformant =>
      'You are the mafia\'s informant. You do not know the mafia, and they do not know you. Reveal civilian roles and communicate anonymously with the mafia, sharing important information';

  @override
  String get rolesGeneralDescriptionSheriff =>
      'You are the city\'s Sheriff, representing the civilians team. Your task is to investigate players, identify members of the mafia organization and let the civilians know the truth';

  @override
  String get rolesGeneralDescriptionJournalist =>
      'You are the journalist for the civilians. Every night, conduct interviews with two players so that everyone learns whether they are on the same team or on different teams';

  @override
  String get rolesGeneralDescriptionTerrorist =>
      'You are the Terrorist from the mafia team. You do not know the mafia, but the mafia knows you. During the day vote, you can blow up a civilian, dying along with them';

  @override
  String get rolesObjectiveMafia => 'Eliminate all civilians';

  @override
  String get rolesObjectiveVicilian => 'Eliminate all members of the mafia';

  @override
  String get rolesObjectiveSpy =>
      'Help the civilians eliminate all mafia members by eavesdropping on their nightly conversations';

  @override
  String get rolesObjectiveDoctor =>
      'Help the civilians eliminate all mafia members by saving them from the mafia\'s attacks';

  @override
  String get rolesObjectiveBeauty =>
      'Help the civilians eliminate all mafia members by distracting mafia members';

  @override
  String get rolesObjectiveBodyguard =>
      'Help the civilians eliminate all mafia members by protecting civilians from mafia members';

  @override
  String get rolesObjectiveBarman =>
      'Help the mafia members eliminate the civilians by intoxicating them';

  @override
  String get rolesObjectiveInformant =>
      'Help the mafia members eliminate the civilians by providing them with important information';

  @override
  String get rolesObjectiveSheriff =>
      'Help the civilians eliminate all mafia members by identifying mafia members';

  @override
  String get rolesObjectiveJournalist =>
      'Help the civilians eliminate all mafia members by conducting daily reports';

  @override
  String get rolesObjectiveTerrorist =>
      'Help the mafia members eliminate the civilians by blowing up an important civilian';

  @override
  String get rolesDayPhaseMafia =>
      'Participate in discussions and voting, carefully manipulate the opinions of other players, and guide the conversation in a direction favorable to the mafia';

  @override
  String get rolesDayPhaseCivilian =>
      'Participate in discussions and voting, guide the conversation, and support the civilians';

  @override
  String get rolesDayPhaseSpy =>
      'Participate in discussions and voting, guide the conversation, and support the civilians';

  @override
  String get rolesDayPhaseDoctor =>
      'Participate in discussions and voting, guide the conversation, and support the civilians';

  @override
  String get rolesDayPhaseBeauty =>
      'Participate in discussions and voting, guide the conversation, and support the civilians';

  @override
  String get rolesDayPhaseBodyguard =>
      'Every day, you can choose a player to protect from an attack by the terrorist or the mafia';

  @override
  String get rolesDayPhaseBarman =>
      'Participate in discussions and voting, carefully manipulate the opinions of other players, and guide the conversation in a direction favorable to the mafia';

  @override
  String get rolesDayPhaseInformant =>
      'Participate in discussions and voting, carefully manipulate the opinions of other players, and guide the conversation in a direction favorable to the mafia';

  @override
  String get rolesDayPhaseSheriff =>
      'Participate in discussions and voting, take the initiative, and lead the civilians to victory';

  @override
  String get rolesDayPhaseJournalist =>
      'Participate in discussions and voting, guide the conversation, and support the civilians';

  @override
  String get rolesDayPhaseTerrorist =>
      'You can participate in discussions, but you do not have the right to vote. During the day vote, you can blow up a player; however, if the Bodyguard protects that player, you will die, taking the Bodyguard with you';

  @override
  String get skill => 'Skill';

  @override
  String get rolesThirdDescriptionMafia =>
      'Every night, the mafia gathers, discusses, and chooses one player to eliminate. The Spy can see your nightly conversations, but does not know who exactly is sending them';

  @override
  String get rolesThirdDescriptionCivilian =>
      'You have nothing to do at night, rest';

  @override
  String get rolesThirdDescriptionSpy =>
      'At night, you can eavesdrop on the conversations of the mafia and the Informant, but their identities remain unknown';

  @override
  String get rolesThirdDescriptionDoctor =>
      'Every night, you can heal one player chosen by the mafia for an attack. If you choose the correct player, their life will be saved';

  @override
  String get rolesThirdDescriptionBeauty =>
      'Every night, you can distract one player. The distracted player will not be able to vote or use their abilities until the next night';

  @override
  String get rolesThirdDescriptionBodyguard =>
      'You continue to protect the player you chose during the day from mafia attacks at night';

  @override
  String get rolesThirdDescriptionBarman =>
      'Every night, you can intoxicate one player. An intoxicated player will not be able to vote, use abilities, or speak clearly until the next night';

  @override
  String get rolesThirdDescriptionInformant =>
      'Every night, you can reveal the role of one player and communicate with the mafia. The mafia and the Spy see your messages, but the sender\'s identity remains hidden';

  @override
  String get rolesThirdDescriptionSheriff =>
      'Every night you can investigate one player to find out their role';

  @override
  String get rolesThirdDescriptionJournalist =>
      'Every night, you can interview two players to find out if they are on the same team. The results of the report are visible to everyone in the chat';

  @override
  String get rolesThirdDescriptionTerrorist =>
      'At night you have nothing to do, rest';

  @override
  String get rolesWinningConditionMafia =>
      'You win when no civilians remain alive';

  @override
  String get rolesWinningConditionsCivilian =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsSpy =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsDoctor =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsBeauty =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsBodyguard =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsBarman =>
      'You win when no civilians remain alive';

  @override
  String get rolesWinningConditionsInformant =>
      'You win when no civilians remain alive';

  @override
  String get rolesWinningConditionsSheriff =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsJournalist =>
      'You win when no members of the mafia remain alive';

  @override
  String get rolesWinningConditionsTerrorist =>
      'You win when no civilians remain alive';

  @override
  String get gameplayRules => 'Gameplay Rules:';

  @override
  String get objective => 'Objective';

  @override
  String get dayPhase => 'Day Phase';

  @override
  String get nightPhase => 'Night Phase';

  @override
  String get winningConditions => 'Winning Conditions';

  @override
  String get night => 'Night';

  @override
  String get itIsYou => 'it is you';

  @override
  String get uknown => 'uknown';

  @override
  String get gameInformationPopupCured =>
      'You’re in “safe” hands, the mafia can’t touch you now';

  @override
  String get gameInformationPopupInterviewed =>
      'Congrats — you’re now part of their “big investigation,” whether you like it or not. And, as always, everyone’s already gossiping about whether you’re on the same side as the other interviewee';

  @override
  String get underTheEffectYouCannotVoteUseAbilitiesAndYour =>
      'Under the effect: you cannot vote, use abilities, and your messages appear distorted';

  @override
  String get gameInformationPopupIntoxicated =>
      'Under the effect: you cannot vote, use abilities, and your messages appear distorted';

  @override
  String get gameInformationPopupInvestigated =>
      'The sheriff entered your details into the system — now they know who you are';

  @override
  String get gameInformationPopupRevealed =>
      'Now your life depends on how important your role is';

  @override
  String get gameInformationPopupProtected =>
      'While the protection is active, you’re safe from harm.';

  @override
  String get gameInformationPopupSatisfied =>
      'You’ve succumbed to the temptation and cannot vote or use abilities.';

  @override
  String get gameInformationPopupTitleCured => 'The doctor has cured you';

  @override
  String get gameInformationPopupTitleInterviewed =>
      'The journalist interviewed you';

  @override
  String get gameInformationPopupTitleIntoxicated =>
      'The bartender got you drunk';

  @override
  String get gameInformationPopupTitleInvestigated =>
      'The sheriff investigated you.';

  @override
  String get gameInformationPopupTitleRevealed =>
      'The informant revealed your role.';

  @override
  String get gameInformationPopupTitleProtected =>
      'The bodyguard has protected you.';

  @override
  String get gameInformationPopupTitleSatisfied =>
      'The beauty has enchanted you.';

  @override
  String get gameInformationPopupExpirationCured =>
      'The effect will wear off in one day';

  @override
  String get gameInformationPopupExpirationInterviewed =>
      'The effect lasts until the end of the game';

  @override
  String get gameInformationPopupExpirationIntoxicated =>
      'The effect will wear off in one day';

  @override
  String get gameInformationPopupExpirationInvestigated =>
      'The effect lasts until the end of the game';

  @override
  String get gameInformationPopupExpirationRevealed =>
      'The effect lasts until the end of the game';

  @override
  String get gameInformationPopupExpirationProtected =>
      'The effect will wear off in one day';

  @override
  String get gameInformationPopupExpirationSatisfied =>
      'The effect will wear off in one day';

  @override
  String get youMustWriteYourReport => 'You must write your report';

  @override
  String get inviteFriend => 'Invite Friend';

  @override
  String get phaseMessagesDay => 'The silence of night is over. Now speak.';

  @override
  String get phaseMessageDayVoting => 'Choose the imposter of the day';

  @override
  String get phaseMessageNight => 'The night begins. All must rest in silence';

  @override
  String get phaseMessageNightVoting => 'The Mafia cast their deadly vote.';

  @override
  String nicknameDidNotSurviveTheNight(String nickname) {
    return '[$nickname] did not survive the night..';
  }

  @override
  String nicknameWasEliminatedByTheTownsDecision(String nickname) {
    return '[$nickname] was eliminated by the town\'s decision';
  }

  @override
  String terroristTriedToBombTargetplayerButBodyguardSavedHimher(
      String targetPlayer) {
    return 'Terrorist tried to bomb [$targetPlayer], but bodyguard saved him/her';
  }

  @override
  String terroristBombardedTargetplayer(String targetPlayer) {
    return 'Terrorist bombarded [$targetPlayer]';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnDifferentTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return '[$firstPlayerNickname] and [$secondPlayerNickname] are on different teams';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnSameTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return '[$firstPlayerNickname] and [$secondPlayerNickname] are on same teams';
  }
}
