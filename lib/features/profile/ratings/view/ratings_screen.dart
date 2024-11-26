import 'package:flutter/material.dart';

import 'package:mafia_classic/features/profile/ratings/data/data.dart';
import 'package:mafia_classic/features/profile/ratings/widgets/widgets.dart';
import 'package:mafia_classic/models/models.dart';

import 'package:mafia_classic/generated/l10n.dart';
//import 'package:mafia_classic/theme/theme.dart';

class RatingsScreen extends StatefulWidget {
  const RatingsScreen({super.key});

  @override
  State<RatingsScreen> createState() => _RatingsScreenState();
}

class _RatingsScreenState extends State<RatingsScreen> {
  String sortBy = 'Experience';
  String timeFrame = 'Today';

  String translatedSortBy = '';
  String translatedTimeFrame = '';

  bool isFirstBuild = true;

  final List<String> sortByOptions = ['Experience', 'Games Played', 'Games Won'];
  final List<String> timeFrameOptions = ['Today', 'All Time'];

  List<Player> players = getPlayers();

  void sortUsers() {
    setState(() {
      if (sortBy == 'Experience') {
        players.sort((a, b) => b.experience.compareTo(a.experience));
      } else if (sortBy == 'Games Played') {
        players.sort((a, b) => b.gamesPlayed.compareTo(a.gamesPlayed));
      } else if (sortBy == 'Games Won') {
        players.sort((a, b) => b.gamesWon.compareTo(a.gamesWon));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    sortUsers();
  }

  @override
  Widget build(BuildContext context) {

    if(isFirstBuild) {
      isFirstBuild = false;
      setState(() {
        translatedSortBy = S.of(context).experience;
        translatedTimeFrame = S.of(context).today;
      });
    }

    final theme = Theme.of(context);

    List<String> translateSortOptions() { 
      return [
        S.of(context).experience,
        S.of(context).gamesPlayed,
        S.of(context).gamesWon
      ];
    }    

    List<String> translateTimeFrameOptions() { 
      return [
        S.of(context).today,
        S.of(context).allTime
      ];
    }   

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
          title: Text(S.of(context).ratings.toUpperCase(), style: theme.textTheme.bodyMedium)
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RatingsFilterDropdown(
                      translatedSortOption: translatedSortBy, 
                      translatedOptions: translateSortOptions(),
                      onChangedEvent: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            translatedSortBy = newValue;
                            sortBy = sortByOptions[translateSortOptions().indexOf(newValue)];
                            sortUsers();
                          });
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: RatingsFilterDropdown(
                      translatedSortOption: translatedTimeFrame,
                      translatedOptions: translateTimeFrameOptions(),
                      onChangedEvent: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            translatedTimeFrame = newValue;
                            timeFrame = timeFrameOptions[translateTimeFrameOptions().indexOf(newValue)];
                            // Add logic to filter by time frame if necessary
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final user = players[index];
                    return UserRatingCard(player: user, playerIndex: index, sortBy: sortBy);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
