import 'package:get/get.dart';

class GroupFilterScreenController extends GetxController {
  // For the "Expense View" section
  var groupOneSelected = 0.obs;

  // For the "Transaction Type" section
  var groupTwoSelected = 0.obs;

  // Used if you want to show a specific screen based on 'Invoice Me' or 'All Group'
  var showIndividual = false.obs;

  void selectGroupOne(int index) {
    groupOneSelected.value = index;

    // You can use this flag if you want to switch screens later based on selection
    showIndividual.value = index == 1;

    // Optional: Add logic if needed for side effects when switching selection
  }

  void selectGroupTwo(int index) {
    groupTwoSelected.value = index;

    // Optional: Add logic here based on borrow/lent choice
  }
}
