import 'package:app_admin/models/notification.dart';
import 'package:app_admin/models/purchases.dart';
import 'package:app_admin/models/question.dart';
import 'package:app_admin/models/quiz.dart';
import 'package:app_admin/models/sp_category.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../models/chart_model.dart';
import '../models/user.dart';

class FirebaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future deleteContent(String collectionName, String documentName) async {
    await firestore.collection(collectionName).doc(documentName).delete();
  }

  Future<String?> getCategoryName(String catId) async {
    String? categoryName;
    await firestore.collection('categories').doc(catId).get().then((DocumentSnapshot snap) {
      categoryName = snap['name'];
    });
    return categoryName;
  }

  Future<String?> getQuizName(String quizId) async {
    String? quizName;
    await firestore.collection('quizes').doc(quizId).get().then((DocumentSnapshot snap) {
      quizName = snap['name'];
    });
    return quizName;
  }

  Future increaseQuestionCountInQuiz(String quizId, int? itemSize) async {
    final int size = itemSize ?? 1;
    await firestore.collection('quizes').doc(quizId).get().then((DocumentSnapshot snap) async {
      int count = snap.get('question_count') ?? 0;
      await firestore.collection('quizes').doc(quizId).update({'question_count': count + size});
    });
  }

  Future decreaseQuestionCountInQuiz(String quizId) async {
    await firestore.collection('quizes').doc(quizId).get().then((DocumentSnapshot snap) async {
      int count = snap.get('question_count') ?? 0;
      await firestore.collection('quizes').doc(quizId).update({'question_count': count - 1});
    });
  }

  Future increaseQuizCountInCategory(String categoryId) async {
    await firestore.collection('categories').doc(categoryId).get().then((DocumentSnapshot snap) async {
      int count = snap.get('quiz_count') ?? 0;
      await firestore.collection('categories').doc(categoryId).update({'quiz_count': count + 1});
    });
  }

  Future decreaseQuizCountInCategory(String categoryId) async {
    await firestore.collection('categories').doc(categoryId).get().then((DocumentSnapshot snap) async {
      int count = snap.get('quiz_count') ?? 0;
      await firestore.collection('categories').doc(categoryId).update({'quiz_count': count - 1});
    });
  }

  Future removeQuizFromFeatured(String documentName) async {
    return firestore.collection('quizes').doc(documentName).update({'featured': false});
  }

  Future addQuizToFeatured(String documentName) async {
    return firestore.collection('quizes').doc(documentName).update({'featured': true});
  }

  Future deleteRelatedQuizesAndQuestions(String catId) async {
    WriteBatch batch = firestore.batch();
    await firestore.collection('quizes').where('parent_id', isEqualTo: catId).get().then((QuerySnapshot snapshot) async {
      if (snapshot.size != 0) {
        // ignore: avoid_function_literals_in_foreach_calls
        snapshot.docs.forEach((doc) async {
          batch.delete(doc.reference);
          await deleteRelatedQuestionsAssociatedWithQuiz(doc.id);
        });
        return batch.commit();
      }
    });
  }

  Future deleteRelatedQuestionsAssociatedWithQuiz(String quizId) async {
    WriteBatch batch = firestore.batch();
    await firestore.collection('questions').where('quiz_id', isEqualTo: quizId).get().then((QuerySnapshot snapshot) async {
      if (snapshot.size != 0) {
        // ignore: avoid_function_literals_in_foreach_calls
        snapshot.docs.forEach((doc) => batch.delete(doc.reference));
        return batch.commit();
      }
    });
  }

  Future<List<Category>> getCategories() async {
    List<Category> data = [];
    await firestore.collection('categories').get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Category.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Quiz>> getQuizes() async {
    List<Quiz> data = [];
    await firestore.collection('quizes').get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Quiz.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<Quiz>> getCategoryBasedQuizes(String catId) async {
    List<Quiz> data = [];
    await firestore.collection('quizes').where('parent_id', isEqualTo: catId).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => Quiz.fromFirestore(e)).toList();
    });
    return data;
  }

  Future updateUserAccess(String userId, bool isDisabled) async {
    return await firestore.collection('users').doc(userId).update({'disabled': isDisabled});
  }

  Future removeEditorAccess(String userId) async {
    return await firestore.collection('users').doc(userId).set({'role': null}, SetOptions(merge: true));
  }

  Future assignEditorAccess(String userId) async {
    return await firestore.collection('users').doc(userId).set({
      'role': ['editor']
    }, SetOptions(merge: true));
  }

  Future removeCategoryFromFeatured(String documentName) async {
    return firestore.collection('categories').doc(documentName).update({'featured': false});
  }

  Future addCategoryToFeatured(String id) async {
    return firestore.collection('categories').doc(id).update({'featured': true});
  }

  Future<SpecialCategory> getSpecialCategory() async {
    SpecialCategory specialCategory;
    final DocumentReference ref = firestore.collection('settings').doc('special_categories');
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      debugPrint('true');
      specialCategory = SpecialCategory.fromFirestore(snapshot);
    } else {
      debugPrint('false');
      specialCategory = SpecialCategory(enabled: false, id1: null, id2: null);
    }
    debugPrint(specialCategory.id2);
    return specialCategory;
  }

  Future saveSpecialCategory(SpecialCategory specialCategory) async {
    Map<String, dynamic> data = SpecialCategory.getMap(specialCategory);
    final DocumentReference ref = firestore.collection('settings').doc('special_categories');
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      debugPrint('true');
      await ref.update(data);
    } else {
      debugPrint('false');
      await ref.set(data);
    }
  }

  Future<String> uploadImageToFirebaseHosting(XFile image, String folderName) async {
    //return download link
    Uint8List imageData = await XFile(image.path).readAsBytes();
    final Reference storageReference = FirebaseStorage.instance.ref().child('$folderName/${image.name}.png');
    final SettableMetadata metadata = SettableMetadata(contentType: 'image/png');
    final UploadTask uploadTask = storageReference.putData(imageData, metadata);
    final TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    String imageUrl = await snapshot.ref.getDownloadURL();
    return imageUrl;
  }

  Future updateUserPoints(String userId, int newPoints) async {
    final docRef = firestore.collection("users").doc(userId);
    return await docRef.update({'points': newPoints});
  }

  Future<bool> checkVerificationInfo() async {
    final DocumentReference ref = firestore.collection('settings').doc('info');
    DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      bool valid = snapshot['valid'] ?? false;
      return valid;
    } else {
      return false;
    }
  }

  Future saveVerificationInfo() async {
    final DocumentReference ref = firestore.collection('settings').doc('info');
    await ref.set({'valid': true});
  }

  //New way for gettings counts
  Future<int> getCount(String path) async {
    final CollectionReference collectionReference = firestore.collection(path);
    AggregateQuerySnapshot snap = await collectionReference.count().get();
    int count = snap.count ?? 0;
    return count;
  }

  Future updateCategoriesOrder(List<Category> categories) async {
    final batch = firestore.batch();
    for (int i = 0; i < categories.length; i++) {
      final docRef = FirebaseFirestore.instance.collection('categories').doc(categories[i].id);
      batch.update(docRef, {'index': i});
    }
    await batch.commit();
  }

  Future uploadBulkQuestions(List<Question> questions) async {
    final CollectionReference ref = firestore.collection('questions');
    WriteBatch batch = firestore.batch();

    for (var question in questions) {
      Map<String, dynamic> data = Question.getMap(question);
      final DocumentReference docRef = ref.doc(question.id);
      batch.set(docRef, data);
    }

    await batch.commit();
  }

  // Get Firebase UID for new document
  static String getUID(String collectionName) => FirebaseFirestore.instance.collection(collectionName).doc().id;

  Future<List<ChartModel>> getUserStats(int days) async {
    List<ChartModel> stats = [];
    DateTime lastWeek = DateTime.now().subtract(Duration(days: days));
    final QuerySnapshot snapshot = await firestore.collection('user_stats').where('timestamp', isGreaterThanOrEqualTo: lastWeek).get();
    stats = snapshot.docs.map((e) => ChartModel.fromFirestore(e)).toList();
    return stats;
  }

  Future<List<ChartModel>> getPurchaseStats(int days) async {
    List<ChartModel> stats = [];
    DateTime lastWeek = DateTime.now().subtract(Duration(days: days));
    final QuerySnapshot snapshot = await firestore.collection('purchase_stats').where('timestamp', isGreaterThanOrEqualTo: lastWeek).get();
    stats = snapshot.docs.map((e) => ChartModel.fromFirestore(e)).toList();
    return stats;
  }

  Future<List<UserModel>> getLatestUsers(int limit) async {
    List<UserModel> data = [];
    await firestore.collection('users').orderBy('created_at', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => UserModel.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<UserModel>> getTopUsers(int limit) async {
    List<UserModel> data = [];
    await firestore.collection('users').orderBy('points', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => UserModel.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<List<PurchaseModel>> getLatestPurchases(int limit) async {
    List<PurchaseModel> data = [];
    await firestore.collection('purchases').orderBy('purchase_at', descending: true).limit(limit).get().then((QuerySnapshot? snapshot) {
      data = snapshot!.docs.map((e) => PurchaseModel.fromFirestore(e)).toList();
    });
    return data;
  }

  Future<String?> getLicense() async {
    String? value;
    final DocumentReference ref = firestore.collection('settings').doc('info');
    final DocumentSnapshot snapshot = await ref.get();
    if (snapshot.exists) {
      final Map data = snapshot.data() as Map;
      if (data.containsKey('license')) {
        value = data['license'];
      }
    }
    return value;
  }

  Future updateLicense(String? value) async {
    final docRef = firestore.collection('settings').doc('info');
    await docRef.set({'license': value}, SetOptions(merge: true));
  }

  Future<UserModel?> getUserData() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    final DocumentSnapshot snap = await firestore.collection('users').doc(userId).get();
    UserModel? user = UserModel.fromFirestore(snap);
    return user;
  }

  static Query notificationsQuery() {
    return FirebaseFirestore.instance.collection('notifications').orderBy('date', descending: true);
  }

  Future saveNotification(NotificationModel notification) async {
    final Map<String, dynamic> data = NotificationModel.getMap(notification);
    await firestore.collection('notifications').doc(notification.id).set(data);
  }
}
