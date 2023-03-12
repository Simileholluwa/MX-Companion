import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mx_companion_v1/controllers/zoom_drawer.dart';
import '../../controllers/ad_helper.dart';
import '../../widgets/alert_bottom_sheet.dart';
import '../../widgets/content_area.dart';
import '../../widgets/icon_and_text.dart';
import '../../widgets/text_field.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  static const String routeName = "/menu";

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NativeAd? _nativeAd;

  void loadNativeAd() {
    NativeAd(
      adUnitId: AdHelper.nativeAdUnitId,
      factoryId: 'listTile2',
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

  late TextEditingController phoneNumberController,
      departmentController,
      userNameController;

  var userName = '';
  var phoneNumber = '';
  var department = '';

  @override
  void initState() {
    super.initState();
    loadNativeAd();
    userNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    departmentController = TextEditingController();
  }

  @override
  void dispose() {
    userNameController.dispose();
    phoneNumberController.dispose();
    departmentController.dispose();
    _nativeAd?.dispose();
    super.dispose();
  }

  final RxBool _isLoading = false.obs;

  @override
  Widget build(BuildContext context) {

    MyZoomDrawerController controller = Get.find();

    void showUpdateUserDetails(CollectionReference userDetails,) async {
        await Sheet.updateDetailsDialog(
          title: 'Update Details',
          content: StreamBuilder(
            stream: userDetails.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                departmentController.text =
                streamSnapshot.data!.docs[0]['department'];
                userNameController.text =
                streamSnapshot.data!.docs[0]['userName'];
                phoneNumberController.text =
                streamSnapshot.data!.docs[0]['phoneNumber'];
                return Container(
                  padding: EdgeInsets.only(
                    top: 10.0,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                    left: 20,
                    right: 20,
                  ),
                  child: Obx(() =>
                      Form(
                    key: _formKey,
                    child: Wrap(
                      //spacing: 20,
                      runSpacing: 25,
                      children: [
                        CustomTextField(
                          onSaved: (value) {
                            department = value!;
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Department field is required';
                            } else {
                              return null;
                            }
                          },
                          hintText: 'Department',
                          prefixIcon: Icons.school,
                          textInputType: TextInputType.text,
                          controller: departmentController,
                          filled: false,
                          labelText: 'Department',
                        ),
                        CustomTextField(
                          labelText: 'Phone number',
                          filled: false,
                          onSaved: (value) {
                            phoneNumber = value!;
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Phone number field is required';
                            } else if (value.length != 11) {
                              return 'Phone number must be 11 digits long';
                            } else {
                              return null;
                            }
                          },
                          inputFormatter: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          hintText: 'Phone number',
                          prefixIcon: Icons.phone_android_rounded,
                          textInputType: TextInputType.phone,
                          controller: phoneNumberController,
                        ),
                        CustomTextField(
                          filled: false,
                          labelText: 'Username',
                          onSaved: (value) {
                            userName = value!;
                          },
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'Username field is required';
                            } else if (value.length > 15) {
                              return 'Username should be at most 15 characters';
                            } else {
                              return null;
                            }
                          },
                          hintText: 'Username',
                          prefixIcon: Icons.person,
                          textInputType: TextInputType.text,
                          controller: userNameController,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                                onPressed: () => Get.back(),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            const SizedBox(
                              width: 1,
                              child: Divider(
                                thickness: 20,
                                height: 50,
                              ),
                            ),
                            const SizedBox(
                              width: 30,
                            ),
                            TextButton(
                              onPressed: () async {
                                var userName = userNameController.text
                                    .trim()
                                    .capitalizeFirst;
                                var department = departmentController.text
                                    .trim()
                                    .capitalizeFirst;
                                var phoneNumber =
                                phoneNumberController.text.trim();
                                final isValid =
                                _formKey.currentState!.validate();
                                if (!isValid) {
                                  return;
                                } else {
                                  _formKey.currentState!.save();
                                  _isLoading.value = true;
                                  await userDetails
                                      .doc(streamSnapshot.data!.docs[0].id)
                                      .update({
                                    'userName': userName,
                                    'department': department,
                                    'phoneNumber': phoneNumber,
                                  });
                                  await FirebaseAuth.instance.currentUser!
                                      .updateDisplayName(userName);
                                  _isLoading.value = false;
                                  Get.back();
                                  controller.showSnackBar('Your profile has been updated.',);
                                }
                              },
                              child: _isLoading.isFalse
                                  ? const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                                  : LoadingAnimationWidget.prograssiveDots(
                                color: Theme.of(context).primaryColor,
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),),
                );
              }
              return Container(
                padding: EdgeInsets.only(
                  top: 20.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 20,
                  right: 20,
                ),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    Center(
                      child: LoadingAnimationWidget.fourRotatingDots(
                        color: Theme.of(context).primaryColor,
                        size: 60,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
    }


    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(
          top: 15,
          bottom: 5,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: ContentAreaCustom(
                  addPadding: false,
                  addRadius: true,
                  child: Column(
                    children: [
                      GetBuilder<MyZoomDrawerController>(
                        builder: (_) {
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.only(
                                top: 15,
                                bottom: 10,
                              ),
                              height: 120,
                              width: 120,
                              child: controller.photo != null
                                  ? CircleAvatar(
                                      radius: 55,
                                      child: ClipOval(
                                        child: SizedBox(
                                          height: 110,
                                          width: 110,
                                          child: Image.file(
                                            controller.photo!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    )
                                  : CircleAvatar(
                                      radius: 55,
                                      child: ClipOval(
                                        child: SizedBox(
                                          height: 110,
                                          width: 110,
                                          child: Image.network(
                                            controller.user.value?.photoURL ?? "",
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Center(
                                                child: LoadingAnimationWidget
                                                    .fourRotatingDots(
                                                        color: Theme.of(context).primaryColor,
                                                        size: 50),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                decoration:
                                                    const BoxDecoration(
                                                  image: DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/man.png"),
                                                  ),
                                                ),
                                              );
                                            },
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          controller.user.value != null
                              ? IconButton(
                                  onPressed: () async {
                                    final CollectionReference userDetails =
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(controller.user.value!.uid)
                                            .collection('user_details');
                                    showUpdateUserDetails(
                                      userDetails,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 30,
                                  ),
                                )
                              : Container(),
                          controller.user.value != null
                              ? IconButton(
                                  onPressed: () async {
                                    controller.imgFromGallery();
                                  },
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 30,
                                  ),
                                )
                              : Container(),
                          IconButton(
                            onPressed: () {
                              controller.user.value == null
                                  ? controller.signIn()
                                  : controller.signOut();
                            },
                            icon: Icon(
                              controller.user.value == null
                                  ? Icons.login
                                  : Icons.logout,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        height: 5,
                        thickness: 3,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                            child: Column(
                              children: [
                                controller.user.value == null
                                    ? Container()
                                    : IconAndText(
                                  onTap: () {
                                    controller.history();
                                  },
                                  text: 'Practice History',
                                  image:
                                  const AssetImage("assets/images/bomb.png"),
                                ),
                                IconAndText(
                                  onTap: () {
                                    controller.faq();
                                  },
                                  text: 'FAQs',
                                  image:
                                  const AssetImage("assets/images/questions.png"),
                                ),
                                _nativeAd != null ?
                                Container(
                                  height: 80.0,
                                  alignment: Alignment.center,
                                  child: AdWidget(ad: _nativeAd!),
                                ): Container(),
                                IconAndText(
                                  onTap: () {
                                    controller.feedback();
                                  },
                                  text: 'Feedback',
                                  image: const AssetImage(
                                      "assets/images/testimonials.png"),
                                ),
                                IconAndText(
                                  onTap: () {
                                    controller.showJoinSocial();
                                  },
                                  text: 'Social Groups',
                                  image:
                                  const AssetImage("assets/images/connection.png"),
                                ),
                                controller.user.value == null ?
                                Container() :
                                IconAndText(
                                  onTap: () {
                                    controller.notifications();
                                  },
                                  text: 'Notifications',
                                  image:
                                  const AssetImage("assets/images/newsletter.png"),
                                ),
                                IconAndText(
                                  onTap: () async {
                                    controller.shareApp(context);
                                  },
                                  text: 'Share App',
                                  image: const AssetImage("assets/images/share.png"),
                                ),
                                IconAndText(
                                  onTap: () {
                                    controller.website();
                                  },
                                  text: 'About Us',
                                  image: const AssetImage("assets/images/comment.png"),
                                ),
                              ],
                            ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 5,
                thickness: 3,
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0, bottom: 3),
                child: Center(
                  child: Text('Contact Us'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      controller.openEmail();
                    },
                    icon: const Icon(
                      Icons.mail,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.openTelegram();
                    },
                    icon: const Icon(
                      Icons.telegram,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.openWhatsapp();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.whatsapp,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.openFacebook();
                    },
                    icon: const Icon(
                      Icons.facebook,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
