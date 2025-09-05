class Dispute {
  String? orderId;
  String? userId;
  String? status;
  String? reason;
  String? id;
  String? seller_response;
  String? details;

  Dispute(
      {this.orderId,
      this.userId,
      this.seller_response,
      this.reason,
      this.details,
      this.status,
      this.id});

  Dispute.fromJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    seller_response = json['seller_response'] ?? "";
    userId = json['userId'];
    id = json['_id'];
    reason = json['reason'];
    status = json['status'];
    details = json['details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['orderId'] = this.orderId;
    data['userId'] = this.userId;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['details'] = this.details;
    return data;
  }
}
