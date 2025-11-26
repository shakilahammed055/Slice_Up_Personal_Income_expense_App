// lib/core/services/profile_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/localization/language_service.dart';

class ProfileService {
  static final dio.Dio _dio = dio.Dio();

  static Future<void> fetchProfileSettings({
    required Function(String) onAssistantTypeLoaded,
    required Function(String) onLanguageLoaded,
    required Function(String) onCurrencyLoaded,
    required Function(String) onNameLoaded,
    required Function(String) onEmailLoaded,
    required Function(String) onImageLoaded,
    required Function(int, int) onDateRangeLoaded,
  }) async {
    EasyLoading.show(status: 'Loading profile...');
    try {
      final String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        EasyLoading.showError('No authentication token');
        return;
      }

      final response = await _dio.get(
        Urls.getsettingprofile,
        options: dio.Options(headers: {'Authorization': token}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          // Assistant Type
          if (data['assistantType'] != null) {
            final String apiType = data['assistantType']
                .toString()
                .toLowerCase();
            String displayType = _apiAssistantTypeToDisplay(apiType);
            onAssistantTypeLoaded(displayType);
          }

          // Language
          if (data['language'] != null) {
            String displayLang = _apiLangToName(data['language']);
            onLanguageLoaded(displayLang);
            LanguageService.updateLocale(nameToLocale(displayLang));
          }

          // Currency
          if (data['preferredCurrency'] != null) {
            onCurrencyLoaded(data['preferredCurrency']);
          }

          // Name & Email
          onNameLoaded(data['name'] ?? '');
          onEmailLoaded(data['email'] ?? '');

          // Profile Image
          if (data['img'] != null &&
              data['img'].toString().startsWith('http')) {
            onImageLoaded(data['img']);
          }

          // Date Range
          if (data['startDate'] != null && data['endDate'] != null) {
            try {
              final start = DateTime.parse(data['startDate']).day;
              final end = DateTime.parse(data['endDate']).day;
              onDateRangeLoaded(start, end);
            } catch (e) {
              debugPrint('Date parse error: $e');
            }
          }

          EasyLoading.showSuccess('Profile loaded');
        }
      }
    } catch (e) {
      debugPrint('Profile fetch error: $e');
      EasyLoading.showError('Failed to load profile');
    } finally {
      EasyLoading.dismiss();
    }
  }

  static String _apiAssistantTypeToDisplay(String apiType) {
    switch (apiType) {
      case 'supportive':
      case 'supportive_friendly':
        return 'Supportive & Friendly'.tr;
      case 'sarcastictruth-teller':
      case 'sarcastic':
        return 'Sarcastic Truth-Teller'.tr;
      case 'none':
        return '';
      default:
        return 'Supporter'.tr;
    }
  }

  static String _apiLangToName(String apiLang) {
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

  static Locale nameToLocale(String name) {
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
}
