// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/utils/constants/app_texts.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/core/utils/constants/icon_path.dart';

// // --- DATA MODEL ---
// class SearchResultItem {
//   final String id;
//   final String iconPath;
//   final String title;
//   final String value;
//   final Color valueColor;

//   SearchResultItem({
//     required this.id,
//     required this.iconPath,
//     required this.title,
//     required this.value,
//     required this.valueColor,
//   });
// }

// // --- CONTROLLER ---
// class SearchScreenController extends GetxController {
//   final RxList<SearchResultItem> searchResults = <SearchResultItem>[].obs;

//   @override
//   void onInit() {
//     super.onInit();
//     _loadSampleData();
//   }

//   void _loadSampleData() {
//     searchResults.addAll([
//       SearchResultItem(
//         id: '1',
//         iconPath: IconPath.lipstickIcon,
//         title: AppText.hair,
//         value: AppText.value40,
//         valueColor: AppColors.success,
//       ),
//       SearchResultItem(
//         id: '2',
//         iconPath: IconPath.lipstickIcon,
//         title: 'Makeup',
//         value: AppText.value40,
//         valueColor: AppColors.error,
//       ),
//     ]);
//   }

//   void deleteItem(String id) {
//     searchResults.removeWhere((item) => item.id == id);

//     Get.snackbar(
//       'Deleted',
//       'Item has been removed',
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: AppColors.error,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }

//   void addItem(SearchResultItem item) {
//     searchResults.add(item);
//   }

//   void searchItems(String query) {
//     if (query.isEmpty) {
//       refreshData();
//       return;
//     }

//     final filteredResults = searchResults
//         .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
//         .toList();

//     searchResults.assignAll(filteredResults);
//   }

//   void refreshData() {
//     searchResults.clear();
//     _loadSampleData();
//   }
// }




// lib/features/home_screen/controller/search_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
  final RxString headerValue = ''.obs;
  String currency = 'USD';

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    searchResults.clear();
    try {
      final response = await http.get(
        Uri.parse('https://teddybackend-mivk.onrender.com/api/v1/incomeAndExpences/getFilteredIncomeAndExpenses'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          final Map<String, dynamic> data = jsonData['data'];
          currency = data['currency'] ?? 'USD';
          final List<dynamic> groupedByDate = data['groupedByDate'] ?? [];

          searchResults.assignAll(
            groupedByDate.map((group) {
              final int net = group['net'] ?? 0;
              final String date = group['date'] ?? '';
              final String dayName = group['dayName'] ?? '';
              final String formattedDate = date.length >= 7 ? date.substring(5).replaceAll('-', '/') : date;

              return SearchResultItem(
                id: date,
                iconPath: IconPath.lipstickIcon, 
                title: '$dayName, $formattedDate',
                value: '${net >= 0 ? '+' : ''}${net.toString()} $currency',
                valueColor: net >= 0 ? AppColors.success : AppColors.error,
              );
            }).toList(),
          );

          // Update header value (e.g., total income from API)
          headerValue.value = '${data['totalIncome'] ?? 0} $currency';
        }
      }
    } catch (e) {
      // Fallback to sample data or handle error (e.g., show snackbar)
      // ignore: avoid_print
      print('Error loading data: $e');
      _loadSampleData();
    }
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
    headerValue.value = AppText.value40;
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
    _loadData();
  }
}