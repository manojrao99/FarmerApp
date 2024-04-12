class farmer_kuwait {
  int? farmlandid;
  String? farmlandname;
  int? farmerid;
  String? farmerName;
  String? alias;
  String ?sensordateandtime;
  String ?cretedateandtime;
  double ? mintempurature;
  double ? maxtempurature;
  double ? currenttempurature;
  double ? minhumidity;
  double ? maxhumidity;
  double ? currenthumidity;
  int? mobileNumberPrimary;
  String? famrlandAlias;
  String? farmerSectionType;
  int? deviceTypeID;
  String? hardwareSerialNumber;
  String? deviceEUIID;

  farmer_kuwait({this.farmlandid,
    this.farmlandname,
    this.farmerid,
    this.farmerName,
    this.alias,
    this.mobileNumberPrimary,
    this.famrlandAlias,
    this.farmerSectionType,
    this.deviceTypeID,
    this.sensordateandtime = '',
    this.cretedateandtime = '',
    this.hardwareSerialNumber,
    this.currenthumidity = 0.0,
    this.currenttempurature = 0.0,
    this.maxhumidity = 0.0,
    this.maxtempurature = 0.0,
    this.minhumidity = 0.0,
    this.mintempurature = 0.0,
    this.deviceEUIID});

  farmer_kuwait.fromJson(Map<String, dynamic> json) {
    farmlandid = json['farmlandid'];
    farmlandname = json['farmlandname'];
    farmerid = json['farmerid'];
    farmerName = json['FarmerName'];
    alias = json['Alias'];
    mobileNumberPrimary = json['MobileNumberPrimary'];
    famrlandAlias = json['FamrlandAlias'];
    farmerSectionType = json['FarmerSectionType'];
    deviceTypeID = json['DeviceTypeID'];
    hardwareSerialNumber = json['HardwareSerialNumber'];
    deviceEUIID = json['DeviceEUIID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['farmlandid'] = this.farmlandid;
    data['farmlandname'] = this.farmlandname;
    data['farmerid'] = this.farmerid;
    data['FarmerName'] = this.farmerName;
    data['Alias'] = this.alias;
    data['MobileNumberPrimary'] = this.mobileNumberPrimary;
    data['FamrlandAlias'] = this.famrlandAlias;
    data['FarmerSectionType'] = this.farmerSectionType;
    data['DeviceTypeID'] = this.deviceTypeID;
    data['HardwareSerialNumber'] = this.hardwareSerialNumber;
    data['DeviceEUIID'] = this.deviceEUIID;
    return data;
  }

  farmer_kuwait copyWith({
    int ?farmlandid,
    String? farmlandname,
    int? farmerid,
    String? farmerName,
    String? alias,
    String ?sensordateandtime,
    String ?cretedateandtime,
    double ? mintempurature,
    double ? maxtempurature,
    double ? currenttempurature,
    double ? minhumidity,
    double ? maxhumidity,
    double ? currenthumidity,
    int? mobileNumberPrimary,
    String? famrlandAlias,
    String? farmerSectionType,
    int? deviceTypeID,
    String? hardwareSerialNumber,
    String? deviceEUIID,
  }) {
    return farmer_kuwait(
      farmlandid: this.farmlandid ?? 0,
      farmlandname: this.farmlandname ?? "",
      farmerid: this.farmerid ?? 0,
      farmerName: this.farmerName ?? "",
      alias: this.alias ?? "",
      sensordateandtime: this.sensordateandtime ?? "",
      cretedateandtime: this.cretedateandtime ?? "",
      mintempurature: this.mintempurature ?? 0.0,
      maxtempurature: this.maxtempurature ?? 0.0,
      currenttempurature: this.currenttempurature ?? 0.0,
      minhumidity: this.minhumidity ?? 0.0,
      maxhumidity: this.maxhumidity ?? 0.0,
      currenthumidity: this.currenthumidity ?? 0.0,
      mobileNumberPrimary: this.mobileNumberPrimary,
      famrlandAlias: this.famrlandAlias ?? "",
      farmerSectionType: this.farmerSectionType ?? "",
      deviceTypeID: this.deviceTypeID ?? 0,
      hardwareSerialNumber: this.hardwareSerialNumber ?? "",
      deviceEUIID: this.deviceEUIID ?? "",
    );
  }
}