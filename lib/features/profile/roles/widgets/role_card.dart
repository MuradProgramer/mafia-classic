import 'package:flutter/material.dart';
import 'package:mafia_classic/features/profile/roles/models/models.dart';

import 'role_popup.dart';

class RoleCard extends StatelessWidget {
  final Role role;

  const RoleCard({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: RolePopup(role: role),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset(role.imagePath, height: 50, fit: BoxFit.cover),
            const SizedBox(width: 16),
            Text(role.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}