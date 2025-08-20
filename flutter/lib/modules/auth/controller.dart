import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  AuthController();

  _initData() {
    update(['auth']);
  }

  void onTap() {}

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  var l10n;

  @override
  void onReady() {
    super.onReady();
    _initData();
    l10n = AppLocalizations.of(Get.context!);
  }

  var isLogin = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  // 用户相关接口
  var apiAuth = ApiAuth();

  void toggleMode() {
    // 切换登录注册模式
    isLogin.value = !isLogin.value;

    // 清空输入框
    emailController.clear();
    passwordController.clear();
    usernameController.clear();

    // 清空表单错误提示
    formKey.currentState?.reset();
  }

  void submit() async {
    if (formKey.currentState!.validate()) {
      if (isLogin.value) {
        var result = await apiAuth.login({
          'username': usernameController.text,
          'password': passwordController.text,
        });
        if (result?.code == 200) {
          final prefs = await SharedPreferences.getInstance();
          prefs.setInt('userId', result?.data['id']);
          prefs.setString('username', result?.data['username']);
          prefs.setString('email', result?.data['email']);
          prefs.setString('token', result?.data['token']);

          Get.offNamed(AppRoutes.MAIN);
        }
      } else {
        var result = await apiAuth.register({
          'username': usernameController.text,
          'email': emailController.text,
          'password': passwordController.text,
        });

        if (result?.code == 200) {
          toggleMode();
        }
        Get.snackbar(
          l10n.titleTip,
          result?.message ?? l10n.registerFailed,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}
