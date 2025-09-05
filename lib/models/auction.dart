import 'package:firebase_auth/firebase_auth.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/models/shippingProfile.dart';
import 'package:tokshop/models/user.dart';

class Auction {
  UserModel? winner;
  UserModel? owner;
  String? id;
  double? quantity;
  int? higestbid;
  UserModel? winning;
  List<Bid>? bids;
  Product? product;
  String? tokshow;
  int? newbaseprice;
  int? increaseBidBy;
  int baseprice;
  int duration;
  int? startedTime;
  bool? sudden;
  bool? started;
  bool? ended;
  DateTime? endTime;
  Auction(
      {this.winner,
      this.increaseBidBy,
      this.higestbid,
      this.owner,
      this.winning,
      this.newbaseprice,
      this.bids,
      this.tokshow,
      this.quantity,
      this.sudden,
      required this.baseprice,
      required this.duration,
      this.startedTime,
      this.id,
      this.started,
      this.endTime,
      this.product,
      this.ended});

  factory Auction.fromJson(var json) {
    return Auction(
        id: json["_id"],
        winner:
            json["winner"] != null ? UserModel.fromJson(json["winner"]) : null,
        newbaseprice:
            json["newbaseprice"] ?? 0 ?? json["baseprice"].toDouble() ?? 0,
        higestbid: json["higestbid"] ?? 0,
        winning: json["winning"] != null
            ? UserModel.fromJson(json["winning"])
            : null,
        endTime:
            json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
        bids: json["bids"] != null
            ? List<Bid>.from(json["bids"].map((x) => Bid.fromJson(x)))
            : [],
        owner: json["owner"] == null ? null : UserModel.fromJson(json["owner"]),
        tokshow: json["tokshow"] == null ? null : json["tokshow"],
        sudden: json["sudden"] ?? false,
        quantity: json["quantity"] is double
            ? json["quantity"]
            : json["quantity"].toDouble() ?? 0.0,
        increaseBidBy: json["increaseBidBy"] ?? 0,
        baseprice: json["baseprice"] ?? 0,
        product: json['product'] is Map
            ? Product(
                name: json["product"]['name'],
                id: json["product"]['_id'],
                shipping_profile: json["product"] != null &&
                        json["product"]['shipping_profile'] != null
                    ? ShippingProfile.fromJson(
                        json["product"]['shipping_profile'])
                    : null)
            : null,
        duration: json["duration"] ?? 30,
        startedTime: json["startedTime"] ?? 0,
        started: json["started"] ?? false,
        ended: json["ended"] ?? false);
  }

  toMap() {
    return {
      "_id": id,
      "winner": winner,
      "higestbid": higestbid,
      "winning": winning,
      "bids": bids!.map((e) => e.toJson()).toList(),
      "tokshow": tokshow,
      "sudden": sudden,
      "owner": owner,
      "increaseBidBy": increaseBidBy,
      "baseprice": baseprice,
      "product": product?.toJson(),
      "duration": duration,
      "startedTime": startedTime,
      "started": started,
      "ended": ended
    };
  }

  int getNextAmountBid() {
    if (bids!.isEmpty) return baseprice;
    List allbids = [];
    for (var element in bids!) {
      allbids.add(element.amount);
    }
    return allbids.reduce((curr, next) => curr > next ? curr : next) +
        increaseBidBy;
  }

  int getHighestBidder() {
    if (bids!.isEmpty) return 0;
    List allbids = [];
    for (var element in bids!) {
      allbids.add(element.amount);
    }
    return allbids.reduce((curr, next) => curr > next ? curr : next);
  }

  Bid getCurrentUserBid() {
    return bids!.firstWhere(
        (e) => e.bidder.id == FirebaseAuth.instance.currentUser!.uid);
  }
}

class Bid {
  UserModel bidder;
  int amount;

  Bid({required this.bidder, required this.amount});

  factory Bid.fromJson(var json) {
    return Bid(
      amount: json["amount"] ?? 0,
      bidder: UserModel.fromJson(json["user"]),
    );
  }

  toJson() {
    return {
      "bidder": bidder.toJson(),
      "amount": amount,
    };
  }
}
