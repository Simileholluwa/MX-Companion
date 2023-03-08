import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mx_companion_v1/widgets/content_area.dart';
import '../../controllers/question_paper/question_paper_controller.dart';
import '../home/question_card.dart';

class CustomSearchDelegate extends SearchDelegate {
  QuestionPaperController questionPaperController = Get.find();

  static String routeName = "/customSearch";

  // clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Padding(
        padding: const EdgeInsets.only(right: 15.0),
        child: IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear, size: 30,),
        ),
      ),
    ];
  }

  // second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back_ios_new_sharp, size: 30,),
      ),
    );
  }

  // third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    Iterable<String> searchTerms = questionPaperController.allPapers.map((element) => element.courseCode!);
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.scaffoldBackground,
        useDivider: false,
        opacity: 1,),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: ContentAreaCustom(
                  addRadius: true,
                  addColor: true,
                  addPadding: false,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.separated(
                          itemCount: matchQuery.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder:
                              (BuildContext context, int index) {
                            return Divider(
                              height: 5,
                              thickness: 3,
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor,
                            );
                          },
                          itemBuilder: (context, index) {
                            var result = matchQuery[index];
                            return QuestionsCard(
                              model: questionPaperController.allPapers[index],
                              searchResult: result,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // querying process at the runtime
  @override
  Widget buildSuggestions(BuildContext context) {
    Iterable<String> searchTerms = questionPaperController.allPapers.map((element) => element.courseCode!);
    List<String> matchQuery = [];
    for (var fruit in searchTerms) {
      if (fruit.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(fruit);
      }
    }
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: FlexColorScheme.themedSystemNavigationBar(
        context,
        systemNavBarStyle: FlexSystemNavBarStyle.scaffoldBackground,
        useDivider: false,
        opacity: 1,),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: ContentAreaCustom(
                  addRadius: true,
                  addColor: true,
                  addPadding: false,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListView.separated(
                          itemCount: matchQuery.length,
                          shrinkWrap: true,
                          physics: const BouncingScrollPhysics(),
                          separatorBuilder:
                              (BuildContext context, int index) {
                            return Divider(
                              height: 5,
                              thickness: 3,
                              color: Theme.of(context)
                                  .scaffoldBackgroundColor,
                            );
                          },
                          itemBuilder: (context, index) {
                            var result = matchQuery[index];
                            return QuestionsCard(
                              model: questionPaperController.allPapers[index],
                              searchResult: result,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context){
    return Theme.of(context).copyWith(
      scaffoldBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      focusColor: Colors.transparent,
      inputDecorationTheme: const InputDecorationTheme(
        focusColor: Colors.transparent,
      ),
      appBarTheme: AppBarTheme(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      )
    );
  }
}