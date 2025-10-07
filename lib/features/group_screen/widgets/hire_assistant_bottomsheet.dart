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
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header (fixed height = 56)
              Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Text(
                      'Hire Assistant'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
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

              // Content section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: isDark
                    ? AppColors.backgroundDark
                    : const Color(0xFFFCFCFD),
                child: Column(
                  children: [
                    _buildPlanList(context, controller),
                    SizedBox(height: size.height * 0.03),
                    _buildPricingOptions(context, controller),
                  ],
                ),
              ),

              // Sticky bottom hire button
              _buildHireButton(context, controller),
            ],
          ),
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
            opacity: controller.isPremiumPlan ? 1.0 : 0.20,
            child: _buildPlanItem(
              context,
              emoji: '🤖',
              title: 'AI Assistant Chatbot'.tr,
              isSelected:
                  controller.isPremiumPlan &&
                  controller.selectedPlan.value == 'ai_assistant_chatbot',
              onTap: () {
                if (controller.isPremiumPlan) {
                  controller.selectPlan('ai_assistant_chatbot');
                } else {
                  controller.showComingSoon();
                }
              },
            ),
          ),
          Opacity(
            opacity: controller.isPremiumPlan ? 1.0 : 0.20,
            child: _buildPlanItem(
              context,
              emoji: '🧠',
              title: 'Smart Budget Suggestions'.tr,
              isSelected:
                  controller.isPremiumPlan &&
                  controller.selectedPlan.value == 'smart_budget',
              onTap: () {
                if (controller.isPremiumPlan) {
                  controller.selectPlan('smart_budget');
                } else {
                  controller.showComingSoon();
                }
              },
            ),
          ),
          _buildPlanItem(
            context,
            emoji: '🤝',
            title: 'Split Bills'.tr,
            subtitle: '(Up to 2 groups)'.tr,
            isSelected: controller.selectedPlan.value == 'split_bills',
            onTap: () => controller.selectPlan('split_bills'),
          ),
        ].withSpacing(size.height * 0.015),
      ),
    );
  }

  // =================== PLAN ITEM ===================
  Widget _buildPlanItem(
    BuildContext context, {
    required String emoji,
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          height: 20,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              Text(
                emoji,
                style: getTextStyle2(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: subtitle,
                          style: getTextStyle2(
                            color: const Color(0xFFAAAAAA),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Tick mark icon - always show
              Icon(
                Icons.check,
                color: isDark ? AppColors.textWhite : AppColors.black,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =================== PRICING OPTIONS ===================
  Widget _buildPricingOptions(
    BuildContext context,
    HireAssistantController controller,
  ) {
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
          _buildPricingCard(
            context,
            title: 'Free Plan'.tr,
            isSelected: controller.selectedPricing.value == 'free',
            onTap: () => controller.selectPricing('free'),
          ),
        ],
      ),
    );
  }

  // =================== PRICING CARD ===================
  Widget _buildPricingCard(
    BuildContext context, {
    String? icon,
    required String title,
    String? price,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasDiscount = (price ?? '').contains('-22%');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 68,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF38383A) : const Color(0xFFEDEDF0),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(icon),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: getTextStyle2(
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (price != null)
              hasDiscount
                  ? Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '-22%',
                            style: getTextStyle2(
                              color: const Color(0xFFE21818),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(
                            text: '  \$18',
                            style: getTextStyle2(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Text(
                      price,
                      style: getTextStyle2(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildHireButton(
    BuildContext context,
    HireAssistantController controller,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
        border: const Border(top: BorderSide(color: Color(0xFFEDEDF0))),
      ),
      child: Obx(
        () => GestureDetector(
          onTap: controller.canHire.value ? controller.hireAssistant : null,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: controller.canHire.value
                  ? (isDark
                        ? AppColors.textWhite
                        : Colors
                              .black) // dark mode: white bg, light mode: black bg
                  : Colors.grey[400],
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Text(
              controller.isProcessing.value ? 'Processing...'.tr : 'Hire'.tr,
              style: getTextStyle2(
                color: isDark ? Colors.black : Colors.white, // flip text color
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
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
