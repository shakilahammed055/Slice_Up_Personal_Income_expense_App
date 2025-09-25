// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:teddy_5618/core/Urls/endpoint.dart';
// import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
// import 'package:teddy_5618/features/home_screen/widgets/month_setting.dart';
// import 'package:teddy_5618/features/set_expense_income/screen/expense_screen.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:flutter_easyloading/flutter_easyloading.dart';

// class HomeController extends GetxController {
//   var selectedAssistant = RxString('');
//   var selectedStartDate = RxInt(-1);
//   var selectedEndDate = RxInt(-1);
//   var totalAmount = RxString('-');
//   var currentMonth = RxString('');
//   var nextMonth = RxString('');
//   var isDateRangeSet = RxBool(false);
//   final dio.Dio _dio = dio.Dio();

//   HomeController() {
//     currentMonth.value = DateFormat('MMMM').format(DateTime.now());
//     _updateNextMonth();
//     _loadSavedSettings(); // Load saved settings on initialization
//   }

//   Future<void> _loadSavedSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     currentMonth.value =
//         prefs.getString('currentMonth') ??
//         DateFormat('MMMM').format(DateTime.now());
//     selectedStartDate.value = prefs.getInt('selectedStartDate') ?? -1;
//     selectedEndDate.value = prefs.getInt('selectedEndDate') ?? -1;
//     selectedAssistant.value = prefs.getString('selectedAssistant') ?? '';
//     isDateRangeSet.value =
//         selectedStartDate.value != -1 && selectedEndDate.value != -1;
//     _updateNextMonth();
//     _updateTotalAmount();
//   }

//   Future<void> _saveSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('currentMonth', currentMonth.value);
//     await prefs.setInt('selectedStartDate', selectedStartDate.value);
//     await prefs.setInt('selectedEndDate', selectedEndDate.value);
//     await prefs.setString('selectedAssistant', selectedAssistant.value);
//   }

//   void setAssistant(String assistant) async {
//     selectedAssistant.value = assistant;
//     await _saveSettings(); // Save to local storage first
//     await updateAssistantTypeViaAPI(assistant); // Then sync with API
//   }

//   String _displayToApiAssistantType(String displayAssistantType) {
//     // Map display values to API-compatible values
//     if (displayAssistantType == 'supportive'.tr) {
//       return 'supportive';
//     } else if (displayAssistantType == 'sarcastic'.tr) {
//       return 'sarcastic';
//     }
//     return displayAssistantType; // Fallback to input value if no mapping
//   }

