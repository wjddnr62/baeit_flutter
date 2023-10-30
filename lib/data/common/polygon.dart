import 'package:baeit/config/base_service.dart';

class Polygon {
  final int hangCode;
  final Geometry geometry;
  final String type;

  // final Properties properties;

  Polygon({
    required this.hangCode,
    required this.geometry,
    required this.type,
    // required this.properties
  });

  factory Polygon.fromJson(data) {
    return Polygon(
      hangCode: data['hangCode'],
      geometry: Geometry.fromJson(data['geometry']),
      type: data['type'],
      // properties: Properties.fromJson(data['properties'])
    );
  }
}

class Geometry {
  final String type;
  final List<dynamic> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(data) {
    return Geometry(
        type: data['type'],
        coordinates: data['type'] == 'MultiPolygon'
            ? data['coordinates']
            : data['coordinates'][0]);
  }
}

class Properties {
  final int? objectId;
  final String? admNm;
  final String? admCd;
  final String? admCd2;
  final String? sgg;
  final String? sido;
  final String? sidoNm;
  final String? temp;
  final String? sggNm;

  Properties(
      {this.objectId = 0,
      this.admNm,
      this.admCd,
      this.admCd2,
      this.sgg,
      this.sido,
      this.sidoNm,
      this.temp,
      this.sggNm});

  factory Properties.fromJson(data) {
    return Properties(
        objectId: data['OBJECTID'],
        admNm: data['adm_nm'],
        admCd: data['adm_cd'],
        admCd2: data['adm_cd2'],
        sgg: data['sgg'],
        sido: data['sido'],
        sidoNm: data['sidoNm'],
        temp: data['temp'],
        sggNm: data['sggNm']);
  }
}
