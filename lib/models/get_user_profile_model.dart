class GetUserProfileModel {
  int? isSuccessful;
  int? code;
  String? message;
  Data? data;

  GetUserProfileModel({this.isSuccessful, this.code, this.message, this.data});

  GetUserProfileModel.fromJson(Map<String, dynamic> json) {
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
  String? firstName;
  String? lastName;
  String? email;
  String? countryCode;
  String? phoneNumber;
  String? profileImage;

  Data(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.countryCode,
        this.phoneNumber,
        this.profileImage});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    countryCode = json['country_code'];
    phoneNumber = json['phone_number'];
    profileImage = json['profile_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['country_code'] = this.countryCode;
    data['phone_number'] = this.phoneNumber;
    data['profile_image'] = this.profileImage;
    return data;
  }
}
