import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';

class InGameChatBox extends StatefulWidget {
  final List<InGameMessage> messages;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final Function() scrollToBottom;
  final bool isAlive;
  final String gamePhase;

  const InGameChatBox({
    super.key, 
    required this.messages, 
    required this.scrollController, 
    required this.messageController, 
    required this.scrollToBottom, 
    required this.isAlive, 
    required this.gamePhase
  });

  @override
  State<InGameChatBox> createState() => _InGameChatBoxState();
}

class _InGameChatBoxState extends State<InGameChatBox> {
  @override
  void didUpdateWidget(covariant InGameChatBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.scrollToBottom();
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
                style: TextStyle(color: const Color(0xFFFFB000), fontSize: 14.sp, fontWeight: FontWeight.bold),
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
              CircleAvatar(
                backgroundImage: NetworkImage(message.avatarUrl ?? ''), //!!!!!!!!!!!
                radius: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.nickname ?? '', //!!!!!!!!!!!!
                      style: TextStyle(
                        color: widget.isAlive ? const Color(0xFFFFB000) : const Color(0xFFFFB000).withOpacity(0.7), 
                        fontWeight: FontWeight.bold, 
                        fontSize: 17.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                    Text(
                      message.content,
                      style: TextStyle(
                        color: widget.isAlive ? 
                          ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                            ? Colors.black 
                            : Colors.white 
                          : ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) 
                            ? Colors.black.withOpacity(0.7)
                            : Colors.white.withOpacity(0.7),
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