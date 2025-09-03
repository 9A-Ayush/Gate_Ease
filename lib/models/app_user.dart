class AppUser {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // resident, admin, guard, vendor
  final String flatNo;
  final String societyId;
  final String status; // active, pending, etc.
  final bool profileComplete;
  final String? profileImageUrl;
  final String? about; // About/bio information

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.flatNo,
    required this.societyId,
    required this.status,
    required this.profileComplete,
    this.profileImageUrl,
    this.about,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) => AppUser(
    uid: uid,
    name: map['name'] ?? '',
    email: map['email'] ?? '',
    phone: map['phone'] ?? '',
    role: map['role'] ?? '',
    flatNo: map['flat_no'] ?? '',
    societyId: map['society_id'] ?? '',
    status: map['status'] ?? '',
    profileComplete: map['profileComplete'] ?? false,
    profileImageUrl: map['profileImageUrl'],
    about: map['about'],
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'flat_no': flatNo,
    'society_id': societyId,
    'status': status,
    'profileComplete': profileComplete,
    'profileImageUrl': profileImageUrl,
    'about': about,
  };
}
