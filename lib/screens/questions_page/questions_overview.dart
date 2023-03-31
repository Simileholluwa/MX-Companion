import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import 'package:mx_companion_v1/controllers/questions_controller.dart';
import '../../config/themes/ui_parameters.dart';
import '../../widgets/app_button.dart';
import '../../widgets/content_area.dart';
import '../../widgets/questions/answer_card.dart';
import '../../widgets/questions/questions_answer_card.dart';
import '../../widgets/text_button_with_icon.dart';

class QuestionsOverview extends GetView<QuestionsController> {
  const QuestionsOverview({Key? key}) : super(key: key);

  static const String routeName = "/questionsOverview";

  @override
  Widget build(BuildContext context) {
    AuthController auth = Get.find();

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
          title: Text(
            controller.completedTest,
            style: Theme.of(context).textTheme.titleMedium!.merge(
                  const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: BackButton(),
          ),
        ),
        body: Column(
          children: [
            Obx(
              () => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ContentAreaCustom(
                    addRadius: true,
                    addColor: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    color: Color(0xffeea346),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "${controller.time.value} remaining",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium!
                                        .merge(
                                          const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          auth.connectionStatus.value == 1
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: controller.allQuestions.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: Get.width ~/ 90,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                  ),
                                  itemBuilder: (_, index) {
                                    AnswerStatus? _answerStatus;
                                    if (controller.allQuestions[index]
                                            .selectedAnswer !=
                                        null) {
                                      _answerStatus = AnswerStatus.answered;
                                    }
                                    return QuestionAnswerCard(
                                      addSplash: true,
                                      index: index + 1,
                                      status: _answerStatus,
                                      onTap: () =>
                                          controller.jumpToQuestion(index),
                                    );
                                  })
                              : SizedBox(
                                  width: double.maxFinite,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.wifi_off_sharp,
                                        size: 150,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        'Kindly ensure you have an active and stable internet.',
                                        textAlign: TextAlign.center,
                                      ),
                                      TextButtonWithIcon(
                                        onTap: () {},
                                        icon: Icons.refresh_sharp,
                                        text: 'Refresh',
                                      ),
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: UIParameters.mobileScreenPadding,
              child: AppButton(
                onTap: () {
                  auth.connectionStatus.value == 1
                      ? controller.submit()
                      : auth.showSnackBar('Please turn on your mobile data.');
                },
                buttonWidget: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
