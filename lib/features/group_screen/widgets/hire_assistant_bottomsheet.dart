import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/group_screen/controller/hire_assistant_controller.dart';

class HireAssistantBottomsheet extends StatelessWidget {
  const HireAssistantBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HireAssistantController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      top: false,
      child: Container(
        height: size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AppBar Row
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.015,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: size.width * 0.08),
                  Text(
                    'Hire Assistant'.tr,
                    style: getTextStyle2(
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(
                      Icons.close,
                      size: size.width * 0.06,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.06,
                        vertical: size.height * 0.04,
                      ),
                      color: isDark
                          ? AppColors.backgroundDark
                          : Color(0xFFFCFCFD),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildPlanList(context, controller),
                          SizedBox(height: size.height * 0.03),
                          _buildPricingOptions(context, controller),
                        ],
                      ),
                    ),
                    _buildFreeOption(context, controller),
                    _buildHireButton(context, controller),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanList(
    BuildContext context,
    HireAssistantController controller,
  ) {
    final size = MediaQuery.of(context).size;

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanItem(
            context,
            emoji: '🤖',
            title: 'AI Assistant'.tr,
            subtitle: '(100 messages)',
            isSelected: controller.selectedPlan.value == 'ai_assistant',
            onTap: () => controller.selectPlan('ai_assistant'),
          ),
          Opacity(
            opacity: 0.20,
            child: _buildPlanItem(
              context,
              emoji: '🤖',
              title: 'AI Assistant Chatbot'.tr,
              isSelected: false,
              onTap: () => controller.showComingSoon(),
            ),
          ),
          Opacity(
            opacity: 0.20,
            child: _buildPlanItem(
              context,
              emoji: '🧠',
              title: 'Smart Budget Suggestions'.tr,
              isSelected: false,
              onTap: () => controller.showComingSoon(),
            ),
          ),
          _buildPlanItem(
            context,
            emoji: '🤝',
            title: 'Split Bills'.tr,
            subtitle: '(Up to 3 groups)'.tr,
            isSelected: controller.selectedPlan.value == 'split_bills',
            onTap: () => controller.selectPlan('split_bills'),
          ),
        ].withSpacing(size.height * 0.015),
      ),
    );
  }

  Widget _buildPlanItem(
    BuildContext context, {
    required String emoji,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: size.height * 0.015,
          horizontal: size.width * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? isDark
                    ? AppColors.deepGrey
                    : AppColors.lightGreyContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              emoji,
              style: getTextStyle2(
                fontSize: size.width * 0.05,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: size.width * 0.03),
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: title,
                      style: getTextStyle2(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      TextSpan(
                        text: ' $subtitle',
                        style: getTextStyle2(
                          color: Color(0xFFAAAAAA),
                          fontSize: size.width * 0.035,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: isDark ? AppColors.textWhite : AppColors.black,
                size: size.width * 0.06,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingOptions(
    BuildContext context,
    HireAssistantController controller,
  ) {
    final size = MediaQuery.of(context).size;
    return Obx(
      () => Column(
        children: [
          _buildPricingCard(
            context,
            icon: IconPath.chiwawa1,
            title: 'Monthly'.tr,
            price: '\$2',
            isSelected: controller.selectedPricing.value == 'monthly',
            onTap: () => controller.selectPricing('monthly'),
          ),
          _buildPricingCard(
            context,
            icon: IconPath.rabbit1,
            title: 'Yearly'.tr,
            price: '-22%  \$18',
            isSelected: controller.selectedPricing.value == 'yearly',
            onTap: () => controller.selectPricing('yearly'),
          ),
        ].withSpacing(size.height * 0.02),
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    String? icon,
    required String title,
    String? price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
        decoration: ShapeDecoration(
          color: isDark ? Color(0xFF38383A) : Color(0xFFEDEDF0),

          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: isSelected ? 2 : 0,
              color: isSelected
                  ? isDark
                        ? Color(0xFFEDEDF0)
                        : AppColors.backgroundDark
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                width: size.width * 0.15,
                height: size.width * 0.2,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(icon),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            if (icon != null) SizedBox(width: size.width * 0.03),
            Expanded(
              child: Text(
                title,
                style: getTextStyle2(
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (price != null)
              Text.rich(
                TextSpan(
                  children: [
                    if (price.contains('-22%'))
                      TextSpan(
                        text: '-22%',
                        style: getTextStyle2(
                          color: const Color(0xFFE21818),
                          fontSize: size.width * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    TextSpan(
                      text: price.contains('-22%') ? '  \$18' : price,
                      style: getTextStyle2(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeOption(
    BuildContext context,
    HireAssistantController controller,
  ) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.06,
        vertical: size.height * 0.02,
      ),
      child: GestureDetector(
        onTap: () => controller.selectPricing('free'),
        child: Obx(
          () => Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.06,
              vertical: size.height * 0.02,
            ),
            decoration: ShapeDecoration(
              color: controller.selectedPricing.value == 'free'
                  ? isDark
                        ? AppColors.deepGrey
                        : AppColors.lightGreyContainer
                  : isDark
                  ? AppColors.deepGrey
                  : AppColors.lightGreyContainer,
              //  const Color(0xFFEDEDF0),
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  width: controller.selectedPricing.value == 'free' ? 2 : 0,
                  color: controller.selectedPricing.value == 'free'
                      ? isDark
                            ? AppColors.textWhite
                            : AppColors.black
                      : Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: Text(
              'Free'.tr,
              textAlign: TextAlign.center,
              style: getTextStyle2(
                color: isDark ? AppColors.textWhite : AppColors.black,
                fontSize: size.width * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHireButton(
    BuildContext context,
    HireAssistantController controller,
  ) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.05,
        vertical: size.height * 0.02,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
        border: const Border(top: BorderSide(color: Color(0xFF38383A))),
      ),
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: controller.canHire.value ? controller.hireAssistant : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                decoration: ShapeDecoration(
                  color: controller.canHire.value
                      ? isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark
                      : AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  controller.isProcessing.value
                      ? 'Processing...'.tr
                      : 'Hire'.tr,
                  textAlign: TextAlign.center,
                  style: getTextStyle2(
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.textWhite,
                    fontSize: size.width * 0.045,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),
          // Container(
          //   width: size.width * 0.3,
          //   height: 4,
          //   decoration: ShapeDecoration(
          //     color: const Color(0xFF2B2F38),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(100),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

extension WidgetListExtension on List<Widget> {
  List<Widget> withSpacing(double spacing) {
    return asMap().entries
        .map(
          (entry) => [
            entry.value,
            if (entry.key < length - 1) SizedBox(height: spacing),
          ],
        )
        .expand((element) => element)
        .toList();
  }
}
