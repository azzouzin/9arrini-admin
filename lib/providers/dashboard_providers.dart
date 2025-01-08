import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/firebase_service.dart';

final usersCountProvider = FutureProvider<int>((ref)async{
  final int count = await FirebaseService().getCount('users');
  return count;
});

final categoriessCountProvider = FutureProvider<int>((ref)async{
  final int count = await FirebaseService().getCount('categories');
  return count;
});

final quizzesCountProvider = FutureProvider<int>((ref)async{
  final int count = await FirebaseService().getCount('quizes');
  return count;
});

final questionsCountProvider = FutureProvider<int>((ref)async{
  final int count = await FirebaseService().getCount('questions');
  return count;
});

final notificationsCountProvider = FutureProvider<int>((ref)async{
  final int count = await FirebaseService().getCount('notifications');
  return count;
});

final purchasesCountProvider = FutureProvider<int>((ref)async{
  final int count = await FirebaseService().getCount('purchases');
  return count;
});