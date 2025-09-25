import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/screen/bottom_navigationbar.dart';
import 'package:teddy_5618/features/chat_screen/controller/chat_screen_controller.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ChatController controller = Get.put(ChatController());
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
     
      appBar: AppBar(
        backgroundColor:isDark ? AppColors.backgroundDark : AppColors.textWhite ,
        leading: GestureDetector(
          onTap: () {
            Get.offAll(() => BottomNavbarView());
          },
          child: Transform.scale(
            scale: 0.4,
            child: isDark
                ? Image.asset(IconPath.backarrowwhite)
                : Image.asset(IconPath.backarrow),
          ),
        ),
      ),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
        ),
        child: Column(
          children: [
            // Scrollable Chat Area
            Expanded(
              child: SingleChildScrollView(
                controller: controller.scrollController,
                child: Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.019,
                    left: screenWidth * 0.061,
                    right: screenWidth * 0.061,
                  ),
                  child: Column(
                    children: [
                      Obx(
                        () => ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.messages.length,
                          itemBuilder: (context, index) {
                            final message = controller.messages[index];
                            final isUser = message.isUser;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: isUser
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: screenWidth * 0.082,
                                        height: screenWidth * 0.082,
                                        margin: EdgeInsets.only(
                                          right: screenWidth * 0.02,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: isDark
                                              ? Color(0xFF262626)
                                              : Color(0xffEDEDF0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(30),
                                            ),
                                          ),
                                        ),
                                        child: Image.asset(IconPath.chiwawa1),
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                            bottom: screenHeight * 0.019,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.041,
                                            vertical: screenHeight * 0.014,
                                          ),
                                          decoration: ShapeDecoration(
                                            color: isDark
                                                ? Color(0xFF262626)
                                                : Color(0xffEDEDF0),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(24),
                                                topRight: Radius.circular(24),
                                                bottomLeft: Radius.circular(0),
                                                bottomRight: Radius.circular(
                                                  24,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child: SizedBox(
                                            width: screenWidth * 0.653,
                                            child: Text(
                                              message.text,
                                              style: getTextStyle2(
                                                color: isDark
                                                    ? AppColors.textWhite
                                                    : AppColors.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                lineHeight: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Container(
                                    margin: EdgeInsets.only(
                                      bottom: screenHeight * 0.019,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.041,
                                      vertical: screenHeight * 0.014,
                                    ),
                                    decoration: ShapeDecoration(
                                      color: 
                                      isDark
                                      ? Color(0xFF262626)
                                                : Color(0xFF141414),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24),
                                          topRight: Radius.circular(24),
                                          bottomLeft: Radius.circular(24),
                                          bottomRight: Radius.circular(0),
                                        ),
                                      ),
                                    ),
                                    child: SizedBox(
                                      width: screenWidth * 0.653,
                                      child: Text(
                                        message.text,
                                        style: getTextStyle2(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          lineHeight: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.118,
                      ), // ~100px on 844px height
                    ],
                  ),
                ),
              ),
            ),
            // Input Field
            Container(
              width: screenWidth,
              padding: EdgeInsets.only(
                left: screenWidth * 0.010,
                right: screenWidth * 0.010,
                bottom: screenHeight * 0.0095,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: screenWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.030,
                      vertical: screenHeight * 0.014,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            height: 44.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.041,
                              vertical: 0,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.deepGrey
                                  : Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            child: Center(
                              child: TextField(
                                cursorHeight: 20,
                                controller: controller.messageController,
                                style: getTextStyle2(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 12,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'Search for category or title'.tr,
                                  hintStyle: getTextStyle2(
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 12,
                                  ),
                                  border: InputBorder.none,
                                ),
                                onSubmitted: (value) =>
                                    controller.sendMessage(),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send),
                          onPressed: controller.sendMessage,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.014,
                      left: screenWidth * 0.287,
                      right: screenWidth * 0.287,
                    ),
                    child: Container(
                      width: screenWidth * 0.344,
                      height: 4,
                      decoration: ShapeDecoration(
                        color: Color(0xFF141414),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(100)),
                        ),
                      ),
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
}
