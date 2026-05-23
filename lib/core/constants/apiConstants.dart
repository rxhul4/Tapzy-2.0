class ApiConstants{
  static String baseUrl = "https://dev.tapzy.in/api"; //QA URL
  // static String baseUrl = "https://profile.tapzy.in/api"; // Live URL
  static String loginApi = "$baseUrl/login";
  static String verifyOtp = "$baseUrl/verifyOtp";
  static String deleteCardApi = "$baseUrl/delete_digital_card";
  static String addSocialProfile = "$baseUrl/add_social_profile";
  static String editProfile = "$baseUrl/edit_user_profile";
  static String disableDigitalCard = "$baseUrl/disable_digital_card";
  static String addBusinessProfile = "$baseUrl/add_business_profile";
  static String editBusinessProfile = "$baseUrl/edit_business_profile";
  static String getUserProfile = "$baseUrl/get_user_profile";
  static String getDigitalCard = "$baseUrl/get_digital_card";
  static String getBusinessProfile = "$baseUrl/get_business_profile";
  static String linkCard = "$baseUrl/link_card";
  static String getSharedContacts = "$baseUrl/get_shared_contacts";
  static String scanPaperCard = "$baseUrl/scan_paper_card";
  static String editSharedContact = "$baseUrl/edit_shared_contact";
  static String deleteSharedContact = "$baseUrl/delete_shared_contact";
  static String getNotifications = "$baseUrl/get_notifications";
  static String deleteNotification = "$baseUrl/delete_notification";
  static String registerFcmToken = "$baseUrl/register_fcm_token";
  static String getAnalytics = "$baseUrl/get_analytics";
  static String clearAnalytics = "$baseUrl/clear_analytics";
}