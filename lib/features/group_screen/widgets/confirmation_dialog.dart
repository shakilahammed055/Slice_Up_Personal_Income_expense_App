import 'dart:ui'; // Required for ImageFilter.blur
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class ConfirmationDialog extends StatelessWidget {
  
  final VoidCallback onConfirm;
  final String title;
  final String content;
  final String? button1;
  final String? button2;

  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.content,
    this.button1,
    this.button2,
  });

  @override
  Widget build(BuildContext context) {
   
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: SizedBox(
        // ✅ --- THIS LINE FIXES THE SHAPE --- ✅
        width: 270.0, // Standard width for a Cupertino alert dialog
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14.0),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: _buildDialogContent(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogContent(BuildContext context) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
    // This part remains the same as it correctly builds the text and buttons
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: getTextStyle3(
                  color: CupertinoColors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                textAlign: TextAlign.center,
                style: getTextStyle3(
                  fontWeight: FontWeight.w400,
                  color: CupertinoColors.black,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: CupertinoColors.separator),
        SizedBox(
          height: 50,
       
         child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  // Apply padding inside the Expanded
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      button1 ?? 'Cancel'.tr,
                      style: getTextStyle3(
                        fontWeight: FontWeight.w400,
                        color: 
                         isDark ? AppColors.blueButton : CupertinoColors.activeBlue,
                        
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              const VerticalDivider(width: 1, color: CupertinoColors.separator),
              Expanded(
                child: Padding(
                  // Apply padding inside the Expanded
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      button2 ?? 'Leave'.tr,
                      style: getTextStyle3(
                        fontWeight: FontWeight.w400,
                        color: 
                        isDark ? AppColors.blueButton : CupertinoColors.activeBlue,
                        fontSize: 17,
                      ),
                    ),
                    onPressed: () {
                      onConfirm();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),

        ),
      ],
    );
  }
}
