import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mx_companion_v1/controllers/notifications_controller.dart';
import 'package:mx_companion_v1/controllers/question_paper/result_controller.dart';
import 'package:mx_companion_v1/firebase_ref/references.dart';
import 'package:mx_companion_v1/widgets/questions/questions_answer_card.dart';
import 'package:mx_companion_v1/widgets/star_system.dart';
import 'package:mx_companion_v1/widgets/text_button_with_icon.dart';
import '../../config/themes/ui_parameters.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/questions_controller.dart';
import '../../screens/questions_page/check_answer.dart';
import '../alert_bottom_sheet.dart';
import '../app_button.dart';
import '../content_area.dart';
import '../rating_bar.dart';
import '../rating_widget.dart';
import '../stats_widget.dart';
import '../text_field.dart';
import 'answer_card.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({Key? key}) : super(key: key);

  static const String routeName = "/resultScreen";

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController commentController;
  var comment = '';

  @override
  void initState() {
    super.initState();
    commentController = TextEditingController();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    QuestionsController controller = Get.find();
    AuthController auth = Get.find();

    String? pointsEarned;
    var userRatings = 0.0.obs;
    var userCount = 0.obs;
    var ratingSum = 0.obs;
    var allFives = 0.obs;
    var allFours = 0.obs;
    var allThrees = 0.obs;
    var allTwos = 0.obs;
    var allOnes = 0.obs;
    var tries = 0.obs;
    RxBool _isLoading = false.obs;

    final CollectionReference quizRating = fireStore
        .collection('users')
        .doc(auth.getUser()!.uid)
        .collection('user_rating');

    final CollectionReference allRating = fireStore.collection('allRatings');

    final CollectionReference allComment = fireStore
        .collection('comments')
        .doc(controller.paperId)
        .collection('allComments');

    void rateQuiz() async {
       await Sheet.updateDetailsDialog(
          title: 'Review Quiz',
          content: StreamBuilder(
            stream: quizRating.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                List<DocumentSnapshot> snapShot = streamSnapshot.data!.docs;
                var ratings = snapShot
                    .where((element) => element.id == controller.paperId);

                commentController.text = ratings.first['comment'];
                var rating = ratings.first['rating'];
                bool isRated = ratings.first['isRated'];
                var triesOnline = ratings.first['tries'];
                tries.value = triesOnline;
                if (streamSnapshot.data!.docs.isEmpty) {
                  return Container();
                } else {
                  return Padding(
                    padding: EdgeInsets.only(
                      top: 10.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: CustomTextField(
                                  onSaved: (value) {
                                    comment = value!;
                                  },
                                  validator: (String? value) {
                                    if (value!.isEmpty) {
                                      return 'Please, leave a comment';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: commentController,
                                  filled: false,
                                  labelText: 'Leave a comment',
                                  prefixIcon: Icons.comment,
                                  hintText: 'Comment',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const StarPage(),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            const SizedBox(
                              width: 1,
                              child: Divider(
                                thickness: 20,
                                height: 50,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            TextButton(
                              onPressed: () async {
                                final isValid =
                                    _formKey.currentState!.validate();
                                if (!isValid) {
                                  return;
                                } else {
                                  _formKey.currentState!.save();
                                  var comment = commentController.text.trim();
                                  switch (rating) {
                                    case 5:
                                      isRated == true
                                          ? ratingSum.value -= 5
                                          : null;
                                      isRated == true
                                          ? allFives.value -= 1
                                          : null;
                                      break;
                                    case 4:
                                      isRated == true
                                          ? ratingSum.value -= 4
                                          : null;
                                      isRated == true
                                          ? allFours.value -= 1
                                          : null;
                                      break;
                                    case 3:
                                      isRated == true
                                          ? ratingSum.value -= 3
                                          : null;
                                      isRated == true
                                          ? allThrees.value -= 1
                                          : null;
                                      break;
                                    case 2:
                                      isRated == true
                                          ? ratingSum.value -= 2
                                          : null;
                                      isRated == true
                                          ? allTwos.value -= 1
                                          : null;
                                      break;
                                    case 1:
                                      isRated == true
                                          ? ratingSum.value -= 1
                                          : null;
                                      isRated == true
                                          ? allOnes.value -= 1
                                          : null;
                                      break;
                                    default:
                                      isRated == true
                                          ? ratingSum.value -= 5
                                          : null;
                                      isRated == true
                                          ? allOnes.value -= 1
                                          : null;
                                      break;
                                  }

                                  switch (StarPage.starValue.value) {
                                    case 1:
                                      isRated == true
                                          ? allOnes.value += 1
                                          : allOnes.value += 1;
                                      isRated == false
                                          ? userCount.value += 1
                                          : null;
                                      rating = 1;
                                      break;
                                    case 2:
                                      isRated == true
                                          ? allTwos.value += 1
                                          : allTwos.value += 1;
                                      isRated == false
                                          ? userCount.value += 1
                                          : null;
                                      rating = 2;
                                      break;
                                    case 3:
                                      isRated == true
                                          ? allThrees.value += 1
                                          : allThrees.value += 1;
                                      isRated == false
                                          ? userCount.value += 1
                                          : null;
                                      rating = 3;
                                      break;
                                    case 4:
                                      isRated == true
                                          ? allFours.value += 1
                                          : allFours.value += 1;
                                      isRated == false
                                          ? userCount.value += 1
                                          : null;
                                      rating = 4;
                                      break;
                                    case 5:
                                      isRated == true
                                          ? allFives.value += 1
                                          : allFives.value += 1;
                                      isRated == false
                                          ? userCount.value += 1
                                          : null;
                                      rating = 5;
                                      break;
                                    default:
                                      isRated == true
                                          ? allOnes.value += 1
                                          : allOnes.value += 1;
                                      isRated == false
                                          ? userCount.value += 1
                                          : null;
                                      rating = 1;
                                  }

                                  try {
                                    _isLoading.value = true;
                                    await quizRating
                                        .doc(controller.paperId)
                                        .update({
                                      "rating": rating,
                                      "comment": comment,
                                      "isRated": true,
                                    });

                                    await allRating
                                        .doc(controller.paperId)
                                        .update({
                                      "ratingCount": userCount.value,
                                      "ratingSum": ratingSum.value + rating,
                                      "allFives": allFives.value,
                                      "allFours": allFours.value,
                                      "allThrees": allThrees.value,
                                      "allTwos": allTwos.value,
                                      "allOnes": allOnes.value,
                                    });

                                    await allRating
                                        .doc(controller.paperId)
                                        .update({
                                      "rating":
                                          ratingSum.value / userCount.value,
                                    });

                                    isRated == true
                                        ? controller.updateComment(
                                            comment, rating)
                                        : controller.saveComment(
                                            comment, rating);

                                    _isLoading.value = false;

                                    Get.back();

                                    Get.find<AuthController>().showSnackBar(
                                        'Thank you for reviewing this quiz.');
                                  } catch (e) {
                                    _isLoading.value = false;
                                    Get.find<AuthController>()
                                        .showSnackBar('Unable to send review.');
                                  }
                                }
                              },
                              child: _isLoading.isTrue
                                  ? LoadingAnimationWidget.prograssiveDots(
                                      color: Theme.of(context).primaryColor,
                                      size: 50,
                                    )
                                  : const Text('Review',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
              }
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 20.0,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                      left: 20,
                      right: 20,
                    ),
                    child: Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: Theme.of(context).primaryColor,
                        size: 60,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.scaffoldBackground,
        useDivider: false,
        opacity: 1,
      ),
      child: WillPopScope(
        onWillPop: () async {
          Get.find<AuthController>()
              .showSnackBar('Use the button provided to save and exit.');
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 70,
            shadowColor: Colors.transparent,
            automaticallyImplyLeading: false,
            scrolledUnderElevation: 0,
            title: Text(
              'Quiz Summary',
              style: Theme.of(context).textTheme.titleLarge!.merge(
                    const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ContentAreaCustom(
                    addRadius: true,
                    addColor: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        top: 20,
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => controller.isRewarded!.isTrue
                                ? Visibility(
                                    visible: controller.isRewarded!.value,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: Text(
                                            "ANSWERS",
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 20,
                                            right: 20,
                                          ),
                                          child: GridView.builder(
                                            itemCount:
                                                controller.allQuestions.length,
                                            shrinkWrap: true,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: Get.width ~/ 90,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 8,
                                              mainAxisSpacing: 8,
                                            ),
                                            itemBuilder: (_, index) {
                                              final _question = controller
                                                  .allQuestions[index];
                                              AnswerStatus _status =
                                                  AnswerStatus.notAnswered;
                                              final _selectedAnswer =
                                                  _question.selectedAnswer;
                                              final _correctAnswer =
                                                  _question.correctAnswer;

                                              if (_selectedAnswer ==
                                                  _correctAnswer) {
                                                _status = AnswerStatus.correct;
                                              } else if (_question
                                                      .selectedAnswer ==
                                                  null) {
                                                _status = AnswerStatus.wrong;
                                              } else {
                                                _status = AnswerStatus.wrong;
                                              }
                                              return QuestionAnswerCard(
                                                index: index + 1,
                                                status: _status,
                                                onTap: () {
                                                  controller.jumpToQuestion(
                                                    index,
                                                    goBack: false,
                                                  );
                                                  Get.toNamed(AnswerCheckScreen
                                                      .routeName);
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Divider(
                                          height: 5,
                                          thickness: 3,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                      ],
                                    ),
                                  )
                                : Container(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "YOUR STATS",
                                      textAlign: TextAlign.left,
                                    ),
                                    Obx(
                                      () => controller.isRewardedPoints!.isFalse
                                          ? TextButtonWithIcon(
                                              onTap: () {
                                                if (controller.rewardedAd != null) {
                                                  controller.rewardedAd?.show(
                                                      onUserEarnedReward: (_, reward) {
                                                        controller
                                                            .isRewardedPoints!
                                                            .value = true;
                                                        pointsEarned =
                                                            controller.points;
                                                      });
                                                } else {
                                                  if (controller.interstitialAd2 != null) {
                                                    controller.interstitialAd2?.show();
                                                    controller
                                                        .isRewardedPoints!
                                                        .value = true;
                                                    pointsEarned =
                                                        controller.points;
                                                  } else {
                                                    auth.showSnackBar(
                                                        'Please turn on your mobile data.');
                                                  }
                                                }
                                              },
                                              text:
                                                  'Claim ${controller.points} points',
                                              icon: Icons.payments,
                                            )
                                          : TextButtonWithIcon(
                                              onTap: () {
                                                Get.find<AuthController>()
                                                    .showSnackBar(
                                                        'Points have been claimed.');
                                              },
                                              icon: Icons.check,
                                              text: 'Points claimed',
                                            ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "scroll left or right for more",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                    fontSize: 8,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      Obx(
                                        () =>
                                            controller.isRewardedPoints!.isFalse
                                                ? const Stat(
                                                    text: '0.0',
                                                    name: 'Points',
                                                  )
                                                : Stat(
                                                    text: controller.points,
                                                    name: 'Points',
                                                  ),
                                      ),
                                      const SizedBox(width: 10),
                                      Stat(
                                        text:
                                            '${controller.correctQuestionCount} / ${controller.allQuestions.length}',
                                        name: 'Score',
                                      ),
                                      const SizedBox(width: 10),
                                      Stat(
                                        text: controller.timeSpent,
                                        name: 'Minutes',
                                      ),
                                      const SizedBox(width: 10),
                                      StreamBuilder(
                                          stream: quizRating.snapshots(),
                                          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot){
                                            if (streamSnapshot.hasData) {
                                              List<DocumentSnapshot> snapShot = streamSnapshot.data!.docs;
                                              var ratings = snapShot
                                                  .where((element) => element.id == controller.paperId);

                                              int triesOnline = ratings.first['tries'];
                                              tries.value = triesOnline;
                                              return Stat(
                                                text: triesOnline.toString(),
                                                name: 'Attempts',
                                               );
                                            }
                                            return const Stat(
                                              text: '12',
                                              name: 'Attempts',
                                            );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 5,
                            thickness: 3,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          Column(
                            children: [
                              const SizedBox(
                                height: 2,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20,),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "REVIEWS",
                                      textAlign: TextAlign.left,
                                    ),
                                    StreamBuilder(
                                        stream: quizRating.snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                streamSnapshot) {
                                          if (streamSnapshot.hasData) {
                                            List<DocumentSnapshot> snapShot =
                                                streamSnapshot.data!.docs;
                                            var ratings = snapShot.where(
                                                (element) =>
                                                    element.id ==
                                                    controller.paperId);

                                            bool isRated =
                                                ratings.first['isRated'];
                                            if (streamSnapshot
                                                .data!.docs.isEmpty) {
                                              return Container();
                                            } else {
                                              return TextButtonWithIcon(
                                                onTap: () {
                                                  rateQuiz();
                                                },
                                                text: isRated == true
                                                    ? 'Edit review'
                                                    : 'Review quiz',
                                                icon: isRated == true
                                                    ? Icons.edit
                                                    : Icons.star,
                                              );
                                            }
                                          }
                                          return Container();
                                        }),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20, right: 20,),
                                child: StreamBuilder(
                                  stream: allRating.snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot>
                                          streamSnapshot) {
                                    if (streamSnapshot.hasData) {
                                      List<DocumentSnapshot> snapShot =
                                          streamSnapshot.data!.docs;
                                      var paperRating = snapShot.where(
                                          (element) =>
                                              element.id == controller.paperId);

                                      var rated =
                                          paperRating.first['rating'].toDouble();
                                      userRatings.value = rated;
                                      var count =
                                          paperRating.first['ratingCount'];
                                      userCount.value = count;
                                      var sum = paperRating.first['ratingSum'];
                                      ratingSum.value = sum;
                                      var fives = paperRating.first['allFives'];
                                      allFives.value = fives;
                                      var fours = paperRating.first['allFours'];
                                      allFours.value = fours;
                                      var threes = paperRating.first['allThrees'];
                                      allThrees.value = threes;
                                      var twos = paperRating.first['allTwos'];
                                      allTwos.value = twos;
                                      var ones = paperRating.first['allOnes'];
                                      allOnes.value = ones;

                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 150,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .highlightColor,
                                              borderRadius:
                                                  UIParameters.cardBorderRadius,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    rated.toString(),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge!
                                                        .merge(
                                                          const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 60,
                                                          ),
                                                        ),
                                                  ),
                                                  RatingBar(
                                                    rating: rated,
                                                    size: 24,
                                                  ),
                                                  Text(
                                                    '$count verified ratings',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 150,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Rating(
                                                  number: '5',
                                                  value: count <= 0
                                                      ? 0.0
                                                      : fives / count,
                                                ),
                                                Rating(
                                                  number: '4',
                                                  value: count <= 0
                                                      ? 0.0
                                                      : fours / count,
                                                ),
                                                Rating(
                                                  number: '3',
                                                  value: count <= 0
                                                      ? 0.0
                                                      : threes / count,
                                                ),
                                                Rating(
                                                  number: '2',
                                                  value: count <= 0
                                                      ? 0.0
                                                      : twos / count,
                                                ),
                                                Rating(
                                                  number: '1',
                                                  value: count <= 0
                                                      ? 0.0
                                                      : ones / count,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              StreamBuilder(
                                stream: allComment.snapshots(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot>
                                        streamSnapshot) {
                                  if (streamSnapshot.hasData) {
                                    if (streamSnapshot.data!.docs.isEmpty) {
                                      return const Padding(
                                        padding: EdgeInsets.only(
                                          top: 10,
                                          left: 20,
                                        ),
                                        child: Text(
                                            'Be the first to review this quiz!'),
                                      );
                                    }
                                    return Column(
                                      children: [
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Divider(
                                          height: 5,
                                          thickness: 3,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                        ),
                                        const SizedBox(
                                          height: 2,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20, right: 20,),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "COMMENTS",
                                                textAlign: TextAlign.left,
                                              ),
                                              TextButtonWithIcon(
                                                onTap: () {
                                                  if (streamSnapshot.data!.docs.length <= 2) {
                                                    auth.showSnackBar('All comments are shown below');
                                                  } else {
                                                    controller
                                                      .navigateToComments();
                                                  }
                                                },
                                                text: 'View all',
                                                icon: Icons.view_list_sharp,
                                              ),
                                            ],
                                          ),
                                        ),
                                        ListView.separated(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            shrinkWrap: true,
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return const SizedBox(
                                                height: 10,
                                              );
                                            },
                                            itemCount: streamSnapshot
                                                        .data!.docs.length <
                                                    2
                                                ? 1
                                                : 2,
                                            itemBuilder: (context, index) {
                                              final DocumentSnapshot
                                                  documentSnapShot =
                                                  streamSnapshot
                                                      .data!.docs[index];
                                              return Material(
                                                borderRadius: UIParameters
                                                    .cardBorderRadius,
                                                child: InkWell(
                                                  borderRadius: UIParameters
                                                      .cardBorderRadius,
                                                  onTap: () {
                                                    controller.commentPreview(
                                                        documentSnapShot[
                                                            'comment'],
                                                        documentSnapShot[
                                                            'rating'],
                                                        documentSnapShot[
                                                            'userDisplayName']);
                                                  },
                                                  child: Ink(
                                                    decoration: BoxDecoration(
                                                        borderRadius: UIParameters
                                                            .cardBorderRadius),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      vertical: 5,
                                                      horizontal: 20,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Flexible(
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      RatingBar(
                                                                          rating:
                                                                              documentSnapShot['rating'].toDouble()),
                                                                      Text(
                                                                        documentSnapShot['created']
                                                                            .toDate()
                                                                            .toString()
                                                                            .substring(0,
                                                                                16),
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .titleMedium!
                                                                            .merge(
                                                                              const TextStyle(
                                                                                fontSize: 12,
                                                                              ),
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(
                                                                    documentSnapShot[
                                                                        'userDisplayName'],
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    softWrap:
                                                                        false,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .titleMedium!
                                                                        .merge(
                                                                          const TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                  ),
                                                                  Text(
                                                                    documentSnapShot[
                                                                        'comment'],
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    softWrap:
                                                                        false,
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .titleMedium!
                                                                        .merge(
                                                                          TextStyle(
                                                                              color: Theme.of(context).hintColor),
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
                                              );
                                            }),
                                      ],
                                    );
                                  }
                                  return Container();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: UIParameters.mobileScreenPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      child: AppButton(
                        onTap: () async {
                          if (controller.interstitialAd != null) {
                            controller.interstitialAd?.show();
                            controller.saveTestResult(pointsEarned);
                            await quizRating
                                .doc(controller.paperId)
                                .update({
                              "tries": tries.value += 1,
                            });
                            HelperNotification.scheduleLocalNotifications(
                              101,
                              'Awesome!',
                              'You have just completed a practice quiz on ${controller.questionModel.courseCode}. Don\'t be driven by your points, the more you practice, the better you become!',
                              DateTime.now().add(
                                const Duration(seconds: 30),
                              ),
                            );
                          } else {
                            controller.navigateToHome();
                            Get.find<AuthController>()
                                .showSnackBar('Practice result not saved.');
                          }
                        },
                        buttonWidget: const Text('Save & Exit',
                            style: TextStyle(
                              fontSize: 15,
                            )),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Obx(
                      () => controller.isRewarded!.isFalse
                          ? SizedBox(
                              width: 160,
                              child: AppButton(
                                onTap: () {
                                  if (controller.rewardedAd != null) {
                                    controller.rewardedAd?.show(
                                        onUserEarnedReward: (_, reward) {
                                      controller.isRewarded!.value = true;
                                    });
                                  } else {
                                    if (controller.interstitialAd2 != null) {
                                      controller.interstitialAd2?.show();
                                      controller.isRewarded!.value = true;
                                    } else {
                                      auth.showSnackBar(
                                          'Please turn on your mobile data.');
                                    }
                                  }
                                },
                                buttonWidget: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('View answers'),
                                    SizedBox(width: 10),
                                    Icon(Icons.videocam),
                                  ],
                                ),
                              ),
                            )
                          : Container(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
