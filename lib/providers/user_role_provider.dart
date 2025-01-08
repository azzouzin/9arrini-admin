import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRoles { admin, editor, guest, none }

final userRoleProvider = StateProvider<UserRoles>((ref) => UserRoles.none);

bool hasAdminAccess(WidgetRef ref) {
  final userRole = ref.watch(userRoleProvider);
  if (userRole == UserRoles.admin) {
    return true;
  } else {
    return false;
  }
}

bool hasAccess(WidgetRef ref) {
  final userRole = ref.watch(userRoleProvider);
  if (userRole == UserRoles.admin || userRole == UserRoles.editor) {
    return true;
  } else {
    return false;
  }
}
