class UserModel {
  int? hostId;
  String email;
  String password;
  String confirmPassword;
  String mobileNo;
  String? createAt;   // Optional: used only if returned by API
  bool? isActive;     // Optional: used only if returned by API

  UserModel({
    this.hostId,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.mobileNo,
    this.createAt,
    this.isActive,
  });

  // From API response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      hostId: json['hostId'],
      email: json['email'],
      password: json['password'],
      confirmPassword: json['confirmPassword'] ?? '',
      mobileNo: json['mobileNo'],
      createAt: json['createAt'],
      isActive: json['isActive'] == 1 || json['isActive'] == true,
    );
  }

  // For sending to API (signup)
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'mobileNo': mobileNo,
    };
  }
  // Convert to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'hostId': hostId,
      'email': email,
      'password': password,
      'mobileNo': mobileNo,
      'createAt': createAt ?? DateTime.now().toIso8601String(),
      'isActive': (isActive ?? true) ? 1 : 0,
    };
  }

  // Convert from SQLite Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      hostId: map['hostId'],
      email: map['email'],
      password: map['password'],
      confirmPassword: map['password'], // db doesn't store confirmPassword
      mobileNo: map['mobileNo'],
      createAt: map['createAt'],
      isActive: map['isActive'] == 1,
    );
  }
}
