import 'package:flutter/material.dart';
import 'package:mafia_classic/features/profile/roles/models/models.dart';

import 'role_card_popup.dart';

class RoleCard extends StatefulWidget {
  final String roleName;
  final double width;
  final double height;

  const RoleCard({super.key, required this.roleName, required this.width, required this.height});

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () => {
          showGeneralDialog(
            context: context,
            barrierDismissible: true,
            barrierLabel: "Dismiss",
            barrierColor: Colors.black.withOpacity(0.7),
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) {
              return RoleCardPopup(roleName: widget.roleName);
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve: Curves.elasticOut,
                reverseCurve: Curves.easeInBack,
              );

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1.0, 0.0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              );
            },
          )
                                          
        },
        child: Image.asset(
          width: widget.width,
          height: widget.height,
          'assets/images/role-card-${widget.roleName}.png',
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}