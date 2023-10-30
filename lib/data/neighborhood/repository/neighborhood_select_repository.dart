import 'package:baeit/data/neighborhood/service/neighborhood_list_service.dart';
import 'package:baeit/data/neighborhood/service/neighborhood_set_representative_service.dart';
import 'package:baeit/data/neighborhood/service/non_member_area_service.dart';

class NeighborHoodSelectRepository {
  static Future<dynamic> getNeighborHoodList() =>
      NeighborHoodListService().start();

  static Future<dynamic> setNeighborHoodRepresentative(String memberAreaUuid) =>
      NeighborHoodSetRepresentativeService(memberAreaUuid: memberAreaUuid)
          .start();

  static Future<dynamic> nonMemberArea() => NonMemberAreaService().start();
}
