import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void showImagePickerBottomSheet(
    BuildContext context,
    SettingController controller,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          color: isDark
                                  ? Color(0xFF262626)
                                  : AppColors.textWhite,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Image Source'.tr,
                style: getTextStyle2(
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(
                  Icons.camera_alt,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
                title: Text(
                  'Take Photo'.tr,
                  style: getTextStyle2(
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
                title: Text(
                  'Choose from Gallery'.tr,
                  style: getTextStyle2(
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Get.back();
                  controller.pickImage(ImageSource.gallery);
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () => Get.back(),
                child: Text(
                  'Cancel'.tr,
                  style: getTextStyle2(
                    color: Color(0xFF828282),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }