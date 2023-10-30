class Comment {
  final String communityCommentUuid;
  final String communityUuid;
  final String text;
  final String status;
  final String eupmyeondongName;
  final DateTime createDate;
  int editFlag;
  final int mineFlag;
  final int reportFlag;
  List<Comment> list;
  final CommentMember writeMember;
  final CommentMember? parentWriterMember;
  final String? parentCommunityCommentUuid;
  final String? rootCommunityCommentUuid;

  Comment(
      {required this.communityCommentUuid,
      required this.communityUuid,
      required this.text,
      required this.status,
      required this.eupmyeondongName,
      required this.createDate,
      required this.editFlag,
      required this.mineFlag,
      required this.reportFlag,
      required this.list,
      required this.writeMember,
      this.parentWriterMember,
      this.parentCommunityCommentUuid,
      this.rootCommunityCommentUuid});

  factory Comment.fromJson(data) {
    return Comment(
        communityCommentUuid: data['communityCommentUuid'],
        communityUuid: data['communityUuid'],
        text: data['text'],
        status: data['status'],
        eupmyeondongName: data['eupmyeondongName'],
        createDate: DateTime.parse(data['createDate']),
        editFlag: data['editFlag'],
        mineFlag: data['mineFlag'],
        reportFlag: data['reportFlag'],
        writeMember: CommentMember.fromJson(data['writerMember']),
        parentWriterMember: data['parentWriterMember'] != null
            ? CommentMember.fromJson(data['parentWriterMember'])
            : null,
        parentCommunityCommentUuid: data['parentCommunityCommentUuid'],
        rootCommunityCommentUuid: data['rootCommunityCommentUuid'],
        list: (data['list'] as List).length == 0
            ? []
            : (data['list'] as List).map((e) => Comment.fromJson(e)).toList());
  }
}

class CommentMember {
  final String memberUuid;
  final String nickName;
  final String? phone;
  final String? profile;
  final String status;

  CommentMember(
      {required this.memberUuid,
      required this.nickName,
      this.phone,
      this.profile,
      required this.status});

  factory CommentMember.fromJson(data) {
    return CommentMember(
        memberUuid: data['memberUuid'],
        nickName: data['nickName'],
        status: data['status'],
        phone: data['phone'],
        profile: data['profile']);
  }
}
