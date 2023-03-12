import 'package:get/get.dart';
import 'package:mx_companion_v1/controllers/auth_controller.dart';
import 'package:mx_companion_v1/models/questions_model.dart';
import '../../firebase_ref/loading_status.dart';
import '../../firebase_ref/references.dart';
import '../../screens/questions_page/questions_page.dart';

class QuestionPaperController extends GetxController {
  final allPapers = <QuestionsModel>[].obs;
  final loadingStatus = LoadingStatus.loading.obs;
  final errorCode = ''.obs;

  @override
  void onReady() {
    getAllPapers();
    super.onReady();
  }

  Future<void> getAllPapers() async {
    loadingStatus.value = LoadingStatus.loading;
    try {
      questionPaperRF.snapshots().listen((value) {
        allPapers.assignAll(value.docs.map((paper) => QuestionsModel.fromSnapshot(paper)).toList());
        loadingStatus.value = LoadingStatus.completed;
      },
          onError: (e) {
            loadingStatus.value = LoadingStatus.error;
            print('error here : ${e.toString()}');
            if(e.code == 'permission-denied'){
              errorCode.value = 'denied';
            }
            else {
              errorCode.value = 'network';
            }
            return;
          }
      );
    } catch (e) {
      loadingStatus.value = LoadingStatus.error;
      return;
    }
  }

  void navigateToQuestions({required QuestionsModel paper, bool tryAgain = false}){
    AuthController _authController = Get.find();
    if(_authController.isLoggedIn()){
      if(tryAgain){
        Get.toNamed(QuestionsPage.routeName, arguments: paper, preventDuplicates:false, );
      } else {
        Get.toNamed(QuestionsPage.routeName, arguments: paper,);
      }
    } else {
      _authController.showLoginAlertDialog('To start practicing your selected course, you need to sign in. It will only take a while..');
    }
  }
}
