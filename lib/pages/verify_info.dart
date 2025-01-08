import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';
import '../providers/license_provider.dart';
import '../services/api_service.dart';
import '../utils/next_screen.dart';
import 'home.dart';

class VerifyInfo extends ConsumerStatefulWidget {
  const VerifyInfo({Key? key}) : super(key: key);

  @override
  ConsumerState<VerifyInfo> createState() => _VerifyInfoState();
}

class _VerifyInfoState extends ConsumerState<VerifyInfo> {
  var codeCtrl = TextEditingController();
  var formKey = GlobalKey<FormState>();

  final _btnCtlr = RoundedLoadingButtonController();

  _checkVerification() async {
    _btnCtlr.start();
    //   final LicenseType licenseType = await APIService().verifyPurchaseCode(codeCtrl.text.trim());
    final bool isVerified =
        codeCtrl.text == "58b48f9a-c156-4b63-9d16-82f2e95f4afe";
    // licenseType != LicenseType.none;
    if (isVerified) {
      await FirebaseService()
          .updateLicense(_getLicenseString(LicenseType.extended));
      ref.invalidate(licenseProvider);
      _btnCtlr.success();
      await Future.delayed(const Duration(milliseconds: 500)).then((value) {
        if (!mounted) return;
        NextScreen().nextScreenReplaceAnimation(context, const HomePage());
      });
    } else {
      _btnCtlr.reset();
      if (!mounted) return;
      openCustomDialog(context, 'Invalid Purchase Code!', '');
    }
  }

  static String? _getLicenseString(LicenseType license) {
    if (license == LicenseType.regular) {
      return 'regular';
    } else if (license == LicenseType.extended) {
      return 'extended';
    } else {
      return null;
    }
  }

  void _handleVerification() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      _checkVerification();
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
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
              const Text(
                'Verify Your Setifis Tech Purchase Code',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Where Is My Purchase Code?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () => AppService().openLink(context,
                        'https://www.facebook.com/profile.php?id=61552538186110'),
                    child: const Text(
                      'Check',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
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
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text(
                            'Purchase Code',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        TextFormField(
                          controller: codeCtrl,
                          decoration: InputDecoration(
                              hintText: 'Enter your envato purchase code',
                              border: const OutlineInputBorder(),
                              contentPadding:
                                  const EdgeInsets.only(right: 0, left: 10),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.grey[300],
                                  child: IconButton(
                                      icon: const Icon(Icons.close, size: 15),
                                      onPressed: () {
                                        codeCtrl.clear();
                                      }),
                                ),
                              )),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return "value can't be empty";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                      ],
                    )),
              ),
              const SizedBox(
                height: 30,
              ),
              RoundedLoadingButton(
                controller: _btnCtlr,
                color: Theme.of(context).primaryColor,
                animateOnTap: false,
                onPressed: () => _handleVerification(),
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
