class version {
  String? mobileAPPVersion;

  version({this.mobileAPPVersion});

  version.fromJson(Map<String, dynamic> json) {
    mobileAPPVersion = json['MobileAPPVersion'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MobileAPPVersion'] = this.mobileAPPVersion;
    return data;
  }
}