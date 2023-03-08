import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import 'package:mx_companion_v1/controllers/question_paper/question_paper_controller.dart';
import 'package:mx_companion_v1/models/questions_model.dart';
import '../../config/themes/ui_parameters.dart';
import '../../controllers/ad_helper.dart';
import '../../controllers/notifications_controller.dart';
import '../../firebase_ref/references.dart';
import '../../widgets/rating_bar.dart';

class QuestionsCard extends StatefulWidget {
  final QuestionsModel model;
  final bool isSelected;
  final String? searchResult;
  const QuestionsCard({
    Key? key,
    required this.model,
    this.isSelected = false,
    this.searchResult,
  }) : super(key: key);

  @override
  State<QuestionsCard> createState() => _QuestionsCardState();
}

class _QuestionsCardState extends State<QuestionsCard> {
  QuestionPaperController controller = Get.find();
  AuthController auth = Get.find();
  RewardedAd? rewardedAd;
  InterstitialAd? interstitialAd;
  Rx<DateTime> fullDate = DateTime.now().obs;

  bool _decideWhichDayToEnable(DateTime day) {
    if ((day.isAfter(DateTime.now().subtract(const Duration(days: 1))) &&
        day.isBefore(DateTime.now().add(const Duration(days: 10))))) {
      return true;
    }
    return false;
  }

  Future<void> selectDate() async {
    final date = await showDatePicker(
        context: Get.context!,
        firstDate: DateTime(2022),
        initialDate: DateTime.now(),
        confirmText: 'Continue',
        helpText: 'Select reminder date',
        selectableDayPredicate: _decideWhichDayToEnable,
        lastDate: DateTime(2025));

    if (date != null) {
      final time = await showTimePicker(
        context: Get.context!,
        initialEntryMode: TimePickerEntryMode.input,
        helpText: 'Select reminder time',
        confirmText: 'Set reminder',
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (time != null) {
        fullDate.value = DateTimeField.combine(date, time);
        HelperNotification.scheduleNotifications(
            int.tryParse(widget.model.courseCode!.substring(3, 6))!,
            'It\'s time for ${widget.model.courseCode}!',
            'Here is your reminder to study ${widget.model.courseCode}',
            fullDate.value,
            auth.getUser()!.uid,
            '${widget.model.id}');
      } else {
        auth.showSnackBar('No time selected.');
      }
    } else {
      auth.showSnackBar('No date and time selected.');
    }
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              controller.navigateToQuestions(
                paper: widget.model,
                tryAgain: false,
              );
            },
          );
          interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load an interstitial ad: ${err.message}');
          }
        },
      ),
    );
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              setState(() {
                ad.dispose();
                rewardedAd = null;
              });
              loadRewardedAd();
            },
          );
          rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load a rewarded ad: ${err.message}');
          }
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    loadRewardedAd();
    loadInterstitialAd();
  }

  @override
  void dispose() {
    rewardedAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: UIParameters.cardBorderRadius,
      ),
      child: Column(
        children: [
          _buildFront(),
        ],
      ),
    );
  }

  Widget _buildFront() {
    final CollectionReference allRating = fireStore.collection('allRatings');

    final CollectionReference userSchedule = fireStore
        .collection('users')
        .doc(auth.getUser()?.uid)
        .collection('user_schedule');

    return Slidable(
      endActionPane: ActionPane(
        extentRatio: .85,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              if (rewardedAd != null) {
                rewardedAd?.show(onUserEarnedReward: (_, reward) {
                  controller.navigateToQuestions(
                    paper: widget.model,
                    tryAgain: false,
                  );
                });
              } else {
                if (interstitialAd != null){
                  interstitialAd?.show();
                } else {
                  auth.showSnackBar('Please turn on your mobile data.');
                }
              }
            },
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            icon: Icons.start,
            label: 'Start',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
          StreamBuilder(
              stream: userSchedule.snapshots(),
              builder:
                  (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  if (streamSnapshot.data!.docs.isEmpty) {
                    return SlidableAction(
                      onPressed: (context) async {
                        auth.getUser() == null
                            ? auth.showLoginAlertDialog(
                                'To set a reminder for your selected course, you need to sign in. It will only take a while..')
                            : selectDate();
                      },
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.notifications_active,
                      label: 'Reminder',
                    );
                  } else {
                    List<DocumentSnapshot> snapShot =
                        streamSnapshot.data!.docs;
                    var schedule = snapShot
                        .where((element) => element.id == widget.model.id!);
                    bool isSet = schedule.first['isSet'];
                    int id = schedule.first['reminder_id'];
                    return SlidableAction(
                      onPressed: (context) async {
                        bool isPending = await HelperNotification.isPendingNotification(id);
                        auth.getUser() == null
                            ? auth.showLoginAlertDialog(
                                'To set a reminder for your selected course, you need to sign in. It will only take a while..')
                            : ((isSet == true && isPending == true)
                                ? auth.showCancelReminderAlertDialog(
                                    () async {
                                      await userSchedule.doc(widget.model.id!).update({
                                        "isSet": false,
                                      });
                                      HelperNotification.cancelScheduledNotification(id);
                                      Get.back();
                                    }, widget.model.courseCode!)
                                : selectDate());
                      },
                      backgroundColor: Colors.purpleAccent,
                      foregroundColor: Colors.white,
                      icon: Icons.notifications_active,
                      label: 'Reminder',
                    );
                  }
                }
                return SlidableAction(
                  onPressed: (context) async {
                    auth.getUser() == null
                        ? auth.showLoginAlertDialog(
                            'To set a reminder for your selected course, you need to sign in. It will only take a while..')
                        : selectDate();
                  },
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  icon: Icons.notifications_active,
                  label: 'Reminder',
                );
              }),
          SlidableAction(
            onPressed: (context) {
              auth.showPracticeInfo(
                'Course title: ${widget.model.courseTitle}\nSemester: ${widget.model.semester}\nTime: ${widget.model.timeInMinutes()}\nNote: The system automatically submits when the time elapses. Have fun!',
              );
            },
            label: 'Information',
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.info,
            autoClose: false,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: UIParameters.cardBorderRadius,
              color: Theme.of(context).highlightColor,
            ),
            child: Center(
              child: Column(
                children: [
                  Text(
                    widget.model.creditUnit!,
                    style: Theme.of(context).textTheme.titleLarge!.merge(
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 36,
                          ),
                        ),
                  ),
                  Text(
                    'units',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.searchResult ?? widget.model.courseCode!,
                        style: Theme.of(context).textTheme.titleLarge!.merge(
                              const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                      ),
                      Text(
                        '${widget.model.semester!} semester',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium!.merge(
                              TextStyle(color: Theme.of(context).hintColor),
                            ),
                      ),
                      Text(
                        widget.model.courseTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: Theme.of(context).textTheme.titleMedium!.merge(
                              TextStyle(color: Theme.of(context).hintColor),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StreamBuilder(
                      stream: allRating.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          List<DocumentSnapshot> snapShot =
                              streamSnapshot.data!.docs;
                          var ratings = snapShot.where(
                              (element) => element.id == widget.model.id!);
                          return Row(
                            children: [
                              RatingBar(
                                rating: ratings.first['rating'].toDouble(),
                                size: 12,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: const [
                            RatingBar(
                              rating: 4.5,
                              size: 12,
                            ),
                          ],
                        );
                      }),
                ],
              ),
              const SizedBox(height: 3,),
            ],
          ),
        ],
      ),
    );
  }
}
