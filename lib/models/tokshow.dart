import 'package:tokshop/models/auction.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/models/user.dart';

import 'product.dart';

class Tokshow {
  Tokshow({
    this.activeauction,
    this.pinned,
    this.thumbnail,
    this.repeat,
    this.hosts,
    this.viewers,
    this.date,
    this.started,
    this.status,
    this.hlsUrl,
    this.egressId,
    this.id,
    this.owner,
    this.title,
    this.token,
    this.roomType,
    this.invitedhostIds,
    this.speakersSentNotifications,
    this.recordingIds,
    this.activeTime,
    this.category,
    this.resourceId,
    this.recordingsid,
    this.description,
    this.previewVideos,
    this.streamOptions,
    this.recordingUid,
    this.giveAway,
    this.ended,
    this.recordedRoom,
    this.allowchat,
    this.allowrecording,
  });

  double? discount = 0.0;
  Auction? activeauction;
  Product? pinned;
  GiveAway? giveAway;
  String? previewVideos = '';
  List<UserModel>? hosts = [];
  List<String>? invitedhostIds = [];
  List<UserModel>? viewers = [];
  ProductCategory? category;
  String? egressId;
  bool? started;
  bool? status;
  String? repeat;
  String? id;
  String? thumbnail;
  int? activeTime;
  UserModel? owner;
  String? hlsUrl = "";
  String? title = "";
  int? date = 0;
  String? recordingUid = "";
  String? resourceId = "";
  List<String>? recordingIds = [];
  List<String>? speakersSentNotifications = [];
  String? description = "";
  String? recordingsid = "";
  List<dynamic>? streamOptions = [];
  String? roomType;
  dynamic token;
  bool? ended;
  bool? recordedRoom;
  bool? allowrecording;
  bool? allowchat;

  factory Tokshow.fromJson(Map<String, dynamic> json) {
    return Tokshow(
      giveAway: json["pinned_giveaway"] is Map
          ? GiveAway.fromJson(json["pinned_giveaway"])
          : null,
      pinned: json["pinned"] is Map ? Product.fromJson(json["pinned"]) : null,
      hosts: json["hosts"] == null
          ? []
          : List<UserModel>.from(json["hosts"].map((x) =>
              x.toString().length > 40
                  ? UserModel.fromJson(x)
                  : UserModel(id: x))),
      viewers: json["viewers"] == null
          ? []
          : List<UserModel>.from(json["viewers"].map((x) =>
              x.toString().length > 50
                  ? UserModel.fromJson(x)
                  : UserModel(id: x))),
      status: json["status"],
      hlsUrl: json["hlsUrl"] ?? "",
      id: json["_id"] ?? "",
      egressId: json["egressId"] ?? "",
      owner: json["owner"] == null
          ? null
          : json["owner"].toString().length > 40
              ? UserModel.fromJson(json["owner"])
              : UserModel(id: json["owner"]),
      title: json["title"] ?? "",
      recordingIds: json["recordingIds"] == null ||
              json["recordingIds"].toString().length > 30
          ? []
          : List<String>.from(json["recordingIds"].map((x) => x)),
      speakersSentNotifications: json["speakersSentNotifications"] == null
          ? []
          : List<String>.from(json["speakersSentNotifications"].map((x) => x)),
      invitedhostIds: json["invitedhostIds"] == null
          ? []
          : List<String>.from(json["invitedhostIds"].map((x) => x)),
      token: json["token"],
      started: json["started"] ?? false,
      repeat: json["repeat"] ?? "",
      recordingsid: json["recordingsid"] ?? "",
      description: json["description"] ?? "",
      thumbnail: json["thumbnail"] ?? "",
      category: json['category'] == null
          ? null
          : ProductCategory.fromJson(json['category']),
      recordingUid: json["recordingUid"] ?? "",
      previewVideos: json["preview_videos"] ?? '',
      streamOptions: json["streamOptions"] ?? [],
      resourceId: json["resourceId"] ?? "",
      date: json["date"] ?? 0,
      activeTime: json["activeTime"] ?? DateTime.now().millisecondsSinceEpoch,
      roomType: json["roomType"] ?? "",
      activeauction:
          json["activeauction"] != null && json["activeauction"] is Map
              ? Auction.fromJson(json["activeauction"])
              : null,
      ended: json["ended"] ?? false,
      recordedRoom: json["recordedRoom"] ?? false,
      allowchat: json["allowchat"] ?? true,
      allowrecording: json["allowrecording"] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        "hosts": hosts == null
            ? []
            : List<dynamic>.from(hosts!.map((x) => x.toJson())),
        "viewers": viewers == null
            ? []
            : List<dynamic>.from(viewers!.map((x) => x.toJson())),
        "status": status,
        "_id": id,
        "owner": owner?.toJson(),
        "title": title,
        "token": token,
        "roomType": roomType,
        "recordingsid": recordingsid,
        "recordingUid": recordingUid,
        "resourceId": resourceId,
        "allowrecording": allowrecording ?? true,
        "allowchat": allowchat ?? true,
      };
}

bool isInteger(num value) => value is int || value == value.roundToDouble();
