import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:toastification/toastification.dart';

class ToastUtils {
  ToastUtils._();

  static void message(BuildContext context,
      {required String title, String? descryption, VoidCallback? onTap}) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 10),
      title: Text(title),
      // you can also use RichText widget for title and description parameters
      description: descryption != null
          ? RichText(text: TextSpan(text: descryption))
          : null,
      alignment: Alignment.topRight,
      direction: TextDirection.ltr,
      animationDuration: const Duration(milliseconds: 300),
      animationBuilder: (context, animation, alignment, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      icon: const Icon(
        Icons.message,
        color: Colors.green,
      ),
      primaryColor: Colors.green,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      showProgressBar: true,
      closeButtonShowType: CloseButtonShowType.onHover,
      closeOnClick: false,
      pauseOnHover: true,
      dragToClose: true,
      // applyBlurEffect: true,
      callbacks: ToastificationCallbacks(
        onTap: (toastItem) => onTap,
        onCloseButtonTap: (toastItem) {
          toastification.dismiss(toastItem);
        },
      ),
    );
  }
}

class NotifierController {
  final List<LocalNotification> _notificationList = [];

  newNotification(String title, subtitle, body) async {
    try {
      await _notificationList.last.close();
      _notificationList.removeLast();
    } catch (_) {}

    LocalNotification notification = LocalNotification(
      title: title,
      subtitle: subtitle,
      body: body,
    );

    notification.onShow = () {};
    notification.onClose = (closeReason) {
      _notificationList.remove(notification);
    };

    _notificationList.add(notification);
    notification.show();
  }
}
