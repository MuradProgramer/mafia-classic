// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "additionalRoles":
            MessageLookupByLibrary.simpleMessage("Additional Roles"),
        "alive": MessageLookupByLibrary.simpleMessage("Alive"),
        "allTime": MessageLookupByLibrary.simpleMessage("All Time"),
        "alreadyHaveAccauntSigIn": MessageLookupByLibrary.simpleMessage(
            "Alredy have an accaunt? Sign In"),
        "apply": MessageLookupByLibrary.simpleMessage("Apply"),
        "barman": MessageLookupByLibrary.simpleMessage("Barman"),
        "bodyguard": MessageLookupByLibrary.simpleMessage("Bodyguard"),
        "change": MessageLookupByLibrary.simpleMessage("Change"),
        "changeAvatar": MessageLookupByLibrary.simpleMessage("Change avatar"),
        "changeNickname":
            MessageLookupByLibrary.simpleMessage("Change nickname"),
        "changePassword":
            MessageLookupByLibrary.simpleMessage("Change password"),
        "citizen": MessageLookupByLibrary.simpleMessage("Citizen"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "confirmPassword":
            MessageLookupByLibrary.simpleMessage("Confirm Password"),
        "create": MessageLookupByLibrary.simpleMessage("Create"),
        "createGame": MessageLookupByLibrary.simpleMessage("Create Game"),
        "dead": MessageLookupByLibrary.simpleMessage("Dead"),
        "deleteAccaunt": MessageLookupByLibrary.simpleMessage("Delete accaunt"),
        "doctor": MessageLookupByLibrary.simpleMessage("Doctor"),
        "dontHaveAccauntRegister": MessageLookupByLibrary.simpleMessage(
            "Don\'t have an accaunt? Sign up"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "enterMessage": MessageLookupByLibrary.simpleMessage("Enter message"),
        "enterUsername": MessageLookupByLibrary.simpleMessage("Enter username"),
        "experience": MessageLookupByLibrary.simpleMessage("Experience"),
        "filter": MessageLookupByLibrary.simpleMessage("Filter"),
        "friendInTheRoom":
            MessageLookupByLibrary.simpleMessage("Friends in the room"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends"),
        "gameStarted": MessageLookupByLibrary.simpleMessage("Game Started"),
        "games": MessageLookupByLibrary.simpleMessage("Games"),
        "gamesPlayed": MessageLookupByLibrary.simpleMessage("Games Played"),
        "gamesWon": MessageLookupByLibrary.simpleMessage("Games Won"),
        "gatheringPlayers":
            MessageLookupByLibrary.simpleMessage("Gathering Players"),
        "informant": MessageLookupByLibrary.simpleMessage("Informant"),
        "join": MessageLookupByLibrary.simpleMessage("Join"),
        "journalist": MessageLookupByLibrary.simpleMessage("Journalist"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "logOut": MessageLookupByLibrary.simpleMessage("Log out"),
        "mafia": MessageLookupByLibrary.simpleMessage("Mafia"),
        "max": MessageLookupByLibrary.simpleMessage("Max"),
        "min": MessageLookupByLibrary.simpleMessage("Min"),
        "mistress": MessageLookupByLibrary.simpleMessage("Mistress"),
        "newPassword": MessageLookupByLibrary.simpleMessage("New password"),
        "nickname": MessageLookupByLibrary.simpleMessage("Nickname"),
        "oldPassword": MessageLookupByLibrary.simpleMessage("Old password"),
        "online": MessageLookupByLibrary.simpleMessage("online"),
        "onlyRoomsWithAvailableSpace": MessageLookupByLibrary.simpleMessage(
            "Only rooms with available space"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwordOptional":
            MessageLookupByLibrary.simpleMessage("Password (Optional)"),
        "passwordsDoNotMatch":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "players": MessageLookupByLibrary.simpleMessage("Players"),
        "playersInRoom":
            MessageLookupByLibrary.simpleMessage("Players in the Room"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "ratings": MessageLookupByLibrary.simpleMessage("Ratings"),
        "remainingTime": MessageLookupByLibrary.simpleMessage("Remaining time"),
        "requestAlredySent":
            MessageLookupByLibrary.simpleMessage("Request alredy sent"),
        "requests": MessageLookupByLibrary.simpleMessage("Requests"),
        "reset": MessageLookupByLibrary.simpleMessage("Reset"),
        "roleBarmanDescription": MessageLookupByLibrary.simpleMessage(
            "Barman - plays on the side of the mafia team. At night, he can make any player drunk. Thus, a drunk player will write illegible text in the chat, and will also not be able to vote during the day. The player will sober up only the next night."),
        "roleBodyguardDescription": MessageLookupByLibrary.simpleMessage(
            "Bodyguard - plays on the side of the civilians. During the day, while everyone is chatting, the Bodyguard decides who to protect from a terrorist explosion or from being killed by the Mafia the next night. Thus, the Player under the protection of the bodyguard will remain alive if he is tried blow up The Terrorist or Mafioso will decide to kill at night. The Bodyguard\'s protection only applies once, either during the day or at night, if the terrorist did not try to blow up the player during the day. If the Bodyguard was killed during the day, then at night he cannot protect against the Mafia\'s shot."),
        "roleCitizenDescription": MessageLookupByLibrary.simpleMessage(
            "Civilians are tasked with identifying mafia players. They have no special abilities. All they can do is discuss and vote on who to kill in the day\'s vote."),
        "roleDoctorDescription": MessageLookupByLibrary.simpleMessage(
            "The Doctor is a civilian. The Doctor can save one of the players from death at night if he is killed that night. When night comes, he chooses who he will treat."),
        "roleInformantDescription": MessageLookupByLibrary.simpleMessage(
            "The informant is a player of the mafia team. The mafia does not know who the informant is. At night, the informant can check any player and reveal his role. He can also send messages to the mafia chat, and the spy will also see the informant\'s messages, but the mafioso and the spy will not see the nickname and photo of the informant. If all the mafiosi die, then the informant can vote for the player who will die at night."),
        "roleJournalistDescription": MessageLookupByLibrary.simpleMessage(
            "Journalist - plays on the side of the civilians. At night, he has the opportunity to conduct an investigation and check any two players, whether they play on the same team or on different ones. All players will see the result of the investigation in the news."),
        "roleMafiaDescription": MessageLookupByLibrary.simpleMessage(
            "The Mafia is a registered character in the game. Each team of Mafiosi knows the players from their country, unlike the citizens of the world, who do not know who is playing for whom. They wake up at night in order to kill one of the inhabitants of the world, also known like them. Doctor and Sheriff."),
        "roleMistressDescription": MessageLookupByLibrary.simpleMessage(
            "The Mistress is a civilian. At night, she comes to the player and distracts him from the action. The player to whom the Mistress came cannot use his ability at night, and also will not be able to vote the next day. The Mistress\'s love spell wears off only on next night."),
        "roleSheriffDescription": MessageLookupByLibrary.simpleMessage(
            "The Sheriff is a civilian. He is one of the most important players in the Mafia game. Every night he can examine another player and find out who is a Mafioso in the game and who is a civilian."),
        "roleSpyDescription": MessageLookupByLibrary.simpleMessage(
            "A spy is a civilian. He sees what the mafia talks about at night, but does not see the personalities of the mafia."),
        "roleTerroristDescription": MessageLookupByLibrary.simpleMessage(
            "Terrorist - plays for the Mafia team, but is not a member of the Mafia himself. The Mafia knows his identity, but the terrorist does not know the identity of the Mafia members. The Terrorist has one special ability. At any time during the day voting, the terrorist can blow up anyone player by killing both himself and the victim. The terrorist cannot be killed by the mafia at night. So the terrorist must help the mafia win using his life. Regardless of whether the terrorist is killed, he will receive experience points at the end of the game if. The mafia will win."),
        "roles": MessageLookupByLibrary.simpleMessage("Roles"),
        "roomName": MessageLookupByLibrary.simpleMessage("Room Name"),
        "roomsWithAPassword":
            MessageLookupByLibrary.simpleMessage("Rooms with a password"),
        "roomsWithourAdditionalRoles": MessageLookupByLibrary.simpleMessage(
            "Rooms without additional roles"),
        "roomsWithoutAPassword":
            MessageLookupByLibrary.simpleMessage("Rooms without a password"),
        "rules": MessageLookupByLibrary.simpleMessage("Rules"),
        "rulesDescription": MessageLookupByLibrary.simpleMessage(
            "The players are divided into two teams: civilians who do not know each other, and the Mafia team, which is in the minority but knows each other. \n\nIn a civilian team, players can have special statuses. For example, among civilians, as a rule, there is a Sheriff and a Doctor\n\nThe gameplay is divided into two phases - \"day\" and \"night\".\n\nAt night the mafia wakes up, \"consults\" and kills one from the surviving townspeople by voting. The resident who receives the most votes dies at night.\n\nIf the votes are divided equally, the victim is chosen at random.\n\nIf none of the Mafiosi voted, everyone remains alive.\n\nAt the same time, the Sheriff and the Doctor wake up. The sheriff chooses one of the residents whom he wants to “test” for involvement in the mafia. The doctor chooses who he will treat.\n\nIf the doctor cured the player who was voted for by the Mafiosi, the player remains alive. But if there is more than one mafioso in the game, they can vote for multiple players. Thus, if the doctor treated one of them, the next one with the most votes will die.\n\nWhen day comes, it is announced who was killed during the night. The killed player is eliminated from the game, having the right to a final farewell message.\n\nDuring the day, players discuss which of them may be “dishonest” - involved in the mafia. At the end of the discussion, all players vote who they want to kill in the daily vote.\n\nThe most suspicious resident with the most votes dies.\n\nIf the votes are evenly divided, the victim is chosen at random. If no one voted, everyone remains alive.\n\nThe killed player is eliminated from the game, having the right to the last, farewell message.\n\nVictory is awarded after the complete destruction of one of the teams.\n\nIf all civilians are killed, the Mafia wins.\n\nAccordingly, in the event of the death of all Mafiosi - civilians win."),
        "searchFriends": MessageLookupByLibrary.simpleMessage("Search friends"),
        "seconds": MessageLookupByLibrary.simpleMessage("Seconds"),
        "sendRequest": MessageLookupByLibrary.simpleMessage("Send request"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "sheriff": MessageLookupByLibrary.simpleMessage("Sheriff"),
        "signIn": MessageLookupByLibrary.simpleMessage("Sign In"),
        "signUp": MessageLookupByLibrary.simpleMessage("Sign Up"),
        "spy": MessageLookupByLibrary.simpleMessage("Spy"),
        "terrorist": MessageLookupByLibrary.simpleMessage("Terrorist"),
        "today": MessageLookupByLibrary.simpleMessage("Today"),
        "writeNewNickname":
            MessageLookupByLibrary.simpleMessage("Write new nickname")
      };
}
