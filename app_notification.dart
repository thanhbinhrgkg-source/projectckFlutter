class AppNotification {
  final int id;
  final String memberId;
  final String title;
  final String content;
  final String type;
  final int? refId;
  final bool isRead;
  final String createdDate;
  AppNotification({
    required this.id,
    required this.memberId,
    required this.title,
    required this.content,
    required this.type,
    required this.refId,
    required this.isRead,
    required this.createdDate,
  });
  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      memberId: map['memberId'],
      title: map['title'],
      content: map['content'] ?? '',
      type: map['type'] ?? '',
      refId: map['refId'],
      isRead: map['isRead'] == 1,
      createdDate: map['createdDate'] ?? '',
    );
  }
}
