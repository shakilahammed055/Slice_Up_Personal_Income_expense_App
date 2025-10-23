// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/home_screen/controller/home_screen_controller.dart';
import 'package:uuid/uuid.dart'; // Add uuid package for unique IDs
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ExpenseType {
  final String id;
  final String name;

  ExpenseType({required this.id, required this.name});
}

class ExpenseEntry {
  final String id; // Added unique ID
  final double amount;
  final String
  date; // Format: 'dd/MM/yyyy' or repeat option like 'Every Friday'
  final String type;
  final String note;
  final bool isIncome;

  ExpenseEntry({
    String? id, // Allow passing an ID, or generate a new one
    required this.amount,
    required this.date,
    required this.type,
    required this.note,
    required this.isIncome,
  }) : id = id ?? Uuid().v4(); // Generate unique ID if not provided

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntry &&
          runtimeType == other.runtimeType &&
          id == other.id && // Compare by ID for uniqueness
          amount == other.amount &&
          date == other.date &&
          type == other.type &&
          note == other.note &&
          isIncome == other.isIncome;

  @override
  int get hashCode =>
      id.hashCode ^ // Use ID in hashCode
      amount.hashCode ^
      date.hashCode ^
      type.hashCode ^
      note.hashCode ^
      isIncome.hashCode;
}

