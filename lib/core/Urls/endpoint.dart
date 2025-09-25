class Urls {
  static const baseUrl = "https://teddybackend-mivk.onrender.com/api/v1";
  static const createuser = "$baseUrl/users/createUser";
  static const verifyotp = "$baseUrl/auth/otpCrossCheck";
  static const resendOtp = "$baseUrl/auth/reSend_OTP";
  static const login = "$baseUrl/auth/login";
  static const sendotp = "$baseUrl/auth/send_OTP";
  static const forgetpassword = "$baseUrl/auth/forgetPassword";
  static const resetpassword = "$baseUrl/auth/resetPassword";
  static const uploadimage =
      "$baseUrl/users/uploadOrChangeImg?acctionType=upload";
  static const getsettingprofile = "$baseUrl/users/getSettingProfile";
  static const updateprofile = "$baseUrl/users/updateProfileData";
  static const addmultiplefriends = "$baseUrl/users/friends/add-multiple";
  static const allfriends = "$baseUrl/users/friends";
  static const creategroup = "$baseUrl/groupTransaction/createGroupTransaction";
  static const addfriends = "$baseUrl/users/friends/add-multiple";
  static const deletefriend = "$baseUrl/users/friends/";
  static const getallgroup = "$baseUrl/groupTransaction/getGroups";
  static const getallfriend = "$baseUrl/users/friends";
  static const updatecategory = "$baseUrl/users/categories/";
  static const addgroupcategory = "$baseUrl/users/categories/group";
  static const addpersonalcategory = "$baseUrl/users/categories/personal";
  static const getallcategory = "$baseUrl/users/categories";

  // Trip members endpoints
  static const removeTripMember = "$baseUrl/groupTransaction/members/remove";
  static const getGroups = "$baseUrl/groupTransaction/getGroups";

  // Dynamic methods for group-specific endpoints
  static String addGroupMember(String groupId) =>
      "$baseUrl/groupTransaction/addGroupMember/$groupId";
  static String addGroupExpense(String groupId) =>
      "$baseUrl/groupTransaction/addGroupExpense/$groupId";
  static String getGroupTransactions(String groupId) =>
      "$baseUrl/groupTransaction/getGroupTransactions/$groupId";
  static String getGroupDetails(String groupId) =>
      "$baseUrl/groupTransaction/getGroupDetails/$groupId";
  static String getGroupMembers(String groupId) =>
      "$baseUrl/groupTransaction/getGroupMembers/$groupId";
  static const postallgroupcategory = "$baseUrl/users/categories/group";
  static const getallgroupcategory = "$baseUrl/users/categories/group";
  static const deleteaccount = "$baseUrl/users/selfDestruct";
  static const getincomeandexpence =
      "$baseUrl/incomeAndExpences/getFilteredIncomeAndExpenses";
}
