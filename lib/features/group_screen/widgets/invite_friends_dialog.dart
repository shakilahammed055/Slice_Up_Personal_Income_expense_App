import 'package:flutter/cupertino.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

void showInviteDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(
          'Invite friends to collaborate',
          style: getTextStyle2(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        content: Column(
          children: [
            Text(
              'You need at least 2 members.',
              style: getTextStyle2(fontSize: 13, fontWeight: FontWeight.w400),
            ),

            Text(
              'Already invited?\nGive them a bit of time to join.',
              textAlign: TextAlign.center,
              style: getTextStyle2(fontSize: 13, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              // Add your invite logic
            },
            child: Text(
              'Invite'.tr,
              style: getTextStyle2(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.lightblue,
              ),
            ),
          ),
        ],
      );
    },
  );
}
