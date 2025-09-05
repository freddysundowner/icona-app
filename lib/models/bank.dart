class Bank {
  String? id;
  String? name;
  String? last4;
  String? accountNumber;
  String? accountName;

  Bank({
    this.name,
    this.last4,
    this.accountNumber,
    this.id,
    this.accountName,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'],
      name: json['bank_name'],
      last4: json['last4'],
      accountNumber: json['account'],
    );
  }
}
