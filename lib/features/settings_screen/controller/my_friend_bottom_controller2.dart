import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

class MyFriendBottomController2 extends GetxController {
  final RxList<Friend> myFriends = <Friend>[].obs; // Explicitly initialized

  @override
  void onInit() async {
    super.onInit();
    await fetchFriends();
  }

  // Fetch friends from the API
  Future<void> fetchFriends() async {
    EasyLoading.show(status: 'Loading friends...');
    try {
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        EasyLoading.showError('No authentication token found');
        return;
      }

      final dio.Dio dioInstance = dio.Dio();
      final dio.Response response = await dioInstance.get(
        Urls.allfriends,
        options: dio.Options(headers: {'Authorization': approvalToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        debugPrint('Fetch Friends API Response: $responseData');
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          dynamic data = responseData['data'];
          List<dynamic> friendsList = [];
          if (data is List<dynamic>) {
            friendsList = data;
          } else if (data is Map<String, dynamic> && data['details'] != null) {
            dynamic details = data['details'];
            if (details is Map<String, dynamic> && details['success'] is List<dynamic>) {
              friendsList = details['success'];
            }
          }
          myFriends.clear();
          for (var friend in friendsList) {
            if (friend is Map<String, dynamic>) {
              myFriends.add(
                Friend(
                  name: friend['name'] ?? friend['email'].split('@')[0].capitalizeFirst ?? 'Friend',
                  email: friend['email'] ?? '',
                ),
              );
            }
          }
          // Update friend count in SettingController
          final SettingController settingController = Get.find<SettingController>();
          settingController.friends.assignAll(myFriends);
          settingController.friendCount.value = myFriends.length;
          EasyLoading.showSuccess('Friends loaded');
        } else {
          EasyLoading.showError('Unexpected response format from server');
          myFriends.clear(); // Ensure list is empty on failure
        }
      } else {
        EasyLoading.showError('Failed to load friends: ${response.statusCode}');
        myFriends.clear(); // Ensure list is empty on failure
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to load friends';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
      myFriends.clear(); // Ensure list is empty on exception
    } catch (e) {
      EasyLoading.showError('Unexpected error occurred: $e');
      myFriends.clear(); // Ensure list is empty on unexpected error
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Add multiple friends via the API
  Future<void> addFriends(List<String> emails) async {
    EasyLoading.show(status: 'Adding friends...');
    try {
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        EasyLoading.showError('No authentication token found');
        return;
      }

      final dio.Dio dioInstance = dio.Dio();
      final List<Map<String, String>> requestBody = emails
          .map((email) => {'email': email})
          .toList();
      
      final dio.Response response = await dioInstance.post(
        Urls.addfriends,
        data: requestBody,
        options: dio.Options(
          headers: {
            'Authorization': approvalToken,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        dynamic responseData = response.data;
        debugPrint('API Response: $responseData'); // Debug the response
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          dynamic data = responseData['data'];
          if (data is Map<String, dynamic> && data['details'] != null) {
            dynamic details = data['details'];
            if (details is Map<String, dynamic> && details['success'] is List<dynamic>) {
              List<dynamic> newFriendsList = details['success'];
              for (var friend in newFriendsList) {
                if (friend is Map<String, dynamic>) {
                  Friend newFriend = Friend(
                    name: friend['name'] ?? friend['email'].split('@')[0].capitalizeFirst ?? 'Friend',
                    email: friend['email'] ?? '',
                  );
                  if (!myFriends.any((existingFriend) => existingFriend.email == newFriend.email)) {
                    myFriends.add(newFriend);
                  }
                }
              }
              // Update friend count in SettingController
              final SettingController settingController = Get.find<SettingController>();
              settingController.friends.assignAll(myFriends);
              settingController.friendCount.value = myFriends.length;
              EasyLoading.showSuccess('Friends added successfully');
            } else {
              EasyLoading.showError('No success list found in response details');
            }
          } else {
            EasyLoading.showError('Unexpected data format in response');
          }
        } else {
          EasyLoading.showError('Unexpected response format from server');
        }
      } else {
        EasyLoading.showError('Failed to add friends: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to add friends';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Invalid email(s) provided.';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
    } catch (e) {
      EasyLoading.showError('Unexpected error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Remove a friend via the API
  Future<void> removeFriend(String email) async {
    EasyLoading.show(status: 'Removing friend...');
    try {
      final String? approvalToken = await AuthService.getApprovalToken();
      if (approvalToken == null || approvalToken.isEmpty) {
        EasyLoading.showError('No authentication token found');
        return;
      }

      final dio.Dio dioInstance = dio.Dio();
      final dio.Response response = await dioInstance.delete(
        '${Urls.deletefriend}$email',
        options: dio.Options(headers: {'Authorization': approvalToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        myFriends.removeWhere((friend) => friend.email == email);
        // Update friend count in SettingController
        final SettingController settingController = Get.find<SettingController>();
        settingController.friends.assignAll(myFriends);
        settingController.friendCount.value = myFriends.length;
        EasyLoading.showSuccess('$email has been removed from your list.');
      } else {
        EasyLoading.showError('Failed to remove friend: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'Failed to remove friend';
      if (e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == dio.DioExceptionType.badResponse) {
        errorMessage = 'Server error: ${e.response?.statusCode}';
        if (e.response?.statusCode == 401) {
          errorMessage = 'Authentication failed. Please login again.';
        } else if (e.response?.statusCode == 404) {
          errorMessage = 'Friend not found.';
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      EasyLoading.showError(errorMessage);
    } catch (e) {
      EasyLoading.showError('Unexpected error occurred: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }
}