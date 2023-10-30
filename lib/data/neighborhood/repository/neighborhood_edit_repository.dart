import 'package:baeit/data/neighborhood/service/neighborhood_name_edit_service.dart';
import 'package:baeit/data/neighborhood/service/neighborhood_remove_service.dart';

class NeighborHoodEditRepository {
  static Future<dynamic> neighborHoodNameEdit(
          String memberAreaUuid, String townName) =>
      NeighborHoodNameEditService(
              memberAreaUuid: memberAreaUuid, townName: townName)
          .start();

  static Future<dynamic> neighborHoodRemove(String memberAreaUuid) =>
      NeighborHoodRemoveService(memberAreaUuid: memberAreaUuid).start();
}
