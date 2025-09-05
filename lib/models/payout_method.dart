class PayoutMethod {
  String? accountname;
  String? type;
  String? userid;
  bool? primary;
  String? id;

  PayoutMethod(
      {this.accountname, this.type, this.primary, this.id, this.userid});

  factory PayoutMethod.fromJson(var json) => PayoutMethod(
        accountname: json["accountname"] ?? "",
        primary: json["primary"] ?? false,
        id: json["_id"] ?? "",
        type: json["type"] ?? "",
        userid: json["userid"],
      );

  toJson() => {
        "accountname": accountname,
        "primary": primary,
        "id": id,
        "type": type,
        "userid": userid,
      };
}
