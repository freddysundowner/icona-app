class StripeTransaction {
  String? id;
  String? status;
  String? bank;
  String? last4;
  String? currency;
  double? amount;
  int? arrival_date;
  int? created;

  StripeTransaction(
      {this.id,
      this.status,
      this.bank,
      this.last4,
      this.currency,
      this.amount,
      this.arrival_date,
      this.created});

  factory StripeTransaction.fromJson(Map<String, dynamic> json) {
    return StripeTransaction(
      id: json['id'],
      status: json['status'],
      bank: json['destination']['bank_name'],
      last4: json['destination']['last4'],
      currency: json['currency'],
      amount: json['amount'] / 100,
      arrival_date: json['arrival_date'],
      created: json['created'],
    );
  }
}
