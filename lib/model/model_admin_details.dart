class ModelAdminDetails {
  List<dynamic>? number;

  ModelAdminDetails({this.number});

  ModelAdminDetails.fromJson(Map<String, dynamic> json) {
    number = json['number'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['number'] = number;
    return data;
  }
}
