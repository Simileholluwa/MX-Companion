import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Sheet {
  static final Sheet _singleton = Sheet._internal();

  Sheet._internal();

  factory Sheet() {
    return _singleton;
  }

  static Future appSheet({
    required VoidCallback onTap,
    required VoidCallback onPressed,
    required String text,
    required String message,
    required String action,
    VoidCallback? reminderAction,
    bool setReminder = false,
    bool cancel = true,
    required BuildContext context,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      context: context,
      builder: (context) {
        return Popover(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    bottom: 20,
                    top: 10,
                  ),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Text(
                    message,
                    style: Theme.of(Get.context!).textTheme.titleMedium!.merge(
                          TextStyle(color: Theme.of(Get.context!).hintColor),
                        ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    cancel == true
                        ? TextButton(
                            onPressed: onPressed,
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ))
                        : const SizedBox(),
                    cancel == true
                        ? const SizedBox(
                            width: 30,
                          )
                        : const SizedBox(),
                    cancel == true
                        ? const SizedBox(
                            width: 1,
                            child: Divider(
                              thickness: 20,
                              height: 50,
                            ),
                          )
                        : const SizedBox(),
                    cancel == true
                        ? const SizedBox(
                            width: 30,
                          )
                        : const SizedBox(),
                    TextButton(
                      onPressed: onTap,
                      child: Text(
                        action,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future updateDetailsDialog({
    required String title,
    required Widget content,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      context: Get.context!,
      builder: (context) {
        return Popover(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 35,
                    right: 35,
                    bottom: 20,
                    top: 10,
                  ),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: content,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future starRating({
    required VoidCallback onTap,
    required String title,
    String? tapString,
    required Widget content,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      context: Get.context!,
      builder: (context) {
        return Popover(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 10,
                  ),
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: content,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: onTap,
                      child: Text(
                        tapString ?? 'Review',
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future cardOptions({
    required Widget content,
  }) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0,
      isScrollControlled: true,
      context: Get.context!,
      builder: (context) {
        return Popover(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30,),
                  child: content,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}

class Popover extends StatelessWidget {
  const Popover({
    Key? key,
    this.child,
  }) : super(key: key);

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      //margin: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(context),
          if (child != null) child!,
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            color: theme.dividerColor,
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
