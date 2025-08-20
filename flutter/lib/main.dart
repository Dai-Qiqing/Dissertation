import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'GlobalDataController.dart';
import 'index.dart';

void main() {

  // 在整个 App 里都能用 Get.find<GlobalDataController>()
  Get.put(GlobalDataController());

  runApp(
    ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 设计图大小
      builder: (context, child) {
        return GetMaterialApp(
          theme: ThemeData(
            appBarTheme: const AppBarTheme(
              color: Color(0xFF120426),
            ),
            scaffoldBackgroundColor: ColorValue.primary,
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          initialBinding: MainBinding(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh'),
          ],
        );
      },
    ),
  );
}
