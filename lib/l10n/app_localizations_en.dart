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
  String get kamikaze => 'Kamikaze';

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
  String get roleKamikazeDescription =>
      'Kamikaze - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the kamikaze does not know the identity of the Mafia members. The Kamikaze has one special ability. At any time during the day voting, the kamikaze can blow up anyone player by killing both himself and the victim. The kamikaze cannot be killed by the mafia at night. So the kamikaze must help the mafia win using his life. Regardless of whether the kamikaze is killed, he will receive experience points at the end of the game if. The mafia will win.';

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
      'Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a kamikaze explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Kamikaze or Mafioso will decide to kill at night. The Bodyguard\'s protection only applies once, either during the day or at night, if the kamikaze did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia\'s shot.';

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
  String get enterMessage => 'Type here';

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
  String get cure => 'Save';

  @override
  String get satisfy => 'Charm';

  @override
  String get protect => 'Protect';

  @override
  String get intoxicate => 'Intoxicate';

  @override
  String get reveale => 'Reveal';

  @override
  String get investigate => 'Investigate';

  @override
  String get interview => 'Interview';

  @override
  String get mafias => 'Mafias';

  @override
  String get civilians => 'Civilians';

  @override
  String get pickYourTarget => 'Choose a Victim';

  @override
  String get iveChosenNoRegrets => 'I\'ve chosen. No regrets';

  @override
  String get choose => 'Choose';

  @override
  String get enterTheMessage => 'Enter the message...';

  @override
  String get lobby => 'Lobby';

  @override
  String get search => ' Search';

  @override
  String get filterOff => 'Filter Off';

  @override
  String get noAvailableGames =>
      'No active games yet… Create one and invite your friends!';

  @override
  String get youArePlayingHere => 'You are playing in this room';

  @override
  String get youDiedHere => 'You died in this room';

  @override
  String get show => 'Show';

  @override
  String get allPlayers => 'All Players';

  @override
  String get areHere => 'roles';

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
  String get includedRoles => 'Extra Roles:';

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
  String get ridingSoloAintTheWay => 'Forward only together';

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
  String get stats => 'Statistics';

  @override
  String get overall => 'Overall';

  @override
  String get wins => 'Wins';

  @override
  String get loses => 'Losses';

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
  String gameKamikazeExplosion(String playerNickname) {
    return 'Kamikaze tried to bomb [$playerNickname], but bodyguard saved him/her';
  }

  @override
  String get timeForDecision => 'Town\'s decision - ';

  @override
  String get skillsDescriptionsBeauty =>
      'Choose a player to charm. They will be unable to vote or use their ability';

  @override
  String get skillsDescriptionsBodyguard =>
      'Choose a player to protect from the Mafia and the Kamikaze';

  @override
  String get skillsDescriptionsBarman =>
      'Choose a player to intoxicate. They will be unable to vote, speak, or use their ability';

  @override
  String get skillsDescriptionsDoctor =>
      'Choose a player to save from a Mafia attack';

  @override
  String get skillsDescriptionsInformant =>
      'Choose a player to reveal their role';

  @override
  String get skillsDescriptionsSheriff =>
      'Choose a player to investigate and learn their role';

  @override
  String get skillsDescriptionsJournalist =>
      'Choose two players to find out if they are on the same team';

  @override
  String get hasJoined => 'has joined';

  @override
  String get hasLeft => 'has left';

  @override
  String get rolesGeneralDescriptionMafia =>
      'You are Mafia and play for the mafia team. Your task is to eliminate civilians through deception during day voting and night kills together with your team';

  @override
  String get rolesGeneralDescriptionCivilian =>
      'You are a Civilian and play for the civilian team. Your task is to identify all mafia members and vote against them, helping the civilians achieve victory';

  @override
  String get rolesGeneralDescriptionSpy =>
      'You are a Spy and play for the civilian team. Eavesdrop on mafia conversations and share useful information with the civilians to expose the mafia';

  @override
  String get rolesGeneralDescriptionDoctor =>
      'You are a Doctor and play for the civilian team. Use your medical skills to save civilians from night mafia attacks';

  @override
  String get rolesGeneralDescriptionBeauty =>
      'You are the Beauty and play for the civilian team. Use your charm to distract the mafia, preventing them from using abilities and participating in voting';

  @override
  String get rolesGeneralDescriptionBodyguard =>
      'You are a Bodyguard and play for the civilian team. Use your skills to protect civilians from kamikaze or mafia attacks';

  @override
  String get rolesGeneralDescriptionInformant =>
      'You are the Informant and play for the mafia team. You don\'t know the mafia, and they don\'t know you. Reveal civilian roles and communicate anonymously with the mafia, passing on vital information';

  @override
  String get rolesGeneralDescriptionSheriff =>
      'You are the Sheriff and play for the civilian team. Your task is to investigate players and identify mafia members';

  @override
  String get rolesGeneralDescriptionJournalist =>
      'You are a Journalist and play for the civilian team. Every night, conduct interviews with two players so everyone finds out if they are on the same team or different ones';

  @override
  String get rolesGeneralDescriptionKamikaze =>
      'You are the Kamikaze and play for the mafia team. You don\'t know the mafia, but the mafia knows you. During the day voting, you can blow up a civilian, dying along with them';

  @override
  String get rolesGeneralDescriptionBarman =>
      'You are the Barman and play for the mafia team. You don\'t know the mafia, and they don\'t know you. Use your bartending skills to intoxicate civilians';

  @override
  String get rolesObjectiveMafia => 'Eliminate all civilians';

  @override
  String get rolesObjectiveVicilian => 'Eliminate all mafia members';

  @override
  String get rolesObjectiveSpy =>
      'Help the civilians eliminate all mafia members by eavesdropping on their nightly conversations';

  @override
  String get rolesObjectiveDoctor =>
      'Help the civilians eliminate all mafia members by saving them from mafia attacks';

  @override
  String get rolesObjectiveBeauty =>
      'Help the civilians eliminate all mafia members by distracting mafia members';

  @override
  String get rolesObjectiveBodyguard =>
      'Help the civilians eliminate all mafia members by protecting civilians from kamikaze and mafia members';

  @override
  String get rolesObjectiveBarman =>
      'Help the mafia members eliminate civilians by getting them drunk';

  @override
  String get rolesObjectiveInformant =>
      'Help the mafia members eliminate civilians by passing important information to them';

  @override
  String get rolesObjectiveSheriff =>
      'Help the civilians eliminate all mafia members by identifying mafia members';

  @override
  String get rolesObjectiveJournalist =>
      'Help the civilians eliminate all mafia members by conducting daily reports';

  @override
  String get rolesObjectiveKamikaze =>
      'Help the mafia members eliminate civilians by detonating an important civilian';

  @override
  String get rolesDayPhaseMafia =>
      'Participate in discussions and voting, steer the conversation in the mafia\'s favour';

  @override
  String get rolesDayPhaseCivilian =>
      'Participate in discussions and voting, guide the conversation and support the civilians';

  @override
  String get rolesDayPhaseSpy =>
      'Participate in discussions and voting, guide the conversation and support the civilians';

  @override
  String get rolesDayPhaseDoctor =>
      'Participate in discussions and voting, guide the conversation and support the civilians';

  @override
  String get rolesDayPhaseBeauty =>
      'Participate in discussions and voting, guide the conversation and support the civilians';

  @override
  String get rolesDayPhaseBodyguard =>
      'Each day you can choose a player to protect from a Kamikaze or Mafia attack';

  @override
  String get rolesDayPhaseBarman =>
      'Participate in discussions and voting, steer the conversation in the mafia\'s favour';

  @override
  String get rolesDayPhaseInformant =>
      'Participate in discussions and voting, steer the conversation in the mafia\'s favour';

  @override
  String get rolesDayPhaseSheriff =>
      'Participate in discussions and voting, take the initiative and lead the civilians to victory';

  @override
  String get rolesDayPhaseJournalist =>
      'Participate in discussions and voting, guide the conversation and support the civilians';

  @override
  String get rolesDayPhaseKamikaze =>
      'You can participate in discussions but are not allowed to vote. During the day voting, you can blow up a player, however, if a Bodyguard protects them, you will die taking only the Bodyguard with you';

  @override
  String get skill => 'Skill';

  @override
  String get rolesThirdDescriptionMafia =>
      'Every night the Mafia gathers, discusses and chooses one player to eliminate. Spy can see your night conversations, but does not know who exactly is sending them';

  @override
  String get rolesThirdDescriptionCivilian =>
      'There is nothing for you to do at night, just rest';

  @override
  String get rolesThirdDescriptionSpy =>
      'At night you can eavesdrop on the conversations of Mafia and Informant, but their identities remain unknown';

  @override
  String get rolesThirdDescriptionDoctor =>
      'Every night you can save one player chosen by the Mafia for attack. If you choose the right player, their life will be spared';

  @override
  String get rolesThirdDescriptionBodyguard =>
      'The player you chose during the day remains under your protection throughout the night against Mafia attacks';

  @override
  String get rolesThirdDescriptionBarman =>
      'Every night you can intoxicate one player. The intoxicated player will be unable to vote, use abilities or speak clearly until the next night';

  @override
  String get rolesThirdDescriptionInformant =>
      'Every night you can reveal the role of one player and communicate with the Mafia. Mafia and Spy can see your messages, but your identity remains hidden';

  @override
  String get rolesThirdDescriptionSheriff =>
      'Every night you can investigate one player to find out their role';

  @override
  String get rolesThirdDescriptionJournalist =>
      'Every night you can interview two players to find out if they are on the same team. The results are visible to everyone in the chat';

  @override
  String get rolesThirdDescriptionKamikaze =>
      'There is nothing for you to do at night, just rest';

  @override
  String get rolesThirdDescriptionBeauty =>
      'Every night you can charm one player. The distracted player will be unable to vote or use their abilities until the next night';

  @override
  String get rolesWinningConditionMafia =>
      'You win when no civilians are left alive';

  @override
  String get rolesWinningConditionsCivilian =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsSpy =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsDoctor =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsBeauty =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsBodyguard =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsBarman =>
      'You win when no civilians are left alive';

  @override
  String get rolesWinningConditionsInformant =>
      'You win when no civilians are left alive';

  @override
  String get rolesWinningConditionsSheriff =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsJournalist =>
      'You win when no Mafia members are left alive';

  @override
  String get rolesWinningConditionsKamikaze =>
      'You win when no civilians are left alive';

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
  String get uknown => 'unknown';

  @override
  String get underTheEffectYouCannotVoteUseAbilitiesAndYour =>
      'Under the effect: you cannot vote, use abilities, and your messages appear distorted';

  @override
  String get gameInformationPopupCured =>
      'You\'re in «safe» hands, the Mafia won\'t be able to harm you tonight';

  @override
  String get gameInformationPopupInterviewed =>
      'Congratulations — you\'re now the star of the report. Everyone is already debating whether you and the other interviewee are on the same side or not';

  @override
  String get gameInformationPopupIntoxicated =>
      'Under the effect: you cannot vote or use skills, and your messages appear distorted';

  @override
  String get gameInformationPopupInvestigated =>
      'The sheriff entered your details into the system and now they know who you are';

  @override
  String get gameInformationPopupRevealed =>
      'Now your life depends on how important your role is';

  @override
  String get gameInformationPopupProtected =>
      'While the protection is active, you\'re safe';

  @override
  String get gameInformationPopupSatisfied =>
      'You\'ve been enchanted — you cannot vote or use abilities';

  @override
  String get gameInformationPopupTitleCured => 'The Doctor has saved you';

  @override
  String get gameInformationPopupTitleInterviewed =>
      'The Journalist interviewed you';

  @override
  String get gameInformationPopupTitleIntoxicated => 'The Barman got you drunk';

  @override
  String get gameInformationPopupTitleInvestigated =>
      'The Sheriff investigated you';

  @override
  String get gameInformationPopupTitleRevealed =>
      'The Informant revealed your role';

  @override
  String get gameInformationPopupTitleProtected =>
      'The Bodyguard has protected you';

  @override
  String get gameInformationPopupTitleSatisfied => 'The Beauty has charm you';

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
  String get phaseMessagesDay =>
      'A new day begins. Talk, question and suspect. The mafia walks among you';

  @override
  String get phaseMessageDayVoting =>
      'Time to decide. Who do you trust least? Cast your vote';

  @override
  String get phaseMessageNight =>
      'Night falls over the town. In the darkness, the mafia whispers';

  @override
  String get phaseMessageNightVoting =>
      'The mafia never sleeps.. someone\'s fate is being decided right now';

  @override
  String nicknameDidNotSurviveTheNight(String nickname) {
    return '[$nickname] did not survive the night..';
  }

  @override
  String nicknameWasEliminatedByTheTownsDecision(String nickname) {
    return '[$nickname] was eliminated by the town\'s decision';
  }

  @override
  String kamikazeTriedToBombTargetplayerButBodyguardSavedHimher(
      String targetPlayer) {
    return 'Kamikaze tried to bomb [$targetPlayer], but Bodyguard saved him/her';
  }

  @override
  String kamikazeBombardedTargetplayer(String targetPlayer) {
    return 'Kamikaze bombarded [$targetPlayer]';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnDifferentTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return 'Journalist conducted an interview with [$firstPlayerNickname] and [$secondPlayerNickname] — they play on opposite teams';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnSameTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return 'Journalist conducted an interview with [$firstPlayerNickname] and [$secondPlayerNickname] — they play on the same team';
  }

  @override
  String personalFeedBackToInformantAndSheriff(
      String playerNickname, String playerRole) {
    return 'After your investigation, it seems that [$playerNickname] is [$playerRole]';
  }

  @override
  String get inGame => 'in room';

  @override
  String get enterTheTitle => 'Enter the title';

  @override
  String get gameRoles => 'Game Roles';

  @override
  String get play => 'Play';

  @override
  String get filterOn => 'Filter On';

  @override
  String get gameIsFull => 'Game is Full';

  @override
  String get enterRoomName => ' Enter room name';

  @override
  String get noFriendRequests => 'No friend requests';

  @override
  String get noFriendsToSuggest => 'No friends to suggest';

  @override
  String get minsAgo => 'mins ago';

  @override
  String get hoursAgo => 'hours ago';

  @override
  String get daysAgo => 'days ago';

  @override
  String get lessThanAMinute => 'less than a minute';

  @override
  String get playerProfile => 'Player Profile';

  @override
  String get status => 'Status';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get deleteFriend => 'Delete friend';

  @override
  String get acceptRequest => 'Accept request';

  @override
  String get rejectRequest => 'Reject request';

  @override
  String get cancelRequest => 'Cancel request';

  @override
  String get sent => 'Sent';

  @override
  String get invite => 'Invite';

  @override
  String get home => 'Home';

  @override
  String get notification => 'Notification';

  @override
  String get sentFriendRequest => ' sent friend request';

  @override
  String get acceptedYourRequest => ' accepted your request';

  @override
  String get whoIsNext => 'Who is Next?';

  @override
  String get invititationToGame => 'Invititation To Room';

  @override
  String get invitedYouToTheGame => ' invited you to the room - ';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get gameInformationPopupLastMafia =>
      'All Mafia members are dead. As the Informant, you can now participate in the Mafia\'s night voting';

  @override
  String get gameInformationPopupTitleLastMafia => 'Last Mafia';

  @override
  String get gameInformationPopupExpirationLastMafia =>
      'The effect lasts until the end of the game';

  @override
  String get youAreNotElligibleToSendMessageRightNow =>
      'You are not elligible to send message right now';

  @override
  String get theShadowsHaveConsumedYourLight =>
      'The shadows have consumed your light.';

  @override
  String get youAreDead => 'You are dead';

  @override
  String get iDeadSituationOneText =>
      'The mafia chose you as their victim tonight. You did not live to see the morning';

  @override
  String get iDeadSituationTwoText =>
      'The town voted and pointed at you. You were eliminated by the town\'s decision';

  @override
  String get iDeadSituationThreeText =>
      'The kamikaze chose you as their target. The explosion cut your life short';

  @override
  String get iDeadSituationFourText =>
      'You blew yourself up along with your target. Your mission ended here';

  @override
  String get nightVotingCanNotSendMessage =>
      'While everyone sleeps, the mafia chooses their victim';

  @override
  String get nightCanNotSendMessage =>
      'Only the mafia can speak during the night';

  @override
  String get dayVotingCanNotSendMessage =>
      'No one can speak during the day voting';

  @override
  String get unsupportedFileFormat =>
      'This file format is not supported for avatars';

  @override
  String get fileIsTooLargeItMustBe200kb =>
      'The file is too large. Please upload an avatar smaller than 200 KB';
}
