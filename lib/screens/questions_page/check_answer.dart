import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/questions_controller.dart';
import '../../widgets/content_area.dart';
import '../../widgets/questions/answer_card.dart';
import '../../widgets/questions/result_screen.dart';

class AnswerCheckScreen extends GetView<QuestionsController> {
  const AnswerCheckScreen({Key? key}) : super(key: key);

  static const String routeName = '/checkAnswerScreen';

  @override
  Widget build(BuildContext context) {
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
          title: Obx(
            () => Center(
              child: Text(
                'Q. ${(controller.questionIndex.value + 1).toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.titleMedium!.merge(const TextStyle(fontWeight: FontWeight.bold,),),
              ),
            ),
          ),
          centerTitle: true,
          leading: const Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: BackButton(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: IconButton(
                onPressed: () => Get.toNamed(ResultScreen.routeName),
                icon: const Icon(Icons.menu_sharp, size: 30,),
              ),
            ),
          ],
        ),
        body: Obx(
          () => Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: ContentAreaCustom(
                    addRadius: true,
                    addColor: true,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20,),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              controller.currentQuestion.value!.question,
                              style: Theme.of(context).textTheme.titleLarge!.merge( const TextStyle(fontWeight: FontWeight.bold,),),
                            ),
                          ),
                          GetBuilder<QuestionsController>(
                              id: 'answers_review_list',
                              builder: (_) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.only(
                                    top: 10,
                                    left: 20,
                                    right: 20,
                                  ),
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (BuildContext context, int index) {
                                    final answer = controller
                                        .currentQuestion.value!.answers[index];
                                    final selectedAnswer = controller
                                        .currentQuestion.value!.selectedAnswer;
                                    final correctAnswer = controller
                                        .currentQuestion.value!.correctAnswer;
                                    final String answerText =
                                        '${answer.identifier}. ${answer.answer}';
                                    if (correctAnswer == selectedAnswer &&
                                        answer.identifier == selectedAnswer) {
                                      return CorrectAnswer(answer: answerText);
                                    } else if (selectedAnswer == null) {
                                    } else if (correctAnswer != selectedAnswer &&
                                        answer.identifier == selectedAnswer) {
                                      return WrongAnswer(answer: answerText);
                                    } else if (correctAnswer ==
                                        answer.identifier) {
                                      return CorrectAnswer(answer: answerText);
                                    }
                                    return AnswerCard(
                                      noSplash: true,
                                      answer:
                                          answerText,
                                      onTap: () {},
                                      isSelected: false,
                                    );
                                  },
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const SizedBox(
                                    height: 10,
                                  ),
                                  itemCount: controller
                                      .currentQuestion.value!.answers.length,
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

