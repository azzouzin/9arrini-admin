import 'package:app_admin/configs/config.dart';
import 'package:app_admin/pages/verify_info.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import '../providers/license_provider.dart';
import '../utils/next_screen.dart';

class LicenseTab extends ConsumerWidget {
  const LicenseTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final license = ref.watch(licenseProvider);

    final String licenseString = license.value == LicenseType.extended
        ? 'Extended License'
        : license.value == LicenseType.regular
            ? 'Regular License'
            : 'Unknown';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(100),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Column(
            children: [
              Icon(
                LineIcons.checkCircle,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 30),
              Text(
                'Your license key is valid and activated',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blueGrey),
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    text: 'License Type:  ',
                    children: [TextSpan(text: licenseString, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600))]),
              )
            ],
          ),
        ),
        const SizedBox(height: 30),
        RichText(
          text: TextSpan(style: Theme.of(context).textTheme.bodyMedium, text: 'Want to deactivate this license?  ', children: [
            TextSpan(
                style: const TextStyle(color: Colors.blueAccent),
                text: 'Click here',
                recognizer: TapGestureRecognizer()..onTap = () => _handleDeactivateLicense(context, ref))
          ]),
        )
      ],
    );
  }

  _handleDeactivateLicense(BuildContext context, WidgetRef ref) async {
    if (hasAdminAccess(ref)) {
      await FirebaseService().updateLicense(null);
      ref.invalidate(licenseProvider);
      if (!context.mounted) return;
      NextScreen().nextScreenReplaceAnimation(context, const VerifyInfo());
    } else {
      openCustomDialog(context, Config.testingDialog, '');
    }
  }
}
