import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';

import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/individual_card.dart';
import 'package:teddy_5618/features/group_screen/widgets/settlement_bottom.dart';
import 'package:teddy_5618/features/group_screen/widgets/minimize_card.dart';
import 'package:teddy_5618/features/group_screen/widgets/sliceup_balance_card.dart';
// Ensure this import path is correct

class SliceupPageScreen extends StatelessWidget {
  const SliceupPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the list of BalanceEntry objects for each row
    final controller = Get.put(GroupTripSpentController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
   

    final List<IndividualTransactionEntry> individualEntries = [
      IndividualTransactionEntry(
        fromAvatarColor: Colors.green,
        fromAvatarText: 'O',
        fromName: 'Ole',
        toAvatarColor: Colors.brown,
        toAvatarText: 'A',
        toName: 'Alice',
        amount: 'US\$ 40',
      ),
      IndividualTransactionEntry(
        fromAvatarColor: Colors.green,
        fromAvatarText: 'O',
        fromName: 'Ole',
        toAvatarColor: Colors.red,
        toAvatarText: 'E',
        toName: 'Eric',
        amount: 'US\$ 40',
      ),
      IndividualTransactionEntry(
        fromAvatarColor: Colors.brown,
        fromAvatarText: 'A',
        fromName: 'Alice',
        toAvatarColor: Colors.purple,
        toAvatarText: 'J',
        toName: 'Jon',
        amount: 'US\$ 40',
      ),
      IndividualTransactionEntry(
        fromAvatarColor: Colors.brown,
        fromAvatarText: 'A',
        fromName: 'Alice',
        toAvatarColor: Colors.red,
        toAvatarText: 'E',
        toName: 'Eric',
        amount: 'US\$ 40',
      ),
      IndividualTransactionEntry(
        fromAvatarColor: Colors.red,
        fromAvatarText: 'E',
        fromName: 'Eric',
        toAvatarColor: Colors.purple,
        toAvatarText: 'J',
        toName: 'Jon',
        amount: 'US\$ 40',
      ),
    ];

     final List<BalanceEntry> balanceEntries = [
      BalanceEntry(
        circleavatarColor: Colors.brown,
        circleavatartext: 'A',
        name: 'Alice',
        amount: '+S\$ 35',
        amountcolor: AppColors.green,
      ),
      BalanceEntry(
        circleavatarColor: Colors.green,
        circleavatartext: 'O',
        name: 'Ole',
        amount: '-S\$ 110',
        amountcolor: AppColors.error,
      ),
      BalanceEntry(
        circleavatarColor: Colors.purple,
        circleavatartext: 'J',
        name: 'Jon',
        amount: '-S\$ 29',
        amountcolor: AppColors.error,
      ),
      BalanceEntry(
        circleavatarColor: Colors.red,
        circleavatartext: 'E',
        name: 'Eric',
        amount: '-S\$ 45',
        amountcolor: AppColors.error,
      ),
    ];

    final List<MinimizeTransactionEntry> minimizeEntries = [
      MinimizeTransactionEntry(
        fromAvatarColor: Colors.green,
        fromAvatarText: 'O',
        fromName: 'Ole',
        toAvatarColor: Colors.brown,
        toAvatarText: 'A',
        toName: 'Alice',
        amount: 'US\$ 2,000,00000',
      ),
      MinimizeTransactionEntry(
        fromAvatarColor: Colors.green,
        fromAvatarText: 'O',
        fromName: 'Ole',
        toAvatarColor: Colors.red,
        toAvatarText: 'E',
        toName: 'Eric',
        amount: 'Rp 4000',
      ),
      MinimizeTransactionEntry(
        fromAvatarColor: Colors.brown,
        fromAvatarText: 'A',
        fromName: 'Alice',
        toAvatarColor: Colors.purple,
        toAvatarText: 'J',
        toName: 'Jon',
        amount: 'US\$ 40',
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLightGrey,
      // AppColors.backgroundLightGrey,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 23), 

            IndividualCard(entries: individualEntries),
           

            SizedBox(height: 24),

            // SlidingButtonIndivMin(controller: controller),

             Obx(() {
              final isIndividual = controller.isIndividualSelected.value;

              return GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                    ),
                    builder: (context) => SettlementBottom(),
                  );
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 1.1,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isIndividual
                        ? isDark
                              ? AppColors.green
                              : AppColors.green
                        //  AppColors.black
                        : AppColors.borderGrey, // Change color based on view
                    borderRadius: BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isIndividual
                        ? 'Settle up'.tr
                        : 'Settled'.tr, // Change text dynamically
                    style: getTextStyle2(
                      color: isIndividual
                          ? isDark
                                ? AppColors.black
                                : AppColors.black
                          // AppColors.textWhite
                          : AppColors.textGrey, // Change color based on view
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }),

            SizedBox(height: 16),
            // Obx(() {
            //   if (controller.isIndividualSelected.value) {
            //     return IndividualCard(entries: individualEntries);
            //   } else {
            //     return MinimizeCard(entries: minimizeEntries);
            //   }
            // }),
            SliceupBalanceCard(entries: balanceEntries),
            SizedBox(height: 24),
             MinimizeCard(entries: minimizeEntries),
           
            SizedBox(height: 66),
          ],
        ),
      ),
    );
  }
}
