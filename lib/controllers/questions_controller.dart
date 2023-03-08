import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mx_companion_v1/controllers/question_paper/question_paper_controller.dart';
import 'package:mx_companion_v1/firebase_ref/loading_status.dart';
import 'package:mx_companion_v1/models/questions_model.dart';
import 'package:mx_companion_v1/screens/home/home_screen.dart';
import '../firebase_ref/references.dart';
import '../screens/comments/comments.dart';
import '../widgets/questions/result_screen.dart';
import 'ad_helper.dart';

class QuestionsController extends GetxController {
  final loadingStatus = LoadingStatus.loading.obs;
  late QuestionsModel questionModel;
  final allQuestions = <Questions>[];
  final questionIndex = 0.obs;
  bool get isFirstQuestion => questionIndex.value > 0;
  bool get isLastQuestion => questionIndex.value >= allQuestions.length - 1;
  late final RxBool? _isRewarded;
  RxBool? get isRewarded => _isRewarded;
  late final RxBool? _isRewardedPoints;
  RxBool? get isRewardedPoints => _isRewardedPoints;
  Rxn<Questions> currentQuestion = Rxn<Questions>();
  InterstitialAd? interstitialAd, interstitialAd2;
  BannerAd? bannerAd;
  RewardedAd? rewardedAd;
  int random = 1 + Random().nextInt(20);


  //Timer
  Timer? _timer;
  int secondsLeft = 1;
  final time = '00.00'.obs;

  @override
  void onReady() {
    final _questionPaper = Get.arguments as QuestionsModel;
    loadData(_questionPaper);
    loadInterstitialAd2();
    loadInterstitialAd();
    loadBannerAd();
    loadRewardedAd();
    _isRewarded = false.obs;
    _isRewardedPoints = false.obs;
    super.onReady();
  }

  @override
  void onClose(){
    interstitialAd?.dispose();
    interstitialAd2?.dispose();
    bannerAd?.dispose();
    rewardedAd?.dispose();
    super.onClose();
  }

  void loadBannerAd(){
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          bannerAd = ad as BannerAd;
          update();
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    ).load();
  }

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdHelper.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                rewardedAd = null;
                update();
              loadRewardedAd();
            },
          );
            rewardedAd = ad;
        },
        onAdFailedToLoad: (err) {
          if(kDebugMode) {
            print('Failed to load a rewarded ad: ${err.message}');
          }
        },
      ),
    );
  }

  void loadInterstitialAd2() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {},
          );
          interstitialAd2 = ad;
          update();
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load an interstitial ad: ${err.message}');
          }
        },
      ),
    );
  }

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              Get.offNamedUntil(HomeScreen.routeName, (route) => false);
            },
          );
          interstitialAd = ad;
          update();
        },
        onAdFailedToLoad: (err) {
          if (kDebugMode) {
            print('Failed to load an interstitial ad: ${err.message}');
          }
        },
      ),
    );
  }

  Future<void> loadData(QuestionsModel questionPaper) async {
    questionModel = questionPaper;
    loadingStatus.value = LoadingStatus.loading;
    try {
      final QuerySnapshot<Map<String, dynamic>> questionQuery =
          await questionPaperRF
              .doc(questionPaper.id)
              .collection("questions")
              .get();

      final questions = questionQuery.docs
          .map((snapshot) => Questions.fromSnapshot(snapshot))
          .toList()..shuffle();

      questionPaper.questions = questions.sublist(0, 20);

      for (Questions _question in questionPaper.questions!) {
        final QuerySnapshot<Map<String, dynamic>> answerQuery =
            await questionPaperRF
                .doc(questionPaper.id)
                .collection("questions")
                .doc(_question.id)
                .collection("answers")
                .get();

        final answers = answerQuery.docs
            .map((answer) => Answers.fromSnapshot(answer))
            .toList();
        _question.answers = answers;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (questionPaper.questions != null &&
        questionPaper.questions!.isNotEmpty) {
      allQuestions.assignAll(questionPaper.questions!);
      shuffle(allQuestions, 1);
      currentQuestion.value = questionPaper.questions![0];
      _startTimer(questionPaper.timeSeconds!);
      loadingStatus.value = LoadingStatus.completed;
    } else {
      loadingStatus.value = LoadingStatus.error;
    }
  }

  void selectedAnswer(String? answer) {
    currentQuestion.value!.selectedAnswer = answer;
    update(['answers_list', 'answer_review_list']);
  }

  String get completedTest {
    final answered = allQuestions
        .where((element) => element.selectedAnswer != null)
        .toList()
        .length;
    return "$answered out of ${allQuestions.length} answered";
  }

  void jumpToQuestion(int index, {bool goBack = true}) {
    questionIndex.value = index;
    currentQuestion.value = allQuestions[index];
    if(goBack) {
      Get.back();
    }
  }

  void cancelTimer(){
    _timer?.cancel();
  }
  
  void submit(){
    _timer!.cancel();
    Get.toNamed(ResultScreen.routeName);
  }
  

  void nextQuestion() {
    if (questionIndex.value >= allQuestions.length - 1) {
      return;
    } else {
      questionIndex.value++;
      currentQuestion.value = allQuestions[questionIndex.value];
    }
  }

  void prevQuestion() {
    if (questionIndex.value <= 0) {
      return;
    } else {
      questionIndex.value--;
      currentQuestion.value = allQuestions[questionIndex.value];
    }
  }

  void tryAgain() {
    Get.find<QuestionPaperController>()
        .navigateToQuestions(paper: questionModel, tryAgain: true,
    );
    _startTimer(questionModel.timeSeconds!);
  }

  void navigateToHome() {
    _timer?.cancel();
    Get.offAllNamed(HomeScreen.routeName);
  }

  void navigateToComments(){
    Get.toNamed(CommentScreen.routeName);
  }

  _startTimer(int seconds) {
    const duration = Duration(seconds: 1,);
    secondsLeft = seconds;
    _timer = Timer.periodic(duration, (Timer timer) {
      if (secondsLeft == 1) {
        submit();
      } else {
        int minutes = secondsLeft ~/ 60;
        int seconds = secondsLeft % 60;
        time.value =
            "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
        secondsLeft--;
      }
    });
  }

}