//   Future<bool> updateAssistantTypeViaAPI(String newAssistantType) async {
//     EasyLoading.show(status: 'Updating assistant type...');
//     try {
//       debugPrint('Updating assistant type via API...');
//       final String? approvalToken = await AuthService.getApprovalToken();
//       if (approvalToken == null || approvalToken.isEmpty) {
//         debugPrint('No approval token found');
//         EasyLoading.showError('No authentication token found');
//         return false;
//       }
//       debugPrint(
//         'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
//       );
//       String apiAssistantType = _displayToApiAssistantType(newAssistantType);
//       debugPrint('Mapped assistant type for API: $apiAssistantType');
//       final Map<String, dynamic> requestBody = {
//         'assistantType': apiAssistantType,
//       };
//       debugPrint('Request body: $requestBody');
//       final dio.Response response = await _dio.patch(
//         Urls.updateprofile,
//         data: requestBody,
//         options: dio.Options(
//           headers: {
//             'Authorization': approvalToken,
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//       debugPrint('API response received: statusCode=${response.statusCode}');
//       debugPrint('Response data: ${response.data}');
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         dynamic responseData = response.data;
//         if (responseData is Map<String, dynamic>) {
//           selectedAssistant.value = newAssistantType;
//           debugPrint('Assistant type updated successfully via API');
//           EasyLoading.showSuccess('Assistant type updated successfully');
//           return true;
//         } else {
//           debugPrint('Unexpected response format: ${responseData.runtimeType}');
//           EasyLoading.showError('Unexpected response format from server');
//           return false;
//         }
//       } else {
//         debugPrint(
//           'Update failed with status: ${response.statusCode}, response: ${response.data}',
//         );
//         EasyLoading.showError(
//           'Failed to update assistant type: ${response.statusCode}',
//         );
//         return false;
//       }
//     } on dio.DioException catch (e) {
//       debugPrint('DioException during update: ${e.type}');
//       debugPrint('Error message: ${e.message}');
//       debugPrint('Response status: ${e.response?.statusCode}');
//       debugPrint('Response data: ${e.response?.data}');
//       String errorMessage = 'Failed to update assistant type';
//       if (e.type == dio.DioExceptionType.connectionTimeout ||
//           e.type == dio.DioExceptionType.sendTimeout ||
//           e.type == dio.DioExceptionType.receiveTimeout) {
//         errorMessage =
//             'Connection timeout. Please check your internet connection.';
//       } else if (e.type == dio.DioExceptionType.badResponse) {
//         errorMessage = 'Server error: ${e.response?.statusCode}';
//         if (e.response?.statusCode == 401) {
//           errorMessage = 'Authentication failed. Please login again.';
//         } else if (e.response?.statusCode == 400) {
//           errorMessage = 'Invalid assistant type provided.';
//         }
//       } else if (e.message != null) {
//         errorMessage = e.message!;
//       }
//       EasyLoading.showError(errorMessage);
//       return false;
//     } catch (e) {
//       debugPrint('Unexpected error during update: $e');
//       EasyLoading.showError('Unexpected error occurred');
//       return false;
//     } finally {
//       EasyLoading.dismiss();
//     }
//   }

//   void setStartDate(int date) {
//     if (date >= 1 && date <= getDaysInMonth(currentMonth.value)) {
//       selectedStartDate.value = date;
//       if (date > 1) {
//         selectedEndDate.value = date - 1;
//       } else {
//         selectedEndDate.value = -1;
//       }
//       _updateDateRangeStatus();
//       _updateTotalAmount();
//     }
//   }

//   void setEndDate(int date) {
//     if (date >= 1 && date <= getDaysInMonth(nextMonth.value)) {
//       selectedEndDate.value = date;
//       _updateDateRangeStatus();
//       _updateTotalAmount();
//     }
//   }

//   void clearMonthSettings() {
//     selectedStartDate.value = -1;
//     selectedEndDate.value = -1;
//     isDateRangeSet.value = false;
//     currentMonth.value = DateFormat('MMMM').format(DateTime.now());
//     _updateNextMonth();
//     _updateTotalAmount();
//     _saveSettings(); // Save cleared settings
//   }

//   void setMonth(String month) {
//     currentMonth.value = month;
//     _updateNextMonth();
//     clearMonthSettings();
//   }

//   void _updateNextMonth() {
//     List<String> months = [
//       'January',
//       'February',
//       'March',
//       'April',
//       'May',
//       'June',
//       'July',
//       'August',
//       'September',
//       'October',
//       'November',
//       'December',
//     ];
//     int currentIndex = months.indexOf(currentMonth.value);
//     nextMonth.value = months[(currentIndex + 1) % 12];
//   }

//   int getDaysInMonth(String month) {
//     switch (month) {
//       case 'January':
//         return 31;
//       case 'February':
//         return 28;
//       case 'March':
//         return 31;
//       case 'April':
//         return 30;
//       case 'May':
//         return 31;
//       case 'June':
//         return 30;
//       case 'July':
//         return 31;
//       case 'August':
//         return 31;
//       case 'September':
//         return 30;
//       case 'October':
//         return 31;
//       case 'November':
//         return 30;
//       case 'December':
//         return 31;
//       default:
//         return 30;
//     }
//   }

