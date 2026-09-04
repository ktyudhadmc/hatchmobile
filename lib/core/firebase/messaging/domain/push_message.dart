class PushMessage {
  const PushMessage({
    required this.id,
    required this.data,
    this.title,
    this.body,
    this.sentAt,
  });

  final String? id;
  final String? title;
  final String? body;
  final DateTime? sentAt;
  final Map<String, String> data;
}
