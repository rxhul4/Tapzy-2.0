class AddBusinessModel {
  int? isSuccessful;
  int? code;
  String? message;

  AddBusinessModel({this.isSuccessful, this.code, this.message});

  AddBusinessModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isSuccessful'] = this.isSuccessful;
    data['code'] = this.code;
    data['message'] = this.message;
    return data;
  }
}
