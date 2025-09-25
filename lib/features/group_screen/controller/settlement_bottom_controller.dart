import 'package:get/get.dart';

class SettlementBottomController extends GetxController {
  /// Holds selected state for the "To Pay" list
  var groupOneSelected = <bool>[false, false].obs;

  /// Holds selected state for the "To Collect" list
  var groupTwoSelected = <bool>[false].obs;

  /// Toggle a specific checkbox in Group One
  void toggleGroupOne(int index) {
    groupOneSelected[index] = !groupOneSelected[index];
  }

  /// Toggle a specific checkbox in Group Two
  void toggleGroupTwo(int index) {
    groupTwoSelected[index] = !groupTwoSelected[index];
  }

  /// Select or unselect all in Group One
  void selectAllGroupOne(bool isSelected) {
    for (var i = 0; i < groupOneSelected.length; i++) {
      groupOneSelected[i] = isSelected;
    }
  }

  /// Select or unselect all in Group Two
  void selectAllGroupTwo(bool isSelected) {
    for (var i = 0; i < groupTwoSelected.length; i++) {
      groupTwoSelected[i] = isSelected;
    }
  }

  /// Check if all items in Group One are selected
  bool get isAllGroupOneSelected =>
      groupOneSelected.every((selected) => selected);

  /// Check if all items in Group Two are selected
  bool get isAllGroupTwoSelected =>
      groupTwoSelected.every((selected) => selected);
}
