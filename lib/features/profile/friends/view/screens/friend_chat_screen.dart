import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mafia_classic/models/models.dart';
import 'package:mafia_classic/services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final Friendship friend;

  const ChatScreen({super.key, required this.friend});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // List<Message> messages = [
  //   Message(from: "JohnDoe", text: "Привет!", date: DateTime.now().subtract(Duration(minutes: 5))),
  //   Message(from: "Я", text: "Привет! Как дела?", date: DateTime.now().subtract(Duration(minutes: 2))),
  //   Message(from: "JohnDoe", text: "Всё отлично, спасибо!", date: DateTime.now().subtract(Duration(minutes: 1))),
  // ];

  List<Message>? messages = [];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _getMessages();
    // Scroll to the bottom when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _getMessages() async {
    messages = await GetIt.I<ApiService>().getMessages(widget.friend.nickname);
    messages ??= <Message>[];
    setState(() {});
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messages?.add(
          Message(from: "Я", text: _controller.text, date: DateTime.now()),
        );
        _controller.clear();
      });
      // Scroll to the bottom after sending a message
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                child: Text(widget.friend.nickname[0]),
              ),
              const SizedBox(width: 10),
              Text(widget.friend.nickname),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: messages == null ? 0 : messages!.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(
                      message: messages![index],
                      isMe: messages![index].from == "Я",
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Введите сообщение...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onSubmitted: (value) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendMessage,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.from,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${message.date.hour}:${message.date.minute}, ${message.date.day}/${message.date.month}/${message.date.year}',
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.black54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
