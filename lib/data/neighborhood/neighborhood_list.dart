class NeighborHood {
  final String? memberAreaUuid;
  final String? buildingName;
  final String? hangCode;
  final String? hangName;
  final String? lati;
  final String? longi;
  final String? roadAddress;
  String? townName;
  final String? zipAddress;
  int? representativeFlag;
  final int? addressEupmyeondongNo;
  final String? sidoName;
  final String? sigunguName;
  final String? eupmyeondongName;

  NeighborHood(
      {this.memberAreaUuid,
      this.buildingName,
      this.hangCode,
      this.hangName,
      this.lati,
      this.longi,
      this.roadAddress,
      this.townName,
      this.zipAddress,
      this.representativeFlag,
      this.addressEupmyeondongNo,
      this.sidoName,
      this.sigunguName,
      this.eupmyeondongName});

  factory NeighborHood.fromJson(data) {
    return NeighborHood(
        memberAreaUuid: data['memberAreaUuid'],
        buildingName: data['buildingName'],
        hangCode: data['hangCode'],
        hangName: data['hangName'],
        lati: data['lati'].toString(),
        longi: data['longi'].toString(),
        roadAddress: data['roadAddress'],
        townName: data['townName'],
        zipAddress: data['zipAddress'],
        representativeFlag: data['representativeFlag'] ?? 1,
        addressEupmyeondongNo: data['addressEupmyeondongNo'],
        sidoName: data['sidoName'],
        sigunguName: data['sigunguName'],
        eupmyeondongName: data['eupmyeondongName']);
  }

  toMapAll() {
    Map<String, Object> data = {};
    if (buildingName != null) {
      data.addAll({'buildingName': buildingName!});
    }
    if (hangCode != null) {
      data.addAll({'hangCode': hangCode!});
    }
    if (hangName != null) {
      data.addAll({'hangName': hangName!});
    }
    if (lati != null) {
      data.addAll({'lati': lati!});
    }
    if (longi != null) {
      data.addAll({'longi': longi!});
    }
    if (roadAddress != null) {
      data.addAll({'roadAddress': roadAddress!});
    }
    if (townName != null) {
      data.addAll({'townName': townName!});
    }
    if (zipAddress != null) {
      data.addAll({'zipAddress': zipAddress!});
    }
    if (addressEupmyeondongNo != null) {
      data.addAll({'addressEupmyeondongNo': addressEupmyeondongNo!});
    }
    if (representativeFlag != null) {
      data.addAll({'representativeFlag': representativeFlag!});
    }
    if (sidoName != null) {
      data.addAll({'sidoName': sidoName!});
    }
    if (sigunguName != null) {
      data.addAll({'sigunguName': sigunguName!});
    }
    if (eupmyeondongName != null) {
      data.addAll({'eupmyeondongName': eupmyeondongName!});
    }
    return data;
  }

  toMap() {
    Map<String, Object> data = {};
    if (buildingName != null) {
      data.addAll({'buildingName': buildingName!});
    }
    if (hangCode != null) {
      data.addAll({'hangCode': hangCode!});
    }
    if (lati != null) {
      data.addAll({'lati': lati!});
    }
    if (longi != null) {
      data.addAll({'longi': longi!});
    }
    if (roadAddress != null) {
      data.addAll({'roadAddress': roadAddress!});
    }
    if (townName != null) {
      data.addAll({'townName': townName!});
    }
    if (zipAddress != null) {
      data.addAll({'zipAddress': zipAddress!});
    }
    return data;
  }
}
