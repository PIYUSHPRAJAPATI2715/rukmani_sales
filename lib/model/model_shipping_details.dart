class ModelShippingAddress {
  int? shippingAmount;
  int? minFreeShipping;
  String? shopName;
  String? upiId;

  ModelShippingAddress({this.shippingAmount, this.minFreeShipping, this.shopName, this.upiId});

  ModelShippingAddress.fromJson(Map<String, dynamic> json) {
    shippingAmount = json['shipping_amount'];
    minFreeShipping = json['min_free_shipping'];
    shopName = json['shop_name'];
    upiId = json['upi_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['shipping_amount'] = shippingAmount;
    data['min_free_shipping'] = minFreeShipping;
    data['shop_name'] = shopName;
    data['upi_id'] = upiId;
    return data;
  }
}
