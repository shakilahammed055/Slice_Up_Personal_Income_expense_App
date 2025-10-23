import 'package:get/get.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/core/services/network_caller.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';

// Models for API response parsing
class Summary {
  final double totalIncome;
  final double totalExpenses;
  final double savingAmount;
  final double savingPercentage;
  final Map<String, int> percentages;

  Summary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.savingAmount,
    required this.savingPercentage,
    required this.percentages,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalExpenses: (json['totalExpenses'] ?? 0).toDouble(),
      savingAmount: (json['savingAmount'] ?? 0).toDouble(),
      savingPercentage: (json['savingPercentage'] ?? 0).toDouble(),
      percentages: Map<String, int>.from(json['percentages'] ?? {}),
    );
  }
}

class TypeSummary {
  final String typeName;
  final double income;
  final double expenses;
  final double savingAmount;
  final Map<String, int> percentages;
  final double progress;

  TypeSummary({
    required this.typeName,
    required this.income,
    required this.expenses,
    required this.savingAmount,
    required this.percentages,
    required this.progress,
  });

  factory TypeSummary.fromJson(Map<String, dynamic> json) {
    final income = (json['Income'] ?? json['income'] ?? 0).toDouble();
    final expenses = (json['Expenses'] ?? json['expenses'] ?? 0).toDouble();
    final total = income + expenses;
    final progress = total > 0 ? (expenses / total) : 0.0;

    return TypeSummary(
      typeName: json['typeName'] ?? '',
      income: income,
      expenses: expenses,
      savingAmount: (json['savingAmount'] ?? 0).toDouble(),
      percentages: Map<String, int>.from(json['percentages'] ?? {}),
      progress: progress,
    );
  }
}

// Model for monthly breakdown in yearly view
class MonthlyBreakdown {
  final String month;
  final int monthNumber;
  final double income;
  final double expenses;
  final double saving;
  final Map<String, int> percentages;

  MonthlyBreakdown({
    required this.month,
    required this.monthNumber,
    required this.income,
    required this.expenses,
    required this.saving,
    required this.percentages,
  });

  factory MonthlyBreakdown.fromJson(Map<String, dynamic> json) {
    return MonthlyBreakdown(
      month: json['month'] ?? '',
      monthNumber: json['monthNumber'] ?? 0,
      income: (json['income'] ?? 0).toDouble(),
      expenses: (json['expenses'] ?? 0).toDouble(),
      saving: (json['saving'] ?? 0).toDouble(),
      percentages: Map<String, int>.from(json['percentages'] ?? {}),
    );
  }
}

class BarChartController extends GetxController {
  final NetworkCaller _networkCaller = NetworkCaller();

  // Observable properties
  final RxBool isLoading = false.obs;
  final RxString viewType = 'monthly'.obs;
  final RxString period = ''.obs;
  final RxInt year = DateTime.now().year.obs;
  final RxString month = ''.obs;
  final RxString currency = 'US\$'.obs;
  final Rxn<Summary> summary = Rxn<Summary>();
  final RxList<TypeSummary> typesSummary = <TypeSummary>[].obs;
  final RxList<MonthlyBreakdown> monthlyBreakdown = <MonthlyBreakdown>[].obs;
  final RxList<String> availableMonths = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with current date
    final now = DateTime.now();
    year.value = now.year;
    month.value = _getMonthName(now.month);

