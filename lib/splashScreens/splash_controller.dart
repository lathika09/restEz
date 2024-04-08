import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();

  RxBool animate = false.obs;
  bool hasShownSplash = false;

  Future startAnimation() async {
    if (animate.value) {
      return;
    }
    await Future.delayed(Duration(milliseconds: 100));
    animate.value=true;
    await Future.delayed(Duration(milliseconds: 3000));
    // Get.to(const WelcomePage());
    Get.offAndToNamed('welcome');
  }
}

