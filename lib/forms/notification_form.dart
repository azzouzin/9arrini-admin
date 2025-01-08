import 'package:app_admin/components/custom_buttons.dart';
import 'package:app_admin/components/custom_dialogs.dart';
import 'package:app_admin/components/top_title.dart';
import 'package:app_admin/configs/constants.dart';
import 'package:app_admin/models/notification.dart';
import 'package:app_admin/providers/dashboard_providers.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/services/firebase_service.dart';
import 'package:app_admin/services/notification_service.dart';
import 'package:app_admin/utils/custom_dialog.dart';
import 'package:app_admin/utils/styles.dart';
import 'package:app_admin/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:rounded_loading_button_plus/rounded_loading_button.dart';

import '../components/html_editor.dart';

class NotificationForm extends ConsumerStatefulWidget {
  const NotificationForm({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationForm> createState() => _NotificationsState();
}

class _NotificationsState extends ConsumerState<NotificationForm> {
  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  String? date;
  final _btnCtlr = RoundedLoadingButtonController();
  final String _targetUsers = Constants.fcmSubscriptionTopicForAllUsers;

  final HtmlEditorController controller = HtmlEditorController();

  _handleSendNotification() async {
    if (hasAdminAccess(ref)) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        final navigator = Navigator.of(context);
        if (await controller.getText() != '') {
          _btnCtlr.start();
          String description = await controller.getText();
          final NotificationModel notification = _notification(description);
          await NotificationService().sendCustomNotificationByTopic(notification, _targetUsers);
          await FirebaseService().saveNotification(notification);
          ref.invalidate(notificationsCountProvider);
          _btnCtlr.success();
          navigator.pop();
          if (!mounted) return;
          openCustomDialog(context, "Notification Sent Successfully!", '');
        } else {
          navigator.pop();
          if (!mounted) return;
          openCustomDialog(context, "Description can't be empty", '');
        }
      }
    } else {
      openCustomDialog(context, 'Only admin can send notifications!', '');
    }
  }

  _handlePreview() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (await controller.getText() != '') {
        String description = await controller.getText();
        if (!mounted) return;
        CustomDialogs().openNotificationDialog(context, notification: _notification(description));
      } else {
        if (!mounted) return;
        openToast("Description can't be empty!", context);
      }
    }
  }

  NotificationModel _notification(String description) {
    final notification = NotificationModel(
      id: FirebaseService.getUID('notifications'),
      title: titleCtrl.text,
      body: description,
      date: DateTime.now(),
    );

    return notification;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.black)),
        actions: [
          CustomButtons.circleButton(context, icon: Icons.remove_red_eye, onPressed: () => _handlePreview()),
          const SizedBox(width: 15),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 15, bottom: 15),
        child: RoundedLoadingButton(
          animateOnTap: false,
          borderRadius: 5,
          controller: _btnCtlr,
          onPressed: () => _handleSendNotification(),
          color: Theme.of(context).primaryColor,
          elevation: 0,
          width: MediaQuery.of(context).size.width * 0.40,
          child: const Wrap(
            children: [
              Text(
                'Send Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const TopTitle(title: 'Send A Notification To Users'),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    'Notification Title',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: TextFormField(
                    decoration: inputDecoration('Enter Notification Title', titleCtrl),
                    controller: titleCtrl,
                    validator: (value) {
                      if (value!.isEmpty) return 'Title is empty';
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    'Notification Description',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                    decoration: BoxDecoration(color: Colors.grey[100], border: Border.all(color: Colors.grey[300]!, width: 2)),
                    height: 500,
                    child: CustomHtmlEditor(
                      controller: controller,
                      initialText: '',
                    )),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
