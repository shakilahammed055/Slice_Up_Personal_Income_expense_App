import 'package:get/get.dart';
import 'package:teddy_5618/features/auth/screen/forget_password.dart';
import 'package:teddy_5618/features/auth/screen/forget_password_otp_screen.dart';
import 'package:teddy_5618/features/auth/screen/login_screen.dart';
import 'package:teddy_5618/features/auth/screen/otp_screen.dart';
import 'package:teddy_5618/features/auth/screen/reset_password.dart';
import 'package:teddy_5618/features/auth/screen/signup_screen.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/screen/bottom_navigationbar.dart';
import 'package:teddy_5618/features/chat_screen/screen/chat_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/expenses_page_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/group_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_spent_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/sliceup_page_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/status_page_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/bar_chart_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/filter_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/home_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/search_screen.dart';
import 'package:teddy_5618/features/profile_setup/screen/profile_setup_screen.dart';
import 'package:teddy_5618/features/set_expense_income/screen/expense_screen.dart';
import 'package:teddy_5618/features/settings_screen/screen/setting_screen.dart';
import 'package:teddy_5618/features/splash_screen/screen/splash_screen.dart';
import 'package:teddy_5618/features/splash_screen/screen/splash_screen1.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';

class AppRoute {
  static String loginScreen = "/loginScreen";
  static String splashscreen = "/splashscreen";
  static String splashscreen1 = "/splashscreen1";
  static String profileSetupScreen = "/profileSetupScreen";
  static String forgetPasswordScreen = "/forgetPasswordScreen";
  static String chatScreen = "/chatScreen";
  static String groupScreen = "/groupScreen";
  static String bottomNavbarView = "/bottomNavbarView";
  static String expensescreen = "/expensescreen";
  static String signupscreen = "/signupscreen";
  static String otpscreen = "/otpscreen";
  static String forgetpasswordotpscreen = "/forgetpasswordotpscreen";
  static String resetpassword = "/resetpassword";
  static String homescreen = "/homescreen";
  static String searchscreen = "/searchscreen";
  static String barChartscreen = "/barChartscreen";
  static String filterscreen = "/filterscreen";
  static String profileSetupscreen = "/profileSetupscreen";
  static String groupscreen = "/groupscreen";
  static String groupTripHomescreen = "/groupTripHomescreen";
  static String groupTripSpentscreen = "/groupTripSpentscreen";
  static String expensesPagescreen = "/expensesPagescreen";
  static String sliceUpPagescreen = "/sliceUpPagescreen";
  static String statusPagescreen = "/statusPagescreen";
  static String settingscreen = "/settingscreen";

  static String getLoginScreen() => loginScreen;
  static String getsplashscreen() => splashscreen;
  static String getsplashscreen1() => splashscreen1;
  static String getprofileSetupScreen() => profileSetupScreen;
  static String getforgetPasswordScreen() => forgetPasswordScreen;
  static String getchatScreen() => chatScreen;
  static String getgroupScreen() => groupScreen;
  static String getbottomNavbarView() => bottomNavbarView;
  static String getexpensescreen() => expensescreen;
  static String getsignupscreen() => signupscreen;
  static String getotpscreen() => otpscreen;
  static String getforgetpasswordotpscreen() => forgetpasswordotpscreen;
  static String getresetpassword() => resetpassword;
  static String gethomescreen() => homescreen;
  static String getsearchscreen() => searchscreen;
  static String getbarChartscreen() => barChartscreen;
  static String getfilterscreen() => filterscreen;
  static String getprofileSetupscreen() => profileSetupscreen;
  static String getgroupscreen() => groupscreen;
  static String getgroupTripHomescreen() => groupTripHomescreen;
  static String getgroupTripSpentscreen() => groupTripSpentscreen;
  static String getexpensesPagescreen() => expensesPagescreen;
  static String getsliceUpPagescreen() => sliceUpPagescreen;
  static String getstatusPagescreen() => statusPagescreen;
  static String getsettingscreen() => settingscreen;

  static List<GetPage> routes = [
    GetPage(name: loginScreen, page: () => LoginScreen()),
    GetPage(name: splashscreen, page: () => SplashScreen()),
    GetPage(name: splashscreen1, page: () => SplashScreen1()),
    GetPage(name: profileSetupScreen, page: () => ProfileSetupScreen()),
    GetPage(name: forgetPasswordScreen, page: () => ForgetPasswordScreen()),
    GetPage(name: chatScreen, page: () => ChatScreen()),
    GetPage(name: groupScreen, page: () => GroupScreen()),
    GetPage(name: bottomNavbarView, page: () => BottomNavbarView()),
    GetPage(name: expensescreen, page: () => ExpenseScreen()),
    GetPage(name: signupscreen, page: () => SignupScreen()),
    GetPage(name: otpscreen, page: () => OtpScreen()),
    GetPage(
      name: forgetpasswordotpscreen,
      page: () => ForgetPasswordOtpScreen(),
    ),
    GetPage(name: resetpassword, page: () => ResetPassword()),
    GetPage(name: homescreen, page: () => HomeScreen()),
    GetPage(name: searchscreen, page: () => SearchScreen()),
    GetPage(name: barChartscreen, page: () => BarChartScreen()),
    GetPage(name: filterscreen, page: () => FilterScreen()),
    GetPage(name: profileSetupscreen, page: () => ProfileSetupScreen()),
    GetPage(name: groupscreen, page: () => GroupScreen()),
    GetPage(
      name: groupTripHomescreen,
      page: () => GroupTripHomeScreen(trip: Get.arguments as Trip),
    ),
    GetPage(
      name: groupTripSpentscreen,
      page: () => GroupTripSpentScreen(groupId: Get.arguments as String?),
    ),
    GetPage(name: expensesPagescreen, page: () => ExpensesPageScreen()),
    GetPage(name: sliceUpPagescreen, page: () => SliceupPageScreen()),
    GetPage(
      name: statusPagescreen,
      page: () => StatusPageScreen(trip: Get.arguments as Trip?),
    ),
    GetPage(name: settingscreen, page: () => SettingScreen()),
  ];
}
