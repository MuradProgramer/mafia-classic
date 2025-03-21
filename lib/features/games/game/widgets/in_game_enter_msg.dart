import 'package:flutter/material.dart';

class EnterMessage extends StatefulWidget {
  final TextEditingController messageController;
  final Function() sendMessage;

  const EnterMessage({super.key, required this.messageController, required this.sendMessage});

  @override
  State<EnterMessage> createState() => _EnterMessageState();
}

class _EnterMessageState extends State<EnterMessage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.messageController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Введите сообщение...",
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.send, color: Colors.blue),
          onPressed: widget.sendMessage,
        ),
      ],
    );
  }
}