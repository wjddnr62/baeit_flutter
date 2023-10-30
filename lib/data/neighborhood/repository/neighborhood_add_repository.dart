import 'package:baeit/data/neighborhood/service/neighborhood_add_service.dart';
import 'package:baeit/data/neighborhood/service/get_address_detail_service.dart';
import 'package:baeit/data/neighborhood/service/get_address_point_service.dart';
import 'package:baeit/data/neighborhood/service/get_address_service.dart';
import 'package:baeit/data/neighborhood/neighborhood_list.dart';

class NeighborHoodAddRepository {
  static Future<dynamic> getAddressData(String keyword, {int? page}) =>
      GetAddressService(keyword: keyword).start();

  static Future<dynamic> getAddressDetailData(String address) =>
      GetAddressDetailService(address: address).start();

  static Future<dynamic> getAddressPointData(String lat, String lon) =>
      GetAddressPointService(lat: lat, lon: lon).start();

  static Future<dynamic> neighborHoodAdd(NeighborHood neighborHood) =>
      NeighborHoodAddService(neighborHood: neighborHood).start();
}
