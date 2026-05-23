class DeleteCardModel {
  int? isSuccessful;
  int? code;
  String? message;

  DeleteCardModel({this.isSuccessful, this.code, this.message});

  DeleteCardModel.fromJson(Map<String, dynamic> json) {
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
