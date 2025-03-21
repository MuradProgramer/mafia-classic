import 'package:flutter/material.dart';
import 'package:mafia_classic/features/games/game/models/models.dart';

class InGameChatBox extends StatefulWidget {
  final List<InGameMessage> messages;
  final ScrollController scrollController;
  final TextEditingController messageController;
  final Function() scrollToBottom;

  const InGameChatBox({super.key, required this.messages, required this.scrollController, required this.messageController, required this.scrollToBottom});

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
      controller: widget.scrollController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
    
        if (message.isSystemMessage) {
          // Event Message
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                message.content,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
    
        // Message from Player
        return Container(
          margin: const EdgeInsets.all(4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(message.avatarUrl),
                radius: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.nickname,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      message.content,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
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