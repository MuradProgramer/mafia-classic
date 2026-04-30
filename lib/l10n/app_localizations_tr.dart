// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get profile => 'Profil';

  @override
  String get games => 'Oyunlar';

  @override
  String get create => 'Oluştur';

  @override
  String get settings => 'Ayarlar';

  @override
  String get roles => 'Roles';

  @override
  String get friends => 'Arkadaşlar';

  @override
  String get ratings => 'Ratings';

  @override
  String get share => 'Share';

  @override
  String get mafia => 'Mafya';

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
  String get online => 'Çevrimiçi';

  @override
  String get sendRequest => 'Send request';

  @override
  String get requestAlredySent => 'Request alredy sent';

  @override
  String get requests => 'İstekler';

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
  String get change => 'Değiştir';

  @override
  String get nickname => 'Kullanıcı adı';

  @override
  String get changeNickname => 'Change nickname';

  @override
  String get writeNewNickname => 'Write new nickname';

  @override
  String get changeAvatar => 'Change avatar';

  @override
  String get logOut => 'Çıkış Yap';

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
  String get join => 'Katıl';

  @override
  String get gameStarted => 'Oyun başladı';

  @override
  String get gatheringPlayers => 'Gathering Players';

  @override
  String get alive => 'Sağ';

  @override
  String get dead => 'Ölü';

  @override
  String get createGame => 'Oyun Oluştur';

  @override
  String get passwordOptional => 'Password (Optional)';

  @override
  String get roomName => 'Room Name';

  @override
  String get reset => 'Sıfırla';

  @override
  String get filter => 'Filtre';

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
  String get apply => 'Uygula';

  @override
  String get close => 'Kapat';

  @override
  String get remainingTime => 'Remaining time';

  @override
  String get seconds => 'saniye';

  @override
  String get playersInRoom => 'Oyunçu Odada';

  @override
  String get enterMessage => 'Yazın';

  @override
  String get alreadyHaveAnAccount => 'Zaten bir hesabınız var mı?';

  @override
  String get youMustWriteYourNickname => 'Kullanıcı adınızı yazmalısınız';

  @override
  String get yourNicknameMustContainAtLeast3Characters =>
      'Kullanıcı adınız en az 3 karakter içermelidir';

  @override
  String get yourNicknameCanContainLettersNumbersAnd =>
      'Kullanıcı adınız harf, rakam ve . _ - içerebilir';

  @override
  String get youMustWriteYourEmail => 'E-postanızı yazmalısınız';

  @override
  String get enterValidEmail => 'Geçerli bir e-posta girin';

  @override
  String get youMustWriteYourPassword => 'Şifrenizi yazmalısınız';

  @override
  String get yourPasswordMustContainAtLeast6Characters =>
      'Şifreniz en az 6 karakter içermelidir';

  @override
  String get youMustConfirmYourPassword => 'Şifrenizi onaylamalısınız';

  @override
  String get passwordsAreNotMatching => 'Şifreler eşleşmiyor';

  @override
  String get confirm => 'Onayla';

  @override
  String get sorryConnectionWithServerTimeouted =>
      'Üzgünüz, sunucu bağlantısı zaman aşımına uğradı...';

  @override
  String get playerWithThisEmailAlreadyExist =>
      'Bu e-posta adresiyle bir oyuncu zaten mevcut';

  @override
  String get playerWithThisNicknameAlreadyExist =>
      'Bu kullanıcı adıyla bir oyuncu zaten mevcut';

  @override
  String get sorrySomethingBadHappened => 'Üzgünüz, bir hata oluştu...';

  @override
  String get userWithThisEmailDoesNotExist =>
      'Bu e-posta adresine sahip bir kullanıcı bulunamadı';

  @override
  String get emailOrPasswordIsInvalid => 'E-posta veya şifre geçersiz';

  @override
  String get dontHaveAnAccount => 'Hesabınız yok mu?';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get playersInTheRoom => 'Oyunçu odada';

  @override
  String get civilian => 'Civilian ';

  @override
  String get day => 'Gün';

  @override
  String get isYourDestiny => 'kaderin';

  @override
  String get useSkill => 'Yeteneğ';

  @override
  String get civiliansAreWithUs => 'civilians are with us';

  @override
  String get bombard => 'Bombala';

  @override
  String get vote => 'Oy ver';

  @override
  String get myMoveIsMade => 'Oy ver';

  @override
  String get iAcceptTheWeightOfMyChoice => 'I accept the weight of my choice';

  @override
  String get cure => 'Xilas et';

  @override
  String get satisfy => 'Büyüle';

  @override
  String get protect => 'Koru';

  @override
  String get intoxicate => 'Sarhoş et';

  @override
  String get reveale => 'İfşa et';

  @override
  String get investigate => 'Araştır';

  @override
  String get interview => 'Röportaj';

  @override
  String get mafias => 'Mafyalar';

  @override
  String get civilians => 'Siviller';

  @override
  String get pickYourTarget => 'Kurbanı seçin';

  @override
  String get iveChosenNoRegrets => 'I\'ve chosen. No regrets';

  @override
  String get choose => 'Seç';

  @override
  String get enterTheMessage => 'Enter the message...';

  @override
  String get lobby => 'Lobi';

  @override
  String get search => ' Ara';

  @override
  String get filterOff => 'Filtre Kapalı';

  @override
  String get noAvailableGames =>
      'Henüz aktif oyun yok… Bir tane oluştur ve arkadaşlarını davet et!';

  @override
  String get youArePlayingHere => 'Bu odada oynuyorsun';

  @override
  String get youDiedHere => 'Bu odada öldün';

  @override
  String get show => 'Tüm';

  @override
  String get allPlayers => 'Oyuncular';

  @override
  String get areHere => 'roller';

  @override
  String get defeated => 'Defeated';

  @override
  String get stillHere => 'Still here';

  @override
  String get enterTheName => ' Enter the name';

  @override
  String get on => 'açık';

  @override
  String get off => 'kapalı';

  @override
  String get enterThePassword => ' Şifreyi gir';

  @override
  String get numberOfPlayers => 'Oyuncu Sayısı';

  @override
  String get extraRoles => 'Ekstra Roller';

  @override
  String get beauty => 'Beauty';

  @override
  String get bartender => 'Bartender';

  @override
  String get roomsWith => 'Odada:';

  @override
  String get availableSpots => 'Boş Yerler';

  @override
  String get friendsIn => 'Arkadaşlar';

  @override
  String get access => 'Erişim';

  @override
  String get mixed => 'Miks';

  @override
  String get open => 'Açık';

  @override
  String get private => 'Özel';

  @override
  String get includedRoles => 'Ekstra Roller:';

  @override
  String get lover => 'Lover';

  @override
  String get starting => 'Başlıyor:';

  @override
  String get waiting => 'Oyuncular bekleniyor';

  @override
  String get trustedIndividuals => 'GÜVENİLİR KİŞİLER';

  @override
  String get justiceRidesWithUs => 'Adalet bizimle.';

  @override
  String get noUsersFound => 'No users found';

  @override
  String get noFriendsFound => 'Hiç arkadaş bulunamadı';

  @override
  String get delete => 'Delete';

  @override
  String get registry => 'SEÇİLMİŞLER';

  @override
  String get ofChoosenOnes => 'LİSTESİ';

  @override
  String get onlyTheTruestRideTogether => 'Gerçek sadıklar birlikte gider';

  @override
  String get noPlayersFound => 'No players found';

  @override
  String get noRequestsFound => 'No requests found';

  @override
  String get wanted => 'ARANIYOR:';

  @override
  String get goodCompany => 'İYİ ARKADAŞ GRUBU';

  @override
  String get ridingSoloAintTheWay => 'İleri sadece birlikte';

  @override
  String get requestPending => 'Request Pending';

  @override
  String get approvePending => 'Approve Pending';

  @override
  String get classic => 'classic';

  @override
  String get welcome => 'Welcome,';

  @override
  String get chat => 'Sohbet';

  @override
  String get offline => 'Offline';

  @override
  String get joinDate => 'Katılım Tarihi';

  @override
  String get report => 'Şikayet et';

  @override
  String get addToFriends => 'Arkadaşlara Ekle';

  @override
  String get currentlyOffline => 'Currently Offline';

  @override
  String get currentlyAreNotPlaying => 'Currently are not playing';

  @override
  String get currentlyArePlayingIn => 'Currently are playing in:';

  @override
  String get playersInTotal => 'Players in total';

  @override
  String get stats => 'İstatistik';

  @override
  String get overall => 'Overall';

  @override
  String get wins => 'Galibiyet';

  @override
  String get loses => 'Mağlubiyet';

  @override
  String get mafiaWins => 'Mafya Galibiyet';

  @override
  String get civilianWins => 'Sivil Galibiyet';

  @override
  String get playedRoles => 'Oynanan Roller';

  @override
  String get avatar => 'Avatar';

  @override
  String get upload => 'Yükle';

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
  String get timeForDecision => 'Şehrin kararı - ';

  @override
  String get skillsDescriptionsBeauty =>
      'Büyülemek istediğiniz oyuncuyu seçin.Bu oyuncu oy veremez ve yeteneklerini kullanamaz.';

  @override
  String get skillsDescriptionsBodyguard =>
      'Mafia ve Kamikaze\'den korumak istediğiniz oyuncuyu seçin';

  @override
  String get skillsDescriptionsBarman =>
      'Sarhoş etmek istediğiniz oyuncuyu seçin. Bu oyuncu oy veremez, konuşamaz ve yeteneklerini kullanamaz';

  @override
  String get skillsDescriptionsDoctor =>
      'Mafia saldırısından kurtaracağınız oyuncuyu seçin';

  @override
  String get skillsDescriptionsInformant =>
      'Rolünü öğrenmek istediğiniz oyuncuyu seçin';

  @override
  String get skillsDescriptionsSheriff =>
      'Rolünü öğrenmek için araştıracağınız oyuncuyu seçin';

  @override
  String get skillsDescriptionsJournalist =>
      'Aynı takımda olup olmadıklarını öğrenmek için iki oyuncu seçin';

  @override
  String get hasJoined => 'katıldı';

  @override
  String get hasLeft => 'ayrıldı';

  @override
  String get rolesGeneralDescriptionMafia =>
      'Siz — Mafia rölündesiniz ve mafya takımı adına oynuyorsunuz. Göreviniz, gündüz oylamalarında aldatma yaparak ve takımınızla birlikte gece cinayetleri işleyerek sivilleri ortadan kaldırmaktır';

  @override
  String get rolesGeneralDescriptionCivilian =>
      'Siz — Civilian rölündesiniz ve sivil takımı adına oynuyorsunuz. Göreviniz, tüm mafya üyelerini tespit etmek ve sivillerin zafere ulaşmasına yardımcı olmak için onlara karşı oy vermektir';

  @override
  String get rolesGeneralDescriptionSpy =>
      'Siz — Spy rölündesiniz ve sivil takımı adına oynuyorsunuz. Mafyanın konuşmalarını dinleyin ve mafyayı ifşa etmek için sivil oyuncularla yararlı bilgiler paylaşın';

  @override
  String get rolesGeneralDescriptionDoctor =>
      'Siz — Doctor rölündesiniz ve sivil takımı adına oynuyorsunuz. Sivilleri mafyanın gece saldırılarından kurtarmak için tıbbi becerilerinizi kullanın';

  @override
  String get rolesGeneralDescriptionBeauty =>
      'Siz — Beauty rölündesiniz ve sivil takımı adına oynuyorsunuz. Mafyayı yeteneklerini kullanmaktan ve oylamaya katılmaktan alıkoymak için onları büyüleyin';

  @override
  String get rolesGeneralDescriptionBodyguard =>
      'Siz — Bodyguard rölündesiniz ve sivil takımı adına oynuyorsunuz. Sivilleri kamikaze veya mafya saldırılarından korumak için becerilerinizi kullanın';

  @override
  String get rolesGeneralDescriptionInformant =>
      'Siz — Informant rölündesiniz ve mafya takımı adına oynuyorsunuz. Mafyayı tanımıyorsunuz, onlar da sizi tanımıyor. Sivillerin rollerini ortaya çıkarın ve önemli bilgileri mafyaya anonim olarak iletin';

  @override
  String get rolesGeneralDescriptionSheriff =>
      'Siz — Sheriff rölündesiniz ve sivil takımı adına oynuyorsunuz. Göreviniz, oyuncuları soruşturmak ve mafya üyelerini tespit etmektir';

  @override
  String get rolesGeneralDescriptionJournalist =>
      'Siz — Journalist rölündesiniz ve sivil takımı adına oynuyorsunuz. Her gece iki oyuncuyla röportaj yapın, böylece herkes onların aynı takımda mı yoksa farklı takımlarda mı olduğunu öğrensin';

  @override
  String get rolesGeneralDescriptionKamikaze =>
      'Siz — Kamikaze rölündesiniz ve mafya takımı adına oynuyorsunuz. Mafia\'yı tanımıyorsunuz, ancak mafia sizi tanıyor. Gündüz oylaması sırasında bir oyuncuyu patlatabilir ve onunla birlikte hayatınızı kaybedersiniz';

  @override
  String get rolesGeneralDescriptionBarman =>
      'Siz — Barman rölündesiniz ve mafya takımı adına oynuyorsunuz. Mafia\'yı tanımıyorsunuz, onlar da sizi tanımıyor. Sivilleri sarhoş etmek için barmenlik becerilerinizi kullanın';

  @override
  String get rolesObjectiveMafia => 'Tüm sivilleri ortadan kaldır';

  @override
  String get rolesObjectiveVicilian => 'Tüm mafya üyelerini ortadan kaldır';

  @override
  String get rolesObjectiveSpy =>
      'Mafyanın gece konuşmalarını dinleyerek sivillerin tüm mafya üyelerini ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveDoctor =>
      'Sivilleri mafya saldırılarından kurtararak sivillerin tüm mafya üyelerini ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveBeauty =>
      'Mafya üyelerini büyüleyerek sivillerin tüm mafya üyelerini ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveBodyguard =>
      'Sivilleri kamikaze ve mafya üyelerinden koruyarak sivillerin tüm mafya üyelerini ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveBarman =>
      'Sivilleri sarhoş ederek mafya üyelerinin sivilleri ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveInformant =>
      'Mafyaya önemli bilgiler ileterek sivilleri ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveSheriff =>
      'Mafya üyelerini tespit ederek sivillerin tüm mafya üyelerini ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveJournalist =>
      'Her gün röportajlar yaparak sivillerin tüm mafya üyelerini ortadan kaldırmasına yardım et';

  @override
  String get rolesObjectiveKamikaze =>
      'Önemli bir sivili patlatarak mafya üyelerinin sivilleri ortadan kaldırmasına yardım et';

  @override
  String get rolesDayPhaseMafia =>
      'Tartışmalara ve oylamalara katılın, konuşmayı mafyanın lehine yönlendirin';

  @override
  String get rolesDayPhaseCivilian =>
      'Tartışmalara ve oylamalara katılın, konuşmayı yönlendirin ve sivilleri destekleyin';

  @override
  String get rolesDayPhaseSpy =>
      'Tartışmalara ve oylamalara katılın, konuşmayı yönlendirin ve sivilleri destekleyin';

  @override
  String get rolesDayPhaseDoctor =>
      'Tartışmalara ve oylamalara katılın, konuşmayı yönlendirin ve sivilleri destekleyin';

  @override
  String get rolesDayPhaseBeauty =>
      'Tartışmalara ve oylamalara katılın, konuşmayı yönlendirin ve sivilleri destekleyin';

  @override
  String get rolesDayPhaseBodyguard =>
      'Her gün bir oyuncuyu Kamikaze veya Mafia saldırısından korumak için seçebilirsiniz';

  @override
  String get rolesDayPhaseBarman =>
      'Tartışmalara ve oylamalara katılın, konuşmayı mafyanın lehine yönlendirin';

  @override
  String get rolesDayPhaseInformant =>
      'Tartışmalara ve oylamalara katılın, konuşmayı mafyanın lehine yönlendirin';

  @override
  String get rolesDayPhaseSheriff =>
      'Tartışmalara ve oylamalara katılın, inisiyatif alın ve sivilleri zafere taşıyın';

  @override
  String get rolesDayPhaseJournalist =>
      'Tartışmalara ve oylamalara katılın, konuşmayı yönlendirin ve sivilleri destekleyin';

  @override
  String get rolesDayPhaseKamikaze =>
      'Tartışmalara katılabilirsiniz ancak oy veremezsiniz. Gündüz oylaması sırasında bir oyuncuyu patlatabilirsiniz, ancak onu bir Bodyguard korursa, yalnızca Bodyguard\'ı yanınıza alarak ölürsünüz';

  @override
  String get skill => 'Yetenek';

  @override
  String get rolesThirdDescriptionMafia =>
      'Her gece mafya bir araya gelir, tartışır ve öldürmek için bir oyuncu seçer. Spy gece konuşmalarınızı görebilir ancak mesajları kimin gönderdiğini bilemez';

  @override
  String get rolesThirdDescriptionCivilian =>
      'Gece yapacak bir işiniz yok, dinlenin';

  @override
  String get rolesThirdDescriptionSpy =>
      'Geceleri Mafia ve Informat\'ın konuşmalarını dinleyebilirsiniz ancak kimlikleri gizli kalır';

  @override
  String get rolesThirdDescriptionDoctor =>
      'Her gece mafyanın saldırı için seçtiği bir oyuncuyu kurtarabilirsiniz. Doğru oyuncuyu seçerseniz hayatı kurtarılır';

  @override
  String get rolesThirdDescriptionBodyguard =>
      'Gündüz seçtiğiniz oyuncu, gece mafya saldırılarına karşı koruma altında kalmaya devam eder';

  @override
  String get rolesThirdDescriptionBarman =>
      'Her gece bir oyuncuyu sarhoş edebilirsiniz. Sarhoş olan oyuncu bir sonraki geceye kadar oy veremez, yeteneklerini kullanamaz ve düzgün konuşamaz';

  @override
  String get rolesThirdDescriptionInformant =>
      'Her gece bir oyuncunun rolünü açığa çıkarabilir ve mafyayla iletişim kurabilirsiniz. Mafia ve Spy mesajlarınızı görebilir ancak kimliğiniz gizli kalır';

  @override
  String get rolesThirdDescriptionSheriff =>
      'Her gece bir oyuncuyu rolünü öğrenmek için soruşturabilirsiniz';

  @override
  String get rolesThirdDescriptionJournalist =>
      'Her gece iki oyuncuyla röportaj yaparak aynı takımda olup olmadıklarını öğrenebilirsiniz. Röportajın sonuçları herkes tarafından sohbette görülebilir';

  @override
  String get rolesThirdDescriptionKamikaze =>
      'Gece yapacak bir işiniz yok, dinlenin';

  @override
  String get rolesThirdDescriptionBeauty =>
      'Her gece bir oyuncuyu büyüleye bilirsiniz. Büyülenen oyuncu bir sonraki geceye kadar oy veremez ve yeteneklerini kullanamaz';

  @override
  String get rolesWinningConditionMafia =>
      'Tüm siviller öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsCivilian =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsSpy =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsDoctor =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsBeauty =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsBodyguard =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsBarman =>
      'Tüm siviller öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsInformant =>
      'Tüm siviller öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsSheriff =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsJournalist =>
      'Tüm mafya üyeleri öldüğünde kazanırsınız';

  @override
  String get rolesWinningConditionsKamikaze =>
      'Tüm siviller öldüğünde kazanırsınız';

  @override
  String get gameplayRules => 'Oyun Kuralları:';

  @override
  String get objective => 'Hedef';

  @override
  String get dayPhase => 'Gündüz Evresi';

  @override
  String get nightPhase => 'Gece Evresi';

  @override
  String get winningConditions => 'Kazanma Koşulları';

  @override
  String get night => 'Gece';

  @override
  String get itIsYou => 'Sensin';

  @override
  String get uknown => 'Bilinmeyen';

  @override
  String get underTheEffectYouCannotVoteUseAbilitiesAndYour =>
      'Under the effect: you cannot vote, use abilities, and your messages appear distorted';

  @override
  String get gameInformationPopupCured =>
      '«Güvenli» ellerdesiniz, mafya bu gece size zarar veremeyecek';

  @override
  String get gameInformationPopupInterviewed =>
      'Tebrikler — röportajın yıldızı oldunuz. Herkes şimdiden sizin ve diğer röportaj yapılanla aynı tarafta olup olmadığını konuşuyor';

  @override
  String get gameInformationPopupIntoxicated =>
      'Etki altındasınız: oy vere veya yeteneklerinizi kullanamazsınız, mesajlarınız ise bozuk görünür';

  @override
  String get gameInformationPopupInvestigated =>
      'Sheriff bilgilerinizi sisteme girdi ve artık kim olduğunuzu biliyor';

  @override
  String get gameInformationPopupRevealed =>
      'Artık hayatınız rolünüzün ne kadar önemli olduğuna bağlı';

  @override
  String get gameInformationPopupProtected =>
      'Koruma aktif olduğu sürece güvendesiniz';

  @override
  String get gameInformationPopupSatisfied =>
      'Büyülendiniz, siz oy vere ve ya yeteneklerinizi kullanamazsınız';

  @override
  String get gameInformationPopupTitleCured => 'Doctor sizi kurtardı';

  @override
  String get gameInformationPopupTitleInterviewed =>
      'Journalist sizi röportaj yaptı';

  @override
  String get gameInformationPopupTitleIntoxicated => 'Barman sizi sarhoş etti';

  @override
  String get gameInformationPopupTitleInvestigated => 'Sheriff sizi araştırdı';

  @override
  String get gameInformationPopupTitleRevealed =>
      'Informant rolünüzü ifşa etti';

  @override
  String get gameInformationPopupTitleProtected => 'Bodyguard sizi korudu';

  @override
  String get gameInformationPopupTitleSatisfied => 'Beauty sizi büyüledi';

  @override
  String get gameInformationPopupExpirationCured =>
      'Etki bir gün sonra geçecek';

  @override
  String get gameInformationPopupExpirationInterviewed =>
      'Etki oyunun sonuna kadar sürer';

  @override
  String get gameInformationPopupExpirationIntoxicated =>
      'Etki bir gün sonra geçecek';

  @override
  String get gameInformationPopupExpirationInvestigated =>
      'Etki oyunun sonuna kadar sürer';

  @override
  String get gameInformationPopupExpirationRevealed =>
      'Etki oyunun sonuna kadar sürer';

  @override
  String get gameInformationPopupExpirationProtected =>
      'Etki bir gün sonra geçecek';

  @override
  String get gameInformationPopupExpirationSatisfied =>
      'Etki bir gün sonra geçecek';

  @override
  String get youMustWriteYourReport => 'You must write your report';

  @override
  String get inviteFriend => 'Davet et';

  @override
  String get phaseMessagesDay =>
      'Yeni bir gün başlıyor. Konuş, sorgula ve şüphelen. Mafya aranızda';

  @override
  String get phaseMessageDayVoting =>
      'Karar verme zamanı. Kime en az güveniyorsunuz? Oyunuzu kullanın';

  @override
  String get phaseMessageNight =>
      'Şehir karanlığa gömülüyor. Karanlıkta mafya bir şeyler konuşuyor';

  @override
  String get phaseMessageNightVoting =>
      'Mafya uyumaz.. şu an birinin kaderi belirleniyor';

  @override
  String nicknameDidNotSurviveTheNight(String nickname) {
    return '[$nickname] geceyi atlatamadı..';
  }

  @override
  String nicknameWasEliminatedByTheTownsDecision(String nickname) {
    return '[$nickname] kasabanın kararıyla elendi..';
  }

  @override
  String kamikazeTriedToBombTargetplayerButBodyguardSavedHimher(
      String targetPlayer) {
    return 'Kamikaze [$targetPlayer]\'ı bombalamaya çalıştı, ancak Bodyguard onu kurtardı';
  }

  @override
  String kamikazeBombardedTargetplayer(String targetPlayer) {
    return 'Kamikaze [$targetPlayer]\'ı bombaladı';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnDifferentTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return 'Journalist [$firstPlayerNickname] ve [$secondPlayerNickname] ile röportaj yaptı — farklı takımlarda oynuyorlar';
  }

  @override
  String firstplayernicknameAndSecondplayernicknameAreOnSameTeams(
      String firstPlayerNickname, String secondPlayerNickname) {
    return 'Journalist [$firstPlayerNickname] ve [$secondPlayerNickname] ile röportaj yaptı — aynı takımda oynuyorlar';
  }

  @override
  String personalFeedBackToInformantAndSheriff(
      String playerNickname, String playerRole) {
    return 'Araştırmandan sonra [$playerNickname]\'nin [$playerRole] olduğunu öğrendin';
  }

  @override
  String get inGame => 'Odada';

  @override
  String get enterTheTitle => 'Oda adı gir';

  @override
  String get gameRoles => 'Oyun Rolleri';

  @override
  String get play => 'Oyna';

  @override
  String get filterOn => 'Filtre Açık';

  @override
  String get gameIsFull => 'Oda dolu';

  @override
  String get enterRoomName => ' Oda adı gir';

  @override
  String get noFriendRequests => 'Arkadaşlık isteği yok';

  @override
  String get noFriendsToSuggest => 'Önerilecek arkadaş yok';

  @override
  String get minsAgo => 'dk önce';

  @override
  String get hoursAgo => 'saat önce';

  @override
  String get daysAgo => 'gün önce';

  @override
  String get lessThanAMinute => 'Bir dakikadan az';

  @override
  String get playerProfile => 'Oyuncu Profili';

  @override
  String get status => 'Durum';

  @override
  String get lastSeen => 'Son görülme';

  @override
  String get deleteFriend => 'Çıkar';

  @override
  String get acceptRequest => 'İsteği kabul et';

  @override
  String get rejectRequest => 'İsteği reddet';

  @override
  String get cancelRequest => 'Isteği iptal et';

  @override
  String get sent => 'Gönderildi';

  @override
  String get invite => 'Davet et';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get notification => 'Notification';

  @override
  String get sentFriendRequest => ' arkadaşlık isteği gönderdi';

  @override
  String get acceptedYourRequest => ' arkadaşlık isteğinizi kabul etti';

  @override
  String get whoIsNext => 'Sıradaki kim?';

  @override
  String get invititationToGame => 'Odaya davet';

  @override
  String get invitedYouToTheGame => ' sizi şu odaya davet etti - ';

  @override
  String get accept => 'Kabul et';

  @override
  String get decline => 'Reddet';

  @override
  String get gameInformationPopupLastMafia =>
      'Tüm Mafia üyeleri öldü. Informant olarak artık Mafia\'nın gece oylamasına katılabilirsiniz';

  @override
  String get gameInformationPopupTitleLastMafia => 'Son Mafya';

  @override
  String get gameInformationPopupExpirationLastMafia =>
      'Etki oyunun sonuna kadar sürer';

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
      'Mafya bu gece sizi kurban olarak seçti. Sabahı göremediniz';

  @override
  String get iDeadSituationTwoText =>
      'Şehir oyladı ve şehrin kararıyla elendiniz';

  @override
  String get iDeadSituationThreeText =>
      'Kamikaze sizi hedef olarak seçti. Patlama hayatınıza son verdi';

  @override
  String get iDeadSituationFourText =>
      'Kendinizi hedefinizle birlikte havaya uçurdunuz. Göreviniz burada sona erdi';

  @override
  String get nightVotingCanNotSendMessage =>
      'Herkes uyurken mafya kurbanını seçiyor';

  @override
  String get nightCanNotSendMessage =>
      'Gece boyunca yalnızca mafya konuşabilir';

  @override
  String get dayVotingCanNotSendMessage =>
      'Gündüz oylaması sırasında kimse konuşamaz';

  @override
  String get unsupportedFileFormat =>
      'Bu dosya formatı avatar için desteklenmiyor';

  @override
  String get fileIsTooLargeItMustBe200kb =>
      'Dosya çok büyük. Lütfen 200 KB\'dan küçük bir avatar yükleyin';
}
