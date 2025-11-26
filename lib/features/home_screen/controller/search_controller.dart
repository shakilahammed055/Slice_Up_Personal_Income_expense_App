import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/home_screen/controller/home_screen_controller.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';

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
  final TextEditingController textController = TextEditingController();
  final RxString searchText = ''.obs;
  final RxList<SearchResultItem> searchResults = <SearchResultItem>[].obs;
  final RxString headerValue = ''.obs;
  String currency = '';

  @override
  void onInit() {
    super.onInit();
    textController.addListener(() {
      searchText.value = textController.text;
    });
    _loadData();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }

  Future<void> _loadData() async {
    searchResults.clear();
    try {
      final homeController = Get.find<HomeController>();
      if (homeController.isApiDataLoaded.value &&
          homeController.apiGroupedByDate.isNotEmpty) {
        // Use API data if available
        final Map<String, dynamic> data = {
          'currency': '', // prefer API value when available
          'groupedByDate': homeController.apiGroupedByDate,
        };
        currency = data['currency'] ?? '';
        final List<dynamic> groupedByDate = data['groupedByDate'] ?? [];

        searchResults.assignAll(
          groupedByDate.map((group) {
            final int net = group['net'] ?? 0;
            final String date = group['date'] ?? '';
            final String dayName = _getDayNameFromDate(date);
            final String formattedDate = date.length >= 7
                ? date.substring(5).replaceAll('-', '/')
                : date;

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
        headerValue.value = '${homeController.totalIncome} $currency';
      } else {
        // Fallback to local data
        final expenseController = Get.find<ExpenseController>();
        final groupedEntries = expenseController.getEntriesByDate();
        searchResults.assignAll(
          groupedEntries.entries.map((entry) {
            final double net = expenseController.getTotalAmountForDate(
              entry.key,
            );
            final String date = entry.key;
            final String dayName = _getDayNameFromDate(date);
            final String formattedDate = date; // Already in dd/MM/yyyy

            return SearchResultItem(
              id: date,
              iconPath: IconPath.lipstickIcon,
              title: '$dayName, $formattedDate',
              value:
                  '${net >= 0 ? '+' : ''}${net.toStringAsFixed(2)} $currency',
              valueColor: net >= 0 ? AppColors.success : AppColors.error,
            );
          }).toList(),
        );
        headerValue.value =
            '${expenseController.entries.fold<double>(0.0, (sum, e) => sum + (e.isIncome ? e.amount : 0))} $currency';
      }
    } catch (e) {
      // Fallback to sample data or handle error (e.g., show snackbar)
      // ignore: avoid_print
      print('Error loading data: $e');
      _loadSampleData();
    }
  }

  String _getDayNameFromDate(String dateStr) {
    try {
      DateTime date;
      if (dateStr.contains('-')) {
        // API format: YYYY-MM-DD
        date = DateTime.parse(dateStr);
      } else {
        // Local format: dd/MM/yyyy
        final parts = dateStr.split('/');
        date = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
      return DateFormat('EEE').format(date);
    } catch (e) {
      return '';
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

  void clearSearch() {
    textController.clear();
    searchText.value = '';
    refreshData();
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
