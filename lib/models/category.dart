import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  String? name;
  String? id;
  String? thumbnailUrl;
  int? quizCount;
  bool? featured;
  int? orderIndex;
  int? year;

  Category({
    required this.name,
    required this.id,
    this.thumbnailUrl,
    this.quizCount,
    this.featured,
    this.orderIndex,
    this.year,
  });

  factory Category.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return Category(
      name: d['name'],
      id: d['id'],
      thumbnailUrl: d['image_url'],
      quizCount: d['quiz_count'],
      featured: d['featured'] ?? false,
      orderIndex: d['index'] ?? 0,
      year: d['year'] ?? 0,
    );
  }

  static Map<String, dynamic> getMap(Category d) {
    return {
      'name': d.name,
      'id': d.id,
      'image_url': d.thumbnailUrl,
      'quiz_count': d.quizCount,
      'featured': d.featured,
      'index': d.orderIndex,
      'year': d.year,
    };
  }
}
