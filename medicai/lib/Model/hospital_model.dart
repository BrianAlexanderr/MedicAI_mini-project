class Facility {
  final int facilityId;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final String? photoUrl;

  Facility({
    required this.facilityId,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.photoUrl,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      facilityId: json['facility_id'],
      name: json['name'],
      type: json['type'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      address: json['address'],
      photoUrl: json['photo_url'],
    );
  }
}