    // Check if storage is initialized and set test token if needed
    _initializeTokenAndFetch();
  }

  Future<void> _initializeTokenAndFetch() async {
    try {
      // Initialize storage if not already done
      await StorageService.init();

      // Get token from AuthService (where login saves it)
      final String? token = await AuthService.getApprovalToken();
      if (token != null && token.isNotEmpty) {
        // Save to StorageService for consistency with other controllers
        final String? userId = await AuthService.getUserId();
        await StorageService.saveToken(token, userId ?? '');

        fetchAnalytics();
      }
    // ignore: empty_catches
    } catch (e) {
    }
  }

  String _getMonthName(int monthNumber) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[monthNumber];
  }

  Future<void> fetchAnalytics({
    String? viewType,
    int? year,
    String? month,
  }) async {
    try {
      isLoading.value = true;

      // Get token from AuthService first, fallback to StorageService
      String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        token = StorageService.token;
      }

      if (token == null || token.isEmpty) {
        isLoading.value = false;
        return;
      }

      // Use provided params or current state
      final requestViewType = viewType ?? this.viewType.value;
      final requestYear = year ?? this.year.value;
      final requestMonth = month ?? this.month.value;

      final body = <String, dynamic>{
        'viewType': requestViewType,
        'year': requestYear,
      };

      // Add month only for monthly view
      if (requestViewType == 'monthly' && requestMonth.isNotEmpty) {
        body['month'] = requestMonth;
      }


      // Use raw token as provided (your Postman example shows no Bearer prefix)
      final response = await _networkCaller.postRequest(
        Urls.monthlyyearlyBarChart,
        body: body,
        token: token,
      );


      if (response.isSuccess && response.responseData != null) {
        final data = response.responseData['data'];
        if (data != null) {
          if (data['typesSummary'] != null) {
          }
          _parseApiResponse(data);
        } else {
        }
      } else {
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
    } finally {
      isLoading.value = false;
    }
  }

  void _parseApiResponse(Map<String, dynamic> data) {

    // Parse basic info
    viewType.value = data['viewType'] ?? 'monthly';
    period.value = data['period'] ?? '';
    currency.value = data['currency'] ?? 'US\$';


    // Parse summary
    if (data['summary'] != null) {
      summary.value = Summary.fromJson(data['summary']);
    } else {
    }

    // Parse types summary based on view type
    if (data['viewType'] == 'yearly') {
      // Parse monthlyBreakdown for yearly view
      if (data['monthlyBreakdown'] != null &&
          data['monthlyBreakdown'] is List) {
        final List<dynamic> monthlyData = data['monthlyBreakdown'];
        final parsedMonthly = monthlyData
            .map((item) => MonthlyBreakdown.fromJson(item))
            .where(
              (item) => item.expenses > 0 || item.income > 0,
            ) // Only show months with data
            .toList();

        // Sort by highest value (income or expenses) descending
        parsedMonthly.sort((a, b) {
          final aValue = a.income > a.expenses ? a.income : a.expenses;
          final bValue = b.income > b.expenses ? b.income : b.expenses;
          return bValue.compareTo(aValue); // Descending order
        });

        monthlyBreakdown.value = parsedMonthly;
      }

      // For yearly view, parse expenseCategoryBreakdown and incomeCategoryBreakdown
      final List<TypeSummary> tempList = [];

      // Parse expense categories
      if (data['expenseCategoryBreakdown'] != null &&
          data['expenseCategoryBreakdown'] is List) {
        final List<dynamic> expenseData = data['expenseCategoryBreakdown'];
        for (var item in expenseData) {
          final amount = (item['amount'] ?? 0).toDouble();
          final percentage = (item['percentage'] ?? 0).toInt();
          tempList.add(
            TypeSummary(
              typeName: item['typeName'] ?? '',
              income: 0,
              expenses: amount,
              savingAmount: 0,
              percentages: {'expense': percentage},
              progress: percentage / 100,
            ),
          );
        }
      }

      // Parse income categories
      if (data['incomeCategoryBreakdown'] != null &&
          data['incomeCategoryBreakdown'] is List) {
        final List<dynamic> incomeData = data['incomeCategoryBreakdown'];
        for (var item in incomeData) {
          final amount = (item['amount'] ?? 0).toDouble();
          final percentage = (item['percentage'] ?? 0).toInt();
          tempList.add(
            TypeSummary(
              typeName: item['typeName'] ?? '',
              income: amount,
              expenses: 0,
              savingAmount: 0,
              percentages: {'income': percentage},
              progress: percentage / 100,
            ),
          );
        }
      }

      // Sort categories by highest value (income or expenses) descending
      tempList.sort((a, b) {
        final aValue = a.income > a.expenses ? a.income : a.expenses;
        final bValue = b.income > b.expenses ? b.income : b.expenses;
        return bValue.compareTo(aValue); // Descending order
      });

      typesSummary.value = tempList;
    } else {
      // For monthly view, parse typesSummary as before
      if (data['typesSummary'] != null && data['typesSummary'] is List) {
        final List<dynamic> typesData = data['typesSummary'];
        final parsedTypes = typesData
            .map((item) => TypeSummary.fromJson(item))
            .toList();

        // Sort by highest value (income or expenses) descending
        parsedTypes.sort((a, b) {
          final aValue = a.income > a.expenses ? a.income : a.expenses;
          final bValue = b.income > b.expenses ? b.income : b.expenses;
          return bValue.compareTo(aValue); // Descending order
        });

        typesSummary.value = parsedTypes;
        // ignore: unused_local_variable
        for (var type in typesSummary) {
        }
      } else {
        typesSummary.clear();
      }
    }

    // Parse available months
    if (data['availableMonths'] != null && data['availableMonths'] is List) {
      availableMonths.value = List<String>.from(data['availableMonths']);
    }

    // Update navigation info
    if (data['navigation'] != null) {
      final nav = data['navigation'];
      if (nav['currentYear'] != null) {
        year.value = nav['currentYear'];
      }
      if (nav['currentMonth'] != null) {
        month.value = nav['currentMonth'];
      }
    }

  }

  // Helper methods for UI
  void setMonthlyView() {
    // Clear existing data when switching views
    typesSummary.clear();
    monthlyBreakdown.clear();
    summary.value = null;

    viewType.value = 'monthly';
    fetchAnalytics();
  }

  void setYearlyView() {
    // Clear existing data when switching views
    typesSummary.clear();
    monthlyBreakdown.clear();
    summary.value = null;

    viewType.value = 'yearly';
    // For yearly view, ensure we don't pass month parameter
    fetchAnalytics(viewType: 'yearly', year: year.value);
  }

  void setYearAndMonth(int newYear, [String? newMonth]) {
    // Clear existing data when parameters change
    typesSummary.clear();
    monthlyBreakdown.clear();
    summary.value = null;

    year.value = newYear;
    if (newMonth != null) {
      month.value = newMonth;
    }

    fetchAnalytics();
  }
}
