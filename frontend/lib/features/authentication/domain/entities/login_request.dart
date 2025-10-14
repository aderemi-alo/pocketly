class LoginRequest {
  final String email;
  final String password;
  final String deviceId;
  final String? name;

  const LoginRequest({
    required this.email,
    required this.password,
    required this.deviceId,
    this.name,
  });

  Map<String, dynamic> toJson() {
    final json = {'email': email, 'password': password, 'deviceId': deviceId};
    if (name != null) {
      json['name'] = name!;
    }
    return json;
  }

  @override
  String toString() => 'LoginRequest(email: $email, deviceId: $deviceId)';
}
