import 'package:flutter/material.dart';

void showBouncingPopupFromTop(BuildContext context, Widget child) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (context, animation, secondaryAnimation) => child,
    
    transitionBuilder: (context, animation, secondaryAnimation, child) {
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

void showBouncingPopupFromLeft(BuildContext context, Widget child) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Dismiss",
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 800),
    pageBuilder: (context, animation, secondaryAnimation) => child,

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
  );
}