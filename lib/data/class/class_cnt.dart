class ClassCnt {
  final int likeCnt;
  final int viewCnt;
  final int madeCnt;
  final int communityCnt;

  ClassCnt(
      {required this.likeCnt,
      required this.viewCnt,
      required this.madeCnt,
      required this.communityCnt});

  factory ClassCnt.fromJson(data) {
    return ClassCnt(
        likeCnt: data['classLikeCnt'] + data['communityLikeCnt'],
        viewCnt: data['classViewCnt'] + data['communityViewCnt'],
        madeCnt: data['classSaveCnt'],
        communityCnt: data['communitySaveCnt']);
  }
}
