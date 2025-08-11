import 'package:flutter/material.dart';

void showBouncingPopupFromTop(BuildContext context, Widget child) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (_, __, ___) => child,
    transitionBuilder: (_, animation, secondaryAnimation, child) {
      final bounceIn = CurvedAnimation(
        parent: animation,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeOutQuad,
      );

      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(bounceIn),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}