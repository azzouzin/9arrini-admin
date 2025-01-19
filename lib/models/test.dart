import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Test {
  String? id;
  String? name;
  String? link;
  String? chapterID;
  String? chapterName;
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
    this.chapterID,
    this.chapterName,
    this.year,
  });

  factory Test.fromFirestore(DocumentSnapshot snap) {
    Map d = snap.data() as Map<dynamic, dynamic>;
    int milliseconds = (d['created_at'].nanoseconds / 1000000).round();

    // Create DateTime object
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
        (d['created_at'].seconds * 1000) + milliseconds);

    // Format the date (optional)
    String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return Test(
      id: d['id'],
      createdAt: formattedDate,
      updatedAt: d['updated_at'],
      name: d['name'],
      link: d['link'],
      year: d['year'],
      chapterID: d['chapterID'],
      chapterName: d['chapterName'],
    );
  }

  static Map<String, dynamic> getMap(Test test) {
    return {
      'id': test.id,
      'created_at': test.createdAt,
      'updated_at': test.updatedAt,
      'name': test.name,
      'link': test.link,
      'chapterID': test.chapterID,
      'year': test.year,
      'chapterName': test.chapterName,
    };
  }
}
