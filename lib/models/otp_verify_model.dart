// edit_user_profile

class OtpVerifyModel {
  int? isSuccessful;
  int? code;
  String? message;
  Data? data;

  OtpVerifyModel({this.isSuccessful, this.code, this.message, this.data});

  OtpVerifyModel.fromJson(Map<String, dynamic> json) {
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
  int? userId;
  String? authToken;

  Data({this.userId, this.authToken});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    authToken = json['auth_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['auth_token'] = this.authToken;
    return data;
  }
}
