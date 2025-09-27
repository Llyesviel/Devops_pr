class Donation {
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

  Donation.copyWith({
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
    required Donation original,
  }) : id = id ?? original.id,
       userId = userId ?? original.userId,
       shelterId = shelterId ?? original.shelterId,
       amount = amount ?? original.amount,
       message = message ?? original.message,
       isAnonymous = isAnonymous ?? original.isAnonymous,
       status = status ?? original.status,
       paymentMethod = paymentMethod ?? original.paymentMethod,
       paymentIntentId = paymentIntentId ?? original.paymentIntentId,
       createdAt = createdAt ?? original.createdAt,
       updatedAt = updatedAt ?? original.updatedAt,
       userName = userName ?? original.userName,
       userEmail = userEmail ?? original.userEmail,
       shelterName = shelterName ?? original.shelterName;

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
      userName: (json['users'] as Map<String, dynamic>?)?['full_name'] 
          as String?,
      userEmail: (json['users'] as Map<String, dynamic>?)?['email'] 
          as String?,
      shelterName: (json['shelters'] as Map<String, dynamic>?)?['name'] 
          as String?,
    );

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
    };

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
  }) => Donation(
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

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isCancelled => status == 'cancelled';

  String get displayName =>
      isAnonymous ? 'Anonymous' : userName ?? 'Unknown User';

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Donation && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Donation(id: $id, amount: $amount, '
      'status: $status, shelter: $shelterName)';
}