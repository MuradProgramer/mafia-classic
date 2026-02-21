import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';
import 'package:mafia_classic/features/games/view/games_screen.dart';
import 'package:mafia_classic/features/widgets/player_info_popup.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

class InGameChatBox extends StatefulWidget {
  final List<InGameMessage> messages;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final Function() scrollToBottom;
  final bool isAlive;
  final String gamePhase;
  final List<Player> players;


  const InGameChatBox({
    super.key, 
    required this.messages, 
    required this.scrollController, 
    required this.messageController, 
    required this.scrollToBottom, 
    required this.isAlive, 
    required this.gamePhase, 
    required this.players,
  });

  @override
  State<InGameChatBox> createState() => _InGameChatBoxState();
}

class _InGameChatBoxState extends State<InGameChatBox> {
  bool _isUserAtBottom() {
    if (!widget.scrollController.hasClients) return false;
    const threshold = 50.0; 
    return widget.scrollController.position.maxScrollExtent -
          widget.scrollController.position.pixels < threshold;
  }

  bool _autoScroll = true;
  bool _userDragging = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.isScrollingNotifier.value) {
        _userDragging = true;
        _autoScroll = false;
      }

      if (_isUserAtBottom()) {
        _userDragging = false;
        _autoScroll = true;
      }
    });
  }

  void scrollToBottom() {
    if (widget.scrollController.hasClients) {
      final position = widget.scrollController.position.maxScrollExtent;
      Future.microtask(() {
        if (widget.scrollController.hasClients && _autoScroll) {
          widget.scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant InGameChatBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_autoScroll) {
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      controller: widget.scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
    
        if (message.type == 'System') {
          // Event Message
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Center(
              child: Text(
                message.content,
                textAlign: TextAlign.center,
                style: TextStyle(color: message.color, fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
    
        // Message from Player
        return Container(
          margin: EdgeInsets.only(left: 8.w, top: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (message.playerId == null) return;
                  if (message.playerId! <= 0) return;
                  if (message.playerId == authorizedUser.id) return;
                  showBouncingPopupFromLeft(
                    context, 
                    PlayerInfoPopup(
                      id: message.playerId!,
                      height: 727.h, 
                      width: 405.w, 
                      nickname: message.nickname ?? '',
                    )
                  ).then((_) {
                    
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: (['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white),
                      width: 0.7.sp,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(message.avatarUrl ?? ''), //!!!!!!!!!!!
                    radius: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.nickname ?? '', //!!!!!!!!!!!!
                      style: TextStyle(
                        color: !message.colorHasOpacity ? const Color(0xFFFFB000) : const Color(0xFFFFB000).withOpacity(0.5),

                        fontWeight: FontWeight.bold, 
                        fontSize: 17.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: !message.colorHasOpacity ? 
                          ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                            ? Colors.black 
                            : Colors.white 
                          : ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                            ? Colors.black.withOpacity(0.5)
                            : Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}