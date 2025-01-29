class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String age;
  final String gender;
  final String mobileNumber;
  final String photoUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.age,
    required this.gender,
    required this.mobileNumber,
    required this.photoUrl,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'],
      age: json['age'].toString(),
      gender: json['gender'],
      mobileNumber: json['mobile_number'],
      photoUrl: json['photo_url'] ?? '',
    );
  }
}