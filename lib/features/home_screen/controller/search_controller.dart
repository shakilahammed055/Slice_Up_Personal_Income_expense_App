// 

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';

// --- DATA MODEL ---
class SearchResultItem {
  final String id;
  final String iconPath;
  final String title;
  final String value;
  final Color valueColor;

  SearchResultItem({
    required this.id,
    required this.iconPath,
    required this.title,
    required this.value,
    required this.valueColor,
  });
}

// --- CONTROLLER ---
class SearchScreenController extends GetxController {
  final RxList<SearchResultItem> searchResults = <SearchResultItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleData();
  }

  void _loadSampleData() {
    searchResults.addAll([
      SearchResultItem(
        id: '1',
        iconPath: IconPath.lipstickIcon,
        title: AppText.hair,
        value: AppText.value40,
        valueColor: AppColors.success,
      ),
      SearchResultItem(
        id: '2',
        iconPath: IconPath.lipstickIcon,
        title: 'Makeup',
        value: AppText.value40,
        valueColor: AppColors.error,
      ),
    ]);
  }

  void deleteItem(String id) {
    searchResults.removeWhere((item) => item.id == id);

    Get.snackbar(
      'Deleted',
      'Item has been removed',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void addItem(SearchResultItem item) {
    searchResults.add(item);
  }

  void searchItems(String query) {
    if (query.isEmpty) {
      refreshData();
      return;
    }

    final filteredResults = searchResults
        .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    searchResults.assignAll(filteredResults);
  }

  void refreshData() {
    searchResults.clear();
    _loadSampleData();
  }
}
