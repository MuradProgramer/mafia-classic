import 'package:flutter/material.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/models/models.dart';

class ProfileScreen extends StatefulWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  final String title = 'MAFIA CLASSIC';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        return false; // Prevent back navigation
      },
      child: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-2.png"), fit: BoxFit.cover, opacity: 0.4),
        ),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: theme.appBarTheme.backgroundColor,
            title: Text(widget.title, style: theme.appBarTheme.titleTextStyle),
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
        
              // PROFILE DATA
        
              Container(
                margin: const EdgeInsets.only(top: 30, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(
                      widget.user.avatarUrl,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Text(widget.user.nickname, style: theme.textTheme.bodyMedium,)
                        ],
                      )
                    ),
                  ],
                ),
              ),
        
              // BUTTONS PART
        
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [           
              
                    ////////// FRIENDS //////////
                     
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        key: const Key("Friends Button"),
                        style: theme.elevatedButtonTheme.style,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/profile/friends');
                        },
                        child: Text(
                          S.of(context).friends, 
                          style: theme.textTheme.labelSmall
                        ),
                      ),
                    ),
                    
                    ////////// ROLES //////////
                    
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        key: const Key("Roles Button"),
                        style: theme.elevatedButtonTheme.style,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/profile/roles');
                        },
                        child: Text(
                          S.of(context).roles, 
                          style: theme.textTheme.labelSmall
                        ),
                      ),
                    ),
              
                    ////////// RATINGS //////////
              
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        key: const Key("Ratings Button"),
                        style: theme.elevatedButtonTheme.style,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/profile/ratings');
                        },
                        child: Text(
                          S.of(context).ratings, 
                          style: theme.textTheme.labelSmall
                        ),
                      ),
                    ),
              
                    ////////// SHARE //////////
              
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        key: const Key("Share Button"),
                        style: theme.elevatedButtonTheme.style,
                        onPressed: () {
                          Navigator.of(context).pushNamed('/profile');
                        },
                        child: Text(
                          S.of(context).share, 
                          style: theme.textTheme.labelSmall
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        
              // JUST FOR DESIGN
              SizedBox(
                height: deviceHeight * 0.05,
              )
            ]
          ),
        ),
      ),
    );
  }
}