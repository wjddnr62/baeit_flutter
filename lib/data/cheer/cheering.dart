class Cheering {
  final String cheeringAreaUuid;
  final String status;
  final int cheeringCnt;
  final int goalCnt;
  final int shareCnt;
  final int selfCheeringFlag;

  Cheering(
      {required this.cheeringAreaUuid,
      required this.status,
      required this.cheeringCnt,
      required this.goalCnt,
      required this.shareCnt,
      required this.selfCheeringFlag});

  factory Cheering.fromJson(data) {
    return Cheering(
        cheeringAreaUuid: data['cheeringAreaUuid'],
        status: data['status'],
        cheeringCnt: data['cheeringCnt'],
        goalCnt: data['goalCnt'],
        shareCnt: data['shareCnt'],
        selfCheeringFlag: data['selfCheeringFlag']);
  }
}
