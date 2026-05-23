class GetBusinessCardByIdModel {
  int? isSuccessful;
  int? code;
  String? message;
  Data? data;

  GetBusinessCardByIdModel(
      {this.isSuccessful, this.code, this.message, this.data});

  GetBusinessCardByIdModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  int? userId;
  String? cardLabel;
  String? profileImage;
  String? businessQrImage;
  String? businessUserName;
  String? industry;
  String? designation;
  String? company;
  String? bio;
  String? services;
  int? businessContact1;
  int? businessContact2;
  int? businessContact3;
  String? businessEmail;
  String? businessEmail2;
  int? businessWpNumber;
  String? businessMessangerId;
  String? addressLine1;
  String? addressLine2;
  String? addressLine3;
  String? businessProfileLink;
  String? websiteLinks;
  String? driveLink;
  String? docLink;
  String? cloudLink;
  String? skypeUsername;
  String? hangoutsUsername;
  String? twitterUsername;
  String? linkedinUsername;
  String? facebookUsername;
  String? instagramUsername;
  String? customLinkLabel;
  String? customLink;
  String? gpayNumberUpi;
  String? paypalNumberUpi;
  String? paytmNumberUpi;
  String? educationDetail;
  String? experienceDetail;
  String? hobbiesDetail;
  String? infoDetail;
  String? type;
  int? isActive;
  int? isImageSet;
  String? profilePrimaryColor;
  String? username;
  String? companyLogo;
  String? googleReviewLink;

  Data(
      {this.id,
        this.userId,
        this.cardLabel,
        this.profileImage,
        this.businessQrImage,
        this.businessUserName,
        this.industry,
        this.designation,
        this.company,
        this.bio,
        this.services,
        this.businessContact1,
        this.businessContact2,
        this.businessContact3,
        this.businessEmail,
        this.businessEmail2,
        this.businessWpNumber,
        this.businessMessangerId,
        this.addressLine1,
        this.addressLine2,
        this.addressLine3,
        this.businessProfileLink,
        this.websiteLinks,
        this.driveLink,
        this.docLink,
        this.cloudLink,
        this.skypeUsername,
        this.hangoutsUsername,
        this.twitterUsername,
        this.linkedinUsername,
        this.facebookUsername,
        this.instagramUsername,
        this.customLinkLabel,
        this.customLink,
        this.gpayNumberUpi,
        this.paypalNumberUpi,
        this.paytmNumberUpi,
        this.educationDetail,
        this.experienceDetail,
        this.hobbiesDetail,
        this.infoDetail,
        this.type,
        this.isActive,
        this.isImageSet,
        this.profilePrimaryColor,
        this.username,
        this.companyLogo,
        this.googleReviewLink,
      });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    cardLabel = json['card_label'];
    profileImage = json['profile_image'];
    businessQrImage = json['business_qr_image'];
    businessUserName = json['business_user_name'];
    industry = json['industry'];
    designation = json['designation'];
    company = json['company'];
    bio = json['bio'];
    services = json['services'];
    businessContact1 = json['business_contact_1'];
    businessContact2 = json['business_contact_2'];
    businessContact3 = json['business_contact_3'];
    businessEmail = json['business_email'];
    businessEmail2 = json['business_email_2'];
    businessWpNumber = json['business_wp_number'];
    businessMessangerId = json['business_messanger_id'];
    addressLine1 = json['address_line_1'];
    addressLine2 = json['address_line_2'];
    addressLine3 = json['address_line_3'];
    businessProfileLink = json['business_profile_link'];
    websiteLinks = json['website_links'];
    driveLink = json['drive_link'];
    docLink = json['doc_link'];
    cloudLink = json['cloud_link'];
    skypeUsername = json['skype_username'];
    hangoutsUsername = json['hangouts_username'];
    twitterUsername = json['twitter_username'];
    linkedinUsername = json['linkedin_username'];
    facebookUsername = json['facebook_username'];
    instagramUsername = json['instagram_username'];
    customLinkLabel = json['custom_link_label'];
    customLink = json['custom_link'];
    gpayNumberUpi = json['gpay_number_upi'];
    paypalNumberUpi = json['paypal_number_upi'];
    paytmNumberUpi = json['paytm_number_upi'];
    educationDetail = json['education_detail'];
    experienceDetail = json['experience_detail'];
    hobbiesDetail = json['hobbies_detail'];
    infoDetail = json['info_detail'];
    type = json['type'];
    isActive = json['is_active'];
    isImageSet = json['is_image_set'];
    profilePrimaryColor = json['profile_primary_color'];
    username = json['username'];
    companyLogo = json['company_logo'];
    googleReviewLink = json['google_review_link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['card_label'] = this.cardLabel;
    data['profile_image'] = this.profileImage;
    data['business_qr_image'] = this.businessQrImage;
    data['business_user_name'] = this.businessUserName;
    data['industry'] = this.industry;
    data['designation'] = this.designation;
    data['company'] = this.company;
    data['bio'] = this.bio;
    data['services'] = this.services;
    data['business_contact_1'] = this.businessContact1;
    data['business_contact_2'] = this.businessContact2;
    data['business_contact_3'] = this.businessContact3;
    data['business_email'] = this.businessEmail;
    data['business_email_2'] = this.businessEmail2;
    data['business_wp_number'] = this.businessWpNumber;
    data['business_messanger_id'] = this.businessMessangerId;
    data['address_line_1'] = this.addressLine1;
    data['address_line_2'] = this.addressLine2;
    data['address_line_3'] = this.addressLine3;
    data['business_profile_link'] = this.businessProfileLink;
    data['website_links'] = this.websiteLinks;
    data['drive_link'] = this.driveLink;
    data['doc_link'] = this.docLink;
    data['cloud_link'] = this.cloudLink;
    data['skype_username'] = this.skypeUsername;
    data['hangouts_username'] = this.hangoutsUsername;
    data['twitter_username'] = this.twitterUsername;
    data['linkedin_username'] = this.linkedinUsername;
    data['facebook_username'] = this.facebookUsername;
    data['instagram_username'] = this.instagramUsername;
    data['custom_link_label'] = this.customLinkLabel;
    data['custom_link'] = this.customLink;
    data['gpay_number_upi'] = this.gpayNumberUpi;
    data['paypal_number_upi'] = this.paypalNumberUpi;
    data['paytm_number_upi'] = this.paytmNumberUpi;
    data['education_detail'] = this.educationDetail;
    data['experience_detail'] = this.experienceDetail;
    data['hobbies_detail'] = this.hobbiesDetail;
    data['info_detail'] = this.infoDetail;
    data['type'] = this.type;
    data['is_active'] = this.isActive;
    data['is_image_set'] = this.isImageSet;
    data['profile_primary_color'] = this.profilePrimaryColor;
    data['username'] = this.username;
    data['company_logo'] = this.companyLogo;
    data['google_review_link'] = this.googleReviewLink;
    return data;
  }
}
