import 'dart:async';

import 'package:flutter/material.dart';

void showTopSnackBar(BuildContext context, String message) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => TopBounceSnackBar(
      message: message,
      onDismiss: () {
        overlayEntry.remove();
      },
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}

class TopBounceSnackBar extends StatefulWidget {
  final String message;
  final VoidCallback onDismiss;

  const TopBounceSnackBar({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  State<TopBounceSnackBar> createState() => _TopBounceSnackBarState();
}

class _TopBounceSnackBarState extends State<TopBounceSnackBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800), 
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -2), 
      end: const Offset(0.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
      reverseCurve: Curves.elasticOut, 
    ));

    _controller.forward();

    _timer = Timer(const Duration(seconds: 3), () {
      _dismiss();
    });
  }

  void _dismiss() async {
    if (!mounted) return;
    
    _timer?.cancel();

    await _controller.reverse();

    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.translucent, 
          child: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00695C),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        softWrap: true,
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
