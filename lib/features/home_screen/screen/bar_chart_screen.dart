import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/home_screen/controller/filter_screen_controller.dart';
import 'package:teddy_5618/features/home_screen/widgets/monthly_bar_chart_screen.dart';
import 'package:teddy_5618/features/home_screen/widgets/sliding_button.dart'; // Import the SlidingButton

import 'package:teddy_5618/features/home_screen/widgets/yearly_bar_chart_screen.dart'; // Import Yearly screen

class BarChartScreen extends StatelessWidget {
  const BarChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      FilterScreenController(),
    ); // Initialize controller
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            CupertinoIcons.back,
            size: MediaQuery.of(context).size.height / 25,
          ),
        ),
        title: SlidingButton(controller: controller), // <--- MODIFIED HERE
        backgroundColor: isDark
            ? Color(0xFF262626)
            : AppColors.textWhite,
      ),

      body: Obx(() {
        // <--- WRAP BODY CONTENT WITH OBX
        if (controller.isMonthlySelected.value) {
          return const MonthlyBarChartScreen(); // Show Monthly screen
        } else {
          return const YearlyBarChartScreen(); // Show Yearly screen
        }
      }),
    );
  }
}
