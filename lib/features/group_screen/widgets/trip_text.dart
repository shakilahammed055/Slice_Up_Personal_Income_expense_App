import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart';

class TripText extends StatelessWidget {
  final TripTextType? type;
  final String? groupId; // ✅ Add optional group ID parameter
  final bool enableRefresh;

  const TripText({
    super.key,
    this.type,
    this.groupId,
    this.enableRefresh = false,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Use unique tag per group to avoid data mixing between trips
    final String tag = groupId ?? 'default';

    // Use Get.find() if the controller already exists for this group, otherwise Get.put()
    final controller = Get.isRegistered<TripTextController>(tag: tag)
        ? Get.find<TripTextController>(tag: tag)
        : Get.put(TripTextController(), tag: tag);

    // Defer any controller state changes to after the current frame so we
    // don't mutate reactive state during the widget build phase. Mutating
    // Rx values while building causes the Flutter error seen in logs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (type != null && controller.currentType.value != type) {
          controller.setTripTextType(type!);
        }

        if (groupId != null &&
            groupId!.isNotEmpty &&
            controller.currentGroupId.value != groupId) {
          // debugPrint(
          //   '🎯 [TRIP_TEXT] Setting group ID from widget (deferred): $groupId',
          // );
          controller.setGroupId(groupId!);
          // Refresh after setting group id (deferred)
          controller.refreshCurrentData();
        }
      } catch (e) {
        // debugPrint('⚠️ [TRIP_TEXT] Deferred state update failed: $e');
      }
    });

    Widget obxContent = Obx(() {
      // ✅ Observe reactive values from controller to trigger rebuilds on any change
      // These lines ensure the Obx widget rebuilds when any observable changes
      controller.sliceupIsAllSettled.value; // Observe settlement status
      controller.currentType.value; // Observe type changes
      controller.isLoading.value; // Observe loading state
      controller.summaryData; // Observe summary data changes

      // TripText rebuild (debug prints removed)

      // ✅ Add loading state indicator
      if (controller.isLoading.value) {
        return SizedBox(
          height: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 16,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              if (controller.shouldShowSecondaryText)
                Container(
                  height: 16,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        );
      }

      // Determine numeric values for youllPay and youllCollect. If both are
      // zero, hide the TripText entirely (return an empty widget).
      double parseAmountString(String s) {
        try {
          // remove non-numeric characters except dot and minus
          final cleaned = s.replaceAll(RegExp(r"[^0-9.\-]"), '');
          return double.tryParse(cleaned) ?? 0.0;
        } catch (_) {
          return 0.0;
        }
      }

      double youllPayVal = 0.0;
      double youllCollectVal = 0.0;

      // Prefer structured summary data when available
      try {
        final sd = controller.summaryData;
        if (sd.containsKey('youllPay')) {
          final yp = sd['youllPay'];
          if (yp is Map && yp['amount'] != null) {
            youllPayVal = (yp['amount'] is num)
                ? yp['amount'].toDouble()
                : double.tryParse(yp['amount'].toString()) ?? 0.0;
          }
        }
        if (sd.containsKey('youllCollect')) {
          final yc = sd['youllCollect'];
          if (yc is Map && yc['amount'] != null) {
            youllCollectVal = (yc['amount'] is num)
                ? yc['amount'].toDouble()
                : double.tryParse(yc['amount'].toString()) ?? 0.0;
          }
        }
      } catch (_) {}

      // Fallback to parsing formatted strings
      if (youllPayVal == 0.0) {
        youllPayVal = parseAmountString(controller.primaryAmount);
      }
      if (youllCollectVal == 0.0) {
        youllCollectVal = parseAmountString(controller.secondaryAmount);
      }

      // Check if we should hide the TripText.
      // NEW LOGIC: Do NOT use totalExpenses as a gate anymore.
      // If we have any non-zero pay/collect amount or a non-empty label,
      // we show the widget.
      final primaryText = controller.primaryText;

      final bool hasAnyAmount =
          youllPayVal > 0 ||
          youllCollectVal > 0 ||
          controller.primaryAmount.isNotEmpty ||
          controller.secondaryAmount.isNotEmpty;
      final bool hasAnyText =
          primaryText.isNotEmpty || controller.secondaryText.isNotEmpty;

      if (!hasAnyAmount && !hasAnyText) {
        return const SizedBox.shrink();
      }

      // Build primary text widget. Don't rely on trailing spaces in the
      // controller text — control spacing here so all screens render the
      // same single space between label and amount.
      final String primaryLabelText = controller.primaryText;

      // Decide amount colors: for status screen we want to match the
      // pay/collect color scheme when not yet settled, but keep the
      // settled message color when fully settled.
      final bool statusNotSettled =
          controller.currentType.value == TripTextType.status &&
          !controller.sliceupIsAllSettled.value;

      // Build list of widgets to show based on amount values
      final List<Widget> textWidgets = [];

      // ✅ IMPORTANT: When all settled, show the "All sliced up and settled!" message
      // whenever sliceupIsAllSettled is true and primaryText contains that message.
      final bool shouldShowSettledMessage = primaryText.contains(
        'All sliced up and settled',
      );

      // Show primary text (You'll pay) only if youllPayVal > 0
      // OR if we're showing the settled message
      if (youllPayVal > 0 || shouldShowSettledMessage) {
        Widget primaryWidget = Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: primaryLabelText,
                style: getTextStyle2(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF828282),
                ),
              ),
              // Only show amount if NOT the settled message
              if (controller.primaryAmount.isNotEmpty &&
                  !shouldShowSettledMessage)
                TextSpan(
                  // Ensure exactly one space between label and amount regardless
                  // of whether controller.primaryText included a trailing space.
                  text: controller.primaryAmount.startsWith(' ')
                      ? controller.primaryAmount
                      : ' ${controller.primaryAmount}',
                  style: getTextStyle2(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: statusNotSettled
                        ? // Use "you'll pay" color when status isn't settled
                          Color(0xFFEF5C00)
                        : _getPrimaryAmountColor(controller.currentType.value),
                  ),
                ),
            ],
          ),
        );
        textWidgets.add(primaryWidget);
      }

      // Show secondary text (You'll collect) only if controller says to show it
      if (controller.secondaryText.isNotEmpty) {
        if (textWidgets.isNotEmpty) {
          textWidgets.add(const SizedBox(height: 2));
        }
        Widget secondaryWidget = Text.rich(
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
                  color:
                      (controller.currentType.value == TripTextType.status &&
                          !controller.sliceupIsAllSettled.value)
                      ? // Use "you'll collect" color when status isn't settled
                        Color(0xFF00D460)
                      : _getSecondaryAmountColor(controller.currentType.value),
                ),
              ),
            ],
          ),
        );
        textWidgets.add(secondaryWidget);
      }

      // If no widgets to show, return empty widget
      if (textWidgets.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: textWidgets,
      );
    });

    if (enableRefresh) {
      return RefreshIndicator(
        onRefresh: () async {
          try {
            controller.refreshCurrentData();
          } catch (_) {}
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(padding: EdgeInsets.zero, child: obxContent),
        ),
      );
    }

    return obxContent;
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
