import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';

// Single, clean implementation of the currency bottom sheet.
Future<void> showCurrencyBottom(
  BuildContext context, {
  required String selectedCurrency,
  required Future<bool> Function(String symbol) onCurrencySelected,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final screenHeight = MediaQuery.of(context).size.height;

  Future<List<Map<String, String>>> fetchCurrencies() async {
    try {
      final String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token');
      }

      final response = await http.get(
        Uri.parse(Urls.getcurrency),
        headers: {'Authorization': token},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to load currencies: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      debugPrint('🔍 [CURRENCY API] decoded response: $decoded');
      List<dynamic> raw = [];

      // Handle the API response: data is an array at root or under 'data' key
      if (decoded is List) {
        raw = decoded;
      } else if (decoded is Map) {
        if (decoded['data'] is List) {
          raw = decoded['data'];
        } else if (decoded['success'] == true) {
          // API returns { "success": true, "data": [...] }
          raw = decoded['data'] ?? [];
        }
      }

      final parsed = <Map<String, String>>[];
      for (var item in raw) {
        if (item is String) {
          final symbol = item.trim();
          final nameRaw = item.trim();
          final name = nameRaw.startsWith(symbol)
              ? nameRaw.substring(symbol.length).trim()
              : nameRaw;
          final display = (symbol + ' ' + name).trim();
          debugPrint(
            '🔍 [CURRENCY] raw string item: $item -> symbol="$symbol", label="$name", display="$display"',
          );
          parsed.add({'symbol': symbol, 'name': name, 'display': display});
        } else if (item is Map) {
          final symbol = (item['symbol'] ?? '').toString().trim();
          final label = (item['label'] ?? '').toString().trim();
          final display = (symbol + ' ' + label).trim();
          debugPrint(
            '🔍 [CURRENCY] raw map item: $item -> symbol="$symbol", label="$label", display="$display"',
          );
          parsed.add({'symbol': symbol, 'label': label, 'display': display});
        }
      }
      return parsed.isNotEmpty ? parsed : throw Exception('No currencies');
    } catch (e) {
      debugPrint('fetchCurrencies error: $e');
      return [
        {'symbol': 'S\$', 'name': 'Singapore dollar'},
        {'symbol': 'US\$', 'name': 'United States dollar'},
      ];
    }
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return FutureBuilder<List<Map<String, String>>>(
        future: fetchCurrencies(),
        builder: (c, snap) {
          final items = snap.data ?? [];
          if (snap.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Container(
            constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
            padding: EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF262626) : AppColors.textWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 48), // Placeholder for alignment
                    Expanded(
                      child: Text(
                        'Currency',
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24),
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(height: 1),
                    itemBuilder: (_, i) {
                      final it = items[i];

                      // Show only symbol and label
                      final symbol = (it['symbol'] ?? '').toString().trim();
                      final label = (it['label'] ?? '').toString().trim();
                      final display = (symbol + ' ' + label)
                          .trim(); // e.g. "A$ Australian dollar"

                      debugPrint(
                        '🧾 [CURRENCY LIST ITEM] raw=$it -> symbol="$symbol", label="$label", display="$display"',
                      );

                      final bool isSelected = selectedCurrency == symbol;

                      // Show symbol in the leading slot and the human-readable
                      // label in the title to avoid glyph/duplication issues.
                      // (display previously contained `symbol + ' ' + label`).
                      debugPrint(
                        '🔣 [CURRENCY CODEPOINTS] symbol=${symbol.codeUnits}, display=${display.codeUnits}',
                      );

                      return ListTile(
                        title: Text(
                          // Use label only for the title so the symbol doesn't
                          // depend on font fallback inside the main title text.
                          label,
                          style: getTextStyle2(
                            color: isSelected
                                ? AppColors.black
                                : Color(0xFF828282),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        leading: Text(
                          symbol,
                          style: getTextStyle2(
                            color: isSelected
                                ? AppColors.black
                                : Color(0xFF828282),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: AppColors.black)
                            : null,
                        onTap: () async {
                          // Pass only symbol to controller
                          debugPrint('✅ [CURRENCY] Selected Symbol: $symbol');
                          final ok = await onCurrencySelected(symbol);
                          if (ok) Get.back();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
