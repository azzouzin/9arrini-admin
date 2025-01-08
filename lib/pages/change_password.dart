import 'package:app_admin/configs/config.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';
import '../utils/styles.dart';

class ChangePassword extends ConsumerStatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangePassword> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<ChangePassword> {
  final formKey = GlobalKey<FormState>();
  var passwordOldCtrl = TextEditingController();
  var passwordNewCtrl = TextEditingController();
  bool changeStarted = false;

  Future _handleChange() async {
    if (hasAccess(ref)) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        setState(() => changeStarted = true);

        await AuthService().changeAdminPassword(passwordOldCtrl.text, passwordNewCtrl.text).then((bool? success) {
          if (success != null && success == true) {
            debugPrint('success');
            setState(() => changeStarted = false);
            if(!mounted) return;
            Navigator.pop(context);
            openCustomDialog(context, 'Password has been changed successfully!', '');
          } else {
            debugPrint('failed to change password');
            setState(() => changeStarted = false);
            if(!mounted) return;
            openCustomDialog(context, 'Failure in changing password', 'Please try again!');
          }
        });
      }
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }

  clearTextFields() {
    passwordOldCtrl.clear();
    passwordNewCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Change Password",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600, color: Colors.black),
            ),
            Container(
              margin: const EdgeInsets.only(top: 5, bottom: 10),
              height: 3,
              width: 200,
              decoration: BoxDecoration(color: Colors.indigoAccent, borderRadius: BorderRadius.circular(15)),
            ),
            const SizedBox(
              height: 100,
            ),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'Old Password',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextFormField(
                    controller: passwordOldCtrl,
                    decoration: inputDecoration('Enter old password', passwordOldCtrl),
                    validator: (String? value) {
                      if (value!.isEmpty) return 'Old password is empty!';
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'New Password',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  TextFormField(
                    controller: passwordNewCtrl,
                    decoration: inputDecoration('Enter new password', passwordNewCtrl),
                    obscureText: true,
                    validator: (String? value) {
                      if (value!.isEmpty) return 'New password is empty!';
                      return null;
                    },
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.deepPurpleAccent,
                      height: 45,
                      child: changeStarted == true
                          ? const Center(
                              child: SizedBox(height: 30, width: 30, child: CircularProgressIndicator()),
                            )
                          : TextButton(
                              child: const Text(
                                'Update Password',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              onPressed: () => _handleChange())),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
