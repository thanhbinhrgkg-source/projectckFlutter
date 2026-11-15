class Survey {
  final int? id;
  final int topicId;
  final String? topicName;
  final String memberId;
  final String title;
  final String description;
  final int isOpen;
  final String? createdDate;
  Survey({
    required this.id,
    required this.topicId,
    required this.topicName,
    required this.memberId,
    required this.title,
    required this.description,
    required this.isOpen,
    required this.createdDate,
  });
  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      id: map['id'],
      topicId: map['topicId'],
      topicName: map.containsKey('topicName') ? map['topicName'] : null,
      memberId: map['memberId'],
      title: map['title'],
      description: map['description'],
      isOpen: map['isOpen'],
      createdDate: map['createdDate'],
    );
  }
  Map<String, Object?> toMap() {
    return {
      'id': id,
      'topicId': topicId,
      'memberId': memberId,
      'title': title,
      'description': description,
      'isOpen': isOpen,
      if (createdDate != null) 'createdDate': createdDate,
    };
  }
}
