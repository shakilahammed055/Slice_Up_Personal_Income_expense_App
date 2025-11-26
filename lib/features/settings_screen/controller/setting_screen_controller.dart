// ignore_for_file: unused_local_variable, use_build_context_synchronously

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart' hide Response;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/core/localization/language_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teddy_5618/features/auth/screen/login_screen.dart';

class Friend {
  final String name;
  final String email;

  Friend({required this.name, required this.email});
}

class SettingController extends GetxController {
  final selectedCategoryName = ''.obs;
  final selectedCategoryIcon = ''.obs;

  void selectCategory(String icon, String name) {
    selectedCategoryIcon.value = icon;
    selectedCategoryName.value = name;
  }

  final email = ''.obs;
  final userName = 'Jonathan'.obs;
  final friendCount = 3.obs;
  final dateRange = '24~26'.obs;
  final currency = 'S\$'.obs;
  final themeMode = 'Light'.obs;
  final assistantType = 'Supporter'.obs;
  final profileImagePath = ''.obs;
  final friends = <Friend>[
    Friend(name: 'Friend 1', email: 'friend1@gmail.com'),
    Friend(name: 'Friend 2', email: 'friend2@gmail.com'),
    Friend(name: 'Friend 3', email: 'friend3@gmail.com'),
  ].obs;
  var personalCategories = <String>[].obs;
  var groupCategories = <String>[].obs;
  var categoryDetails = <Map<String, dynamic>>[].obs;
  final selectedStartDate = (-1).obs;
  final selectedEndDate = (-1).obs;
  final RxBool isDateRangeSet = false.obs;

