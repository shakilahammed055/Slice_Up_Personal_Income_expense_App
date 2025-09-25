import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void showCurrencyDialog(BuildContext context, SettingController controller) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Define currency list with symbol and name
  final currencies = [
    {'symbol': 'S\$', 'name': 'Singapore dollar'},
    {'symbol': 'US\$', 'name': 'United States dollar'},
    {'symbol': '€', 'name': 'Euro'},
    {'symbol': '£', 'name': 'British pound'},
    {'symbol': 'AU\$', 'name': 'Australian dollar'},
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 184,
          maxHeight: screenHeight * 0.40,
        ),
        child: Container(
          width: screenWidth,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth,
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 48), // Placeholder for alignment
                    Expanded(
                      child: Text(
                        'Currency',
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24),
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: isDark ? Color(0xFF262626) : Color(0xFFFCFCFD),
                  child: ListView.builder(
                    itemCount: currencies.length,
                    itemBuilder: (context, index) {
                      final currency = currencies[index];
                      return Obx(
                        () => GestureDetector(
                          onTap: () async {
                            await controller.updateCurrencyViaAPI(currency['symbol']!);
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Currency updated to ${currency['name']}',
                            );
                          },
                          child: Container(
                            width: screenWidth,
                            height: 54,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? Color(0xFF262626)
                                  : AppColors.textWhite,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? AppColors.deepGrey
                                      : Color(0xFFEDEDF0),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    currency['symbol']!,
                                    style: getTextStyle2(
                                      color:
                                          controller.currency.value ==
                                              currency['symbol']
                                              ? (isDark
                                                    ? AppColors.textWhite
                                                    : AppColors.black)
                                              : Color(0xFF828282),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    currency['name']!,
                                    style: getTextStyle2(
                                      color:
                                          controller.currency.value ==
                                              currency['symbol']
                                              ? (isDark
                                                    ? AppColors.textWhite
                                                    : AppColors.black)
                                              : Color(0xFF828282),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (controller.currency.value ==
                                    currency['symbol'])
                                  Icon(
                                    Icons.check,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Center(
                  child: Container(
                    width: 134,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: isDark ? AppColors.textWhite : Color(0xFF2B2F38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}