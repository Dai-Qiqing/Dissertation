import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AuthPage extends GetView<AuthController> {
  const AuthPage({super.key});

  // 主视图
  Widget _buildView(context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorValue.gradientStart,
            ColorValue.gradientCenter,
            ColorValue.gradientEnd,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Form(
            key: controller.formKey,
            child: Obx(
              () {
                final isLogin = controller.isLogin.value;
                final l10n = AppLocalizations.of(context);
                return Column(
                  children: [
                    Text(
                      l10n.appName,
                      style: TextStyle(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 60.h),
                    InputView(
                      controller: controller.usernameController,
                      label: l10n.username,
                      icon: Icons.person,
                      tip: l10n.usernameInputTip,
                    ),
                    SizedBox(height: 25.h),
                    if (!isLogin)
                      InputView(
                        controller: controller.emailController,
                        label: l10n.email,
                        icon: Icons.email,
                        tip: l10n.emailInputTip,
                        email: true,
                      ),
                    if (!isLogin) SizedBox(height: 25.h),
                    InputView(
                      controller: controller.passwordController,
                      obscureText: true,
                      label: l10n.password,
                      icon: Icons.lock,
                      tip: l10n.passwordInputTip,
                    ),
                    SizedBox(height: 25.h),
                    ElevatedButton(
                      onPressed: controller.submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFDABFDA),
                        minimumSize: Size(double.infinity, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        isLogin ? l10n.login : l10n.register,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                    TextButton(
                      onPressed: controller.toggleMode,
                      child: Text(
                        isLogin ? l10n.toRegister : l10n.toLogin,
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 11.sp,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(),
      id: 'auth',
      builder: (_) {
        return Scaffold(
          body: SafeArea(
            child: _buildView(context),
          ),
        );
      },
    );
  }
}
