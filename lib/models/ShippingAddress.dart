class ShippingAddress {
  ShippingAddress({
    this.id,
    required this.name,
    this.countryCode,
    this.primary,
    required this.country,
    required this.zipcode,
    required this.addrress1,
    required this.addrress2,
    required this.city,
    required this.state,
    this.userId,
    this.phoneNumber,
    this.email,
  });

  String? id;
  String name;
  String? countryCode;
  String? phoneNumber;
  String? email;
  bool? primary;
  String country;
  String zipcode;
  String addrress1;
  String addrress2;
  String state;
  String city;
  String? userId;

  factory ShippingAddress.fromJson(Map<String, dynamic> json) =>
      ShippingAddress(
        id: json["_id"],
        primary: json["primary"] ?? false,
        countryCode: json["countryCode"] ?? "",
        name: json["name"],
        zipcode: json["zipcode"],
        addrress1: json["addrress1"],
        country: json["country"] ?? "",
        addrress2: json["addrress2"],
        city: json["city"],
        state: json["state"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "addrress1": addrress1,
        "countryCode": countryCode,
        "zipcode": zipcode,
        "country": country,
        "addrress2": addrress2,
        "primary": primary,
        "city": city,
        "state": state,
        "userId": userId,
        'phone': phoneNumber,
        "email": email
      };
}

class UserAddress {
  UserAddress({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.bio,
    required this.userName,
    required this.email,
  });

  String id;
  String firstName;
  String lastName;
  String bio;
  String userName;
  String email;

  factory UserAddress.fromJson(Map<String, dynamic> json) => UserAddress(
        id: json["_id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        bio: json["bio"],
        userName: json["userName"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "firstName": firstName,
        "lastName": lastName,
        "bio": bio,
        "userName": userName,
        "email": email,
      };
}
