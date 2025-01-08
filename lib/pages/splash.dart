import 'dart:async';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/models/user.dart';
import 'package:app_admin/pages/home.dart';
import 'package:app_admin/pages/sign_in.dart';
import 'package:app_admin/providers/license_provider.dart';
import 'package:app_admin/providers/user_data_provider.dart';
import 'package:app_admin/utils/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_role_provider.dart';
import '../services/auth_service.dart';
import '../utils/next_screen.dart';
import 'verify_info.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _InitialScreen1State();
}

class _InitialScreen1State extends ConsumerState<SplashScreen> {
  late StreamSubscription<User?> _auth;

  @override
  void initState() {
    _auth = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _checkVerification(user);
      } else {
        if(!mounted) return;
        NextScreen().nextScreenReplaceAnimation(context, const SignInPage());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _auth.cancel();
    super.dispose();
  }

  _checkVerification(User user) async {
    await ref.read(userDataProvider.notifier).getData();
    final UserModel? userData = ref.read(userDataProvider);
    final UserRoles role = AuthService.getUserRole(userData);

    if (role == UserRoles.admin || role == UserRoles.editor) {
      ref.read(userRoleProvider.notifier).update((state) => role);
      final LicenseType license = await ref.read(licenseProvider.future);
      final bool isVerified = license != LicenseType.none;

      if (isVerified) {
        if (!mounted) return;
        NextScreen().nextScreenReplaceAnimation(context, const HomePage());
      } else {
        if (!mounted) return;
        NextScreen().nextScreenReplaceAnimation(context, const VerifyInfo());
      }
    } else {
      // Not ADMIN or AUTHOR
      await AuthService().adminLogout().then((value) {
        if(!mounted) return;
        openToast('Access Denied!', context);
        NextScreen().nextScreenReplaceAnimation(context, const SignInPage());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.asset(Config.logo, height: 45, width: 300)),
    );
  }
}
