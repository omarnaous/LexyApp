class GoogleLocationModel {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  GoogleLocationModel({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory GoogleLocationModel.fromJson(Map<String, dynamic> json) {
    final location = json['geometry']['location'];
    return GoogleLocationModel(
      name: json['name'],
      address: json['formatted_address'],
      latitude: location['lat'],
      longitude: location['lng'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
