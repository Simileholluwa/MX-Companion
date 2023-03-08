import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dialogs {
  static final Dialogs _singleton = Dialogs._internal();

  Dialogs._internal();

  factory Dialogs() {
    return _singleton;
  }

  static Widget appDialog({
    required VoidCallback onTap,
    required VoidCallback onPressed,
    required String text,
    required String message,
    required String action,
    VoidCallback? reminderAction,
    bool setReminder = false,
    bool cancel = true,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(
          text,
        ),
      ),
      titlePadding: const EdgeInsets.only(top: 20, left: 20, bottom: 10,),
      content: Text(
        message,
        style: Theme.of(Get.context!).textTheme.titleMedium!.merge( TextStyle(color: Theme.of(Get.context!).hintColor),),
      ),
      actions: [
        cancel == true ? TextButton(
          onPressed: onPressed,
          child: const Text(
            'Cancel',
          )
        ) : const SizedBox(),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
          ),
        ),
      ],
    );
  }

  static Widget updateDetailsDialog({
    required String title,
    required Widget content,
  }) {
    return AlertDialog(
      //scrollable: true,
      contentPadding: const EdgeInsets.all(5,),
      titlePadding: const EdgeInsets.only(top: 20, left: 20, bottom: 10,),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(
          title,
        ),
      ),
      content: content,
    );
  }

  static Widget starRating({
    required VoidCallback onTap,
    required String title,
    String? tapString,
    required Widget content,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: SizedBox(
        width: double.maxFinite,
        child: Text(
          title,
        ),
      ),
      titlePadding: const EdgeInsets.only(top: 20, left: 20, bottom: 10,),
      content: content,
      actions: [
        TextButton(
          onPressed: onTap,
          child: Text(
            tapString ?? 'Review',
          ),
        ),
      ],
    );
  }
}

