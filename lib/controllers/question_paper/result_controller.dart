import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mx_companion_v1/controllers/questions_controller.dart';
import '../../firebase_ref/references.dart';
import '../../widgets/alert_user.dart';
import '../../widgets/star_system.dart';
import '../auth_controller.dart';

extension QuestionsControllerExtension on QuestionsController {
  int get correctQuestionCount => allQuestions
      .where((element) => element.selectedAnswer == element.correctAnswer)
      .toList()
      .length;

  String get paperId {
    return questionModel.id!;
  }

  String get correctAnsweredQuestions {
    return '$correctQuestionCount out of ${allQuestions.length} are correct';
  }

  String get points {
    var points = ((correctQuestionCount / allQuestions.length * 100) + (secondsLeft / questionModel.timeSeconds! * 100)) / 10;
    return points.toStringAsFixed(2);
  }

  String get timeSpent {
    var timeMinutes = (questionModel.timeSeconds! - secondsLeft) ~/ 60;
    var timeSeconds = (questionModel.timeSeconds! - secondsLeft) % 60;
    return "${timeMinutes.toString().padLeft(2, '0')}:${timeSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> saveComment(String comment, int rating) async {
    var batch = fireStore.batch();
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return;

    try {
      batch.set(fireStore
          .collection('comments')
          .doc(paperId)
          .collection('allComments')
          .doc(), {
        "created": DateTime.now(),
        "comment": comment,
        "rating": rating,
        "userEmail": _user.email,
        "userDisplayName": _user.displayName
      });
      await batch.commit();
    } catch (e){
      return;
    }
  }

  Future<String> getDocId(String email) {
    var doc = fireStore
        .collection('comments')
        .doc(paperId)
        .collection('allComments')
        .where("userEmail", isEqualTo: email).get();
    return doc.then((value) => value.docs.first.id);
  }

  Future<void> updateComment(String comment, int rating) async {
    var batch = fireStore.batch();
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return;
    var docId = await getDocId(_user.email!);
    print(docId);

    try {
      batch.set(fireStore
          .collection('comments')
          .doc(paperId)
          .collection('allComments')
          .doc(docId), {
        "created": DateTime.now(),
        "comment": comment,
        "rating": rating,
        "userEmail": _user.email,
        "userDisplayName": _user.displayName
      });
      await batch.commit();
    } catch (e){
      return;
    }
  }

  void commentPreview(String text, int value, String userName) {
    Get.dialog(
      Dialogs.starRating(
        onTap: () {
          Get.back();
        },
        tapString: 'Close',
        title: 'Review by $userName',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                Text(
                  text,
                  style: Theme.of(Get.context!).textTheme.titleMedium!.merge( TextStyle(color: Theme.of(Get.context!).hintColor, fontSize: 15,),),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StarPage(value: value, canChange: false,),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> saveTestResult(String? pointsEarned) async {
    var batch = fireStore.batch();
    User? _user = Get.find<AuthController>().getUser();
    if (_user == null) return;

    try {
      batch.set(
          userRF.doc(_user.uid)
              .collection('user_tests')
              .doc(),
          {
            "created": DateTime.now(),
            "points": pointsEarned ?? '0.00',
            "correct_answer_count":
            "$correctQuestionCount/${allQuestions.length}",
            "question_id": questionModel.courseCode,
            "time_spent": questionModel.timeSeconds! - secondsLeft,
            "course_title": questionModel.courseTitle,
          });
      await batch.commit();
      Get.find<AuthController>()
          .showSnackBar('Practice result saved.');
      navigateToHome();
    } catch(e){
      Get.find<AuthController>()
          .showSnackBar('Practice result not saved.');
    }
  }
}
