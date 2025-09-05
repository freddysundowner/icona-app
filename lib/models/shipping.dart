class Shipping {
  String? id;
  String? name;
  double? cost;
  Shipping({this.id, this.name, this.cost});

  factory Shipping.fromJson(Map<String, dynamic> json) {
    return Shipping(
      id: json['_id'],
      name: json['name'],
      cost: double.parse(json['cost'].toString()), //convert int to double
    );
  }
}