class ExpenseController extends GetxController {
  var selectedTab = 'Expense'.obs;
  var amount = ''.obs;
  var selectedType = Rxn<ExpenseType>();
  var selectedDate = DateTime.now().obs;
  var isEditing = false.obs;
  var editingId = ''.obs;
  var repeatEvery = RxnInt();
  var repeatUnit = RxString('');
  var repeatStartDate = DateTime.now().obs;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final dateController = TextEditingController();
  final expenseTypes = <ExpenseType>[].obs;
  final incomeTypes = <ExpenseType>[].obs;
  final entries = <ExpenseEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(() {
      amount.value = amountController.text;
    });
    updateDateText(selectedDate.value);
    fetchExpenseTypes();
    fetchIncomeTypes();
  }

  ExpenseType? findTypeById(String id) {
    return [...expenseTypes, ...incomeTypes].firstWhereOrNull((t) => t.id == id);
  }

  String getRepeatDisplay(int every, String unit) {
    if (unit == 'week') {
      final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      return 'Every ${days[every]}'.tr;
    } else if (unit == 'month') {
      String suffix = every == 1 ? '1st' : '${every}nd';
      return 'Every $suffix of Month'.tr;
    }
    return '';
  }

  void setRepeatConfig(int every, String unit, DateTime startDate) {
    repeatEvery.value = every;
    repeatUnit.value = unit;
    repeatStartDate.value = startDate;
    dateController.text = getRepeatDisplay(every, unit);
  }

  void loadForEdit(Map<String, dynamic> trans) {
    final bool isInc = trans['transactionType'] == 'income';
    selectedTab.value = isInc ? 'Income'.tr : 'Expense'.tr;
    amountController.text = (trans['amount'] as num).toString();
    amount.value = amountController.text;
    final String typeId = trans['type_id'] as String;
    selectedType.value = findTypeById(typeId);
    noteController.text = trans['description'] ?? '';
    isEditing.value = true;
    editingId.value = trans['_id'] as String;

    if (trans['repeat'] != null) {
      final rep = trans['repeat'];
      repeatEvery.value = rep['every'];
      repeatUnit.value = rep['unit'];
      repeatStartDate.value = DateTime.parse(trans['date']);
      dateController.text = getRepeatDisplay(repeatEvery.value!, repeatUnit.value);
    } else {
      repeatEvery.value = null;
      repeatUnit.value = '';
      final DateTime date = DateTime.parse(trans['date']);
      updateDateText(date);
    }
  }

  Future<void> fetchExpenseTypes() async {
    try {
      final token = await AuthService.getApprovalToken();
      final response = await http.get(
        Uri.parse(
          Urls.getallcategory,
        ),
        headers: {'Authorization': token ?? ''},
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final dataList = jsonData['data'] as List;
          final filteredDataList = dataList
            .where((item) => 
                item['type'] == 'personal' && 
                item['transactionType'] == 'expense'
            )
            .toList();
          expenseTypes.value = filteredDataList
              .map(
                (item) => ExpenseType(
                  id: item['_id'] as String,
                  name: item['name'] as String,
                ),
              )
              .toList();
        }
      }
    } catch (e) {
      // Handle error silently or show snackbar if needed
      debugPrint('Error fetching expense types: $e');
    }
  }

  Future<void> fetchIncomeTypes() async {
  debugPrint('Entering fetchIncomeTypes function');
  try {
    debugPrint('Calling AuthService.getApprovalToken()');
    final token = await AuthService.getApprovalToken();
    debugPrint('Token retrieved: $token');
    
    final uri = Uri.parse(
      Urls.getallcategory,
    );
    debugPrint('URI parsed: $uri');
    
    final headers = {'Authorization': token ?? ''};
    debugPrint('Calling http.get with URI: $uri');
    
    final response = await http.get(uri, headers: headers);
    debugPrint('HTTP response statusCode: ${response.statusCode}');
    debugPrint('HTTP response body: ${response.body}');
    
    if (response.statusCode == 200) {
      debugPrint('Status is 200, proceeding to jsonDecode');
      final jsonData = jsonDecode(response.body);
      debugPrint('JSON decoded: $jsonData');
      
      if (jsonData['success'] == true) {
        debugPrint('Status is success, casting jsonData["data"] to List');
        final dataList = jsonData['data'] as List;
        debugPrint('Data list casted: $dataList');
        
        // ✅ UPDATED FILTER: Personal + Income types only
        debugPrint('Filtering dataList for type "personal" AND transactionType "income"');
        final filteredDataList = dataList
            .where((item) => 
                item['type'] == 'personal' && 
                item['transactionType'] == 'income'
            )
            .toList();
        debugPrint('Filtered data list (Personal Income): $filteredDataList');
        
        // Map to ExpenseType objects (keeping your existing mapping)
        debugPrint('Mapping filteredDataList to ExpenseType objects');
        final mappedList = filteredDataList.map((item) {
          debugPrint('Processing item: $item');
          final id = item['_id'] as String;
          final name = item['name'] as String;
          debugPrint('Creating ExpenseType(id: $id, name: $name)');
          return ExpenseType(id: id, name: name);
        }).toList();
        
        debugPrint('Mapped list: $mappedList');
        debugPrint('Assigning to incomeTypes.value');
        incomeTypes.value = mappedList;
        debugPrint('incomeTypes.value updated successfully');
        
      } else {
        debugPrint('jsonData["success"] is not true: ${jsonData['success']}');
      }
    } else {
      debugPrint('response.statusCode is not 200: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Exception caught in fetchIncomeTypes: $e');
    debugPrint('Error fetching income types: $e');
  }
  debugPrint('Exiting fetchIncomeTypes function');
}

  Future<bool> createCategory(bool isIncome, String categoryName) async {
    debugPrint(
      'createCategory called with isIncome: $isIncome, categoryName: $categoryName',
    );
    if (categoryName.isEmpty) {
      debugPrint('categoryName is empty, showing error');
      EasyLoading.showError('Category name cannot be empty.');
      debugPrint('Returning false due to empty categoryName');
      return false;
    }

    debugPrint('categoryName is not empty, proceeding to try block');
    try {
      debugPrint('Fetching token...');
      final token = await AuthService.getApprovalToken();
      debugPrint('Token fetched: ${token ?? 'null'}');
      final url = isIncome
          ? Urls.incomepersonal
          : Urls.addpersonalcategory;
      debugPrint('Selected URL: $url');
      debugPrint('Creating MultipartRequest...');
      var request = http.Request('POST', Uri.parse(url));
      request.headers['Authorization'] = token ?? '';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({'name': categoryName});
      debugPrint('Request body set: ${request.body}');

      debugPrint('Sending HTTP POST request with JSON body...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('HTTP response status code: ${response.statusCode}');
      debugPrint('HTTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Status code is 200 or 201, parsing JSON...');
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['success'] == true) {
          debugPrint('API status is success');
          debugPrint('Returning true');
          return true;
        } else {
          debugPrint('API status is not success: ${jsonData['status']}');
          final errorMsg = jsonData['message'] ?? 'Failed to create category.';
          debugPrint('Showing error: $errorMsg');
          EasyLoading.showError(errorMsg);
          debugPrint('Returning false due to API error');
          return false;
        }
      } else {
        debugPrint('Status code not 200 or 201: ${response.statusCode}');
        debugPrint('Showing generic error');
        EasyLoading.showError('Failed to create category. Please try again.');
        debugPrint('Returning false due to HTTP error');
        return false;
      }
    } catch (e) {
      debugPrint('Exception caught: $e');
      debugPrint('Error creating category: $e');
      debugPrint('Showing network error');
      EasyLoading.showError('Network error. Please check your connection.');
      debugPrint('Returning false due to exception');
      return false;
    }
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
    if (!isEditing.value) {
      clearForm();
    }
  }

  void setType(ExpenseType type) {
    selectedType.value = type;
  }

  void addCategory(String category, bool isIncome) {
    final newType = ExpenseType(
      id: Uuid().v4(),
      name: category,
    ); // Local ID for now
    if (category.isNotEmpty &&
        !(isIncome ? incomeTypes : expenseTypes).any(
          (t) => t.name == category,
        )) {
      (isIncome ? incomeTypes : expenseTypes).add(newType);
    }
  }

  Future<void> editCategory(String oldCategory, String newCategory, bool isIncome) async {
    final types = isIncome ? incomeTypes : expenseTypes;
    final index = types.indexWhere((t) => t.name == oldCategory);
    if (index == -1 ||
        newCategory.isEmpty ||
        types.any((t) => t.name == newCategory && t.id != types[index].id)) {
      throw Exception('Invalid category update');
    }

    try {
      final token = await AuthService.getApprovalToken();
      final url = '${Urls.updatecategory}${types[index].id}';
      var request = http.Request('PATCH', Uri.parse(url));
      request.headers['Authorization'] = token ?? '';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'name': newCategory,
        'type': 'personal',
      });
      debugPrint('PATCH request to: $url');
      debugPrint('Request body: ${request.body}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('HTTP response status code: ${response.statusCode}');
      debugPrint('HTTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['success'] == true || jsonData['status'] == 'success') {
          // Update local type
          types[index] = ExpenseType(id: types[index].id, name: newCategory);
          // Update selectedType if matching
          if (selectedType.value != null &&
              selectedType.value!.name == oldCategory) {
            selectedType.value = types[index];
          }
          // Update existing entries with the new category name
          for (var i = 0; i < entries.length; i++) {
            if (entries[i].type == oldCategory && entries[i].isIncome == isIncome) {
              entries[i] = ExpenseEntry(
                id: entries[i].id,
                amount: entries[i].amount,
                date: entries[i].date,
                type: newCategory,
                note: entries[i].note,
                isIncome: entries[i].isIncome,
              );
            }
          }
          entries.refresh();
          debugPrint('Category updated successfully locally');
          return;
        } else {
          final errorMsg = jsonData['message'] ?? 'Failed to update category';
          throw Exception(errorMsg);
        }
      } else {
        throw Exception('Failed to update category: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error editing category: $e');
      // Revert local changes if any (but since we update after success, no need)
      throw Exception('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String category, bool isIncome) async {
    final types = isIncome ? incomeTypes : expenseTypes;
    final typeToDelete = types.firstWhereOrNull((t) => t.name == category);
    if (typeToDelete == null) {
      throw Exception('Category not found');
    }

    try {
      final token = await AuthService.getApprovalToken();
      final url = '${Urls.deleteCategory}${typeToDelete.id}';
      debugPrint('DELETE request to: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': token ?? '',
        },
      );
      debugPrint('HTTP response status code: ${response.statusCode}');
      debugPrint('HTTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['success'] == true || jsonData['status'] == 'success') {
          // Refetch both lists to sync with backend
          await fetchExpenseTypes();
          await fetchIncomeTypes();
          // Update selectedType if matching
          if (selectedType.value != null && selectedType.value!.name == category) {
            selectedType.value = null;
          }
          // Remove existing entries with the deleted category
          entries.removeWhere(
            (entry) => entry.type == category && entry.isIncome == isIncome,
          );
          entries.refresh();
          debugPrint('Category deleted successfully');
          return;
        } else {
          final errorMsg = jsonData['message'] ?? 'Failed to delete category';
          throw Exception(errorMsg);
        }
      } else {
        throw Exception('Failed to delete category: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting category: $e');
      throw Exception('Error deleting category: $e');
    }
  }

  void updateDateText(DateTime date) {
    dateController.text = DateFormat('dd/MM/yyyy').format(date);
    selectedDate.value = date;
    repeatEvery.value = null;
    repeatUnit.value = '';
  }

  Future<void> _saveToBackend({
    required double amount,
    required String dateStr,
    required String note,
  }) async {
    debugPrint(
      'Entering _saveToBackend with amount: $amount, dateStr: $dateStr, note: $note',
    );
    try {
      debugPrint('Fetching token...');
      final token = await AuthService.getApprovalToken();
      debugPrint('Token fetched: ${token ?? 'null'}');
      final isIncome = selectedTab.value == 'Income'.tr;
      debugPrint('isIncome: $isIncome');
      final transactionType = isIncome ? 'income' : 'expense';
      debugPrint('transactionType: $transactionType');

      String apiDate;
      if (repeatEvery.value != null) {
        apiDate = DateFormat('yyyy-MM-dd').format(repeatStartDate.value);
      } else {
        // Parse and format date (assumes one-time date format; repeat options will fail parsing)
        debugPrint('Parsing date: $dateStr');
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
          debugPrint('Parsed date: $parsedDate');
        } catch (e) {
          debugPrint('Date parsing error: $e');
          throw Exception('Invalid date format. Please select a one-time date.');
        }
        apiDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
      debugPrint('Formatted API date: $apiDate');

      final typeId = selectedType.value!.id;
      debugPrint('typeId: $typeId');
      final description = note.isEmpty ? selectedType.value!.name : note;
      debugPrint('description: $description');

      final body = {
        "transactionType": transactionType,
        "date": apiDate,
        "amount": amount,
        "description": description,
        "type_id": typeId,
      };

      if (repeatEvery.value != null) {
        body['repeat'] = {
          "every": repeatEvery.value,
          "unit": repeatUnit.value,
        };
      }

      debugPrint('Request body: ${jsonEncode(body)}');

      
      final response = await http.post(
        Uri.parse(
          Urls.addincomeexpence,
        ),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Response code is 200 or 201, parsing JSON...');
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['status'] == 'success') {
          debugPrint('API status is success, adding to local entries');
          // Add to local entries on success
          entries.add(
            ExpenseEntry(
              amount: amount,
              date: dateStr,
              type: selectedType.value!.name,
              note: description,
              isIncome: isIncome,
            ),
          );
          Get.find<HomeController>().refreshIncomeAndExpenses();
          Get.back();
          debugPrint('Entry added to local list');
          return;
        } else {
          debugPrint('API status is not success: ${jsonData['status']}');
          throw Exception(jsonData['message'] ?? 'Failed to save entry');
        }
      } else {
        debugPrint('Status code not 200 or 201: ${response.statusCode}');
        throw Exception('Failed to save entry: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in _saveToBackend: $e');
      throw Exception('Error saving entry: $e');
    }
  }

  Future<void> updateEntry({
    required double amount,
    required String dateStr,
    required String note,
  }) async {
    try {
      debugPrint('Fetching token...');
      final token = await AuthService.getApprovalToken();
      debugPrint('Token fetched: ${token ?? 'null'}');

      String apiDate;
      if (repeatEvery.value != null) {
        apiDate = DateFormat('yyyy-MM-dd').format(repeatStartDate.value);
      } else {
        // Parse and format date (assumes one-time date format; repeat options will fail parsing)
        debugPrint('Parsing date: $dateStr');
        DateTime parsedDate;
        try {
          parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
          debugPrint('Parsed date: $parsedDate');
        } catch (e) {
          debugPrint('Date parsing error: $e');
          throw Exception('Invalid date format. Please select a one-time date.');
        }
        apiDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      }
      debugPrint('Formatted API date: $apiDate');

      final typeId = selectedType.value!.id;
      debugPrint('typeId: $typeId');
      final description = note;
      debugPrint('description: $description');

      final body = <String, dynamic>{};
      body['amount'] = amount;
      body['date'] = apiDate;
      body['description'] = description;
      body['type_id'] = typeId;

      if (repeatEvery.value != null) {
        body['repeat'] = {
          "every": repeatEvery.value,
          "unit": repeatUnit.value,
        };
      }

      debugPrint('Request body: ${jsonEncode(body)}');

      
      final response = await http.put(
        Uri.parse(
          '${Urls.updateincomeexpence}$editingId',
        ),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Response code is 200 or 201, parsing JSON...');
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['status'] == 'success') {
          debugPrint('API status is success');
          Get.find<HomeController>().refreshIncomeAndExpenses();
          Get.back();
          return;
        } else {
          debugPrint('API status is not success: ${jsonData['status']}');
          throw Exception(jsonData['message'] ?? 'Failed to update entry');
        }
      } else {
        debugPrint('Status code not 200 or 201: ${response.statusCode}');
        throw Exception('Failed to update entry: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in updateEntry: $e');
      throw Exception('Error updating entry: $e');
    }
  }

  Future<void> deleteCurrentEntry() async {
    final description = noteController.text;
    EasyLoading.show(status: 'Deleting...');
    try {
      final token = await AuthService.getApprovalToken();
      final response = await http.delete(
        Uri.parse(
          '${Urls.deleteincomeexpense}$editingId',
        ),
        headers: {
          'Authorization': token ?? '',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.find<HomeController>().refreshIncomeAndExpenses();
        Get.back();
        EasyLoading.showSuccess('Entry deleted successfully');
      } else {
        throw Exception('Failed to delete entry: ${response.statusCode}');
      }
    } catch (e) {
      EasyLoading.showError('Error deleting entry: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> saveEntry({
    required double amount,
    required String date,
    required String note,
  }) async {
    if (selectedType.value == null) {
      EasyLoading.showError('Please select a category.');
      return;
    }
    if (amount <= 0) {
      EasyLoading.showError('Amount must be greater than zero.');
      return;
    }
    try {
      if (isEditing.value) {
        await updateEntry(amount: amount, dateStr: date, note: note);
        EasyLoading.showSuccess('Entry updated successfully');
      } else {
        await _saveToBackend(amount: amount, dateStr: date, note: note);
        EasyLoading.showSuccess('${selectedTab.value} saved successfully');
      }
      clearForm();
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
  }

  Future<bool> deleteEntry(ExpenseEntry entry) async {
    // Show confirmation dialog
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    // Store the entry for potential undo
    final deletedEntry = entry;
    final deletedIndex = entries.indexOf(entry);

    // Remove the entry
    entries.remove(entry);
    entries.refresh(); // Notify listeners

    EasyLoading.showSuccess('Entry Deleted');

    debugPrint('Deleted entry: $entry, Remaining entries: ${entries.length}');
    return true;
  }

  Map<String, List<ExpenseEntry>> getEntriesByDate() {
    final Map<String, List<ExpenseEntry>> groupedEntries = {};
    for (var entry in entries) {
      if (!groupedEntries.containsKey(entry.date)) {
        groupedEntries[entry.date] = [];
      }
      groupedEntries[entry.date]!.add(entry);
    }
    // Sort entries by date for consistent display
    final sortedEntries = Map.fromEntries(
      groupedEntries.entries.toList()..sort((a, b) {
        try {
          final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
          final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
          return dateB.compareTo(dateA);
        } catch (e) {
          return a.key.compareTo(b.key);
        }
      }),
    );
    return sortedEntries;
  }

  double getTotalAmountForDate(String date) {
    return entries
        .where((entry) => entry.date == date)
        .fold(
          0.0,
          (sum, entry) => sum + (entry.isIncome ? entry.amount : -entry.amount),
        );
  }

  void clearForm() {
    amountController.clear();
    noteController.clear();
    selectedType.value = null;
    amount.value = '';
    selectedDate.value = DateTime.now();
    updateDateText(DateTime.now());
    isEditing.value = false;
    editingId.value = '';
    repeatEvery.value = null;
    repeatUnit.value = '';
  }
}