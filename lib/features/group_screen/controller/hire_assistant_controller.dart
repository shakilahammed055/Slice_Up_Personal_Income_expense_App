// import 'package:get/get.dart';
// import 'package:flutter/material.dart';

// class HireAssistantController extends GetxController {
//   final selectedPlan = 'ai_assistant'.obs;
//   final selectedPricing = 'free'.obs;
//   final isProcessing = false.obs;
//   final canHire = true.obs;

//   // Getter to check if premium features should be enabled
//   bool get isPremiumPlan =>
//       selectedPricing.value == 'monthly' || selectedPricing.value == 'yearly';

//   @override
//   void onInit() {
//     super.onInit();
//     // Update canHire based on initial selections
//     _updateCanHire();
//     // Listen to changes in selections
//     ever(selectedPlan, (_) => _updateCanHire());
//     ever(selectedPricing, (_) => _updateCanHire());
//   }

//   void selectPlan(String plan) {
//     selectedPlan.value = plan;
//   }

//   void selectPricing(String pricing) {
//     selectedPricing.value = pricing;
//   }

//   void showComingSoon() {
//     Get.snackbar(
//       'Coming Soon'.tr,
//       'This feature is not available yet.'.tr,
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.blue,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 2),
//     );
//   }

//   void _updateCanHire() {
//     // Disable hire button if no valid plan or pricing is selected
//     canHire.value =
//         selectedPlan.value.isNotEmpty &&
//         selectedPricing.value.isNotEmpty &&
//         !isProcessing.value;
//   }

//   void hireAssistant() async {
//     if (isProcessing.value || !canHire.value) return;

//     isProcessing.value = true;

//     try {
//       // Simulate API call or processing
//       await Future.delayed(const Duration(seconds: 2));

//       // Validate selections
//       if (selectedPlan.value.isEmpty) {
//         throw Exception('Please select a plan'.tr);
//       }
//       if (selectedPricing.value.isEmpty) {
//         throw Exception('Please select a pricing option'.tr);
//       }

//       // Here you would typically:
//       // 1. Make API call to process the hiring
//       // 2. Handle payment if needed (e.g., integrate with payment gateway)
//       // 3. Update user subscription status
//       // For demo purposes, show a success message
//       Get.snackbar(
//         'Success'.tr,
//         'Assistant hired successfully!\nPlan: ${selectedPlan.value}\nPricing: ${selectedPricing.value}',
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.green,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );

