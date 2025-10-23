import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';

class GroupEditController extends GetxController {
  var isChecking = false.obs;
  var isDeleting = false.obs;

  /// Checks whether a group can be deleted by querying the slice-up endpoint.
  /// Returns true when no outstanding settlements are present (deletable).
  Future<bool> canDeleteGroup(String groupId) async {
    isChecking.value = true;
    try {
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Authentication error', 'Please login again');
        return false;
      }

      final Uri url = Uri.parse(Urls.getSliceUp(groupId));
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // We expect the API to return a list or data structure containing settlements.
        // If there are no settlements, it's safe to delete the group.
        if (data == null) return false;

        // Try common shapes: data['data']['settlements'] or data['data'] as list
        final payload = data['data'];
        if (payload == null) return true; // no data, assume deletable

        if (payload is Map) {
          // If backend explicitly indicates everything is settled, allow delete
          if (payload['isAllSettled'] != null &&
              payload['isAllSettled'] == true) {
            return true;
          }

          if (payload['settlements'] != null) {
            final settlements = payload['settlements'];
            if (settlements is List && settlements.isEmpty) return true;
            return false;
          }
        }

        if (payload is List) {
          return payload.isEmpty;
        }

        // Fallback: if response contains an explicit flag
        if (data['success'] != null && data['success'] == true) return true;

        return false;
      } else {
        debugPrint(
          'canDeleteGroup failed: ${response.statusCode} ${response.body}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception in canDeleteGroup: $e');
      return false;
    } finally {
      isChecking.value = false;
    }
  }

  /// Calls the DELETE group API. Returns true on success.
  Future<bool> deleteGroup(String groupId) async {
    isDeleting.value = true;
    EasyLoading.show(status: 'Deleting group...');
    try {
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Authentication error', 'Please login again');
        return false;
      }

      final request = http.Request(
        'DELETE',
        Uri.parse(Urls.deleteGroup(groupId)),
      );
      request.headers.addAll({
        'Authorization': token,
        'Content-Type': 'application/json',
      });

      final streamed = await request.send();
      final respString = await streamed.stream.bytesToString();
      debugPrint('deleteGroup status: ${streamed.statusCode}');
      debugPrint('deleteGroup body: $respString');

      if (streamed.statusCode == 200) {
        final resp = jsonDecode(respString);
        // API shape may vary. Check common fields.
        if ((resp['success'] != null && resp['success'] == true) ||
            (resp['status'] != null && resp['status'] == 'success') ||
            (resp['message'] != null &&
                resp['message'].toString().toLowerCase().contains('deleted'))) {
          // Remove group locally if TripController present
          if (Get.isRegistered<TripController>()) {
            final TripController tripCtrl = Get.find<TripController>();
            tripCtrl.trips.removeWhere((t) => t.id == groupId);
          }
          EasyLoading.showSuccess('Group deleted successfully');
          return true;
        } else {
          // not deleted; message likely contains outstanding debts
          final msg = resp['message'] ?? 'Failed to delete group';
          Get.snackbar('Failed', msg.toString());
          return false;
        }
      } else {
        Get.snackbar(
          'Failed',
          'Failed to delete group: ${streamed.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Exception in deleteGroup: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isDeleting.value = false;
      EasyLoading.dismiss();
    }
  }
}
