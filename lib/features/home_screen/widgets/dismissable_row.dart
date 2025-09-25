import 'package:flutter/material.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/controller/search_controller.dart';

class DismissibleRow extends StatelessWidget {
  final SearchResultItem item;
  final VoidCallback onDelete;

  const DismissibleRow({super.key, required this.item, required this.onDelete});

  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: Center(
            child: Text(
              'Delete Entry',
              style: getTextStyle2(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ),
          content: Text(
            'Are you sure you want to delete this entry?',
            textAlign: TextAlign.center,
            style: getTextStyle2(color: Colors.red, fontSize: 14),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: Text(
                'Cancel',
                style: getTextStyle2(
                  color: Colors.grey[600] ?? Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: getTextStyle2(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFE21818),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Image.asset(IconPath.deleteIcon, scale: 4),
      ),
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmationDialog(context);
      },
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        color: isDark ? const Color(0xFF262626) : AppColors.textWhite,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
        child: Row(
          children: [
            Image.asset(
              item.iconPath,
              scale: responsive.fromSmallMediumLarge(
                small: 4.0,
                medium: 4.0,
                large: 4.0,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              item.title,
              style: getTextStyle2(
                color: isDark ? AppColors.textWhite : AppColors.black,
                fontSize: responsive.fromSmallMediumLarge(
                  small: 12.0,
                  medium: 14.0,
                  large: 14.0,
                ),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              item.value,
              style: getTextStyle2(
                fontSize: responsive.fromSmallMediumLarge(
                  small: 12.0,
                  medium: 14.0,
                  large: 14.0,
                ),
                fontWeight: FontWeight.w500,
                color: item.valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
