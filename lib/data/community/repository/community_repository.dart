import 'package:baeit/data/common/image_value.dart';
import 'package:baeit/data/community/community_create.dart';
import 'package:baeit/data/community/service/add_community_comment_service.dart';
import 'package:baeit/data/community/service/change_community_status_service.dart';
import 'package:baeit/data/community/service/check_community_chat_service.dart';
import 'package:baeit/data/community/service/community_bookmark_service.dart';
import 'package:baeit/data/community/service/community_registration_service.dart';
import 'package:baeit/data/community/service/get_community_comment_service.dart';
import 'package:baeit/data/community/service/get_community_detail_service.dart';
import 'package:baeit/data/community/service/get_community_like_sevice.dart';
import 'package:baeit/data/community/service/get_community_member_service.dart';
import 'package:baeit/data/community/service/get_community_mine_service.dart';
import 'package:baeit/data/community/service/get_community_recent_service.dart';
import 'package:baeit/data/community/service/get_community_service.dart';
import 'package:baeit/data/community/service/get_community_share_link_service.dart';
import 'package:baeit/data/community/service/remove_community_comment_service.dart';
import 'package:baeit/data/community/service/report_community_service.dart';

class CommunityRepository {
  static Future<dynamic> getCommunity(
          {String? category,
          required String lati,
          required String longi,
          String? nextCursor,
          required int orderType,
          int? size,
          String? searchText}) =>
      GetCommunityService(
              category: category,
              lati: lati,
              longi: longi,
              nextCursor: nextCursor,
              orderType: orderType,
              size: size,
              searchText: searchText)
          .start();

  static Future<dynamic> getCommunityLike({String? nextCursor}) =>
      GetCommunityLikeService(nextCursor: nextCursor).start();

  static Future<dynamic> getCommunityRecent({String? nextCursor}) =>
      GetCommunityRecentLike(nextCursor: nextCursor).start();

  static Future<dynamic> getCommunityMine(
          {String? nextCursor, String? status}) =>
      GetCommunityMineService(nextCursor: nextCursor, status: status).start();

  static Future<dynamic> getCommunityMember(
          {required String memberUuid, String? nextCursor, String? status}) =>
      GetCommunityMemberService(
              memberUuid: memberUuid, nextCursor: nextCursor, status: status)
          .start();

  static Future<dynamic> changeCommunityLike(
          {required String communityUuid, required String status}) =>
      ChangeCommunityStatusService(communityUuid: communityUuid, status: status)
          .start();

  static Future<dynamic> communityBookmark({required String communityUuid}) =>
      CommunityBookmarkService(communityUuid: communityUuid).start();

  static Future<dynamic> getCommunityDetail(
          {required String communityUuid,
          required String lati,
          required String longi,
          int? readFlag}) =>
      GetCommunityDetailService(
              communityUuid: communityUuid,
              lati: lati,
              longi: longi,
              readFlag: readFlag ?? 1)
          .start();

  static Future<dynamic> communityRegistration(
          {required CommunityCreate communityCreate}) =>
      CommunityRegistrationService(communityCreate: communityCreate).start();

  static Future<dynamic> getCommunityComment({required String communityUuid}) =>
      GetCommunityCommentService(communityUuid: communityUuid).start();

  static Future<dynamic> addCommunityComment(
          {String? communityCommentUuid,
          required String communityUuid,
          String? parentCommentUuid,
          String? rootCommentUuid,
          required String text}) =>
      AddCommunityCommentService(
              communityUuid: communityUuid,
              communityCommentUuid: communityCommentUuid,
              parentCommentUuid: parentCommentUuid,
              rootCommentUuid: rootCommentUuid,
              text: text)
          .start();

  static Future<dynamic> reportCommunity(
          {String? communityUuid,
          String? communityCommentUuid,
          required int type,
          List<Data>? images,
          required String reportText}) =>
      ReportCommunityService(
              communityUuid: communityUuid,
              communityCommentUuid: communityCommentUuid,
              type: type,
              images: images,
              reportText: reportText)
          .start();

  static Future<dynamic> removeCommunityComment(
          {required String communityCommentUuid}) =>
      RemoveCommunityCommentService(communityCommentUuid: communityCommentUuid)
          .start();

  static Future<dynamic> getCommunityShareLink(
          {required String communityUuid}) =>
      GetCommunityShareLinkService(communityUuid: communityUuid).start();

  static Future<dynamic> changeCommunityStatus(
          {required String communityUuid, required String status}) =>
      ChangeCommunityStatusService(communityUuid: communityUuid, status: status)
          .start();

  static Future<dynamic> checkCommunityChat({required String communityUuid}) =>
      CheckCommunityChatService(communityUuid: communityUuid).start();
}
