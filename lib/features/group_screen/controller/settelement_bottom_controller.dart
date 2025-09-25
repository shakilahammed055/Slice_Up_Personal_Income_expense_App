import 'package:get/get.dart';


class GroupFilterScreenController extends GetxController {
  RxList<bool> groupOneSelections = <bool>[false, false].obs;
  RxList<bool> groupTwoSelections = <bool>[false].obs;

  void toggleGroupOne(int index) {
    groupOneSelections[index] = !groupOneSelections[index];
  }

  void toggleGroupTwo(int index) {
    groupTwoSelections[index] = !groupTwoSelections[index];
  }
}
