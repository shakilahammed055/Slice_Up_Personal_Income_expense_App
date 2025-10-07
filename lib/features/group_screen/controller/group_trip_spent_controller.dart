import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/expense_event_controller.dart';

class GroupTripSpentController extends GetxController {
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final isTotalAmountFocused = false.obs;
  final isNoteFocused = false.obs;
  final FocusNode totalAmountFocusNode = FocusNode();
  final RxString selectedCategoryName = ''.obs;
  final RxString selectedCategoryIcon = ''.obs;
  final RxBool isLoading = false.obs;

  // ----------------------------
  // ✅ API Integration Variables
  // ----------------------------
  final RxList<Map<String, dynamic>> groupMembers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMembers = false.obs;
  final RxString error = ''.obs;
  final RxString groupOwnerEmail = ''.obs;
  final RxString currentGroupId = ''.obs;
  final RxBool isInitialized = false.obs; // Add initialization flag

  // Constructor to accept group ID
  GroupTripSpentController({String? groupId}) {
    if (groupId != null && groupId.isNotEmpty) {
      currentGroupId.value = groupId;
      debugPrint(
        "🎯 GroupTripSpentController initialized with groupId: $groupId",
      );
    }
  }

  // ----------------------------
  // ✅ Group ID Management
  // ----------------------------

  // Method to set the group ID after controller initialization
  void setGroupId(String groupId) {
    if (groupId.isNotEmpty && currentGroupId.value != groupId) {
      // Only clear data if we're switching to a different group
      if (currentGroupId.value.isNotEmpty && currentGroupId.value != groupId) {
        clearAllTripData();
        debugPrint(
          "🔄 Switching from group ${currentGroupId.value} to $groupId - cleared data",
        );
      }

      currentGroupId.value = groupId;
      isInitialized.value = true;
      debugPrint("🔄 Updated groupId to: $groupId");

      // Only reload group members if we don't have them or group changed
      if (groupMembers.isEmpty) {
        getGroupMembers();
      }
    } else if (groupId.isNotEmpty && currentGroupId.value == groupId) {
      debugPrint("✅ Group ID already set to $groupId - no action needed");
    }
  } // Method to clear all trip-specific data

  void clearAllTripData() {
    debugPrint("🧹 Clearing all trip data for clean state");

    // Clear member data
    groupMembers.clear();
    groupOwnerEmail.value = '';
    error.value = '';

    // Clear form data
    totalAmountController.clear();
    noteController.clear();
    selectedCategoryName.value = '';
    selectedCategoryIcon.value = '';
    selectedType.value = '';
    selectedDate.value = DateTime.now();

    // Clear friend selections
    clearFriendSelections();

    // Clear loading states
    isLoading.value = false;
    isLoadingMembers.value = false;

    // Clear currency selection
    selectedCurrency.value = 'US\$';

    // Reset focus states
    isTotalAmountFocused.value = false;
    isNoteFocused.value = false;

    // Reset initialization flag
    isInitialized.value = false;

    debugPrint("✅ All trip data cleared successfully");
  }

  // Method to clear only user input (preserving group-specific data)
  void clearUserInput() {
    debugPrint("🧹 Clearing user input only");

    // Clear form data
    totalAmountController.clear();
    noteController.clear();
    selectedCategoryName.value = '';
    selectedCategoryIcon.value = '';
    selectedType.value = '';
    selectedDate.value = DateTime.now();

    // Clear friend selections
    clearFriendSelections();

    // Reset focus states
    isTotalAmountFocused.value = false;
    isNoteFocused.value = false;

    debugPrint("✅ User input cleared successfully");
  }

  // ----------------------------
  // ✅ Checkbox logic for Share with (Equally)
  // ----------------------------

  final RxMap<String, bool> friendCheckStates = <String, bool>{}.obs;

  // Use this new list to track selected friends
  final RxList<String> selectedSharedWithFriends = <String>[].obs;

  void toggleFriendCheckbox(String friendName) {
    // Toggle the state of the tapped checkbox
    friendCheckStates[friendName] = !(friendCheckStates[friendName] ?? false);

    // Update the list of selected friends based on the map
    if (friendCheckStates[friendName] == true) {
      selectedSharedWithFriends.add(friendName);
    } else {
      selectedSharedWithFriends.remove(friendName);
    }
  }

  bool isFriendChecked(String friendName) {
    return friendCheckStates[friendName] == true;
  }

  // ----------------------------
  // ✅ Equally / Custom toggle
  // ----------------------------
  final RxBool isEquallySelected = true.obs;

  String get currentPeriodUnit =>
      isEquallySelected.value ? 'Equally'.tr : 'Custom'.tr;

  void toggleEquallyCustom() {
    isEquallySelected.value = !isEquallySelected.value;
  }

  // ----------------------------
  // ✅ Individual / Minimize toggle
  // ----------------------------
  final RxBool isIndividualSelected = true.obs;

  String get currentSelectionUnit =>
      isIndividualSelected.value ? 'Individual'.tr : 'Minimize'.tr;

  void toggleIndividualMinimize() {
    isIndividualSelected.value = !isIndividualSelected.value;
  }

  // ----------------------------
  // ✅ Individual / Multiple toggle (reinstated for SlidingButtonIndivMul)
  // ----------------------------
  final RxBool isMultipleSelected = false.obs;

  String get currentSelectionUnitMultiple =>
      isMultipleSelected.value ? 'Individual'.tr : 'Multiple'.tr;

  void toggleIndividualMultiple() {
    isMultipleSelected.value = !isMultipleSelected.value;
  }

