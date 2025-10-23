import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';

/// Simple friend model to keep name and email from the API
class Friend {
  final String name;
  final String email;

  Friend({required this.name, required this.email});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}

class MyFriendBottomController extends GetxController {
  final RxList<Friend> friends = <Friend>[].obs;
  final RxBool isLoading = true.obs;

  RxList<Friend> get myFriends => friends;

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      isLoading.value = true;
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }
      final Uri url = Uri.parse(Urls.allfriends);
      final Map<String, String> headers = {'Authorization': token};
      final http.Response response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> friendsData = responseData['data'] ?? [];
        final List<Friend> friendList = friendsData
            .map<Friend>((friend) => Friend.fromJson(friend))
            .toList();
        friends.assignAll(friendList);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load friends'.tr);
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- REMOVAL: keep using email as identifier but operate on Friend objects ---
  Future<void> removeFriend(String email) async {
    EasyLoading.show(status: 'Removing...'.tr);
    try {
      // 1. Get the authentication token
      final String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }

      // Save token to StorageService for other controllers that may need it
      try {
        await StorageService.saveToken(token, StorageService.userId ?? '');
      } catch (e) {
        debugPrint('Warning: failed to save token to StorageService: $e');
      }

      // 2. Check whether this friend is part of any group. If yes, show the
      // "can't delete yet" dialog and abort deletion.
      final bool inGroup = await _isFriendInAnyGroup(email, token);
      final ctx = Get.context;
      if (inGroup) {
        if (ctx != null) {
          showCupertinoDialog(
            // ignore: use_build_context_synchronously
            context: ctx,
            builder: (BuildContext context) => ConfirmationDialog(
              title: 'You can’t delete them yet'.tr,
              content:
                  'To delete them, they must be removed from your group, or you can delete the entire group.'
                      .tr,
              button1: 'Okay'.tr,
              singleButton: true,
              onConfirm: () {},
            ),
          );
        } else {
          Get.snackbar('Info'.tr, 'Cannot delete: member part of a group.'.tr);
        }
        return;
      }

      // 3. Prepare the request URL by adding the email to the path
      final Uri url = Uri.parse('${Urls.allfriends}/$email');

      final Map<String, String> headers = {
        'Authorization': token,
        'Content-Type': 'text/plain',
      };

      // 4. Make the DELETE request (no body is needed)
      final http.Response response = await http.delete(url, headers: headers);

      // 5. Handle the response
      if (response.statusCode == 200) {
        // If the API call is successful, remove the friend from the UI list
        friends.removeWhere((f) => f.email == email);
        EasyLoading.showSuccess('$email has been removed.');
      } else {
        // Try to parse error message
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to remove friend.');
        } catch (e) {
          throw Exception('Failed to remove friend: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Returns true if the given email is part of any group that the user has.
  /// This method fetches the user's groups and inspects member lists. It will
  /// try to avoid an excessive number of requests by first checking group
  /// objects for member lists, then falling back to fetching members per group
  /// if necessary.
  Future<bool> _isFriendInAnyGroup(String email, String token) async {
    try {
      final Uri url = Uri.parse(Urls.getallgroup);
      final Map<String, String> headers = {'Authorization': token};
      final http.Response response = await http.get(url, headers: headers);
      if (response.statusCode != 200) return false;

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      final dynamic groupsData = responseData['data'];

      List<dynamic> groups = [];
      // Try common shapes
      if (groupsData is Map && groupsData['groups'] is List) {
        groups = groupsData['groups'];
      } else if (groupsData is List) {
        groups = groupsData;
      }

      for (var g in groups) {
        if (g is Map) {
          final gid = (g['_id'] ?? g['id'] ?? '').toString();

          // If members are present in the group object, check them
          final membersInline =
              g['members'] ?? g['groupMembers'] ?? g['membersList'];
          if (membersInline is List) {
            for (var m in membersInline) {
              if (m is Map) {
                final memEmail = (m['email'] ?? m['memberEmail'] ?? '')
                    .toString();
                if (memEmail == email) return true;
              } else if (m is String) {
                if (m == email) return true;
              }
            }
          } else if (gid.isNotEmpty) {
            // Fallback: fetch group members for this group id
            try {
              final Uri memUrl = Uri.parse(Urls.getGroupMembers(gid));
              final http.Response memResp = await http.get(
                memUrl,
                headers: headers,
              );
              if (memResp.statusCode == 200) {
                final Map<String, dynamic> memData = jsonDecode(memResp.body);
                final dynamic memList = memData['data'];
                if (memList is List) {
                  for (var mm in memList) {
                    if (mm is Map) {
                      final memEmail = (mm['email'] ?? mm['memberEmail'] ?? '')
                          .toString();
                      if (memEmail == email) return true;
                    }
                  }
                } else if (memList is Map && memList['members'] is List) {
                  for (var mm in memList['members']) {
                    final memEmail = (mm['email'] ?? mm['memberEmail'] ?? '')
                        .toString();
                    if (memEmail == email) return true;
                  }
                }
              }
            } catch (e) {
              debugPrint('Warning: failed to fetch members for group $gid: $e');
            }
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('_isFriendInAnyGroup error: $e');
      return false;
    }
  }
}
