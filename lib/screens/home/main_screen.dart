import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import 'package:mx_companion_v1/controllers/zoom_drawer.dart';
import 'package:mx_companion_v1/screens/home/question_card.dart';
import '../../controllers/ad_helper.dart';
import '../../controllers/question_paper/question_paper_controller.dart';
import '../../firebase_ref/loading_status.dart';
import '../../widgets/AppIconText.dart';
import '../../widgets/content_area.dart';
import '../../widgets/text_button_with_icon.dart';
import '../search/search_delegate.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  static const String routeName = "/mainScreen";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  AuthController auth = Get.find();
  MyZoomDrawerController controller = Get.find();

  static const _kAdIndex = 5;

  BannerAd? _ad;
  NativeAd? _nativeAd;
  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _nativeAd != null) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  @override
  void initState() {
    super.initState();
    loadBannerAd();
    loadNativeAd();
  }

  @override
  void dispose() {
    _ad?.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  void loadBannerAd() {
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    ).load();
  }

  void loadNativeAd() {
    NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile',
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _nativeAd = ad as NativeAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          if (kDebugMode) {
            print(
                'Ad load failed (code=${error.code} message=${error.message})');
          }
        },
      ),
    ).load();
  }

  @override
  Widget build(BuildContext context) {
    DateTime _lastExitTime = DateTime.now();
    QuestionPaperController questionPaperController = Get.find();
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
            auth.showSnackBar(
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
            toolbarHeight: 0,
            scrolledUnderElevation: 0,
          ),
          body: SafeArea(
            child: Obx(
              () => Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.toggleZoomDrawer();
                              },
                              icon: const Icon(
                                Icons.apps,
                                size: 30,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showSearch(
                                    context: context,
                                    delegate: CustomSearchDelegate()
                                );
                              },
                              icon: const Icon(
                                Icons.search,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 30.0,
                          bottom: 20,
                        ),
                        child: AppIconText(
                          icon: const Icon(
                            Icons.waving_hand,
                            color: Colors.orange,
                            size: 15,
                          ),
                          text: Text(
                            controller.user.value == null
                                ? 'Hello there'
                                : 'Hello ${controller.user.value!.displayName}',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 30.0,
                          right: 20,
                        ),
                        child: Text(
                          'What would you like to practice?',
                          style: Theme.of(context).textTheme.titleLarge!.merge(
                                const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 30, bottom: 25),
                        child: Text('swipe left on each course card for more options',
                          style: TextStyle(
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (questionPaperController.loadingStatus.value ==
                      LoadingStatus.loading)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: ContentAreaCustom(
                          addRadius: true,
                          addColor: true,
                          child: SizedBox(
                            height: double.maxFinite,
                            width: double.maxFinite,
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
                                Text(
                                  'MX Companion',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge!
                                      .merge(
                                        const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 40,
                                        ),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (questionPaperController.loadingStatus.value ==
                      LoadingStatus.completed)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: ContentAreaCustom(
                          addRadius: true,
                          addColor: true,
                          addPadding: false,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                Obx(
                                  () => ListView.separated(
                                    physics: const BouncingScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: questionPaperController
                                            .allPapers.length +
                                        (_nativeAd != null ? 1 : 0),
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider(
                                        height: 5,
                                        thickness: 3,
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                      );
                                    },
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      if (_nativeAd != null &&
                                          index == _kAdIndex) {
                                        return Container(
                                          height: 100.0,
                                          alignment: Alignment.center,
                                          child: AdWidget(ad: _nativeAd!),
                                        );
                                      } else {
                                        return Center(
                                          child: QuestionsCard(
                                            model: questionPaperController
                                                    .allPapers[
                                                _getDestinationItemIndex(
                                                    index)],
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (questionPaperController.loadingStatus.value == LoadingStatus.error)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 10,
                        ),
                        child: ContentAreaCustom(
                          addRadius: true,
                          addColor: true,
                          child: SizedBox(
                            height: double.maxFinite,
                            width: double.maxFinite,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  questionPaperController.errorCode.value == 'denied' ? Icons.waving_hand : Icons.wifi_off_sharp,
                                size: 150,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  questionPaperController.errorCode.value == 'denied' ? 'Hi there! Kindly log in to access available courses' : 'Ensure you have an active internet.',
                                  textAlign: TextAlign.center,
                                ),
                                TextButtonWithIcon(
                                  onTap: () {
                                    questionPaperController.errorCode.value == 'denied' ? auth.navigateToLogin() : questionPaperController.getAllPapers();
                                  },
                                  icon: questionPaperController.errorCode.value == 'denied' ? Icons.login : Icons.refresh_sharp,
                                  text: questionPaperController.errorCode.value == 'denied' ? 'Login' : 'Refresh',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 5,
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
