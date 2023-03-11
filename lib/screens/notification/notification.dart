import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../config/themes/ui_parameters.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/alert_bottom_sheet.dart';
import '../../widgets/content_area.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = "/notifications";

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    AuthController controller = Get.find();

    final CollectionReference _userNotifications = FirebaseFirestore.instance
        .collection('users')
        .doc(controller.getUser()!.uid)
        .collection('user_notifications');

    Future<void> _delete(String historyId) async {
      await _userNotifications.doc(historyId).delete();
      controller.showSnackBar(
        'Notification deleted.',
      );
    }

    Future<void> _deleteAll(QuerySnapshot<Object?> snapShots ) async {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in snapShots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      controller.showSnackBar('Notifications deleted.');
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.scaffoldBackground,
        useDivider: false,
        opacity: 1,
      ),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(
              left: 15,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                size: 30,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          title: Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge!.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 30,
                ),
                onPressed: () async {
                  final collection = _userNotifications;
                  var snapShots = await collection.get();
                  if (snapShots.docs.isEmpty) {
                    controller.showSnackBar('Nothing to delete.');
                  } else {
                    controller.showDeleteAllHistory(() {
                      _deleteAll(snapShots);
                      Get.back();
                    }, 'Are you sure you want to delete all notifications?',);
                  }
                },
              ),
            ),
          ],
        ),
        body: StreamBuilder(
          stream: _userNotifications
              .orderBy(
                'created',
                descending: true,
              )
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              if (streamSnapshot.data!.docs.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.notifications,
                          size: 150,
                        ),
                        Text(
                          'You do not have any notifications.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: ContentAreaCustom(
                          addRadius: true,
                          addColor: true,
                          addPadding: false,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider(
                                        height: 5,
                                        thickness: 3,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      );
                                    },
                                    itemCount: streamSnapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final DocumentSnapshot documentSnapShot =
                                          streamSnapshot.data!.docs[index];
                                      return Dismissible(
                                        key: UniqueKey(),
                                        secondaryBackground: Container(
                                          height: 80,
                                          margin: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                UIParameters.cardBorderRadius,
                                            //color: maroonColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: const [
                                                Icon(
                                                  Icons.delete,
                                                  //color: Colors.white,
                                                  size: 30,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        background: Container(
                                          height: 80,
                                          margin: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                UIParameters.cardBorderRadius,
                                            //color: maroonColor,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: const [
                                                Icon(
                                                  Icons.delete,
                                                  //color: Colors.white,
                                                  size: 30,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        onDismissed:
                                            (DismissDirection direction) {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            _delete(documentSnapShot.id);
                                          } else {
                                            _delete(documentSnapShot.id);
                                          }
                                          setState(() {
                                            streamSnapshot.data!.docs
                                                .removeAt(index);
                                          });
                                        },
                                        confirmDismiss:
                                            (DismissDirection direction) async {
                                          return await Sheet.appSheet(
                                            onTap: () => Navigator.of(context).pop(true),
                                            onPressed: () => Get.back(),
                                            text: 'Delete notification',
                                            message: 'Are you sure you want to delete notification from list?',
                                            action: 'Delete',
                                            context: context,
                                          );
                                        },
                                        child: Material(
                                          type: MaterialType.transparency,
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            onTap: () {
                                              controller.showNotificationDetails(documentSnapShot['notification_title'], documentSnapShot['notification_body']);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 20,
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Theme.of(
                                                                  context)
                                                              .scaffoldBackgroundColor,
                                                        ),
                                                        child: documentSnapShot[
                                                                    'type'] ==
                                                                "success"
                                                            ? const Icon(
                                                                FontAwesomeIcons
                                                                    .faceGrin,
                                                                color: Colors
                                                                    .green,
                                                          size: 30,
                                                              )
                                                            : (documentSnapShot[
                                                                        'type'] ==
                                                                    "reminder"
                                                                ? const Icon(
                                                                    Icons
                                                                        .notifications_active,
                                                                    color: Colors
                                                                        .red,
                                                          size: 30,
                                                                  )
                                                                : (documentSnapShot[
                                                                            'type'] ==
                                                                        "review"
                                                                    ? const Icon(
                                                                        Icons
                                                                            .star_half,
                                                                        color: Colors
                                                                            .blue,
                                                          size: 30,
                                                                      )
                                                                    : (documentSnapShot['type'] ==
                                                                            "general"
                                                                        ? const Icon(
                                                                            Icons.waving_hand,
                                                                            color:
                                                                                Colors.orange,
                                                          size: 30,
                                                                          )
                                                                        : const Icon(
                                                                            Icons.bubble_chart,
                                                                            color:
                                                                                Colors.pinkAccent,
                                                          size: 30,
                                                                          )))),
                                                      ),
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      Flexible(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              documentSnapShot[
                                                                  'notification_title'],
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: false,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .merge(
                                                                    const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20,
                                                                    ),
                                                                  ),
                                                            ),
                                                            Text(
                                                              documentSnapShot[
                                                                  'notification_body'],
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: false,
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .merge(
                                                                    TextStyle(
                                                                        color: Theme.of(context)
                                                                            .hintColor),
                                                                  ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Text(
                                                              documentSnapShot[
                                                                      'created']
                                                                  .toDate()
                                                                  .toString()
                                                                  .substring(
                                                                      0, 16),
                                                              style: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .titleMedium!
                                                                  .merge(
                                                                    TextStyle(
                                                                      color: Theme.of(
                                                                              context)
                                                                          .hintColor,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.fourRotatingDots(
                    color: Theme.of(context).primaryColor,
                    size: 70,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
              Text('MX Companion',
                style: Theme.of(context).textTheme.titleLarge!.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
