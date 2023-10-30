import 'package:baeit/data/common/polygon.dart';

class MapData {
  final String name;
  final int cnt;
  final double lati;
  final double longi;
  final int? addressSidoNo;
  final int? addressSigunguNo;
  final int? addressEupmyeondongNo;
  // final Geometry geometry;

  MapData(
      {required this.name,
      required this.cnt,
      required this.lati,
      required this.longi,
      this.addressSidoNo,
      this.addressSigunguNo,
      this.addressEupmyeondongNo,
      // required this.geometry
      });

  factory MapData.fromJson(data) {
    return MapData(
        name: data['name'],
        cnt: data['cnt'],
        lati: double.parse(data['lati'].toString()),
        longi: double.parse(data['longi'].toString()),
        addressSidoNo: data['addressSidoNo'],
        addressSigunguNo: data['addressSigunguNo'],
        addressEupmyeondongNo: data['addressEupmyeondongNo'],
        // geometry: Geometry.fromJson(data['geometry'])
    );
  }

  toMap() {
    Map<String, dynamic> data = {};
    data.addAll({'name': name});
    data.addAll({'cnt': cnt});
    data.addAll({'lati': lati});
    data.addAll({'longi': longi});
    data.addAll({'addressSidoNo': addressSidoNo});
    data.addAll({'addressSigunguNo': addressSigunguNo});
    data.addAll({'addressEupmyeondongNo':addressEupmyeondongNo});
    return data;
  }
}
