// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/sliceup_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/settlement_bottom_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/individual_card.dart';
import 'package:teddy_5618/features/group_screen/widgets/settlement_bottom.dart';
import 'package:teddy_5618/features/group_screen/widgets/sliceup_balance_card.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
// Ensure this import path is correct

class SliceupPageScreen extends StatelessWidget {
  final Trip? trip; // Add trip parameter
  final String? groupId; // Add groupId parameter

  const SliceupPageScreen({super.key, this.trip, this.groupId});

  @override
  Widget build(BuildContext context) {
    // Use either trip ID or direct groupId parameter
    final effectiveGroupId = groupId ?? trip?.id;

    // Create a unique controller tag based on the group ID to ensure data isolation
    final String controllerTag = effectiveGroupId ?? 'default';
    final controller = Get.put(GroupTripSpentController(), tag: controllerTag);

    // ✅ Initialize SliceUpController for this trip/group
    final sliceUpController = Get.put(
      SliceUpController(),
      tag: effectiveGroupId ?? 'default',
    );

    // Set the group ID if available
    if (effectiveGroupId != null && effectiveGroupId.isNotEmpty) {
      controller.setGroupId(effectiveGroupId);
      sliceUpController.setGroupId(
        effectiveGroupId,
      ); // ✅ Set group ID for slice-up data
      debugPrint(
        "🔍 [SLICEUP_PAGE] Group ID: $effectiveGroupId - Trip: ${trip?.name}",
      );
      debugPrint(
        "🔍 [SLICEUP_PAGE] SliceUpController initialized with group ID: $effectiveGroupId",
      );
    } else {
      debugPrint("❌ [SLICEUP_PAGE] No group ID available");
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLightGrey,
      // AppColors.backgroundLightGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 23),

            Obx(() {
              if (sliceUpController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (sliceUpController.error.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Error loading data',
                          style: getTextStyle2(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          sliceUpController.error.value,
                          style: getTextStyle2(fontSize: 12, color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Use real data from SliceUpController instead of hardcoded
              final individualEntries = sliceUpController
                  .getIndividualTransactions();

              if (individualEntries.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No settlements yet',
                          style: getTextStyle2(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Add some expenses to see settlements',
                          style: getTextStyle2(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return IndividualCard(entries: individualEntries);
            }),

            SizedBox(height: 24),

            // SlidingButtonIndivMin(controller: controller),
            Obx(() {
              final isIndividual = controller.isIndividualSelected.value;
              final isAllSettled = sliceUpController.isAllSettled.value;

              return GestureDetector(
                onTap: isAllSettled
                    ? null
                    : () async {
                        // Prepare the settlement controller outside of widget build
                        final settCtrl = Get.put(SettlementBottomController());
                        if (trip?.id != null && trip!.id!.isNotEmpty) {
                          await settCtrl.prepareForGroup(trip!.id!);
                        }

                        showMaterialModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                          ),
                          builder: (context) =>
                              SettlementBottom(groupId: trip?.id),
                        );
                      },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isAllSettled
                        ? AppColors.borderGrey
                        : (isIndividual
                              ? AppColors.green
                              : AppColors.borderGrey),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isAllSettled
                        ? 'Settled'.tr
                        : (isIndividual ? 'Settle up'.tr : 'Settled'.tr),
                    style: getTextStyle2(
                      color: isAllSettled
                          ? AppColors.textGrey
                          : (isIndividual
                                ? AppColors.black
                                : AppColors.textGrey),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 16),
            // Use real balance data instead of hardcoded
            Obx(() {
              final balanceEntries = sliceUpController.getBalanceEntries();

              if (balanceEntries.isEmpty &&
                  !sliceUpController.isLoading.value) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'No balance information available',
                      style: getTextStyle2(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              }

              return SliceupBalanceCard(entries: balanceEntries);
            }),

            SizedBox(height: 66),
          ],
        ),
      ),
    );
  }
}
