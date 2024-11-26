class Message {
  final String from;
  final String text;
  final DateTime date;

  Message({
    required this.from, 
    required this.text, 
    required this.date
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      from: json['from'],
      text: json['text'],  
      date: DateTime.parse(json['date']),  
    );
  }
}