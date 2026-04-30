// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get profile => 'Profil';

  @override
  String get games => 'Oyunlar';

  @override
  String get create => 'Yarat';

  @override
  String get settings => 'Ayarlar';

  @override
  String get roles => 'Roles';

  @override
  String get friends => 'Dostlar';

  @override
  String get ratings => 'Ratings';

  @override
  String get share => 'Share';

  @override
  String get mafia => 'Mafiya';

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
  String get online => 'Onlayn';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestAlredySent => 'Request alredy sent';

  @override
  String get requests => 'Sorğular';

  @override
  String get language => 'Dil';

  @override
  String get password => 'Şifre';

  @override
  String get changePassword => 'Change password';

  @override
  String get oldPassword => 'Old password';

  @override
  String get newPassword => 'New password';

  @override
  String get change => 'Dəyiş';

  @override
  String get nickname => 'İstifadəçi adı';

  @override
  String get changeNickname => 'Change nickname';

  @override
  String get writeNewNickname => 'Write new nickname';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get logOut => 'Çıxış et';

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
  String get max => 'Maks';

  @override
  String get join => 'Qoşul';

  @override
  String get gameStarted => 'Oyun başladı';

  @override
  String get gatheringPlayers => 'Gathering Players';

  @override
  String get alive => 'Sağ';

  @override
  String get dead => 'Ölü';

  @override
  String get createGame => 'Oyun Yarat';

  @override
  String get passwordOptional => 'Password (Optional)';

  @override
  String get roomName => 'Room Name';

  @override
  String get reset => 'Sıfırla';

  @override
  String get filter => 'Filtr';

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
  String get apply => 'Tətbiq et';

  @override
  String get close => 'Bağla';

  @override
  String get remainingTime => 'Remaining time';

  @override
  String get seconds => 'saniyə';

  @override
  String get playersInRoom => 'Oyunçu Otaqda';

  @override
  String get enterMessage => 'Yazın';

  @override
  String get alreadyHaveAnAccount => 'Artıq hesabınız var?';

  @override
  String get youMustWriteYourNickname => 'Ləqəbinizi yazmalısınız';

  @override
  String get yourNicknameMustContainAtLeast3Characters =>
      'Ləqəbiniz ən azı 3 simvoldan ibarət olmalıdır';

  @override
  String get yourNicknameCanContainLettersNumbersAnd =>
      'Ləqəbinizdə hərflər, rəqəmlər və . _ - simvolları ola bilər';

  @override
  String get youMustWriteYourEmail => 'E-poçtunuzu yazmalısınız';

  @override
  String get enterValidEmail => 'Düzgün e-poçt daxil edin';

  @override
  String get youMustWriteYourPassword => 'Şifrənizi yazmalısınız';

  @override
  String get yourPasswordMustContainAtLeast6Characters =>
      'Şifrəniz ən azı 6 simvoldan ibarət olmalıdır';

  @override
  String get youMustConfirmYourPassword => 'Şifrənizi təsdiqləməlisiniz';

  @override
  String get passwordsAreNotMatching => 'Şifrələr uyğun gəlmir';

  @override
  String get confirm => 'Təsdiqlə';

  @override
  String get sorryConnectionWithServerTimeouted =>
      'Bağışlayın, serverlə əlaqə vaxtı bitdi...';

  @override
  String get playerWithThisEmailAlreadyExist =>
      'Bu e-poçtla oyunçu artıq mövcuddur';

  @override
  String get playerWithThisNicknameAlreadyExist =>
      'Bu ləqəblə oyunçu artıq mövcuddur';

  @override
  String get sorrySomethingBadHappened => 'Bağışlayın, xəta baş verdi...';

  @override
  String get userWithThisEmailDoesNotExist =>
      'Bu e-poçtla istifadəçi tapılmadı';

  @override
  String get emailOrPasswordIsInvalid => 'E-poçt və ya şifrə yanlışdır';

  @override
  String get dontHaveAnAccount => 'Hesabınız yoxdur?';

  @override
  String get forgotPassword => 'Şifrəni unutmusunuz?';

  @override
  String get playersInTheRoom => 'Oyunçu otaqda';

  @override
  String get civilian => 'Civilian ';

  @override
  String get day => 'Gün';

  @override
  String get isYourDestiny => 'taleyin';

  @override
  String get useSkill => 'Bacarığ';

  @override
  String get civiliansAreWithUs => 'civilians are with us';

  @override
  String get bombard => 'Partlat';

  @override
  String get vote => 'Səs ver';

  @override
  String get myMoveIsMade => 'Səs ver';

  @override
  String get iAcceptTheWeightOfMyChoice => 'I accept the weight of my choice';

  @override
  String get cure => 'Kurtar';

  @override
  String get satisfy => 'Ovsunla';

  @override
  String get protect => 'Qoru';

  @override
  String get intoxicate => 'Sərxoş et';

  @override
  String get reveale => 'Aşkar et';

  @override
  String get investigate => 'Araşdır';

  @override
  String get interview => 'Müsahibə';

  @override
  String get mafias => 'Mafiyalar';

  @override
  String get civilians => 'Sakinlər';

  @override
  String get pickYourTarget => 'Qurbanı seçin';

  @override
  String get iveChosenNoRegrets => 'I\\\'ve chosen. No regrets';

  @override
  String get choose => 'Seç';

  @override
  String get enterTheMessage => 'Enter the message...';

  @override
  String get lobby => 'Lobi';

  @override
  String get search => ' Axtar';

  @override
  String get filterOff => 'Filtr Bağlı';

  @override
  String get noAvailableGames =>
      'Hələ aktiv oyun yoxdur… Özün yarat və dostlarını dəvət et!';

  @override
  String get youArePlayingHere => 'Sən bu otaqda oynayırsan';

  @override
  String get youDiedHere => 'Sən bu otaqda ölmüsən';

  @override
  String get show => 'Bütün';

  @override
  String get allPlayers => 'Oyunçular';

  @override
  String get areHere => 'rollar';

  @override
  String get defeated => 'Defeated';

  @override
  String get stillHere => 'Still here';

  @override
  String get enterTheName => ' Enter the name';

  @override
  String get on => 'açıq';

  @override
  String get off => 'bağlı';

  @override
  String get enterThePassword => ' Şifreni daxil et';

  @override
  String get numberOfPlayers => 'Oyunçu sayı';

  @override
  String get extraRoles => 'Əlavə Rollar';

  @override
  String get beauty => 'Beauty';

  @override
  String get bartender => 'Bartender';

  @override
  String get roomsWith => 'Otaqda:';

  @override
  String get availableSpots => 'Boş yerlər';

  @override
  String get friendsIn => 'Dostlar';

  @override
  String get access => 'Giriş';

  @override
  String get mixed => 'Miks';

  @override
  String get open => 'Açıq';

  @override
  String get private => 'Parollu';

  @override
  String get includedRoles => 'Əlavə Rollar:';

  @override
  String get lover => 'Lover';

  @override
  String get starting => 'Başlayır:';

  @override
  String get waiting => 'Oyunçular gözlənilir';

  @override
  String get trustedIndividuals => 'ETİBARLI ŞƏXSLƏR';

  @override
  String get justiceRidesWithUs => 'Ədalət bizimlədir.';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get noFriendsFound => 'Dost tapılmadı';

  @override
  String get delete => 'Delete';

  @override
  String get registry => 'SEÇİLMİŞLƏR';

  @override
  String get ofChoosenOnes => 'SİYAHISI';

  @override
  String get onlyTheTruestRideTogether => 'Yalnız ən sadiqlər birlikdə gedir';

  @override
  String get noPlayersFound => 'No players found';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get wanted => 'AXTARILIR:';

  @override
  String get goodCompany => 'YAXŞI DOST QRUPU';

  @override
  String get ridingSoloAintTheWay => 'İrəli yalnız birlikdə';

  @override
  String get requestPending => 'Request Pending';

  @override
  String get approvePending => 'Approve Pending';

  @override
  String get classic => 'classic';

  @override
  String get welcome => 'Welcome,';

  @override
  String get chat => 'Çat';

  @override
  String get offline => 'Offline';

  @override
  String get joinDate => 'Qoşulma Tarixi';

  @override
  String get report => 'Şikayət et';

  @override
  String get addToFriends => 'Dostluq at';

  @override
  String get currentlyOffline => 'Currently Offline';

  @override
  String get currentlyAreNotPlaying => 'Currently are not playing';

  @override
  String get currentlyArePlayingIn => 'Currently are playing in:';

  @override
  String get playersInTotal => 'Players in total';

  @override
  String get stats => 'Statistika';

  @override
  String get overall => 'Overall';

  @override
  String get wins => 'Qələbələr';

  @override
  String get loses => 'Məğlubiyyət';

  @override
  String get mafiaWins => 'Mafiya Qələbəsi';

  @override
  String get civilianWins => 'Sakin Qələbəsi';

  @override
  String get playedRoles => 'Oynanmış Rollar';

  @override
  String get avatar => 'Avatar';

  @override
  String get upload => 'Yüklə';

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
    return 'Kamikaze tried to bomb [\$playerNickname], but bodyguard saved him/her';
  }

  @override
  String get timeForDecision => 'Şəhərin qərarı - ';

  @override
  String get skillsDescriptionsBeauty =>
      'Ovsunlamaq istədiyiniz oyunçunu seçin. O, səs verə və ya bacarıqlarından istifadə edə bilməyəcək';

  @override
  String get skillsDescriptionsBodyguard =>
      'Mafia və Kamikaze\'dən qorumaq istədiyiniz oyunçunu seçin';

  @override
  String get skillsDescriptionsBarman =>
      'Sərxoş etmək istədiyiniz oyunçunu seçin. O, səs verə, danışa və bacarıqlarından istifadə edə bilməyəcək';

  @override
  String get skillsDescriptionsDoctor =>
      'Mafiya hücumundan xilas edəcəyiniz oyunçunu seçin';

  @override
  String get skillsDescriptionsInformant =>
      'Rolunu aşkar etmək istədiyiniz oyunçunu seçin';

  @override
  String get skillsDescriptionsSheriff =>
      'Rolunu öyrənmək üçün araşdıracağınız oyunçunu seçin';

  @override
  String get skillsDescriptionsJournalist =>
      'Eyni komandada olub-olmadıqlarını öyrənmək üçün iki oyunçu seçin';

  @override
  String get hasJoined => 'qoşuldu';

  @override
  String get hasLeft => 'ayrıldı';

  @override
  String get rolesGeneralDescriptionMafia =>
      'Siz — Mafia rolundasınız və mafiya komandasında oynayırsınız. Məqsədiniz, gündüz səsvermələrində aldatmaq və komandanızla birlikdə gecə qətlləri həyata keçirərək sakinləri aradan qaldırmaqdır';

  @override
  String get rolesGeneralDescriptionCivilian =>
      'Siz — Civilian rolundasınız və sakinlərin komandasında oynayırsınız. Məqsədiniz, bütün mafiya üzvlərini ifşa etmək və sakinlərin qələbəyə çatmasına kömək etmək üçün onlara qarşı səs verməkdir';

  @override
  String get rolesGeneralDescriptionSpy =>
      'Siz — Spy rolundasınız və sakinlərin komandasında oynayırsınız. Mafiyanın söhbətlərini dinləyin və mafiyanı ifşa etmək üçün sakinlərlə faydalı məlumatlar paylaşın';

  @override
  String get rolesGeneralDescriptionDoctor =>
      'Siz — Doctor rolundasınız və sakinlərin komandasında oynayırsınız. Sakinləri mafiyanın gecə hücumlarından xilas etmək üçün tibbi bacarıqlarınızdan istifadə edin';

  @override
  String get rolesGeneralDescriptionBeauty =>
      'Siz — Beauty rolundasınız və sakinlərin komandasında oynayırsınız. Mafiyanı öz bacarıqlarından istifadə etməkdən və səsvermədə iştirak etməkdən məhrum etmək üçün onları ovsunlayın';

  @override
  String get rolesGeneralDescriptionBodyguard =>
      'Siz — Bodyguard rolundasınız və sakinlərin komandasında oynayırsınız. Sakinləri kamikadze və ya mafiya hücumlarından qorumaq üçün bacarıqlarınızdan istifadə edin';

  @override
  String get rolesGeneralDescriptionInformant =>
      'Siz — Informant rolundasınız və mafiya komandasında oynayırsınız. Siz mafiyanı tanımırsınız, onlar da sizi tanımır. Sakinlərin rollarını aşkar edin və önəmli məlumatları anonim şəkildə mafiyaya ötürün';

  @override
  String get rolesGeneralDescriptionSheriff =>
      'Siz — Sheriff rolundasınız və sakinlərin komandasında oynayırsınız. Məqsədiniz, oyunçuları araşdırmaq və mafiya üzvlərini müəyyən etməkdir';

  @override
  String get rolesGeneralDescriptionJournalist =>
      'Siz — Journalist rolundasınız və sakinlərin komandasında oynayırsınız. Hər gecə iki oyunçu ilə müsahibə aparın ki, hamı onların eyni komandada yoxsa fərqli komandada olduğunu öyrənsin';

  @override
  String get rolesGeneralDescriptionKamikaze =>
      'Siz — Kamikaze rolundasınız və mafiya komandasında oynayırsınız. Siz mafiyanı tanımırsınız, lakin mafia sizi tanıyır. Gündüz səsverməsi zamanı bir oyunçunu partlada bilərsiniz, amma nəticədə siz də onunla birlikdə ölürsünüz';

  @override
  String get rolesGeneralDescriptionBarman =>
      'Siz — Barman rolundasınız və mafiya komandasında oynayırsınız. Siz mafiyanı tanımırsınız, onlar da sizi tanımır. Sakinləri sərxoş etmək üçün barmen bacarıqlarınızdan istifadə edin';

  @override
  String get rolesObjectiveMafia => 'Bütün sakinləri aradan qaldır';

  @override
  String get rolesObjectiveVicilian => 'Bütün mafiya üzvlərini aradan qaldır';

  @override
  String get rolesObjectiveSpy =>
      'Mafiyanın gecə söhbətlərini dinləyərək sakinlərin bütün mafiya üzvlərini aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveDoctor =>
      'Sakinləri mafiya hücumlarından xilas edərək sakinlərin bütün mafiya üzvlərini aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveBeauty =>
      'Mafiya üzvlərini ovsunlayaraq sakinlərin bütün mafiya üzvlərini aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveBodyguard =>
      'Sakinləri kamikadze və mafiya üzvlərindən qoruyaraq sakinlərin bütün mafiya üzvlərini aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveBarman =>
      'Sakinləri sərxoş edərək mafiya üzvlərinin sakinləri aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveInformant =>
      'Mafiya üzvlərinə önəmli məlumatlar ötürərək sakinləri aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveSheriff =>
      'Mafiya üzvlərini müəyyən edərək sakinlərin bütün mafiya üzvlərini aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveJournalist =>
      'Hər gün reportajlar keçirərək sakinlərin bütün mafiya üzvlərini aradan qaldırmasına kömək et';

  @override
  String get rolesObjectiveKamikaze =>
      'Önəmli bir sakini partladaraq mafiya üzvlərinin sakinləri aradan qaldırmasına kömək et';

  @override
  String get rolesDayPhaseMafia =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti mafiyanın lehinə yönləndirin';

  @override
  String get rolesDayPhaseCivilian =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti sivillərin lehinə yönləndirin və onlara dəstək olun';

  @override
  String get rolesDayPhaseSpy =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti sivillərin lehinə yönləndirin və onlara dəstək olun';

  @override
  String get rolesDayPhaseDoctor =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti sivillərin lehinə yönləndirin və onlara dəstək olun';

  @override
  String get rolesDayPhaseBeauty =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti sivillərin lehinə yönləndirin və onlara dəstək olun';

  @override
  String get rolesDayPhaseBodyguard =>
      'Hər gün bir oyunçunu Kamikaze və ya Mafia hücumundan qorumaq üçün seçə bilərsiniz';

  @override
  String get rolesDayPhaseBarman =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti mafiyanın lehinə yönləndirin';

  @override
  String get rolesDayPhaseInformant =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti mafiyanın lehinə yönləndirin';

  @override
  String get rolesDayPhaseSheriff =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, təşəbbüs göstərin və sivilləri qələbəyə apарın';

  @override
  String get rolesDayPhaseJournalist =>
      'Müzakirələrdə və səsvermələrdə iştirak edin, söhbəti sivillərin lehinə yönləndirin və onlara dəstək olun';

  @override
  String get rolesDayPhaseKamikaze =>
      'Müzakirələrdə iştirak edə bilərsiniz, lakin səs vermək hüququnuz yoxdur. Gündüz səsvermesi zamanı bir oyunçunu partlada bilərsiniz, lakin onu Bodyguard qoruyarsa, yalnız Bodyguard\'ı özünüzlə apararaq öləcəksiniz';

  @override
  String get skill => 'Bacarıq';

  @override
  String get rolesThirdDescriptionMafia =>
      'Hər gecə mafiya toplaşır, müzakirə edir və öldürmək üçün bir oyunçu seçir. Spy gecə söhbətlərinizi görə bilir, lakin onları kimin göndərdiyini bilmir';

  @override
  String get rolesThirdDescriptionCivilian =>
      'Gecə görə biləcəyiniz bir iş yoxdur, istirahət edin';

  @override
  String get rolesThirdDescriptionSpy =>
      'Gecələr Mafia və Informant\'ın söhbətlərini dinləyə bilərsiniz, lakin onların kimliyini bilmirsiniz';

  @override
  String get rolesThirdDescriptionDoctor =>
      'Hər gecə mafiyаnın hücum üçün seçdiyi bir oyunçunu xilas edə bilərsiniz. Düzgün oyunçunu seçsəniz, onun həyatını xilas edəcəksiniz';

  @override
  String get rolesThirdDescriptionBodyguard =>
      'Gündüz seçdiyiniz oyunçu gecə mafiya hücumlarına qarşı qorunmaqda davam edir';

  @override
  String get rolesThirdDescriptionBarman =>
      'Hər gecə bir oyunçunu sərxoş edə bilərsiniz. Sərxoş olan oyunçu növbəti gecəyə qədər səs verə, bacarıqlarından istifadə edə və aydın danışa bilməyəcək';

  @override
  String get rolesThirdDescriptionInformant =>
      'Hər gecə bir oyunçunun rolunu aşkar edə və mafiya ilə danışa bilərsiniz. Mafia və Spy mesajlarınızı görə bilir, lakin kimliyiniz gizli qalır';

  @override
  String get rolesThirdDescriptionSheriff =>
      'Hər gecə bir oyunçunun rolunu öyrənmək üçün onu araşdıra bilərsiniz';

  @override
  String get rolesThirdDescriptionJournalist =>
      'Hər gecə iki oyunçu ilə müsahibə apararaq onların eyni komandada olub-olmadığını öyrənə bilərsiniz. Müsahibənin nəticələri çatda hamıya görünür';

  @override
  String get rolesThirdDescriptionKamikaze =>
      'Gecə görə biləcəyiniz bir iş yoxdur, istirahət edin';

  @override
  String get rolesThirdDescriptionBeauty =>
      'Hər gecə bir oyunçunu ovsunlaya bilərsiniz. Ovsunlanan oyunçu növbəti gecəyə qədər səs verə və bacarıqlarından istifadə edə bilməyəcək';

  @override
  String get rolesWinningConditionMafia =>
      'Bütün sivillər öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsCivilian =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsSpy =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsDoctor =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsBeauty =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsBodyguard =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsBarman =>
      'Bütün sivillər öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsInformant =>
      'Bütün sivillər öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsSheriff =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsJournalist =>
      'Bütün mafiya üzvləri öldükdə qalib gəlirsiniz';

  @override
  String get rolesWinningConditionsKamikaze =>
      'Bütün sivillər öldükdə qalib gəlirsiniz';

  @override
  String get gameplayRules => 'Oyun Qaydaları:';

  @override
  String get objective => 'Məqsəd';

  @override
  String get dayPhase => 'Gündüz Fazası';

  @override
  String get nightPhase => 'Gecə Fazası';

  @override
  String get winningConditions => 'Qələbə Şərtləri';

  @override
  String get night => 'Gecə';

  @override
  String get itIsYou => 'Sənsən';

  @override
  String get uknown => 'Gizli';

  @override
  String get underTheEffectYouCannotVoteUseAbilitiesAndYour =>
      'Under the effect: you cannot vote, use abilities, and your messages appear distorted';

  @override
  String get gameInformationPopupCured =>
      'Siz «etibarlı» əllərdəsiniz, mafiya bu gecə sizə zərər verə bilməyəcək';

  @override
  String get gameInformationPopupInterviewed =>
      'Təbrik edirik — reportajın ulduzu oldunuz. Hamı artıq sizin və digər sorğulanan ilə eyni tərəfdə olub-olmadığını müzakirə edir';

  @override
  String get gameInformationPopupIntoxicated =>
      'Təsir altındasınız: səs verə və ya bacarıqlarınızdan istifadə edə bilmərsiz, mesajlarınız isə təhrif olunmuş görünür';

  @override
  String get gameInformationPopupInvestigated =>
      'Sheriff məlumatlarınızı sistemə daxil etdi və artıq kim olduğunuzu bilir';

  @override
  String get gameInformationPopupRevealed =>
      'İndi həyatınız rolunuzun nə qədər önəmli olduğundan asılıdır';

  @override
  String get gameInformationPopupProtected =>
      'Qoruma aktiv olduğu müddətcə təhlükəsizsiniz';

  @override
  String get gameInformationPopupSatisfied =>
      'Ovsunlandınız, siz səs verə və ya bacarıqlarınızdan istifadə edə bilmərsiniz';

  @override
  String get gameInformationPopupTitleCured => 'Doctor sizi xilas etdi';

  @override
  String get gameInformationPopupTitleInterviewed =>
      'Journalist sizinlə müsahibə apardı';

  @override
  String get gameInformationPopupTitleIntoxicated => 'Barman sizi sərxoş etdi';

  @override
  String get gameInformationPopupTitleInvestigated => 'Sheriff sizi araşdırdı';

  @override
  String get gameInformationPopupTitleRevealed =>
      'Informant rolunuzu aşkar etdi';

  @override
  String get gameInformationPopupTitleProtected => 'Bodyguard sizi qorudu';

  @override
  String get gameInformationPopupTitleSatisfied => 'Beauty sizi ovsunladı';

  @override
  String get gameInformationPopupExpirationCured =>
      'Təsir bir gündən sonra keçəcək';

  @override
  String get gameInformationPopupExpirationInterviewed =>
      'Təsir oyunun sonuna qədər davam edir';

  @override
  String get gameInformationPopupExpirationIntoxicated =>
      'Təsir bir gündən sonra keçəcək';

  @override
  String get gameInformationPopupExpirationInvestigated =>
      'Təsir oyunun sonuna qədər davam edir';

  @override
  String get gameInformationPopupExpirationRevealed =>
      'Təsir oyunun sonuna qədər davam edir';

  @override
  String get gameInformationPopupExpirationProtected =>
      'Təsir bir gündən sonra keçəcək';

  @override
  String get gameInformationPopupExpirationSatisfied =>
      'Təsir bir gündən sonra keçəcək';

  @override
  String get youMustWriteYourReport => 'You must write your report';

  @override
  String get inviteFriend => 'Dəvət et';

  @override
  String get phaseMessagesDay =>
      'Yeni gün başlayır. Danış, sual et və şübhələn. Mafiya aranızdadır';

  @override
  String get phaseMessageDayVoting =>
      'Qərar vermə vaxtıdır. Kimə ən az etibar edirsiniz? Səsinizi verin';

  @override
  String get phaseMessageNight =>
      'Gecə düşür. Qaranlıqda mafiya nəsə müzakirə edir';

  @override
  String get phaseMessageNightVoting =>
      'Mafiya yatmır.. indi kimsənin taleyi həll olunur';

  @override
  String nicknameDidNotSurviveTheNight(String nickname) {
    return '[$nickname] səhərə sağ çıxmadı..';
  }

  @override
  String nicknameWasEliminatedByTheTownsDecision(String nickname) {
    return '[$nickname] şəhərin qərarı ilə linc edildi..';
  }

  @override
  String kamikazeTriedToBombTargetplayerButBodyguardSavedHimher(
      String targetPlayer) {
    return 'Kamikaze [$targetPlayer]-ı partlatmağa cəhd etdi, lakin Bodyguard onu xilas etdi';
  }

  @override
  String kamikazeBombardedTargetplayer(String targetPlayer) {
    return 'Kamikaze [$targetPlayer]-ı partlatdı';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnDifferentTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return 'Journalist [$firstPlayerNickname] və [$secondPlayerNickname] ilə müsahibə apardı — onlar fərqli komandada oynayırlar';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnSameTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return 'Journalist [$firstPlayerNickname] və [$secondPlayerNickname] ilə müsahibə apardı — onlar eyni komandada oynayırlar';
  }

  @override
  String personalFeedBackToInformantAndSheriff(
      String playerNickname, String playerRole) {
    return 'Araşdırmandan sonra [$playerNickname]\'nin [$playerRole] olduğunu öyrəndin';
  }

  @override
  String get inGame => 'Otaqda';

  @override
  String get enterTheTitle => 'Enter the title';

  @override
  String get gameRoles => 'Oyun Rolları';

  @override
  String get play => 'Oyna';

  @override
  String get filterOn => 'Filtr Açıq';

  @override
  String get gameIsFull => 'Otaq dolu';

  @override
  String get enterRoomName => ' Otaq adını daxil et';

  @override
  String get noFriendRequests => 'Dostluq sorğusu yoxdur';

  @override
  String get noFriendsToSuggest => 'Tövsiyə ediləcək dost yoxdur';

  @override
  String get minsAgo => 'dəq əvvəl';

  @override
  String get hoursAgo => 'saat əvvəl';

  @override
  String get daysAgo => 'gün əvvəl';

  @override
  String get lessThanAMinute => 'Bir dəqiqədən az';

  @override
  String get playerProfile => 'Oyunçu Profili';

  @override
  String get status => 'Status';

  @override
  String get lastSeen => 'Son görülmə';

  @override
  String get deleteFriend => 'Dostluqdan sil';

  @override
  String get acceptRequest => 'Sorğunu qəbul et';

  @override
  String get rejectRequest => 'Sorğunu rədd et';

  @override
  String get cancelRequest => 'Sorğunu ləğv et';

  @override
  String get sent => 'Göndərildi';

  @override
  String get invite => 'Dəvət et';

  @override
  String get home => 'Ana Səhifə';

  @override
  String get notification => 'Notification';

  @override
  String get sentFriendRequest => ' dostluq üçün dəvət göndərdi';

  @override
  String get acceptedYourRequest => ' dostluq dəvətinizi qəbul etdi';

  @override
  String get whoIsNext => 'Növbəti kim olacaq?';

  @override
  String get invititationToGame => 'Otağa dəvət';

  @override
  String get invitedYouToTheGame => ' sizi bu otağa dəvət etdi - ';

  @override
  String get accept => 'Qəbul et';

  @override
  String get decline => 'Rədd et';

  @override
  String get gameInformationPopupLastMafia =>
      'Bütün Mafia üzvləri öldü. Informant olaraq artıq Mafia\'nın gecə səsvermesində iştirak edə bilərsiniz';

  @override
  String get gameInformationPopupTitleLastMafia => 'Son Mafiya';

  @override
  String get gameInformationPopupExpirationLastMafia =>
      'Təsir oyunun sonuna qədər davam edir';

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
      'Mafiya bu gecə sizi qurban seçdi. Siz səhərə sağ çıxa bilmədiniz';

  @override
  String get iDeadSituationTwoText =>
      'Şəhər sizə səs verdi və şəhərin qərarı ilə oyundan çıxarıldınız';

  @override
  String get iDeadSituationThreeText =>
      'Kamikaze sizi hədəf seçdi. Partlayış həyatınıza son qoydu';

  @override
  String get iDeadSituationFourText =>
      'Siz özünüzü hədəfinizlə birlikdə partlatdınız. Missiyanız burada sona çatdı';

  @override
  String get nightVotingCanNotSendMessage =>
      'Hamı yatarkən mafiya qurbanını seçir';

  @override
  String get nightCanNotSendMessage => 'Gecə yalnız mafiya danışa bilər';

  @override
  String get dayVotingCanNotSendMessage =>
      'Gündüz səsvermesi zamanı heç kim danışa bilməz';

  @override
  String get unsupportedFileFormat => 'Bu fayl formatı avatar üçün uyğun deyil';

  @override
  String get fileIsTooLargeItMustBe200kb =>
      'Fayl çox böyükdür. Zəhmət olmasa 200 KB-dan kiçik avatar yükləyin';
}
