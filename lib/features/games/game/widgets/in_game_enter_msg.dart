import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/utils/snackbar.dart';

class EnterMessage extends StatefulWidget {
  final TextEditingController messageController;
  final Function() sendMessage;
  final bool canISendMessage;
  final String gamePhase;

  const EnterMessage({
    super.key, 
    required this.messageController, 
    required this.sendMessage, 
    required this.canISendMessage, 
    required this.gamePhase
  });

  @override
  State<EnterMessage> createState() => _EnterMessageState();
}

class _EnterMessageState extends State<EnterMessage> {
  @override
  Widget build(BuildContext context) {
    final double deviceHeight = MediaQuery.of(context).size.height;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: deviceHeight * 0.05,
            decoration: BoxDecoration(
              color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? const Color(0xFFFFECC5) : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 5.w, bottom: 6.h),
              child: TextField(
                controller: widget.messageController,
                style: TextStyle(color: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? Colors.black : Colors.white, fontSize: 15.sp),
                cursorColor: ['Day', 'DayVoting'].any((e) => e == widget.gamePhase) ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                decoration: InputDecoration(
                  hintText: '${S.of(context).enterMessage}...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
        //widget.canISendMessage 
        IconButton(
          icon: Icon(Icons.send, color: Colors.white, size: 25.sp),
          onPressed: () {
            if (widget.canISendMessage) {
              widget.sendMessage();
              return;
            }
            TopSnackBarManager.show({"content": "You are not elligible to send message right now"}, 5);
          },
        ) 
          //: const SizedBox(),
      ],
    );
  }
}