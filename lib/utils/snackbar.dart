import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/mafia_classic_app.dart';

// void showTopSnackBar(String message) {
//   final navigatorState = rootNavigatorKey.currentState;
//   if (navigatorState == null) return;
  
//   late OverlayEntry overlayEntry;

//   overlayEntry = OverlayEntry(
//     builder: (context) => TopBounceSnackBar(
//       message: message,
//       onDismiss: () {
//         overlayEntry.remove();
//       },
//     ),
//   );

//   navigatorState.overlay!.insert(overlayEntry);
// }

class TopSnackBarManager {
  static OverlayEntry? _currentEntry;

  static void show(Map<String, dynamic> content, int snackType) {
    final navigatorState = rootNavigatorKey.currentState;
    if (navigatorState == null) return;

    _currentEntry?.remove();
    _currentEntry = null;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        switch (snackType) {
          case 1:
            return TopBounceSnackBar(
              message: content['message'],
              onDismiss: () {
                if (_currentEntry == entry) {
                  _currentEntry = null;
                }
                entry.remove();
              },
            );

          case 2:
            return TopBounceSnackBarNewMessage(
              avatarUrl: content['avatarUrl'],
              content: content['content'],
              nickname: content['nickname'],
              onDismiss: () {
                if (_currentEntry == entry) {
                  _currentEntry = null;
                }
                entry.remove();
              },
            );
          default:
        }

        return TopBounceSnackBar(
          message: content['message'],
          onDismiss: () {
            if (_currentEntry == entry) {
              _currentEntry = null;
            }
            entry.remove();
          },
        );
      }
    );

    _currentEntry = entry;
    navigatorState.overlay!.insert(entry);
  }

  static void dismiss() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
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


class TopBounceSnackBarNewMessage extends StatefulWidget {
  final String nickname;
  final String avatarUrl;
  final String content;
  final VoidCallback onDismiss;

  const TopBounceSnackBarNewMessage({
    super.key,
    required this.onDismiss, 
    required this.nickname, 
    required this.avatarUrl, 
    required this.content,
  });

  @override
  State<TopBounceSnackBarNewMessage> createState() => _TopBounceSnackBarNewMessage();
}

class _TopBounceSnackBarNewMessage extends State<TopBounceSnackBarNewMessage> with SingleTickerProviderStateMixin {
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
                  color: const Color(0xFF111111),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white,
                          width: 1.sp,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(widget.avatarUrl),
                        radius: 20.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nickname,
                            style: TextStyle(
                              color:const Color(0xFFFFB000),
                              fontWeight: FontWeight.bold, 
                              fontSize: 17.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                          Text(
                            widget.content,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ],
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
