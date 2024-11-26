import 'package:flutter/material.dart';
import 'package:mafia_classic/features/profile/roles/data/data.dart';
import 'package:mafia_classic/features/profile/roles/widgets/widgets.dart';
import 'package:mafia_classic/generated/l10n.dart';

class RolesScreen extends StatelessWidget {
  const RolesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = getRoles(context);

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
          title: Text(S.of(context).roles.toUpperCase(), style: theme.textTheme.bodyMedium)
        ),
        body: ListView.builder(
          itemCount: roles.length,
          itemBuilder: (context, index) {
            return RoleCard(role: roles[index]);
          }
        )
      ),
    );
  }
}