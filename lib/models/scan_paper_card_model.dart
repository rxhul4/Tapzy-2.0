class ScanPaperCardModel {
  int? isSuccessful;
  int? code;
  String? message;

  ScanPaperCardModel({this.isSuccessful, this.code, this.message});

  ScanPaperCardModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSuccessful'] = isSuccessful;
    data['code'] = code;
    data['message'] = message;
    return data;
  }
}
