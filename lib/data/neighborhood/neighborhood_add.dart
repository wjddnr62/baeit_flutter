class AddressData {
  final Results results;

  AddressData({required this.results});

  factory AddressData.fromJson(data) {
    return AddressData(results: Results.fromJson(data['results']));
  }
}

class Results {
  final Common common;
  final List<Juso> juso;

  Results({required this.common, required this.juso});

  factory Results.fromJson(data) {
    return Results(
        common: Common.fromJson(data['common']),
        juso: data['juso'] != null
            ? (data['juso'] as List).map((e) => Juso.fromJson(e)).toList()
            : []);
  }
}

class Common {
  final int totalCount;
  final int currentPage;
  final int countPerPage;
  final String errorCode;
  final String errorMessage;

  Common(
      {required this.totalCount,
      required this.currentPage,
      required this.countPerPage,
      required this.errorCode,
      required this.errorMessage});

  factory Common.fromJson(data) {
    return Common(
        totalCount: int.parse(data['totalCount']),
        currentPage: data['currentPage'],
        countPerPage: data['countPerPage'],
        errorCode: data['errorCode'],
        errorMessage: data['errorMessage']);
  }
}

class Juso {
  final String? roadAddr;
  final String? roadAddrPart1;
  final String? roadAddrPart2;
  final String? jibunAddr;
  final String? zipNo;
  final String? bdNm;
  final String? siNm;
  final String? sggNm;
  final String? emdNm;
  final String? rn;

  Juso(
      {this.roadAddr,
      this.roadAddrPart1,
      this.roadAddrPart2,
      this.jibunAddr,
      this.zipNo,
      this.bdNm,
      this.siNm,
      this.sggNm,
      this.emdNm,
      this.rn});

  factory Juso.fromJson(data) {
    return Juso(
        roadAddr: data['roadAddr'],
        roadAddrPart1: data['roadAddrPart1'],
        roadAddrPart2: data['roadAddrPart2'],
        jibunAddr: data['jibunAddr'],
        zipNo: data['zipNo'],
        bdNm: data['bdNm'],
        siNm: data['siNm'],
        sggNm: data['sggNm'],
        emdNm: data['emdNm'],
        rn: data['rn']);
  }
}

class AddressDetailData {
  final String addressName;
  final String addressType;
  final String lat;
  final String lon;
  final RoadAddress? roadAddress;
  final Address address;

  AddressDetailData(
      {required this.addressName,
      required this.addressType,
      required this.lat,
      required this.lon,
      this.roadAddress,
      required this.address});

  factory AddressDetailData.fromJson(data) {
    return AddressDetailData(
        addressName: data['address_name'],
        addressType: data['address_type'],
        lat: data['y'],
        lon: data['x'],
        roadAddress: data['road_address'] == null
            ? null
            : RoadAddress.fromJson(data['road_address']),
        address: Address.fromJson(data['address']));
  }
}

class AddressPointData {
  final RoadAddress? roadAddress;
  final Address? address;

  AddressPointData({required this.roadAddress, required this.address});

  factory AddressPointData.fromJson(data) {
    return AddressPointData(
        roadAddress: data != null && data['road_address'] != null
            ? RoadAddress.fromJson(data['road_address'])
            : null,
        address: data != null && data['address'] != null
            ? Address.fromJson(data['address'])
            : null);
  }
}

class RoadAddress {
  final String? addressName;
  final String? region1depthName;
  final String? region2depthName;
  final String? region3depthName;
  final String? roadName;
  final String? buildingName;

  RoadAddress(
      {this.addressName,
      this.region1depthName,
      this.region2depthName,
      this.region3depthName,
      this.roadName,
      this.buildingName});

  factory RoadAddress.fromJson(data) {
    return RoadAddress(
        addressName: data['address_name'] ?? '',
        region1depthName: data['region_1depth_name'] ?? '',
        region2depthName: data['region_2depth_name'] ?? '',
        region3depthName: data['region_3depth_name'] ?? '',
        roadName: data['road_name'] ?? '',
        buildingName: data['building_name'] ?? '');
  }
}

class Address {
  final String? addressName;
  final String? region1depthName;
  final String? region2depthName;
  final String? region3depthName;
  final String? region3depthHName;
  final String? hCode;
  final String? mainAddressNo;
  final String? subAddressNo;

  Address(
      {this.addressName,
      this.region1depthName,
      this.region2depthName,
      this.region3depthName,
      this.region3depthHName,
      this.hCode,
      this.mainAddressNo,
      this.subAddressNo});

  factory Address.fromJson(data) {
    return Address(
        addressName: data['address_name'],
        region1depthName: data['region_1depth_name'],
        region2depthName: data['region_2depth_name'],
        region3depthName: data['region_3depth_name'],
        region3depthHName: data['region_3depth_h_name'],
        hCode: data['h_code'],
        mainAddressNo: data['main_address_no'],
        subAddressNo: data['sub_address_no']);
  }
}
