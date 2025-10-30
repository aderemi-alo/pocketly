class UpdateProfileRequest {
  const UpdateProfileRequest({required this.name});

  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name};
  }

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) {
    return UpdateProfileRequest(name: json['name'] as String);
  }
}
