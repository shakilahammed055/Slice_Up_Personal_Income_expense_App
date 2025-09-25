import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_status_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/individual_status_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/group_filter_screen_controller.dart'; 

class StatusPageScreen extends StatelessWidget {
  const StatusPageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(GroupFilterScreenController());
     final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
        isDark ? AppColors.backgroundDark : AppColors.backgroundLightGrey,
      //  AppColors.backgroundLightGrey,
      body: Obx(() {
        return controller.showIndividual.value
            ? const IndividualStatusScreen()
            : const GroupStatusScreen();
      }),
    );
  }
}
