import 'package:flutter/material.dart';
//import 'package:mafia_classic/theme/theme.dart';

class RatingsFilterDropdown extends StatefulWidget {

  final String translatedSortOption;
  final List<String> translatedOptions;
  final Function(String? newValue) onChangedEvent;

  const RatingsFilterDropdown({
    super.key, 
    required this.translatedSortOption, 
    required this.translatedOptions, 
    required this.onChangedEvent
  });

  @override
  State<RatingsFilterDropdown> createState() => _RatingsFilterDropdownState();
}

class _RatingsFilterDropdownState extends State<RatingsFilterDropdown> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      height: 40,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.translatedSortOption,
          dropdownColor: const Color.fromARGB(255, 6, 0, 63),
          items: widget.translatedOptions.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: widget.onChangedEvent,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}