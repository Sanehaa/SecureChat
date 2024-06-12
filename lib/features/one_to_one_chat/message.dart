class Message {
  const Message({
    required this.message,
    required this.senderUsername,
    required this.sentAt,
    required this.path
  });
  final String message;
  final String senderUsername;
  final DateTime sentAt;
  final String path;

  factory Message.fromJson(Map<String, dynamic> message) {
    return Message(
      message: message['message'],
      path: message['path'] ?? '',
      senderUsername: message['senderUsername'],
      sentAt: DateTime.fromMillisecondsSinceEpoch(message['sentAt']),
    );
  }

  @override
  String toString() {
    return 'Message: { message: $message, senderUsername: $senderUsername, sentAt: $sentAt, path: $path }';
  }
}