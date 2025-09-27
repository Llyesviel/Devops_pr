class Donation {
  const Donation({
    required this.id,
    required this.userId,
    required this.shelterId,
    required this.amount,
    required this.isAnonymous,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.message,
    this.paymentIntentId,
    this.userName,
    this.userEmail,
    this.shelterName,
  });

  factory Donation.fromJson(Map<String, dynamic> json) => Donation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      shelterId: json['shelter_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      isAnonymous: json['is_anonymous'] as bool? ?? false,
      status: json['status'] as String,
      paymentMethod: json['payment_method'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      message: json['message'] as String?,
      paymentIntentId: json['payment_intent_id'] as String?,
      userName: json['user_name'] as String?,
      userEmail: json['user_email'] as String?,
      shelterName: json['shelter_name'] as String?,
    );

  final String id;
  final String userId;
  final String shelterId;
  final double amount;
  final String? message;
  final bool isAnonymous;
  final String status; // pending, completed, failed, cancelled
  final String paymentMethod;
  final String? paymentIntentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName;
  final String? userEmail;
  final String? shelterName;

  Donation copyWith({
    String? id,
    String? userId,
    String? shelterId,
    double? amount,
    String? message,
    bool? isAnonymous,
    String? status,
    String? paymentMethod,
    String? paymentIntentId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userEmail,
    String? shelterName,
  }) {
    return Donation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      shelterId: shelterId ?? this.shelterId,
      amount: amount ?? this.amount,
      message: message ?? this.message,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      shelterName: shelterName ?? this.shelterName,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'shelter_id': shelterId,
    'amount': amount,
    'message': message,
    'is_anonymous': isAnonymous,
    'status': status,
    'payment_method': paymentMethod,
    'payment_intent_id': paymentIntentId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'user_name': userName,
    'user_email': userEmail,
    'shelter_name': shelterName,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Donation &&
        other.id == id &&
        other.userId == userId &&
        other.shelterId == shelterId &&
        other.amount == amount &&
        other.message == message &&
        other.isAnonymous == isAnonymous &&
        other.status == status &&
        other.paymentMethod == paymentMethod &&
        other.paymentIntentId == paymentIntentId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.userName == userName &&
        other.userEmail == userEmail &&
        other.shelterName == shelterName;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      shelterId,
      amount,
      message,
      isAnonymous,
      status,
      paymentMethod,
      paymentIntentId,
      createdAt,
      updatedAt,
      userName,
      userEmail,
      shelterName,
    );
  }
}