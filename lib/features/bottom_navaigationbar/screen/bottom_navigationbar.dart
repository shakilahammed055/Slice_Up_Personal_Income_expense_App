import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/controller/bottomnavbar_controller.dart';
import 'package:teddy_5618/features/chat_screen/screen/chat_screen.dart';

class BottomNavbarView extends StatelessWidget {
  BottomNavbarView({super.key});

  final BottomNavbarController controller = Get.put(BottomNavbarController());
  final List<Map<String, dynamic>> navItems = [
    {'icon': Icons.person, 'name': 'My'},
    {'icon': Icons.group, 'name': 'Group'},
    {'icon': Icons.settings, 'name': 'Settings'},
    {'icon': Icons.chat, 'name': 'Chat'}, // Chat is index 3
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      // If ChatScreen is active, show ONLY ChatScreen (no bottom bar)
      if (controller.isChatScreen) {
        return ChatScreen(); // Full-screen without Stack
      }

      // For other screens, show with bottom bar
      return Scaffold(
        backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
        body: Stack(
          children: [
            Positioned.fill(child: controller.getCurrentScreen()),
            Positioned(
              bottom: 30.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF262626) : AppColors.textWhite,
                    borderRadius: BorderRadius.circular(79),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: Offset(0, -1),
                      ),
                    ],
                  ),
                  child: GNav(
                    rippleColor: Color(0xffEDEDF0),
                    hoverColor: Colors.blue[100]!,
                    gap: 5,
                    activeColor: isDark
                        ? AppColors.textWhite
                        : AppColors.backgroundDark,
                    // Colors.black,
                    iconSize: 24.sp,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 12.h,
                    ),
                    duration: Duration(milliseconds: 300),
                    tabBackgroundColor: isDark
                        ? Color(0xFF38383A)
                        : Color(0xffEDEDF0),
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    tabs: navItems
                        .map(
                          (item) => GButton(
                            icon: item['icon'] as IconData,
                            text: item['name'],
                            onPressed: () =>
                                controller.changeTab(navItems.indexOf(item)),
                          ),
                        )
                        .toList(),
                    selectedIndex: controller.selectedIndex.value,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