//       // Close bottom sheet after success
//       Get.back();
//     } catch (e) {
//       Get.snackbar(
//         'Error'.tr,
//         e.toString(),
//         snackPosition: SnackPosition.TOP,
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         duration: const Duration(seconds: 3),
//       );
//     } finally {
//       isProcessing.value = false;
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HireAssistantController extends GetxController {
  final selectedPlan = 'free'.obs;
  final selectedPricing = 'free'.obs;
  final isProcessing = false.obs;
  final canHire = true.obs;
  final planIds = <String, String>{'free': '', 'monthly': '', 'yearly': ''}.obs;
  final isLoading = true.obs;
  final sessionId = ''.obs; // Store the session_id from the hire response
  final isPaymentConfirmed = false.obs; // Track payment confirmation state

  bool get isPremiumPlan =>
      selectedPricing.value == 'monthly' || selectedPricing.value == 'yearly';

  @override
  void onInit() {
    super.onInit();
    _fetchPlans().then((_) => isLoading.value = false);
    _updateCanHire();
    ever(selectedPlan, (_) => _updateCanHire());
    ever(selectedPricing, (_) => _updateCanHire());
  }

  Future<void> _fetchPlans() async {
    final String? approvalToken = await AuthService.getApprovalToken();
    debugPrint('Approval Token: $approvalToken');
    if (approvalToken == null || approvalToken.isEmpty) {
      debugPrint('No approval token found');
      EasyLoading.showError('No authentication token found');
      isLoading.value = false;
      return;
    }

    try {
      final dio = Dio();
      final response = await dio.get(
        'https://teddybackend-mivk.onrender.com/api/v1/plans',
        options: Options(headers: {'Authorization': approvalToken}),
      );

      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Full Response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Parsed Data: $data');
        final plansData = data['data'];
        if (plansData != null && plansData['plans'] != null && plansData['plans'] is List && (plansData['plans'] as List).isNotEmpty) {
          final plans = plansData['plans'] as List;
          debugPrint('Plans List: $plans');
          final newPlanIds = {'free': '', 'monthly': '', 'yearly': ''};
          for (var plan in plans) {
            final name = plan['name']?.toString().toLowerCase() ?? '';
            final id = plan['_id']?.toString() ?? '';
            if (name.contains('free')) newPlanIds['free'] = id;
            else if (name.contains('monthly')) newPlanIds['monthly'] = id;
            else if (name.contains('yearly')) newPlanIds['yearly'] = id;
          }
          planIds.assignAll(newPlanIds);
          debugPrint('Updated Plan IDs: $newPlanIds');
        } else {
          debugPrint('Invalid plans data structure: $plansData');
          EasyLoading.showError('Plans data is missing or invalid');
        }
      } else {
        debugPrint('API Error: Status Code ${response.statusCode}, Data: ${response.data}');
        EasyLoading.showError('Failed to fetch plans');
      }
    } catch (e) {
      debugPrint('Error fetching plans: $e');
      EasyLoading.showError('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectPlan(String plan) {
    debugPrint('Selected Plan: $plan, Plan ID: ${planIds[plan] ?? 'Not found'}');
    selectedPlan.value = plan;
  }

  void selectPricing(String pricing) {
    debugPrint('Selected Pricing: $pricing, Plan ID: ${planIds[pricing] ?? 'Not found'}');
    selectedPricing.value = pricing;
  }

  void showComingSoon() {
    EasyLoading.showInfo(
      'This feature is not available yet'.tr,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateCanHire() {
    canHire.value =
        selectedPlan.value.isNotEmpty &&
        selectedPricing.value.isNotEmpty &&
        !isProcessing.value;
    debugPrint('Can Hire Updated: ${canHire.value}, Plan: ${selectedPlan.value}, Pricing: ${selectedPricing.value}, Plan ID: ${planIds[selectedPricing.value] ?? 'Not found'}');
  }

  Future<void> hireAssistant() async {
    if (isProcessing.value || !canHire.value) return;

    isProcessing.value = true;

    try {
      if (selectedPlan.value.isEmpty) {
        throw Exception('Please select a plan'.tr);
      }
      if (selectedPricing.value.isEmpty) {
        throw Exception('Please select a pricing option'.tr);
      }

      String planId = planIds[selectedPricing.value] ?? '';
      if (planId.isEmpty) {
        throw Exception('Invalid plan selected'.tr);
      }

      debugPrint('Hiring Assistant with Plan ID: $planId');
      final dio = Dio();
      final response = await dio.post(
        'https://teddybackend-mivk.onrender.com/api/v1/payment/create-checkout-session',
        data: {'planId': planId},
        options: Options(headers: {'Authorization': '${await AuthService.getApprovalToken()}'}),
      );

      debugPrint('Payment Response: ${response.data}, Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['url'] != null) {
          final url = data['url'].toString();
          if (await canLaunch(url)) {
            await launch(url); // Open the URL immediately
          } else {
            throw Exception('Could not launch URL: $url');
          }
          if (data['id'] != null) {
            sessionId.value = data['id'].toString(); // Store session_id for confirmation
            isPaymentConfirmed.value = false; // Reset confirmation state
            debugPrint('Session ID stored: ${sessionId.value}');
          } else {
            throw Exception('Invalid response: Missing session ID');
          }
        } else {
          throw Exception('Invalid response: Missing URL or session ID');
        }
      } else {
        final responseData = response.data;
        final errorMessage = responseData is Map && responseData['message'] != null
            ? responseData['message'].toString()
            : 'Unknown error';
        debugPrint('Error Response Data: $responseData');
        throw Exception('Failed to create checkout session: $errorMessage');
      }
    } catch (e) {
      EasyLoading.showError(
        e.toString(),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> confirmPayment() async {
    if (isProcessing.value || sessionId.value.isEmpty) return;

    isProcessing.value = true;

    try {
      debugPrint('Verifying Payment with Session ID: ${sessionId.value}');
      final dio = Dio();
      final response = await dio.post(
        'https://teddybackend-mivk.onrender.com/api/v1/payment/verify-payment?session_id=${sessionId.value}',
        options: Options(headers: {'Authorization': '${await AuthService.getApprovalToken()}'}),
      );

      debugPrint('Verify Payment Response: ${response.data}, Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data['status'] == 'success') {
          isPaymentConfirmed.value = true;
          EasyLoading.showSuccess(
            'Payment verified successfully!'.tr,
            duration: const Duration(seconds: 3),
          );
          Get.back(); // Close the bottom sheet
        } else {
          throw Exception('Payment verification failed: ${data['message'] ?? 'Unknown error'}');
        }
      } else {
        final responseData = response.data;
        final errorMessage = responseData is Map && responseData['message'] != null
            ? responseData['message'].toString()
            : 'Unknown error';
        debugPrint('Error Response Data: $responseData');
        throw Exception('Failed to verify payment: $errorMessage');
      }
    } catch (e) {
      EasyLoading.showError(
        e.toString(),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isProcessing.value = false;
    }
  }
}