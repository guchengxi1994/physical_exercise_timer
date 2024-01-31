import 'package:flutter/material.dart';
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
      // borderRadius: BorderRadius.circular(12),
      // boxShadow: const [
      //   BoxShadow(
      //     color: Color(0x07000000),
      //     blurRadius: 16,
      //     offset: Offset(0, 16),
      //     spreadRadius: 0,
      //   )
      // ],
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
