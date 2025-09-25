import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void showLanguageDialog(BuildContext context, SettingController controller) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final languages = [
    'English',
    'Bahasa Indonesia',
    'Bahasa Malay',
    '한국어',
    '中文',
    '日语',
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
          maxHeight: screenHeight * 0.45,
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
                        'Language',
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          color: isDark
                              ? AppColors.textWhite
                              : Color(0xFF141414),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24),
                      color: isDark ? AppColors.textWhite : Color(0xFF141414),
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
                    itemCount: languages.length,
                    itemBuilder: (context, index) {
                      final language = languages[index];
                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            controller.updateLanguage(language);
                            Get.back();
                            Get.snackbar(
                              'Success',
                              'Language updated to $language',
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
                                Expanded(
                                  child: Text(
                                    language,
                                    style: getTextStyle2(
                                      color:
                                          controller.language.value == language
                                          ? (isDark
                                                ? AppColors.textWhite
                                                : Color(0xFF2B2F38))
                                          : Color(0xFF5D6679),
                                      fontSize: 16,
                                      fontWeight:
                                          controller.language.value == language
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (controller.language.value == language)
                                  Icon(
                                    Icons.check,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : Color(0xFF2B2F38),
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
