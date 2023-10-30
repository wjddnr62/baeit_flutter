class NotificationData {
  final String notificationMessageUuid;
  final String type;
  final String title;
  final String body;
  final String image;
  final DateTime createDate;
  final DateTime updateDate;
  final int readFlag;
  final String memberUuid;
  final String cursor;
  final String largeIcon;
  final dynamic data;

  NotificationData(
      {required this.notificationMessageUuid,
      required this.type,
      required this.title,
      required this.body,
      required this.image,
      required this.createDate,
      required this.updateDate,
      required this.readFlag,
      required this.memberUuid,
      required this.cursor,
      required this.largeIcon,
      required this.data});

  factory NotificationData.fromJson(data) {
    return NotificationData(
        notificationMessageUuid: data['notificationMessageUuid'],
        type: data['type'],
        title: data['title'],
        body: data['body'],
        image: data['image'],
        createDate: DateTime.parse(data['createDate']),
        updateDate: DateTime.parse(data['updateDate']),
        readFlag: data['readFlag'],
        memberUuid: data['memberUuid'],
        cursor: data['cursor'],
        largeIcon: data['largeIcon'],
        data: data['data']);
  }
}
