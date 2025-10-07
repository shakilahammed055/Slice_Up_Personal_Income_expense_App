import 'package:get/get.dart';
import 'package:flutter/material.dart';

class HireAssistantController extends GetxController {
  final selectedPlan = 'ai_assistant'.obs;
  final selectedPricing = 'free'.obs;
  final isProcessing = false.obs;
  final canHire = true.obs;

  // Getter to check if premium features should be enabled
  bool get isPremiumPlan =>
      selectedPricing.value == 'monthly' || selectedPricing.value == 'yearly';

  @override
  void onInit() {
    super.onInit();
    // Update canHire based on initial selections
    _updateCanHire();
    // Listen to changes in selections
    ever(selectedPlan, (_) => _updateCanHire());
    ever(selectedPricing, (_) => _updateCanHire());
  }

  void selectPlan(String plan) {
    selectedPlan.value = plan;
  }

  void selectPricing(String pricing) {
    selectedPricing.value = pricing;
  }

  void showComingSoon() {
    Get.snackbar(
      'Coming Soon'.tr,
      'This feature is not available yet.'.tr,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _updateCanHire() {
    // Disable hire button if no valid plan or pricing is selected
    canHire.value =
        selectedPlan.value.isNotEmpty &&
        selectedPricing.value.isNotEmpty &&
        !isProcessing.value;
  }

  void hireAssistant() async {
    if (isProcessing.value || !canHire.value) return;

    isProcessing.value = true;

    try {
      // Simulate API call or processing
      await Future.delayed(const Duration(seconds: 2));

      // Validate selections
      if (selectedPlan.value.isEmpty) {
        throw Exception('Please select a plan'.tr);
      }
      if (selectedPricing.value.isEmpty) {
        throw Exception('Please select a pricing option'.tr);
      }

      // Here you would typically:
      // 1. Make API call to process the hiring
      // 2. Handle payment if needed (e.g., integrate with payment gateway)
      // 3. Update user subscription status
      // For demo purposes, show a success message
      Get.snackbar(
        'Success'.tr,
        'Assistant hired successfully!\nPlan: ${selectedPlan.value}\nPricing: ${selectedPricing.value}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Close bottom sheet after success
      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        e.toString(),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isProcessing.value = false;
    }
  }
}
