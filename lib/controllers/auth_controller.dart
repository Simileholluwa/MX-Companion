import 'dart:async';
import 'dart:core';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mx_companion_v1/screens/login/login.dart';
import 'package:mx_companion_v1/services/Authentication/auth_exceptions.dart';
import '../firebase_ref/loading_status.dart';
import '../screens/faq/faq.dart';
import '../screens/history/history.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/menu_screen.dart';
import '../screens/notification/notification.dart';
import '../screens/reset_password/reset_password.dart';
import '../screens/signup/signup_screen.dart';
import '../screens/verify_email/verify_email.dart';
import '../services/Authentication/auth_service.dart';
import '../widgets/alert_bottom_sheet.dart';

class AuthController extends GetxController {

  @override
  void onInit(){
    super.onInit();
    // _listener = InternetConnectionCheckerPlus().onStatusChange.listen((InternetConnectionStatus status) {
    //   switch(status){
    //     case InternetConnectionStatus.connected:
    //       connectionStatus.value = 1;
    //       break;
    //     case InternetConnectionStatus.disconnected:
    //       connectionStatus.value = 0;
    //       break;
    //   }
    // });
  }

  @override
  void onClose(){
    _listener.cancel();
    super.onClose();
  }

  @override
  void onReady() {
    initAuth();
    getToken();
    super.onReady();
  }

  final loadingStatus = LoadingStatus.loading.obs;
  final RxBool _isLoading = false.obs;
  late StreamSubscription<InternetConnectionStatus> _listener;
  //var connectionStatus = 0.obs;

  RewardedAd? rewardedAd;
  RxBool get isLoading => _isLoading;
  String? mToken = "";
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  late FirebaseAuth _auth;
  final _user = Rxn<User>();
  late Stream<User?> _authStateChanges;

