import 'package:flutter/material.dart';
import 'package:mafia_classic/generated/l10n.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-2.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.of(context).settings),
          automaticallyImplyLeading: false
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).language),
                  DropdownButton<String>(
                    dropdownColor: const Color.fromARGB(255, 6, 0, 63),
                    value: _selectedLanguage,
                    items: <String>['English', 'Русский', 'Türkçe', 'Azərbaycanca']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                  )
                ]
              ),
              
              const SizedBox(height: 16.0),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).password),
                  SizedBox(
                    width: 150.0,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S.of(context).changePassword),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(hintText: S.of(context).oldPassword),
                                  ),
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(hintText: S.of(context).newPassword),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ]
              ),
              
              const SizedBox(height: 16.0),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).nickname),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S.of(context).changeNickname),
                              content: TextField(
                                decoration: InputDecoration(hintText: S.of(context).writeNewNickname),
                              ),
                              actions: [
                                ElevatedButton(
                                  child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16.0),
      
              ElevatedButton(
                onPressed: () {
                  // change avatar
                },
                child: Text(S.of(context).changeAvatar, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // log out
                },
                child: Text(S.of(context).logOut, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // delete accaunt
                },
                child: Text(S.of(context).deleteAccaunt, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}