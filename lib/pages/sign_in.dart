import 'package:app_admin/configs/config.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../models/user.dart';
import '../providers/license_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/user_role_provider.dart';
import '../services/auth_service.dart';
import 'home.dart';
import 'verify_info.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  var passwordCtrl = TextEditingController();
  var emailCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();
  String? password;
  final _btnCtlr = RoundedLoadingButtonController();
  bool _obsecureText = true;
  IconData _lockIcon = CupertinoIcons.eye_fill;

  _onChangeVisiblity() {
    if (_obsecureText == true) {
      setState(() {
        _obsecureText = false;
        _lockIcon = CupertinoIcons.eye;
      });
    } else {
      setState(() {
        _obsecureText = true;
        _lockIcon = CupertinoIcons.eye_fill;
      });
    }
  }

  void _handleSignIn() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _btnCtlr.start();
      await AuthService().loginWithEmailPassword(emailCtrl.text, passwordCtrl.text).then((UserCredential? user) async {
        if (user != null) {
          debugPrint('Login Success');

          await ref.read(userDataProvider.notifier).getData();
          final UserModel? userData = ref.read(userDataProvider);
          final UserRoles role = AuthService.getUserRole(userData);
          ref.read(userRoleProvider.notifier).update((state) => role);

          if (role == UserRoles.admin || role == UserRoles.editor) {
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
            await AuthService().adminLogout();
            _btnCtlr.reset();
            if (!mounted) return;
            openCustomDialog(context, 'The email is not authorized as an admin', '');
          }
        } else {
          _btnCtlr.reset();
          debugPrint('SignInErorr');
          if(!mounted) return;
          openCustomDialog(context, 'Sign In Error! Please try again.', 'Email/Password is invalid');
        }
      });
    }
  }



  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          padding: const EdgeInsets.fromLTRB(40, 70, 40, 70),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                Config.logo,
                width: 200,
              ),
              const SizedBox(
                height: 5,
              ),
              const Text(
                'Welcome to Admin Panel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 50,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Email',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                        TextFormField(
                          controller: emailCtrl,
                          decoration: InputDecoration(
                            hintText: 'Enter email address',
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            suffixIcon: IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => emailCtrl.clear()),
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "Password can't be empty";
                            }

                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'Password',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.normal),
                          ),
                        ),
                        TextFormField(
                          controller: passwordCtrl,
                          obscureText: _obsecureText,
                          decoration: InputDecoration(
                            hintText: 'Enter password',
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(3))),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                            suffixIcon: Wrap(
                              children: [
                                IconButton(icon: Icon(_lockIcon, size: 18), onPressed: () => _onChangeVisiblity()),
                                IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () => passwordCtrl.clear()),
                              ],
                            ),
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "Password can't be empty";
                            }
                            return null;
                          },
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 50,
              ),
              RoundedLoadingButton(
                controller: _btnCtlr,
                elevation: 0,
                color: Theme.of(context).primaryColor,
                animateOnTap: false,
                onPressed: () => _handleSignIn(),
                child: const Text('Sign In'),
              ),
              const SizedBox(
                height: 20,
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}
