class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final String phoneNumber;
  final String address;
  final bool isAnonymous;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.phoneNumber = '',
    this.address = '742 Evergreen Terrace, New York, NY 10001',
    this.isAnonymous = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'address': address,
      'isAnonymous': isAnonymous,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return UserModel(
      id: docId ?? map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Fashion Connoisseur',
      photoUrl: map['photoUrl'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '742 Evergreen Terrace, New York, NY 10001',
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? address,
    bool? isAnonymous,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }
}
