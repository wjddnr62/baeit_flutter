class Push {
  final String? messageType;
  final String? targetPage;
  final String? body;
  final String? title;
  final String? pushUuid;
  final String? noticeUuid;
  final String? chatRoomUuid;
  final String? classUuid;
  final String? feedbackUuid;
  final String? communityUuid;
  final int? fcmMessageId;
  final int? seq;
  final String? soundName;
  final String? category;

  Push(
      {this.messageType,
      this.targetPage,
      this.body,
      this.title,
      this.pushUuid,
      this.noticeUuid,
      this.chatRoomUuid,
      this.classUuid,
      this.communityUuid,
      this.feedbackUuid,
      this.fcmMessageId,
      this.seq,
      this.soundName,
      this.category});

  factory Push.fromJson(data) {
    return Push(
        messageType:
            data['messageType'] == null ? '' : data['messageType'].toString(),
        targetPage: data['targetPage'] == null ? '' : data['targetPage'],
        body: data['body'] == null ? '' : data['body'],
        title: data['title'] == null ? '' : data['title'],
        noticeUuid: data['noticeUuid'],
        pushUuid: data['pushUuid'],
        chatRoomUuid: data['chatRoomUuid'],
        classUuid: data['classUuid'],
        communityUuid: data['communityUuid'],
        feedbackUuid: data['feedbackUuid'],
        fcmMessageId: data['fcmMessageId'] != null
            ? int.parse(data['fcmMessageId'])
            : null,
        seq: data['seq'] != null ? int.parse(data['seq']) : null,
        soundName: data['soundName'] != null ? data['soundName'] : null,
    category: data['category'] != null ? data['category'] : null);
  }

  toMap() {
    Map<String, dynamic> data = {};
    if (messageType != null) data.addAll({'messageType': messageType});

    if (targetPage != null) data.addAll({'targetPage': targetPage});

    if (body != null) data.addAll({'body': body});

    if (title != null) data.addAll({'title': title});

    if (pushUuid != null) data.addAll({'pushUuid': pushUuid});

    if (noticeUuid != null) data.addAll({'noticeUuid': noticeUuid});

    if (chatRoomUuid != null) data.addAll({'chatRoomUuid': chatRoomUuid});

    if (classUuid != null) data.addAll({'classUuid': classUuid});

    if (feedbackUuid != null) data.addAll({'feedbackUuid': feedbackUuid});

    if (communityUuid != null) data.addAll({'communityUuid': communityUuid});

    if (category != null) data.addAll({'category': category});
    return data;
  }
}
