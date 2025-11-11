// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get profile => 'Профиль';

  @override
  String get games => 'Игры';

  @override
  String get create => 'Создать';

  @override
  String get settings => 'Настройки';

  @override
  String get roles => 'Роли';

  @override
  String get friends => 'Друзья';

  @override
  String get ratings => 'Рейтинг';

  @override
  String get share => 'Поделиться';

  @override
  String get mafia => 'Мафия';

  @override
  String get terrorist => 'Террорист';

  @override
  String get barman => 'Бармен';

  @override
  String get informant => 'Информатор';

  @override
  String get citizen => 'Мирный';

  @override
  String get doctor => 'Доктор';

  @override
  String get sheriff => 'Шериф';

  @override
  String get mistress => 'Любовница';

  @override
  String get journalist => 'Журналист';

  @override
  String get bodyguard => 'Телохранитель';

  @override
  String get spy => 'Шпион';

  @override
  String get rules => 'Правила';

  @override
  String get roleMafiaDescription =>
      'Мафия - неотъемлемый персонаж в игре. Каждый Мафиози знает игроков из своей команды, в отличие от мирных жителей, которые не знают, кто за кого играет. Просыпаются ночью для того, чтобы убить одного из мирных жителей, которыми также являются Доктор и Шериф.';

  @override
  String get roleTerroristDescription =>
      'Террорист - играет на стороне команды мафии, но сам не является членом мафии. Мафия знает его личность, но террорист не знает личности членов мафии. Террорист имеет одну особую способность. В любое время в течение дневного голосования террорист может взорвать любого игрока, убив и себя, и жертву. Террорист не может быть убит мафией в ночное время. Таким образом, террорист должен помочь мафии выиграть, используя свою жизнь. Независимо от того, был ли убит террорист, он получит очки опыта в конце игры, если победит мафия.';

  @override
  String get roleBarmanDescription =>
      'Бармен - играет на стороне команды мафии. Ночью он может напоить любого игрока. Таким образом пьяный игрок будет писать неразборчивый текст в чате, а также не сможет голосовать днём. Игрок трезвеет только на следующую ночь.';

  @override
  String get roleInformantDescription =>
      'Информатор - игрок команды мафии. Мафия не знает кто информатор. Ночью информатор может проверить любого игрока и раскрыть его роль. Также он может отправлять сообщения в чат мафии, при этом шпион также будет видеть сообщения информатора, но мафиози и шпион не будут видеть никнейм и фото информатора. Если погибают все мафиози то информатор ночью может проголосовать за игрока, который погибнет ночью.';

  @override
  String get roleCitizenDescription =>
      'У мирных жителей задача выявить игроков мафии. Они не имеют никаких специальных способностей. Все, что они могут сделать, это обсуждать и голосовать за того, кого убить на дневном голосовании.';

  @override
  String get roleDoctorDescription =>
      'Доктор - мирный житель. Доктор может спасти ночью от смерти одного из игроков, если его будут убивать этой ночью. Когда наступает ночь он выбирает того, кого будет лечить.';

  @override
  String get roleSheriffDescription =>
      'Шериф - мирный житель. Является одним из самых основных игроков в игре Мафия. Каждую ночь он может исследовать другого игрока и узнать кто в игре Мафиози, а кто мирный житель.';

  @override
  String get roleMistressDescription =>
      'Любовница - мирный житель. Ночью она приходит к игроку и отвлекает его от действия. Игрок, к которому пришла Любовница, не может применить свою способность ночью, а также не сможет голосовать на следующий день. Любовные чары Любовницы спадают только на следующую ночь.';

  @override
  String get roleJournalistDescription =>
      'Журналист - играет на стороне мирных. Ночью имеет возможность провести расследование и проверить любых двух игроков, играют ли они в одной команде или в разных. Результат расследования в новостях увидят все игроки.';

  @override
  String get roleBodyguardDescription =>
      'Телохранитель - играет на стороне мирных. Днём, в то время когда все общаются в чате, Телохранитель решает кого защитить от взрыва террориста или от убийства Мафией в следующую ночь. Таким образом Игрок под защитой телохранителя останется жив, если его попытается взорвать Террорист или Мафиози решат убить ночью. Защита Телохранителя действует только один раз либо днём, либо ночью, если днем террорист не пытался взорвать игрока. Если Телохранителя убили днём, то ночью он не может защитить от выстрела Мафии.';

  @override
  String get roleSpyDescription =>
      'Шпион - мирный житель. Видит о чем общается мафия ночью, но не видит личностей мафии.';

  @override
  String get rulesDescription =>
      'Игроки делятся на две команды: мирные жители, не знакомые друг с другом, и команда Мафии, находящаяся в меньшинстве, но знающая друг друга. \n\nВ команде мирных, игроки могут иметь специальные статусы. Например, среди мирных жителей, как правило, есть Шериф и Доктор\n\nИгровой процесс разделён на две фазы - \"день\" и \"ночь\".\n\nНочью просыпается мафия, \"совещается\" и убивает одного из оставшихся в живых горожан путем голосования. Житель получивший большее количество голосов погибает ночью.\n\nВ случае если голоса разделились поровну жертва выбирается случайным образом.\n\nЕсли же никто из Мафиози не проголосовал - все остаются живы.\n\nВ тоже самое время просыпается Шериф и Доктор. Шериф выбирает одного из жителей, которого желает «проверить» на причастность к мафии. Доктор выбирает кого будет лечить.\n\nВ случае если доктор вылечил игрока, за которого проголосовали Мафиози, игрок остается вживых. Но если в игре присутствует более одного мафиози, они могут проголосовать за нескольких игроков. Таким образом если доктор лечил одного из них погибнет следующий, набравший большее количество голосов.\n\nКогда наступает день объявляется, кто был убит ночью. Убитый игрок выбывает из игры, имея право на последнее, прощальное сообщение.\n\nДнём игроки обсуждают, кто из них может быть «нечестен» - причастен к мафии. В конце обсуждения все игроки голосуют кого они хотят убить на дневном голосовании.\n\nСамый подозрительный житель, набравший большее число голосов погибает.\n\nВ случае если голоса разделились поровну жертва выбирается случайным образом. Если же никто не проголосовал все остаются живы.\n\nУбитый игрок выбывает из игры, имея право на последнее, прощальное сообщение.\n\nПобеда присуждается после полного уничтожения одной из команд.\n\nЕсли убиты все мирные жители побеждает Мафия.\n\nСоответственно, в случае гибели всех Мафиози - побеждают мирные жители.';

  @override
  String get experience => 'Опыт';

  @override
  String get gamesPlayed => 'Игры';

  @override
  String get gamesWon => 'Выигрыши';

  @override
  String get today => 'За Сегодня';

  @override
  String get allTime => 'За Всё Время';

  @override
  String get searchFriends => 'Поиск друзей';

  @override
  String get enterUsername => 'Введите имя пользователя';

  @override
  String get online => 'в сети';

  @override
  String get sendRequest => 'Отправить запрос';

  @override
  String get requestAlredySent => 'Запрос уже отправлен';

  @override
  String get requests => 'Запросы в друзья';

  @override
  String get language => 'Язык';

  @override
  String get password => 'Пароль';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get oldPassword => 'Старый пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get change => 'Изменить';

  @override
  String get nickname => 'Никнейм';

  @override
  String get changeNickname => 'Изменить никнейм';

  @override
  String get writeNewNickname => 'Введите новый никнейм';

  @override
  String get changeAvatar => 'Изменить аватарку';

  @override
  String get logOut => 'Выйти из учетной записи';

  @override
  String get deleteAccaunt => 'Удалить аккаунт';

  @override
  String get email => 'Э-Почта';

  @override
  String get signIn => 'Войти';

  @override
  String get dontHaveAccauntRegister => 'Нет аккаунта? Зарегистрируйтесь';

  @override
  String get confirmPassword => 'Повторите пароль';

  @override
  String get passwordsDoNotMatch => 'Пороли не совпадают';

  @override
  String get signUp => 'Регистрация';

  @override
  String get alreadyHaveAccauntSigIn => 'Уже есть аккаунт? Войти';

  @override
  String get players => 'Игроки';

  @override
  String get min => 'Мин';

  @override
  String get max => 'Макс';

  @override
  String get join => 'Войти';

  @override
  String get gameStarted => 'Игра Началась';

  @override
  String get gatheringPlayers => 'Збор Игроков';

  @override
  String get alive => 'Живой';

  @override
  String get dead => 'Мертвый';

  @override
  String get createGame => 'Создать Игру';

  @override
  String get passwordOptional => 'Пароль (Необязательно)';

  @override
  String get roomName => 'Название Комнаты';

  @override
  String get reset => 'сбросить';

  @override
  String get filter => 'Фильтр';

  @override
  String get friendInTheRoom => 'Друзья в комнате';

  @override
  String get onlyRoomsWithAvailableSpace =>
      'Только комнаты со свободным местом';

  @override
  String get roomsWithoutAPassword => 'Комнаты без пароля';

  @override
  String get roomsWithAPassword => 'Комнаты с паролем';

  @override
  String get additionalRoles => 'Дополнительные роли';

  @override
  String get roomsWithourAdditionalRoles => 'Комнаты без дополнительных ролей';

  @override
  String get apply => 'Применить';

  @override
  String get close => 'Закрыть';

  @override
  String get remainingTime => 'Оставшееся время';

  @override
  String get seconds => 'секунд';

  @override
  String get playersInRoom => 'Игроков в комнате';

  @override
  String get enterMessage => 'Введите сообщение';

  @override
  String get alreadyHaveAnAccount => 'Уже есть аккаунт?';

  @override
  String get youMustWriteYourNickname => 'Вы должны ввести свой никнейм';

  @override
  String get yourNicknameMustContainAtLeast3Characters =>
      'Ваш никнейм должен содержать минимум 3 символа';

  @override
  String get yourNicknameCanContainLettersNumbersAnd =>
      'Ваш никнейм может содержать буквы, цифры и . _ -';

  @override
  String get youMustWriteYourEmail => 'Вы должны ввести свою почту';

  @override
  String get enterValidEmail => 'Введите корректный email';

  @override
  String get youMustWriteYourPassword => 'Вы должны ввести пароль';

  @override
  String get yourPasswordMustContainAtLeast6Characters =>
      'Ваш пароль должен содержать минимум 6 символов';

  @override
  String get youMustConfirmYourPassword => 'Вы должны подтвердить пароль';

  @override
  String get passwordsAreNotMatching => 'Пароли не совпадают';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get sorryConnectionWithServerTimeouted =>
      'Извините, соединение с сервером прервалось...';

  @override
  String get playerWithThisEmailAlreadyExist =>
      'Игрок с таким email уже существует';

  @override
  String get playerWithThisNicknameAlreadyExist =>
      'Игрок с таким никнеймом уже существует';

  @override
  String get sorrySomethingBadHappened => 'Извините, что-то пошло не так...';

  @override
  String get userWithThisEmailDoesNotExist =>
      'Пользователь с таким email не существует';

  @override
  String get emailOrPasswordIsInvalid => 'Email или пароль неверны';

  @override
  String get dontHaveAnAccount => 'Нет аккаунта?';

  @override
  String get forgotPassword => 'Забыли пароль';

  @override
  String get playersInTheRoom => 'Игроки в комнате';

  @override
  String get civilian => 'Мирный';

  @override
  String get day => 'День';

  @override
  String get isYourDestiny => 'твоя судьба';

  @override
  String get useSkill => 'Навык';

  @override
  String get civiliansAreWithUs => 'Мирные жители с нами';

  @override
  String get bombard => 'Взорвать';

  @override
  String get vote => 'Выбрать';

  @override
  String get myMoveIsMade => 'Голосовать';

  @override
  String get iAcceptTheWeightOfMyChoice => 'Я принимаю тяжесть своего выбора';

  @override
  String get cure => 'Лечить';

  @override
  String get satisfy => 'Очаровать';

  @override
  String get protect => 'Защитить';

  @override
  String get intoxicate => 'Опьянить';

  @override
  String get reveale => 'Раскрыть';

  @override
  String get investigate => 'Проверить';

  @override
  String get interview => 'Опросить';

  @override
  String get mafias => 'Мафия';

  @override
  String get civilians => 'Мирные';

  @override
  String get pickYourTarget => 'Мафия выбирает жертву - ';

  @override
  String get iveChosenNoRegrets => 'Я выбрал. Без сожалений';

  @override
  String get choose => 'Выбрать';

  @override
  String get enterTheMessage => 'Введите сообщение...';

  @override
  String get lobby => 'Лобби';

  @override
  String get search => 'Поиск...';

  @override
  String get filterOff => 'Фильтр выключен';

  @override
  String get noAvailableGames => 'Нет доступных игр...';

  @override
  String get youArePlayingHere => 'Вы играете здесь';

  @override
  String get youDiedHere => 'Вы погибли здесь';

  @override
  String get show => 'Показать';

  @override
  String get allPlayers => 'Все игроки';

  @override
  String get areHere => 'здесь';

  @override
  String get defeated => 'Побеждён';

  @override
  String get stillHere => 'Всё ещё здесь';

  @override
  String get enterTheName => 'Введите имя';

  @override
  String get on => 'вкл';

  @override
  String get off => 'выкл';

  @override
  String get enterThePassword => 'Введите пароль';

  @override
  String get numberOfPlayers => 'Количество игроков';

  @override
  String get extraRoles => 'Дополнительные роли';

  @override
  String get beauty => 'Красавица';

  @override
  String get bartender => 'Бармен';

  @override
  String get roomsWith => 'Комнаты с:';

  @override
  String get availableSpots => 'Свободные места';

  @override
  String get friendsIn => 'Друзья в';

  @override
  String get access => 'Доступ';

  @override
  String get mixed => 'Микс';

  @override
  String get open => 'Открытый';

  @override
  String get private => 'Приват';

  @override
  String get includedRoles => 'Включённые роли:';

  @override
  String get lover => 'Влюблённый';

  @override
  String get starting => 'Начало:';

  @override
  String get waiting => 'Ожидание Игроков';

  @override
  String get trustedIndividuals => 'НАДЁЖНЫЕ ЛИЦА';

  @override
  String get justiceRidesWithUs => 'Справедливость с нами.';

  @override
  String get noUsersFound => 'Пользователи не найдены';

  @override
  String get noFriendsFound => 'Друзья не найдены';

  @override
  String get delete => 'Удалить';

  @override
  String get registry => 'РЕЕСТР';

  @override
  String get ofChoosenOnes => 'ИЗБРАННЫХ';

  @override
  String get onlyTheTruestRideTogether => 'Только самые верные идут вместе.';

  @override
  String get noPlayersFound => 'Игроки не найдены';

  @override
  String get noRequestsFound => 'Запросы не найдены';

  @override
  String get wanted => 'РАЗЫСКИВАЕТСЯ:';

  @override
  String get goodCompany => 'ХОРОШАЯ КОМПАНИЯ';

  @override
  String get ridingSoloAintTheWay => 'Играть в одиночку — не путь.';

  @override
  String get requestPending => 'Запрос ожидает подтверждения';

  @override
  String get approvePending => 'Одобрение ожидает';

  @override
  String get classic => 'Классический';

  @override
  String get welcome => 'Начнём';

  @override
  String get chat => 'Чат';

  @override
  String get offline => 'Не в сети';

  @override
  String get joinDate => 'Дата регистрации';

  @override
  String get report => 'Пожаловаться';

  @override
  String get addToFriends => 'Добавить в друзья';

  @override
  String get currentlyOffline => 'Сейчас не в сети';

  @override
  String get currentlyAreNotPlaying => 'Сейчас не играет';

  @override
  String get currentlyArePlayingIn => 'Сейчас играет в:';

  @override
  String get playersInTotal => 'Всего игроков';

  @override
  String get stats => 'Статистика';

  @override
  String get overall => 'Общее';

  @override
  String get wins => 'Победа';

  @override
  String get loses => 'Поражения';

  @override
  String get mafiaWins => 'Победа мафии';

  @override
  String get civilianWins => 'Победа мирных';

  @override
  String get playedRoles => 'Сыгранные роли';

  @override
  String get avatar => 'Аватар';

  @override
  String get upload => 'Загрузить';

  @override
  String get soundEffects => 'Звуковые эффекты';

  @override
  String get onOn => 'Вкл';

  @override
  String get offOff => 'Выкл';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get currentAvatar => 'Текущий аватар';

  @override
  String get uploadNew => 'Загрузить новый';

  @override
  String get uploadAnother => 'Загрузить другой';

  @override
  String get currentNickname => 'Текущий никнейм';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get title => 'Название';

  @override
  String get youMustWriteATitleOfTheReport =>
      'Вы должны написать название отчёта';

  @override
  String get typeHere => 'Пишите здесь';

  @override
  String get inCaseOfAnyProblemPleaseNotifyUs =>
      'В случае любой проблемы, пожалуйста, сообщите нам';

  @override
  String get recover => 'Восстановить';

  @override
  String get writeDownTheEmailToGetACode => 'Введите email, чтобы получить код';

  @override
  String get next => 'Далее';

  @override
  String get back => 'Назад';

  @override
  String get youMustWriteTheSmsCode => 'Вы должны ввести SMS-код';

  @override
  String get sms => 'SMS';

  @override
  String get codeMustBeNumeric => 'Код должен быть числовым';

  @override
  String get codeMustBe6Charactes => 'Код должен состоять из 6 символов';

  @override
  String gameTerroristExplosion(String playerNickname) {
    return 'Terrorist tried to bomb [\$playerNickname], but bodyguard saved him/her';
  }

  @override
  String get timeForDecision => 'Дневное голосование - ';

  @override
  String get skillsDescriptionsBeauty =>
      'Выберите игрока, которого хотите очаровать. Он не сможет голосовать и использовать способности';

  @override
  String get skillsDescriptionsBodyguard =>
      'Выберите игрока, которого хотите защитить от мафии и террориста';

  @override
  String get skillsDescriptionsBarman =>
      'Выберите игрока, которого хотите опьянить. Он не сможет голосовать, говорить и использовать способности';

  @override
  String get skillsDescriptionsDoctor =>
      'Выберите игрока, которого вы вылечите при нападении мафии';

  @override
  String get skillsDescriptionsInformant =>
      'Выберите игрока, чью роль хотите раскрыть';

  @override
  String get skillsDescriptionsSheriff =>
      'Выберите двух игроков, чтобы узнать, в одной они команде или нет';

  @override
  String get skillsDescriptionsJournalist =>
      'Выберите игрока для расследования, чтобы узнать его роль';

  @override
  String get hasJoined => 'зашел';

  @override
  String get hasLeft => 'вышел';
}
