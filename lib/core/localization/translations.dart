import 'package:get/get.dart';
import 'package:teddy_5618/core/localization/language/english.dart';
import 'package:teddy_5618/core/localization/language/bahasa_indonesia.dart';
import 'package:teddy_5618/core/localization/language/japanese.dart';
import 'package:teddy_5618/core/localization/language/malay.dart';
import 'package:teddy_5618/core/localization/language/chinese.dart';
import 'package:teddy_5618/core/localization/language/korean.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': english,
    'id_ID': indonesia,
    'ja_JP': japanese,
    'ms_MY': malay,
    'zh_CN': chinese,
    'ko_KR': korean,
  };
}
