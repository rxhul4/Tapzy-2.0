class LoginModel {
  int? isSuccessful;
  int? code;
  String? message;
  Data? data;

  LoginModel({this.isSuccessful, this.code, this.message, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  int? isNew;

  Data({this.userId, this.isNew});

  Data.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    isNew = json['isNew'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['isNew'] = this.isNew;
    return data;
  }
}
