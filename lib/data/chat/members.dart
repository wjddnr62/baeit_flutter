class Members {
  final String chatRoomMemberUuid;
  final MemberData member;
  final int unreadCnt;
  final int classWriterFlag;
  final int communityWriterFlag;
  int noticeReceiveFlag;
  int messageCnt;

  Members(
      {required this.chatRoomMemberUuid,
      required this.member,
      required this.unreadCnt,
      required this.classWriterFlag,
      required this.communityWriterFlag,
      required this.noticeReceiveFlag,
      required this.messageCnt});

  factory Members.fromJson(data) {
    return Members(
        chatRoomMemberUuid: data['chatRoomMemberUuid'],
        member: MemberData.fromJson(data['member']),
        unreadCnt: data['unreadCnt'],
        classWriterFlag: data['classWriterFlag'],
        communityWriterFlag: data['communityWriterFlag'],
        noticeReceiveFlag: data['noticeReceiveFlag'],
        messageCnt: data['messageCnt']);
  }
}

class MemberData {
  final String memberUuid;
  final String nickName;
  final String? profile;
  final String? introText;

  MemberData(
      {required this.memberUuid,
      required this.nickName,
      this.profile,
      this.introText});

  factory MemberData.fromJson(data) {
    return MemberData(
        memberUuid: data['memberUuid'],
        nickName: data['nickName'],
        profile: data['profile'],
        introText: data['introText']);
  }
}
