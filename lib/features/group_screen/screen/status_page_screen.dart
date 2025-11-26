import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_status_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/individual_status_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/group_filter_screen_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/status_screen_controller.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';

class StatusPageScreen extends StatelessWidget {
  final Trip? trip; // Add trip parameter to get group ID

  const StatusPageScreen({super.key, this.trip});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupFilterScreenController());
    final statusController = Get.put(StatusScreenController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Debug: Print trip information
    debugPrint("🔍 [STATUS_PAGE] Trip provided: ${trip?.id} - ${trip?.name}");

    // Initialize status data when trip is available
    if (trip != null && trip!.id != null && trip!.id!.isNotEmpty) {
      debugPrint(
        "🚀 [STATUS_PAGE] Calling fetchGroupStatus with ID: ${trip!.id}",
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        statusController.fetchGroupStatus(trip!.id!);
      });
    } else {
      debugPrint(
        "⚠️ [STATUS_PAGE] No valid trip provided - trip: $trip, id: ${trip?.id}",
      );
      debugPrint("🚫 [STATUS_PAGE] Cannot load status without valid trip ID");
      // Don't use hardcoded group ID - show empty state instead
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLightGrey,
      //  AppColors.backgroundLightGrey,
      body: RefreshIndicator(
        onRefresh: () async {
          if (trip != null && trip!.id != null && trip!.id!.isNotEmpty) {
            await statusController.fetchGroupStatus(trip!.id!);
          }
        },
        child: Obx(() {
          return controller.showIndividual.value
              ? const IndividualStatusScreen()
              : const GroupStatusScreen();
        }),
      ),
    );
  }
}
