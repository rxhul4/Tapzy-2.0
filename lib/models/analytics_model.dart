class AnalyticsModel {
  bool? isSuccessful;
  int? code;
  String? message;
  AnalyticsData? data;

  AnalyticsModel({this.isSuccessful, this.code, this.message, this.data});

  AnalyticsModel.fromJson(Map<String, dynamic> json) {
    isSuccessful = json['isSuccessful'];
    code = json['code'];
    message = json['message'];
    data = json['data'] != null ? AnalyticsData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSuccessful'] = isSuccessful;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class AnalyticsData {
  int? totalViews;
  int? totalClicks;
  int? totalContacts;
  List<AnalyticsProfile>? profiles;
  List<ClicksBreakdown>? clicksBreakdown;
  List<ChartDataPoint>? chartData;

  AnalyticsData({
    this.totalViews,
    this.totalClicks,
    this.totalContacts,
    this.profiles,
    this.clicksBreakdown,
    this.chartData,
  });

  AnalyticsData.fromJson(Map<String, dynamic> json) {
    totalViews = json['total_views'];
    totalClicks = json['total_clicks'];
    totalContacts = json['total_contacts'];
    if (json['profiles'] != null) {
      profiles = <AnalyticsProfile>[];
      json['profiles'].forEach((v) {
        profiles!.add(AnalyticsProfile.fromJson(v));
      });
    }
    if (json['clicks_breakdown'] != null) {
      clicksBreakdown = <ClicksBreakdown>[];
      json['clicks_breakdown'].forEach((v) {
        clicksBreakdown!.add(ClicksBreakdown.fromJson(v));
      });
    }
    if (json['chart_data'] != null) {
      chartData = <ChartDataPoint>[];
      json['chart_data'].forEach((v) {
        chartData!.add(ChartDataPoint.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_views'] = totalViews;
    data['total_clicks'] = totalClicks;
    data['total_contacts'] = totalContacts;
    if (profiles != null) {
      data['profiles'] = profiles!.map((v) => v.toJson()).toList();
    }
    if (clicksBreakdown != null) {
      data['clicks_breakdown'] = clicksBreakdown!.map((v) => v.toJson()).toList();
    }
    if (chartData != null) {
      data['chart_data'] = chartData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AnalyticsProfile {
  int? id;
  String? type;
  String? label;

  AnalyticsProfile({this.id, this.type, this.label});

  AnalyticsProfile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    label = json['label'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['label'] = label;
    return data;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnalyticsProfile &&
        other.id == id &&
        other.type?.toLowerCase() == type?.toLowerCase();
  }

  @override
  int get hashCode => Object.hash(id, type?.toLowerCase());
}

class ClicksBreakdown {
  String? name;
  int? clicks;

  ClicksBreakdown({this.name, this.clicks});

  ClicksBreakdown.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    clicks = json['clicks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['clicks'] = clicks;
    return data;
  }
}

class ChartDataPoint {
  String? date;
  String? label;
  int? views;
  int? clicks;

  ChartDataPoint({this.date, this.label, this.views, this.clicks});

  ChartDataPoint.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    label = json['label'];
    views = json['views'];
    clicks = json['clicks'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['label'] = label;
    data['views'] = views;
    data['clicks'] = clicks;
    return data;
  }
}
