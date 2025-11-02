import 'package:flutter/material.dart';
import 'package:mafia_classic/features/profile/roles/models/models.dart';

import 'role_card_popup.dart';

class RoleCard extends StatefulWidget {
  final String roleName;
  final double width;
  final double height;
  final bool isMini;

  const RoleCard({
    super.key, 
    required this.roleName, 
    required this.width, 
    required this.height, 
    required this.isMini
  });

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
              return RoleCardPopup(roleName: widget.roleName, closeType: 1);
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
          ).then((value) {
            FocusScope.of(context).unfocus();
          })
                                          
        },
        child: Image.asset(
          width: widget.width,
          height: widget.height,
          (widget.isMini) 
          ? 'assets/images/role-card-mark-${widget.roleName.toLowerCase()}.png'
          : 'assets/images/role-card-${widget.roleName.toLowerCase()}.png',
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}