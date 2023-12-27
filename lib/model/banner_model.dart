class BannerModel {
  String id; // Document ID from Firestore
  String imageUrl;

  BannerModel({
    required this.id,
    required this.imageUrl,
  });

  factory BannerModel.fromMap(String id, Map<String, dynamic> map) {
    return BannerModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}
