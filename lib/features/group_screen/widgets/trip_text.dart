import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart';

class TripText extends StatelessWidget {
  final TripTextType? type;
  final String? groupId; // ✅ Add optional group ID parameter

  const TripText({super.key, this.type, this.groupId});

  @override
  Widget build(BuildContext context) {
    // Use Get.find() if the controller already exists, otherwise Get.put()
    final controller = Get.isRegistered<TripTextController>()
        ? Get.find<TripTextController>()
        : Get.put(TripTextController());

    // Set the type when widget is built
    if (type != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.setTripTextType(type!);
      });
    }

    // ✅ Set group ID if provided
    if (groupId != null && groupId!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('🎯 [TRIP_TEXT] Setting group ID from widget: $groupId');
        controller.setGroupId(groupId!);
      });
    }

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: controller.primaryText,
                  style: getTextStyle2(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF828282),
                  ),
                ),
                if (controller.primaryAmount.isNotEmpty)
                  TextSpan(
                    text: controller.primaryAmount,
                    style: getTextStyle2(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _getPrimaryAmountColor(
                        controller.currentType.value,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Only show secondary text if not status screen
          if (controller.shouldShowSecondaryText) ...[
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: controller.secondaryText,
                    style: getTextStyle2(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF828282),
                    ),
                  ),
                  TextSpan(
                    text: controller.secondaryAmount,
                    style: getTextStyle2(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _getSecondaryAmountColor(
                        controller.currentType.value,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getPrimaryAmountColor(TripTextType type) {
    switch (type) {
      case TripTextType.expenses:
        return Color(0xFFEF5C00); // Orange for expenses (you'll pay)
      case TripTextType.sliceup:
        return Color(0xFFEF5C00); // Blue for total expenses
      case TripTextType.status:
        return Color(0xFF828282); // Green for settled amount
    }
  }

  Color _getSecondaryAmountColor(TripTextType type) {
    switch (type) {
      case TripTextType.expenses:
        return Color(0xFF00D460); // Green for collect amount
      case TripTextType.sliceup:
        return Color(0xFF00D460); // Orange for your share
      case TripTextType.status:
        return Color(0xFFEF5C00); // Orange for pending amount
    }
  }
}