  var language = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadInitialSettings();
    await loadSavedLanguage();
    // Delay API calls until after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await fetchProfileSettings();
      await fetchCategories();
    });
  }

  Future<void> fetchCategories() async {
    try {
      final String? token = await _getTokenForSession();
      if (token == null || token.isEmpty) {
        debugPrint('Cannot fetch categories: missing auth token');
        return;
      }

      final response = await _dio.get(
        Urls.getallcategory,
        options: dio.Options(
          headers: {'Authorization': token},
          validateStatus: (_) => true,
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic> &&
            data['success'] == true &&
            data['data'] is List) {
          categoryDetails.clear();
          personalCategories.clear();
          groupCategories.clear();
          for (var category in data['data']) {
            if (category is Map<String, dynamic>) {
              categoryDetails.add(category);
              if (category['type'] == 'personal') {
                personalCategories.add(category['name']);
              } else if (category['type'] == 'group') {
                groupCategories.add(category['name']);
              }
            }
          }
        }
      } else {
        final message = response.data is Map<String, dynamic>
            ? response.data['message']
            : null;
        debugPrint(
          'Failed to fetch categories: status=${response.statusCode}, message=$message',
        );
        // EasyLoading.showError(
        //   message ?? 'Failed to fetch categories: ${response.statusCode}',
        // );
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException while fetching categories: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      EasyLoading.showError('Unable to fetch categories at the moment');
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> updatePersonalCategory(String name, BuildContext context) async {
    try {
      EasyLoading.show(status: 'Updating personal category...');
      final response = await dio.Dio().post(
        Urls.addpersonalcategory,
        data: {'name': name.isEmpty ? '🚗 Transport' : name},
        options: dio.Options(
          headers: {
            'Authorization': await AuthService.getApprovalToken() ?? '',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCategories();
        EasyLoading.showSuccess('Personal category updated');
        Navigator.pop(context); // Close the bottom sheet on success
      } else {
        EasyLoading.showError('Failed to update personal category');
      }
    } catch (e) {
      debugPrint('Error updating personal category: $e');
      EasyLoading.showError('Error updating personal category');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateGroupCategory(String name, BuildContext context) async {
    try {
      EasyLoading.show(status: 'Updating group category...');
      final response = await dio.Dio().post(
        Urls.addgroupcategory,
        data: {'name': name.isEmpty ? '👕 Fashion' : name},
        options: dio.Options(
          headers: {
            'Authorization': await AuthService.getApprovalToken() ?? '',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCategories();
        EasyLoading.showSuccess('Group category updated');
        Navigator.pop(context); // Close the bottom sheet on success
      } else {
        EasyLoading.showError('Failed to update group category');
      }
    } catch (e) {
      debugPrint('Error updating group category: $e');
      EasyLoading.showError('Error updating group category');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> updateExistingCategory(
    String newName,
    String categoryId,
    String type,
    BuildContext context,
  ) async {
    try {
      EasyLoading.show(status: 'Updating category...');
      final response = await dio.Dio().patch(
        '${Urls.updatecategory}$categoryId',
        data: {'name': newName, 'type': type},
        options: dio.Options(
          headers: {
            'Authorization': await AuthService.getApprovalToken() ?? '',
          },
        ),
      );
      if (response.statusCode == 200) {
        await fetchCategories();
        EasyLoading.showSuccess('Category updated');
        Navigator.pop(context); // Close the bottom sheet on success
      } else {
        EasyLoading.showError('Failed to update category');
      }
    } catch (e) {
      debugPrint('Error updating category: $e');
      EasyLoading.showError('Error updating category');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<bool> deleteCategoryViaAPI(
    String categoryId,
    String type,
    int index,
    BuildContext context,
  ) async {
    try {
      EasyLoading.show(status: 'Deleting category...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return false;
      }
      final response = await dio.Dio().delete(
        '$Urls/users/categories/$categoryId',
        options: dio.Options(
          headers: {
            'Authorization': approvalToken,
            'Content-Type': 'application/json',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (type == 'personal') {
          personalCategories.removeAt(index);
        } else {
          groupCategories.removeAt(index);
        }
        categoryDetails.removeWhere((detail) => detail['_id'] == categoryId);
        EasyLoading.showSuccess('Category deleted successfully');
        Navigator.pop(context); // Close the delete confirmation bottom sheet
        return true;
      } else {
        EasyLoading.showError(
          'Failed to delete category: ${response.statusCode}',
        );
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during delete: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to delete category';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Category not found';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
      return false;
    } catch (e) {
      debugPrint('Unexpected error during delete: $e');
      EasyLoading.showError('Unexpected error occurred');
      return false;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> loadInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString('themeMode');
    if (savedThemeMode != null) {
      themeMode.value = savedThemeMode;
      Get.changeThemeMode(
        savedThemeMode == 'Dark'.tr ? ThemeMode.dark : ThemeMode.light,
      );
    }
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('language');
    debugPrint('Loaded language from storage: $savedLanguage');
    if (savedLanguage != null) {
      language.value = savedLanguage;
      LanguageService.updateLocale(nameToLocale(savedLanguage));
    } else {
      language.value = 'English';
      await _saveLanguage('English');
      debugPrint('Default language set to: ${language.value}');
    }
  }

  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    debugPrint('Saved language to storage: $value');
    LanguageService.updateLocale(nameToLocale(value));
  }

  Future<void> _saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', value);
    Get.changeThemeMode(value == 'Dark'.tr ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> fetchProfileSettings() async {
    EasyLoading.show(status: 'Loading profile settings...');
    try {
      debugPrint('Fetching profile settings from API...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        // EasyLoading.showError('No authentication token found');
        return;
      }
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );

      final dio.Response response = await _dio.get(
        Urls.getsettingprofile,
        options: dio.Options(headers: {'Authorization': approvalToken}),
      );
      debugPrint('API response received: statusCode=${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          dynamic profileData = responseData['data'];
          if (profileData is Map<String, dynamic>) {
            if (profileData['name'] != null) {
              userName.value = profileData['name'];
            }
            if (profileData['email'] != null) {
              email.value = profileData['email'];
            }
            if (profileData['img'] != null &&
                profileData['img'].toString().startsWith('http')) {
              profileImagePath.value = profileData['img'];
            }
            if (profileData['friends'] != null) {
              friends.clear();
              List<dynamic> friendsList = profileData['friends'];
              for (var friend in friendsList) {
                if (friend is Map<String, dynamic>) {
                  friends.add(
                    Friend(
                      name: friend['name'] ?? 'Unknown',
                      email: friend['email'] ?? '',
                    ),
                  );
                }
              }
              friendCount.value = profileData['friendsCount'] ?? friends.length;
            }
            if (profileData['preferredCurrency'] != null) {
              currency.value = profileData['preferredCurrency'];
            }
            if (profileData['assistantType'] != null) {
              assistantType.value = _apiAssistantTypeToDisplay(
                profileData['assistantType'],
              );
            }
            if (profileData['language'] != null) {
              String apiLang = profileData['language'];
              String displayName = _apiLangToName(apiLang);
              language.value = displayName;
              await _saveLanguage(displayName);
              LanguageService.updateLocale(nameToLocale(displayName));
            }
            // Add date range handling
            if (profileData['startDate'] != null &&
                profileData['endDate'] != null) {
              try {
                DateTime startDate = DateTime.parse(profileData['startDate']);
                DateTime endDate = DateTime.parse(profileData['endDate']);
                selectedStartDate.value = startDate.day;
                selectedEndDate.value = endDate.day;
                isDateRangeSet.value = true;
                dateRange.value = '${startDate.day}~${endDate.day}';
                debugPrint('Set dateRange to: ${dateRange.value}');
              } catch (e) {
                debugPrint('Error parsing dates: $e');
                EasyLoading.showError('Invalid date format from server');
              }
            }
            debugPrint('Profile settings updated successfully');
            EasyLoading.showSuccess('Profile loaded');
          } else {
            debugPrint('No "data" object in response');
            EasyLoading.showError('Invalid response format from server');
          }
        } else {
          debugPrint('Unexpected response format: ${responseData.runtimeType}');
          EasyLoading.showError('Unexpected response format from server');
        }
      } else {
        debugPrint(
          'Fetch failed with status: ${response.statusCode}, response: ${response.data}',
        );
        EasyLoading.showError('Failed to load profile: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during fetch: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to load profile';
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
    } catch (e) {
      debugPrint('Unexpected error during fetch: $e');
      EasyLoading.showError('Unexpected error occurred');
    } finally {
      EasyLoading.dismiss();
    }
  }

  String _apiLangToName(String apiLang) {
    switch (apiLang.toLowerCase()) {
      case 'en':
        return 'English';
      case 'id':
        return 'Bahasa Indonesia';
      case 'ms':
        return 'Bahasa Malay';
      case 'ko':
        return '한국어';
      case 'zh':
        return '中文';
      case 'ja':
        return '日语';
      default:
        return 'English';
    }
  }

  String _apiAssistantTypeToDisplay(String apiType) {
    switch (apiType.toLowerCase()) {
      case 'supportive':
      case 'supportive_friendly':
        return 'Supportive & Friendly'.tr;
      case 'sarcastictruth-teller':
        return 'Sarcastic Truth-Teller'.tr;
      case 'none':
        return ''.tr;
      default:
        return 'Supporter'.tr;
    }
  }

  Future<bool> updateProfileName(String newName) async {
    EasyLoading.show(status: 'Updating name...');
    try {
      debugPrint('Updating profile name via API...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return false;
      }
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );
      final Map<String, dynamic> requestBody = {'name': newName};
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
          userName.value = newName;
          debugPrint('Name updated successfully via API');
          EasyLoading.showSuccess('Name updated successfully');
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
        EasyLoading.showError('Failed to update name: ${response.statusCode}');
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during update: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to update name';
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
          errorMessage = 'Invalid name provided.';
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

  Future<bool> updateLanguageViaAPI(String newLanguageDisplayName) async {
    EasyLoading.show(status: 'Updating language...');
    try {
      debugPrint('Updating language via API...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return false;
      }
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );
      String apiLanguageCode = _displayToApiLang(newLanguageDisplayName);
      debugPrint('Mapped language code for API: $apiLanguageCode');
      final Map<String, dynamic> requestBody = {'language': apiLanguageCode};
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
          language.value = newLanguageDisplayName;
          await _saveLanguage(newLanguageDisplayName);
          debugPrint('Language updated successfully via API');
          EasyLoading.showSuccess('Language updated successfully');
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
          'Failed to update language: ${response.statusCode}',
        );
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during update: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to update language';
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
          errorMessage = 'Invalid language provided.';
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

  Future<bool> updateCurrencyViaAPI(String newCurrency) async {
    EasyLoading.show(status: 'Updating currency...');
    try {
      debugPrint('Updating currency via API...');
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
        'preferredCurrency': newCurrency,
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
          currency.value = newCurrency;
          debugPrint('Currency updated successfully via API');
          EasyLoading.showSuccess('Currency updated successfully');
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
          'Failed to update currency: ${response.statusCode}',
        );
        return false;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during update: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to update currency';
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
          errorMessage = 'Invalid currency provided.';
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
          assistantType.value = newAssistantType;
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

  String _displayToApiLang(String displayName) {
    switch (displayName) {
      case 'English':
        return 'en';
      case 'Bahasa Indonesia':
        return 'id';
      case 'Bahasa Malay':
        return 'ms';
      case '한국어':
        return 'ko';
      case '中文':
        return 'zh';
      case '日语':
        return 'ja';
      default:
        return 'en';
    }
  }

  String _displayToApiAssistantType(String displayType) {
    switch (displayType) {
      case 'Supportive & Friendly':
        return 'supportive'; // Map to API value
      case 'Sarcastic Truth-Teller':
        return 'SarcasticTruth-Teller';
      case '':
        return 'None';
      default:
        return 'supportive'; // Default to supportive
    }
  }

  void updateLanguage(String name) {
    language.value = name;
    _saveLanguage(name);
    updateLanguageViaAPI(name);
  }

  void updateCurrency(String value) {
    currency.value = value;
    updateCurrencyViaAPI(value);
  }

  Locale nameToLocale(String name) {
    switch (name) {
      case 'Bahasa Indonesia':
        return const Locale('id', 'ID');
      case 'Bahasa Malay':
        return const Locale('ms', 'MY');
      case '한국어':
        return const Locale('ko', 'KR');
      case '中文':
        return const Locale('zh', 'CN');
      case '日语':
        return const Locale('ja', 'JP');
      default:
        return const Locale('en', 'US');
    }
  }

  String localeToName(Locale locale) {
    switch ('${locale.languageCode}_${locale.countryCode}') {
      case 'id_ID':
        return 'Bahasa Indonesia';
      case 'ms_MY':
        return 'Bahasa Malay';
      case 'ko_KR':
        return '한국어';
      case 'zh_CN':
        return '中文';
      case 'ja_JP':
        return '日语';
      default:
        return 'English';
    }
  }

  final ImagePicker _picker = ImagePicker();
  final dio.Dio _dio = dio.Dio();

  int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void updateField(RxString field, String value) {
    if (value.isNotEmpty) {
      field.value = value;
    }
  }

  void updateThemeMode(String value) {
    themeMode.value = value;
    _saveThemeMode(value);
  }

  void updateAssistantType(String value) {
    assistantType.value = value;
  }

  void setStartDate(int date) {
    selectedStartDate.value = date;
  }

  void setEndDate(int date) {
    selectedEndDate.value = date;
  }

  void clearMonthSettings() {
    selectedStartDate.value = -1;
    selectedEndDate.value = -1;
    isDateRangeSet.value = false;
    dateRange.value = '';
  }

  void saveDateRange() {
    if (selectedStartDate.value != -1 && selectedEndDate.value != -1) {
      int start = selectedStartDate.value;
      int end = selectedEndDate.value;
      DateTime now = DateTime.now();
      int currentYear = now.year;
      int currentMonth = now.month;
      int daysInStartMonth = getDaysInMonth(currentYear, currentMonth);
      int daysInEndMonth = getDaysInMonth(currentYear, currentMonth + 1);

      // Ensure start date is valid for the current month
      if (start > daysInStartMonth) {
        start = daysInStartMonth;
        selectedStartDate.value = start;
      }

      // Calculate end date as one month after start date, then subtract one day
      int endYear = currentYear;
      int endMonth = currentMonth + 1;
      if (endMonth > 12) {
        endMonth = 1;
        endYear += 1;
      }
      int endDay = start - 1; // Previous day relative to start
      if (endDay < 1) {
        // If endDay goes below 1, adjust to the last day of the previous month
        endMonth -= 1;
        if (endMonth < 1) {
          endMonth = 12;
          endYear -= 1;
        }
        endDay = getDaysInMonth(endYear, endMonth);
      } else if (endDay > daysInEndMonth) {
        endDay = daysInEndMonth; // Cap at last day of next month
      }

      String startDateStr =
          '$currentYear-${currentMonth.toString().padLeft(2, '0')}-${start.toString().padLeft(2, '0')}';
      String endDateStr =
          '$endYear-${endMonth.toString().padLeft(2, '0')}-${endDay.toString().padLeft(2, '0')}';

      dateRange.value = '$start~$endDay';
      isDateRangeSet.value = true;

      // Call API to update dates
      _updateDateRangeAPI(startDateStr, endDateStr);
    } else {
      EasyLoading.showError('Please select both Start and End dates');
    }
  }

  Future<void> _updateDateRangeAPI(String startDate, String endDate) async {
    EasyLoading.show(status: 'Updating date range...');
    try {
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return;
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
      } else {
        debugPrint(
          'Update failed with status: ${response.statusCode}, response: ${response.data}',
        );
        EasyLoading.showError(
          'Failed to update date range: ${response.statusCode}',
        );
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
    } catch (e) {
      debugPrint('Unexpected error during update: $e');
      EasyLoading.showError('Unexpected error occurred');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> pickImage(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        EasyLoading.showError('Camera access is required to take photos.');
        openAppSettings(); // Optional: guide user to settings
        return;
      }
    } else {
      // For gallery - use Permission.photos on Android 13+
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 33) {
          status = await Permission.photos.request();
        } else {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request(); // iOS uses photos
      }

      if (status.isDenied) {
        EasyLoading.showError('Gallery access is required to select photos.');
        return;
      }

      if (status.isPermanentlyDenied) {
        EasyLoading.showError(
          'Gallery access denied. Please enable in settings.',
        );
        openAppSettings();
        return;
      }
    }

    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null && await File(image.path).exists()) {
        EasyLoading.show(status: 'Uploading image...');
        final String? uploadedImageUrl = await _uploadImage(File(image.path));
        if (uploadedImageUrl != null) {
          profileImagePath.value = uploadedImageUrl;
          EasyLoading.showSuccess('Profile image updated');
        } else {
          profileImagePath.value = image.path;
          EasyLoading.showInfo('Using local image temporarily');
        }
      } else {
        EasyLoading.showInfo('No image selected');
      }
    } catch (e) {
      debugPrint('Image picker error: $e');
      EasyLoading.showError('Failed to pick image: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    debugPrint('Starting image upload process...');
    try {
      debugPrint('Retrieving approval token...');
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return null;
      }
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );
      debugPrint('Preparing form data...');
      final String fileName = imageFile.path.split('/').last;
      debugPrint('Image file name: $fileName');
      final dio.FormData formData = dio.FormData.fromMap({
        'files': await dio.MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      debugPrint('Form data prepared successfully');
      debugPrint('Sending POST request to API...');
      final dio.Response response = await _dio.post(
        Urls.uploadimage,
        data: formData,
        options: dio.Options(headers: {'Authorization': approvalToken}),
        onSendProgress: (sent, total) {
          debugPrint(
            'Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
          );
        },
      );
      debugPrint('API response received: statusCode=${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Parsing response data...');
        dynamic responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final String? imageUrl =
              responseData['img'] ??
              responseData['path'] ??
              responseData['url'] ??
              responseData['data']?['img'];
          debugPrint('Extracted image URL: $imageUrl');
          return imageUrl;
        } else if (responseData is String && responseData.startsWith('http')) {
          debugPrint('Direct URL received: $responseData');
          return responseData;
        } else {
          debugPrint('Unexpected response format: ${responseData.runtimeType}');
          EasyLoading.showError('Unexpected response format from server');
          return null;
        }
      } else {
        debugPrint(
          'Upload failed with status: ${response.statusCode}, response: ${response.data}',
        );
        EasyLoading.showError('Server error: ${response.statusCode}');
        return null;
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during upload: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to upload image';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 413) {
          errorMessage = 'Image file is too large.';
        } else if (e.response?.statusCode == 500) {
          errorMessage =
              'Server error: ${e.response?.data['message'] ?? 'Unexpected error'}';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
      return null;
    } catch (e) {
      debugPrint('Unexpected error during upload: $e');
      EasyLoading.showError('Unexpected error occurred');
      return null;
    }
  }
  // Future<String?> _uploadImage(File imageFile) async {
  //   debugPrint('Starting image upload process...');
  //   try {
  //     debugPrint('Retrieving approval token...');
  //     final String? approvalToken = await AuthService.getApprovalToken();
  //     if (approvalToken == null || approvalToken.isEmpty) {
  //       debugPrint('No approval token found');
  //       EasyLoading.showError('No authentication token found');
  //       return null;
  //     }
  //     debugPrint(
  //       'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
  //     );

  //     // Check if imageFile exists at the provided path
  //     if (!await imageFile.exists()) {
  //       debugPrint('File does not exist at path: ${imageFile.path}');
  //       EasyLoading.showError('Image file not found at the specified path');
  //       return null;
  //     }

  //     debugPrint('Preparing form data...');
  //     final String fileName = imageFile.path.split('/').last;
  //     debugPrint('Image file name: $fileName');

  //     final dio.FormData formData = dio.FormData.fromMap({
  //       'files': await dio.MultipartFile.fromFile(
  //         imageFile.path, // Send the full file path here
  //         filename: fileName, // Only the filename is required here
  //       ),
  //     });

  //     debugPrint('Form data prepared successfully');
  //     debugPrint('Sending POST request to API...');

  //     final dio.Response response = await _dio.post(
  //       Urls.uploadimage,
  //       data: formData,
  //       options: dio.Options(headers: {'Authorization': approvalToken}),
  //       onSendProgress: (sent, total) {
  //         debugPrint(
  //           'Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%',
  //         );
  //       },
  //     );

  //     debugPrint('API response received: statusCode=${response.statusCode}');
  //     debugPrint('Response data: ${response.data}');

  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       debugPrint('Parsing response data...');
  //       dynamic responseData = response.data;

  //       if (responseData is Map<String, dynamic>) {
  //         final String? imageUrl =
  //             responseData['img'] ??
  //             responseData['path'] ??
  //             responseData['url'] ??
  //             responseData['data']?['img'];
  //         debugPrint('Extracted image URL: $imageUrl');
  //         return imageUrl;
  //       } else if (responseData is String && responseData.startsWith('http')) {
  //         debugPrint('Direct URL received: $responseData');
  //         return responseData;
  //       } else {
  //         debugPrint('Unexpected response format: ${responseData.runtimeType}');
  //         EasyLoading.showError('Unexpected response format from server');
  //         return null;
  //       }
  //     } else {
  //       debugPrint(
  //         'Upload failed with status: ${response.statusCode}, response: ${response.data}',
  //       );
  //       EasyLoading.showError('Server error: ${response.statusCode}');
  //       return null;
  //     }
  //   } on dio.DioException catch (e) {
  //     debugPrint('DioException during upload: ${e.type}');
  //     debugPrint('Error message: ${e.message}');
  //     debugPrint('Response status: ${e.response?.statusCode}');
  //     debugPrint('Response data: ${e.response?.data}');

  //     String errorMessage = 'Failed to upload image';
  //     if (e.type == dio.DioExceptionType.connectionTimeout ||
  //         e.type == dio.DioExceptionType.sendTimeout ||
  //         e.type == dio.DioExceptionType.receiveTimeout) {
  //       errorMessage =
  //           'Connection timeout. Please check your internet connection.';
  //     } else if (e.type == dio.DioExceptionType.badResponse) {
  //       errorMessage = 'Server error: ${e.response?.statusCode}';
  //       if (e.response?.statusCode == 401) {
  //         errorMessage = 'Authentication failed. Please login again.';
  //       } else if (e.response?.statusCode == 413) {
  //         errorMessage = 'Image file is too large.';
  //       } else if (e.response?.statusCode == 500) {
  //         errorMessage =
  //             'Server error: ${e.response?.data['message'] ?? 'Unexpected error'}';
  //       }
  //     } else if (e.message != null) {
  //       errorMessage = e.message!;
  //     }

  //     EasyLoading.showError(errorMessage);
  //     return null;
  //   } catch (e) {
  //     debugPrint('Unexpected error during upload: $e');
  //     EasyLoading.showError('Unexpected error occurred');
  //     return null;
  //   }
  // }

  void addCategory(String type) {
    Get.defaultDialog(
      title: 'Add New Category',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(hintText: 'Enter category name'),
            onSubmitted: (name) {
              if (name.isNotEmpty) {
                if (type == 'Personal spending') {
                  personalCategories.add(name);
                } else if (type == 'Group spending') {
                  groupCategories.add(name);
                }
                Get.back();
                EasyLoading.showSuccess('Category added');
              }
            },
          ),
        ],
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
    );
  }

  void deleteCategory(String type, int index) {
    final categoryName = type == 'personal'
        ? personalCategories[index]
        : groupCategories[index];
    Get.defaultDialog(
      title: 'Delete Category',
      content: Text('Are you sure you want to delete $categoryName?'),
      confirm: ElevatedButton(
        onPressed: () {
          if (type == 'personal') {
            personalCategories.removeAt(index);
          } else {
            groupCategories.removeAt(index);
          }
          Get.back();
          EasyLoading.showSuccess('Category deleted');
        },
        child: Text('Delete'),
      ),
      cancel: TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
    );
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      await Future.delayed(Duration(seconds: 1));
      if (email.isEmpty ||
          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Invalid email address');
      }
      EasyLoading.showSuccess('Password reset link sent to $email');
    } catch (e) {
      EasyLoading.showError('Failed to send password reset link: $e');
    }
  }

  Future<void> logout() async {
    EasyLoading.show(status: 'Logging out...');
    try {
      final String? token = await _getTokenForSession();
      if (token == null || token.isEmpty) {
        debugPrint('Logout failed: missing auth token');
        EasyLoading.showError('No authentication token found');
        return;
      }
      final dio.Response response = await _dio.post(
        Urls.logout,
        options: dio.Options(
          headers: {'Authorization': token, 'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        await StorageService.logoutUser();
        await _clearAllLocalData();
        EasyLoading.showSuccess('Logged out successfully');
        Future.delayed(
          const Duration(milliseconds: 400),
          () => Get.offAll(LoginScreen()),
        );
      } else {
        debugPrint(
          'Logout failed: status=${response.statusCode}, data=${response.data}',
        );
        EasyLoading.showError('Failed to log out: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during logout: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      String errorMessage = 'Failed to log out';
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
    } catch (e) {
      debugPrint('Unexpected error during logout: $e');
      EasyLoading.showError('Unexpected error occurred');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> deleteAccount() async {
    try {
      EasyLoading.show(status: 'Deleting account...');

      // Get approval token
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        debugPrint('No approval token found');
        EasyLoading.showError('No authentication token found');
        return;
      }

      debugPrint('Starting account deletion via API...');
      debugPrint(
        'Approval token retrieved: ${approvalToken.substring(0, 20)}...',
      );

      // Make API call to delete account
      final dio.Response response = await _dio.delete(
        Urls.deleteaccount,
        options: dio.Options(
          headers: {
            'Authorization': approvalToken,
            'Content-Type': 'application/json',
          },
        ),
      );

      debugPrint('API response received: statusCode=${response.statusCode}');
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear all local data on successful deletion
        await _clearAllLocalData();

        // Show success message and navigate user away (likely to login screen)
        EasyLoading.showSuccess('Account deleted successfully');

        // Navigate to login screen or home screen
        Future.delayed(Duration(seconds: 1), () {
          Get.offAll(LoginScreen()); // Adjust route as needed
        });
      } else {
        debugPrint(
          'Delete failed with status: ${response.statusCode}, response: ${response.data}',
        );
        EasyLoading.showError(
          'Failed to delete account: ${response.statusCode}',
        );
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException during account deletion: ${e.type}');
      debugPrint('Error message: ${e.message}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');

      String errorMessage = 'Failed to delete account';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage =
            'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Account not found';
        } else if (e.response?.statusCode == 403) {
          errorMessage = 'You do not have permission to delete this account';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      EasyLoading.showError(errorMessage);
    } catch (e) {
      debugPrint('Unexpected error during account deletion: $e');
      EasyLoading.showError('Unexpected error occurred');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Helper method to clear all local data
  Future<void> _clearAllLocalData() async {
    try {
      // Clear all observable data
      userName.value = '';
      profileImagePath.value = '';
      email.value = '';
      friends.clear();
      friendCount.value = 0;
      personalCategories.clear();
      groupCategories.clear();
      categoryDetails.clear();
      clearMonthSettings();
      currency.value = 'S\$';
      language.value = 'English';
      themeMode.value = 'Light';
      assistantType.value = 'Supporter';

      // Clear authentication data
      await AuthService.clearAuthData();

      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all preferences or be more specific:
      // await prefs.remove('themeMode');
      // await prefs.remove('language');
      // await prefs.remove('approvalToken'); // if you store token here

      debugPrint('All local data cleared successfully');
    } catch (e) {
      debugPrint('Error clearing local data: $e');
    }
  }

  Future<String?> _getTokenForSession() async {
    String? token = await AuthService.getApprovalToken();
    if (token != null && token.isNotEmpty) {
      await _cacheTokenInStorage(token);
      return token;
    }
    try {
      await StorageService.init();
      token = StorageService.token;
    } catch (e) {
      debugPrint('Failed to initialize StorageService: $e');
    }
    return token;
  }

  Future<void> _cacheTokenInStorage(String token) async {
    try {
      await StorageService.init();
      final String? userId = await AuthService.getUserId();
      await StorageService.saveToken(token, userId ?? '');
    } catch (e) {
      debugPrint('Failed to cache token in StorageService: $e');
    }
  }
}
