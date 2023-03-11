import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/notifications_controller.dart';
import '../../firebase_options.dart';
import '../../firebase_ref/references.dart';
import '../../models/questions_model.dart';
import 'auth_exceptions.dart';
import 'auth_provider.dart';
import 'auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String userName,
    required String department,
    required String phoneNumber,
    required String url,
    required DateTime created,
    required String deviceToken,
  }) async {
    try {

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseAuth.instance.currentUser!.updateDisplayName(userName);
      FirebaseAuth.instance.currentUser!.updatePhotoURL(url);
      addUserDetails(email, department, phoneNumber, userName, created, url,);
      addDeviceToken(deviceToken);
      uploadUserRating();
      HelperNotification.scheduleLocalNotifications(100, 'Hello $userName', 'Welcome to MX Companion! The best place to study past questions and ace your e-exams and e-tests. We hope you find our app resourceful.', DateTime.now().add(const Duration(seconds: 20)));

      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {

      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'unknown') {
        throw UnknownAuthException();
      } else if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }

  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'unknown') {
        throw UnknownAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedAuthException();
      } else if (e.code == 'too-many-requests') {
        throw TooManyRequestAuthException();
      } else {
        throw GenericAuthException();
      }
    }
    catch (e) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }


  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<AuthUser> resetPassword({required String email}) async {
    try {

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (e){
      throw GenericAuthException();
    }
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  Future addUserDetails(String email, String department, String phoneNumber, String userName, DateTime created, String url) async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('user_details').add(
        {
          'email' : email,
          'department' : department,
          'phoneNumber' : phoneNumber,
          'userName' : userName,
          'url' : url,
          'created' : created,
        });
  }

  Future addDeviceToken(String deviceToken) async {
    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('user_device_token').doc("device_token").set({
      'device_token' : deviceToken,
    });
  }

  Future uploadUserRating() async {
    final fireStore = FirebaseFirestore.instance;
    //Load json files
    final manifestContent = await DefaultAssetBundle.of(Get.context!)
        .loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assetsPapers = manifestMap.keys
        .where((path) =>
    path.startsWith("assets/DB/papers") && path.contains(".json"))
        .toList();

    //Read json content
    List<QuestionsModel> questionPapers = [];
    for(var paper in assetsPapers){
      String paperContent = await rootBundle.loadString(paper);
      questionPapers.add(QuestionsModel.fromJson(json.decode(paperContent)));
    }

    var batch = fireStore.batch();
    for(var papers in questionPapers){
      for (var ratings in papers.ratings!){
        batch.set(
            userRF.doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('user_rating')
                .doc(papers.id),{
          "comment": ratings.comment,
          "rating": ratings.rating,
          "isRated": ratings.isRated,
          "tries": 0,
        });
      }

      for (var _ in papers.ratings!){
        batch.set(
            userRF.doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('user_schedule')
                .doc(papers.id),{
          "isSet": false,
          "reminder_id": int.tryParse(papers.courseCode!.substring(3, 6))!,
        });
      }
    }
    await batch.commit();
  }
}







