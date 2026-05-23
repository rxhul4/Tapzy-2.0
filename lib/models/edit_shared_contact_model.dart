class EditSharedContactModel {
  int? isSuccessful;
  int? code;
  String? message;

  EditSharedContactModel({this.isSuccessful, this.code, this.message});

  EditSharedContactModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['isSuccessful'] = isSuccessful;
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}
