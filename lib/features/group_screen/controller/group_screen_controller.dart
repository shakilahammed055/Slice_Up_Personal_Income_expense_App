import 'package:get/get.dart';



class GroupScreenController extends GetxController {
  // Observable variable to track the selected assistant
  final selectedAssistant = ''.obs;

  // Method to update the selected assistant
  void setAssistant(String assistant) {
    selectedAssistant.value = assistant;
  }
}

  // void handleFabPress() {
  //   if (isDateRangeSet.value) {
  //     Get.to(() => ExpenseScreen());
  //   } else {
  //     Get.dialog(Showmonthsetting(controller: this));
  //   }
  // }