//   void _updateTotalAmount() {
//     if (selectedStartDate.value != -1 && selectedEndDate.value != -1) {
//       int daysInCurrentMonth = getDaysInMonth(currentMonth.value);
//       int days =
//           (daysInCurrentMonth - selectedStartDate.value + 1) +
//           selectedEndDate.value;
//       totalAmount.value = days > 0 ? 'S\$${days * 100}' : '-';
//     } else {
//       totalAmount.value = '-';
//     }
//   }

//   void _updateDateRangeStatus() {
//     isDateRangeSet.value =
//         selectedStartDate.value != -1 && selectedEndDate.value != -1;
//   }

//   void handleFabPress(BuildContext context) {
//     debugPrint('handleFabPress called');
//     if (isDateRangeSet.value) {
//       Get.to(() => const ExpenseScreen());
//     } else {
//       Showmonthsetting(controller: this).show(context);
//     }
//   }

//   Future<void> saveDateRange() async {
//     if (selectedStartDate.value != -1 && selectedEndDate.value != -1) {
//       int start = selectedStartDate.value;
//       int end = selectedEndDate.value;
//       DateTime now = DateTime.now();
//       int currentYear = now.year;
//       List<String> months = [
//         'January',
//         'February',
//         'March',
//         'April',
//         'May',
//         'June',
//         'July',
//         'August',
//         'September',
//         'October',
//         'November',
//         'December',
//       ];
//       int currentMonthIndex = months.indexOf(currentMonth.value) + 1;
//       int endYear = currentMonthIndex == 12 ? currentYear + 1 : currentYear;
//       int endMonth = currentMonthIndex == 12 ? 1 : currentMonthIndex + 1;

//       String startDateStr =
//           '$currentYear-${currentMonthIndex.toString().padLeft(2, '0')}-${start.toString().padLeft(2, '0')}';
//       String endDateStr =
//           '$endYear-${endMonth.toString().padLeft(2, '0')}-${end.toString().padLeft(2, '0')}';

//       isDateRangeSet.value = true;
//       await _saveSettings(); // Save settings locally first
//       await _updateDateRangeAPI(startDateStr, endDateStr); // Then call API
//     } else {
//       EasyLoading.showError('Please select both Start and End dates');
//     }
//   }

//   Future<bool> _updateDateRangeAPI(String startDate, String endDate) async {
//     EasyLoading.show(status: 'Updating date range...');
//     try {
//       final String? approvalToken = await AuthService.getApprovalToken();
//       if (approvalToken == null || approvalToken.isEmpty) {
//         debugPrint('No approval token found');
//         EasyLoading.showError('No authentication token found');
//         return false;
//       }
//       debugPrint(
//         'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
//       );
//       final Map<String, dynamic> requestBody = {
//         'startDate': startDate,
//         'endDate': endDate,
//       };
//       debugPrint('Request body: $requestBody');
//       final dio.Response response = await _dio.patch(
//         Urls.updateprofile,
//         data: requestBody,
//         options: dio.Options(
//           headers: {
//             'Authorization': approvalToken,
//             'Content-Type': 'application/json',
//           },
//         ),
//       );
//       debugPrint('API response received: statusCode=${response.statusCode}');
//       debugPrint('Response data: ${response.data}');
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         EasyLoading.showSuccess('Date range updated to $startDate~$endDate');
//         return true;
//       } else {
//         debugPrint(
//           'Update failed with status: ${response.statusCode}, response: ${response.data}',
//         );
//         EasyLoading.showError(
//           'Failed to update date range: ${response.statusCode}',
//         );
//         return false;
//       }
//     } on dio.DioException catch (e) {
//       debugPrint('DioException during update: ${e.type}');
//       debugPrint('Error message: ${e.message}');
//       debugPrint('Response status: ${e.response?.statusCode}');
//       debugPrint('Response data: ${e.response?.data}');
//       String errorMessage = 'Failed to update date range';
//       if (e.type == dio.DioExceptionType.connectionTimeout ||
//           e.type == dio.DioExceptionType.sendTimeout ||
//           e.type == dio.DioExceptionType.receiveTimeout) {
//         errorMessage =
//             'Connection timeout. Please check your internet connection.';
//       } else if (e.type == dio.DioExceptionType.badResponse) {
//         errorMessage = 'Server error: ${e.response?.statusCode}';
//         if (e.response?.statusCode == 401) {
//           errorMessage = 'Authentication failed. Please login again.';
//         }
//       } else if (e.message != null) {
//         errorMessage = e.message!;
//       }
//       EasyLoading.showError(errorMessage);
//       return false;
//     } catch (e) {
//       debugPrint('Unexpected error during update: $e');
//       EasyLoading.showError('Unexpected error occurred');
//       return false;
//     } finally {
//       EasyLoading.dismiss();
//     }
//   }
// }







// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/home_screen/widgets/month_setting.dart';
import 'package:teddy_5618/features/set_expense_income/screen/expense_screen.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class HomeController extends GetxController {
  var selectedAssistant = RxString('');
  var selectedStartDate = RxInt(-1);
  var selectedEndDate = RxInt(-1);
  var totalAmount = RxString('-');
  var currentMonth = RxString('');
  var nextMonth = RxString('');
  var isDateRangeSet = RxBool(false);
  
  // New API data observables
  var remainingBalance = RxDouble(0.0);
  var apiStartDate = RxString('');
  var apiEndDate = RxString('');
  var isApiDataLoaded = RxBool(false);
  
  final dio.Dio _dio = dio.Dio();

  HomeController() {
    currentMonth.value = DateFormat('MMMM').format(DateTime.now());
    _updateNextMonth();
    _loadSavedSettings();
    _fetchIncomeAndExpenses(); // Fetch API data on initialization
  }

  // New method to fetch income and expenses from API
  Future<void> _fetchIncomeAndExpenses() async {
    try {
      // EasyLoading.show(status: 'Loading data...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        return;
      }

      final dio.Response response = await _dio.get(
        Urls.getincomeandexpence, // Make sure this URL is defined in your endpoint
        options: dio.Options(
          headers: {
            'Authorization': approvalToken,
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('API response received: statusCode=${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['status'] == 'success') {
          final data = responseData['data'];
          
          // Update remaining balance
          remainingBalance.value = (data['remainingBalance'] ?? 0.0).toDouble();
          
          // Update date range from API
          if (data['profileDate'] != null) {
            final profileDate = data['profileDate'];
            if (profileDate['startDate'] != null && profileDate['endDate'] != null) {
              apiStartDate.value = profileDate['startDate'];
              apiEndDate.value = profileDate['endDate'];
              
              // Update local date range settings from API
              await _updateLocalDateRangeFromAPI(profileDate['startDate'], profileDate['endDate']);
            }
          }
          
          isApiDataLoaded.value = true;
          debugPrint('Income and expenses data loaded successfully');
        }
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during fetch: ${e.type}');
      debugPrint('Error message: ${e.message}');
      isApiDataLoaded.value = true; // Set to true even on error to stop loading
    } catch (e) {
      debugPrint('Unexpected error during fetch: $e');
      isApiDataLoaded.value = true;
    } finally {
      EasyLoading.dismiss();
    }
  }

  // New method to update local date range from API data
  Future<void> _updateLocalDateRangeFromAPI(String startDateStr, String endDateStr) async {
    try {
      // Parse start date
      final startDate = DateTime.parse(startDateStr);
      final currentMonthIndex = startDate.month;
      final startDay = startDate.day;
      
      // Parse end date
      final endDate = DateTime.parse(endDateStr);
      final endMonthIndex = endDate.month;
      final endDay = endDate.day;
      
      // Update local state
      currentMonth.value = DateFormat('MMMM').format(startDate);
      selectedStartDate.value = startDay;
      selectedEndDate.value = endDay;
      
      // Update next month based on current month
      _updateNextMonth();
      
      // Update date range status
      isDateRangeSet.value = true;
      
      // Save to local storage
      await _saveSettings();
      
      // Update total amount
      _updateTotalAmount();
      
      debugPrint('Local date range updated from API: $startDay ~ $endDay');
    } catch (e) {
      debugPrint('Error parsing API dates: $e');
    }
  }

  // Refresh method to call when needed (e.g., after updating date range)
  Future<void> refreshIncomeAndExpenses() async {
    remainingBalance.value = 0.0;
    apiStartDate.value = '';
    apiEndDate.value = '';
    isApiDataLoaded.value = false;
    await _fetchIncomeAndExpenses();
  }

  Future<void> _loadSavedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    currentMonth.value =
        prefs.getString('currentMonth') ??
        DateFormat('MMMM').format(DateTime.now());
    selectedStartDate.value = prefs.getInt('selectedStartDate') ?? -1;
    selectedEndDate.value = prefs.getInt('selectedEndDate') ?? -1;
    selectedAssistant.value = prefs.getString('selectedAssistant') ?? '';
    isDateRangeSet.value =
        selectedStartDate.value != -1 && selectedEndDate.value != -1;
    _updateNextMonth();
    _updateTotalAmount();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentMonth', currentMonth.value);
    await prefs.setInt('selectedStartDate', selectedStartDate.value);
    await prefs.setInt('selectedEndDate', selectedEndDate.value);
    await prefs.setString('selectedAssistant', selectedAssistant.value);
  }

  void setAssistant(String assistant) async {
    selectedAssistant.value = assistant;
    await _saveSettings();
    await updateAssistantTypeViaAPI(assistant);
  }

  String _displayToApiAssistantType(String displayAssistantType) {
    if (displayAssistantType == 'supportive'.tr) {
      return 'supportive';
    } else if (displayAssistantType == 'sarcastic'.tr) {
      return 'sarcastic';
    }
    return displayAssistantType;
  }

  Future<bool> updateAssistantTypeViaAPI(String newAssistantType) async {
    EasyLoading.show(status: 'Updating assistant type...');
    try {
      debugPrint('Updating assistant type via API...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return false;
      }
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );
      String apiAssistantType = _displayToApiAssistantType(newAssistantType);
      debugPrint('Mapped assistant type for API: $apiAssistantType');
      final Map<String, dynamic> requestBody = {
        'assistantType': apiAssistantType,
      };
      debugPrint('Request body: $requestBody');
      final dio.Response response = await _dio.patch(
        Urls.updateprofile,
        data: requestBody,
        options: dio.Options(
          headers: {
            'Authorization': approvalToken,
            'Content-Type': 'application/json',
          },
        ),
      );
      debugPrint('API response received: statusCode=${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          selectedAssistant.value = newAssistantType;
          debugPrint('Assistant type updated successfully via API');
          EasyLoading.showSuccess('Assistant type updated successfully');
          return true;
        } else {
          debugPrint('Unexpected response format: ${responseData.runtimeType}');
          EasyLoading.showError('Unexpected response format from server');
          return false;
        }
      } else {
        debugPrint(
          'Update failed with status: ${response.statusCode}, response: ${response.data}',
        );
        EasyLoading.showError(
          'Failed to update assistant type: ${response.statusCode}',
        );
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during update: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to update assistant type';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid assistant type provided.';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
      return false;
    } catch (e) {
      debugPrint('Unexpected error during update: $e');
      EasyLoading.showError('Unexpected error occurred');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  void setStartDate(int date) {
    if (date >= 1 && date <= getDaysInMonth(currentMonth.value)) {
      selectedStartDate.value = date;
      if (date > 1) {
        selectedEndDate.value = date - 1;
      } else {
        selectedEndDate.value = -1;
      }
      _updateDateRangeStatus();
      _updateTotalAmount();
    }
  }

  void setEndDate(int date) {
    if (date >= 1 && date <= getDaysInMonth(nextMonth.value)) {
      selectedEndDate.value = date;
      _updateDateRangeStatus();
      _updateTotalAmount();
    }
  }

  void clearMonthSettings() {
    selectedStartDate.value = -1;
    selectedEndDate.value = -1;
    isDateRangeSet.value = false;
    currentMonth.value = DateFormat('MMMM').format(DateTime.now());
    _updateNextMonth();
    _updateTotalAmount();
    _saveSettings();
  }

  void setMonth(String month) {
    currentMonth.value = month;
    _updateNextMonth();
    clearMonthSettings();
  }

  void _updateNextMonth() {
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    int currentIndex = months.indexOf(currentMonth.value);
    nextMonth.value = months[(currentIndex + 1) % 12];
  }

  int getDaysInMonth(String month) {
    switch (month) {
      case 'January':
        return 31;
      case 'February':
        return 28;
      case 'March':
        return 31;
      case 'April':
        return 30;
      case 'May':
        return 31;
      case 'June':
        return 30;
      case 'July':
        return 31;
      case 'August':
        return 31;
      case 'September':
        return 30;
      case 'October':
        return 31;
      case 'November':
        return 30;
      case 'December':
        return 31;
      default:
        return 30;
    }
  }

  void _updateTotalAmount() {
    if (selectedStartDate.value != -1 && selectedEndDate.value != -1) {
      int daysInCurrentMonth = getDaysInMonth(currentMonth.value);
      int days =
          (daysInCurrentMonth - selectedStartDate.value + 1) +
          selectedEndDate.value;
      totalAmount.value = days > 0 ? 'S\$${days * 100}' : '-';
    } else {
      totalAmount.value = '-';
    }
  }

  void _updateDateRangeStatus() {
    isDateRangeSet.value =
        selectedStartDate.value != -1 && selectedEndDate.value != -1;
  }

  void handleFabPress(BuildContext context) {
    debugPrint('handleFabPress called');
    if (isDateRangeSet.value) {
      Get.to(() => const ExpenseScreen());
    } else {
      Showmonthsetting(controller: this).show(context);
    }
  }

  Future<void> saveDateRange() async {
    if (selectedStartDate.value != -1 && selectedEndDate.value != -1) {
      int start = selectedStartDate.value;
      int end = selectedEndDate.value;
      DateTime now = DateTime.now();
      int currentYear = now.year;
      List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      int currentMonthIndex = months.indexOf(currentMonth.value) + 1;
      int endYear = currentMonthIndex == 12 ? currentYear + 1 : currentYear;
      int endMonth = currentMonthIndex == 12 ? 1 : currentMonthIndex + 1;

      String startDateStr =
          '$currentYear-${currentMonthIndex.toString().padLeft(2, '0')}-${start.toString().padLeft(2, '0')}';
      String endDateStr =
          '$endYear-${endMonth.toString().padLeft(2, '0')}-${end.toString().padLeft(2, '0')}';

      isDateRangeSet.value = true;
      await _saveSettings();
      bool success = await _updateDateRangeAPI(startDateStr, endDateStr);
      if (success) {
        await refreshIncomeAndExpenses(); // Refresh data after successful update
      }
    } else {
      EasyLoading.showError('Please select both Start and End dates');
    }
  }

  Future<bool> _updateDateRangeAPI(String startDate, String endDate) async {
    EasyLoading.show(status: 'Updating date range...');
    try {
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return false;
      }
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );
      final Map<String, dynamic> requestBody = {
        'startDate': startDate,
        'endDate': endDate,
      };
      debugPrint('Request body: $requestBody');
      final dio.Response response = await _dio.patch(
        Urls.updateprofile,
        data: requestBody,
        options: dio.Options(
          headers: {
            'Authorization': approvalToken,
            'Content-Type': 'application/json',
          },
        ),
      );
      debugPrint('API response received: statusCode=${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        EasyLoading.showSuccess('Date range updated to $startDate~$endDate');
        return true;
      } else {
        debugPrint(
          'Update failed with status: ${response.statusCode}, response: ${response.data}',
        );
        EasyLoading.showError(
          'Failed to update date range: ${response.statusCode}',
        );
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during update: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to update date range';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
      return false;
    } catch (e) {
      debugPrint('Unexpected error during update: $e');
      EasyLoading.showError('Unexpected error occurred');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }
}