class NotificationsAll {
  int? userMasterID;
  String ?headder;
  String? criticality;
  String? message;
  String?title;
  bool? textvisuble;
  String ?prossestype;
  String? sentOn;


  NotificationsAll(
      {this.userMasterID,
      this.criticality,
      this.message,
      this.sentOn,
        this.title,
        this.headder,
        this.prossestype,
      this.textvisuble});

  NotificationsAll.fromJson(Map<String, dynamic> json) {
    userMasterID = json['UserMasterID'];
    criticality = json['Criticality'];
    message = json['Message'];
    prossestype=json['ProcessType'];
    headder=json['fHeadder'];
    title=json['fTitle'];
    textvisuble = false;
    sentOn = json['SentOn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['UserMasterID'] = userMasterID;
    data['Criticality'] = criticality;
    data['Message'] = message;
    data['SentOn'] = sentOn;
    return data;
  }
}
