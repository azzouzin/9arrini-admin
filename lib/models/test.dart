import 'package:cloud_firestore/cloud_firestore.dart';

class Test {
  String? id;
  String? name;
  String? link;
  int? year;
  // ignore: prefer_typing_uninitialized_variables
  var createdAt;
  // ignore: prefer_typing_uninitialized_variables
  var updatedAt;

  Test({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.link,
    this.year,
  });

  factory Test.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    return Test(
      id: d['id'],
      createdAt: d['created_at'],
      updatedAt: d['updated_at'],
      name: d['name'],
      link: d['link'],
      year: d['year'],
    );
  }

  static Map<String, dynamic> getMap(Test test) {
    return {
      'id': test.id,
      'created_at': test.createdAt,
      'updated_at': test.updatedAt,
      'name': test.name,
      'link': test.link,
      'year': test.year,
    };
  }
}
