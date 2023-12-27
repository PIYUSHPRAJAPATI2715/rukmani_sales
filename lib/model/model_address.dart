class ModelAddress {
  String? title;
  String? address;
  // String? landmark;
  String? city;
  String? phone;


  ModelAddress({this.address, this.city, this.phone, this.title});

  ModelAddress.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    address = json['address'];
    // landmark = json['landmark'];
    city = json['city'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['address'] = address;
    // data['landmark'] = landmark;
    data['city'] = city;
    data['phone'] = phone;
    return data;
  }
}

class ModelCityList {
  List<String>? cityList = [];
  List<String>? cityListUPI = [];

  ModelCityList({this.cityList,this.cityListUPI});

  ModelCityList.fromJson(Map<String, dynamic> json) {
    if (json['cityList'] == null) {
      cityList = [];
    } else {
      cityList = json['cityList'].cast<String>();
    }
    if (json['upis'] == null) {
      cityListUPI = [];
    } else {
      cityListUPI = json['upis'].cast<String>();
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cityList'] = this.cityList;
    data['upis'] = this.cityListUPI;
    return data;
  }
}
