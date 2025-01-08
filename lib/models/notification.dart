import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id, title, body;
  final DateTime date;

  NotificationModel({required this.id, required this.title, required this.body, required this.date});

  factory NotificationModel.fromFirestore(DocumentSnapshot snapshot) {
    final Map<String, dynamic> d = snapshot.data() as Map<String, dynamic>;
    return NotificationModel(
      id: snapshot.id,
      title: d['title'],
      body: d['body'],
      date: (d['date'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> getMap(NotificationModel d) {
    return {
      'title': d.title,
      'body': d.body,
      'date': d.date,
    };
  }
}
