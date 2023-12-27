class ModelProfileData {
  String? address;
  String? profile;
  String? name;
  String? email;

  ModelProfileData({this.address, this.profile, this.name, this.email});

  ModelProfileData.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    profile = json['profile'] ?? "";
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['address'] = this.address;
    data['profile'] = this.profile;
    data['name'] = this.name;
    data['email'] = this.email;
    return data;
  }
}
