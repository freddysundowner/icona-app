import 'package:tokshop/models/category.dart';
import 'package:tokshop/models/shippingProfile.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/models/user.dart';

class GiveAway {
  String? id;
  String? name;
  String? description;
  List<String>? images;
  String? status;
  String? startedtime;
  int? duration;
  double? quantity;
  String? whocanenter;
  String? endedtime;
  Tokshow? room;
  UserModel? user;
  ShippingProfile? shipping_profile;
  ProductCategory? category;
  UserModel? winner;
  List<UserModel> participants = [];

  GiveAway(
      {this.id,
      this.name,
      this.duration,
      this.whocanenter,
      this.description,
      this.images,
      this.quantity,
      this.status,
      this.shipping_profile,
      this.startedtime,
      this.endedtime,
      this.room,
      this.user,
      this.winner,
      this.participants = const [],
      this.category});

  GiveAway.fromJson(Map<String, dynamic> json) {
    print(json['tokshow']);
    id = json['_id'];
    name = json['name'];
    shipping_profile = json['shipping_profile'] != null
        ? ShippingProfile.fromJson(json['shipping_profile'])
        : null;
    duration = json['duration'] ?? 0;
    whocanenter = json['whocanenter'] ?? "";
    description = json['description'];
    category = json['category'] != null
        ? ProductCategory.fromJson(json['category'])
        : null;
    images = json['images'] != null &&
            json['images'].length > 0 &&
            json['images'][0] != []
        ? List.generate(json['images'].length, (index) => json['images'][index])
        : [];
    status = json['status'];
    quantity = isInteger(json['quantity'])
        ? json['quantity'].toDouble()
        : json['quantity']; // is innt make it double;
    startedtime = json['startedtime'];
    endedtime = json['endedtime'];
    room = json['tokshow'] != null
        ? Tokshow(
            id: json['tokshow']['_id'],
            title: json['tokshow']['title'],
          )
        : null;
    user = json['user'] != null && json['user'].toString().length > 50
        ? UserModel.fromJson(json['user'])
        : null;
    winner = json['winner'] != null ? UserModel.fromJson(json['winner']) : null;
    participants = json["participants"] == null
        ? []
        : List<UserModel>.from(json["participants"].map((x) =>
            x.toString().length > 50
                ? UserModel.fromJson(x)
                : UserModel(id: x)));
  }
}
