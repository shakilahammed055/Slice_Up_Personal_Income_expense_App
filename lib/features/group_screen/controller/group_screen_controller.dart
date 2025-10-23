import 'package:get/get.dart';
import 'package:teddy_5618/core/services/storage_service.dart';

class GroupScreenController extends GetxController {
  // Observable variable to track the selected assistant
  final selectedAssistant = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSelectedAssistant();
  }

  // Load the saved assistant selection from storage
  Future<void> _loadSelectedAssistant() async {
    try {
      await StorageService.init();
      final savedAssistant = StorageService.getSelectedAssistant();
      if (savedAssistant != null && savedAssistant.isNotEmpty) {
        selectedAssistant.value = savedAssistant;
      }
    // ignore: empty_catches
    } catch (e) {
    }
  }

  // Method to update the selected assistant and save it
  Future<void> setAssistant(String assistant) async {
    selectedAssistant.value = assistant;
    try {
      await StorageService.saveSelectedAssistant(assistant);
    // ignore: empty_catches
    } catch (e) {
    }
  }
}

  // void handleFabPress() {
  //   if (isDateRangeSet.value) {
  //     Get.to(() => ExpenseScreen());
  //   } else {
  //     Get.dialog(Showmonthsetting(controller: this));
  //   }
  // }
