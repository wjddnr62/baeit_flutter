class PageInfo {
  final int page;
  final int pageBlock;
  final int rowPerPage;
  final int pagePerBlock;
  final int totalRow;
  final int virtualNum;
  final int totalPage;
  final int totalBlock;
  final int startPage;
  final int endPage;
  final int isPrevBlock;
  final int isNextBlock;
  final int startIdx;

  PageInfo(
      {required this.page,
      required this.pageBlock,
      required this.rowPerPage,
      required this.pagePerBlock,
      required this.totalRow,
      required this.virtualNum,
      required this.totalPage,
      required this.totalBlock,
      required this.startPage,
      required this.endPage,
      required this.isPrevBlock,
      required this.isNextBlock,
      required this.startIdx});

  factory PageInfo.fromJson(data) {
    return PageInfo(
        page: data['page'],
        pageBlock: data['pageBlock'],
        rowPerPage: data['rowPerPage'],
        pagePerBlock: data['pagePerBlock'],
        totalRow: data['totalRow'],
        virtualNum: data['virtualNum'],
        totalPage: data['totalPage'],
        totalBlock: data['totalBlock'],
        startPage: data['startPage'],
        endPage: data['endPage'],
        isPrevBlock: data['isPrevBlock'],
        isNextBlock: data['isNextBlock'],
        startIdx: data['startIdx']);
  }
}
