import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseModel {
  final String id, userId, userName, userEmail, productId, productTitle, price, platform;
  final int points;
  final DateTime purchaseAt;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.productId,
    required this.productTitle,
    required this.purchaseAt,
    required this.points,
    required this.price,
    required this.platform,
  });

  factory PurchaseModel.fromFirestore(DocumentSnapshot snapshot) {
    final d = snapshot.data() as Map<String, dynamic>;
    return PurchaseModel(
      id: snapshot.id,
      userId: d['user_id'],
      userName: d['user_name'],
      productTitle: d['product_title'],
      productId: d['product_id'],
      userEmail: d['user_email'],
      purchaseAt: (d['purchase_at'] as Timestamp).toDate().toLocal(),
      points: d['points'],
      price: d['price'],
      platform: d['platform'] ?? 'Android',
    );
  }
}
