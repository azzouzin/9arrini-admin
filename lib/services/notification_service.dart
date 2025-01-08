import 'dart:convert';
import 'package:app_admin/services/app_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../configs/fcm_config.dart';
import '../models/notification.dart';
import 'package:googleapis_auth/auth_io.dart';

class NotificationService {
  Future sendCustomNotificationByTopic(NotificationModel notification, String topic) async {
    final String accessToken = await _getAccessToken();
    final String body = AppService.getNormalText(notification.body);
    final String projectId = serviceCreds['project_id'];

    var notificationBody = {
      "message": {
        "notification": {
          'title': notification.title,
          'body': body,
        },
        'data': <String, String>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'status': 'done',
          'notification_type': 'custom',
          'description': body,
        },
        "topic": topic,
      }
    };

    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(notificationBody),
      );
      if (response.statusCode == 200) {
        debugPrint('Notification sent successfully');
      } else {
        debugPrint('Failed to send notification: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  Future<String> _getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(serviceCreds);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final authClient = await clientViaServiceAccount(accountCredentials, scopes);

    final credentials = authClient.credentials;
    return credentials.accessToken.data;
  }
}
