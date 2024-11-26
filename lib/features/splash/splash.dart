import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/features/auth/auth.dart';
//import 'package:mafia_classic/features/games/view/games_screen.dart';
//import 'package:mafia_classic/models/models.dart';
//import 'package:mafia_classic/features/profile/profile.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    //final width = MediaQuery.of(context).size.width;

    Timer(const Duration(seconds: 5), () {
      Navigator.push(context, 
        MaterialPageRoute(
          builder: (context) => const SignInScreen()   // TRUEEE
          //builder: (context) => const GamesScreen() 
          // builder: (context) => HomeScreen(user: User(
          //   nickname: 'murad',
          //   email: 'murad',
          //   avatarUrl: 'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg',
          //   accessToken: 'asdads',
          //   refreshToken: 'asads',
          //   expirationDate: DateTime.now()
          // ),)
        ) 
      );
    });

    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/2-moons-night-buildings.png"), fit: BoxFit.cover, opacity: 0.5),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: height * 0.2),
              
              child: const Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'MAFIA CLASSIC', 
                  style: TextStyle(
                    fontSize: 40, 
                    color: Colors.white, 
                    fontWeight: FontWeight.w700,
                  )
                )
              )
            ),
            Text(
              'Powered by CORPORAZ', 
              style: TextStyle(
                color: Colors.white.withOpacity(0.8), 
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        )        
      ),
    );
    
  }
}