  void initAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    _auth = FirebaseAuth.instance;
    _authStateChanges = _auth.authStateChanges();
    _authStateChanges.listen((User? user) {
      _user.value = user;
    });
    //navigateToUploader();
    if (_auth.currentUser != null) {
      if (_auth.currentUser!.emailVerified) {
        navigateToHome();
      } else {
        navigateToVerify();
      }
    } else {
      navigateToHome();
    }
  }

  signInWithEmail(String email, String password) async {
    try {
      _isLoading.value = true;
      await AuthService.firebase().logIn(
        email: email,
        password: password,
      );
      _isLoading.value = false;
      if (_user.value!.emailVerified) {
        navigateToHome();
        showSnackBar('Signed in as ${_user.value!.displayName}');
      } else {
        navigateToVerify();
      }
    } on UserNotFoundAuthException {
      _isLoading.value = false;
      showSnackBar('No account found with this email.');
    } on WrongPasswordAuthException {
      _isLoading.value = false;
      showSnackBar('Your password is incorrect.');
    } on UnknownAuthException {
      _isLoading.value = false;
      showSnackBar('Text fields cannot be empty.');
    } on InvalidEmailAuthException {
      _isLoading.value = false;
      showSnackBar('The email address is invalid.');
    } on NetworkRequestFailedAuthException {
      _isLoading.value = false;
      showSnackBar('You are not connected to the internet.');
    } on TooManyRequestAuthException {
      _isLoading.value = false;
      showSnackBar(
          'Your account is locked due to too many incorrect password. Please, try again later.');
    } on GenericAuthException {
      _isLoading.value = false;
      showSnackBar('Sign in failed. Try again later.');
    }
  }

  signUpWithEmail(
    String email,
    String password,
    String userName,
    String department,
    String phoneNumber,
    String url,
    DateTime created,
  ) async {
    try {
      _isLoading.value = true;
      await AuthService.firebase().createUser(
        email: email,
        password: password,
        userName: userName,
        department: department,
        phoneNumber: phoneNumber,
        url: url,
        created: created,
        deviceToken: mToken!,
      );
      _isLoading.value = false;
      await AuthService.firebase().sendEmailVerification();
      navigateToVerify();
      showSnackBar(
        'Sign up successful.',
      );
    } on WeakPasswordAuthException {
      _isLoading.value = false;
      showSnackBar('Password is too weak.');
    } on EmailAlreadyInUseAuthException {
      _isLoading.value = false;
      showSnackBar('This email already exist.');
    } on UnknownAuthException {
      _isLoading.value = false;
      showSnackBar('Text fields cannot be empty.');
    } on InvalidEmailAuthException {
      _isLoading.value = false;
      showSnackBar('The email address is invalid.');
    } on NetworkRequestFailedAuthException {
      _isLoading.value = false;
      showSnackBar('You are not connected to the internet.');
    } on TooManyRequestAuthException {
      _isLoading.value = false;
      showSnackBar('Too many incorrect password. Try again later.');
    } on GenericAuthException {
      _isLoading.value = false;
      showSnackBar('Sign in failed. Try again later.');
    } on UserNotLoggedInAuthException {
      _isLoading.value = false;
      showSnackBar('You are not signed in');
    }
  }

  User? getUser() {
    _user.value = _auth.currentUser;
    return _user.value;
  }

  resetPassword(String email) async {
    try {
      _isLoading.value = true;
      await AuthService.firebase().resetPassword(email: email);
      _isLoading.value = false;
      navigateToLogin();
      showSnackBar(
        'Check your email for password reset instructions.',
      );
    } on UserNotFoundAuthException {
      _isLoading.value = false;
      showSnackBar('No account found with this email.');
    } on UnknownAuthException {
      _isLoading.value = false;
      showSnackBar('Text fields cannot be empty.');
    } on InvalidEmailAuthException {
      _isLoading.value = false;
      showSnackBar('The email address is invalid.');
    } on NetworkRequestFailedAuthException {
      _isLoading.value = false;
      showSnackBar('You are not connected to the internet.');
    } on TooManyRequestAuthException {
      _isLoading.value = false;
      showSnackBar('Too many requests sent. Try again later.');
    } on GenericAuthException {
      _isLoading.value = false;
      navigateToLogin();
      showSnackBar(
        'Check your email for password reset instructions.',
      );
    }
  }

  signOut() async {
    try {
      await AuthService.firebase().logOut();
      navigateToHome();
      showSnackBar(
        'Signed out successfully.',
      );
    } on UserNotLoggedInAuthException {
      showSnackBar('You are currently not signed in.');
    }
  }

  verifyEmail() async {
    try {
      _isLoading.value = true;
      await AuthService.firebase().sendEmailVerification();
      showSnackBar(
        'Email verification has been sent to your email.',
      );
      _isLoading.value = false;
    } on UserNotLoggedInAuthException {
      _isLoading.value = false;
      showSnackBar('You are currently not signed in.');
    }
  }

  void navigateToHome() {
    Get.offAllNamed(HomeScreen.routeName);
  }

  void navigateToFaq() {
    Get.toNamed(FaqScreen.routeName);
  }

  void navigateToMenu() {
    Get.toNamed(MenuScreen.routeName);
  }

  navigateToVerify() {
    Get.offAndToNamed(VerifyEmail.routeName);
  }

  void navigateToReset() {
    Get.toNamed(ResetPassword.routeName);
  }

  void navigateToNotifications() {
    Get.toNamed(NotificationScreen.routeName);
  }

  void navigateToUploader() {
    Get.offAllNamed("/uploader");
  }

  void navigateToLogin() {
    Get.toNamed(LoginScreen.routeName);
  }

  void navigateToSignup() {
    Get.toNamed(SignupScreen.routeName);
  }

  void navigateToHistory() {
    Get.toNamed(HistoryScreen.routeName);
  }

  void showLoginAlertDialog(String message) async {
     await Sheet.appSheet(
        onTap: () {
          Get.back();
          navigateToLogin();
        },
        onPressed: () {
          Get.back();
        },
        action: 'Sign In',
        text: 'Hello there!',
        message: message,
       context: Get.context!
      );
  }

  void showCancelReminderAlertDialog(VoidCallback onTap, String courseCode) async {
      await Sheet.appSheet(
        onTap: onTap,
        onPressed: () {
          Get.back();
        },
        action: 'Remove',
        text: 'Remove Reminder',
        message:
            'Are you sure you want to remove reminder to practice $courseCode?',
        context: Get.context!,
      );
  }

  void showSignOutAlertDialog() async {
      await Sheet.appSheet(
        onTap: () {
          Get.back();
          signOut();
        },
        onPressed: () {
          Get.back();
        },
        action: 'Sign Out',
        text: 'Sign Out',
        message: 'Are you sure you want to sign out? Your access to practice questions will be restricted.',
        context: Get.context!
      );
  }

  Future<void> showDeleteAllHistory(
    VoidCallback onTap,
    String message,
  ) async {
    await Sheet.appSheet(
      onTap: onTap,
      onPressed: () => Get.back(),
      text: 'Delete All',
      message: 'Are you sure you want to delete all practice history?',
      action: 'Delete',
      context: Get.context!,
    );
  }

  void showPracticeInfo(
      String courseCode, String message, BuildContext context) async {
    await Sheet.appSheet(
      onTap: () {
        Get.back();
      },
      onPressed: () {
        Get.back();
      },
      context: context,
      cancel: false,
      action: 'Got It!',
      text: '$courseCode Course Information',
      message: message,
    );
  }

  void showNotificationDetails(String title, String body) async {
      await Sheet.appSheet(
        onTap: () {
          Get.back();
        },
        onPressed: () {
          Get.back();
        },
        cancel: false,
        action: 'Got It!',
        text: title,
        message: body,
        context: Get.context!,
      );
  }

  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  void showSnackBar(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
    );
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      mToken = token;
      update();
    });
  }
}
