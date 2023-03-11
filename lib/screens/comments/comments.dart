import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mx_companion_v1/controllers/question_paper/result_controller.dart';
import 'package:mx_companion_v1/controllers/questions_controller.dart';
import '../../config/themes/ui_parameters.dart';
import '../../firebase_ref/references.dart';
import '../../widgets/content_area.dart';
import '../../widgets/rating_bar.dart';

class CommentScreen extends StatefulWidget {
  const CommentScreen({
    Key? key,
  }) : super(key: key);

  static const String routeName = "/comments";

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  
  @override
  Widget build(BuildContext context) {

    QuestionsController controller = Get.find();

    final CollectionReference allComment = fireStore
        .collection('comments')
        .doc(controller.paperId)
        .collection('allComments');
    
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
          leading: Container(
            margin: const EdgeInsets.only(
              left: 15,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_outlined,
                size: 30,
              ),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          title: Text(
            'Comments',
            style: Theme.of(context).textTheme.titleLarge!.merge(
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
            ),
          ),
        ),
        body: StreamBuilder(
          stream: allComment
              .orderBy(
            'created',
            descending: true,
          )
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
            if (streamSnapshot.hasData) {
              if (streamSnapshot.data!.docs.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.comment,
                          size: 150,
                        ),
                        Text(
                         'There are no new comments.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Column(
                  children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: ContentAreaCustom(
                          addRadius: true,
                          addColor: true,
                          addPadding: false,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider(
                                        height: 5,
                                        thickness: 3,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      );
                                    },
                                    itemCount: streamSnapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final DocumentSnapshot documentSnapShot =
                                      streamSnapshot.data!.docs[index];
                                      return Material(
                                        type: MaterialType.transparency,
                                        borderRadius:
                                        UIParameters.cardBorderRadius,
                                        child: InkWell(
                                          borderRadius:
                                          UIParameters.cardBorderRadius,
                                          onTap: () {
                                            controller.commentPreview(documentSnapShot[
                                            'comment'], documentSnapShot[
                                            'rating'], documentSnapShot['userDisplayName']);
                                          },
                                          child: Ink(
                                            decoration: BoxDecoration(
                                                borderRadius: UIParameters.cardBorderRadius
                                            ),
                                            padding:
                                            const EdgeInsets.symmetric(
                                              vertical: 15,
                                              horizontal: 20,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.start,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                              RatingBar(rating: documentSnapShot[
                                                              'rating'].toDouble()),
                                                              Text(
                                                                documentSnapShot[
                                                                'created']
                                                                    .toDate()
                                                                    .toString()
                                                                    .substring(
                                                                    0, 16),
                                                                style: Theme.of(
                                                                    context)
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .merge(
                                                                  const TextStyle(
                                                                    fontSize:
                                                                    12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 5,),
                                                          Text(
                                                            documentSnapShot[
                                                            'userDisplayName'],
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            softWrap: false,
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .merge(
                                                              const TextStyle(
                                                                fontWeight:
                                                                FontWeight
                                                                    .bold,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            documentSnapShot[
                                                            'comment'],
                                                            maxLines: 3,
                                                            overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                            softWrap: false,
                                                            style: Theme.of(
                                                                context)
                                                                .textTheme
                                                                .titleMedium!
                                                                .merge(
                                                              TextStyle(
                                                                  color: Theme.of(context)
                                                                      .hintColor),
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
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.fourRotatingDots(
                    color: Theme.of(context).primaryColor,
                    size: 70,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text('MX Companion',
                    style: Theme.of(context).textTheme.titleLarge!.merge(
                      const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
