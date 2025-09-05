import 'package:tokshop/models/ShippingAddress.dart';
import 'package:tokshop/models/payment_method.dart';
import 'package:tokshop/models/payout_method.dart';

import 'bank.dart';

class UserModel {
  List<UserModel> followers = [];
  List<dynamic> reviewer = [];
  List<String> blocked = [];
  List<UserModel> following = [];
  ShippingAddress? address;
  bool? seller;
  double? wallet;
  double? pendingWallet;
  String? gender;
  String? logintype;
  String? currecy;
  String? roomuid;
  String? country;
  String? currentRoom;
  int? agorauid;
  String? id;
  List<PayoutMethod>? payoutMethods;
  Bank? bank;
  UserPaymentMethod? defaultpaymentmethod;
  String? firstName;
  String? lastName;
  String? bio;
  String? userName;
  String? email;
  String? phonenumber;
  int? followersCount;
  int? followingCount;
  String? profilePhoto;
  String? coverPhoto;
  int? memberShip;
  bool? receivemessages;
  String? accessToken;
  int? tokshows;
  String? authtoken;
  String? salescount;
  double? walletPending;
  double? averagereviews;
  bool? accountDisabled;

  UserModel({
    this.address,
    this.averagereviews,
    this.walletPending,
    this.salescount,
    this.defaultpaymentmethod,
    this.seller,
    this.gender,
    this.country,
    this.followersCount,
    this.followingCount,
    this.blocked = const [],
    this.reviewer = const [],
    this.followers = const [],
    this.following = const [],
    this.wallet,
    this.coverPhoto,
    this.logintype,
    this.currentRoom,
    this.bank,
    this.payoutMethods,
    this.agorauid,
    this.id,
    this.firstName,
    this.lastName,
    this.bio,
    this.userName,
    this.email,
    this.accessToken,
    this.authtoken,
    this.currecy,
    this.receivemessages,
    this.phonenumber,
    this.profilePhoto,
    this.tokshows,
    this.memberShip,
    this.accountDisabled,
  });

  UserModel.fromPlayer(this.id, this.firstName, this.lastName, this.bio,
      this.userName, this.phonenumber, this.profilePhoto, this.country);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      followers: json["followers"] == null
          ? []
          : List<UserModel>.from(json["followers"].map((x) =>
              x.toString().length > 40
                  ? UserModel.fromJson(x)
                  : UserModel(id: x))),
      blocked: json["blocked"] == null
          ? []
          : List<String>.from(json["blocked"].map((x) => x)),
      following: json["following"] == null
          ? []
          : List<UserModel>.from(json["following"].map((x) =>
              x.toString().length > 40
                  ? UserModel.fromJson(x)
                  : UserModel(id: x))),
      bank: json["bank.dart"] is Map ? Bank.fromJson(json["bank.dart"]) : null,
      wallet: json['wallet'] is int
          ? double.parse(json['wallet'].toString())
          : json['wallet'],
      defaultpaymentmethod: json["defaultpaymentmethod"] != null &&
              json["defaultpaymentmethod"].toString().length > 40
          ? UserPaymentMethod.toJson(json["defaultpaymentmethod"])
          : null,
      address: json["address"] is Map
          ? ShippingAddress.fromJson(json["address"])
          : null,
      receivemessages: json["receivemessages"] ?? false,
      salescount: "0",
      walletPending: json["walletPending"] is int
          ? double.parse(json["walletPending"].toString())
          : json["walletPending"] == null
              ? 0.0
              : json["walletPending"].toDouble(),
      averagereviews: json["averagereviews"] is int
          ? double.parse(json["averagereviews"].toString())
          : json["averagereviews"] == null
              ? 0.0
              : json["averagereviews"].toDouble(),
      reviewer: json["reviewer"] ?? [],
      currecy: json["currecy"] ?? "USD",
      gender: json["gender"] ?? "",
      country: json["country"] ?? '',
      seller: json["seller"] ?? false,
      coverPhoto: json["coverPhoto"] ?? "",
      logintype: json["logintype"] ?? "emailpassword",
      tokshows: json["tokshows"] ?? 0,
      agorauid: json["agorauid"] ?? 0,
      currentRoom: json["currentRoom"] ?? "",
      id: json["_id"],
      firstName: json["firstName"],
      lastName: json["lastName"],
      bio: json["bio"],
      userName: json["userName"],
      email: json["email"],
      phonenumber: json["phonenumber"],
      profilePhoto: json["profilePhoto"],
      memberShip: json["memberShip"],
      followersCount: json["followersCount"],
      followingCount: json["followingCount"],
      authtoken: json["authtoken"] ?? "",
      accessToken: json["accessToken"] ?? "",
      accountDisabled: json["accountDisabled"] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        "followingCount": followingCount,
        "followersCount": followersCount,
        "wallet": wallet,
        "currentRoom": currentRoom,
        "_id": id,
        "roomuid": roomuid,
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "userName": userName,
        "email": email,
        "phonenumber": phonenumber,
        "profilePhoto": profilePhoto,
        "memberShip": memberShip,
        "accountDisabled": accountDisabled,
      };
}
