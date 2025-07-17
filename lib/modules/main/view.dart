import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';
import 'package:get/get.dart';

class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  // 主视图
  Widget _buildView() {
    return Center(
      child: PageView(
        controller: controller.pageController,
        onPageChanged: controller.setCurrentNavIndex,
        children: controller.mainPages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      init: MainController(),
      id: "main",
      builder: (_) {
        return Scaffold(
          extendBody: true,
          body: SafeArea(
            child: _buildView(),
          ),

          bottomNavigationBar: Obx(
                () {
              final l10n = AppLocalizations.of(context);
              return
                Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF622358),
                      border: Border(
                        top: BorderSide(
                            width: 2, color: Color(0xFF926C8E)), // 上边框
                        // left: BorderSide(width: 2, color: Color(0xFF926C8E)),   // 左边框
                        // right: BorderSide(width: 2, color: Color(0xFF926C8E)),  // 右边框
                        // 不设置 bottom 即无底部边框
                      ),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(35),
                          topLeft: Radius.circular(35)),
                    ),
                    child:
                    BottomNavigationBar(
                      backgroundColor: Colors.transparent,
                      fixedColor: Colors.white,
                      unselectedItemColor: Color(0xff9F7A9E),
                      currentIndex: controller.currentNavIndex.value,
                      type: BottomNavigationBarType.fixed,
                      onTap: (index) {
                        if (index == 2) {
                          return;
                        }
                        controller.setCurrentNavIndex(index);
                        controller.updatePageIndex(index);
                      },
                      items: [
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.home),
                          label: l10n.home,
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.insert_chart_outlined),
                          label: l10n.chart,
                        ),
                        BottomNavigationBarItem(
                          icon: SizedBox(height: 30.0, width: 80.0,),
                          activeIcon: SizedBox(height: 30.0, width: 80.0,),
                          label: "",
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.cell_tower),
                          label: l10n.device,
                        ),
                        BottomNavigationBarItem(
                          icon: const Icon(Icons.person),
                          label: l10n.profile,
                        ),
                      ],
                    )
                );
            },
          ),
          floatingActionButton: Transform.translate(
            offset: const Offset(0, 16), // y 正数向下移动，单位是像素
            child: SizedBox(
              width: 70,
              height: 70,
              child: FloatingActionButton(
                onPressed: _onAdd,
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                shape: const CircleBorder(side: BorderSide.none),
                child: Image.asset(
                  'assets/nav_button.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation
              .centerDocked,

        );
      },
    );
  }

  void _onAdd() {
    controller.setCurrentNavIndex(2);
    controller.updatePageIndex(2);
  }

}