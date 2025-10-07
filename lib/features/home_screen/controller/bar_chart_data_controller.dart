// // teddy_5618/features/home_screen/controller/bar_chart_data_controller.dart
// import 'package:get/get.dart';
// import 'package:teddy_5618/features/home_screen/controller/filter_screen_controller.dart';


// class ChartDataPoint {
//   final String label; 
//   final double value; 

//   ChartDataPoint(this.label, this.value);
// }

// class BarChartDataController extends GetxController {
//   final FilterScreenController filterController = Get.find<FilterScreenController>();

//   // Observable for your monthly chart data
//   RxList<ChartDataPoint> monthlyChartData = <ChartDataPoint>[].obs;
//   // Observable for your yearly chart data
//   RxList<ChartDataPoint> yearlyChartData = <ChartDataPoint>[].obs;

//   RxBool isLoadingChartData = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     // Listen to changes in the filter controller's selected date and period type
//     ever(filterController.selectedMonthYearFilter, (_) => _fetchChartData());
//     ever(filterController.isMonthlySelected, (_) => _fetchChartData());

//     // Initial data fetch
//     _fetchChartData();
//   }

//   // This method will fetch or generate your chart data
//   void _fetchChartData() async {
//     isLoadingChartData.value = true;

//     // Simulate a network request or heavy computation
//     await Future.delayed(const Duration(milliseconds: 500));

//     final bool isMonthly = filterController.isMonthlySelected.value;
//     final DateTime selectedDate = filterController.selectedMonthYearFilter.value;

//     if (isMonthly) {
//       // Generate dummy data for a monthly view
//       // You would fetch actual data for selectedDate.year and selectedDate.month
//       monthlyChartData.value = _generateDummyMonthlyData(selectedDate.year, selectedDate.month);
//       yearlyChartData.clear(); // Clear yearly data if monthly is selected
//     } else {
//       // Generate dummy data for a yearly view
//       // You would fetch actual data for selectedDate.year (or a range of years)
//       yearlyChartData.value = _generateDummyYearlyData(selectedDate.year);
//       monthlyChartData.clear(); // Clear monthly data if yearly is selected
//     }

//     isLoadingChartData.value = false;
//   }

//   List<ChartDataPoint> _generateDummyMonthlyData(int year, int month) {
//     // Example: Dummy data for 7 days in the selected month
//     List<ChartDataPoint> data = [];
//     final int daysInMonth = DateTime(year, month + 1, 0).day; // Get last day of month

//     for (int i = 1; i <= daysInMonth; i += (daysInMonth / 7).round().clamp(1, daysInMonth)) { // Roughly 7 points
//       data.add(ChartDataPoint("$i", (i * 10.0) + (month * 5.0) + (year % 10 * 20.0)));
//       if (data.length >= 7) break; // Limit to around 7 points for readability
//     }
//     return data;
//   }

//   List<ChartDataPoint> _generateDummyYearlyData(int year) {
//     // Example: Dummy data for 12 months in the selected year
//     return List.generate(12, (index) {
//       final monthName = _getMonthName(index + 1);
//       return ChartDataPoint(monthName, (index + 1) * 100.0 + (year % 10 * 500.0));
//     });
//   }

//   String _getMonthName(int month) {
//     switch (month) {
//       case 1: return 'Jan'; case 2: return 'Feb'; case 3: return 'Mar'; case 4: return 'Apr';
//       case 5: return 'May'; case 6: return 'Jun'; case 7: return 'Jul'; case 8: return 'Aug';
//       case 9: return 'Sep'; case 10: return 'Oct'; case 11: return 'Nov'; case 12: return 'Dec';
//       default: return '';
//     }
//   }
// }



// teddy_5618/features/home_screen/controller/bar_chart_data_controller.dart
import 'package:get/get.dart';
import 'package:teddy_5618/features/home_screen/controller/filter_screen_controller.dart';


class ChartDataPoint {
  final String label; 
  final double value; 

  ChartDataPoint(this.label, this.value);
}

class BarChartDataController extends GetxController {
  late final FilterScreenController filterController;

  // Observable for your monthly chart data
  RxList<ChartDataPoint> monthlyChartData = <ChartDataPoint>[].obs;
  // Observable for your yearly chart data
  RxList<ChartDataPoint> yearlyChartData = <ChartDataPoint>[].obs;

  RxBool isLoadingChartData = false.obs;

  @override
  void onInit() {
    super.onInit();
    filterController = Get.find<FilterScreenController>();
    // Listen to changes in the filter controller's selected date and period type
    ever(filterController.selectedMonthYearFilter, (_) => _fetchChartData());
    ever(filterController.isMonthlySelected, (_) => _fetchChartData());

    // Initial data fetch
    _fetchChartData();
  }

  // This method will fetch or generate your chart data
  void _fetchChartData() async {
    isLoadingChartData.value = true;

    // Simulate a network request or heavy computation
    await Future.delayed(const Duration(milliseconds: 500));

    final bool isMonthly = filterController.isMonthlySelected.value;
    final DateTime selectedDate = filterController.selectedMonthYearFilter.value ?? DateTime.now();

    if (isMonthly) {
      // Generate dummy data for a monthly view
      // You would fetch actual data for selectedDate.year and selectedDate.month
      monthlyChartData.value = _generateDummyMonthlyData(selectedDate.year, selectedDate.month);
      yearlyChartData.clear(); // Clear yearly data if monthly is selected
    } else {
      // Generate dummy data for a yearly view
      // You would fetch actual data for selectedDate.year (or a range of years)
      yearlyChartData.value = _generateDummyYearlyData(selectedDate.year);
      monthlyChartData.clear(); // Clear monthly data if yearly is selected
    }

    isLoadingChartData.value = false;
  }

  List<ChartDataPoint> _generateDummyMonthlyData(int year, int month) {
    // Example: Dummy data for 7 days in the selected month
    List<ChartDataPoint> data = [];
    final int daysInMonth = DateTime(year, month + 1, 0).day; // Get last day of month

    for (int i = 1; i <= daysInMonth; i += (daysInMonth / 7).round().clamp(1, daysInMonth)) { // Roughly 7 points
      data.add(ChartDataPoint("$i", (i * 10.0) + (month * 5.0) + (year % 10 * 20.0)));
      if (data.length >= 7) break; // Limit to around 7 points for readability
    }
    return data;
  }

  List<ChartDataPoint> _generateDummyYearlyData(int year) {
    // Example: Dummy data for 12 months in the selected year
    return List.generate(12, (index) {
      final monthName = _getMonthName(index + 1);
      return ChartDataPoint(monthName, (index + 1) * 100.0 + (year % 10 * 500.0));
    });
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1: return 'Jan'; case 2: return 'Feb'; case 3: return 'Mar'; case 4: return 'Apr';
      case 5: return 'May'; case 6: return 'Jun'; case 7: return 'Jul'; case 8: return 'Aug';
      case 9: return 'Sep'; case 10: return 'Oct'; case 11: return 'Nov'; case 12: return 'Dec';
      default: return '';
    }
  }
}