  // ----------------------------
  // ✅ Date selection
  // ----------------------------
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());

  void selectDate(DateTime? date) {
    selectedDate.value = date;
  }

  // ----------------------------
  // ✅ Currency
  // ----------------------------
  final RxString selectedCurrency = 'US\$'.obs;
  final List<String> currencyOptions = ['US\$', 'EUR€', 'JPY¥', 'KRW₩'];

  void setSelectedCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  // ----------------------------
  // ✅ Friend Selection
  // ----------------------------
  // For "Paid by" (single selection)
  final RxString selectedPaidByFriend = ''.obs;

  // For "Share with (Equally)" (single selection to match original UI)
  final RxString selectedSharedWithFriend = ''.obs;

  final RxList<String> friendNames = <String>[].obs;

  void setSelectedPaidByFriend(String friend) {
    // Allow toggling - if already selected, deselect it
    if (selectedPaidByFriend.value == friend) {
      selectedPaidByFriend.value = '';
      selectedSharedWithFriend.value = '';
    } else {
      selectedPaidByFriend.value = friend;
      selectedSharedWithFriend.value = friend;
    }
  }

  void setSelectedSharedWithFriend(String friend) {
    // Allow toggling - if already selected, deselect it
    if (selectedSharedWithFriend.value == friend) {
      selectedSharedWithFriend.value = '';
      friendCheckStates[friend] = false;
    } else {
      selectedSharedWithFriend.value = friend;
      // Update checkbox states to reflect single selection
      friendCheckStates.forEach((key, _) {
        friendCheckStates[key] = key == friend;
      });
    }
  }

  // ----------------------------
  // ✅ Amount Controllers (separated by page)
  // ----------------------------
  final RxMap<String, TextEditingController> equalFriendControllers =
      <String, TextEditingController>{}.obs;

  final RxMap<String, TextEditingController> customFriendControllers =
      <String, TextEditingController>{}.obs;

  final RxMap<String, TextEditingController> multipleFriendControllers =
      <String, TextEditingController>{}.obs;

  // Total per page
  final TextEditingController equalTotalController = TextEditingController();
  final TextEditingController customTotalController = TextEditingController();
  final TextEditingController multipleTotalController = TextEditingController();

  void onTotalAmountFocusChange(bool hasFocus) {
    isTotalAmountFocused.value = hasFocus;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint("🚀 GroupTripSpentController onInit called");

    // Ensure Individual is selected by default
    isMultipleSelected.value = false;

    // Add focus listener
    totalAmountFocusNode.addListener(() {
      isTotalAmountFocused.value = totalAmountFocusNode.hasFocus;
    });

    // Auto-focus after a delay
    Future.delayed(const Duration(milliseconds: 10), () {
      totalAmountFocusNode.requestFocus();
    });

    // Load group members ONLY if we have a valid group ID
    if (currentGroupId.value.isNotEmpty) {
      debugPrint(
        "🎯 Loading group members for groupId: ${currentGroupId.value}",
      );
      getGroupMembers();
    } else {
      debugPrint("⚠️ No group ID set - waiting for setGroupId() call");
      // Don't auto-fetch groups, wait for explicit group selection
    }

    // Fetch categories from API
    fetchGroupCategories();

    // Debug category state after initialization
    Future.delayed(const Duration(seconds: 2), () {
      debugCategoryState();
    });
  }

  void onNoteFocusChange(bool hasFocus) {
    isNoteFocused.value = hasFocus;
  }

  // Button text (per page if needed)
  final RxString buttonText = 'Save'.obs;

  // ----------------------------
  // ✅ Helpers
  // ----------------------------
  void initializeFriendControllerIfAbsent(
    String friendName,
    Map<String, TextEditingController> map,
  ) {
    if (!map.containsKey(friendName)) {
      map[friendName] = TextEditingController();
    }
  }

  void disposeFriendControllers() {
    equalFriendControllers.forEach((_, c) => c.dispose());
    customFriendControllers.forEach((_, c) => c.dispose());
    multipleFriendControllers.forEach((_, c) => c.dispose());

    equalTotalController.dispose();
    customTotalController.dispose();
    multipleTotalController.dispose();
  }

  void calculateAndSetTotalAmount(
    Map<String, TextEditingController> map,
    TextEditingController totalController,
  ) {
    int total = 0;
    map.forEach((name, controller) {
      if (isFriendChecked(name)) {
        final value = int.tryParse(controller.text) ?? 0;
        total += value;
      }
    });
    totalController.text = total.toString();
    buttonText.value = 'Next'.tr;
  }

  //category bottomsheet

  var selectedType = ''.obs;

  // Categories loaded from API - starts empty until API call completes
  final expenseTypes = <String>[].obs;

  // API-related variables for categories
  final RxBool isLoadingCategories = false.obs;
  final RxString categoryError = ''.obs;

  // Dynamic category mapping from API - replaces static categoryIdMap
  final RxMap<String, String> categoryIdMap = <String, String>{}.obs;

  void setType(String type) {
    selectedType.value = type;
  }

  // ----------------------------
  // ✅ API Methods for Categories
  // ----------------------------

  // Fetch all group categories from API
  Future<void> fetchGroupCategories() async {
    try {
      debugPrint('🔄 fetchGroupCategories called');
      isLoadingCategories.value = true;
      categoryError.value = '';

      // Clear categories first to show loading state
      expenseTypes.clear();
      categoryIdMap.clear();
      debugPrint('🧹 Cleared existing categories and mapping');

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found for fetchGroupCategories');
        categoryError.value = 'Authentication required';
        // Don't initialize default categories immediately - let user see the issue
        return;
      }

      debugPrint(
        '✅ Token found for fetchGroupCategories: ${token.substring(0, 20)}...',
      );

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      var request = http.Request('GET', Uri.parse(Urls.getallgroupcategory));
      request.headers.addAll(headers);

      debugPrint(
        '🌐 Making request to getallgroupcategory: ${Urls.getallgroupcategory}',
      );

      http.StreamedResponse response = await request.send();

      debugPrint(
        '📊 GetGroupCategories Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        debugPrint('📋 GetGroupCategories Raw Response: $responseBody');

        final responseData = json.decode(responseBody);
        debugPrint('🔍 GetGroupCategories Parsed Response: $responseData');

        // Check for both possible response formats
        bool isSuccess =
            responseData['status'] == 'success' ||
            responseData['success'] == true;
        var categoriesData = responseData['data'];

        if (isSuccess && categoriesData != null) {
          List<dynamic> categories = [];

          // Handle different response structures
          if (categoriesData is List) {
            categories = categoriesData;
          } else if (categoriesData is Map &&
              categoriesData['categories'] != null) {
            categories = categoriesData['categories'] as List<dynamic>;
          } else {
            debugPrint('⚠️ Unexpected data structure: $categoriesData');
            categories = [];
          }

          debugPrint('📂 Found ${categories.length} categories');

          // Clear existing categories and mapping
          expenseTypes.clear();
          categoryIdMap.clear();

          for (var category in categories) {
            if (category is Map<String, dynamic>) {
              final categoryName = category['name']?.toString() ?? '';
              final categoryId =
                  category['_id']?.toString() ??
                  category['id']?.toString() ??
                  '';

              if (categoryName.isNotEmpty && categoryId.isNotEmpty) {
                debugPrint('🔍 Debug - categoryName: "$categoryName"');
                debugPrint('🔍 Debug - categoryId: "$categoryId"');

                // Use the category name directly since emoji is already included
                String displayName = categoryName;

                debugPrint('🔍 Debug - final displayName: "$displayName"');

                expenseTypes.add(displayName);
                categoryIdMap[displayName] = categoryId;

                debugPrint('📂 Added category: $displayName (ID: $categoryId)');
              }
            }
          }

          debugPrint(
            '✅ Successfully loaded ${expenseTypes.length} categories from API',
          );
          debugPrint('🗂️ Category ID mapping: $categoryIdMap');
        } else {
          debugPrint('❌ API returned error or no data');
          categoryError.value =
              responseData['message'] ?? 'Failed to load categories';
          // Don't fall back to default categories - let user know there's an issue
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint(
          '❌ GetGroupCategories failed with status: ${response.statusCode}',
        );
        debugPrint('❌ GetGroupCategories error response: $responseBody');
        categoryError.value = 'Failed to fetch categories';
        // Don't fall back to default categories - let user know there's an issue
      }
    } catch (e) {
      debugPrint('❌ Exception in fetchGroupCategories: $e');
      categoryError.value = 'Error fetching categories: $e';
      // Only initialize default categories if it's a critical error
      debugPrint('⚠️ Initializing fallback categories due to exception');
      _initializeDefaultCategories();
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Initialize default categories as fallback
  void _initializeDefaultCategories() {
    debugPrint('🔄 Initializing default categories as fallback');

    // Clear existing data
    expenseTypes.clear();
    categoryIdMap.clear();

    // Add default categories (these will work locally but won't have valid IDs for API calls)
    final defaultCategories = [
      '🚗 Transport',
      '🍽️ Food',
      '🏠 Housing',
      '🛍️ Shopping',
      '🎉 Entertainment',
      '👕 Fashion',
      '💊 Clinic',
      '💄 Beauty',
    ];

    for (String category in defaultCategories) {
      expenseTypes.add(category);
      categoryIdMap[category] = 'default_category_id'; // Placeholder ID
    }

    debugPrint('⚠️ Initialized ${expenseTypes.length} default categories');
  }

  // Manual refresh method for debugging
  void refreshCategories() {
    debugPrint('🔄 Manual refresh categories called');
    fetchGroupCategories();
  }

  // Debug method to check current state
  void debugCategoryState() {
    debugPrint('📊 Category Debug State:');
    debugPrint('📦 expenseTypes count: ${expenseTypes.length}');
    debugPrint('📦 expenseTypes content: $expenseTypes');
    debugPrint('🗂️ categoryIdMap count: ${categoryIdMap.length}');
    debugPrint('🗂️ categoryIdMap content: $categoryIdMap');
    debugPrint('⏳ isLoadingCategories: ${isLoadingCategories.value}');
    debugPrint('❌ categoryError: ${categoryError.value}');
  }

  // Add new category to API
  Future<bool> addCategoryToAPI(String categoryName, {String icon = ''}) async {
    try {
      debugPrint('🔄 addCategoryToAPI called with: $categoryName');
      isLoadingCategories.value = true;
      categoryError.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found for addCategoryToAPI');
        categoryError.value = 'Authentication required';
        return false;
      }

      debugPrint(
        '✅ Token found for addCategoryToAPI: ${token.substring(0, 20)}...',
      );

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Prepare request body - send the full category name (with emoji) as the name
      final requestBody = {
        'name': categoryName, // This now contains the full string with emoji
        'icon': icon.isNotEmpty
            ? icon
            : '', // Empty icon since emoji is in the name
      };

      debugPrint('📤 Request body: $requestBody');
      debugPrint('🔍 Sending full categoryName: "$categoryName"');

      var request = http.Request('POST', Uri.parse(Urls.postallgroupcategory));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      debugPrint(
        '🌐 Making request to postallgroupcategory: ${Urls.postallgroupcategory}',
      );

      http.StreamedResponse response = await request.send();

      debugPrint('📊 AddGroupCategory Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        debugPrint('📋 AddGroupCategory Raw Response: $responseBody');

        final responseData = json.decode(responseBody);
        debugPrint('🔍 AddGroupCategory Parsed Response: $responseData');

        // Fix: Check for 'success' instead of 'status'
        if (responseData['success'] == true) {
          debugPrint('✅ Category added successfully to API');

          // Extract the new category data from response
          final categoryData = responseData['data']?['category'];
          if (categoryData != null) {
            final categoryName = categoryData['name']?.toString() ?? '';
            final categoryId = categoryData['_id']?.toString() ?? '';

            debugPrint('📂 New category: $categoryName (ID: $categoryId)');

            // Add to local lists immediately for better UX
            if (categoryName.isNotEmpty && categoryId.isNotEmpty) {
              expenseTypes.add(categoryName);
              categoryIdMap[categoryName] = categoryId;
              debugPrint('✅ Added new category to local lists');
            }
          }

          // Refresh the categories list and mapping from API
          await fetchGroupCategories();

          return true;
        } else {
          debugPrint('❌ API returned error for addCategory');
          categoryError.value =
              responseData['message'] ?? 'Failed to add category';
          return false;
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint(
          '❌ AddGroupCategory failed with status: ${response.statusCode}',
        );
        debugPrint('❌ AddGroupCategory error response: $responseBody');
        categoryError.value = 'Failed to add category';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception in addCategoryToAPI: $e');
      categoryError.value = 'Error adding category: $e';
      return false;
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Local methods for backward compatibility
  void addCategory(String category) async {
    debugPrint('🔍 addCategory called with: "$category"');

    if (category.isNotEmpty && !expenseTypes.contains(category)) {
      // Instead of separating emoji and name, send the full category string
      // This ensures the emoji is preserved as part of the category name

      // Try to add to API first with the full category string
      bool apiSuccess = await addCategoryToAPI(category, icon: '');

      if (!apiSuccess) {
        // If API fails, add locally as fallback
        expenseTypes.add(category);
        debugPrint('⚠️ Added category locally as API fallback');
      }
    }
  }

  void editCategory(String oldCategory, String newCategory) {
    final index = expenseTypes.indexOf(oldCategory);
    if (index != -1 &&
        newCategory.isNotEmpty &&
        !expenseTypes.contains(newCategory)) {
      expenseTypes[index] = newCategory;
      if (selectedType.value == oldCategory) {
        selectedType.value = newCategory;
      }

      debugPrint('📝 Category edited locally: $oldCategory -> $newCategory');
    }
  }

  void deleteCategory(String category) {
    expenseTypes.remove(category);
    if (selectedType.value == category) {
      selectedType.value = '';
    }

    debugPrint('🗑️ Category deleted locally: $category');
  }

  // ----------------------------
  // ✅ API Integration for Adding Group Expense
  // ----------------------------

  Future<void> addGroupExpense() async {
    try {
      isLoading.value = true;

      // Enhanced validation
      if (totalAmountController.text.isEmpty) {
        Get.snackbar('Error', 'Please enter total amount');
        return;
      }

      double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
      if (totalAmount <= 0) {
        Get.snackbar('Error', 'Please enter a valid amount greater than 0');
        return;
      }

      if (selectedCategoryName.value.isEmpty) {
        Get.snackbar('Error', 'Please select a category');
        return;
      }

      // Ensure we have group ID
      if (currentGroupId.value.isEmpty) {
        await getGroupMembers();
        if (currentGroupId.value.isEmpty) {
          Get.snackbar(
            'Error',
            'Group information not available. Please try again.',
          );
          return;
        }
      }

      // Debug sharing type detection

      // Check if we should force equal sharing (if custom has no amounts)
      bool hasCustomAmounts = false;
      customFriendControllers.forEach((name, controller) {
        if (controller.text.isNotEmpty &&
            (double.tryParse(controller.text) ?? 0) > 0) {
          hasCustomAmounts = true;
        }
      });

      // If user selected custom but has no custom amounts, force to equal
      if (!isEquallySelected.value && !hasCustomAmounts) {
        isEquallySelected.value = true;
      }

      // For custom sharing, validate that amounts are entered
      if (!isEquallySelected.value) {
        if (!hasCustomAmounts) {
          Get.snackbar('Error', 'Please enter amounts for custom sharing');
          return;
        }
        customFriendControllers.forEach((name, controller) {
          if (controller.text.isNotEmpty &&
              (double.tryParse(controller.text) ?? 0) > 0) {}
        });
      } else {
        // For equal sharing, ensure we have selected friends
        if (selectedSharedWithFriends.isEmpty) {
          // Auto-select all members if none selected
          selectedSharedWithFriends.clear();
          selectedSharedWithFriends.addAll(friendNames);
        }
      }

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      // Debug log

      // Prepare request headers - based on your original API example
      var headers = {
        'Authorization': token, // Direct token without Bearer prefix
        'Content-Type': 'application/json',
      };

      // Convert currency symbol to API format
      String currencyCode = 'USD'; // Default to USD
      if (selectedCurrency.value.contains('EUR') ||
          selectedCurrency.value.contains('€')) {
        currencyCode = 'EUR';
      } else if (selectedCurrency.value.contains('SGD') ||
          selectedCurrency.value.contains('S\$')) {
        currencyCode = 'SGD';
      } else if (selectedCurrency.value.contains('GBP') ||
          selectedCurrency.value.contains('£')) {
        currencyCode = 'GBP';
      } else if (selectedCurrency.value.contains('AUD') ||
          selectedCurrency.value.contains('A\$')) {
        currencyCode = 'AUD';
      } else if (selectedCurrency.value.contains('USD') ||
          selectedCurrency.value.contains('US\$') ||
          selectedCurrency.value.contains('\$')) {
        currencyCode = 'USD';
      }

      // Get category ID from dynamic mapping
      String? categoryId = categoryIdMap[selectedCategoryName.value];

      // If category ID not found in mapping, try to use selectedType as fallback
      if (categoryId == null || categoryId.isEmpty) {
        categoryId = categoryIdMap[selectedType.value];
      }

      // If still no category ID found, show error
      if (categoryId == null || categoryId.isEmpty) {
        Get.snackbar(
          'Error',
          'Category ID not found. Please select a valid category.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint(
        '📂 Using category ID: $categoryId for category: ${selectedCategoryName.value}',
      );

      // Get current user email for paidBy - use the group owner or first member
      String currentUserEmail = groupOwnerEmail.value.isNotEmpty
          ? groupOwnerEmail.value
          : (groupMembers.isNotEmpty
                ? groupMembers.first['email']
                : "unknown@email.com");

      // Determine paid by member email - for now use current user (can be enhanced later)
      String paidByMemberEmail = currentUserEmail;

      // Prepare request body based on sharing type
      Map<String, dynamic> requestBody;

      if (isEquallySelected.value) {
        // Equal sharing format - use actual member emails
        List<String> selectedMemberEmails = [];

        if (selectedSharedWithFriends.isNotEmpty) {
          // Convert selected friend names back to emails
          for (String selectedFriendName in selectedSharedWithFriends) {
            // Find the member with this name and get their email
            for (var member in groupMembers) {
              if (member['name'] == selectedFriendName) {
                String memberEmail = member['email'];
                if (!selectedMemberEmails.contains(memberEmail)) {
                  selectedMemberEmails.add(memberEmail);
                }
                break;
              }
            }
          }
        } else {
          // If no friends selected, include all members
          selectedMemberEmails = [currentUserEmail];
        }

        // Ensure current user is included
        if (!selectedMemberEmails.contains(currentUserEmail)) {
          selectedMemberEmails.insert(0, currentUserEmail);
        }

        requestBody = {
          "expenseDate":
              selectedDate.value?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          "totalExpenseAmount":
              double.tryParse(totalAmountController.text) ?? 0.0,
          "currency": currencyCode,
          "category": categoryId,
          "note": noteController.text.isEmpty ? "No note" : noteController.text,
          "paidBy": {
            "type": isIndividualSelected.value ? "individual" : "multiple",
            "memberEmail": paidByMemberEmail,
          },
          "shareWith": {"type": "equal", "members": selectedMemberEmails},
        };
      } else {
        // Custom sharing format - requires shares array with actual emails
        List<Map<String, dynamic>> shares = [];
        customFriendControllers.forEach((friendName, amountController) {
          if (amountController.text.isNotEmpty) {
            double amount = double.tryParse(amountController.text) ?? 0.0;
            if (amount > 0) {
              // Find the member email for this friend name
              String memberEmail = currentUserEmail; // default fallback
              for (var member in groupMembers) {
                if (member['name'] == friendName) {
                  memberEmail = member['email'];
                  break;
                }
              }

              shares.add({"memberEmail": memberEmail, "amount": amount});
            }
          }
        });

        // Ensure we have at least one share
        if (shares.isEmpty) {
          shares.add({
            "memberEmail": currentUserEmail,
            "amount": double.tryParse(totalAmountController.text) ?? 0.0,
          });
        }

        requestBody = {
          "expenseDate":
              selectedDate.value?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          "totalExpenseAmount":
              double.tryParse(totalAmountController.text) ?? 0.0,
          "currency": currencyCode,
          "category": categoryId,
          "note": noteController.text.isEmpty ? "No note" : noteController.text,
          "paidBy": {
            "type": isIndividualSelected.value ? "individual" : "multiple",
            "memberEmail": paidByMemberEmail,
          },
          "shareWith": {"type": "custom", "shares": shares},
        };
      }

      // Debug log the request body

      // Validate that we have valid member emails
      if (isEquallySelected.value) {
        final selectedMemberEmails =
            requestBody['shareWith']['members'] as List<String>;

        // Ensure all emails are valid (not duplicates or placeholders)
        final uniqueEmails = selectedMemberEmails.toSet().toList();
        if (uniqueEmails.length != selectedMemberEmails.length) {}
      } else {
        // ignore: unused_local_variable
        final shares =
            requestBody['shareWith']['shares'] as List<Map<String, dynamic>>;
      }

      // Make API request
      var request = http.Request(
        'POST',
        Uri.parse(Urls.addGroupExpense(currentGroupId.value)),
      );
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      // Debug response
      String responseString = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var responseData = json.decode(responseString);

        Get.snackbar(
          'Success',
          responseData['message'] ?? 'Group expense added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Clear form after successful submission
        clearForm();

        // Notify other controllers that expenses have been updated using event system
        try {
          final eventController = Get.find<ExpenseEventController>();
          eventController.notifyExpenseUpdated(currentGroupId.value);
        } catch (e) {
          debugPrint(
            "⚠️ [EXPENSE_SAVED] Event controller not found, using direct refresh: $e",
          );
        }

        // Also try direct controller refresh as backup
        try {
          final expensesController = Get.find<ExpensesPageController>(
            tag: currentGroupId.value,
          );
          debugPrint(
            "🔄 [EXPENSE_SAVED] Refreshing expenses for group: ${currentGroupId.value}",
          );
          expensesController.refreshExpenses();
        } catch (e) {
          debugPrint("⚠️ [EXPENSE_SAVED] Expenses controller not found: $e");
          // This is normal if the expenses page isn't currently visible
        }

        // Navigate to GroupTripHomeScreen after successful expense addition
        Future.delayed(Duration(seconds: 1), () {
          // Create a Trip object - you might want to get actual trip data from API
          final trip = Trip(
            id: currentGroupId.value,
            name:
                'Group Trip', // You can get actual group name from groupInfo or API
            date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          );

          // Navigate to GroupTripHomeScreen but keep navigation stack
          Get.off(() => GroupTripHomeScreen(trip: trip));
        });
      } else {
        // Show detailed error message
        try {
          var errorData = json.decode(responseString);
          Get.snackbar(
            'Error',
            'Failed to add expense: ${errorData['message'] ?? response.reasonPhrase}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to add expense. Status: ${response.statusCode}, Error: $responseString',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      // Debug log
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------
  // ✅ API Methods for Group Members
  // ----------------------------

  // Get user's groups and set the first one as current group if none is set
  Future<void> getUserGroupsAndSetFirst() async {
    try {
      debugPrint('🔄 getUserGroupsAndSetFirst called');

      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found for getUserGroupsAndSetFirst');
        error.value = 'Authentication required';
        return;
      }

      debugPrint(
        '✅ Token found for getUserGroupsAndSetFirst: ${token.substring(0, 20)}...',
      );

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      var request = http.Request('GET', Uri.parse(Urls.getGroups));
      request.headers.addAll(headers);

      debugPrint('🌐 Making request to getGroups: ${Urls.getGroups}');
      debugPrint('🔑 Request headers: $headers');

      http.StreamedResponse response = await request.send();

      debugPrint('📊 GetGroups Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        debugPrint('📋 GetGroups Raw Response: $responseBody');

        final responseData = json.decode(responseBody);
        debugPrint('🔍 GetGroups Parsed Response: $responseData');

        if (responseData['data'] != null &&
            responseData['data']['groups'] != null) {
          final List<dynamic> groups = responseData['data']['groups'];
          debugPrint('👥 Found ${groups.length} groups');

          if (groups.isNotEmpty) {
            // Use the first group as the current group
            final firstGroup = groups.first;
            debugPrint('📦 First group data: $firstGroup');

            final groupId =
                firstGroup['groupId'] ?? firstGroup['id'] ?? firstGroup['_id'];
            debugPrint('🆔 Extracted groupId: $groupId');

            if (groupId != null) {
              currentGroupId.value = groupId.toString();
              debugPrint('✅ Set currentGroupId to: ${currentGroupId.value}');
              debugPrint('🔍 GroupId type: ${groupId.runtimeType}');
              debugPrint('🔍 GroupId toString(): ${groupId.toString()}');

              // Now fetch group members for this group
              await getGroupMembers();
              return;
            } else {
              debugPrint('❌ No valid groupId found in first group');
            }
          } else {
            debugPrint('❌ Groups array is empty');
          }
        } else {
          debugPrint('❌ No data.groups found in response');
          debugPrint('🔍 Response structure: ${responseData.keys.toList()}');

          // Try alternative structure in case API format is different
          if (responseData['data'] is List) {
            final List<dynamic> groups = responseData['data'] as List<dynamic>;
            debugPrint(
              '👥 Found ${groups.length} groups in alternative structure',
            );

            if (groups.isNotEmpty) {
              final firstGroup = groups.first;
              final groupId =
                  firstGroup['_id'] ??
                  firstGroup['id'] ??
                  firstGroup['groupId'];

              if (groupId != null) {
                currentGroupId.value = groupId.toString();
                debugPrint('✅ Set currentGroupId to: ${currentGroupId.value}');
                await getGroupMembers();
                return;
              }
            }
          }
        }

        error.value = 'No groups found. Please create a group first.';
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint('❌ GetGroups failed with status: ${response.statusCode}');
        debugPrint('❌ GetGroups error response: $responseBody');
        error.value = 'Failed to fetch user groups';
      }
    } catch (e) {
      debugPrint('❌ Exception in getUserGroupsAndSetFirst: $e');
      debugPrint('❌ Exception stack trace: ${StackTrace.current}');
      error.value = 'Error fetching user groups: $e';
    }
  }

  // Get group members using the POST API
  Future<void> getGroupMembers() async {
    try {
      debugPrint(
        '🎯 getGroupMembers called - currentGroupId: "${currentGroupId.value}"',
      );
      debugPrint(
        '🔍 currentGroupId.value type: ${currentGroupId.value.runtimeType}',
      );
      debugPrint(
        '🔍 currentGroupId.value length: ${currentGroupId.value.length}',
      );

      isLoadingMembers.value = true;
      error.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No authentication token found');
        error.value = 'Authentication required';
        return;
      }

      debugPrint('✅ Token found: ${token.substring(0, 20)}...');

      // Check if we have a valid group ID
      if (currentGroupId.value.isEmpty) {
        debugPrint('❌ Empty group ID, cannot fetch members without a group');
        error.value = 'No group selected. Please select a group first.';
        return;
      }

      String groupId = currentGroupId.value;
      debugPrint('📍 Using groupId: $groupId');

      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Make API request to getGroupMembers with dynamic group ID
      String finalUrl = Urls.getGroupMembers(groupId);
      debugPrint('🌐 Final URL being used: $finalUrl');
      debugPrint('🔍 Raw groupId parameter: "$groupId"');
      debugPrint('🔍 currentGroupId.value: "${currentGroupId.value}"');

      var request = http.Request('GET', Uri.parse(finalUrl));

      request.headers.addAll(headers);

      debugPrint('🌐 Making request to: ${Urls.getGroupMembers(groupId)}');
      debugPrint('🔑 Headers: $headers');

      http.StreamedResponse response = await request.send();

      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        debugPrint('📋 Raw Response Data: $responseString');

        final responseData =
            json.decode(responseString) as Map<String, dynamic>;
        debugPrint('🔍 Parsed Response Data: $responseData');
        debugPrint('🔍 Response Data keys: ${responseData.keys.toList()}');

        if (responseData['status'] == 'success') {
          final data = responseData['data'] as Map<String, dynamic>? ?? {};
          debugPrint('📦 Data section: $data');
          debugPrint('📦 Data keys: ${data.keys.toList()}');

          // Extract group information from the actual API structure
          final groupId = data['groupId']?.toString() ?? '';
          final groupName = data['groupName']?.toString() ?? '';
          final totalMembers = data['totalMembers'] ?? 0;

          // Extract owner information from the actual API structure
          final ownerData = data['owner'] as Map<String, dynamic>? ?? {};
          final ownerEmail = ownerData['email']?.toString() ?? '';

          debugPrint('🆔 Group ID: $groupId');
          debugPrint('📛 Group name: $groupName');
          debugPrint('👥 Total members: $totalMembers');
          debugPrint('👤 Owner email: $ownerEmail');

          // Store group information
          if (groupId.isNotEmpty) {
            currentGroupId.value = groupId;
          }
          groupOwnerEmail.value = ownerEmail;

          // Handle members safely - it should be a list
          List<dynamic> members = [];
          if (data['members'] != null) {
            if (data['members'] is List) {
              members = data['members'] as List<dynamic>;
            } else {
              debugPrint(
                '⚠️ Warning: members is not a List, it is: ${data['members'].runtimeType}',
              );
              debugPrint('⚠️ Members data: ${data['members']}');
            }
          } else {
            debugPrint('⚠️ Warning: members is null in API response');
          }

          debugPrint('👥 Members: $members');

          // Extract member information from the actual API response structure
          Set<String> memberEmails = {};
          List<Map<String, dynamic>> processedMembers = [];

          debugPrint('🔄 Processing members from API response...');

          // Process members from the API response
          for (var member in members) {
            if (member is Map) {
              final memberMap = Map<String, dynamic>.from(member);
              final email = memberMap['email']?.toString() ?? '';
              final isOwner = memberMap['isOwner'] ?? false;

              if (email.isNotEmpty) {
                memberEmails.add(email);

                processedMembers.add({
                  'email': email,
                  'name': _extractNameFromEmail(email),
                  'id': email, // Using email as ID for now
                  'isOwner': isOwner,
                  'role': isOwner ? 'owner' : 'member',
                  'balance': {}, // Not provided in this API response
                });

                debugPrint(
                  '👤 Processed member: $email (${_extractNameFromEmail(email)}) - Owner: $isOwner',
                );
              }
            }
          }

          // Sort so owner appears first
          processedMembers.sort((a, b) {
            if (a['isOwner'] == true) return -1;
            if (b['isOwner'] == true) return 1;
            return (a['email'] as String).compareTo(b['email'] as String);
          });

          debugPrint(
            '📊 Total unique member emails found: ${memberEmails.length}',
          );
          debugPrint('👥 Processed members: ${processedMembers.length}');

          groupMembers.value = processedMembers;
          debugPrint(
            '✅ Loaded ${processedMembers.length} group members: ${processedMembers.map((m) => m['name']).join(', ')}',
          );
          // ignore: unnecessary_brace_in_string_interps
          debugPrint('🏆 Group owner: ${ownerEmail}');

          // Update friend names list for backward compatibility (owner first)
          friendNames.clear();
          friendNames.addAll(processedMembers.map((m) => m['name'] as String));

          // Initialize all checkboxes as unchecked (deselected by default)
          friendCheckStates.clear();
          for (String friendName in friendNames) {
            friendCheckStates[friendName] = false;
          }

          // Start with no selections
          selectedPaidByFriend.value = '';
          selectedSharedWithFriend.value = '';
          debugPrint('🎯 All members initialized as deselected');

          // Initialize text controllers for each member
          for (var member in processedMembers) {
            final memberName = member['name'] as String;
            initializeFriendControllerIfAbsent(
              memberName,
              multipleFriendControllers,
            );
            initializeFriendControllerIfAbsent(
              memberName,
              equalFriendControllers,
            );
            initializeFriendControllerIfAbsent(
              memberName,
              customFriendControllers,
            );
          }
        } else {
          error.value =
              responseData['message'] ?? 'Failed to load group members';
          debugPrint('❌ API returned success: false');
          debugPrint('❌ Error message: ${error.value}');
        }
      } else {
        error.value =
            'Failed to load group members. Status: ${response.statusCode}';
        debugPrint('❌ Request failed with status: ${response.statusCode}');
        final responseString = await response.stream.bytesToString();
        debugPrint('❌ Response body: $responseString');
      }
    } catch (e) {
      error.value = 'Error loading group members: $e';
      debugPrint('❌ Exception in getGroupMembers: $e');
      debugPrint('❌ Exception stack trace: ${StackTrace.current}');
    } finally {
      isLoadingMembers.value = false;
    }
  }

  // Helper method to extract name from email
  String _extractNameFromEmail(String email) {
    if (email.contains('@')) {
      String username = email.split('@')[0];

      // Handle emails with dots (like rezwanrahim.rupak)
      if (username.contains('.')) {
        List<String> parts = username.split('.');
        // Take first name + last initial or first 2 parts
        if (parts.length >= 2) {
          String firstName = parts[0];
          String lastName = parts[1];
          // If names are too similar, include more of the last name
          if (firstName.length >= 8) {
            return '${firstName.substring(0, 7)}${lastName[0].toUpperCase()}';
          } else {
            return '${firstName[0].toUpperCase()}${firstName.substring(1)} ${lastName[0].toUpperCase()}';
          }
        }
      }

      // Handle emails with numbers (like rezwanrahim31)
      if (username.contains(RegExp(r'\d'))) {
        // Extract the numeric part to differentiate
        String numbers = username.replaceAll(RegExp(r'[^0-9]'), '');
        String letters = username.replaceAll(RegExp(r'[0-9]'), '');
        if (letters.length >= 6 && numbers.isNotEmpty) {
          // ignore: unnecessary_brace_in_string_interps
          return '${letters.substring(0, 6)}${numbers}';
        }
      }

      // Default: capitalize first letter of each word
      return username
          .replaceAll('.', ' ')
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '',
          )
          .join(' ');
    }
    return email;
  }

  // Helper method to get current logged-in user ID
  Future<String?> getCurrentUserId() async {
    try {
      return await AuthService.getUserId();
    } catch (e) {
      debugPrint('❌ Error getting current user ID: $e');
      return null;
    }
  }

  // Helper method to get current logged-in user email
  Future<String?> getCurrentUserEmail() async {
    try {
      return await AuthService.getUserEmail();
    } catch (e) {
      debugPrint('❌ Error getting current user email: $e');
      return null;
    }
  }

  // Post API to save expense with selected members
  Future<void> saveExpenseWithMembers() async {
    try {
      isLoading.value = true;
      error.value = '';

      // Validate inputs
      if (totalAmountController.text.isEmpty) {
        Get.snackbar('Error', 'Please enter total amount');
        return;
      }

      if (selectedPaidByFriend.value.isEmpty) {
        Get.snackbar('Error', 'Please select who paid');
        return;
      }

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authentication required');
        return;
      }

      // Find the email for the selected paid by friend
      String? paidByEmail;
      for (var member in groupMembers) {
        if (member['name'] == selectedPaidByFriend.value) {
          paidByEmail = member['email'];
          break;
        }
      }

      if (paidByEmail == null) {
        Get.snackbar('Error', 'Selected payer not found');
        return;
      }

      // Prepare share with members
      List<String> shareWithEmails = [];
      if (isMultipleSelected.value) {
        // Multiple selection - get emails from selected friends
        for (String friendName in selectedSharedWithFriends) {
          for (var member in groupMembers) {
            if (member['name'] == friendName) {
              shareWithEmails.add(member['email']);
              break;
            }
          }
        }
      } else {
        // Individual selection - use the selected friend
        for (var member in groupMembers) {
          if (member['name'] == selectedSharedWithFriend.value) {
            shareWithEmails.add(member['email']);
            break;
          }
        }
      }

      if (shareWithEmails.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select at least one member to share the expense with',
        );
        return;
      }

      // Get category ID from dynamic mapping
      String? categoryId = categoryIdMap[selectedType.value];

      // If category ID not found, show error
      if (categoryId == null || categoryId.isEmpty) {
        Get.snackbar(
          'Error',
          'Category ID not found. Please select a valid category.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Prepare request body
      final requestBody = {
        "expenseDate":
            selectedDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        "totalExpenseAmount": int.tryParse(totalAmountController.text) ?? 0,
        "currency": selectedCurrency.value
            .replaceAll('US\$', 'USD')
            .replaceAll('€', 'EUR')
            .replaceAll('¥', 'JPY')
            .replaceAll('₩', 'KRW'),
        "category": categoryId,
        "note": noteController.text.isEmpty
            ? "Expense note"
            : noteController.text,
        "paidBy": {"type": "individual", "memberEmail": paidByEmail},
        "shareWith": {
          "type": isEquallySelected.value ? "equal" : "custom",
          "members": shareWithEmails,
        },
      };

      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Build dynamic endpoint URL with current group ID
      String addGroupExpenseUrl;
      if (currentGroupId.value.isNotEmpty) {
        addGroupExpenseUrl = Urls.addGroupExpense(currentGroupId.value);
      } else {
        // Cannot proceed without a valid group ID
        Get.snackbar(
          'Error',
          'No group selected. Please select a group first.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Make API request
      var request = http.Request('POST', Uri.parse(addGroupExpenseUrl));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(responseString);

        if (responseData['success'] == true) {
          Get.snackbar(
            'Success',
            'Expense saved successfully!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Clear form after success
          clearForm();

          // Close any open bottomsheets
          Get.back();
        } else {
          Get.snackbar(
            'Error',
            responseData['message'] ?? 'Failed to save expense',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to save expense. Status: ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    totalAmountController.clear();
    noteController.clear();
    selectedCategoryName.value = '';
    selectedCategoryIcon.value = '';
    selectedType.value = '';
    selectedDate.value = DateTime.now();

    // Clear friend selection states
    clearFriendSelections();
  }

  // Separate method to clear only friend selections
  void clearFriendSelections() {
    friendCheckStates.clear();
    selectedSharedWithFriends.clear();
    selectedPaidByFriend.value = '';
    selectedSharedWithFriend.value = '';
    debugPrint('🧹 Cleared all friend selection states');
  }

  @override
  void onClose() {
    totalAmountController.dispose();
    noteController.dispose();
    totalAmountFocusNode.dispose();
    disposeFriendControllers();
    super.onClose();
  }
}
