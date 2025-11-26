// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/settlement_bottom_controller.dart';
// ...existing imports...

class SettlementBottom extends StatelessWidget {
  final String? groupId;
  final String controllerTag;

  const SettlementBottom({
    super.key,
    this.groupId,
    this.controllerTag = 'groupTripSpent',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(SettlementBottomController());
    // Ensure controller is prepared for this group (fetches data directly)
    if (groupId != null && groupId!.isNotEmpty && controller.prepared.isFalse) {
      // run async prepare without blocking build
      Future.microtask(() => controller.prepareForGroup(groupId!));
    }

    // controller.sliceUpController is prepared before opening this widget

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Title row with Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Text(
                  'Settlement'.tr,
                  style: getTextStyle2(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _sectionHeader('To pay'.tr, context),

            // Make the settlement list refreshable via pull-to-refresh.
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Re-fetch settlements for the current group and re-init selections
                  await controller.fetchSliceUpDirect(groupId ?? '');
                  final settlements = controller.activeSettlements
                      .where((s) => s['isHistorical'] == false)
                      .toList();
                  controller.initGroupOne(settlements.length);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Dynamic To Pay list (from settlements)
                      Obx(() {
                        // Use only active (non-historical) settlements fetched directly
                        final settlements = controller.activeSettlements
                            .where((s) => s['isHistorical'] == false)
                            .toList();
                        if (settlements.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'No items to pay'.tr,
                              style: getTextStyle2(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: List.generate(settlements.length, (index) {
                            final item = settlements[index];
                            final from = (item['from'] ?? '').toString();
                            final to = (item['to'] ?? '').toString();
                            final amount = item['amount'] ?? 0;
                            final fromName = (item['fromName'] ?? '')
                                .toString();
                            final toName = (item['toName'] ?? '').toString();

                            String _shortName(
                              String rawName,
                              String email, [
                              int len = 12,
                            ]) {
                              final name = (rawName.isNotEmpty)
                                  ? rawName
                                  : (email.split('@').first);
                              if (name.length <= len) return name;
                              return '${name.substring(0, len)}...';
                            }

                            final title =
                                '${_shortName(fromName, from)} to ${_shortName(toName, to)} ${_formatAmount(amount)}';

                            return Obx(
                              () => GestureDetector(
                                onTap: () => controller.toggleGroupOne(index),
                                child: _buildSingleRow(
                                  context: context,
                                  title: title,
                                  showCheck:
                                      controller.groupOneSelected.length > index
                                      ? controller.groupOneSelected[index]
                                      : false,
                                ),
                              ),
                            );
                          }),
                        );
                      }),

                      // Keep the To Collect block commented out for now (preserved)
                      // _sectionHeader('To Collect'.tr, context),
                      // ...
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // "To Collect" section is currently disabled.
            // _sectionHeader('To Collect'.tr, context),
            //
            // // Dynamic To Collect list (based on positive balances)
            // Obx(() {
            //   // Use balances fetched directly from API
            //   final balances = controller.balances.toList();
            //   final toCollect = balances
            //       .where((b) => (b['netBalance'] ?? 0) > 0)
            //       .toList();
            //   if (toCollect.isEmpty) {
            //     return Padding(
            //       padding: const EdgeInsets.all(12.0),
            //       child: Text(
            //         'No items to collect'.tr,
            //         style: getTextStyle2(fontSize: 14, color: Colors.grey),
            //       ),
            //     );
            //   }
            //
            //   return Column(
            //     children: List.generate(toCollect.length, (index) {
            //       final entry = toCollect[index];
            //       final memberName = (entry['memberName'] ?? '').toString();
            //       final net = entry['netBalance'] ?? 0;
            //       final title =
            //           '${memberName.isNotEmpty ? memberName : (entry['memberEmail'] ?? '')} ${_formatAmount(net)}';
            //       return Obx(
            //         () => GestureDetector(
            //           onTap: () => controller.toggleGroupTwo(index),
            //           child: _buildSingleRow(
            //             context: context,
            //             title: title,
            //             showCheck: controller.groupTwoSelected.length > index
            //                 ? controller.groupTwoSelected[index]
            //                 : false,
            //           ),
            //         ),
            //       );
            //     }),
            //   );
            // }),
            const SizedBox(height: 40),
            const Spacer(),
            const Divider(),

            Obx(() {
              final isProcessing = controller.isProcessing.value;
              return GestureDetector(
                onTap: isProcessing
                    ? null
                    : () async {
                        // Build settlements payload from selected items in groupOne
                        final settlements = <Map<String, dynamic>>[];
                        final rawSettlements = controller.activeSettlements
                            .where((s) => s['isHistorical'] == false)
                            .toList();
                        for (
                          var i = 0;
                          i < controller.groupOneSelected.length;
                          i++
                        ) {
                          if (controller.groupOneSelected[i] &&
                              i < rawSettlements.length) {
                            final s = rawSettlements[i];
                            settlements.add({
                              'fromEmail': s['from'] ?? '',
                              'toEmail': s['to'] ?? '',
                              'amount': s['amount'] ?? 0,
                            });
                          }
                        }

                        final success = await controller.submitSettlements(
                          groupId ?? '',
                          settlements,
                        );
                        if (success) {
                          // After a successful settlement, update the UI on the parent
                          // Sliceup page by setting the GroupTripSpentController flag
                          try {
                            if (groupId != null && groupId!.isNotEmpty) {
                              final tripCtrl =
                                  Get.find<GroupTripSpentController>(
                                    tag: controllerTag,
                                  );
                              tripCtrl.isIndividualSelected.value =
                                  false; // show 'Settled'
                            }
                          } catch (e) {
                            // ignore if controller not found
                          }

                          Get.back();
                        } else {
                          final msg = controller.apiError.value.isNotEmpty
                              ? controller.apiError.value
                              : 'Failed to submit settlements';
                          Get.snackbar('Error', msg);
                        }
                      },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isProcessing ? Colors.grey : AppColors.green,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: isProcessing
                      ? CircularProgressIndicator()
                      : Text(
                          'Select'.tr,
                          style: getTextStyle2(
                            color: AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleRow({
    required BuildContext context,
    required String title,
    required bool showCheck,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 55,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: getTextStyle2(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.black,
              ),
            ),
          ),
          // ✅ Custom checkbox
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: showCheck ? Colors.black : Colors.transparent,
              border: Border.all(color: AppColors.borderGrey, width: 2.0),
            ),
            child: Icon(
              Icons.done,
              size: 15,
              color: showCheck ? Colors.white : Colors.transparent,
              shadows: const [Shadow(blurRadius: 20, color: Colors.white)],
            ),
          ),
        ],
      ).marginSymmetric(horizontal: 8),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Container(
        height: 50,
        width: double.infinity,
        color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: getTextStyle2(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ).marginOnly(left: 15),
      ),
    );
  }

  String _formatAmount(dynamic amount) {
    try {
      double v = 0;
      if (amount is num) v = amount.toDouble();
      if (amount is String) v = double.tryParse(amount) ?? 0.0;
      if ((v % 1) == 0) return 'US\$ ${v.toInt()}';
      return 'US\$ ${v.toStringAsFixed(2)}';
    } catch (e) {
      return 'US\$ 0';
    }
  }
}
