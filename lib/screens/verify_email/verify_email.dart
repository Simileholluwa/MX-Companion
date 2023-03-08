import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import '../../config/themes/ui_parameters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/text_button_with_icon.dart';

class VerifyEmail extends GetView<AuthController> {
  const VerifyEmail({Key? key}) : super(key: key);

  static const String routeName = "/verify";

  @override
  Widget build(BuildContext context) {
    DateTime _lastExitTime = DateTime.now();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.scaffoldBackground,
        useDivider: false,
        opacity: 1,
      ),
      child: WillPopScope(
        onWillPop: () async {
          if (DateTime.now().difference(_lastExitTime) >=
              const Duration(seconds: 2)) {
            controller.showSnackBar(
              'Press the back button again to exit app.',
            );
            _lastExitTime = DateTime.now();
            return false;
          } else {
            return true;
          }
        },
        child: Scaffold(
          appBar: AppBar(
            shadowColor: Colors.transparent,
            scrolledUnderElevation: 0,
            toolbarHeight: 70,
            automaticallyImplyLeading: false,
            title: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                'Verify Email',
                style: Theme.of(context).textTheme.titleLarge!.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
            ),
          ),
          body: controller.getUser()!.emailVerified ?
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: UIParameters.mobileScreenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/practice_complete.png"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Email verified! Have fun studying.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AppButton(
                    onTap: () {
                      controller.navigateToHome();
                    },
                    buttonWidget: controller.isLoading.isFalse
                        ? const Text(
                      'Home', style: TextStyle(fontSize: 20,),
                    )
                        : LoadingAnimationWidget.prograssiveDots(
                      color: Theme.of(context).primaryColor,
                      size: 60,
                    ),

                  ),
                ],
              ),
            ),
          ) :
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: UIParameters.mobileScreenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.background,
                    ),
                    child: Center(
                      child: Container(
                        height: 130,
                        width: 130,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/check.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Please follow the link sent to your registered email inbox including your spam folder to verify your account. If you did not receive an email, use the button below.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  AppButton(
                    onTap: () {
                      controller.verifyEmail();
                    },
                    buttonWidget: controller.isLoading.isFalse
                        ? const Text(
                      'Resend Verification Email', style: TextStyle(fontSize: 20,),
                    )
                        : LoadingAnimationWidget.prograssiveDots(
                      color: Theme.of(context).primaryColor,
                      size: 60,
                    ),

                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButtonWithIcon(
                        onTap: () {
                          controller.navigateToLogin();
                        },
                        icon: Icons.login_sharp,
                        text: 'Login',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
